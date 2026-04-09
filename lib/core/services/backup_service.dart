import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import '../database/database_provider.dart';
import 'error_service.dart';

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
  final DatabaseProvider _dbProvider;

  BackupService(this._dbProvider);

  Future<String> exportToJson() async {
    final db = await _dbProvider.database;
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/lurebox_backup_$timestamp.json';

    final fishCatches = await db.query('fish_catches');
    final equipments = await db.query('equipments');
    final speciesHistory = await db.query('species_history');
    final settings = await db.query('settings');

    final backupData = {
      'version': 1,
      'exportTime': DateTime.now().toIso8601String(),
      'fishCatches': fishCatches,
      'equipments': equipments,
      'speciesHistory': speciesHistory,
      'settings': settings,
    };

    final jsonString = const JsonEncoder.withIndent(' ').convert(backupData);
    final file = File(filePath);
    await file.writeAsString(jsonString);

    return filePath;
  }

  Future<int> importFromJson(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw DatabaseException('File not found');
    }

    final jsonString = await file.readAsString();
    final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

    final db = await _dbProvider.database;
    int importedCount = 0;

    await db.transaction((txn) async {
      if (backupData.containsKey('fishCatches')) {
        final fishCatches = backupData['fishCatches'] as List;
        for (final fish in fishCatches) {
          await txn.insert('fish_catches', Map<String, dynamic>.from(fish));
          importedCount++;
        }
      }

      if (backupData.containsKey('equipments')) {
        final equipments = backupData['equipments'] as List;
        for (final equipment in equipments) {
          await txn.insert('equipments', Map<String, dynamic>.from(equipment));
        }
      }

      if (backupData.containsKey('speciesHistory')) {
        final speciesHistory = backupData['speciesHistory'] as List;
        for (final species in speciesHistory) {
          await txn.insert(
            'species_history',
            Map<String, dynamic>.from(species),
          );
        }
      }

      if (backupData.containsKey('settings')) {
        final settings = backupData['settings'] as List;
        for (final setting in settings) {
          final map = Map<String, dynamic>.from(setting);
          await txn.insert(
            'settings',
            map,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });

    return importedCount;
  }

  Future<String> uploadToWebDAV({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    HttpClient? client;
    try {
      final db = await _dbProvider.database;
      final fishCatches = await db.query('fish_catches');
      final equipments = await db.query('equipments');
      final speciesHistory = await db.query('species_history');
      final settings = await db.query('settings');

      final backupData = {
        'version': 1,
        'exportTime': DateTime.now().toIso8601String(),
        'fishCatches': fishCatches,
        'equipments': equipments,
        'speciesHistory': speciesHistory,
        'settings': settings,
      };

      final jsonString = const JsonEncoder.withIndent(' ').convert(backupData);
      final bytes = utf8.encode(jsonString);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'lurebox_backup_$timestamp.json';
      final baseUrl = serverUrl.endsWith('/')
          ? serverUrl.substring(0, serverUrl.length - 1)
          : serverUrl;
      final url = '$baseUrl/$fileName';

      final uri = Uri.parse(url);
      if (uri.host.isEmpty) {
        throw DatabaseException('Invalid server URL: missing host');
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
    } catch (e) {
      debugPrint('WebDAV upload error: $e');
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

      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);
      final request = await client.openUrl('PROPFIND', uri);

      final credentials = base64Encode(utf8.encode('$username:$password'));
      request.headers.set('Authorization', 'Basic $credentials');
      request.headers.set('Depth', '0');

      final response = await request.close();

      return response.statusCode == 207 || response.statusCode == 200;
    } catch (e) {
      debugPrint('WebDAV test connection error: $e');
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
      final baseUrl = serverUrl.endsWith('/')
          ? serverUrl.substring(0, serverUrl.length - 1)
          : serverUrl;
      final url = '$baseUrl/$fileName';

      final uri = Uri.parse(url);
      if (uri.host.isEmpty) return null;

      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 30);
      final request = await client.openUrl('GET', uri);

      final credentials = base64Encode(utf8.encode('$username:$password'));
      request.headers.set('Authorization', 'Basic $credentials');

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        return jsonDecode(responseBody) as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      debugPrint('WebDAV download error: $e');
      return null;
    } finally {
      client?.close();
    }
  }
}
