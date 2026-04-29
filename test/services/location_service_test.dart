import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/database/database_provider.dart';
import 'package:lurebox/core/services/location_service.dart';
import 'package:lurebox/core/utils/input_validator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Custom Mock Database for query-based tests
class MockDb extends Mock implements Database {
  final Map<String, List<Map<String, dynamic>>> _queryResults = {};

  void addQueryResult(String sql, List<Map<String, dynamic>> results) {
    _queryResults[sql] = results;
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
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
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
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) async {
    return action(_MockTransaction(this));
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {}
}

class _MockTransaction implements Transaction {

  _MockTransaction(this._mockDb);
  final MockDb _mockDb;

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
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) {
    return _mockDb.rawUpdate(sql, arguments);
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
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    return 1;
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
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    return [];
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

  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) async {
    return action(this);
  }

  Future<void> close() async {}

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final methodName = invocation.memberName.toString();
    if (methodName.contains('batch')) {
      return _MockBatch();
    }
    if (methodName.contains('Cursor')) {
      return _MockQueryCursor();
    }
    if (methodName.contains('database')) {
      return _mockDb;
    }
    return null;
  }
}

class _MockBatch implements Batch {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockQueryCursor implements QueryCursor {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// Mock DatabaseProvider for query-based tests
class MockDatabaseProvider extends Mock implements DatabaseProvider {

  MockDatabaseProvider(this.mockDb);
  final MockDb mockDb;

  @override
  Future<Database> get database => Future.value(mockDb);
}

// Real DatabaseProvider for integration tests
class RealDatabaseProvider implements DatabaseProvider {

  RealDatabaseProvider(this._db);
  final Database _db;

  @override
  Future<Database> get database => Future.value(_db);

  @override
  Future<void> close() async {}

  @override
  Future<void> resetForTesting() async {}
}

void main() {
  // Initialize FFI for desktop testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('LocationService - query operations (mocked)', () {
    late LocationService service;
    late MockDatabaseProvider mockDbProvider;
    late MockDb mockDatabase;

    setUp(() {
      mockDatabase = MockDb();
      mockDbProvider = MockDatabaseProvider(mockDatabase);
      service = LocationService(mockDbProvider);
    });

    tearDown(() {
      // No resources to clean up - mocks are garbage collected
    });

    test('getAllLocations returns location data from rawQuery', () async {
      final locationData = [
        {
          'location_name': '西湖',
          'fish_count': 5,
          'first_time': '2024-01-01T10:00:00.000',
          'last_time': '2024-06-15T14:30:00.000',
        },
        {
          'location_name': '钱塘江',
          'fish_count': 3,
          'first_time': '2024-02-01T08:00:00.000',
          'last_time': '2024-05-20T16:00:00.000',
        },
      ];
      mockDatabase.addQueryResult(
        '''
      SELECT DISTINCT location_name, COUNT(*) as fish_count,
      MIN(catch_time) as first_time, MAX(catch_time) as last_time
      FROM fish_catches
      WHERE location_name IS NOT NULL AND location_name != ''
      GROUP BY location_name
      ORDER BY fish_count DESC
    ''',
        locationData,
      );

      final result = await service.getAllLocations();

      expect(result, equals(locationData));
      expect(result.length, equals(2));
      expect(result[0]['location_name'], equals('西湖'));
      expect(result[0]['fish_count'], equals(5));
    });

    test('getAllLocations returns empty list when no locations', () async {
      mockDatabase.addQueryResult(
        '''
      SELECT DISTINCT location_name, COUNT(*) as fish_count,
      MIN(catch_time) as first_time, MAX(catch_time) as last_time
      FROM fish_catches
      WHERE location_name IS NOT NULL AND location_name != ''
      GROUP BY location_name
      ORDER BY fish_count DESC
    ''',
        [],
      );

      final result = await service.getAllLocations();

      expect(result, isEmpty);
    });

    test('getFishCountByLocation returns fish count for given location', () async {
      mockDatabase.addQueryResult(
        'SELECT COUNT(*) as count FROM fish_catches WHERE location_name = ?',
        [{'count': 10}],
      );

      final result = await service.getFishCountByLocation('西湖');

      expect(result, equals(10));
    });

    test('getFishCountByLocation returns 0 when location not found', () async {
      mockDatabase.addQueryResult(
        'SELECT COUNT(*) as count FROM fish_catches WHERE location_name = ?',
        [{'count': 0}],
      );

      final result = await service.getFishCountByLocation('未知地点');

      expect(result, equals(0));
    });
  });

