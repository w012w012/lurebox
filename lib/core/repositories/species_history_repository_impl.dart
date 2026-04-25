import 'package:lurebox/core/repositories/base_repository.dart';
import 'package:lurebox/core/repositories/species_history_repository.dart';

/// SQLite implementation — species history repository.
///
/// Table: species_history

class SqliteSpeciesHistoryRepository extends BaseSqliteRepository
    implements SpeciesHistoryRepository {

  SqliteSpeciesHistoryRepository();

  SqliteSpeciesHistoryRepository.withDatabase(super.testDb)
      : super.withDatabase();
  @override
  String get tableName => 'species_history';

  @override
  Future<List<SpeciesHistory>> getAll({
    int limit = 100,
    bool includeDeleted = false,
  }) async {
    try {
      final db = await database;
      final results = await db.query(
        tableName,
        where: includeDeleted ? null : 'is_deleted = ?',
        whereArgs: includeDeleted ? null : [0],
        orderBy: 'use_count DESC, created_at ASC',
        limit: limit,
      );
      return List<SpeciesHistory>.from(results
          .map((map) => SpeciesHistory.fromMap(map as Map<String, dynamic>)),);
    } catch (e) {
      throwDbError('get species history', e);
    }
  }

  @override
  Future<SpeciesHistory?> getByName(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return null;
    try {
      final db = await database;
      final results = await db.query(
        tableName,
        where: 'name = ?',
        whereArgs: [trimmedName],
        limit: 1,
      );
      if (results.isEmpty) return null;
      return SpeciesHistory.fromMap(results.first);
    } catch (e) {
      throwDbError('get species history by name', e);
    }
  }

  @override
  Future<void> upsert(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;
    try {
      final db = await database;
      await db.rawInsert(
        '''INSERT INTO $tableName (name, use_count, is_deleted, created_at)
           VALUES (?, 1, 0, ?)
           ON CONFLICT(name) DO UPDATE SET
             use_count = use_count + 1,
             is_deleted = 0''',
        [trimmedName, DateTime.now().toIso8601String()],
      );
    } catch (e) {
      throwDbError('upsert species history', e);
    }
  }

  @override
  Future<void> incrementUseCount(String name) async {
    await upsert(name);
  }

  @override
  Future<void> softDelete(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;
    try {
      final db = await database;
      await db.update(
        tableName,
        {'is_deleted': 1},
        where: 'name = ?',
        whereArgs: [trimmedName],
      );
    } catch (e) {
      throwDbError('soft delete species history', e);
    }
  }

  @override
  Future<void> restore(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;
    try {
      final db = await database;
      await db.update(
        tableName,
        {'is_deleted': 0},
        where: 'name = ?',
        whereArgs: [trimmedName],
      );
    } catch (e) {
      throwDbError('restore species history', e);
    }
  }

  @override
  Future<bool> exists(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return false;
    try {
      final db = await database;
      final results = await db.query(
        tableName,
        where: 'name = ? AND is_deleted = ?',
        whereArgs: [trimmedName, 0],
        limit: 1,
      );
      return results.isNotEmpty;
    } catch (e) {
      throwDbError('check species history existence', e);
    }
  }

  @override
  Future<int> getCount() async {
    try {
      final db = await database;
      final results = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE is_deleted = ?',
        [0],
      );
      return results.first['count'] as int? ?? 0;
    } catch (e) {
      throwDbError('get species history count', e);
    }
  }
}
