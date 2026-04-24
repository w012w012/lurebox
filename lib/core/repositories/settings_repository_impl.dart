import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'base_repository.dart';
import 'settings_repository.dart';

/// SQLite implementation — app settings repository (key-value store).
///
/// Table: settings

class SqliteSettingsRepository extends BaseSqliteRepository
    implements SettingsRepository {
  @override
  String get tableName => 'settings';

  SqliteSettingsRepository();

  SqliteSettingsRepository.withDatabase(Future<Database> testDb)
      : super.withDatabase(testDb);

  @override
  Future<String?> get(String key) async {
    try {
      final db = await database;
      final results = await db.query(
        tableName,
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
      if (results.isEmpty) return null;
      return results.first['value'] as String?;
    } catch (e) {
      throwDbError('get setting', e);
    }
  }

  @override
  Future<String> getOrDefault(String key, String defaultValue) async {
    final value = await get(key);
    return value ?? defaultValue;
  }

  @override
  Future<void> set(String key, String value) async {
    try {
      final db = await database;
      await db.insert(
          tableName,
          {
            'key': key,
            'value': value,
            'updated_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throwDbError('set setting', e);
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      final db = await database;
      await db.delete(tableName, where: 'key = ?', whereArgs: [key]);
    } catch (e) {
      throwDbError('delete setting', e);
    }
  }

  @override
  Future<bool> exists(String key) async {
    try {
      final db = await database;
      final results = await db.query(
        tableName,
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
      return results.isNotEmpty;
    } catch (e) {
      throwDbError('check setting existence', e);
    }
  }

  @override
  Future<Map<String, String>> getAll() async {
    try {
      final db = await database;
      final results = await db.query(tableName);
      final settings = <String, String>{};
      for (final row in results) {
        final key = row['key'] as String?;
        final value = row['value'] as String?;
        if (key != null && value != null) {
          settings[key] = value;
        }
      }
      return settings;
    } catch (e) {
      throwDbError('get all settings', e);
    }
  }

  @override
  Future<void> setAll(Map<String, String> settings) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        for (final entry in settings.entries) {
          await txn.insert(
              tableName,
              {
                'key': entry.key,
                'value': entry.value,
                'updated_at': DateTime.now().toIso8601String(),
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      });
    } catch (e) {
      throwDbError('set all settings', e);
    }
  }

  @override
  Future<int> getInt(String key, {int defaultValue = 0}) async {
    final value = await get(key);
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  @override
  Future<double> getDouble(String key, {double defaultValue = 0.0}) async {
    final value = await get(key);
    if (value == null) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final value = await get(key);
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true' || value == '1';
  }

  @override
  Future<void> setInt(String key, int value) async {
    await set(key, value.toString());
  }

  @override
  Future<void> setDouble(String key, double value) async {
    await set(key, value.toString());
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await set(key, value.toString());
  }
}
