import 'package:lurebox/core/constants/pagination_constants.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/fish_filter.dart';
import 'package:lurebox/core/repositories/base_repository.dart';
import 'package:lurebox/core/repositories/fish_catch_repository.dart';

/// SQLite 瀹炵幇 - 娓旇幏璁板綍浠撳偍灞?
///
/// 浣跨敤 SQLite 鏁版嵁搴撳疄鐜版笖鑾疯褰曠殑鏁版嵁璁块棶銆?
/// 鏁版嵁琛ㄥ悕锛歠ish_catches

class SqliteFishCatchRepository extends BaseSqliteRepository
    implements FishCatchRepository {

  SqliteFishCatchRepository();

  SqliteFishCatchRepository.withDatabase(super.testDb)
      : super.withDatabase();
  @override
  String get tableName => 'fish_catches';

  /// SQL WHERE clause result
  ///
  /// [whereClause] is the SQL WHERE string (empty string if no filter)
  /// [whereArgs] are the parameterized arguments
  (String whereClause, List<dynamic> whereArgs) _buildWhereClause(
      FishFilter filter,) {
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
      clauses.add('(species = ? OR species LIKE ?)');
      args.add(filter.speciesFilter);
      args.add('${filter.speciesFilter}%');
    }

    // 4. Search query (species + location_name)
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final pattern = '%${filter.searchQuery!.toLowerCase()}%';
      clauses.add('(LOWER(species) LIKE ? OR LOWER(location_name) LIKE ?)');
      args.add(pattern);
      args.add(pattern);
    }

    final whereClause = clauses.isNotEmpty ? clauses.join(' AND ') : '';
    return (whereClause, args);
  }

  /// Add date filter clauses based on timeFilter
  void _addDateFilter(
      FishFilter filter, List<String> clauses, List<dynamic> args,) {
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
    final column = switch (filter.sortBy) {
      'length' => 'length',
      'weight' => 'weight',
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
      final placeholders = List.filled(ids.length, '?').join(',');
      final results = await db.rawQuery(
        'SELECT * FROM $tableName WHERE id IN ($placeholders)',
        ids,
      ) as List<Map<String, dynamic>>;
      return results.map(FishCatch.fromMap).toList();
    } catch (e) {
      throwDbError('get fish catches by ids', e);
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
      final placeholders = List.filled(ids.length, '?').join(',');
      await db.delete(
        tableName,
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
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

      final items =
          List<FishCatch>.from(results.map(FishCatch.fromMap));
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
      if (species != null && species.isNotEmpty) {
        // 浼樺寲锛氫娇鐢ㄦ洿楂樻晥鐨凩IKE鏌ヨ锛岄伩鍏嶅墠瀵奸€氶厤绗?
        whereClauses.add('(species = ? OR species LIKE ?)');
        whereArgs.add(species);
        whereArgs.add('$species%');
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
        totalCount = PaginationConstants.unknownTotalCount; // -1 琛ㄧず鏈煡锛岄渶瑕侀澶栨煡璇?
      }

      final results = await db.query(
        tableName,
        where: whereClause,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: orderBy,
        limit: pageSize,
        offset: offset,
      ) as List<Map<String, dynamic>>;
      final items =
          List<FishCatch>.from(results.map(FishCatch.fromMap));
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
    required FishFilter filter, int pageSize = PaginationConstants.defaultPageSize,
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

      final items =
          List<FishCatch>.from(results.map(FishCatch.fromMap));

      // Correct hasMore calculation based on total filtered count
      final hasMore = (page + 1) * pageSize < totalCount;

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
      List<int> ids, List<String> speciesList,) async {
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
      // SQL: UPDATE ... SET species = CASE id WHEN ? THEN ? ... END ... WHERE id IN (?, ?, ...)
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

      // Single SQL execution - single database round-trip
      await db.rawUpdate(buffer.toString(), args);
    } catch (e) {
      throwDbError('batch update species', e);
    }
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
      final results = await db.rawQuery('''
        SELECT
          fc.rig_type,
          fc.hook_type,
          fc.hook_size,
          fc.hook_weight,
          COUNT(*) as catch_count
        FROM fish_catches fc
        INNER JOIN equipments e ON fc.lure_id = e.id
        WHERE e.lure_type = '软虫'
          AND fc.rig_type IS NOT NULL
        GROUP BY fc.rig_type, fc.hook_type, fc.hook_size, fc.hook_weight
      ''');

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
