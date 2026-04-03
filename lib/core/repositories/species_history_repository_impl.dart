import '../services/database_service.dart';
import 'species_history_repository.dart';

/// SQLite 实现 - 物种历史记录仓储层
///
/// 使用 SQLite 数据库实现物种历史记录的数据访问。
/// 数据表名：species_history

class SqliteSpeciesHistoryRepository implements SpeciesHistoryRepository {
  static const String _tableName = 'species_history';

  @override
  Future<List<SpeciesHistory>> getAll({
    int limit = 100,
    bool includeDeleted = false,
  }) async {
    try {
      final db = await DatabaseService.database;
      final results = await db.query(
        _tableName,
        where: includeDeleted ? null : 'is_deleted = ?',
        whereArgs: includeDeleted ? null : [0],
        orderBy: 'use_count DESC, created_at ASC',
        limit: limit,
      );
      return List<SpeciesHistory>.from(results
          .map((map) => SpeciesHistory.fromMap(map as Map<String, dynamic>)));
    } catch (e) {
      throw Exception('Failed to get species history: $e');
    }
  }

  @override
  Future<SpeciesHistory?> getByName(String name) async {
    try {
      final db = await DatabaseService.database;
      final results = await db.query(
        _tableName,
        where: 'name = ?',
        whereArgs: [name],
        limit: 1,
      );
      if (results.isEmpty) return null;
      return SpeciesHistory.fromMap(results.first);
    } catch (e) {
      throw Exception('Failed to get species history by name: $e');
    }
  }

  @override
  Future<void> upsert(String name) async {
    try {
      final db = await DatabaseService.database;
      final existing = await db.query(
        _tableName,
        where: 'name = ?',
        whereArgs: [name],
      );

      if (existing.isNotEmpty) {
        await db.update(
          _tableName,
          {
            'use_count': (existing.first['use_count'] as int? ?? 0) + 1,
            'is_deleted': 0,
          },
          where: 'name = ?',
          whereArgs: [name],
        );
      } else {
        await db.insert(_tableName, {
          'name': name,
          'use_count': 1,
          'is_deleted': 0,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Failed to upsert species history: $e');
    }
  }

  @override
  Future<void> incrementUseCount(String name) async {
    try {
      final db = await DatabaseService.database;
      final existing = await db.query(
        _tableName,
        where: 'name = ?',
        whereArgs: [name],
      );

      if (existing.isNotEmpty) {
        await db.update(
          _tableName,
          {
            'use_count': (existing.first['use_count'] as int? ?? 0) + 1,
            'is_deleted': 0,
          },
          where: 'name = ?',
          whereArgs: [name],
        );
      } else {
        await db.insert(_tableName, {
          'name': name,
          'use_count': 1,
          'is_deleted': 0,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Failed to increment use count: $e');
    }
  }

  @override
  Future<void> softDelete(String name) async {
    try {
      final db = await DatabaseService.database;
      await db.update(
        _tableName,
        {'is_deleted': 1},
        where: 'name = ?',
        whereArgs: [name],
      );
    } catch (e) {
      throw Exception('Failed to soft delete species history: $e');
    }
  }

  @override
  Future<void> restore(String name) async {
    try {
      final db = await DatabaseService.database;
      await db.update(
        _tableName,
        {'is_deleted': 0},
        where: 'name = ?',
        whereArgs: [name],
      );
    } catch (e) {
      throw Exception('Failed to restore species history: $e');
    }
  }

  @override
  Future<bool> exists(String name) async {
    try {
      final db = await DatabaseService.database;
      final results = await db.query(
        _tableName,
        where: 'name = ? AND is_deleted = ?',
        whereArgs: [name, 0],
        limit: 1,
      );
      return results.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check species history existence: $e');
    }
  }

  @override
  Future<int> getCount() async {
    try {
      final db = await DatabaseService.database;
      final results = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE is_deleted = ?',
        [0],
      );
      return results.first['count'] as int? ?? 0;
    } catch (e) {
      throw Exception('Failed to get species history count: $e');
    }
  }
}
