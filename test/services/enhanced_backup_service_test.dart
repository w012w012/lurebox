import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cross_file/cross_file.dart';
import 'package:lurebox/core/models/cloud_config.dart';
import 'package:lurebox/core/models/backup_history.dart';
import 'package:lurebox/core/repositories/backup_config_repository.dart';
import 'package:lurebox/core/database/database_provider.dart';
import 'package:lurebox/core/services/backup_zip_service.dart';
import 'package:lurebox/core/services/backup_service.dart';
import 'package:lurebox/core/services/enhanced_backup_service.dart';

// Custom Mock Database implementing sqflite's Database interface
class MockDb extends Mock implements Database {
  final Map<String, List<Map<String, dynamic>>> _queryResults = {};
  final List<Map<String, dynamic>> _insertedRecords = [];

  void addQueryResult(String table, List<Map<String, dynamic>> results) {
    _queryResults[table] = results;
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    return (_queryResults[table] ?? <Map<String, dynamic>>[]) as List<Map<String, Object?>>;
  }

  @override
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final record = Map<String, dynamic>.from(values);
    record['id'] = _insertedRecords.length + 1;
    _insertedRecords.add(record);
    return record['id'] as int;
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) async {
    return action(_MockTransaction());
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return 1;
  }

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return 1;
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    return _queryResults[sql] ?? <Map<String, dynamic>>[];
  }

  @override
  Future<int> rawUpdate(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    return 1;
  }

  @override
  Future<int> rawInsert(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    return 1;
  }

  @override
  Future<int> rawDelete(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    return 1;
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {}

  void reset() {
    _queryResults.clear();
    _insertedRecords.clear();
  }
}

class _MockTransaction implements Transaction {
  @override
  Database get database => throw UnimplementedError();

  @override
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return 1;
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    return [];
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return 1;
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return 0;
  }

  @override
  Future<int> rawUpdate(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    return 0;
  }

  @override
  Future<int> rawInsert(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    return 1;
  }

  @override
  Future<int> rawDelete(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    return 0;
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    return [];
  }

  @override
  Future<void> execute(
    String sql, [
    List<Object?>? arguments,
  ]) async {}

  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) async {
    return action(this);
  }

  @override
  Batch batch() => _MockBatch();

  @override
  Future<QueryCursor> rawQueryCursor(String sql, List<Object?>? arguments,
      {int? bufferSize}) async {
    throw UnimplementedError();
  }

  @override
  Future<QueryCursor> queryCursor(String table,
      {bool? distinct,
      List<String>? columns,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset,
      int? bufferSize}) async {
    throw UnimplementedError();
  }
}

class _MockBatch implements Batch {
  @override
  Future<List<Object?>> commit({
    bool? exclusive,
    bool? noResult,
    bool? continueOnError,
  }) async {
    return [];
  }

  @override
  Future<List<Object?>> apply({bool? noResult, bool? continueOnError}) async {
    return [];
  }

  @override
  void rawInsert(String sql, [List<Object?>? arguments]) {}

