import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';

import '../database/database_provider.dart';
import '../models/cloud_config.dart';
import '../models/backup_history.dart';
import '../repositories/backup_config_repository.dart';
import 'backup_service.dart';
import 'backup_zip_service.dart';

/// 增强备份服务
///
/// 整合 JSON 和 ZIP 备份，提供统一的备份管理接口
/// - 自动保存备份历史
/// - 支持云配置持久化
/// - 自动清理过期备份
class EnhancedBackupService {
  final DatabaseProvider _dbProvider;
  final BackupConfigRepository _configRepo;
  late final BackupService _backupService;
  late final BackupZipService _backupZipService;

  EnhancedBackupService(this._dbProvider, this._configRepo) {
    _backupService = BackupService(_dbProvider);
    _backupZipService = BackupZipService(_dbProvider);
  }

  // ========== 云配置管理 ==========

  /// 保存 WebDAV 配置
  Future<int> saveWebDAVConfig({
    required String serverUrl,
    required String username,
    required String password,
    bool setAsActive = true,
  }) async {
    final now = DateTime.now();
    final config = CloudConfig(
      provider: CloudProvider.webdav,
      serverUrl: serverUrl,
      username: username,
      password: password,
      isActive: setAsActive,
      createdAt: now,
      updatedAt: now,
    );

    final id = await _configRepo.saveCloudConfig(config);

    if (setAsActive) {
      await _configRepo.setActiveCloudConfig(id);
    }

    return id;
  }

  /// 获取活跃的 WebDAV 配置
  Future<CloudConfig?> getActiveWebDAVConfig() async {
    return await _configRepo.getActiveCloudConfig();
  }

  /// 获取所有云配置
  Future<List<CloudConfig>> getAllCloudConfigs() async {
    return await _configRepo.getAllCloudConfigs();
  }

  /// 删除云配置
  Future<int> deleteCloudConfig(int id) async {
    return await _configRepo.deleteCloudConfig(id);
  }

  // ========== 统一导出接口 ==========

  /// 导出备份（自动保存历史记录）
  ///
  /// [format] - 备份格式：json, zip_full, zip_db_only
  Future<XFile> exportBackup(
    BackupType format, {
    bool shareAfterExport = true,
  }) async {
    final XFile xFile;
    final DateTime exportTime = DateTime.now();

    switch (format) {
      case BackupType.json:
        final path = await _backupService.exportToJson();
        xFile = XFile(path);
        break;
      case BackupType.zipFull:
        xFile = await _backupZipService.exportToZip(
          options: const BackupExportOptions(
            includePhotos: true,
            createRecoveryPoint: true,
          ),
        );
        break;
      case BackupType.zipDbOnly:
        xFile = await _backupZipService.exportToZip(
          options: const BackupExportOptions(
            includePhotos: false,
            createRecoveryPoint: true,
          ),
        );
        break;
    }

    // 获取文件大小
    final file = File(xFile.path);
    final fileSize = await file.length();

    // 获取统计数据
    final db = await _dbProvider.database;
    final stats = await _getBackupStats(db);

    // 保存备份历史
    final history = BackupHistory(
      filePath: xFile.path,
      fileName: p.basename(xFile.path),
      backupType: format,
      fileSize: fileSize,
      fishCount: stats['fishCount'] ?? 0,
      equipmentCount: stats['equipmentCount'] ?? 0,
      photoCount: stats['photoCount'] ?? 0,
      createdAt: exportTime,
    );
    await _configRepo.addBackupHistory(history);

    // 清理旧备份历史（保留最近20条）
    await cleanupOldBackupHistory(keepCount: 20);

    // 分享文件
    if (shareAfterExport) {
      await Share.shareXFiles(
        [xFile],
        subject: 'LureBox ${format.label}',
        text: '包含 ${stats['fishCount']} 条渔获记录',
      );
    }

    return xFile;
  }

  /// 获取备份统计
  Future<Map<String, int>> _getBackupStats(Database db) async {
    final fishCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM fish_catches'),
        ) ??
        0;
    final equipmentCount = Sqflite.firstIntValue(
          await db
              .rawQuery('SELECT COUNT(*) FROM equipments WHERE is_deleted = 0'),
        ) ??
        0;