  group('LocationService - mutation operations (integration)', () {
    late LocationService service;
    late Database db;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE fish_catches (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                species TEXT NOT NULL,
                length REAL NOT NULL,
                catch_time TEXT NOT NULL,
                location_name TEXT,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
              )
            ''');
          },
        ),
      );
      final provider = RealDatabaseProvider(db);
      service = LocationService(provider);
    });

    tearDown(() async {
      await db.close();
    });

    group('mergeLocations', () {
      test('updates all source locations to target location', () async {
        await db.insert('fish_catches', {
          'species': 'TestFish',
          'length': 30.0,
          'catch_time': DateTime.now().toIso8601String(),
          'location_name': '旧地点1',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        await db.insert('fish_catches', {
          'species': 'TestFish',
          'length': 25.0,
          'catch_time': DateTime.now().toIso8601String(),
          'location_name': '旧地点2',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        await service.mergeLocations(['旧地点1', '旧地点2'], '新地点');

        final results = await db.query(
          'fish_catches',
          columns: ['location_name'],
        );
        final locationNames = results.map((r) => r['location_name']! as String).toList();

        expect(locationNames, equals(['新地点', '新地点']));
        expect(locationNames, isNot(contains('旧地点1')));
        expect(locationNames, isNot(contains('旧地点2')));
      });

      test('updates only specified source locations', () async {
        await db.insert('fish_catches', {
          'species': 'TestFish',
          'length': 30.0,
          'catch_time': DateTime.now().toIso8601String(),
          'location_name': '要被合并的地点',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        await db.insert('fish_catches', {
          'species': 'TestFish',
          'length': 25.0,
          'catch_time': DateTime.now().toIso8601String(),
          'location_name': '保留的地点',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        await service.mergeLocations(['要被合并的地点'], '新地点');

        final results = await db.query(
          'fish_catches',
          columns: ['location_name'],
          orderBy: 'location_name ASC',
        );
        final locationNames = results.map((r) => r['location_name']! as String).toList();

        expect(locationNames, equals(['保留的地点', '新地点']));
      });

      test('handles empty list without error', () async {
        await db.insert('fish_catches', {
          'species': 'TestFish',
          'length': 30.0,
          'catch_time': DateTime.now().toIso8601String(),
          'location_name': '存在的地点',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        await service.mergeLocations([], '新地点');

        final results = await db.query('fish_catches');
        expect(results.length, equals(1));
        expect(results.first['location_name'], equals('存在的地点'));
      });

      test('handles non-existent source location without error', () async {
        await db.insert('fish_catches', {
          'species': 'TestFish',
          'length': 30.0,
          'catch_time': DateTime.now().toIso8601String(),
          'location_name': '存在的地点',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Merging with non-existent location does nothing - no new records created
        await service.mergeLocations(['不存在的地点'], '新地点');

        final results = await db.query(
          'fish_catches',
          columns: ['location_name'],
        );
        final locationNames = results.map((r) => r['location_name']! as String).toList();

        // Only the existing location remains - mergeLocations only updates existing records
        expect(locationNames, equals(['存在的地点']));
      });
    });

    group('renameLocation', () {
      test('updates location name correctly', () async {
        await db.insert('fish_catches', {
          'species': 'TestFish',
          'length': 30.0,
          'catch_time': DateTime.now().toIso8601String(),
          'location_name': '旧名称',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        await service.renameLocation('旧名称', '新名称');

        final results = await db.query(
          'fish_catches',
          columns: ['location_name'],
        );
        final locationNames = results.map((r) => r['location_name']! as String).toList();

        expect(locationNames, equals(['新名称']));
        expect(locationNames, isNot(contains('旧名称')));
      });

      test('updates multiple catches at same location', () async {
        await db.insert('fish_catches', {
          'species': 'TestFish1',
          'length': 30.0,
          'catch_time': DateTime.now().toIso8601String(),
          'location_name': '批量重命名地点',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        await db.insert('fish_catches', {
          'species': 'TestFish2',
          'length': 25.0,
          'catch_time': DateTime.now().toIso8601String(),
          'location_name': '批量重命名地点',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        await service.renameLocation('批量重命名地点', '新名称');

        final results = await db.query(
          'fish_catches',
          columns: ['location_name'],
        );
        final locationNames = results.map((r) => r['location_name']! as String).toList();

        expect(locationNames, equals(['新名称', '新名称']));
      });

      test('rejects rename to empty string', () async {
        await db.insert('fish_catches', {
          'species': 'TestFish',
          'length': 30.0,
          'catch_time': DateTime.now().toIso8601String(),
          'location_name': '待清空地点',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        expect(
          () => service.renameLocation('待清空地点', ''),
          throwsA(isA<ValidationException>()),
        );
      });

      test('does not affect other locations when renaming', () async {
        await db.insert('fish_catches', {
          'species': 'TestFish',
          'length': 30.0,
          'catch_time': DateTime.now().toIso8601String(),
          'location_name': '要被重命名的地点',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        await db.insert('fish_catches', {
          'species': 'TestFish',
          'length': 25.0,
          'catch_time': DateTime.now().toIso8601String(),
          'location_name': '保留地点',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        await service.renameLocation('要被重命名的地点', '新名称');

        final results = await db.query(
          'fish_catches',
          columns: ['location_name'],
          orderBy: 'species ASC',
        );
        final locationNames = results.map((r) => r['location_name']! as String).toList();

        expect(locationNames, equals(['新名称', '保留地点']));
      });
    });
  });

  group('LocationService - pure functions (unit tests)', () {
    late LocationService service;

    setUp(() {
      // Use a dummy provider for pure function tests
      service = LocationService(_DummyDatabaseProvider());
    });

    group('findSimilarLocations', () {
      test('returns empty list for no similar locations', () {
        final locations = ['西湖', '钱塘江', '千岛湖'];
        final result = service.findSimilarLocations(locations);
        expect(result, isEmpty);
      });

      test('returns empty list for empty input', () {
        final result = service.findSimilarLocations([]);
        expect(result, isEmpty);
      });

      test('returns empty list for single location', () {
        final result = service.findSimilarLocations(['唯一地点']);
        expect(result, isEmpty);
      });

      test('does not group identical locations', () {
        final locations = ['测试地点', '测试地点', '测试地点'];
        final result = service.findSimilarLocations(locations);
        expect(result, isEmpty);
      });

      test('groups locations that become identical after number removal', () {
        final locations = ['1号地点', '2号地点'];
        final result = service.findSimilarLocations(locations);
        expect(result.length, equals(1));
        expect(result[0], containsAll(['1号地点', '2号地点']));
      });

      test('does not group locations with low similarity', () {
        final locations = ['西湖', '钱塘江', '千岛湖'];
        final result = service.findSimilarLocations(locations);
        expect(result, isEmpty);
      });

      test('groups locations with same base name but different numbers', () {
        final locations = ['钓点1号', '钓点2号', '其他钓点'];
        final result = service.findSimilarLocations(locations);
        expect(result.length, equals(1));
        expect(result[0], containsAll(['钓点1号', '钓点2号']));
      });

      test('returns multiple groups for distinct similarity clusters', () {
        final locations = ['1号北京', '2号北京', '1号上海', '2号上海'];
        final result = service.findSimilarLocations(locations);
        expect(result.length, equals(2));
      });

      test('groups locations with high similarity score', () {
        // '钓点1号' and '钓点2号' become '钓点号' and '钓点号' after removing numbers
        // which are identical (similarity = 1.0)
        final locations = ['钓点1号', '钓点2号'];
        final result = service.findSimilarLocations(locations);
        expect(result.length, equals(1));
        expect(result[0], containsAll(['钓点1号', '钓点2号']));
      });
    });

    group('getBestLocationName', () {
      test('returns longest location name', () {
        final result = service.getBestLocationName(
          ['短', '中等长度地点', '最长的地点名称'],
        );
        expect(result, equals('最长的地点名称'));
      });

      test('returns empty string for empty list', () {
        final result = service.getBestLocationName([]);
        expect(result, equals(''));
      });

      test('returns last of equal-length locations', () {
        final result = service.getBestLocationName(['等长1', '等长2', '等长3']);
        expect(result, equals('等长3'));
      });

      test('returns correct name for single location', () {
        final result = service.getBestLocationName(['唯一地点']);
        expect(result, equals('唯一地点'));
      });

      test('handles unicode location names correctly', () {
        final result = service.getBestLocationName(['东京', '纽约', '北京时间']);
        expect(result, equals('北京时间'));
      });
    });
  });
}

/// Dummy provider for pure function tests
class _DummyDatabaseProvider implements DatabaseProvider {
  Database? _db;

  @override
  Future<Database> get database async {
    _db ??= await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    return _db!;
  }

  @override
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  @override
  Future<void> resetForTesting() async {
    await close();
  }
}
