import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lurebox/core/models/cloud_config.dart';
import 'package:lurebox/core/models/backup_history.dart';
import 'package:lurebox/core/repositories/backup_config_repository.dart';
import 'package:lurebox/core/services/secure_storage_service.dart';

void main() {
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // 创建内存数据库用于测试
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
CREATE TABLE cloud_configs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  provider TEXT NOT NULL,
  server_url TEXT NOT NULL,
  username TEXT NOT NULL,
  password TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''');
          await db.execute('''
CREATE TABLE backup_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  file_path TEXT NOT NULL,
  file_name TEXT NOT NULL,
  backup_type TEXT NOT NULL,
  file_size INTEGER NOT NULL,
  fish_count INTEGER DEFAULT 0,
  equipment_count INTEGER DEFAULT 0,
  photo_count INTEGER DEFAULT 0,
  created_at TEXT NOT NULL
)
''');
        },
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('BackupConfigRepository - CloudConfig', () {
    late SqliteBackupConfigRepository repository;

    setUp(() {
      repository = SqliteBackupConfigRepository(
        Future<Database>.value(db),
        InMemoryCloudPasswordStorage(),
      );
    });

    test('saveCloudConfig inserts a new config and returns id', () async {
      final now = DateTime.now();
      final config = CloudConfig(
        provider: CloudProvider.webdav,
        serverUrl: 'https://example.com/webdav',
        username: 'user1',
        password: 'pass123',
        isActive: false,
        createdAt: now,
        updatedAt: now,
      );

      final id = await repository.saveCloudConfig(config);

      expect(id, greaterThan(0));
    });

    test('saveCloudConfig and getAllCloudConfigs returns saved config',
        () async {
      final now = DateTime.now();
      final config = CloudConfig(
        provider: CloudProvider.nextcloud,
        serverUrl: 'https://nextcloud.example.com',
        username: 'admin',
        password: 'secret',
        isActive: false,
        createdAt: now,
        updatedAt: now,
      );

      await repository.saveCloudConfig(config);

      final configs = await repository.getAllCloudConfigs();
      expect(configs.length, equals(1));
      expect(configs.first.provider, equals(CloudProvider.nextcloud));
      expect(configs.first.serverUrl, equals('https://nextcloud.example.com'));
      expect(configs.first.username, equals('admin'));
    });

    test('getAllCloudConfigs returns empty list when no configs exist',
        () async {
      final configs = await repository.getAllCloudConfigs();

      expect(configs, isEmpty);
    });

    test('getActiveCloudConfig returns null when no active config', () async {
      final now = DateTime.now();
      final config = CloudConfig(
        provider: CloudProvider.webdav,
        serverUrl: 'https://example.com',
        username: 'user',
        password: 'pass',
        isActive: false,
        createdAt: now,
        updatedAt: now,
      );

      await repository.saveCloudConfig(config);

      final result = await repository.getActiveCloudConfig();
      expect(result, isNull);
    });

    test(
        'setActiveCloudConfig makes config active and getActiveCloudConfig returns it',
        () async {
      final now = DateTime.now();
      final config1 = CloudConfig(
        provider: CloudProvider.webdav,
        serverUrl: 'https://server1.com',
        username: 'user1',
        password: 'pass1',
        isActive: false,
        createdAt: now,
        updatedAt: now,
      );
      final config2 = CloudConfig(
        provider: CloudProvider.nextcloud,
        serverUrl: 'https://server2.com',
        username: 'user2',
        password: 'pass2',
        isActive: false,
        createdAt: now,
        updatedAt: now,
      );

      final id1 = await repository.saveCloudConfig(config1);
      await repository.saveCloudConfig(config2);
      await repository.setActiveCloudConfig(id1);

      final activeConfig = await repository.getActiveCloudConfig();
      expect(activeConfig, isNotNull);
      expect(activeConfig!.id, equals(id1));
      expect(activeConfig.provider, equals(CloudProvider.webdav));
    });

    test('setActiveCloudConfig deactivates previous active config', () async {
      final now = DateTime.now();
      final config1 = CloudConfig(
        provider: CloudProvider.webdav,
        serverUrl: 'https://server1.com',
        username: 'user1',
        password: 'pass1',
        isActive: false,
        createdAt: now,
        updatedAt: now,
      );
      final config2 = CloudConfig(
        provider: CloudProvider.nextcloud,
        serverUrl: 'https://server2.com',
        username: 'user2',
        password: 'pass2',
        isActive: false,
        createdAt: now,
        updatedAt: now,
      );

      final id1 = await repository.saveCloudConfig(config1);
      final id2 = await repository.saveCloudConfig(config2);
      await repository.setActiveCloudConfig(id1);
      await repository.setActiveCloudConfig(id2);

      final activeConfig = await repository.getActiveCloudConfig();
      expect(activeConfig!.id, equals(id2));

      // Verify all configs - only id2 should be active
      final allConfigs = await repository.getAllCloudConfigs();
      final activeCount = allConfigs.where((c) => c.isActive).length;
      expect(activeCount, equals(1));
    });

    test('updateCloudConfig updates existing config', () async {
      final now = DateTime.now();
      final config = CloudConfig(
        provider: CloudProvider.webdav,
        serverUrl: 'https://old.com',
        username: 'olduser',
        password: 'oldpass',
        isActive: false,
        createdAt: now,
        updatedAt: now,
      );

      await repository.saveCloudConfig(config);
      final savedConfig = (await repository.getAllCloudConfigs()).first;

      final updatedConfig = savedConfig.copyWith(
        serverUrl: 'https://new.com',
        username: 'newuser',
      );

      await repository.updateCloudConfig(updatedConfig);

      final allConfigs = await repository.getAllCloudConfigs();
      expect(allConfigs.first.serverUrl, equals('https://new.com'));
      expect(allConfigs.first.username, equals('newuser'));
    });

    test('updateCloudConfig throws on config without id', () async {
      final now = DateTime.now();
      final config = CloudConfig(
        provider: CloudProvider.webdav,
        serverUrl: 'https://example.com',
        username: 'user',
        password: 'pass',
        isActive: false,
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => repository.updateCloudConfig(config),
        throwsArgumentError,
      );
    });

    test('deleteCloudConfig removes config', () async {
      final now = DateTime.now();
      final config = CloudConfig(
        provider: CloudProvider.webdav,
        serverUrl: 'https://example.com',
        username: 'user',
        password: 'pass',
        isActive: false,
        createdAt: now,
        updatedAt: now,
      );

      final id = await repository.saveCloudConfig(config);
      await repository.deleteCloudConfig(id);

      final configs = await repository.getAllCloudConfigs();
      expect(configs, isEmpty);
    });

    test('password is stored in secure storage, not in DB', () async {
      final passwordStorage = InMemoryCloudPasswordStorage();
      final repo = SqliteBackupConfigRepository(
        Future<Database>.value(db),
        passwordStorage,
      );

      final now = DateTime.now();
      final config = CloudConfig(
        provider: CloudProvider.webdav,
        serverUrl: 'https://example.com',
        username: 'user',
        password: 'super_secret',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final id = await repo.saveCloudConfig(config);

      // Password should be in secure storage
      expect(await passwordStorage.get(id), equals('super_secret'));

      // DB row should have empty password
      final dbRow = (await db.query(
        'cloud_configs',
        where: 'id = ?',
        whereArgs: [id],
      )).first;
      expect(dbRow['password'], equals(''));
    });

    test('getAllCloudConfigs hydrates password from secure storage', () async {
      final now = DateTime.now();
      final config = CloudConfig(
        provider: CloudProvider.webdav,
        serverUrl: 'https://example.com',
        username: 'user',
        password: 'hydrated_pass',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await repository.saveCloudConfig(config);

      final configs = await repository.getAllCloudConfigs();
      expect(configs.first.password, equals('hydrated_pass'));
    });

    test('getActiveCloudConfig hydrates password from secure storage', () async {
      final now = DateTime.now();
      final config = CloudConfig(
        provider: CloudProvider.webdav,
        serverUrl: 'https://example.com',
        username: 'user',
        password: 'active_pass',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final id = await repository.saveCloudConfig(config);
      await repository.setActiveCloudConfig(id);

      final active = await repository.getActiveCloudConfig();
      expect(active, isNotNull);
      expect(active!.password, equals('active_pass'));
    });

    test('deleteCloudConfig also removes password from secure storage', () async {
      final passwordStorage = InMemoryCloudPasswordStorage();
      final repo = SqliteBackupConfigRepository(
        Future<Database>.value(db),
        passwordStorage,
      );

      final now = DateTime.now();
      final config = CloudConfig(
        provider: CloudProvider.webdav,
        serverUrl: 'https://example.com',
        username: 'user',
        password: 'to_delete',
        isActive: false,
        createdAt: now,
        updatedAt: now,
      );

      final id = await repo.saveCloudConfig(config);
      expect(await passwordStorage.get(id), isNotNull);

      await repo.deleteCloudConfig(id);
      expect(await passwordStorage.get(id), isNull);
    });

    test('migrateExistingPasswords moves plaintext DB passwords to secure storage', () async {
      final passwordStorage = InMemoryCloudPasswordStorage();
      final repo = SqliteBackupConfigRepository(
        Future<Database>.value(db),
        passwordStorage,
      );

      // Insert a config with plaintext password directly into DB (simulating old schema)
      await db.insert('cloud_configs', {
        'provider': 'webdav',
        'server_url': 'https://old.example.com',
        'username': 'legacy_user',
        'password': 'legacy_password',
        'is_active': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      await repo.migrateExistingPasswords();

      // Password should now be in secure storage
      final stored = await passwordStorage.get(1);
      expect(stored, equals('legacy_password'));

      // DB password should be cleared
      final dbRow = (await db.query('cloud_configs', where: 'id = ?', whereArgs: [1])).first;
      expect(dbRow['password'], equals(''));
    });

    test('updateCloudConfig updates password in secure storage', () async {
      final now = DateTime.now();
      final config = CloudConfig(
        provider: CloudProvider.webdav,
        serverUrl: 'https://example.com',
        username: 'user',
        password: 'original_pass',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final id = await repository.saveCloudConfig(config);
      final saved = (await repository.getAllCloudConfigs()).first;

      final updated = saved.copyWith(password: 'new_pass');
      await repository.updateCloudConfig(updated);

      final configs = await repository.getAllCloudConfigs();
      expect(configs.first.password, equals('new_pass'));
    });
  });

  group('BackupConfigRepository - BackupHistory', () {
    late SqliteBackupConfigRepository repository;

    setUp(() {
      repository = SqliteBackupConfigRepository(
        Future<Database>.value(db),
        InMemoryCloudPasswordStorage(),
      );
    });

    test('addBackupHistory inserts a new history record', () async {
      final now = DateTime.now();
      final history = BackupHistory(
        filePath: '/backups/backup_20240101.zip',
        fileName: 'backup_20240101.zip',
        backupType: BackupType.zipFull,
        fileSize: 1024 * 1024,
        fishCount: 10,
        equipmentCount: 5,
        photoCount: 20,
        createdAt: now,
      );

      final id = await repository.addBackupHistory(history);

      expect(id, greaterThan(0));
    });

    test('addBackupHistory and getBackupHistory retrieves record', () async {
      final now = DateTime.now();
      final history = BackupHistory(
        filePath: '/backups/backup_20240102.zip',
        fileName: 'backup_20240102.zip',
        backupType: BackupType.zipDbOnly,
        fileSize: 512 * 1024,
        fishCount: 5,
        equipmentCount: 3,
        photoCount: 0,
        createdAt: now,
      );

      await repository.addBackupHistory(history);

      final histories = await repository.getBackupHistory();
      expect(histories.length, equals(1));
      expect(histories.first.fileName, equals('backup_20240102.zip'));
      expect(histories.first.backupType, equals(BackupType.zipDbOnly));
      expect(histories.first.fishCount, equals(5));
    });

    test('getBackupHistory returns empty list when no history', () async {
      final histories = await repository.getBackupHistory();

      expect(histories, isEmpty);
    });

    test('getBackupHistory returns records ordered by created_at DESC',
        () async {
      final baseTime = DateTime.now();

      await repository.addBackupHistory(BackupHistory(
        filePath: '/backups/backup1.zip',
        fileName: 'backup1.zip',
        backupType: BackupType.json,
        fileSize: 100,
        createdAt: baseTime,
      ));
      await repository.addBackupHistory(BackupHistory(
        filePath: '/backups/backup2.zip',
        fileName: 'backup2.zip',
        backupType: BackupType.zipFull,
        fileSize: 200,
        createdAt: baseTime.add(const Duration(milliseconds: 10)),
      ));
      await repository.addBackupHistory(BackupHistory(
        filePath: '/backups/backup3.zip',
        fileName: 'backup3.zip',
        backupType: BackupType.zipDbOnly,
        fileSize: 300,
        createdAt: baseTime.add(const Duration(milliseconds: 20)),
      ));

      final histories = await repository.getBackupHistory();

      expect(histories.length, equals(3));
      expect(histories.first.fileName, equals('backup3.zip'));
      expect(histories.last.fileName, equals('backup1.zip'));
    });

    test('getBackupHistory respects limit parameter', () async {
      final baseTime = DateTime.now();

      for (int i = 0; i < 5; i++) {
        await repository.addBackupHistory(BackupHistory(
          filePath: '/backups/backup$i.zip',
          fileName: 'backup$i.zip',
          backupType: BackupType.json,
          fileSize: 100 * i,
          createdAt: baseTime.add(Duration(milliseconds: i * 10)),
        ));
      }

      final histories = await repository.getBackupHistory(limit: 3);

      expect(histories.length, equals(3));
    });

    test('cleanupOldBackupHistory deletes records beyond keepCount', () async {
      final baseTime = DateTime.now();

      // Add 5 records
      for (int i = 0; i < 5; i++) {
        await repository.addBackupHistory(BackupHistory(
          filePath: '/backups/backup$i.zip',
          fileName: 'backup$i.zip',
          backupType: BackupType.json,
          fileSize: 100,
          createdAt: baseTime.add(Duration(milliseconds: i * 10)),
        ));
      }

      // Keep only 2
      final deleted = await repository.cleanupOldBackupHistory(2);

      expect(deleted, equals(3));

      final remaining = await repository.getBackupHistory();
      expect(remaining.length, equals(2));
    });

    test('cleanupOldBackupHistory returns 0 when nothing to delete', () async {
      final now = DateTime.now();

      await repository.addBackupHistory(BackupHistory(
        filePath: '/backups/backup1.zip',
        fileName: 'backup1.zip',
        backupType: BackupType.json,
        fileSize: 100,
        createdAt: now,
      ));

      final deleted = await repository.cleanupOldBackupHistory(10);

      expect(deleted, equals(0));

      final remaining = await repository.getBackupHistory();
      expect(remaining.length, equals(1));
    });

    test('deleteBackupHistory removes specific record', () async {
      final now = DateTime.now();

      await repository.addBackupHistory(BackupHistory(
        filePath: '/backups/backup1.zip',
        fileName: 'backup1.zip',
        backupType: BackupType.json,
        fileSize: 100,
        createdAt: now,
      ));
      await repository.addBackupHistory(BackupHistory(
        filePath: '/backups/backup2.zip',
        fileName: 'backup2.zip',
        backupType: BackupType.json,
        fileSize: 200,
        createdAt: now,
      ));

      final histories = await repository.getBackupHistory();
      final toDelete = histories.firstWhere((h) => h.fileName == 'backup1.zip');

      await repository.deleteBackupHistory(toDelete.id!);

      final remaining = await repository.getBackupHistory();
      expect(remaining.length, equals(1));
      expect(remaining.first.fileName, equals('backup2.zip'));
    });
  });

  group('CloudConfig model', () {
    test('fromMap creates correct instance', () {
      final map = {
        'id': 1,
        'provider': 'nextcloud',
        'server_url': 'https://cloud.example.com',
        'username': 'testuser',
        'password': 'testpass',
        'is_active': 1,
        'created_at': '2024-01-01T10:00:00.000',
        'updated_at': '2024-01-01T10:00:00.000',
      };

      final config = CloudConfig.fromMap(map);

      expect(config.id, equals(1));
      expect(config.provider, equals(CloudProvider.nextcloud));
      expect(config.serverUrl, equals('https://cloud.example.com'));
      expect(config.username, equals('testuser'));
      expect(config.isActive, isTrue);
    });

    test('toMap creates correct map', () {
      final config = CloudConfig(
        id: 1,
        provider: CloudProvider.webdav,
        serverUrl: 'https://webdav.example.com',
        username: 'admin',
        password: 'secret',
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final map = config.toMap();

      expect(map['id'], equals(1));
      expect(map['provider'], equals('webdav'));
      expect(map['server_url'], equals('https://webdav.example.com'));
      expect(map['is_active'], equals(1));
    });

    test('copyWith creates modified copy', () {
      final original = CloudConfig(
        id: 1,
        provider: CloudProvider.webdav,
        serverUrl: 'https://old.com',
        username: 'user',
        password: 'pass',
        isActive: false,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final copy = original.copyWith(
        serverUrl: 'https://new.com',
        isActive: true,
      );

      expect(copy.id, equals(1));
      expect(copy.serverUrl, equals('https://new.com'));
      expect(copy.isActive, isTrue);
      expect(copy.provider, equals(CloudProvider.webdav));
    });

    test('equality based on id, provider, serverUrl, username, isActive', () {
      final config1 = CloudConfig(
        id: 1,
        provider: CloudProvider.webdav,
        serverUrl: 'https://example.com',
        username: 'user',
        password: 'pass1',
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final config2 = CloudConfig(
        id: 1,
        provider: CloudProvider.webdav,
        serverUrl: 'https://example.com',
        username: 'user',
        password: 'different_password',
        isActive: true,
        createdAt: DateTime(2024, 2, 2),
        updatedAt: DateTime(2024, 2, 2),
      );

      expect(config1, equals(config2));
    });
  });

  group('BackupHistory model', () {
    test('fromMap creates correct instance', () {
      final map = {
        'id': 1,
        'file_path': '/backups/test.zip',
        'file_name': 'test.zip',
        'backup_type': 'zip_full',
        'file_size': 1024,
        'fish_count': 10,
        'equipment_count': 5,
        'photo_count': 20,
        'created_at': '2024-01-01T10:00:00.000',
      };

      final history = BackupHistory.fromMap(map);

      expect(history.id, equals(1));
      expect(history.filePath, equals('/backups/test.zip'));
      expect(history.backupType, equals(BackupType.zipFull));
      expect(history.fishCount, equals(10));
    });

    test('toMap creates correct map', () {
      final history = BackupHistory(
        id: 1,
        filePath: '/backups/backup.zip',
        fileName: 'backup.zip',
        backupType: BackupType.zipDbOnly,
        fileSize: 2048,
        fishCount: 15,
        equipmentCount: 8,
        photoCount: 30,
        createdAt: DateTime(2024, 1, 1),
      );

      final map = history.toMap();

      expect(map['id'], equals(1));
      expect(map['file_path'], equals('/backups/backup.zip'));
      expect(map['backup_type'], equals('zip_db'));
      expect(map['fish_count'], equals(15));
    });

    test('copyWith creates modified copy', () {
      final original = BackupHistory(
        id: 1,
        filePath: '/backups/old.zip',
        fileName: 'old.zip',
        backupType: BackupType.json,
        fileSize: 100,
        createdAt: DateTime(2024, 1, 1),
      );

      final copy = original.copyWith(
        fileName: 'new.zip',
        fileSize: 200,
      );

      expect(copy.fileName, equals('new.zip'));
      expect(copy.fileSize, equals(200));
      expect(copy.backupType, equals(BackupType.json));
    });

    test('formattedFileSize returns human readable size', () {
      final small = BackupHistory(
        filePath: '/a',
        fileName: 'a',
        backupType: BackupType.json,
        fileSize: 500,
        createdAt: DateTime.now(),
      );
      expect(small.formattedFileSize, equals('500 B'));

      final kb = BackupHistory(
        filePath: '/a',
        fileName: 'a',
        backupType: BackupType.json,
        fileSize: 2048,
        createdAt: DateTime.now(),
      );
      expect(kb.formattedFileSize, equals('2.0 KB'));

      final mb = BackupHistory(
        filePath: '/a',
        fileName: 'a',
        backupType: BackupType.json,
        fileSize: 5 * 1024 * 1024,
        createdAt: DateTime.now(),
      );
      expect(mb.formattedFileSize, equals('5.0 MB'));
    });

    test('typeLabel returns backup type display label', () {
      final history = BackupHistory(
        filePath: '/a',
        fileName: 'a',
        backupType: BackupType.zipFull,
        fileSize: 100,
        createdAt: DateTime.now(),
      );

      expect(history.typeLabel, equals('完整备份'));
    });
  });
}