    // 统计照片数量
    final catches = await db.query(
      'fish_catches',
      columns: ['image_path', 'watermarked_image_path'],
    );
    int photoCount = 0;
    for (final fish in catches) {
      if (fish['image_path'] != null) photoCount++;
      if (fish['watermarked_image_path'] != null) photoCount++;
    }

    return {
      'fishCount': fishCount,
      'equipmentCount': equipmentCount,
      'photoCount': photoCount,
    };
  }

  // ========== 备份历史管理 ==========

  /// 获取备份历史列表
  Future<List<BackupHistory>> getBackupHistory({int limit = 20}) async {
    return await _configRepo.getBackupHistory(limit: limit);
  }

  /// 删除备份历史记录（同时删除文件）
  Future<int> deleteBackupHistory(int id, String filePath) async {
    // 删除文件
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Failed to delete backup file: $e');
    }

    // 删除数据库记录
    return await _configRepo.deleteBackupHistory(id);
  }

  /// 清理旧备份历史
  Future<int> cleanupOldBackupHistory({int keepCount = 20}) async {
    return await _configRepo.cleanupOldBackupHistory(keepCount);
  }

  // ========== 恢复点管理 ==========

  /// 清理过期恢复点（保留最近 N 个）
  Future<int> cleanupOldRecoveryPoints({int keepCount = 2}) async {
    final appDir = await getApplicationDocumentsDirectory();
    final recoveryDir = Directory(p.join(appDir.path, 'recovery'));

    if (!await recoveryDir.exists()) return 0;

    final List<File> files = [];
    await for (final entity in recoveryDir.list()) {
      if (entity is File &&
          p.basename(entity.path).startsWith('lurebox_recovery_')) {
        files.add(entity);
      }
    }

    if (files.length <= keepCount) return 0;

    // 获取文件修改时间并排序（最旧的在前）
    final fileWithTime = <(File file, DateTime time)>[];
    for (final file in files) {
      fileWithTime.add((file, await file.lastModified()));
    }
    fileWithTime.sort((a, b) => a.$2.compareTo(b.$2));

    // 删除旧的恢复点
    int deletedCount = 0;
    for (var i = 0; i < fileWithTime.length - keepCount; i++) {
      try {
        await fileWithTime[i].$1.delete();
        deletedCount++;
      } catch (e) {
        debugPrint('Failed to delete recovery point: $e');
      }
    }

    return deletedCount;
  }

  /// 获取恢复点列表
  Future<List<File>> getRecoveryPoints() async {
    final appDir = await getApplicationDocumentsDirectory();
    final recoveryDir = Directory(p.join(appDir.path, 'recovery'));

    if (!await recoveryDir.exists()) return [];

    final List<File> files = [];
    await for (final entity in recoveryDir.list()) {
      if (entity is File &&
          p.basename(entity.path).startsWith('lurebox_recovery_')) {
        files.add(entity);
      }
    }

    // 获取文件修改时间并排序（最新的在前）
    final fileWithTime = <(File file, DateTime time)>[];
    for (final file in files) {
      fileWithTime.add((file, await file.lastModified()));
    }
    fileWithTime.sort((a, b) => b.$2.compareTo(a.$2));

    return fileWithTime.map((t) => t.$1).toList();
  }

  // ========== WebDAV 云备份（使用保存的配置）==========

  /// 上传到 WebDAV（使用保存的配置）
  Future<String?> uploadToCloud() async {
    final config = await getActiveWebDAVConfig();
    if (config == null) {
      throw Exception('No active cloud configuration found');
    }

    return await _backupService.uploadToWebDAV(
      serverUrl: config.serverUrl,
      username: config.username,
      password: config.password,
    );
  }

  /// 测试 WebDAV 连接（使用保存的配置）
  Future<bool> testCloudConnection() async {
    final config = await getActiveWebDAVConfig();
    if (config == null) return false;

    return await _backupService.testWebDAVConnection(
      serverUrl: config.serverUrl,
      username: config.username,
      password: config.password,
    );
  }

  // ========== JSON 导入增强（避免重复数据）=========

  /// 导入 JSON（自动去重）
  ///
  /// 在导入前检查记录是否已存在，避免重复
  Future<ImportResultWithStats> importFromJsonWithDeduplication(
      String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found');
    }

    final jsonString = await file.readAsString();
    final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

    final db = await _dbProvider.database;
    int importedCount = 0;
    int skippedCount = 0;
    int errorCount = 0;

    await db.transaction((txn) async {
      // 导入渔获记录（基于 catch_time + species 去重）
      if (backupData.containsKey('fishCatches')) {
        final fishCatches = backupData['fishCatches'] as List;
        for (final fish in fishCatches) {
          try {
            final map = Map<String, dynamic>.from(fish);
            final catchTime = map['catch_time'] as int?;
            final species = map['species'] as String?;

            // 检查是否已存在相同时间和物种的记录
            if (catchTime != null && species != null) {
              final existing = await txn.query(
                'fish_catches',
                where: 'catch_time = ? AND species = ?',
                whereArgs: [catchTime, species],
                limit: 1,
              );
              if (existing.isNotEmpty) {
                skippedCount++;
                continue;
              }
            }

            await txn.insert('fish_catches', map);
            importedCount++;
          } catch (e) {
            errorCount++;
            debugPrint('Failed to import fish catch: $e');
          }
        }
      }

      // 导入装备（基于 type + brand + model 去重）
      if (backupData.containsKey('equipments')) {
        final equipments = backupData['equipments'] as List;
        for (final equipment in equipments) {
          try {
            final map = Map<String, dynamic>.from(equipment);
            final type = map['type'] as String?;
            final brand = map['brand'] as String?;
            final model = map['model'] as String?;

            // 检查是否已存在
            if (type != null) {
              final where = <String>[];
              final whereArgs = <dynamic>[];

              where.add('type = ?');
              whereArgs.add(type);

              if (brand != null && brand.isNotEmpty) {
                where.add('brand = ?');
                whereArgs.add(brand);
              }
              if (model != null && model.isNotEmpty) {
                where.add('model = ?');
                whereArgs.add(model);
              }

              final existing = await txn.query(
                'equipments',
                where: where.join(' AND '),
                whereArgs: whereArgs,
                limit: 1,
              );
              if (existing.isNotEmpty) {
                skippedCount++;
                continue;
              }
            }

            await txn.insert('equipments', map);
          } catch (e) {
            errorCount++;
            debugPrint('Failed to import equipment: $e');
          }
        }
      }

      // 导入物种历史（基于 name 去重）
      if (backupData.containsKey('speciesHistory')) {
        final speciesHistory = backupData['speciesHistory'] as List;
        for (final species in speciesHistory) {
          try {
            final map = Map<String, dynamic>.from(species);
            final name = map['name'] as String?;

            if (name != null) {
              final existing = await txn.query(
                'species_history',
                where: 'name = ?',
                whereArgs: [name],
                limit: 1,
              );
              if (existing.isNotEmpty) {
                skippedCount++;
                continue;
              }
            }

            await txn.insert('species_history', map);
          } catch (e) {
            errorCount++;
            debugPrint('Failed to import species history: $e');
          }
        }
      }

      // 导入设置（使用 replace 策略）
      if (backupData.containsKey('settings')) {
        final settings = backupData['settings'] as List;
        for (final setting in settings) {
          try {
            final map = Map<String, dynamic>.from(setting);
            await txn.insert(
              'settings',
              map,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          } catch (e) {
            errorCount++;
            debugPrint('Failed to import setting: $e');
          }
        }
      }
    });

    return ImportResultWithStats(
      importedCount: importedCount,
      skippedCount: skippedCount,
      errorCount: errorCount,
    );
  }
}

/// 导入结果（带统计信息）
class ImportResultWithStats {
  final int importedCount;
  final int skippedCount;
  final int errorCount;

  const ImportResultWithStats({
    required this.importedCount,
    required this.skippedCount,
    required this.errorCount,
  });

  int get totalCount => importedCount + skippedCount + errorCount;
  bool get hasErrors => errorCount > 0;
  bool get hasSkipped => skippedCount > 0;
}
