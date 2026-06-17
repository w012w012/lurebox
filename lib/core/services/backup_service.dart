import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:lurebox/core/database/database_provider.dart';
import 'package:lurebox/core/services/app_logger.dart';
import 'package:lurebox/core/services/error_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;

/// 备份服务 - 数据备份与云同步
///
/// 提供完整的数据备份解决方案：
/// - 本地备份：将渔获、装备、物种历史、设置导出为带时间戳的 JSON 文件
/// - 本地恢复：从 JSON 文件导入数据（支持事务确保数据完整性）
/// - 云端备份：通过 WebDAV 协议上传备份到远程服务器
/// - 云端同步：测试连接、下载云端备份
///
/// 备份数据包含版本号和导出时间戳，支持数据迁移。

class BackupService {
  BackupService(this._dbProvider);
  final DatabaseProvider _dbProvider;

  /// 固定的"最新备份"远程文件名。
  ///
  /// [uploadToWebDAV] 默认写入带时间戳的文件（保留历史、向后兼容）；
  /// 应用内"云端恢复"需要一个确定的文件名才能下载，因此 [EnhancedBackupService]
  /// 在上传时额外以该固定名写一份"最新"快照，下载时按此名取回。
  static const String latestBackupFileName = 'lurebox_backup_latest.json';

  /// 单次下载允许缓冲的最大字节数 (50 MB)。
  /// 即使服务器未返回 Content-Length（contentLength == -1），也按此上限流式截断，
  /// 避免恶意/异常超大响应耗尽内存。
  static const int _maxDownloadBytes = 50 * 1024 * 1024;

  Future<String> exportToJson() async {
    final db = await _dbProvider.database;
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/lurebox_backup_$timestamp.json';

    final fishCatches = await db.query('fish_catches');
    final equipments = await db.query('equipments');
    final speciesHistory = await db.query('species_history');
    final settings = await db.query('settings');
    final userSpeciesAlias = await db.query('user_species_alias');

    final backupData = {
      'version': 1,
      'exportTime': DateTime.now().toIso8601String(),
      'fishCatches': fishCatches,
      'equipments': equipments,
      'speciesHistory': speciesHistory,
      'settings': settings,
      'userSpeciesAlias': userSpeciesAlias,
    };

    final jsonString = const JsonEncoder.withIndent(' ').convert(backupData);
    final file = File(filePath);
    await file.writeAsString(jsonString);

    return filePath;
  }

  Future<int> importFromJson(String filePath) async {
    final stat = await FileStat.stat(filePath);
    if (stat.type == FileSystemEntityType.notFound) {
      throw const DatabaseException('File not found');
    }

    final file = File(filePath);

    final jsonString = await file.readAsString();
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const DatabaseException('Invalid backup file format');
    }
    final backupData = decoded;

    final db = await _dbProvider.database;
    var importedCount = 0;

