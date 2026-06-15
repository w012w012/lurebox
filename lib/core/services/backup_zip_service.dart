import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lurebox/core/database/database_provider.dart';
import 'package:lurebox/core/services/app_logger.dart';
import 'package:lurebox/core/services/error_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;

/// 备份 ZIP 服务 - ZIP 压缩备份与完整性校验
///
/// 提供 ZIP 格式的备份功能：
/// - 创建包含数据库和照片的 ZIP 备份文件
/// - 校验备份文件的完整性（SHA-256 校验和）
/// - 提取和验证备份内容
///
/// 使用 archive 包进行 ZIP 创建和解压
/// 使用 crypto 包进行 SHA-256 哈希计算

/// 备份元数据 - 描述备份文件的信息
///
/// 包含备份版本、导出时间、数据校验和、统计信息等
class BackupMetadata {
  const BackupMetadata({
    required this.version,
    required this.exportTime,
    required this.databaseChecksum,
    required this.photoCount,
    required this.fishCatchesCount,
    required this.equipmentCount,
    required this.appVersion,
    this.databaseVersion = 0,
  });

  /// 从 Map 创建 BackupMetadata
  factory BackupMetadata.fromMap(Map<String, dynamic> map) {
    return BackupMetadata(
      version: map['version'] as int,
      exportTime: DateTime.parse(map['exportTime'] as String),
      databaseChecksum: map['databaseChecksum'] as String,
      photoCount: map['photoCount'] as int,
      fishCatchesCount: map['fishCatchesCount'] as int,
      equipmentCount: map['equipmentCount'] as int,
      appVersion: map['appVersion'] as String,
      // 旧备份没有 databaseVersion 字段，用哨兵 0 表示"未知/不拦截"。
      databaseVersion: map['databaseVersion'] as int? ?? 0,
    );
  }

  /// 备份格式版本号
  final int version;

  /// 备份导出时间
  final DateTime exportTime;

  /// 数据库文件的 SHA-256 校验和
  final String databaseChecksum;

  /// 照片数量
  final int photoCount;

  /// 渔获记录数量
  final int fishCatchesCount;

  /// 装备记录数量
  final int equipmentCount;

  /// 应用版本号
  final String appVersion;

  /// 备份内嵌数据库的 schema 版本。
  ///
  /// 0 表示旧备份（未记录该字段），导入时不做跨版本拦截；
  /// 大于当前 app schema 版本则拒绝导入，避免新版备份回灌旧版 app。
  final int databaseVersion;

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'exportTime': exportTime.toIso8601String(),
      'databaseChecksum': databaseChecksum,
      'photoCount': photoCount,
      'fishCatchesCount': fishCatchesCount,
      'equipmentCount': equipmentCount,
      'appVersion': appVersion,
      'databaseVersion': databaseVersion,
    };
  }

  /// 复制并修改指定字段
  BackupMetadata copyWith({
    int? version,
    DateTime? exportTime,
    String? databaseChecksum,
    int? photoCount,
    int? fishCatchesCount,
    int? equipmentCount,
    String? appVersion,
    int? databaseVersion,
  }) {
    return BackupMetadata(
      version: version ?? this.version,
      exportTime: exportTime ?? this.exportTime,
      databaseChecksum: databaseChecksum ?? this.databaseChecksum,
      photoCount: photoCount ?? this.photoCount,
      fishCatchesCount: fishCatchesCount ?? this.fishCatchesCount,
      equipmentCount: equipmentCount ?? this.equipmentCount,
      appVersion: appVersion ?? this.appVersion,
      databaseVersion: databaseVersion ?? this.databaseVersion,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BackupMetadata &&
        other.version == version &&
        other.exportTime == exportTime &&
        other.databaseChecksum == databaseChecksum &&
        other.photoCount == photoCount &&
        other.fishCatchesCount == fishCatchesCount &&
        other.equipmentCount == equipmentCount &&
        other.appVersion == appVersion &&
        other.databaseVersion == databaseVersion;
  }

  @override
  int get hashCode {
    return Object.hash(
      version,
      exportTime,
      databaseChecksum,
      photoCount,
      fishCatchesCount,
      equipmentCount,
      appVersion,
      databaseVersion,
    );
  }
}

