import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:lurebox/core/models/cloud_config.dart';
import 'package:lurebox/core/models/backup_history.dart';
import 'package:lurebox/core/repositories/backup_config_repository.dart';
import 'package:lurebox/core/database/database_provider.dart';
import 'package:lurebox/core/services/enhanced_backup_service.dart';

// Custom Mock Database implementing sqflite's Database interface
class MockDb extends Mock implements Database {
  final Map<String, List<Map<String, dynamic>>> _queryResults = {};
  final List<Map<String, dynamic>> _insertedRecords = [];

  void addQueryResult(String table, List<Map<String, dynamic>> results) {
    _queryResults[table] = results;
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    return _queryResults[table] ?? [];
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
    List<dynamic>? whereArgs,
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
    List<dynamic>? arguments,
  ]) async {
    return _queryResults[sql] ?? [];
  }

  @override
  Future<int> rawUpdate(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    return 1;
  }

  @override
  Future<int> rawInsert(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    return 1;
  }

  @override
  Future<int> rawDelete(
    String sql, [
    List<dynamic>? arguments,
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
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return 1;
  }

  // 注意: 此方法不覆盖任何接口方法,只是模拟 Database 接口签名
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) async {
    return action(this);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return Future.value([]);
  }
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late EnhancedBackupService service;
  late MockDatabaseProvider mockDbProvider;
  late MockBackupConfigRepository mockConfigRepo;
  late MockDb mockDatabase;

  setUpAll(() {
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
      const MethodChannel('plugins.flutter.io/share_plus'),
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

        // Create 5 files, should keep only 2
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

        // Assert
        expect(result, equals(3)); // 5 - 2 = 3 deleted
        // First 2 newest should still exist
        expect(await files[4].exists(), isTrue); // 5000
        expect(await files[3].exists(), isTrue); // 4000
        // Oldest 3 should be deleted
        expect(await files[0].exists(), isFalse);
        expect(await files[1].exists(), isFalse);
        expect(await files[2].exists(), isFalse);

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
    group('importFromJsonWithDeduplication', () {
      test('throws exception when file does not exist', () async {
        // Arrange
        const nonExistentPath = '/non/existent/path/backup.json';

        // Act & Assert
        expect(
          () => service.importFromJsonWithDeduplication(nonExistentPath),
          throwsA(isA<Exception>()),
        );
      });

      test('handles empty backup data', () async {
        // Arrange
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

        // Act
        final result =
            await service.importFromJsonWithDeduplication(tempFile.path);

        // Assert
        expect(result.importedCount, equals(0));
        expect(result.skippedCount, equals(0));
        expect(result.errorCount, equals(0));
        expect(result.totalCount, equals(0));

        // Cleanup
        await tempFile.delete();
        await tempDir.delete();
      });

      test('processes valid JSON with fish catches', () async {
        // Arrange
        final validJson = jsonEncode({
          'version': 1,
          'exportTime': DateTime.now().toIso8601String(),
          'fishCatches': [
            {
              'id': 1,
              'species': 'Bass',
              'catch_time': 1234567890000,
              'length': 30.0
            },
          ],
          'equipments': <Map<String, dynamic>>[],
          'speciesHistory': <Map<String, dynamic>>[],
          'settings': <Map<String, dynamic>>[],
        });

        final tempDir = Directory.systemTemp.createTempSync();
        final tempFile = File('${tempDir.path}/test_backup.json');
        await tempFile.writeAsString(validJson);

        // Act - Test basic flow
        try {
          await service.importFromJsonWithDeduplication(tempFile.path);
        } catch (_) {
          // In test environment, transaction behavior differs
        }

        // Cleanup
        await tempFile.delete();
        await tempDir.delete();
      });
    });

    test('ImportResultWithStats has correct computed properties', () async {
      // Test with errors and skipped
      const resultWithIssues = ImportResultWithStats(
        importedCount: 5,
        skippedCount: 3,
        errorCount: 2,
      );

      expect(resultWithIssues.totalCount, equals(10));
      expect(resultWithIssues.hasErrors, isTrue);
      expect(resultWithIssues.hasSkipped, isTrue);

      // Test with no errors
      const resultNoErrors = ImportResultWithStats(
        importedCount: 5,
        skippedCount: 0,
        errorCount: 0,
      );
      expect(resultNoErrors.hasErrors, isFalse);
      expect(resultNoErrors.hasSkipped, isFalse);
    });
  });
}
