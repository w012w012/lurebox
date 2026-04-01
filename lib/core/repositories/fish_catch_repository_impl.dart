import '../models/fish_catch.dart';
import '../services/database_service.dart';
import 'fish_catch_repository.dart';

/// SQLite 实现 - 渔获记录仓储层
///
/// 使用 SQLite 数据库实现渔获记录的数据访问。
/// 数据表名：fish_catches

class SqliteFishCatchRepository implements FishCatchRepository {
  static const String _tableName = 'fish_catches';

  @override
  Future<List<FishCatch>> getAll() async {
    try {
      final db = await DatabaseService.database;
      final results = await db.query(_tableName, orderBy: 'catch_time DESC');
      return results.map((map) => FishCatch.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get all fish catches: $e');
    }
  }

  @override
  Future<FishCatch?> getById(int id) async {
    try {
      final db = await DatabaseService.database;
      final results = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (results.isEmpty) return null;
      return FishCatch.fromMap(results.first);
    } catch (e) {
      throw Exception('Failed to get fish catch by id: $e');
    }
  }

  @override
  Future<int> create(FishCatch fish) async {
    try {
      final db = await DatabaseService.database;
      final map = fish.toMap();
      map.remove('id');
      map['created_at'] = DateTime.now().toIso8601String();
      map['updated_at'] = DateTime.now().toIso8601String();
      return await db.insert(_tableName, map);
    } catch (e) {
      throw Exception('Failed to create fish catch: $e');
    }
  }

  @override
  Future<void> update(FishCatch fish) async {
    try {
      final db = await DatabaseService.database;
      final map = fish.toMap();
      map['updated_at'] = DateTime.now().toIso8601String();
      await db.update(_tableName, map, where: 'id = ?', whereArgs: [fish.id]);
    } catch (e) {
      throw Exception('Failed to update fish catch: $e');
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      final db = await DatabaseService.database;
      await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Failed to delete fish catch: $e');
    }
  }

  @override
  Future<void> deleteMultiple(List<int> ids) async {
    if (ids.isEmpty) return;
    try {
      final db = await DatabaseService.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      await db.delete(
        _tableName,
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
    } catch (e) {
      throw Exception('Failed to delete multiple fish catches: $e');
    }
  }

  @override
  Future<List<FishCatch>> getByDateRange(DateTime start, DateTime end) async {
    try {
      final db = await DatabaseService.database;
      final results = await db.query(
        _tableName,
        where: 'catch_time >= ? AND catch_time < ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
        orderBy: 'catch_time DESC',
      );
      return results.map((map) => FishCatch.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get fish catches by date range: $e');
    }
  }

  @override
  Future<List<FishCatch>> getByFate(FishFateType fate) async {
    try {
      final db = await DatabaseService.database;
      final results = await db.query(
        _tableName,
        where: 'fate = ?',
        whereArgs: [fate.value],
        orderBy: 'catch_time DESC',
      );
      return results.map((map) => FishCatch.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get fish catches by fate: $e');
    }
  }

  @override
  Future<PaginatedResult<FishCatch>> getPage({
    required int page,
    int pageSize = 20,
    String orderBy = 'catch_time DESC',
  }) async {
    try {
      final db = await DatabaseService.database;
      final offset = (page - 1) * pageSize;

      // 优化：使用单次查询获取数据和COUNT
      final results = await db.query(
        _tableName,
        orderBy: orderBy,
        limit: pageSize,
        offset: offset,
      );

      // 只在第一页或需要时查询总数
      int totalCount;
      if (page == 1) {
        final countResult = await db.rawQuery(
          'SELECT COUNT(*) as count FROM $_tableName',
        );
        totalCount = countResult.first['count'] as int;
      } else {
        // 对于非第一页，使用估算值避免额外查询
        totalCount =
            page * pageSize + (results.length < pageSize ? 0 : pageSize);
      }

      final items = results.map((map) => FishCatch.fromMap(map)).toList();
      final hasMore = results.length == pageSize;

      return PaginatedResult(
        items: items,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
        hasMore: hasMore,
      );
    } catch (e) {
      throw Exception('Failed to get paginated fish catches: $e');
    }
  }

  @override
  Future<PaginatedResult<FishCatch>> getFilteredPage({
    required int page,
    int pageSize = 20,
    DateTime? startDate,
    DateTime? endDate,
    FishFateType? fate,
    String? species,
    String orderBy = 'catch_time DESC',
  }) async {
    try {
      final db = await DatabaseService.database;
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
        // 优化：使用更高效的LIKE查询，避免前导通配符
        whereClauses.add('species = ? OR species LIKE ?');
        whereArgs.add(species);
        whereArgs.add('$species%');
      }

      final whereClause =
          whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

      // 优化：只在第一页查询总数
      int totalCount;
      if (page == 1) {
        final countQuery = whereClause != null
            ? 'SELECT COUNT(*) as count FROM $_tableName WHERE $whereClause'
            : 'SELECT COUNT(*) as count FROM $_tableName';
        final countResult = await db.rawQuery(countQuery, whereArgs);
        totalCount = countResult.first['count'] as int;
      } else {
        totalCount = page * pageSize; // 估算值
      }

      final results = await db.query(
        _tableName,
        where: whereClause,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: orderBy,
        limit: pageSize,
        offset: offset,
      );
      final items = results.map((map) => FishCatch.fromMap(map)).toList();
      final hasMore = results.length == pageSize;

      return PaginatedResult(
        items: items,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
        hasMore: hasMore,
      );
    } catch (e) {
      throw Exception('Failed to get filtered paginated fish catches: $e');
    }
  }

  @override
  Future<List<FishCatch>> getPendingRecognitionCatches() async {
    try {
      final db = await DatabaseService.database;
      final results = await db.query(
        _tableName,
        where: 'pending_recognition = ?',
        whereArgs: [1],
        orderBy: 'catch_time DESC',
      );
      return results.map((map) => FishCatch.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get pending recognition catches: $e');
    }
  }

  @override
  Future<int> getPendingRecognitionCount() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE pending_recognition = ?',
        [1],
      );
      return result.first['count'] as int;
    } catch (e) {
      throw Exception('Failed to get pending recognition count: $e');
    }
  }

  @override
  Future<void> updateSpecies(int id, String species) async {
    try {
      final db = await DatabaseService.database;
      await db.update(
        _tableName,
        {
          'species': species,
          'pending_recognition': 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to update species: $e');
    }
  }

  @override
  Future<void> batchUpdateSpecies(
      List<int> ids, List<String> speciesList) async {
    if (ids.isEmpty ||
        speciesList.isEmpty ||
        ids.length != speciesList.length) {
      throw Exception(
          'Invalid batch update parameters: ids and speciesList must have same length');
    }
    try {
      final db = await DatabaseService.database;
      final now = DateTime.now().toIso8601String();
      await db.transaction((txn) async {
        for (int i = 0; i < ids.length; i++) {
          await txn.update(
            _tableName,
            {
              'species': speciesList[i],
              'pending_recognition': 0,
              'updated_at': now,
            },
            where: 'id = ?',
            whereArgs: [ids[i]],
          );
        }
      });
    } catch (e) {
      throw Exception('Failed to batch update species: $e');
    }
  }

  @override
  Future<Map<String, int>> getSpeciesCounts() async {
    try {
      final db = await DatabaseService.database;
      final results = await db.rawQuery(
        'SELECT species, COUNT(*) as count FROM $_tableName GROUP BY species ORDER BY count DESC',
      );
      final Map<String, int> counts = {};
      for (final row in results) {
        final species = row['species'] as String?;
        final count = row['count'] as int?;
        if (species != null && species.isNotEmpty && count != null) {
          counts[species] = count;
        }
      }
      return counts;
    } catch (e) {
      throw Exception('Failed to get species counts: $e');
    }
  }

  @override
  Future<void> renameSpecies(String oldName, String newName) async {
    if (oldName.isEmpty || newName.isEmpty) {
      throw Exception('Species names cannot be empty');
    }
    try {
      final db = await DatabaseService.database;
      final now = DateTime.now().toIso8601String();
      await db.update(
        _tableName,
        {'species': newName, 'updated_at': now},
        where: 'species = ?',
        whereArgs: [oldName],
      );
    } catch (e) {
      throw Exception('Failed to rename species: $e');
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
      throw Exception('Species name cannot be empty');
    }
    try {
      final db = await DatabaseService.database;
      await db.delete(
        _tableName,
        where: 'species = ?',
        whereArgs: [speciesName],
      );
    } catch (e) {
      throw Exception('Failed to delete species: $e');
    }
  }
}