/// 备份导出选项 - 控制备份导出行为
///
/// 配置备份过程中是否包含照片、是否创建恢复点等
class BackupExportOptions {
  const BackupExportOptions({
    this.includePhotos = true,
    this.createRecoveryPoint = false,
  });

  /// 是否包含照片文件
  final bool includePhotos;

  /// 是否创建恢复点（保留当前数据库副本）
  final bool createRecoveryPoint;

  /// 默认导出选项（包含照片，不创建恢复点）
  static const BackupExportOptions defaultOptions = BackupExportOptions();

  /// 仅导出数据库选项
  static const BackupExportOptions databaseOnly = BackupExportOptions(
    includePhotos: false,
  );

  /// 复制并修改指定字段
  BackupExportOptions copyWith({
    bool? includePhotos,
    bool? createRecoveryPoint,
  }) {
    return BackupExportOptions(
      includePhotos: includePhotos ?? this.includePhotos,
      createRecoveryPoint: createRecoveryPoint ?? this.createRecoveryPoint,
    );
  }
}

/// 完整性校验结果 - 备份文件校验结果
///
/// 包含校验是否通过、错误信息（如果失败）和元数据
class IntegrityResult {
  const IntegrityResult({
    required this.isValid,
    this.errorMessage,
    this.metadata,
  });

  /// 校验成功的空结果
  const IntegrityResult.valid()
      : isValid = true,
        errorMessage = null,
        metadata = null;

  /// 校验失败的结果
  const IntegrityResult.invalid(String message)
      : isValid = false,
        errorMessage = message,
        metadata = null;

  /// 校验成功且包含元数据的结果
  const IntegrityResult.validWithMetadata(this.metadata)
      : isValid = true,
        errorMessage = null;

  /// 校验失败且包含元数据的结果
  const IntegrityResult.invalidWithMetadata(
    this.errorMessage,
    this.metadata,
  ) : isValid = false;

  /// 备份文件是否有效
  final bool isValid;

  /// 错误信息（如果校验失败）
  final String? errorMessage;

  /// 备份元数据
  final BackupMetadata? metadata;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IntegrityResult &&
        other.isValid == isValid &&
        other.errorMessage == errorMessage &&
        other.metadata == metadata;
  }

  @override
  int get hashCode => Object.hash(isValid, errorMessage, metadata);
}

/// 导入结果 - ZIP 导入操作的结果
///
/// 包含导入是否成功、错误信息（如果失败）和元数据
class ImportResult {
  const ImportResult({
    required this.isSuccess,
    this.errorMessage,
    this.metadata,
  });

  /// 导入成功的空结果
  const ImportResult.success()
      : isSuccess = true,
        errorMessage = null,
        metadata = null;

  /// 导入失败的结果
  const ImportResult.failure(String message)
      : isSuccess = false,
        errorMessage = message,
        metadata = null;

  /// 导入成功且包含元数据的结果
  const ImportResult.successWithMetadata(this.metadata)
      : isSuccess = true,
        errorMessage = null;

  /// 导入是否成功
  final bool isSuccess;

  /// 错误信息（如果失败）
  final String? errorMessage;

  /// 备份元数据（如果成功）
  final BackupMetadata? metadata;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImportResult &&
        other.isSuccess == isSuccess &&
        other.errorMessage == errorMessage &&
        other.metadata == metadata;
  }

  @override
  int get hashCode => Object.hash(isSuccess, errorMessage, metadata);
}

