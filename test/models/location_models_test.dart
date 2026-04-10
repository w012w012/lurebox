import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/location_models.dart';

void main() {
  group('LocationWithStats', () {
    late LocationWithStats testInstance;

    setUp(() {
      testInstance = LocationWithStats(
        name: 'Test Lake',
        latitude: 35.0,
        longitude: 139.0,
        fishCount: 10,
        lastCatchTime: DateTime(2024, 1, 15),
      );
    });

    test('creates LocationWithStats with required fields', () {
      expect(testInstance.name, equals('Test Lake'));
      expect(testInstance.latitude, equals(35.0));
      expect(testInstance.longitude, equals(139.0));
      expect(testInstance.fishCount, equals(10));
      expect(testInstance.lastCatchTime, equals(DateTime(2024, 1, 15)));
    });

    test('creates LocationWithStats with null lastCatchTime', () {
      final instance = LocationWithStats(
        name: 'River',
        latitude: 36.0,
        longitude: 140.0,
        fishCount: 5,
      );

      expect(instance.lastCatchTime, isNull);
    });

    test('fromMap creates LocationWithStats from map', () {
      final map = {
        'location_name': 'River Point',
        'latitude': 36.5,
        'longitude': 140.0,
        'fish_count': 5,
        'last_catch_time': '2024-02-20T10:30:00.000',
      };

      final result = LocationWithStats.fromMap(map);

      expect(result.name, equals('River Point'));
      expect(result.latitude, equals(36.5));
      expect(result.longitude, equals(140.0));
      expect(result.fishCount, equals(5));
      expect(result.lastCatchTime, equals(DateTime(2024, 2, 20, 10, 30)));
    });

    test('fromMap handles null values', () {
      final map = <String, dynamic>{};

      final result = LocationWithStats.fromMap(map);

      expect(result.name, equals('Unknown'));
      expect(result.latitude, equals(0.0));
      expect(result.longitude, equals(0.0));
      expect(result.fishCount, equals(0));
      expect(result.lastCatchTime, isNull);
    });

    test('fromMap handles null last_catch_time', () {
      final map = {
        'location_name': 'Test',
        'latitude': 35.0,
        'longitude': 139.0,
        'fish_count': 10,
        'last_catch_time': null,
      };

      final result = LocationWithStats.fromMap(map);

      expect(result.lastCatchTime, isNull);
    });

    test('fromMap handles invalid date format', () {
      final map = {
        'location_name': 'Test',
        'latitude': 35.0,
        'longitude': 139.0,
        'fish_count': 10,
        'last_catch_time': 'invalid-date',
      };

      final result = LocationWithStats.fromMap(map);

      expect(result.lastCatchTime, isNull);
    });

    test('toMap converts LocationWithStats to map', () {
      final map = testInstance.toMap();

      expect(map['location_name'], equals('Test Lake'));
      expect(map['latitude'], equals(35.0));
      expect(map['longitude'], equals(139.0));
      expect(map['fish_count'], equals(10));
      expect(map['last_catch_time'], equals('2024-01-15T00:00:00.000'));
    });

    test('toMap handles null lastCatchTime', () {
      final instance = LocationWithStats(
        name: 'River',
        latitude: 36.0,
        longitude: 140.0,
        fishCount: 5,
      );

      final map = instance.toMap();

      expect(map['last_catch_time'], isNull);
    });

    test('copyWith creates modified copy with new values', () {
      final copy = testInstance.copyWith(name: 'New Lake', fishCount: 20);

      expect(copy.name, equals('New Lake'));
      expect(copy.fishCount, equals(20));
      expect(copy.latitude, equals(35.0));
      expect(copy.longitude, equals(139.0));
    });

    test('copyWith preserves unmodified fields', () {
      final copy = testInstance.copyWith(fishCount: 50);

      expect(copy.name, equals('Test Lake'));
      expect(copy.latitude, equals(35.0));
      expect(copy.longitude, equals(139.0));
      expect(copy.fishCount, equals(50));
      expect(copy.lastCatchTime, equals(DateTime(2024, 1, 15)));
    });

    test('copyWith cannot set lastCatchTime to null (uses ?? operator)', () {
      // Note: copyWith uses ?? operator so explicitly passing null
      // doesn't actually set it to null - this is the actual behavior
      final copy = testInstance.copyWith(lastCatchTime: null);

      // The ?? operator means: if lastCatchTime is null, use this.lastCatchTime
      expect(copy.lastCatchTime, equals(testInstance.lastCatchTime));
    });

    test('equality based on name, latitude, and longitude', () {
      final other = LocationWithStats(
        name: 'Test Lake',
        latitude: 35.0,
        longitude: 139.0,
        fishCount: 999,
        lastCatchTime: DateTime(2020, 1, 1),
      );

      expect(testInstance, equals(other));
    });

    test('different name is not equal', () {
      final other = LocationWithStats(
        name: 'Different Lake',
        latitude: 35.0,
        longitude: 139.0,
        fishCount: 10,
      );

      expect(testInstance, isNot(equals(other)));
    });

    test('different latitude is not equal', () {
      final other = LocationWithStats(
        name: 'Test Lake',
        latitude: 36.0,
        longitude: 139.0,
        fishCount: 10,
      );

      expect(testInstance, isNot(equals(other)));
    });

    test('different longitude is not equal', () {
      final other = LocationWithStats(
        name: 'Test Lake',
        latitude: 35.0,
        longitude: 140.0,
        fishCount: 10,
      );

      expect(testInstance, isNot(equals(other)));
    });

    test('hashCode based on name, latitude, and longitude', () {
      const other = LocationWithStats(
        name: 'Test Lake',
        latitude: 35.0,
        longitude: 139.0,
        fishCount: 999,
      );

      expect(testInstance.hashCode, equals(other.hashCode));
    });

    test('toString contains relevant information', () {
      final str = testInstance.toString();

      expect(str, contains('LocationWithStats'));
      expect(str, contains('Test Lake'));
      expect(str, contains('35.0'));
      expect(str, contains('139.0'));
      expect(str, contains('10'));
    });
  });

  group('LocationStats', () {
    late LocationStats testInstance;

    setUp(() {
      testInstance = const LocationStats(
        totalCatches: 10,
        releaseCount: 7,
        keepCount: 3,
        speciesDistribution: {'Bass': 5, 'Trout': 5},
        avgLength: 30.5,
        avgWeight: 2.3,
      );
    });

    test('creates LocationStats with required fields', () {
      expect(testInstance.totalCatches, equals(10));
      expect(testInstance.releaseCount, equals(7));
      expect(testInstance.keepCount, equals(3));
      expect(testInstance.speciesDistribution['Bass'], equals(5));
      expect(testInstance.speciesDistribution['Trout'], equals(5));
      expect(testInstance.avgLength, equals(30.5));
      expect(testInstance.avgWeight, equals(2.3));
    });

    test('creates LocationStats with null optional fields', () {
      const stats = LocationStats(
        totalCatches: 5,
        releaseCount: 3,
        keepCount: 2,
        speciesDistribution: {},
      );

      expect(stats.avgLength, isNull);
      expect(stats.avgWeight, isNull);
    });

    test('releaseRate calculates correctly', () {
      expect(testInstance.releaseRate, closeTo(0.7, 0.001));
    });

    test('releaseRate returns 0 when totalCatches is 0', () {
      const stats = LocationStats(
        totalCatches: 0,
        releaseCount: 0,
        keepCount: 0,
        speciesDistribution: {},
      );

      expect(stats.releaseRate, equals(0.0));
    });

    test('releaseRate returns 1.0 when all released', () {
      const stats = LocationStats(
        totalCatches: 5,
        releaseCount: 5,
        keepCount: 0,
        speciesDistribution: {'Bass': 5},
      );

      expect(stats.releaseRate, equals(1.0));
    });

    test('releaseRate calculates correctly with partial releases', () {
      const stats = LocationStats(
        totalCatches: 100,
        releaseCount: 33,
        keepCount: 67,
        speciesDistribution: {},
      );

      expect(stats.releaseRate, closeTo(0.33, 0.001));
    });

    test('fromMap creates LocationStats from map', () {
      final map = {
        'total_catches': 20,
        'release_count': 15,
        'keep_count': 5,
        'species_distribution': {'Bass': 10, 'Trout': 10},
        'avg_length': 25.5,
        'avg_weight': 1.8,
      };

      final result = LocationStats.fromMap(map);

      expect(result.totalCatches, equals(20));
      expect(result.releaseCount, equals(15));
      expect(result.keepCount, equals(5));
      expect(result.speciesDistribution['Bass'], equals(10));
      expect(result.speciesDistribution['Trout'], equals(10));
      expect(result.avgLength, equals(25.5));
      expect(result.avgWeight, equals(1.8));
    });

    test('fromMap handles null values', () {
      final map = <String, dynamic>{};

      final result = LocationStats.fromMap(map);

      expect(result.totalCatches, equals(0));
      expect(result.releaseCount, equals(0));
      expect(result.keepCount, equals(0));
      expect(result.speciesDistribution, isEmpty);
      expect(result.avgLength, isNull);
      expect(result.avgWeight, isNull);
    });

    test('fromMap handles null species_distribution', () {
      final map = {
        'total_catches': 10,
        'release_count': 5,
        'keep_count': 5,
        'species_distribution': null,
      };

      final result = LocationStats.fromMap(map);

      expect(result.speciesDistribution, isEmpty);
    });

    test('fromMap handles missing avgLength and avgWeight', () {
      final map = {
        'total_catches': 10,
        'release_count': 5,
        'keep_count': 5,
        'species_distribution': <String, int>{},
      };

      final result = LocationStats.fromMap(map);

      expect(result.avgLength, isNull);
      expect(result.avgWeight, isNull);
    });

    test('toMap converts LocationStats to map', () {
      final map = testInstance.toMap();

      expect(map['total_catches'], equals(10));
      expect(map['release_count'], equals(7));
      expect(map['keep_count'], equals(3));
      expect(map['species_distribution'], equals({'Bass': 5, 'Trout': 5}));
      expect(map['avg_length'], equals(30.5));
      expect(map['avg_weight'], equals(2.3));
    });

    test('toMap handles null avgLength and avgWeight', () {
      const stats = LocationStats(
        totalCatches: 5,
        releaseCount: 3,
        keepCount: 2,
        speciesDistribution: {},
      );

      final map = stats.toMap();

      expect(map['avg_length'], isNull);
      expect(map['avg_weight'], isNull);
    });

    test('copyWith creates modified copy with new values', () {
      final copy = testInstance.copyWith(totalCatches: 50, releaseCount: 40);

      expect(copy.totalCatches, equals(50));
      expect(copy.releaseCount, equals(40));
      expect(copy.keepCount, equals(3));
    });

    test('copyWith preserves unmodified fields', () {
      final copy = testInstance.copyWith(keepCount: 10);

      expect(copy.totalCatches, equals(10));
      expect(copy.releaseCount, equals(7));
      expect(copy.keepCount, equals(10));
      expect(copy.speciesDistribution, equals({'Bass': 5, 'Trout': 5}));
      expect(copy.avgLength, equals(30.5));
      expect(copy.avgWeight, equals(2.3));
    });

    test('copyWith can modify speciesDistribution', () {
      final copy = testInstance.copyWith(
        speciesDistribution: {'Carp': 8, 'Catfish': 2},
      );

      expect(copy.speciesDistribution['Carp'], equals(8));
      expect(copy.speciesDistribution['Catfish'], equals(2));
      expect(copy.totalCatches, equals(10));
    });

    test(
        'copyWith cannot set avgLength and avgWeight to null (uses ?? operator)',
        () {
      // Note: copyWith uses ?? operator so explicitly passing null
      // doesn't actually set it to null - this is the actual behavior
      final copy = testInstance.copyWith(avgLength: null, avgWeight: null);

      // The ?? operator means: if value is null, use this.value
      expect(copy.avgLength, equals(testInstance.avgLength));
      expect(copy.avgWeight, equals(testInstance.avgWeight));
    });

    test('equality based on all fields', () {
      const other = LocationStats(
        totalCatches: 10,
        releaseCount: 7,
        keepCount: 3,
        speciesDistribution: {'Bass': 5, 'Trout': 5},
        avgLength: 30.5,
        avgWeight: 2.3,
      );

      expect(testInstance, equals(other));
    });

    test('different totalCatches is not equal', () {
      const other = LocationStats(
        totalCatches: 20,
        releaseCount: 7,
        keepCount: 3,
        speciesDistribution: {'Bass': 5, 'Trout': 5},
        avgLength: 30.5,
        avgWeight: 2.3,
      );

      expect(testInstance, isNot(equals(other)));
    });

    test('different releaseCount is not equal', () {
      const other = LocationStats(
        totalCatches: 10,
        releaseCount: 5,
        keepCount: 3,
        speciesDistribution: {'Bass': 5, 'Trout': 5},
        avgLength: 30.5,
        avgWeight: 2.3,
      );

      expect(testInstance, isNot(equals(other)));
    });

    test('different keepCount is not equal', () {
      const other = LocationStats(
        totalCatches: 10,
        releaseCount: 7,
        keepCount: 5,
        speciesDistribution: {'Bass': 5, 'Trout': 5},
        avgLength: 30.5,
        avgWeight: 2.3,
      );

      expect(testInstance, isNot(equals(other)));
    });

    test('different speciesDistribution is not equal', () {
      const other = LocationStats(
        totalCatches: 10,
        releaseCount: 7,
        keepCount: 3,
        speciesDistribution: {'Bass': 10},
        avgLength: 30.5,
        avgWeight: 2.3,
      );

      expect(testInstance, isNot(equals(other)));
    });

    test('different avgLength is not equal', () {
      const other = LocationStats(
        totalCatches: 10,
        releaseCount: 7,
        keepCount: 3,
        speciesDistribution: {'Bass': 5, 'Trout': 5},
        avgLength: 40.0,
        avgWeight: 2.3,
      );

      expect(testInstance, isNot(equals(other)));
    });

    test('different avgWeight is not equal', () {
      const other = LocationStats(
        totalCatches: 10,
        releaseCount: 7,
        keepCount: 3,
        speciesDistribution: {'Bass': 5, 'Trout': 5},
        avgLength: 30.5,
        avgWeight: 5.0,
      );

      expect(testInstance, isNot(equals(other)));
    });

    test('null avgLength vs null avgWeight are equal', () {
      const stats1 = LocationStats(
        totalCatches: 10,
        releaseCount: 7,
        keepCount: 3,
        speciesDistribution: {'Bass': 5, 'Trout': 5},
        avgLength: null,
        avgWeight: null,
      );

      const stats2 = LocationStats(
        totalCatches: 10,
        releaseCount: 7,
        keepCount: 3,
        speciesDistribution: {'Bass': 5, 'Trout': 5},
        avgLength: null,
        avgWeight: null,
      );

      expect(stats1, equals(stats2));
    });

    test('hashCode based on all fields', () {
      const other = LocationStats(
        totalCatches: 10,
        releaseCount: 7,
        keepCount: 3,
        speciesDistribution: {'Bass': 5, 'Trout': 5},
        avgLength: 30.5,
        avgWeight: 2.3,
      );

      expect(testInstance.hashCode, equals(other.hashCode));
    });

    test('toString returns default object description', () {
      final str = testInstance.toString();

      // LocationStats uses default Object.toString() since no custom override exists
      expect(str, contains('LocationStats'));
    });
  });

  group('LocationStats speciesDistribution equality', () {
    test('equal maps with same key-value pairs are equal', () {
      const stats1 = LocationStats(
        totalCatches: 10,
        releaseCount: 7,
        keepCount: 3,
        speciesDistribution: {'a': 1, 'b': 2},
        avgLength: 30.5,
        avgWeight: 2.3,
      );

      const stats2 = LocationStats(
        totalCatches: 10,
        releaseCount: 7,
        keepCount: 3,
        speciesDistribution: {'a': 1, 'b': 2},
        avgLength: 30.5,
        avgWeight: 2.3,
      );

      expect(stats1, equals(stats2));
    });

    test('different map values are not equal', () {
      const stats1 = LocationStats(
        totalCatches: 10,
        releaseCount: 7,
        keepCount: 3,
        speciesDistribution: {'a': 1, 'b': 2},
        avgLength: 30.5,
        avgWeight: 2.3,
      );

      const stats2 = LocationStats(
        totalCatches: 10,
        releaseCount: 7,
        keepCount: 3,
        speciesDistribution: {'a': 1, 'b': 3},
        avgLength: 30.5,
        avgWeight: 2.3,
      );

      expect(stats1, isNot(equals(stats2)));
    });

    test('different map lengths are not equal', () {
      const stats1 = LocationStats(
        totalCatches: 10,
        releaseCount: 7,
        keepCount: 3,
        speciesDistribution: {'a': 1},
        avgLength: 30.5,
        avgWeight: 2.3,
      );

      const stats2 = LocationStats(
        totalCatches: 10,
        releaseCount: 7,
        keepCount: 3,
        speciesDistribution: {'a': 1, 'b': 2},
        avgLength: 30.5,
        avgWeight: 2.3,
      );

      expect(stats1, isNot(equals(stats2)));
    });

    test('same map values different order are equal', () {
      const stats1 = LocationStats(
        totalCatches: 10,
        releaseCount: 7,
        keepCount: 3,
        speciesDistribution: {'a': 1, 'b': 2},
        avgLength: 30.5,
        avgWeight: 2.3,
      );

      const stats2 = LocationStats(
        totalCatches: 10,
        releaseCount: 7,
        keepCount: 3,
        speciesDistribution: {'b': 2, 'a': 1},
        avgLength: 30.5,
        avgWeight: 2.3,
      );

      expect(stats1, equals(stats2));
    });
  });
}
