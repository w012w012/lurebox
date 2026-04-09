import '../models/equipment.dart';
import '../services/database_service.dart';
import '../services/error_service.dart';
import 'equipment_repository.dart';

/// SQLite 实现 - 钓具/装备仓储层
///
/// 使用 SQLite 数据库实现钓具装备的数据访问。
/// 数据表名：equipments

class SqliteEquipmentRepository implements EquipmentRepository {
  static const String _tableName = 'equipments';

  @override
  Future<List<Equipment>> getAll({String? type}) async {
    try {
      final db = await DatabaseService.database;
      final whereClauses = <String>['is_deleted = 0'];
      final whereArgs = <dynamic>[];
      if (type != null) {
        whereClauses.add('type = ?');
        whereArgs.add(type);
      }
      final where = whereClauses.join(' AND ');
      final results = await db.query(
        _tableName,
        where: where,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'is_default DESC, created_at DESC',
      );
      return List<Equipment>.from(
          results.map((map) => Equipment.fromMap(map as Map<String, dynamic>)));
    } catch (e) {
      throw DatabaseException('Failed to get equipments: $e');
    }
  }

  @override
  Future<Equipment?> getById(int id) async {
    try {
      final db = await DatabaseService.database;
      final results = await db.query(
        _tableName,
        where: 'is_deleted = 0 AND id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (results.isEmpty) return null;
      return Equipment.fromMap(results.first);
    } catch (e) {
      throw DatabaseException('Failed to get equipment by id: $e');
    }
  }

  @override
  Future<Equipment?> getDefaultEquipment(String type) async {
    try {
      final db = await DatabaseService.database;
      final results = await db.query(
        _tableName,
        where: 'is_deleted = 0 AND type = ? AND is_default = 1',
        whereArgs: [type],
        limit: 1,
      );
      if (results.isEmpty) return null;
      return Equipment.fromMap(results.first);
    } catch (e) {
      throw DatabaseException('Failed to get default equipment: $e');
    }
  }

  @override
  Future<int> create(Equipment equipment) async {
    try {
      final db = await DatabaseService.database;
      final map = equipment.toMap();
      map.remove('id');
      map['created_at'] = DateTime.now().toIso8601String();
      map['updated_at'] = DateTime.now().toIso8601String();
      map['is_deleted'] = 0;
      map['is_default'] = equipment.isDefault ? 1 : 0;
      return await db.insert(_tableName, map);
    } catch (e) {
      throw DatabaseException('Failed to create equipment: $e');
    }
  }

  @override
  Future<void> update(Equipment equipment) async {
    try {
      final db = await DatabaseService.database;
      final map = equipment.toMap();
      map['updated_at'] = DateTime.now().toIso8601String();
      await db.update(
        _tableName,
        map,
        where: 'id = ?',
        whereArgs: [equipment.id],
      );
    } catch (e) {
      throw DatabaseException('Failed to update equipment: $e');
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      final db = await DatabaseService.database;
      await db.update(
        _tableName,
        {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete equipment: $e');
    }
  }

  @override
  Future<PaginatedResult<Equipment>> getPage({
    required int page,
    int pageSize = 20,
    String? type,
    String orderBy = 'is_default DESC, created_at DESC',
  }) async {
    try {
      final db = await DatabaseService.database;
      final offset = (page - 1) * pageSize;

      final whereClauses = <String>['is_deleted = 0'];
      final whereArgs = <dynamic>[];

      if (type != null) {
        whereClauses.add('type = ?');
        whereArgs.add(type);
      }

      final whereClause = whereClauses.join(' AND ');

      final countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE $whereClause',
        whereArgs,
      );
      final totalCount = countResult.first['count'] as int;

      final results = await db.query(
        _tableName,
        where: whereClause,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: orderBy,
        limit: pageSize,
        offset: offset,
      );
      final items = List<Equipment>.from(
          results.map((map) => Equipment.fromMap(map as Map<String, dynamic>)));

      final hasMore = (page * pageSize) < totalCount;

      return PaginatedResult(
        items: items,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
        hasMore: hasMore,
      );
    } catch (e) {
      throw DatabaseException('Failed to get paginated equipments: $e');
    }
  }

  @override
  Future<PaginatedResult<Equipment>> getFilteredPage({
    required int page,
    int pageSize = 20,
    String? type,
    String? brand,
    String? model,
    String? category,
    String orderBy = 'is_default DESC, created_at DESC',
  }) async {
    try {
      final db = await DatabaseService.database;
      final offset = (page - 1) * pageSize;

      final whereClauses = <String>['is_deleted = 0'];
      final whereArgs = <dynamic>[];

      if (type != null) {
        whereClauses.add('type = ?');
        whereArgs.add(type);
      }
      if (brand != null && brand.isNotEmpty) {
        whereClauses.add('brand LIKE ?');
        whereArgs.add('%$brand%');
      }
      if (model != null && model.isNotEmpty) {
        whereClauses.add('model LIKE ?');
        whereArgs.add('%$model%');
      }
      if (category != null && category.isNotEmpty) {
        whereClauses.add('category = ?');
        whereArgs.add(category);
      }

      final whereClause = whereClauses.join(' AND ');

      final countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE $whereClause',
        whereArgs,
      );
      final totalCount = countResult.first['count'] as int;

      final results = await db.query(
        _tableName,
        where: whereClause,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: orderBy,
        limit: pageSize,
        offset: offset,
      );
      final items = List<Equipment>.from(
          results.map((map) => Equipment.fromMap(map as Map<String, dynamic>)));

      final hasMore = (page * pageSize) < totalCount;

      return PaginatedResult(
        items: items,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
        hasMore: hasMore,
      );
    } catch (e) {
      throw DatabaseException('Failed to get filtered paginated equipments: $e');
    }
  }

  @override
  Future<void> setDefaultEquipment(int id, String type) async {
    try {
      final db = await DatabaseService.database;
      await db.transaction((txn) async {
        await txn.update(
          _tableName,
          {'is_default': 0, 'updated_at': DateTime.now().toIso8601String()},
          where: 'type = ?',
          whereArgs: [type],
        );
        await txn.update(
          _tableName,
          {'is_default': 1, 'updated_at': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [id],
        );
      });
    } catch (e) {
      throw DatabaseException('Failed to set default equipment: $e');
    }
  }

  @override
  Future<Map<String, int>> getStats() async {
    try {
      final db = await DatabaseService.database;
      final results = await db.rawQuery('''
        SELECT type, COUNT(*) as count 
        FROM $_tableName 
        WHERE is_deleted = 0 
        GROUP BY type
      ''');

      final stats = <String, int>{};
      for (final row in results) {
        stats[row['type'] as String] = row['count'] as int;
      }
      return stats;
    } catch (e) {
      throw DatabaseException('Failed to get equipment stats: $e');
    }
  }

  @override
  Future<List<String>> getBrands() async {
    try {
      final db = await DatabaseService.database;
      final results = await db.rawQuery('''
        SELECT DISTINCT brand 
        FROM $_tableName 
        WHERE is_deleted = 0 AND brand IS NOT NULL AND brand != ''
        ORDER BY brand
      ''');

      return results.map((row) => row['brand'] as String).toList();
    } catch (e) {
      throw DatabaseException('Failed to get brands: $e');
    }
  }

  @override
  Future<List<String>> getModelsByBrand(String brand) async {
    try {
      final db = await DatabaseService.database;
      final results = await db.rawQuery(
        '''
        SELECT DISTINCT model 
        FROM $_tableName 
        WHERE is_deleted = 0 AND brand = ? AND model IS NOT NULL AND model != ''
        ORDER BY model
      ''',
        [brand],
      );

      return results.map((row) => row['model'] as String).toList();
    } catch (e) {
      throw DatabaseException('Failed to get models by brand: $e');
    }
  }

  @override
  Future<Map<String, int>> getCategoryDistribution(String type) async {
    try {
      final db = await DatabaseService.database;
      final results = await db.rawQuery(
        '''
        SELECT category, COUNT(*) as count 
        FROM $_tableName 
        WHERE is_deleted = 0 AND type = ? AND category IS NOT NULL
        GROUP BY category
        ORDER BY count DESC
      ''',
        [type],
      );

      final distribution = <String, int>{};
      for (final row in results) {
        final category = row['category'] as String;
        distribution[category] = row['count'] as int;
      }
      return distribution;
    } catch (e) {
      throw DatabaseException('Failed to get category distribution: $e');
    }
  }
}
