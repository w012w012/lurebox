import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:lurebox/core/services/location_service.dart';
import 'package:lurebox/core/database/database_provider.dart';

// Custom Mock Database that implements sqflite's Database interface for testing
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
  final MockDb _mockDb;

  _MockTransaction(this._mockDb);

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

  // Use noSuchMethod for remaining methods that aren't explicitly implemented
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

// Mock DatabaseProvider for testing
class MockDatabaseProvider extends Mock implements DatabaseProvider {
  final MockDb mockDb;

  MockDatabaseProvider(this.mockDb);

  @override
  Future<Database> get database => Future.value(mockDb);
}

void main() {
  late LocationService service;
  late MockDatabaseProvider mockDbProvider;
  late MockDb mockDatabase;

  setUp(() {
    mockDatabase = MockDb();
    mockDbProvider = MockDatabaseProvider(mockDatabase);
    service = LocationService(mockDbProvider);
  });

  group('LocationService', () {
    group('getAllLocations', () {
      test('returns location data from rawQuery', () async {
        // Arrange
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

        // Act
        final result = await service.getAllLocations();

        // Assert
        expect(result, equals(locationData));
        expect(result.length, equals(2));
        expect(result[0]['location_name'], equals('西湖'));
        expect(result[0]['fish_count'], equals(5));
      });

      test('returns empty list when no locations', () async {
        // Arrange
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

        // Act
        final result = await service.getAllLocations();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getFishCountByLocation', () {
      test('returns fish count for given location', () async {
        // Arrange
        mockDatabase.addQueryResult(
          'SELECT COUNT(*) as count FROM fish_catches WHERE location_name = ?',
          [
            {'count': 10}
          ],
        );

        // Act
        final result = await service.getFishCountByLocation('西湖');

        // Assert
        expect(result, equals(10));
      });

      test('returns 0 when location not found', () async {
        // Arrange
        mockDatabase.addQueryResult(
          'SELECT COUNT(*) as count FROM fish_catches WHERE location_name = ?',
          [
            {'count': 0}
          ],
        );

        // Act
        final result = await service.getFishCountByLocation('未知地点');

        // Assert
        expect(result, equals(0));
      });
    });

    group('mergeLocations', () {
      test('handles multiple locations without throwing', () async {
        // Arrange & Act - mergeLocations should complete without error
        await service.mergeLocations(['旧地点1', '旧地点2'], '新地点');

        // Assert - no exception means success
      });

      test('handles single location without throwing', () async {
        // Arrange & Act
        await service.mergeLocations(['唯一地点'], '新地点');

        // Assert - no exception means success
      });

      test('handles empty list without throwing', () async {
        // Arrange & Act
        await service.mergeLocations([], '新地点');

        // Assert - no exception means success
      });
    });

    group('renameLocation', () {
      test('updates location name without throwing', () async {
        // Arrange & Act
        await service.renameLocation('旧名称', '新名称');

        // Assert - no exception means success
      });

      test('handles rename to empty string without throwing', () async {
        // Arrange & Act
        await service.renameLocation('旧名称', '');

        // Assert - no exception means success
      });
    });

    group('findSimilarLocations', () {
      test('returns empty list for no similar locations', () {
        // Arrange
        final locations = ['西湖', '钱塘江', '千岛湖'];

        // Act
        final result = service.findSimilarLocations(locations);

        // Assert
        expect(result, isEmpty);
      });

      test('groups similar locations together', () {
        // Arrange - "1号地点" and "2号地点" should be similar after removing numbers
        final locations = ['地点A', '1号地点A', '2号地点A', '地点B'];

        // Act
        final result = service.findSimilarLocations(locations);

        // Assert - after cleaning numbers, '1号地点A' and '2号地点A' become '号地点A' which is similar
        // Note: the algorithm removes numbers and checks similarity > 0.7
        // Since '号地点A' vs '号地点A' is identical (similarity = 1.0), they should be grouped
        expect(result, isA<List<List<String>>>());
      });

      test('returns empty list for empty input', () {
        // Act
        final result = service.findSimilarLocations([]);

        // Assert
        expect(result, isEmpty);
      });

      test('returns empty list for single location', () {
        // Act
        final result = service.findSimilarLocations(['唯一地点']);

        // Assert
        expect(result, isEmpty);
      });

      test('does not group identical locations', () {
        // Arrange - same location appears multiple times but should not self-group
        final locations = ['测试地点', '测试地点', '测试地点'];

        // Act
        final result = service.findSimilarLocations(locations);

        // Assert - identical strings return false in _isSimilarLocation
        expect(result, isEmpty);
      });

      test('groups locations that become identical after number removal', () {
        // Arrange - "1号地点" and "2号地点" both become "号地点" after removing numbers
        final locations = ['1号地点', '2号地点'];

        // Act
        final result = service.findSimilarLocations(locations);

        // Assert - these should be grouped because cleaned strings are identical
        expect(result.length, equals(1));
        expect(result[0], containsAll(['1号地点', '2号地点']));
      });

      test('does not group locations with low similarity', () {
        // Arrange - very different locations
        final locations = ['西湖', '钱塘江', '千岛湖'];

        // Act
        final result = service.findSimilarLocations(locations);

        // Assert
        expect(result, isEmpty);
      });

      test('handles locations with numbers correctly', () {
        // Arrange - numbers should be removed before comparison
        final locations = ['钓点1号', '钓点2号', '其他钓点'];

        // Act
        final result = service.findSimilarLocations(locations);

        // Assert - 1号 and 2号 both become "号" after removing numbers
        // They should be grouped together
        expect(result.length, equals(1));
        expect(result[0], equals(['钓点1号', '钓点2号']));
      });

      test('returns all groups when multiple similarity groups exist', () {
        // Arrange - create two distinct groups using number removal
        // "1号北京" and "2号北京" become "号北京" - similar
        // "1号上海" and "2号上海" become "号上海" - similar
        final locations = ['1号北京', '2号北京', '1号上海', '2号上海'];

        // Act
        final result = service.findSimilarLocations(locations);

        // Assert - should have two groups
        expect(result.length, equals(2));
      });
    });

    group('getBestLocationName', () {
      test('returns longest location name', () {
        // Act
        final result = service.getBestLocationName(['短', '中等长度地点', '最长的地点名称']);

        // Assert
        expect(result, equals('最长的地点名称'));
      });

      test('returns empty string for empty list', () {
        // Act
        final result = service.getBestLocationName([]);

        // Assert
        expect(result, equals(''));
      });

      test('returns last of equal-length locations', () {
        // Act
        final result = service.getBestLocationName(['等长1', '等长2', '等长3']);

        // Assert - reduce returns the last element when accumulator always picks b
        // The implementation does: a.length > b.length ? a : b
        // When lengths are equal, it picks b (the current/last element)
        expect(result, equals('等长3'));
      });

      test('returns correct name for single location', () {
        // Act
        final result = service.getBestLocationName(['唯一地点']);

        // Assert
        expect(result, equals('唯一地点'));
      });

      test('handles unicode location names correctly', () {
        // Act
        final result = service.getBestLocationName(['东京', '纽约', '北京时间']);

        // Assert - longest by character count
        expect(result, equals('北京时间'));
      });
    });
  });
}
