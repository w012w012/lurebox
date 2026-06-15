import 'package:lurebox/core/constants/constants.dart';
import 'package:lurebox/core/constants/pagination_constants.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/fish_filter.dart';
import 'package:lurebox/core/repositories/base_repository.dart';
import 'package:lurebox/core/repositories/fish_catch_repository.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;

/// SQLite 瀹炵幇 - 娓旇幏璁板綍浠撳偍灞?
///
/// 浣跨敤 SQLite 鏁版嵁搴撳疄鐜版笖鑾疯褰曠殑鏁版嵁璁块棶銆?
/// 鏁版嵁琛ㄥ悕锛歠ish_catches

class SqliteFishCatchRepository extends BaseSqliteRepository
    implements FishCatchRepository {
  SqliteFishCatchRepository();

  SqliteFishCatchRepository.withDatabase(super.testDb) : super.withDatabase();
  @override
  String get tableName => 'fish_catches';

  /// 转义 LIKE 通配符（LOW-1）。
  ///
  /// 用户输入中的 `%` `_` 会被 SQLite 当作通配符，导致「过度匹配」
  /// （例如搜索 "50%" 会匹配任意以 50 开头的内容）。这里转义 `\` `%` `_`，
  /// 并在 LIKE 子句后追加 `ESCAPE '\'`，使其按字面量匹配。
  /// 参数化已经防注入，本转义只解决语义层面的通配符越权匹配。
  static String _escapeLike(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
  }

  /// 单条 IN(...) 语句允许的最大 id 数（LOW-2）。
  ///
  /// SQLite 默认变量上限为 999（SQLITE_MAX_VARIABLE_NUMBER）。超过该上限的
  /// `IN ($placeholders)` 会直接报错。这里以 900 为分块上限留出余量
  /// （部分语句还带额外占位符，如 batchUpdateSpecies 的 CASE/updated_at）。
  static const int _maxIdsPerChunk = 900;

  /// 将 ids 切分为 <= [_maxIdsPerChunk] 的分块，供多语句执行。
  static List<List<int>> _chunkIds(List<int> ids) {
    final chunks = <List<int>>[];
    for (var i = 0; i < ids.length; i += _maxIdsPerChunk) {
      final end =
          (i + _maxIdsPerChunk < ids.length) ? i + _maxIdsPerChunk : ids.length;
      chunks.add(ids.sublist(i, end));
    }
    return chunks;
  }

  /// SQL WHERE clause result
  ///
  /// [whereClause] is the SQL WHERE string (empty string if no filter)
  /// [whereArgs] are the parameterized arguments
  (String whereClause, List<dynamic> whereArgs) _buildWhereClause(
    FishFilter filter,
  ) {
    final clauses = <String>[];
    final args = <dynamic>[];

    // 1. Date filter (timeFilter)
    _addDateFilter(filter, clauses, args);

    // 2. Fate filter
    if (filter.fateFilter != null) {
      clauses.add('fate = ?');
      args.add(filter.fateFilter!.value);
    }

    // 3. Species filter
    if (filter.speciesFilter != null && filter.speciesFilter!.isNotEmpty) {
      clauses.add("(species = ? OR species LIKE ? ESCAPE '\\')");
      args.add(filter.speciesFilter);
      args.add('${_escapeLike(filter.speciesFilter!)}%');
    }

    // 4. Search query (species + location_name)
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final pattern = '%${_escapeLike(filter.searchQuery!.toLowerCase())}%';
      clauses.add(
        "(LOWER(species) LIKE ? ESCAPE '\\' "
        "OR LOWER(location_name) LIKE ? ESCAPE '\\')",
      );
      args.add(pattern);
      args.add(pattern);
    }

    final whereClause = clauses.isNotEmpty ? clauses.join(' AND ') : '';
    return (whereClause, args);
  }

  /// Add date filter clauses based on timeFilter
  void _addDateFilter(
    FishFilter filter,
    List<String> clauses,
    List<dynamic> args,
  ) {
    final timeFilter = filter.timeFilter;
    if (timeFilter == 'all') return;

    final (DateTime? start, DateTime? end) = _computeDateRange(
      timeFilter,
      filter.customStartDate,
      filter.customEndDate,
    );
    if (start == null || end == null) return;

    clauses.add('catch_time >= ?');
    args.add(start.toIso8601String());
    clauses.add('catch_time < ?');
    args.add(end.toIso8601String());
  }

  /// Compute date range from timeFilter string
  /// Returns (start, end) as DateTime? (null if 'all')
  (DateTime?, DateTime?) _computeDateRange(
    String timeFilter,
    DateTime? customStart,
    DateTime? customEnd,
  ) {
    final now = DateTime.now();

    switch (timeFilter) {
      case 'today':
        final start = DateTime(now.year, now.month, now.day);
        final end = start.add(const Duration(days: 1));
        return (start, end);

      case 'week':
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(monday.year, monday.month, monday.day);
        final end = start.add(const Duration(days: 7));
        return (start, end);

      case 'month':
        // Explicit rollover to avoid relying on DateTime normalization
        final nextMonth = now.month == 12 ? 1 : now.month + 1;
        final nextYear = now.month == 12 ? now.year + 1 : now.year;
        return (DateTime(now.year, now.month), DateTime(nextYear, nextMonth));

      case 'year':
        return (DateTime(now.year), DateTime(now.year + 1));

      case 'custom':
        if (customStart == null || customEnd == null) return (null, null);
        return (customStart, customEnd);

      default:
        return (null, null);
    }
  }

  /// Build SQL ORDER BY clause from sortBy and sortAsc
  String _buildSortClause(FishFilter filter) {
    // 长度/重量按归一化基准列排序（遗留 NULL 行回退原始值），
    // 避免混合单位（cm/inch、kg/lb/g）下排名错误。详见 H-9。
    final column = switch (filter.sortBy) {
      'length' => 'COALESCE(length_cm, length)',
      'weight' => 'COALESCE(weight_kg, weight)',
      _ => 'catch_time',
    };
    final direction = filter.sortAsc ? 'ASC' : 'DESC';

    // Handle NULLs last for weight column
    if (filter.sortBy == 'weight') {
      // SQLite 3.30.0+ supports NULLS LAST
      return 'ORDER BY CASE WHEN $column IS NULL THEN 1 ELSE 0 END, $column $direction';
    }

    return 'ORDER BY $column $direction';
  }

  @override
  Future<List<FishCatch>> getAll() async {
    try {
      final db = await database;
      final results = await db.query(tableName, orderBy: 'catch_time DESC')
          as List<Map<String, dynamic>>;
      return results.map(FishCatch.fromMap).toList();
    } catch (e) {
      throwDbError('get all fish catches', e);
    }
  }

  @override
  Future<FishCatch?> getById(int id) async {
    try {
      final db = await database;
      final results = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      ) as List<Map<String, dynamic>>;
      if (results.isEmpty) return null;
      return FishCatch.fromMap(results.first);
    } catch (e) {
      throwDbError('get fish catch by id', e);
    }
  }

  @override
  Future<List<FishCatch>> getByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    try {
      final db = await database;
      // LOW-2：分块查询，避免超过 SQLite 999 变量上限。
      final results = <Map<String, dynamic>>[];
      for (final chunk in _chunkIds(ids)) {
        final placeholders = List.filled(chunk.length, '?').join(',');
        final rows = await db.rawQuery(
          'SELECT * FROM $tableName WHERE id IN ($placeholders)',
          chunk,
        ) as List<Map<String, dynamic>>;
        results.addAll(rows);
      }
      return results.map(FishCatch.fromMap).toList();
    } catch (e) {
      throwDbError('get fish catches by ids', e);
    }
  }

  @override
  Future<List<FishCatch>> getBySpecies(String speciesName) async {
    if (speciesName.isEmpty) return [];
    try {
      final db = await database;
      final results = await db.query(
        tableName,
        where: 'species = ?',
        whereArgs: [speciesName],
      );
      return results.map(FishCatch.fromMap).toList();
    } catch (e) {
      throwDbError('get fish catches by species', e);
    }
  }

  @override
  Future<int> create(FishCatch fish) async {
    try {
      final db = await database;
      final map = fish.toMap();
      map.remove('id');
      map.removeWhere((_, v) => v == null);
      map['created_at'] = DateTime.now().toIso8601String();
      map['updated_at'] = DateTime.now().toIso8601String();
      return await db.insert(tableName, map);
    } catch (e) {
      throwDbError('create fish catch', e);
    }
  }

  @override
  Future<void> update(FishCatch fish) async {
    try {
      final db = await database;
      final map = fish.toMap();
      map['updated_at'] = DateTime.now().toIso8601String();
      await db.update(tableName, map, where: 'id = ?', whereArgs: [fish.id]);
    } catch (e) {
      throwDbError('update fish catch', e);
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      final db = await database;
      await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throwDbError('delete fish catch', e);
    }
  }

  @override
  Future<void> deleteMultiple(List<int> ids) async {
    if (ids.isEmpty) return;
    try {
      final db = await database;
      final chunks = _chunkIds(ids);
      // LOW-2：分块删除（避免 999 变量上限）；多分块时包进事务保证原子性。
      if (chunks.length == 1) {
        final placeholders = List.filled(chunks.first.length, '?').join(',');
        await db.delete(
          tableName,
          where: 'id IN ($placeholders)',
          whereArgs: chunks.first,
        );
        return;
      }
      await db.transaction((txn) async {
        for (final chunk in chunks) {
          final placeholders = List.filled(chunk.length, '?').join(',');
          await txn.delete(
            tableName,
            where: 'id IN ($placeholders)',
            whereArgs: chunk,
          );
        }
      });
    } catch (e) {
      throwDbError('delete multiple fish catches', e);
    }
  }

  @override
  Future<List<FishCatch>> getByDateRange(DateTime start, DateTime end) async {
    try {
      final db = await database;
      final results = await db.query(
        tableName,
        where: 'catch_time >= ? AND catch_time < ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
        orderBy: 'catch_time DESC',
      ) as List<Map<String, dynamic>>;
      return List<FishCatch>.from(results.map(FishCatch.fromMap));
    } catch (e) {
      throwDbError('get fish catches by date range', e);
    }
  }

  @override
  Future<List<FishCatch>> getByFate(FishFateType fate) async {
    try {
      final db = await database;
      final results = await db.query(
        tableName,
        where: 'fate = ?',
        whereArgs: [fate.value],
        orderBy: 'catch_time DESC',
      ) as List<Map<String, dynamic>>;
      return List<FishCatch>.from(results.map(FishCatch.fromMap));
    } catch (e) {
      throwDbError('get fish catches by fate', e);
    }
  }

  @override
  Future<PaginatedResult<FishCatch>> getPage({
    required int page,
    int pageSize = PaginationConstants.defaultPageSize,
    String orderBy = 'catch_time DESC',
  }) async {
    pageSize = pageSize.clamp(1, PaginationConstants.maxPageSize);
    try {
      final db = await database;
      final offset = (page - 1) * pageSize;

      // 浼樺寲锛氫娇鐢ㄥ崟娆℃煡璇㈣幏鍙栨暟鎹拰COUNT
      final results = await db.query(
        tableName,
        orderBy: orderBy,
        limit: pageSize,
        offset: offset,
      ) as List<Map<String, dynamic>>;

      // 鍙湪绗竴椤垫煡璇㈡€绘暟
      int totalCount;
      if (page == 1) {
        final countResult = await db.rawQuery(
          'SELECT COUNT(*) as count FROM $tableName',
        );
        totalCount = countResult.first['count'] as int? ?? 0;
      } else {
        // 瀵逛簬闈炵涓€椤碉紝涓嶆彁渚涘噯纭€绘暟锛堥渶瑕侀澶栨煡璇級
        totalCount = PaginationConstants.unknownTotalCount; // -1 琛ㄧず鏈煡
      }

      final items = List<FishCatch>.from(results.map(FishCatch.fromMap));
      final hasMore = results.length == pageSize;

      return PaginatedResult(
        items: items,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
        hasMore: hasMore,
      );
    } catch (e) {
      throwDbError('get paginated fish catches', e);
    }
  }

  @override
  Future<PaginatedResult<FishCatch>> getFilteredPage({
    required int page,
    int pageSize = PaginationConstants.defaultPageSize,
    DateTime? startDate,
    DateTime? endDate,
    FishFateType? fate,
    String? species,
    String orderBy = 'catch_time DESC',
  }) async {
    pageSize = pageSize.clamp(1, PaginationConstants.maxPageSize);
    // NOTE: This method uses legacy parameter style. The FishFilter-based
    // migration was deferred - current implementation is functional.
    try {
      final db = await database;
      final offset = (page - 1) * pageSize;

      final whereClauses = <String>[];
      final whereArgs = <dynamic>[];

      if (startDate != null) {
        whereClauses.add('catch_time >= ?');
        whereArgs.add(startDate.toIso8601String());
      }
      if (endDate != null) {
        whereClauses.add('catch_time < ?');
        whereArgs.add(endDate.toIso8601String());
      }
      if (fate != null) {
        whereClauses.add('fate = ?');
        whereArgs.add(fate.value);
      }
      // 浼樺寲锛氫娇鐢ㄦ洿楂樻晥鐨凩IKE鏌ヨ锛岄伩鍏嶅墠瀵奸€氶厤绗?
      if (species != null && species.isNotEmpty) {
        // LOW-1：转义用户输入中的 LIKE 通配符，避免过度匹配。
        whereClauses.add("(species = ? OR species LIKE ? ESCAPE '\\')");
        whereArgs.add(species);
        whereArgs.add('${_escapeLike(species)}%');
      }

      final whereClause =
          whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

      // 浼樺寲锛氬彧鍦ㄧ涓€椤垫煡璇㈡€绘暟
      int totalCount;
      if (page == 1) {
        final countQuery = whereClause != null
            ? 'SELECT COUNT(*) as count FROM $tableName WHERE $whereClause'
            : 'SELECT COUNT(*) as count FROM $tableName';
        final countResult = await db.rawQuery(countQuery, whereArgs);
        totalCount = countResult.first['count'] as int? ?? 0;
      } else {
        totalCount =
            PaginationConstants.unknownTotalCount; // -1 琛ㄧず鏈煡锛岄渶瑕侀澶栨煡璇?
      }

      final results = await db.query(
        tableName,
        where: whereClause,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: orderBy,
        limit: pageSize,
        offset: offset,
      ) as List<Map<String, dynamic>>;
      final items = List<FishCatch>.from(results.map(FishCatch.fromMap));
      final hasMore = results.length == pageSize;

      return PaginatedResult(
        items: items,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
        hasMore: hasMore,
      );
    } catch (e) {
      throwDbError('get filtered paginated fish catches', e);
    }
  }

  /// Get filtered, sorted, paginated fish catches using FishFilter
  ///
  /// This is the new implementation that uses SQL-level filtering
  /// for all filter fields (timeFilter, fateFilter, speciesFilter, searchQuery)
  /// and proper hasMore calculation based on total filtered count.
  @override
  Future<PaginatedResult<FishCatch>> getFilteredPageByFilter({
    required int page,
    required FishFilter filter,
    int pageSize = PaginationConstants.defaultPageSize,
  }) async {
    pageSize = pageSize.clamp(1, PaginationConstants.maxPageSize);
    try {
      final db = await database;
      final offset = (page - 1) * pageSize;

      // Build WHERE clause from FishFilter
      final (whereClause, whereArgs) = _buildWhereClause(filter);

      // Query 1: Get total count with SAME filters
      final countQuery = whereClause.isNotEmpty
          ? 'SELECT COUNT(*) as count FROM $tableName WHERE $whereClause'
          : 'SELECT COUNT(*) as count FROM $tableName';
      final countResult = await db.rawQuery(countQuery, whereArgs);
      final totalCount = countResult.first['count'] as int? ?? 0;

      // Query 2: Get page data with filters + sort + pagination
      final sortClause = _buildSortClause(filter);
      final dataSql = whereClause.isNotEmpty
          ? 'SELECT * FROM $tableName WHERE $whereClause $sortClause LIMIT ? OFFSET ?'
          : 'SELECT * FROM $tableName $sortClause LIMIT ? OFFSET ?';
      final dataArgs = [...whereArgs, pageSize, offset];
      final results =
          await db.rawQuery(dataSql, dataArgs) as List<Map<String, dynamic>>;

      final items = List<FishCatch>.from(results.map(FishCatch.fromMap));

      // Correct hasMore calculation based on total filtered count
      final hasMore = page * pageSize < totalCount;

      return PaginatedResult(
        items: items,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
        hasMore: hasMore,
      );
    } catch (e) {
      throwDbError('get filtered paginated fish catches', e);
    }
  }

  @override
  Future<List<FishCatch>> getPendingRecognitionCatches() async {
    try {
      final db = await database;
      final results = await db.query(
        tableName,
        where: 'pending_recognition = ?',
        whereArgs: [1],
        orderBy: 'catch_time DESC',
      ) as List<Map<String, dynamic>>;
      return results.map(FishCatch.fromMap).toList();
    } catch (e) {
      throwDbError('get pending recognition catches', e);
    }
  }

  @override
  Future<int> getPendingRecognitionCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE pending_recognition = ?',
        [1],
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      throwDbError('get pending recognition count', e);
    }
  }

  @override
  Future<void> updateSpecies(int id, String species) async {
    try {
      final db = await database;
      await db.update(
        tableName,
        {
          'species': species,
          'pending_recognition': 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throwDbError('update species', e);
    }
  }

  @override
  Future<void> batchUpdateSpecies(
    List<int> ids,
    List<String> speciesList,
  ) async {
    // Edge case: Empty input - return early without SQL execution
    if (ids.isEmpty) {
      return;
    }

    // Edge case: Mismatched lengths - throw descriptive error
    if (ids.length != speciesList.length) {
      throw ArgumentError('ids and speciesList must have same length: '
          'ids.length=${ids.length}, speciesList.length=${speciesList.length}');
    }

    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();

      // LOW-2：CASE-WHEN 模式每条记录用 3 个占位符（CASE 的 id+species）+
      // 末尾 1 个 updated_at + WHERE IN 的 N 个 id，合计 3N+1 个变量。
      // 为不触 SQLite 999 变量上限，按 300 条/块切分（3*300+1=901<999），
      // 多块时包进单个事务保证原子性。
      const batchChunkSize = 300;
      if (ids.length <= batchChunkSize) {
        await _runBatchUpdateChunk(db, ids, speciesList, now);
        return;
      }

      await db.transaction((txn) async {
        for (var i = 0; i < ids.length; i += batchChunkSize) {
          final end = (i + batchChunkSize < ids.length)
              ? i + batchChunkSize
              : ids.length;
          await _runBatchUpdateChunk(
            txn,
            ids.sublist(i, end),
            speciesList.sublist(i, end),
            now,
          );
        }
      });
    } catch (e) {
      throwDbError('batch update species', e);
    }
  }

  /// 执行一块（<=300 条）的批量品种更新（LOW-2 辅助）。
  ///
  /// [executor] 可为 [Database] 或事务 [Transaction]（二者均有 rawUpdate）。
  Future<void> _runBatchUpdateChunk(
    DatabaseExecutor executor,
    List<int> ids,
    List<String> speciesList,
    String now,
  ) async {
    final count = ids.length;

    // Build CASE WHEN SQL: single round-trip for N records
    // Pattern: UPDATE table SET col = CASE id WHEN ? THEN ? ... END WHERE id IN (?, ?, ...)
    final buffer = StringBuffer();
    buffer.write('UPDATE $tableName SET species = CASE id ');

    // Generate N WHEN ... THEN ... clauses (using ? placeholders)
    for (var i = 0; i < count; i++) {
      buffer.write('WHEN ? THEN ? ');
    }

    // SET clause continuation and WHERE clause
    buffer.write('END, pending_recognition = 0, updated_at = ? ');
    buffer.write('WHERE id IN (');

    // Generate ? placeholders for WHERE IN
    for (var i = 0; i < count; i++) {
      if (i > 0) buffer.write(', ');
      buffer.write('?');
    }
    buffer.write(')');

    // Build argument list: 3N + 1 parameters (id, species for each CASE, updated_at, id for WHERE)
    final args = <dynamic>[];
    for (var i = 0; i < count; i++) {
      args.add(ids[i]);
      args.add(speciesList[i]);
    }
    args.add(now);
    // Add ids for WHERE clause (the missing N parameters)
    for (var i = 0; i < count; i++) {
      args.add(ids[i]);
    }

    await executor.rawUpdate(buffer.toString(), args);
  }

  @override
  Future<Map<String, int>> getSpeciesCounts() async {
    try {
      final db = await database;
      final results = await db.rawQuery(
        'SELECT species, COUNT(*) as count FROM $tableName GROUP BY species ORDER BY count DESC',
      );
      final counts = <String, int>{};
      for (final row in results) {
        final species = row['species'] as String?;
        final count = row['count'] as int?;
        if (species != null && species.isNotEmpty && count != null) {
          counts[species] = count;
        }
      }
      return counts;
    } catch (e) {
      throwDbError('get species counts', e);
    }
  }

  @override
  Future<void> renameSpecies(String oldName, String newName) async {
    if (oldName.isEmpty || newName.isEmpty) {
      throwDbError('Species names cannot be empty', 'validation error');
    }
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      await db.update(
        tableName,
        {'species': newName, 'updated_at': now},
        where: 'species = ?',
        whereArgs: [oldName],
      );
    } catch (e) {
      throwDbError('rename species', e);
    }
  }

  @override
  Future<void> mergeSpecies(String fromName, String toName) async {
    // Same as renameSpecies, just a different semantic operation
    await renameSpecies(fromName, toName);
  }

  @override
  Future<void> deleteSpecies(String speciesName) async {
    if (speciesName.isEmpty) {
      throwDbError('Species name cannot be empty', 'validation error');
    }
    try {
      final db = await database;
      await db.delete(
        tableName,
        where: 'species = ?',
        whereArgs: [speciesName],
      );
    } catch (e) {
      throwDbError('delete species', e);
    }
  }

  @override
  Future<Map<String, Map<String, int>>> getSoftWormRigAnalytics() async {
    try {
      final db = await database;
      // Use INNER JOIN since we only want catches with a lure of type '杞櫕'
      final results = await db.rawQuery(
        '''
        SELECT
          fc.rig_type,
          fc.hook_type,
          fc.hook_size,
          fc.hook_weight,
          COUNT(*) as catch_count
        FROM fish_catches fc
        INNER JOIN equipments e ON fc.lure_id = e.id
        WHERE e.lure_type = ?
          AND fc.rig_type IS NOT NULL
        GROUP BY fc.rig_type, fc.hook_type, fc.hook_size, fc.hook_weight
        ''',
        [LureTypes.softBait],
      );

      final rigTypeStats = <String, int>{};
      final hookTypeStats = <String, int>{};
      final hookSizeStats = <String, int>{};
      final hookWeightStats = <String, int>{};

      for (final row in results) {
        final rigType = row['rig_type'] as String?;
        final hookType = row['hook_type'] as String?;
        final hookSize = row['hook_size'] as String?;
        final hookWeight = row['hook_weight'] as String?;
        final count = row['catch_count']! as int;

        if (rigType != null && rigType.isNotEmpty) {
          rigTypeStats[rigType] = (rigTypeStats[rigType] ?? 0) + count;
        }
        if (hookType != null && hookType.isNotEmpty) {
          hookTypeStats[hookType] = (hookTypeStats[hookType] ?? 0) + count;
        }
        if (hookSize != null && hookSize.isNotEmpty) {
          hookSizeStats[hookSize] = (hookSizeStats[hookSize] ?? 0) + count;
        }
        if (hookWeight != null && hookWeight.isNotEmpty) {
          hookWeightStats[hookWeight] =
              (hookWeightStats[hookWeight] ?? 0) + count;
        }
      }

      return {
        'rigType': rigTypeStats,
        'hookType': hookTypeStats,
        'hookSize': hookSizeStats,
        'hookWeight': hookWeightStats,
      };
    } catch (e) {
      throwDbError('get soft worm rig analytics', e);
    }
  }

  @override
  Future<int> getCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      throwDbError('get fish catch count', e);
    }
  }
}
