import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:lurebox/core/services/backup_service.dart';
import 'package:lurebox/core/database/database_provider.dart';

// Custom Mock Database that implements sqflite's Database interface for testing
class MockDb extends Mock implements Database {
  final Map<String, List<Map<String, dynamic>>> _queryResults = {};

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
    return 1;
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) async {
    return action(_MockTransaction(this));
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
    return [];
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
}

class _MockTransaction implements Transaction {
  final MockDb _mockDb;

  _MockTransaction(this._mockDb);

  @override
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return 1;
  }

  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) async {
    return action(_MockTransaction(_mockDb));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return Future.value([]);
  }
}

// Mock DatabaseProvider for testing
class MockDatabaseProvider extends Mock implements DatabaseProvider {
  final MockDb mockDb;

  MockDatabaseProvider(this.mockDb);

  @override
  Future<Database> get database => Future.value(mockDb);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BackupService backupService;
  late MockDatabaseProvider mockDbProvider;
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
  });

  setUp(() {
    mockDatabase = MockDb();
    mockDbProvider = MockDatabaseProvider(mockDatabase);
    backupService = BackupService(mockDbProvider);
  });

  group('BackupService', () {
    group('exportToJson', () {
      test('returns file path with timestamp', () async {
        // Arrange
        mockDatabase.addQueryResult('fish_catches', []);
        mockDatabase.addQueryResult('equipments', []);
        mockDatabase.addQueryResult('species_history', []);
        mockDatabase.addQueryResult('settings', []);

        // Act
        final filePath = await backupService.exportToJson();

        // Assert
        expect(filePath, contains('lurebox_backup_'));
        expect(filePath, endsWith('.json'));

        // Cleanup
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      });

      test('queries all required tables', () async {
        // Arrange
        final fishCatchesData = [
          {'id': 1, 'species': 'Bass', 'length': 30.0}
        ];
        final equipmentsData = [
          {'id': 1, 'type': 'rod', 'brand': 'Test'}
        ];
        final speciesHistoryData = [
          {'id': 1, 'name': 'Bass', 'use_count': 5}
        ];
        final settingsData = [
          {'id': 1, 'key': 'theme', 'value': 'dark'}
        ];

        mockDatabase.addQueryResult('fish_catches', fishCatchesData);
        mockDatabase.addQueryResult('equipments', equipmentsData);
        mockDatabase.addQueryResult('species_history', speciesHistoryData);
        mockDatabase.addQueryResult('settings', settingsData);

        // Act
        await backupService.exportToJson();

        // Assert - verify queries were made
        expect(mockDatabase.query('fish_catches'), completes);
        expect(mockDatabase.query('equipments'), completes);
        expect(mockDatabase.query('species_history'), completes);
        expect(mockDatabase.query('settings'), completes);
      });

      test('writes valid JSON with expected structure', () async {
        // Arrange
        final fishCatchesData = [
          {'id': 1, 'species': 'Bass', 'length': 30.0, 'catch_time': 1234567890}
        ];
        final equipmentsData = [
          {'id': 1, 'type': 'rod', 'brand': 'Shimano'}
        ];
        final speciesHistoryData = [
          {'id': 1, 'name': 'Bass', 'use_count': 1}
        ];
        final settingsData = [
          {'id': 1, 'key': 'theme', 'value': 'light'}
        ];

        mockDatabase.addQueryResult('fish_catches', fishCatchesData);
        mockDatabase.addQueryResult('equipments', equipmentsData);
        mockDatabase.addQueryResult('species_history', speciesHistoryData);
        mockDatabase.addQueryResult('settings', settingsData);

        // Act
        final filePath = await backupService.exportToJson();
        final file = File(filePath);
        final content = await file.readAsString();

        // Parse and verify structure
        final data = jsonDecode(content) as Map<String, dynamic>;

        // Assert
        expect(data.containsKey('version'), isTrue);
        expect(data.containsKey('exportTime'), isTrue);
        expect(data.containsKey('fishCatches'), isTrue);
        expect(data.containsKey('equipments'), isTrue);
        expect(data.containsKey('speciesHistory'), isTrue);
        expect(data.containsKey('settings'), isTrue);
        expect(data['version'], equals(1));
        expect((data['fishCatches'] as List).length, equals(1));
        expect((data['equipments'] as List).length, equals(1));

        // Cleanup
        if (await file.exists()) {
          await file.delete();
        }
      });
    });

    group('importFromJson', () {
      test('returns imported count for valid JSON file', () async {
        // Arrange
        final validJson = jsonEncode({
          'version': 1,
          'exportTime': DateTime.now().toIso8601String(),
          'fishCatches': [
            {'id': 1, 'species': 'Trout', 'length': 25.0}
          ],
          'equipments': [
            {'id': 1, 'type': 'reel', 'brand': 'Abu Garcia'}
          ],
          'speciesHistory': [
            {'id': 1, 'name': 'Trout', 'use_count': 1}
          ],
          'settings': [
            {'id': 1, 'key': 'theme', 'value': 'dark'}
          ],
        });

        // Create a temporary file with valid JSON
        final tempDir = Directory.systemTemp.createTempSync();
        final tempFile = File('${tempDir.path}/test_backup.json');
        await tempFile.writeAsString(validJson);

        // Act
        final count = await backupService.importFromJson(tempFile.path);

        // Assert
        expect(count, equals(1)); // Only fishCatches count toward importedCount

        // Cleanup
        await tempFile.delete();
        await tempDir.delete();
      });

      test('throws exception when file does not exist', () async {
        // Arrange
        const nonExistentPath = '/non/existent/path/backup.json';

        // Act & Assert
        expect(
          () => backupService.importFromJson(nonExistentPath),
          throwsA(isA<Exception>()),
        );
      });

      test('parses JSON with all data types correctly', () async {
        // Arrange
        final validJson = jsonEncode({
          'version': 1,
          'exportTime': DateTime.now().toIso8601String(),
          'fishCatches': [
            {'id': 1, 'species': 'Bass', 'length': 30.0},
            {'id': 2, 'species': 'Pike', 'length': 45.0},
          ],
          'equipments': [
            {'id': 1, 'type': 'rod', 'brand': 'Fenwick'},
            {'id': 2, 'type': 'lure', 'brand': 'Rapala'},
          ],
          'speciesHistory': [
            {'id': 1, 'name': 'Bass', 'use_count': 10},
            {'id': 2, 'name': 'Pike', 'use_count': 5},
          ],
          'settings': [
            {'id': 1, 'key': 'theme', 'value': 'light'},
          ],
        });

        // Create a temporary file
        final tempDir = Directory.systemTemp.createTempSync();
        final tempFile = File('${tempDir.path}/full_backup.json');
        await tempFile.writeAsString(validJson);

        // Act
        final count = await backupService.importFromJson(tempFile.path);

        // Assert
        expect(count, equals(2)); // Two fish catches imported

        // Cleanup
        await tempFile.delete();
        await tempDir.delete();
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
        final count = await backupService.importFromJson(tempFile.path);

        // Assert
        expect(count, equals(0));

        // Cleanup
        await tempFile.delete();
        await tempDir.delete();
      });

      test('handles partial backup data (missing some tables)', () async {
        // Arrange - only fishCatches provided
        final partialJson = jsonEncode({
          'version': 1,
          'exportTime': DateTime.now().toIso8601String(),
          'fishCatches': [
            {'id': 1, 'species': 'Walleye', 'length': 50.0},
          ],
        });

        final tempDir = Directory.systemTemp.createTempSync();
        final tempFile = File('${tempDir.path}/partial_backup.json');
        await tempFile.writeAsString(partialJson);

        // Act
        final count = await backupService.importFromJson(tempFile.path);

        // Assert
        expect(count, equals(1));

        // Cleanup
        await tempFile.delete();
        await tempDir.delete();
      });
    });
  });
}
