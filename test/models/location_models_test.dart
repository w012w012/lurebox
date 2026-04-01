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

    test('toMap converts LocationWithStats to map', () {
      final map = testInstance.toMap();

      expect(map['location_name'], equals('Test Lake'));
      expect(map['latitude'], equals(35.0));
      expect(map['longitude'], equals(139.0));
      expect(map['fish_count'], equals(10));
      expect(map['last_catch_time'], equals('2024-01-15T00:00:00.000'));
    });

    test('copyWith creates modified copy', () {
      final copy = testInstance.copyWith(name: 'New Lake', fishCount: 20);

      expect(copy.name, equals('New Lake'));
      expect(copy.fishCount, equals(20));
      expect(copy.latitude, equals(35.0));
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

    test('hashCode based on name, latitude, and longitude', () {
      final other = LocationWithStats(
        name: 'Test Lake',
        latitude: 35.0,
        longitude: 139.0,
        fishCount: 999,
      );

      expect(testInstance.hashCode, equals(other.hashCode));
    });
  });

  group('LocationStats', () {
    test('creates LocationStats with required fields', () {
      final stats = LocationStats(
        totalCatches: 10,
        releaseCount: 7,
        keepCount: 3,
        speciesDistribution: {'Bass': 5, 'Trout': 5},
        avgLength: 30.5,
        avgWeight: 2.3,
      );

      expect(stats.totalCatches, equals(10));
      expect(stats.releaseCount, equals(7));
      expect(stats.keepCount, equals(3));
      expect(stats.speciesDistribution['Bass'], equals(5));
      expect(stats.avgLength, equals(30.5));
    });

    test('releaseRate calculates correctly', () {
      final stats1 = LocationStats(
        totalCatches: 10,
        releaseCount: 7,
        keepCount: 3,
        speciesDistribution: {},
      );

      expect(stats1.releaseRate, closeTo(0.7, 0.001));

      final stats2 = LocationStats(
        totalCatches: 0,
        releaseCount: 0,
        keepCount: 0,
        speciesDistribution: {},
      );

      expect(stats2.releaseRate, equals(0.0));
    });
  });
}
