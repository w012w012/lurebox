import 'package:sqflite/sqflite.dart' hide DatabaseException;
import '../database/database_provider.dart';
import '../services/error_service.dart';
import 'settings_repository.dart';

/// SQLite 实现 - 应用设置仓储层
///
/// 使用 SQLite 数据库实现应用设置的键值对存储。
/// 数据表名：settings

class SqliteSettingsRepository implements SettingsRepository {
  static const String _tableName = 'settings';

  /// 可选的数据库实例（用于测试注入）
  Future<Database>? _testDb;

  /// 内部获取数据库实例
  Future<Database> get _database async {
    final testDb = _testDb;
    if (testDb != null) return await testDb;
    return await DatabaseProvider.instance.database;
  }

  /// 无参构造函数（使用默认 DatabaseService）
  SqliteSettingsRepository();

  /// 带数据库的构造函数（用于测试）
  SqliteSettingsRepository.withDatabase(Future<Database> testDb) {
    _testDb = testDb;
  }

  @override
  Future<String?> get(String key) async {
    try {
      final db = await _database;
      final results = await db.query(
        _tableName,
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
      if (results.isEmpty) return null;
      return results.first['value'] as String?;
    } catch (e) {
      throw DatabaseException('Failed to get setting: $e');
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
      final db = await _database;
      await db.insert(
          _tableName,
          {
            'key': key,
            'value': value,
            'updated_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw DatabaseException('Failed to set setting: $e');
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      final db = await _database;
      await db.delete(_tableName, where: 'key = ?', whereArgs: [key]);
    } catch (e) {
      throw DatabaseException('Failed to delete setting: $e');
    }
  }

  @override
  Future<bool> exists(String key) async {
    try {
      final db = await _database;
      final results = await db.query(
        _tableName,
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
      return results.isNotEmpty;
    } catch (e) {
      throw DatabaseException('Failed to check setting existence: $e');
    }
  }

  @override
  Future<Map<String, String>> getAll() async {
    try {
      final db = await _database;
      final results = await db.query(_tableName);
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
      throw DatabaseException('Failed to get all settings: $e');
    }
  }

  @override
  Future<void> setAll(Map<String, String> settings) async {
    try {
      final db = await _database;
      await db.transaction((txn) async {
        for (final entry in settings.entries) {
          await txn.insert(
              _tableName,
              {
                'key': entry.key,
                'value': entry.value,
                'updated_at': DateTime.now().toIso8601String(),
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      });
    } catch (e) {
      throw DatabaseException('Failed to set all settings: $e');
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
