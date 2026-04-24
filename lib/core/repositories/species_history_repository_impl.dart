import 'package:sqflite/sqflite.dart' hide DatabaseException;
import '../database/database_provider.dart';
import '../services/error_service.dart';
import 'species_history_repository.dart';

/// SQLite 实现 - 物种历史记录仓储层
///
/// 使用 SQLite 数据库实现物种历史记录的数据访问。
/// 数据表名：species_history

class SqliteSpeciesHistoryRepository implements SpeciesHistoryRepository {
  static const String _tableName = 'species_history';

  /// Optional database instance (for test injection)
  Future<Database>? _testDb;

  /// Internal database getter
  Future<Database> get _database async {
    final testDb = _testDb;
    if (testDb != null) return await testDb;
    return await DatabaseProvider.instance.database;
  }

  /// Default constructor (uses DatabaseService)
  SqliteSpeciesHistoryRepository();

  /// Constructor with database injection (for testing)
  SqliteSpeciesHistoryRepository.withDatabase(Future<Database> testDb) {
    _testDb = testDb;
  }

  @override
  Future<List<SpeciesHistory>> getAll({
    int limit = 100,
    bool includeDeleted = false,
  }) async {
    try {
      final db = await _database;
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
      throw DatabaseException('Failed to get species history: $e');
    }
  }

  @override
  Future<SpeciesHistory?> getByName(String name) async {
    try {
      final db = await _database;
      final results = await db.query(
        _tableName,
        where: 'name = ?',
        whereArgs: [name],
        limit: 1,
      );
      if (results.isEmpty) return null;
      return SpeciesHistory.fromMap(results.first);
    } catch (e) {
      throw DatabaseException('Failed to get species history by name: $e');
    }
  }

  @override
  Future<void> upsert(String name) async {
    try {
      final db = await _database;
      await db.rawInsert(
        '''INSERT INTO $_tableName (name, use_count, is_deleted, created_at)
           VALUES (?, 1, 0, ?)
           ON CONFLICT(name) DO UPDATE SET
             use_count = use_count + 1,
             is_deleted = 0''',
        [name, DateTime.now().toIso8601String()],
      );
    } catch (e) {
      throw DatabaseException('Failed to upsert species history: $e');
    }
  }

  @override
  Future<void> incrementUseCount(String name) async {
    await upsert(name);
  }

  @override
  Future<void> softDelete(String name) async {
    try {
      final db = await _database;
      await db.update(
        _tableName,
        {'is_deleted': 1},
        where: 'name = ?',
        whereArgs: [name],
      );
    } catch (e) {
      throw DatabaseException('Failed to soft delete species history: $e');
    }
  }

  @override
  Future<void> restore(String name) async {
    try {
      final db = await _database;
      await db.update(
        _tableName,
        {'is_deleted': 0},
        where: 'name = ?',
        whereArgs: [name],
      );
    } catch (e) {
      throw DatabaseException('Failed to restore species history: $e');
    }
  }

  @override
  Future<bool> exists(String name) async {
    try {
      final db = await _database;
      final results = await db.query(
        _tableName,
        where: 'name = ? AND is_deleted = ?',
        whereArgs: [name, 0],
        limit: 1,
      );
      return results.isNotEmpty;
    } catch (e) {
      throw DatabaseException('Failed to check species history existence: $e');
    }
  }

  @override
  Future<int> getCount() async {
    try {
      final db = await _database;
      final results = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE is_deleted = ?',
        [0],
      );
      return results.first['count'] as int? ?? 0;
    } catch (e) {
      throw DatabaseException('Failed to get species history count: $e');
    }
  }
}