/// 备份 ZIP 服务类
///
/// 提供 ZIP 格式的备份功能：
/// - 创建包含数据库和照片的 ZIP 备份文件
/// - 校验备份文件的完整性（SHA-256 校验和）
class BackupZipService {
  BackupZipService(this._dbProvider);
  final DatabaseProvider _dbProvider;

  /// 最大允许导入的 ZIP 文件大小 (100 MB)
  static const int _maxImportSizeBytes = 100 * 1024 * 1024;

  /// 获取当前 app 版本号（从 pubspec.yaml 读取）
  Future<String> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version}+${packageInfo.buildNumber}';
    } on Exception catch (e) {
      AppLogger.w('BackupZipService', 'Failed to get app version: $e');
      return 'unknown';
    }
  }

  /// 导出数据库和照片到 ZIP 文件
  ///
  /// 步骤：
  /// 1. 关闭数据库连接（避免文件锁）
  /// 2. 复制数据库文件到临时目录
  /// 3. 收集所有照片路径
  /// 4. 复制照片到临时目录
  /// 5. 生成 metadata.json（含 SHA-256 校验和）
  /// 6. 创建 ZIP 文件
  /// 7. 返回 XFile 供分享
  Future<XFile> exportToZip({
    BackupExportOptions options = BackupExportOptions.defaultOptions,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final zipPath = p.join(
        tempDir.path,
        'lurebox_backup_${DateTime.now().millisecondsSinceEpoch}.zip',
      );
      await _buildBackupZip(zipPath, options);
      return XFile(zipPath);
    } catch (e) {
      AppLogger.e('BackupZipService', 'Export to ZIP error', e);
      rethrow;
    }
  }

  /// 导出数据库和照片到 ZIP 文件并保存到文档目录
  ///
  /// 与 exportToZip 的区别是：这个方法会将 ZIP 文件保存到应用文档目录
  /// 而不是临时目录，方便用户在"导出和备份管理"页面进行管理
  ///
  /// 返回保存后的文件路径
  Future<String> exportToZipAndSave({
    BackupExportOptions options = BackupExportOptions.defaultOptions,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final tempZipPath = p.join(
      tempDir.path,
      'lurebox_backup_${DateTime.now().millisecondsSinceEpoch}.zip',
    );
    try {
      // 1. 先在 temp 目录构建 ZIP
      await _buildBackupZip(tempZipPath, options);

      // 2. 将 ZIP 复制到应用文档目录
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savedZipName = 'lurebox_backup_$timestamp.zip';
      final savedZipPath = p.join(appDir.path, savedZipName);

      await File(tempZipPath).copy(savedZipPath);

      return savedZipPath;
    } catch (e) {
      AppLogger.e('BackupZipService', 'Export to ZIP and save error', e);
      rethrow;
    } finally {
      // 清理临时 ZIP（成功路径已复制到文档目录，失败路径无需保留）
      final tempZip = File(tempZipPath);
      if (await tempZip.exists()) {
        await tempZip.delete();
      }
    }
  }

  /// 构建备份 ZIP 到指定路径（exportToZip / exportToZipAndSave 共享实现）。
  ///
  /// 步骤：关闭并复制数据库（runExclusive 保护，避免并发重开撕裂备份）→
  /// 计算校验和 → 复制照片 → 收集统计 → 写 metadata.json → 打包 ZIP。
  /// 临时工作目录在 finally 中清理（含成功路径），避免泄漏。
  Future<void> _buildBackupZip(
    String zipPath,
    BackupExportOptions options,
  ) async {
    final dbPath = await _getDatabasePath();
    final tempDir = await getTemporaryDirectory();
    final backupDir = Directory(
      p.join(
        tempDir.path,
        'lurebox_backup_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
    await backupDir.create(recursive: true);

    try {
      // 1. 关闭数据库并复制文件到临时目录（互斥：并发重开会写 DB → 撕裂备份）
      final dbCopyPath = p.join(backupDir.path, 'lurebox.db');
      await _dbProvider.runExclusive(() async {
        final dbFile = File(dbPath);
        if (!await dbFile.exists()) {
          throw const DatabaseException('Database file not found');
        }
        await dbFile.copy(dbCopyPath);
      });

      // 2. 计算数据库文件的 SHA-256 校验和
      final dbChecksum = await _calculateSha256(dbCopyPath);

      // 3. 收集并复制照片（如果选项包含照片）
      var photoCount = 0;
      if (options.includePhotos) {
        final photosDir = Directory(p.join(backupDir.path, 'photos'));
        await photosDir.create(recursive: true);

        photoCount = await _copyPhotosToBackup(dbPath, photosDir.path);
      }

      // 4. 获取统计数据
      final stats = await _getBackupStats(dbPath);

      // 5. 生成 metadata.json
      final metadata = BackupMetadata(
        version: 1,
        exportTime: DateTime.now(),
        databaseChecksum: dbChecksum,
        photoCount: photoCount,
        fishCatchesCount: stats['fishCatchesCount']!,
        equipmentCount: stats['equipmentCount']!,
        appVersion: await _getAppVersion(),
        databaseVersion: DatabaseProvider.currentSchemaVersion,
      );

      final metadataJson =
          const JsonEncoder.withIndent('  ').convert(metadata.toMap());
      await File(p.join(backupDir.path, 'metadata.json'))
          .writeAsString(metadataJson);

      // 6. 创建 ZIP 文件
      await _createZip(backupDir.path, zipPath);
    } finally {
      // 清理临时备份工作目录（成功/失败均清理）
      if (await backupDir.exists()) {
        await backupDir.delete(recursive: true);
      }
    }
  }

  /// 获取数据库文件路径
  Future<String> _getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return p.join(dbPath, 'lurebox.db');
  }

  /// 删除指定文件（如果存在），缺失视为空操作。
  /// 用于清理 WAL/SHM 旁文件与失败的临时文件。
  Future<void> _deleteIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// 计算文件的 SHA-256 校验和
  Future<String> _calculateSha256(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 复制照片到备份目录
  ///
  /// 从数据库中读取所有照片路径（仅原图），并复制到备份目录。
  /// 注意：水印图片（watermarked_image_path）不备份，因为它们是临时文件，
  /// 且 WatermarkedImage Widget 会根据当前设置实时渲染水印。
  Future<int> _copyPhotosToBackup(String dbPath, String photosDir) async {
    final db = await openDatabase(dbPath, readOnly: true);
    var count = 0;

    try {
      // 查询所有渔获记录的照片路径（仅原图，不备份水印图片）
      final catches = await db.query(
        'fish_catches',
        columns: ['image_path'],
      );

      final appDir = await getApplicationDocumentsDirectory();
      final processedPaths = <String>{};

      for (final fish in catches) {
        final imagePath = fish['image_path'] as String?;
        if (imagePath != null &&
            imagePath.isNotEmpty &&
            !processedPaths.contains(imagePath)) {
          await _copyPhotoIfExists(imagePath, appDir.path, photosDir);
          processedPaths.add(imagePath);
          count++;
        }
      }

      return count;
    } finally {
      await db.close();
    }
  }

  /// 复制单个照片文件（如果存在）
  Future<void> _copyPhotoIfExists(
    String relativePath,
    String appDir,
    String photosDir,
  ) async {
    // 处理可能的相对路径或绝对路径
    String fullPath;
    if (p.isAbsolute(relativePath)) {
      fullPath = relativePath;
    } else {
      fullPath = p.join(appDir, relativePath);
    }

    final sourceFile = File(fullPath);
    if (await sourceFile.exists()) {
      final fileName = p.basename(fullPath);
      final destPath = p.join(photosDir, fileName);
      await sourceFile.copy(destPath);
    }
  }

  /// 获取备份统计数据
  Future<Map<String, int>> _getBackupStats(String dbPath) async {
    final db = await openDatabase(dbPath, readOnly: true);

    try {
      final fishCatchesCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM fish_catches'),
          ) ??
          0;

      final equipmentCount = Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM equipments WHERE is_deleted = 0',
            ),
          ) ??
          0;

      return {
        'fishCatchesCount': fishCatchesCount,
        'equipmentCount': equipmentCount,
      };
    } finally {
      await db.close();
    }
  }

  /// 创建 ZIP 文件
  Future<void> _createZip(String sourceDir, String zipPath) async {
    final sourceDirectory = Directory(sourceDir);
    final archive = Archive();

    // 递归添加目录中的所有文件
    await for (final entity in sourceDirectory.list(recursive: true)) {
      if (entity is File) {
        final relativePath = p.relative(entity.path, from: sourceDir);
        final bytes = await entity.readAsBytes();
        archive.addFile(ArchiveFile(relativePath, bytes.length, bytes));
      }
    }

    // 编码为 ZIP
    final zipData = ZipEncoder().encode(archive);
    if (zipData == null) {
      throw const DatabaseException('Failed to encode ZIP archive');
    }

    final zipFile = File(zipPath);
    await zipFile.writeAsBytes(zipData);
  }

  /// 从 ZIP 文件导入数据库和照片
  ///
  /// 步骤：
  /// 1. 使用 file_picker 选择 ZIP 文件
  /// 2. 提取 ZIP 到临时目录
  /// 3. 验证 metadata.json 存在且版本兼容
  /// 4. 验证数据库 SHA-256 校验和匹配
  /// 5. 创建恢复点（备份当前数据库）
  /// 6. 关闭当前数据库
  /// 7. 复制新数据库文件替换旧文件
  /// 8. 复制照片到应用文档目录
  /// 9. 重新打开数据库
  /// 10. 清理临时文件
  /// 11. 返回结果
  Future<ImportResult> importFromZip() async {
    try {
      // 1. 使用 file_picker 选择 ZIP 文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result == null || result.files.isEmpty) {
        return const ImportResult.failure('No file selected');
      }

      final zipPath = result.files.single.path;
      if (zipPath == null) {
        return const ImportResult.failure('Invalid file path');
      }

      return importFromZipPath(zipPath);
    } catch (e) {
      AppLogger.e('BackupZipService', 'Import from ZIP error', e);
      return ImportResult.failure('Import failed: $e');
    }
  }

  /// 从指定 ZIP 文件路径导入数据库和照片
  ///
  /// 适用于从已选择的备份文件恢复
  Future<ImportResult> importFromZipPath(String zipPath) async {
    try {
      final zipFile = File(zipPath);
      if (!await zipFile.exists()) {
        return const ImportResult.failure('File not found');
      }

      // 2. 提取 ZIP 到临时目录
      final tempDir = await getTemporaryDirectory();
      final extractDir = Directory(
        p.join(
          tempDir.path,
          'lurebox_import_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
      await extractDir.create(recursive: true);

      try {
        final zipFile = File(zipPath);
        final fileLength = await zipFile.length();
        if (fileLength > _maxImportSizeBytes) {
          return ImportResult.failure(
            'Backup file too large (${(fileLength / 1024 / 1024).toStringAsFixed(1)} MB, '
            'max ${(_maxImportSizeBytes / 1024 / 1024).toStringAsFixed(0)} MB)',
          );
        }
        final zipBytes = await zipFile.readAsBytes();
        final archive = ZipDecoder().decodeBytes(zipBytes);

        // 解压所有文件（含路径遍历防护）
        final canonicalExtractDir = p.canonicalize(extractDir.path);
        for (final archiveFile in archive) {
          final filename = archiveFile.name;
          final filePath = p.join(extractDir.path, filename);
          final resolvedPath = p.canonicalize(filePath);

          // 路径遍历防护：用 p.isWithin 做真正的目录包含判断，
          // 避免 startsWith 被同前缀的兄弟目录（如 extractDir 的同名前缀）绕过。
          if (!p.isWithin(canonicalExtractDir, resolvedPath) &&
              resolvedPath != canonicalExtractDir) {
            return ImportResult.failure(
              'Invalid backup: path traversal detected in "$filename"',
            );
          }

          if (archiveFile.isFile) {
            final outputFile = File(resolvedPath);
            await outputFile.parent.create(recursive: true);
            await outputFile.writeAsBytes(archiveFile.content as List<int>);
          } else {
            await Directory(resolvedPath).create(recursive: true);
          }
        }

        // 3. 验证 metadata.json 存在且版本兼容
        final metadataPath = p.join(extractDir.path, 'metadata.json');
        final metadataFile = File(metadataPath);

        if (!await metadataFile.exists()) {
          return const ImportResult.failure(
            'Invalid backup: metadata.json not found',
          );
        }

        final metadataContent = await metadataFile.readAsString();
        final metadataMap = jsonDecode(metadataContent) as Map<String, dynamic>;
        final metadata = BackupMetadata.fromMap(metadataMap);

        // 验证版本兼容性
        if (metadata.version > 1) {
          return ImportResult.failure(
            'Unsupported backup version: ${metadata.version}. '
            'Please update the app to import this backup.',
          );
        }

        // 跨 schema 版本拦截：新版 app 导出的备份（databaseVersion 更高）
        // 不能回灌到旧版 app —— _onDowngrade 为空操作，旧的非幂等迁移
        // 之后可能重跑导致损坏。databaseVersion==0 为旧备份，放行不拦截。
        if (metadata.databaseVersion > DatabaseProvider.currentSchemaVersion) {
          return ImportResult.failure(
            'This backup was created by a newer app version '
            '(database v${metadata.databaseVersion} > '
            'v${DatabaseProvider.currentSchemaVersion}). '
            'Please update the app to import this backup.',
          );
        }

        // 4. 验证数据库 SHA-256 校验和匹配
        final dbPath = p.join(extractDir.path, 'lurebox.db');
        final dbFile = File(dbPath);

        if (!await dbFile.exists()) {
          return const ImportResult.failure(
            'Invalid backup: database file not found',
          );
        }

        final actualChecksum = await _calculateSha256(dbPath);
        if (actualChecksum != metadata.databaseChecksum) {
          return const ImportResult.failure(
            'Backup integrity check failed: database checksum mismatch. '
            'The backup file may be corrupted.',
          );
        }

        // 5. 创建恢复点（备份当前数据库）
        final currentDbPath = await _getDatabasePath();
        final currentDbFile = File(currentDbPath);

        if (await currentDbFile.exists()) {
          final appDir = await getApplicationDocumentsDirectory();
          final recoveryDir = Directory(p.join(appDir.path, 'recovery'));
          await recoveryDir.create(recursive: true);

          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final recoveryPath = p.join(
            recoveryDir.path,
            'lurebox_recovery_$timestamp.db',
          );
          await currentDbFile.copy(recoveryPath);
        }

        // 6. 获取本应用的文档目录（用于规范化照片路径）
        final appDir = await getApplicationDocumentsDirectory();

        // 7. 规范化备份数据库中的图片路径为绝对路径
        // 新格式（相对路径如 'photos/xxx.jpg'）和旧格式（绝对路径如 'Documents/xxx.jpg'）
        // 都统一转换为 'Documents/photos/xxx.jpg'（绝对路径）
        final tempDb = await openDatabase(dbPath);
        try {
          final catches = await tempDb.query(
            'fish_catches',
            columns: ['id', 'image_path'],
          );
          for (final fish in catches) {
            final id = fish['id']! as int;
            final imagePath = fish['image_path'] as String?;
            if (imagePath != null && imagePath.isNotEmpty) {
              final fileName = p.basename(imagePath);
              // 统一存放到 Documents/photos/ 子目录下（绝对路径）
              final newAbsolutePath = p.join(appDir.path, 'photos', fileName);
              await tempDb.update(
                'fish_catches',
                {'image_path': newAbsolutePath},
                where: 'id = ?',
                whereArgs: [id],
              );
            }
          }
        } finally {
          await tempDb.close();
        }

        // 8. 先复制照片到应用文档目录的 photos/ 子目录。
        //    照片是幂等/增量的：先复制即使后续 DB 交换失败也安全（旧 DB 仍由
        //    步骤 5 的恢复点保护）。若照片复制失败，则在触碰活动 DB 之前失败。
        final photosDir = p.join(extractDir.path, 'photos');
        if (await Directory(photosDir).exists()) {
          final destPhotosDir = Directory(p.join(appDir.path, 'photos'));
          await destPhotosDir.create(recursive: true);

          final photosSourceDir = Directory(photosDir);
          await for (final entity in photosSourceDir.list()) {
            if (entity is File) {
              final fileName = p.basename(entity.path);
              final destPath = p.join(destPhotosDir.path, fileName);
              await entity.copy(destPath);
            }
          }
          AppLogger.i('BackupZipService', 'Photos imported from backup');
        }

        // 9. 互斥临界区：关闭当前库 → 清理陈旧 WAL/SHM 旁文件 → 原子换库 → 重开。
        //    runExclusive 会先 close()，并在其内部阻塞任何 database getter，
        //    避免 close→rename 之间被重新打开旧库横跨文件交换持有连接。
        await _dbProvider.runExclusive(() async {
          // 9a. 清理活动库残留的 WAL/SHM 旁文件。
          //     WAL 模式下，崩溃/非干净关闭可能遗留 -wal/-shm；若不删除，
          //     恢复后的新库（自带无旁文件）会被陈旧 WAL 回放污染 → 静默损坏。
          await _deleteIfExists('$currentDbPath-wal');
          await _deleteIfExists('$currentDbPath-shm');

          // 9b. 原子替换：用临时文件 + rename 确保失败时原 DB 不损坏
          final tempDbPath = '$dbPath.in_progress';
          try {
            await File(dbPath).copy(tempDbPath);
            // 验证临时文件完整性
            final verifyDb = await openDatabase(tempDbPath);
            await verifyDb.close();
            // rename 前再次清理可能新生成的旁文件（验证打开可能创建 -wal/-shm）
            await _deleteIfExists('$tempDbPath-wal');
            await _deleteIfExists('$tempDbPath-shm');
            // 原子性 rename：成功则替换，失败则原 DB 不受影响
            final renamed = await File(tempDbPath).rename(currentDbPath);
            if (!File(renamed.path).existsSync()) {
              throw StateError('Database rename failed unexpectedly');
            }
            // rename 后再保险清理一次旧旁文件（恢复的备份库无旁文件，删旧即可）
            await _deleteIfExists('$currentDbPath-wal');
            await _deleteIfExists('$currentDbPath-shm');
          } catch (e) {
            // 清理失败的临时文件
            await _deleteIfExists(tempDbPath);
            await _deleteIfExists('$tempDbPath-wal');
            await _deleteIfExists('$tempDbPath-shm');
            rethrow;
          }
        });

        // 10. 重新打开数据库（runExclusive 已结束、维护锁已释放，getter 打开新库）
        await _dbProvider.database;

        // 11. 清理临时文件
        await extractDir.delete(recursive: true);

        return ImportResult.successWithMetadata(metadata);
      } catch (e) {
        // 清理临时目录
        if (await extractDir.exists()) {
          await extractDir.delete(recursive: true);
        }
        rethrow;
      }
    } catch (e) {
      AppLogger.e('BackupZipService', 'Import from ZIP error', e);
      return ImportResult.failure('Import failed: $e');
    }
  }
}
