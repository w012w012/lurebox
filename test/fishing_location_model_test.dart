import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/fishing_location.dart';

void main() {
  group('FishingLocation', () {
    late FishingLocation testLocation;

    setUp(() {
      testLocation = FishingLocation(
        id: 1,
        name: 'Lake Michigan',
        latitude: 41.8781,
        longitude: -87.6298,
        lastVisit: DateTime(2024, 1, 15, 10, 30),
        fishCount: 25,
        createdAt: DateTime(2024, 1, 1),
      );
    });

    test('creates FishingLocation with required fields', () {
      expect(testLocation.id, 1);
      expect(testLocation.name, 'Lake Michigan');
      expect(testLocation.latitude, 41.8781);
      expect(testLocation.longitude, -87.6298);
      expect(testLocation.lastVisit, DateTime(2024, 1, 15, 10, 30));
      expect(testLocation.fishCount, 25);
      expect(testLocation.createdAt, DateTime(2024, 1, 1));
    });

    test('fromMap creates FishingLocation from map', () {
      final map = {
        'id': 1,
        'name': 'Lake Michigan',
        'latitude': 41.8781,
        'longitude': -87.6298,
        'last_visit': '2024-01-15T10:30:00.000',
        'fish_count': 25,
        'created_at': '2024-01-01T00:00:00.000',
      };
      final location = FishingLocation.fromMap(map);

      expect(location.id, 1);
      expect(location.name, 'Lake Michigan');
      expect(location.latitude, 41.8781);
      expect(location.longitude, -87.6298);
      expect(location.lastVisit, DateTime(2024, 1, 15, 10, 30));
      expect(location.fishCount, 25);
      expect(location.createdAt, DateTime(2024, 1, 1));
    });

    test('fromMap handles null coordinates', () {
      final map = {
        'id': 2,
        'name': 'Pond',
        'latitude': null,
        'longitude': null,
        'last_visit': null,
        'fish_count': 10,
        'created_at': '2024-01-01T00:00:00.000',
      };
      final location = FishingLocation.fromMap(map);

      expect(location.latitude, null);
      expect(location.longitude, null);
      expect(location.lastVisit, null);
      expect(location.fishCount, 10);
    });

    test('toMap converts FishingLocation to map', () {
      final map = testLocation.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'Lake Michigan');
      expect(map['latitude'], 41.8781);
      expect(map['longitude'], -87.6298);
      expect(map['last_visit'], testLocation.lastVisit?.toIso8601String());
      expect(map['fish_count'], 25);
      expect(map['created_at'], testLocation.createdAt.toIso8601String());
    });

    test('copyWith creates modified copy', () {
      final modified = testLocation.copyWith(name: 'New Lake', fishCount: 50);

      expect(modified.name, 'New Lake');
      expect(modified.fishCount, 50);
      expect(modified.id, testLocation.id);
      expect(modified.latitude, testLocation.latitude);
    });

    test('copyWith can set null values', () {
      final modified = testLocation.copyWith(
        latitude: () => null,
        longitude: () => null,
      );

      expect(modified.latitude, null);
      expect(modified.longitude, null);
    });

    test('hasCoordinates returns true when both coordinates exist', () {
      expect(testLocation.hasCoordinates, true);
    });

    test('hasCoordinates returns false when coordinates are null', () {
      final location = FishingLocation(
        id: 1,
        name: 'Pond',
        createdAt: DateTime.now(),
      );

      expect(location.hasCoordinates, false);
    });

    test('hasCoordinates returns false when only one coordinate exists', () {
      final location = FishingLocation(
        id: 1,
        name: 'Pond',
        latitude: 41.0,
        createdAt: DateTime.now(),
      );

      expect(location.hasCoordinates, false);
    });

    test('coordinateString returns formatted string', () {
      expect(testLocation.coordinateString, '41.8781, -87.6298');
    });

    test('coordinateString returns empty string when no coordinates', () {
      final location = FishingLocation(
        id: 1,
        name: 'Pond',
        createdAt: DateTime.now(),
      );

      expect(location.coordinateString, '');
    });

    test('equality based on id', () {
      final location2 = testLocation.copyWith(name: 'Different Name');

      expect(testLocation == location2, true);
    });

    test('different ids are not equal', () {
      final location2 = FishingLocation(
        id: 2,
        name: 'Lake Michigan',
        createdAt: DateTime.now(),
      );

      expect(testLocation == location2, false);
    });

    test('hashCode based on id', () {
      expect(testLocation.hashCode, 1.hashCode);
    });

    test('toString returns expected format', () {
      expect(
        testLocation.toString(),
        'FishingLocation(id: 1, name: Lake Michigan, fishCount: 25)',
      );
    });
  });

  group('FishingLocation List Extensions', () {
    late List<FishingLocation> locations;

    setUp(() {
      locations = [
        FishingLocation(
          id: 1,
          name: 'Lake Michigan',
          fishCount: 25,
          lastVisit: DateTime(2024, 1, 15),
          createdAt: DateTime(2024, 1, 1),
        ),
        FishingLocation(
          id: 2,
          name: 'Lake Superior',
          fishCount: 50,
          lastVisit: DateTime(2024, 2, 1),
          createdAt: DateTime(2024, 1, 1),
        ),
        FishingLocation(
          id: 3,
          name: 'Lake Erie',
          fishCount: 10,
          lastVisit: DateTime(2024, 1, 1),
          createdAt: DateTime(2024, 1, 1),
        ),
      ];
    });

    test('sortedByFishCount sorts descending', () {
      final sorted = locations.sortedByFishCount();

      expect(sorted[0].name, 'Lake Superior');
      expect(sorted[1].name, 'Lake Michigan');
      expect(sorted[2].name, 'Lake Erie');
    });

    test('sortedByName sorts alphabetically', () {
      final sorted = locations.sortedByName();

      expect(sorted[0].name, 'Lake Erie');
      expect(sorted[1].name, 'Lake Michigan');
      expect(sorted[2].name, 'Lake Superior');
    });

    test('sortedByLastVisit sorts descending', () {
      final sorted = locations.sortedByLastVisit();

      expect(sorted[0].name, 'Lake Superior');
      expect(sorted[1].name, 'Lake Michigan');
      expect(sorted[2].name, 'Lake Erie');
    });

    test('sortedByLastVisit puts null lastVisit last', () {
      final locationsWithNull = [
        FishingLocation(id: 1, name: 'Lake A', createdAt: DateTime.now()),
        FishingLocation(
          id: 2,
          name: 'Lake B',
          lastVisit: DateTime(2024, 1, 1),
          createdAt: DateTime.now(),
        ),
      ];

      final sorted = locationsWithNull.sortedByLastVisit();

      expect(sorted[0].name, 'Lake B');
      expect(sorted[1].name, 'Lake A');
    });

    test('findByName returns matching location', () {
      final found = locations.findByName('Lake Michigan');

      expect(found, isNotNull);
      expect(found!.name, 'Lake Michigan');
    });

    test('findByName returns null when not found', () {
      final found = locations.findByName('Nonexistent Lake');

      expect(found, isNull);
    });

    test('findByName is case sensitive', () {
      final found = locations.findByName('lake michigan');

      expect(found, isNull);
    });
  });
}
