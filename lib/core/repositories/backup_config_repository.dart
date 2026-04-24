import 'package:sqflite/sqflite.dart';
import '../models/cloud_config.dart';
import '../models/backup_history.dart';
import '../services/secure_storage_service.dart';
import '../services/app_logger.dart';

/// 备份配置仓库接口
abstract class BackupConfigRepository {
  /// 保存云配置
  Future<int> saveCloudConfig(CloudConfig config);

  /// 获取活跃的云配置
  Future<CloudConfig?> getActiveCloudConfig();

  /// 获取所有云配置
  Future<List<CloudConfig>> getAllCloudConfigs();

  /// 更新云配置
  Future<int> updateCloudConfig(CloudConfig config);

  /// 删除云配置
  Future<int> deleteCloudConfig(int id);

  /// 设置活跃配置
  Future<void> setActiveCloudConfig(int id);

  /// 添加备份历史记录
  Future<int> addBackupHistory(BackupHistory history);

  /// 获取备份历史列表
  Future<List<BackupHistory>> getBackupHistory({int limit = 20});

  /// 删除备份历史记录
  Future<int> deleteBackupHistory(int id);

  /// 清理旧备份历史（保留最近N条）
  Future<int> cleanupOldBackupHistory(int keepCount);
}

/// SQLite 备份配置仓库实现
///
/// 密码由 [CloudPasswordStorage] 管理，不再持久化到 SQLite。
class SqliteBackupConfigRepository implements BackupConfigRepository {
  final Future<Database> _dbFuture;
  final CloudPasswordStorage _passwordStorage;

  SqliteBackupConfigRepository(this._dbFuture, this._passwordStorage);

  Future<Database> get _db async => await _dbFuture;

  @override
  Future<int> saveCloudConfig(CloudConfig config) async {
    final db = await _db;
    final map = config.toDbMap()..remove('id');
    final id = await db.insert('cloud_configs', map);
    if (config.password.isNotEmpty) {
      await _passwordStorage.save(id, config.password);
    }
    return id;
  }

  @override
  Future<CloudConfig?> getActiveCloudConfig() async {
    final db = await _db;
    final results = await db.query(
      'cloud_configs',
      where: 'is_active = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return _hydratePassword(results.first);
  }

  @override
  Future<List<CloudConfig>> getAllCloudConfigs() async {
    final db = await _db;
    final results = await db.query(
      'cloud_configs',
      orderBy: 'updated_at DESC',
    );
    return Future.wait(results.map(_hydratePassword));
  }

  @override
  Future<int> updateCloudConfig(CloudConfig config) async {
    if (config.id == null) {
      throw ArgumentError('Cannot update config without id');
    }
    final db = await _db;
    await db.update(
      'cloud_configs',
      config.toDbMap(),
      where: 'id = ?',
      whereArgs: [config.id],
    );
    if (config.password.isNotEmpty) {
      await _passwordStorage.save(config.id!, config.password);
    }
    return config.id!;
  }

  @override
  Future<int> deleteCloudConfig(int id) async {
    final db = await _db;
    await _passwordStorage.delete(id);
    return await db.delete(
      'cloud_configs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> setActiveCloudConfig(int id) async {
    final db = await _db;
    await db.transaction((txn) async {
      // 先取消所有活跃状态
      await txn.update(
        'cloud_configs',
        {'is_active': 0},
      );
      // 设置指定配置为活跃
      await txn.update(
        'cloud_configs',
        {
          'is_active': 1,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<int> addBackupHistory(BackupHistory history) async {
    final db = await _db;
    final map = history.toMap()..remove('id');
    return await db.insert('backup_history', map);
  }

  @override
  Future<List<BackupHistory>> getBackupHistory({int limit = 20}) async {
    final db = await _db;
    final results = await db.query(
      'backup_history',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return results.map((e) => BackupHistory.fromMap(e)).toList();
  }

  @override
  Future<int> deleteBackupHistory(int id) async {
    final db = await _db;
    return await db.delete(
      'backup_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> cleanupOldBackupHistory(int keepCount) async {
    final db = await _db;
    // 获取要删除的记录ID
    final results = await db.query(
      'backup_history',
      orderBy: 'created_at DESC',
      offset: keepCount,
    );

    if (results.isEmpty) return 0;

    final idsToDelete = results.map((e) => e['id'] as int).toList();
    return await db.delete(
      'backup_history',
      where: 'id IN (${idsToDelete.map((_) => '?').join(',')})',
      whereArgs: idsToDelete,
    );
  }

  /// 从安全存储中读取密码并填充到 CloudConfig
  Future<CloudConfig> _hydratePassword(Map<String, dynamic> row) async {
    final config = CloudConfig.fromMap(row);
    if (config.id == null) return config;
    final storedPassword = await _passwordStorage.get(config.id!);
    if (storedPassword != null && storedPassword.isNotEmpty) {
      return config.copyWith(password: storedPassword);
    }
    return config;
  }

  /// 将旧版 DB 中的明文密码迁移到安全存储
  ///
  /// 调用时机：App 启动时执行一次。读取所有 DB 中仍有明文密码的配置，
  /// 将密码迁移到 flutter_secure_storage，然后清空 DB 中的 password 字段。
  Future<void> migrateExistingPasswords() async {
    final db = await _db;
    final results = await db.query('cloud_configs');
    for (final row in results) {
      final id = row['id'] as int?;
      final dbPassword = row['password'] as String? ?? '';
      if (id != null && dbPassword.isNotEmpty) {
        await _passwordStorage.save(id, dbPassword);
        await db.update(
          'cloud_configs',
          {'password': ''},
          where: 'id = ?',
          whereArgs: [id],
        );
        AppLogger.i(
          'BackupConfigRepository',
          'Migrated password for cloud config $id to secure storage',
        );
      }
    }
  }
}