    await db.transaction((txn) async {
      if (backupData['fishCatches'] is List) {
        final fishCatches = backupData['fishCatches'] as List;
        for (final fish in fishCatches) {
          if (fish is! Map) continue;
          await txn.insert(
            'fish_catches',
            Map<String, dynamic>.from(fish),
          );
          importedCount++;
        }
      }

      if (backupData['equipments'] is List) {
        final equipments = backupData['equipments'] as List;
        for (final equipment in equipments) {
          if (equipment is! Map) continue;
          await txn.insert(
            'equipments',
            Map<String, dynamic>.from(equipment),
          );
        }
      }

      if (backupData['speciesHistory'] is List) {
        final speciesHistory = backupData['speciesHistory'] as List;
        for (final species in speciesHistory) {
          if (species is! Map) continue;
          await txn.insert(
            'species_history',
            Map<String, dynamic>.from(species),
          );
        }
      }

      if (backupData['settings'] is List) {
        final settings = backupData['settings'] as List;
        for (final setting in settings) {
          if (setting is! Map) continue;
          final map = Map<String, dynamic>.from(setting);
          await txn.insert(
            'settings',
            map,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // user_species_alias 在被引用的表（fish_species 等）之后导入；
      // user_alias 唯一，沿用 replace 冲突策略避免重复别名导入失败。
      if (backupData['userSpeciesAlias'] is List) {
        final userSpeciesAlias = backupData['userSpeciesAlias'] as List;
        for (final alias in userSpeciesAlias) {
          if (alias is! Map) continue;
          final map = Map<String, dynamic>.from(alias);
          await txn.insert(
            'user_species_alias',
            map,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });

    return importedCount;
  }

  /// 上传 JSON 备份到 WebDAV。
  ///
  /// [fileName] 为远程文件名；默认带时间戳（保留历史快照）。传入
  /// [latestBackupFileName] 可覆盖固定的"最新"快照，供应用内云端恢复读取。
  Future<String> uploadToWebDAV({
    required String serverUrl,
    required String username,
    required String password,
    String? fileName,
  }) async {
    HttpClient? client;
    try {
      final db = await _dbProvider.database;
      final fishCatches = await db.query('fish_catches');
      final equipments = await db.query('equipments');
      final speciesHistory = await db.query('species_history');
      final settings = await db.query('settings');
      final userSpeciesAlias = await db.query('user_species_alias');

      final backupData = {
        'version': 1,
        'exportTime': DateTime.now().toIso8601String(),
        'fishCatches': fishCatches,
        'equipments': equipments,
        'speciesHistory': speciesHistory,
        'settings': settings,
        // 与本地 exportToJson 保持一致：包含用户自定义品种别名（FIX-7 往返一致性）。
        'userSpeciesAlias': userSpeciesAlias,
      };

      final jsonString = const JsonEncoder.withIndent(' ').convert(backupData);
      final bytes = utf8.encode(jsonString);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final remoteName = fileName ?? 'lurebox_backup_$timestamp.json';
      final baseUrl = serverUrl.endsWith('/')
          ? serverUrl.substring(0, serverUrl.length - 1)
          : serverUrl;
      final url = '$baseUrl/$remoteName';

      final uri = Uri.parse(url);
      if (uri.host.isEmpty) {
        throw const DatabaseException('Invalid server URL: missing host');
      }
      if (uri.scheme != 'https') {
        throw const DatabaseException(
          'WebDAV URL must use HTTPS for security',
        );
      }

      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 30);
      final request = await client.openUrl('PUT', uri);

      final credentials = base64Encode(utf8.encode('$username:$password'));
      request.headers.set('Authorization', 'Basic $credentials');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Content-Length', bytes.length.toString());

      request.add(bytes);

      final response = await request.close();

      if (response.statusCode == 201 || response.statusCode == 204) {
        return url;
      } else {
        throw DatabaseException('Upload failed: ${response.statusCode}');
      }
    } on Exception catch (e) {
      AppLogger.e('BackupService', 'WebDAV upload error', e);
      rethrow;
    } finally {
      client?.close();
    }
  }

  Future<bool> testWebDAVConnection({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    HttpClient? client;
    try {
      final url = serverUrl.endsWith('/')
          ? serverUrl.substring(0, serverUrl.length - 1)
          : serverUrl;

      final uri = Uri.parse(url);
      if (uri.host.isEmpty) return false;
      if (uri.scheme != 'https') return false;

      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);
      final request = await client.openUrl('PROPFIND', uri);

      final credentials = base64Encode(utf8.encode('$username:$password'));
      request.headers.set('Authorization', 'Basic $credentials');
      request.headers.set('Depth', '0');

      final response = await request.close();

      return response.statusCode == 207 || response.statusCode == 200;
    } on Exception catch (e) {
      AppLogger.e('BackupService', 'WebDAV test connection error', e);
      return false;
    } finally {
      client?.close();
    }
  }

  Future<Map<String, dynamic>?> downloadFromWebDAV({
    required String serverUrl,
    required String username,
    required String password,
    required String fileName,
  }) async {
    HttpClient? client;
    try {
      // Validate fileName to prevent path traversal
      if (!RegExp(r'^[\w\-.]+$').hasMatch(fileName)) {
        throw const DatabaseException('Invalid backup file name');
      }

      final baseUrl = serverUrl.endsWith('/')
          ? serverUrl.substring(0, serverUrl.length - 1)
          : serverUrl;
      final url = '$baseUrl/$fileName';

      final uri = Uri.parse(url);
      if (uri.host.isEmpty) return null;
      if (uri.scheme != 'https') {
        throw const DatabaseException(
          'WebDAV URL must use HTTPS for security',
        );
      }

      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 30);
      final request = await client.openUrl('GET', uri);

      final credentials = base64Encode(utf8.encode('$username:$password'));
      request.headers.set('Authorization', 'Basic $credentials');

      final response =
          await request.close().timeout(const Duration(seconds: 60));

      // 上限保护：先看 Content-Length（若服务器提供）。
      if (response.contentLength > _maxDownloadBytes) {
        throw const DatabaseException('Backup file too large (>50MB)');
      }

      if (response.statusCode != 200) {
        return null;
      }

      // 即使 contentLength == -1（chunked / 未知长度），也在流式读取时按上限截断，
      // 避免异常超大响应耗尽内存。
      final builder = BytesBuilder(copy: false);
      await for (final chunk in response) {
        builder.add(chunk);
        if (builder.length > _maxDownloadBytes) {
          throw const DatabaseException('Backup file too large (>50MB)');
        }
      }

      final responseBody = utf8.decode(builder.takeBytes());
      final decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return decoded;
    } on Exception catch (e) {
      AppLogger.e('BackupService', 'WebDAV download error', e);
      return null;
    } finally {
      client?.close();
    }
  }
}