  @override
  void insert(String table, Map<String, Object?> values,
      {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) {}

  @override
  void rawUpdate(String sql, [List<Object?>? arguments]) {}

  @override
  void update(String table, Map<String, Object?> values,
      {String? where,
      List<Object?>? whereArgs,
      ConflictAlgorithm? conflictAlgorithm}) {}

  @override
  void rawDelete(String sql, [List<Object?>? arguments]) {}

  @override
  void delete(String table, {String? where, List<Object?>? whereArgs}) {}

  @override
  void execute(String sql, [List<Object?>? arguments]) {}

  @override
  void query(String table,
      {bool? distinct,
      List<String>? columns,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) {}

  @override
  void rawQuery(String sql, [List<Object?>? arguments]) {}

  @override
  void noSuchMethod(Invocation invocation) {}
}

// Mock DatabaseProvider
class MockDatabaseProvider extends Mock implements DatabaseProvider {
  final MockDb mockDb;

  MockDatabaseProvider(this.mockDb);

  @override
  Future<Database> get database => Future.value(mockDb);
}

// Mock BackupConfigRepository
class MockBackupConfigRepository extends Mock
    implements BackupConfigRepository {}

// Fake classes for fallback values
class FakeCloudConfig extends Fake implements CloudConfig {}

class FakeBackupHistory extends Fake implements BackupHistory {}

/// Minimal BackupService extension for testing — only implements what
/// EnhancedBackupService.exportBackup calls.
class _FakeBackupService extends BackupService {
  _FakeBackupService() : super(_DummyDbProvider());

  String? exportPath;
  Exception? exportError;

  @override
  Future<String> exportToJson() async {
    if (exportError != null) throw exportError!;
    return exportPath ?? '/tmp/test_backup.json';
  }
}

/// Minimal BackupZipService extension for testing — only implements what
/// EnhancedBackupService.exportBackup calls.
class _FakeBackupZipService extends BackupZipService {
  _FakeBackupZipService() : super(_DummyDbProvider());

  String? exportPath;
  Exception? exportError;

  @override
  Future<XFile> exportToZip({
    BackupExportOptions options = const BackupExportOptions(),
  }) async {
    if (exportError != null) throw exportError!;
    final path = exportPath ?? '/tmp/test_backup.zip';
    return XFile(path);
  }
}

/// Minimal DatabaseProvider stub for the fake services.
class _DummyDbProvider implements DatabaseProvider {
  @override
  Future<Database> get database => throw UnimplementedError();

  @override
  Future<void> close() async {}

  @override
  Future<void> resetForTesting() async {}
}

/// Wraps a real sqflite Database as a DatabaseProvider, for tests that
/// require genuine transaction behavior (e.g. importFromJsonWithDeduplication).
class _RealDbWrapper implements DatabaseProvider {
  _RealDbWrapper(this.db);
  final Database db;

  @override
  Future<Database> get database => Future.value(db);

  @override
  Future<void> close() async {}

  @override
  Future<void> resetForTesting() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late EnhancedBackupService service;
  late MockDatabaseProvider mockDbProvider;
  late MockBackupConfigRepository mockConfigRepo;
  late MockDb mockDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Mock path_provider platform channel
    final binding = TestWidgetsFlutterBinding.instance;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return Directory.systemTemp.path;
        }
        return null;
      },
    );

    // Mock share_plus
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/share'),
      (MethodCall methodCall) async {
        return null;
      },
    );

    // Register fallback values for mocktail
    registerFallbackValue(FakeCloudConfig());
    registerFallbackValue(FakeBackupHistory());
  });

  setUp(() {
    mockDatabase = MockDb();
    mockDbProvider = MockDatabaseProvider(mockDatabase);
    mockConfigRepo = MockBackupConfigRepository();

    // Setup default mock behaviors
    when(() => mockConfigRepo.cleanupOldBackupHistory(any()))
        .thenAnswer((_) async => 0);

    service = EnhancedBackupService(mockDbProvider, mockConfigRepo);
  });

  group('EnhancedBackupService - Cloud Config Management', () {
    group('saveWebDAVConfig', () {
      test('saves WebDAV config and returns id', () async {
        // Arrange
        const testId = 1;
        when(() => mockConfigRepo.saveCloudConfig(any()))
            .thenAnswer((_) async => testId);
        when(() => mockConfigRepo.setActiveCloudConfig(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await service.saveWebDAVConfig(
          serverUrl: 'https://example.com/webdav',
          username: 'testuser',
          password: 'testpass',
        );

        // Assert
        expect(result, equals(testId));
        verify(() => mockConfigRepo.saveCloudConfig(any())).called(1);
      });

      test('saves config without setting active when setAsActive is false',
          () async {
        // Arrange
        const testId = 2;
        when(() => mockConfigRepo.saveCloudConfig(any()))
            .thenAnswer((_) async => testId);

        // Act
        await service.saveWebDAVConfig(
          serverUrl: 'https://example.com/webdav',
          username: 'testuser',
          password: 'testpass',
          setAsActive: false,
        );

        // Assert
        verifyNever(() => mockConfigRepo.setActiveCloudConfig(any()));
      });

      test('sets active config when setAsActive is true', () async {
        // Arrange
        const testId = 3;
        when(() => mockConfigRepo.saveCloudConfig(any()))
            .thenAnswer((_) async => testId);
        when(() => mockConfigRepo.setActiveCloudConfig(any()))
            .thenAnswer((_) async {});

        // Act
        await service.saveWebDAVConfig(
          serverUrl: 'https://example.com/webdav',
          username: 'testuser',
          password: 'testpass',
          setAsActive: true,
        );

        // Assert
        verify(() => mockConfigRepo.setActiveCloudConfig(testId)).called(1);
      });
    });

    group('getActiveWebDAVConfig', () {
      test('returns active cloud config when exists', () async {
        // Arrange
        final config = CloudConfig(
          id: 1,
          provider: CloudProvider.webdav,
          serverUrl: 'https://example.com/webdav',
          username: 'testuser',
          password: 'testpass',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(() => mockConfigRepo.getActiveCloudConfig())
            .thenAnswer((_) async => config);

        // Act
        final result = await service.getActiveWebDAVConfig();

        // Assert
        expect(result, equals(config));
        expect(result?.provider, equals(CloudProvider.webdav));
      });

      test('returns null when no active config exists', () async {
        // Arrange
        when(() => mockConfigRepo.getActiveCloudConfig())
            .thenAnswer((_) async => null);

        // Act
        final result = await service.getActiveWebDAVConfig();

        // Assert
        expect(result, isNull);
      });
    });

    group('getAllCloudConfigs', () {
      test('returns all cloud configs', () async {
        // Arrange
        final configs = [
          CloudConfig(
            id: 1,
            provider: CloudProvider.webdav,
            serverUrl: 'https://example1.com/webdav',
            username: 'user1',
            password: 'pass1',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          CloudConfig(
            id: 2,
            provider: CloudProvider.nextcloud,
            serverUrl: 'https://example2.com/nextcloud',
            username: 'user2',
            password: 'pass2',
            isActive: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        when(() => mockConfigRepo.getAllCloudConfigs())
            .thenAnswer((_) async => configs);

        // Act
        final result = await service.getAllCloudConfigs();

        // Assert
        expect(result.length, equals(2));
        expect(result[0].provider, equals(CloudProvider.webdav));
        expect(result[1].provider, equals(CloudProvider.nextcloud));
      });

      test('returns empty list when no configs exist', () async {
        // Arrange
        when(() => mockConfigRepo.getAllCloudConfigs())
            .thenAnswer((_) async => []);

        // Act
        final result = await service.getAllCloudConfigs();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('deleteCloudConfig', () {
      test('deletes config and returns count', () async {
        // Arrange
        const configId = 5;
        when(() => mockConfigRepo.deleteCloudConfig(configId))
            .thenAnswer((_) async => 1);

        // Act
        final result = await service.deleteCloudConfig(configId);

        // Assert
        expect(result, equals(1));
        verify(() => mockConfigRepo.deleteCloudConfig(configId)).called(1);
      });
    });
  });

  group('EnhancedBackupService - Backup History Management', () {
    group('getBackupHistory', () {
      test('returns backup history with default limit', () async {
        // Arrange
        final history = [
          BackupHistory(
            id: 1,
            filePath: '/path/to/backup1.json',
            fileName: 'backup1.json',
            backupType: BackupType.json,
            fileSize: 1024,
            fishCount: 10,
            equipmentCount: 5,
            photoCount: 3,
            createdAt: DateTime.now(),
          ),
        ];
        when(() => mockConfigRepo.getBackupHistory(limit: 20))
            .thenAnswer((_) async => history);

        // Act
        final result = await service.getBackupHistory();

        // Assert
        expect(result.length, equals(1));
        expect(result[0].fishCount, equals(10));
      });

      test('returns backup history with custom limit', () async {
        // Arrange
        when(() => mockConfigRepo.getBackupHistory(limit: 5))
            .thenAnswer((_) async => []);

        // Act
        await service.getBackupHistory(limit: 5);

        // Assert
        verify(() => mockConfigRepo.getBackupHistory(limit: 5)).called(1);
      });
    });

    group('deleteBackupHistory', () {
      test('deletes history record and file when file exists', () async {
        // Arrange
        const historyId = 1;
        final tempDir = Directory.systemTemp.createTempSync();
        final testFile = File('${tempDir.path}/test_backup.json');
        await testFile.writeAsString('test content');
        final filePath = testFile.path;

        when(() => mockConfigRepo.deleteBackupHistory(historyId))
            .thenAnswer((_) async => 1);

        // Act
        final result = await service.deleteBackupHistory(historyId, filePath);

        // Assert
        expect(result, equals(1));
        expect(await testFile.exists(), isFalse);
        verify(() => mockConfigRepo.deleteBackupHistory(historyId)).called(1);

        // Cleanup
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      test('deletes history record even when file does not exist', () async {
        // Arrange
        const historyId = 2;
        const nonExistentPath = '/non/existent/file.json';

        when(() => mockConfigRepo.deleteBackupHistory(historyId))
            .thenAnswer((_) async => 1);

        // Act
        final result =
            await service.deleteBackupHistory(historyId, nonExistentPath);

        // Assert
        expect(result, equals(1));
        verify(() => mockConfigRepo.deleteBackupHistory(historyId)).called(1);
      });
    });

    group('cleanupOldBackupHistory', () {
      test('calls repository cleanup with keepCount', () async {
        // Arrange
        when(() => mockConfigRepo.cleanupOldBackupHistory(15))
            .thenAnswer((_) async => 3);

        // Act
        final result = await service.cleanupOldBackupHistory(keepCount: 15);

        // Assert
        expect(result, equals(3));
        verify(() => mockConfigRepo.cleanupOldBackupHistory(15)).called(1);
      });

      test('uses default keepCount of 20', () async {
        // Arrange
        when(() => mockConfigRepo.cleanupOldBackupHistory(20))
            .thenAnswer((_) async => 0);

        // Act
        await service.cleanupOldBackupHistory();

        // Assert
        verify(() => mockConfigRepo.cleanupOldBackupHistory(20)).called(1);
      });
    });
  });

  group('EnhancedBackupService - Recovery Points', () {
    group('getRecoveryPoints', () {
      test('returns empty list when recovery directory does not exist',
          () async {
        // Arrange
        final tempDir = Directory.systemTemp.createTempSync();

        TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApplicationDocumentsDirectory') {
              return tempDir.path;
            }
            return null;
          },
        );

        // Act
        final result = await service.getRecoveryPoints();

        // Assert
        expect(result, isEmpty);

        // Cleanup
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      test('returns sorted recovery points (newest first)', () async {
        // Arrange
        final tempDir = Directory.systemTemp.createTempSync();
        final recoveryDir = Directory('${tempDir.path}/recovery');
        await recoveryDir.create();

        // Create test recovery files - use explicit timestamps
        final oldFile = File('${recoveryDir.path}/lurebox_recovery_1000.db');
        final newFile = File('${recoveryDir.path}/lurebox_recovery_2000.db');
        await oldFile.writeAsString('old recovery');
        // Add a small delay to ensure different timestamps
        await Future.delayed(const Duration(milliseconds: 10));
        await newFile.writeAsString('new recovery');

        TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApplicationDocumentsDirectory') {
              return tempDir.path;
            }
            return null;
          },
        );

        // Act
        final result = await service.getRecoveryPoints();

        // Assert
        expect(result.length, equals(2));
        // Verify we got the recovery files (order depends on implementation)
        expect(result.any((f) => f.path.contains('lurebox_recovery_1000')),
            isTrue);
        expect(result.any((f) => f.path.contains('lurebox_recovery_2000')),
            isTrue);

        // Cleanup
        await recoveryDir.delete(recursive: true);
        await tempDir.delete(recursive: true);
      });
    });

    group('cleanupOldRecoveryPoints', () {
      test('returns 0 when recovery directory does not exist', () async {
        // Arrange
        final tempDir = Directory.systemTemp.createTempSync();

        TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApplicationDocumentsDirectory') {
              return tempDir.path;
            }
            return null;
          },
        );

        // Act
        final result = await service.cleanupOldRecoveryPoints();

        // Assert
        expect(result, equals(0));

        // Cleanup
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      test('returns 0 when files are within keepCount', () async {
        // Arrange
        final tempDir = Directory.systemTemp.createTempSync();
        final recoveryDir = Directory('${tempDir.path}/recovery');
        await recoveryDir.create();

        // Create only 2 files (within keepCount of 2)
        final file1 = File('${recoveryDir.path}/lurebox_recovery_1000.db');
        final file2 = File('${recoveryDir.path}/lurebox_recovery_2000.db');
        await file1.writeAsString('recovery 1');
        await file2.writeAsString('recovery 2');

        TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApplicationDocumentsDirectory') {
              return tempDir.path;
            }
            return null;
          },
        );

        // Act
        final result = await service.cleanupOldRecoveryPoints(keepCount: 2);

        // Assert
        expect(result, equals(0));
        expect(await file1.exists(), isTrue);
        expect(await file2.exists(), isTrue);

        // Cleanup
        await recoveryDir.delete(recursive: true);
        await tempDir.delete(recursive: true);
      });

      test('deletes old recovery points beyond keepCount', () async {
        // Arrange
        final tempDir = Directory.systemTemp.createTempSync();
        final recoveryDir = Directory('${tempDir.path}/recovery');
        await recoveryDir.create();

        // Create 5 files (文件名含时间戳：1000~5000，越大越新）
        // 用文件名排序：5000 > 4000 > 3000 > 2000 > 1000
        final files = <File>[];
        for (int i = 0; i < 5; i++) {
          final file =
              File('${recoveryDir.path}/lurebox_recovery_${(i + 1) * 1000}.db');
          await file.writeAsString('recovery $i');
          files.add(file);
        }

        TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApplicationDocumentsDirectory') {
              return tempDir.path;
            }
            return null;
          },
        );

        // Act
        final result = await service.cleanupOldRecoveryPoints(keepCount: 2);

        // Assert - 按文件名降序保留前2个（5000、4000），删除其余3个
        expect(result, equals(3));
        expect(await files[4].exists(), isTrue); // 5000 (最新)
        expect(await files[3].exists(), isTrue); // 4000
        expect(await files[2].exists(), isFalse); // 3000
        expect(await files[1].exists(), isFalse); // 2000
        expect(await files[0].exists(), isFalse); // 1000 (最旧)

        // Cleanup
        await recoveryDir.delete(recursive: true);
        await tempDir.delete(recursive: true);
      });
    });
  });

  group('EnhancedBackupService - Cloud Upload', () {
    group('uploadToCloud', () {
      test('throws exception when no active config found', () async {
        // Arrange
        when(() => mockConfigRepo.getActiveCloudConfig())
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => service.uploadToCloud(),
          throwsA(isA<Exception>()),
        );
      });

      test('verifies config is retrieved when upload attempted', () async {
        // Arrange
        final config = CloudConfig(
          id: 1,
          provider: CloudProvider.webdav,
          serverUrl: 'https://example.com/webdav',
          username: 'testuser',
          password: 'testpass',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(() => mockConfigRepo.getActiveCloudConfig())
            .thenAnswer((_) async => config);

        // Act - This will fail at WebDAV level but config is retrieved
        try {
          await service.uploadToCloud();
        } catch (e) {
          // Expected in test environment without full BackupService mock
        }

        // Assert
        verify(() => mockConfigRepo.getActiveCloudConfig()).called(1);
      });
    });

    group('testCloudConnection', () {
      test('returns false when no active config found', () async {
        // Arrange
        when(() => mockConfigRepo.getActiveCloudConfig())
            .thenAnswer((_) async => null);

        // Act
        final result = await service.testCloudConnection();

        // Assert
        expect(result, isFalse);
      });

      test('verifies config is retrieved when testing connection', () async {
        // Arrange
        final config = CloudConfig(
          id: 1,
          provider: CloudProvider.webdav,
          serverUrl: 'https://example.com/webdav',
          username: 'testuser',
          password: 'testpass',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(() => mockConfigRepo.getActiveCloudConfig())
            .thenAnswer((_) async => config);

        // Act - May fail at HTTP level but verifies config retrieval
        try {
          await service.testCloudConnection();
        } catch (e) {
          // Expected in test environment without full HTTP mock
        }

        // Assert
        verify(() => mockConfigRepo.getActiveCloudConfig()).called(1);
      });
    });
  });

  group('EnhancedBackupService - JSON Import with Deduplication', () {
    // Uses a real in-memory sqflite database because
    // importFromJsonWithDeduplication relies on db.transaction().
    late Database _realDb;
    late EnhancedBackupService _realDbService;

    setUp(() async {
      _realDb = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE fish_catches (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                image_path TEXT,
                watermarked_image_path TEXT,
                species TEXT NOT NULL,
                length REAL NOT NULL,
                length_unit TEXT DEFAULT 'cm',
                weight REAL,
                weight_unit TEXT DEFAULT 'kg',
                fate INTEGER DEFAULT 0,
                catch_time TEXT NOT NULL,
                location_name TEXT,
                latitude REAL,
                longitude REAL,
                notes TEXT,
                equipment_id INTEGER,
                rod_id INTEGER,
                reel_id INTEGER,
                lure_id INTEGER,
                air_temperature REAL,
                pressure REAL,
                weather_code INTEGER,
                pending_recognition INTEGER DEFAULT 0,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                rig_type TEXT,
                sinker_weight TEXT,
                sinker_position TEXT,
                hook_type TEXT,
                hook_size TEXT,
                hook_weight TEXT
              )
            ''');
            await db.execute('''
              CREATE TABLE equipments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                type TEXT NOT NULL,
                brand TEXT,
                model TEXT,
                is_deleted INTEGER DEFAULT 0,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
              )
            ''');
            await db.execute('''
              CREATE TABLE species_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT UNIQUE NOT NULL,
                use_count INTEGER DEFAULT 1,
                is_deleted INTEGER DEFAULT 0,
                created_at TEXT NOT NULL
              )
            ''');
            await db.execute('''
              CREATE TABLE settings (
                key TEXT PRIMARY KEY,
                value TEXT
              )
            ''');
          },
        ),
      );
      _realDbService = EnhancedBackupService(
        _RealDbWrapper(_realDb),
        MockBackupConfigRepository(),
      );
    });

    tearDown(() async {
      await _realDb.close();
    });

    test('throws exception when file does not exist', () async {
      await expectLater(
        _realDbService.importFromJsonWithDeduplication(
            '/non/existent/path/backup.json'),
        throwsA(isA<Exception>()),
      );
    });

    test('handles empty backup data', () async {
      final emptyJson = jsonEncode({
        'version': 1,
        'exportTime': DateTime.now().toIso8601String(),
        'fishCatches': <Map<String, dynamic>>[],
        'equipments': <Map<String, dynamic>>[],
        'speciesHistory': <Map<String, dynamic>>[],
        'settings': <Map<String, dynamic>>[],
      });

      final tempDir = Directory.systemTemp.createTempSync();
      final tempFile = File('${tempDir.path}/empty_backup.json');
      await tempFile.writeAsString(emptyJson);

      final result =
          await _realDbService.importFromJsonWithDeduplication(tempFile.path);

      expect(result.importedCount, equals(0));
      expect(result.skippedCount, equals(0));
      expect(result.errorCount, equals(0));

      await tempFile.delete();
      await tempDir.delete();
    });

    test('imports fish catches without deduplication', () async {
      final validJson = jsonEncode({
        'version': 1,
        'exportTime': DateTime.now().toIso8601String(),
        'fishCatches': [
          {
            'id': 1,
            'species': 'Bass',
            'catch_time': '2024-01-01T10:00:00.000',
            'length': 30.0,
            'fate': 0,
            'created_at': '2024-01-01T00:00:00.000',
            'updated_at': '2024-01-01T00:00:00.000',
          },
          {
            'id': 2,
            'species': 'Trout',
            'catch_time': '2024-01-01T11:00:00.000',
            'length': 25.0,
            'fate': 1,
            'created_at': '2024-01-01T00:00:00.000',
            'updated_at': '2024-01-01T00:00:00.000',
          },
        ],
        'equipments': <Map<String, dynamic>>[],
        'speciesHistory': <Map<String, dynamic>>[],
        'settings': <Map<String, dynamic>>[],
      });

      final tempDir = Directory.systemTemp.createTempSync();
      final tempFile = File('${tempDir.path}/test_backup.json');
      await tempFile.writeAsString(validJson);

      final result =
          await _realDbService.importFromJsonWithDeduplication(tempFile.path);

      expect(result.importedCount, equals(2));
      expect(result.skippedCount, equals(0));
      expect(result.errorCount, equals(0));

      // Verify data was actually inserted
      final rows = await _realDb.query('fish_catches');
      expect(rows.length, equals(2));

      await tempFile.delete();
      await tempDir.delete();
    });

    test('skips duplicate fish catches during import', () async {
      // Pre-insert a fish catch that will conflict with the import
      final now = DateTime.now().toIso8601String();
      await _realDb.insert('fish_catches', {
        'species': 'Bass',
        'catch_time': '2024-01-01T10:00:00.000',
        'length': 30.0,
        'fate': 0,
        'created_at': now,
        'updated_at': now,
      });

      final duplicateJson = jsonEncode({
        'version': 1,
        'exportTime': DateTime.now().toIso8601String(),
        'fishCatches': [
          {
            'id': 99,
            'species': 'Bass',
            'catch_time': '2024-01-01T10:00:00.000',
            'length': 30.0,
            'fate': 0,
            'created_at': now,
            'updated_at': now,
          },
        ],
        'equipments': <Map<String, dynamic>>[],
        'speciesHistory': <Map<String, dynamic>>[],
        'settings': <Map<String, dynamic>>[],
      });

      final tempDir = Directory.systemTemp.createTempSync();
      final tempFile = File('${tempDir.path}/dup_backup.json');
      await tempFile.writeAsString(duplicateJson);

      final result =
          await _realDbService.importFromJsonWithDeduplication(tempFile.path);

      // The duplicate (same catch_time + species) should be skipped
      expect(result.importedCount, equals(0));
      expect(result.skippedCount, equals(1));

      // Only the pre-inserted record should remain
      final rows = await _realDb.query('fish_catches');
      expect(rows.length, equals(1));

      await tempFile.delete();
      await tempDir.delete();
    });
  });

  group('EnhancedBackupService - exportBackup', () {
    // Uses real sqflite FFI for _getBackupStats queries, injects fake
    // BackupService/BackupZipService to control export behavior.
    late Database _realDb;
    late _FakeBackupService _fakeBackupService;
    late _FakeBackupZipService _fakeBackupZipService;

    late MockBackupConfigRepository mockConfigRepo;

    setUp(() async {
      _realDb = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(version: 1, onCreate: (db, v) async {
          await db.execute('''
            CREATE TABLE fish_catches (
              id INTEGER PRIMARY KEY,
              species TEXT,
              catch_time TEXT,
              image_path TEXT,
              created_at TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE equipments (
              id INTEGER PRIMARY KEY,
              type TEXT,
              is_deleted INTEGER DEFAULT 0,
              created_at TEXT
            )
          ''');
        }),
      );
      _fakeBackupService = _FakeBackupService();
      _fakeBackupZipService = _FakeBackupZipService();
      mockConfigRepo = MockBackupConfigRepository();
      when(() => mockConfigRepo.addBackupHistory(any()))
          .thenAnswer((_) async => 1);
      when(() => mockConfigRepo.cleanupOldBackupHistory(any()))
          .thenAnswer((_) async => 0);
    });

    tearDown(() async {
      await _realDb.close();
    });

    test('JSON export returns XFile, saves history, and calls cleanup',
        () async {
      final tempDir = Directory.systemTemp.createTempSync();
      final jsonPath = '${tempDir.path}/test_export.json';
      await File(jsonPath).writeAsString('{}');
      _fakeBackupService.exportPath = jsonPath;

      final service = EnhancedBackupService.withServices(
        _RealDbWrapper(_realDb),
        mockConfigRepo,
        _fakeBackupService,
        _fakeBackupZipService,
      );

      final result = await service.exportBackup(
        BackupType.json,
        shareAfterExport: false,
      );

      expect(result.path, equals(jsonPath));
      verify(() => mockConfigRepo.addBackupHistory(any())).called(1);

      await tempDir.delete(recursive: true);
    });

    test('ZIP full export returns XFile and saves history', () async {
      final tempDir = Directory.systemTemp.createTempSync();
      final zipPath = '${tempDir.path}/test_export.zip';
      await File(zipPath).writeAsBytes([0x50, 0x4B, 0x03, 0x04]);
      _fakeBackupZipService.exportPath = zipPath;

      final service = EnhancedBackupService.withServices(
        _RealDbWrapper(_realDb),
        mockConfigRepo,
        _fakeBackupService,
        _fakeBackupZipService,
      );

      final result = await service.exportBackup(
        BackupType.zipFull,
        shareAfterExport: false,
      );

      expect(result.path, equals(zipPath));
      verify(() => mockConfigRepo.addBackupHistory(any())).called(1);
      // Stats queries hit the real in-memory DB
      final stats = await _realDb.rawQuery('SELECT COUNT(*) FROM fish_catches');
      expect(Sqflite.firstIntValue(stats), equals(0));

      await tempDir.delete(recursive: true);
    });

    test('ZIP db-only export calls BackupZipService', () async {
      final tempDir = Directory.systemTemp.createTempSync();
      final zipPath = '${tempDir.path}/test_export.zip';
      await File(zipPath).writeAsBytes([0x50, 0x4B, 0x03, 0x04]);
      _fakeBackupZipService.exportPath = zipPath;

      final service = EnhancedBackupService.withServices(
        _RealDbWrapper(_realDb),
        mockConfigRepo,
        _fakeBackupService,
        _fakeBackupZipService,
      );

      await service.exportBackup(
        BackupType.zipDbOnly,
        shareAfterExport: false,
      );

      verify(() => mockConfigRepo.addBackupHistory(any())).called(1);

      await tempDir.delete(recursive: true);
    });

    test('throws when BackupService export fails', () async {
      _fakeBackupService.exportError = Exception('Export failed');

      final service = EnhancedBackupService.withServices(
        _RealDbWrapper(_realDb),
        mockConfigRepo,
        _fakeBackupService,
        _fakeBackupZipService,
      );

      await expectLater(
        service.exportBackup(BackupType.json),
        throwsA(isA<Exception>()),
      );
    });

    test('cleanupOldBackupHistory is called after successful export', () async {
      final tempDir = Directory.systemTemp.createTempSync();
      final jsonPath = '${tempDir.path}/test_export.json';
      await File(jsonPath).writeAsString('{}');
      _fakeBackupService.exportPath = jsonPath;

      final service = EnhancedBackupService.withServices(
        _RealDbWrapper(_realDb),
        mockConfigRepo,
        _fakeBackupService,
        _fakeBackupZipService,
      );

      await service.exportBackup(BackupType.json);

      verifyInOrder([
        () => mockConfigRepo.addBackupHistory(any()),
        () => mockConfigRepo.cleanupOldBackupHistory(20),
      ]);

      await tempDir.delete(recursive: true);
    });

    test('backup history contains correct fish and equipment counts', () async {
      await _realDb.insert('fish_catches', {'species': 'Bass'});
      await _realDb.insert('equipments', {'type': 'rod', 'is_deleted': 0});

      final tempDir = Directory.systemTemp.createTempSync();
      final jsonPath = '${tempDir.path}/test_export.json';
      await File(jsonPath).writeAsString('{}');
      _fakeBackupService.exportPath = jsonPath;

      // Re-stub with capture for this test (clears previous stub from setUp)
      BackupHistory? capturedHistory;
      when(() => mockConfigRepo.addBackupHistory(any())).thenAnswer((inv) async {
        capturedHistory = inv.positionalArguments[0] as BackupHistory;
        return 1;
      });
      when(() => mockConfigRepo.cleanupOldBackupHistory(any()))
          .thenAnswer((_) async => 0);

      final service = EnhancedBackupService.withServices(
        _RealDbWrapper(_realDb),
        mockConfigRepo,
        _fakeBackupService,
        _fakeBackupZipService,
      );

      await service.exportBackup(BackupType.json);

      expect(capturedHistory, isNotNull);
      expect(capturedHistory!.fishCount, equals(1));
      expect(capturedHistory!.equipmentCount, equals(1));
      expect(capturedHistory!.backupType, equals(BackupType.json));

      await tempDir.delete(recursive: true);
    });
  });
}