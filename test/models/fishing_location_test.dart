import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/fishing_location.dart';

void main() {
  group('FishingLocation', () {
    group('fromMap', () {
      test('with all fields parses correctly', () {
        final map = {
          'id': 1,
          'name': 'Lake Michigan',
          'latitude': 41.8781,
          'longitude': -87.6298,
          'last_visit': '2024-06-15T14:30:00.000',
          'fish_count': 25,
          'created_at': '2024-01-01T00:00:00.000',
        };

        final result = FishingLocation.fromMap(map);

        expect(result.id, equals(1));
        expect(result.name, equals('Lake Michigan'));
        expect(result.latitude, equals(41.8781));
        expect(result.longitude, equals(-87.6298));
        expect(result.lastVisit, equals(DateTime(2024, 6, 15, 14, 30)));
        expect(result.fishCount, equals(25));
        expect(result.createdAt, equals(DateTime(2024, 1, 1)));
      });

      test('with nullable latitude and longitude parses correctly', () {
        final map = {
          'id': 2,
          'name': 'Secret Spot',
          'latitude': null,
          'longitude': null,
          'last_visit': null,
          'fish_count': 0,
          'created_at': '2024-03-10T00:00:00.000',
        };

        final result = FishingLocation.fromMap(map);

        expect(result.id, equals(2));
        expect(result.name, equals('Secret Spot'));
        expect(result.latitude, isNull);
        expect(result.longitude, isNull);
        expect(result.lastVisit, isNull);
        expect(result.fishCount, equals(0));
      });

      test('with missing last_visit parses as null', () {
        final map = {
          'id': 3,
          'name': 'River Bend',
          'latitude': 35.5,
          'longitude': 139.5,
          'fish_count': 10,
          'created_at': '2024-05-20T00:00:00.000',
        };

        final result = FishingLocation.fromMap(map);

        expect(result.lastVisit, isNull);
      });

      test('with missing fish_count uses default 0', () {
        final map = {
          'id': 4,
          'name': 'Pond',
          'latitude': 40.0,
          'longitude': -75.0,
          'created_at': '2024-07-01T00:00:00.000',
        };

        final result = FishingLocation.fromMap(map);

        expect(result.fishCount, equals(0));
      });

      test('with integer latitude converts to double', () {
        final map = {
          'id': 5,
          'name': 'Test Lake',
          'latitude': 42,
          'longitude': -88,
          'fish_count': 5,
          'created_at': '2024-08-01T00:00:00.000',
        };

        final result = FishingLocation.fromMap(map);

        expect(result.latitude, equals(42.0));
        expect(result.longitude, equals(-88.0));
      });
    });

    group('toMap', () {
      test('outputs correct map structure', () {
        final location = FishingLocation(
          id: 1,
          name: 'Lake Michigan',
          latitude: 41.8781,
          longitude: -87.6298,
          lastVisit: DateTime(2024, 6, 15, 14, 30),
          fishCount: 25,
          createdAt: DateTime(2024, 1, 1),
        );

        final map = location.toMap();

        expect(map['id'], equals(1));
        expect(map['name'], equals('Lake Michigan'));
        expect(map['latitude'], equals(41.8781));
        expect(map['longitude'], equals(-87.6298));
        expect(map['last_visit'], equals('2024-06-15T14:30:00.000'));
        expect(map['fish_count'], equals(25));
        expect(map['created_at'], equals('2024-01-01T00:00:00.000'));
      });

      test('with null lastVisit outputs null in map', () {
        final location = FishingLocation(
          id: 2,
          name: 'Pond',
          latitude: 35.0,
          longitude: 140.0,
          lastVisit: null,
          fishCount: 0,
          createdAt: DateTime(2024, 3, 1),
        );

        final map = location.toMap();

        expect(map['last_visit'], isNull);
      });

      test('toMap output can be round-tripped through fromMap', () {
        final original = FishingLocation(
          id: 10,
          name: 'Mountain Lake',
          latitude: 45.1234,
          longitude: -110.5678,
          lastVisit: DateTime(2024, 12, 25, 8, 15),
          fishCount: 42,
          createdAt: DateTime(2024, 1, 15),
        );

        final map = original.toMap();
        final restored = FishingLocation.fromMap(map);

        expect(restored.id, equals(original.id));
        expect(restored.name, equals(original.name));
        expect(restored.latitude, equals(original.latitude));
        expect(restored.longitude, equals(original.longitude));
        expect(restored.lastVisit, equals(original.lastVisit));
        expect(restored.fishCount, equals(original.fishCount));
        expect(restored.createdAt, equals(original.createdAt));
      });
    });

    group('copyWith', () {
      test('preserves unmodified fields', () {
        final original = FishingLocation(
          id: 1,
          name: 'Lake',
          latitude: 41.0,
          longitude: -87.0,
          lastVisit: DateTime(2024, 6, 1),
          fishCount: 10,
          createdAt: DateTime(2024, 1, 1),
        );

        final copy = original.copyWith(fishCount: 20);

        expect(copy.id, equals(original.id));
        expect(copy.name, equals(original.name));
        expect(copy.latitude, equals(original.latitude));
        expect(copy.longitude, equals(original.longitude));
        expect(copy.lastVisit, equals(original.lastVisit));
        expect(copy.fishCount, equals(20));
        expect(copy.createdAt, equals(original.createdAt));
      });

      test('multiple modified fields preserve others', () {
        final original = FishingLocation(
          id: 1,
          name: 'Old Name',
          latitude: 41.0,
          longitude: -87.0,
          lastVisit: DateTime(2024, 6, 1),
          fishCount: 10,
          createdAt: DateTime(2024, 1, 1),
        );

        final copy = original.copyWith(
          name: 'New Name',
          fishCount: 50,
          lastVisit: () => DateTime(2024, 12, 25),
        );

        expect(copy.id, equals(original.id));
        expect(copy.name, equals('New Name'));
        expect(copy.latitude, equals(original.latitude));
        expect(copy.fishCount, equals(50));
        expect(copy.lastVisit, equals(DateTime(2024, 12, 25)));
      });

      test('copyWith returns new instance', () {
        final original = FishingLocation(
          id: 1,
          name: 'Lake',
          latitude: 41.0,
          longitude: -87.0,
          fishCount: 10,
          createdAt: DateTime(2024),
        );

        final copy = original.copyWith(fishCount: 20);

        expect(original.fishCount, equals(10));
        expect(copy.fishCount, equals(20));
        expect(identical(original, copy), isFalse);
      });
    });

    group('hasCoordinates', () {
      test('returns true when both latitude and longitude are present', () {
        final location = FishingLocation(
          id: 1,
          name: 'Lake',
          latitude: 41.0,
          longitude: -87.0,
          createdAt: DateTime(2024),
        );

        expect(location.hasCoordinates, isTrue);
      });

      test('returns false when latitude is null', () {
        final location = FishingLocation(
          id: 1,
          name: 'Lake',
          latitude: null,
          longitude: -87.0,
          createdAt: DateTime(2024),
        );

        expect(location.hasCoordinates, isFalse);
      });

      test('returns false when longitude is null', () {
        final location = FishingLocation(
          id: 1,
          name: 'Lake',
          latitude: 41.0,
          longitude: null,
          createdAt: DateTime(2024),
        );

        expect(location.hasCoordinates, isFalse);
      });

      test('returns false when both are null', () {
        final location = FishingLocation(
          id: 1,
          name: 'Lake',
          latitude: null,
          longitude: null,
          createdAt: DateTime(2024),
        );

        expect(location.hasCoordinates, isFalse);
      });
    });

    group('coordinateString', () {
      test('returns formatted string when coordinates present', () {
        final location = FishingLocation(
          id: 1,
          name: 'Lake',
          latitude: 41.878100,
          longitude: -87.629800,
          createdAt: DateTime(2024),
        );

        expect(location.coordinateString, equals('41.8781, -87.6298'));
      });

      test('returns empty string when latitude is null', () {
        final location = FishingLocation(
          id: 1,
          name: 'Lake',
          latitude: null,
          longitude: -87.0,
          createdAt: DateTime(2024),
        );

        expect(location.coordinateString, equals(''));
      });

      test('returns empty string when longitude is null', () {
        final location = FishingLocation(
          id: 1,
          name: 'Lake',
          latitude: 41.0,
          longitude: null,
          createdAt: DateTime(2024),
        );

        expect(location.coordinateString, equals(''));
      });

      test('returns empty string when both are null', () {
        final location = FishingLocation(
          id: 1,
          name: 'Lake',
          latitude: null,
          longitude: null,
          createdAt: DateTime(2024),
        );

        expect(location.coordinateString, equals(''));
      });

      test('truncates to 4 decimal places', () {
        final location = FishingLocation(
          id: 1,
          name: 'Precise Lake',
          latitude: 41.878123456789,
          longitude: -87.629876543210,
          createdAt: DateTime(2024),
        );

        expect(location.coordinateString, equals('41.8781, -87.6299'));
      });
    });

    group('equality', () {
      test('based on id only', () {
        final location1 = FishingLocation(
          id: 1,
          name: 'Lake',
          latitude: 41.0,
          longitude: -87.0,
          fishCount: 10,
          createdAt: DateTime(2024),
        );

        final location2 = FishingLocation(
          id: 1,
          name: 'Different Name',
          latitude: 99.0,
          longitude: 99.0,
          fishCount: 999,
          createdAt: DateTime(2020),
        );

        expect(location1, equals(location2));
      });

      test('different id means not equal', () {
        final location1 = FishingLocation(
          id: 1,
          name: 'Lake',
          createdAt: DateTime(2024),
        );

        final location2 = FishingLocation(
          id: 2,
          name: 'Lake',
          createdAt: DateTime(2024),
        );

        expect(location1, isNot(equals(location2)));
      });

      test('hashCode based on id', () {
        final location1 = FishingLocation(
          id: 42,
          name: 'Lake A',
          latitude: 41.0,
          longitude: -87.0,
          createdAt: DateTime(2024),
        );

        final location2 = FishingLocation(
          id: 42,
          name: 'Lake B Totally Different',
          latitude: 99.0,
          longitude: -99.0,
          createdAt: DateTime(2020),
        );

        expect(location1.hashCode, equals(location2.hashCode));
      });
    });

    group('FishingLocationListExtension', () {
      late List<FishingLocation> locations;

      setUp(() {
        locations = [
          FishingLocation(
            id: 1,
            name: 'Zebra Lake',
            latitude: 40.0,
            longitude: -80.0,
            lastVisit: DateTime(2024, 3, 1),
            fishCount: 5,
            createdAt: DateTime(2024, 1, 1),
          ),
          FishingLocation(
            id: 2,
            name: 'Alpha River',
            latitude: 41.0,
            longitude: -81.0,
            lastVisit: DateTime(2024, 6, 15),
            fishCount: 20,
            createdAt: DateTime(2024, 2, 1),
          ),
          FishingLocation(
            id: 3,
            name: 'Beta Bay',
            latitude: 42.0,
            longitude: -82.0,
            lastVisit: DateTime(2024, 1, 10),
            fishCount: 15,
            createdAt: DateTime(2024, 3, 1),
          ),
          FishingLocation(
            id: 4,
            name: 'Gamma Gulf',
            latitude: 43.0,
            longitude: -83.0,
            lastVisit: null,
            fishCount: 8,
            createdAt: DateTime(2024, 4, 1),
          ),
        ];
      });

      group('sortedByFishCount', () {
        test('sorts by fishCount descending', () {
          final sorted = locations.sortedByFishCount();

          expect(sorted[0].fishCount, equals(20));
          expect(sorted[1].fishCount, equals(15));
          expect(sorted[2].fishCount, equals(8));
          expect(sorted[3].fishCount, equals(5));
        });

        test('does not modify original list', () {
          final firstId = locations[0].id;
          locations.sortedByFishCount();
          expect(locations[0].id, equals(firstId));
        });

        test('returns new list instance', () {
          final sorted = locations.sortedByFishCount();
          expect(identical(sorted, locations), isFalse);
        });
      });

      group('sortedByName', () {
        test('sorts alphabetically ascending', () {
          final sorted = locations.sortedByName();

          expect(sorted[0].name, equals('Alpha River'));
          expect(sorted[1].name, equals('Beta Bay'));
          expect(sorted[2].name, equals('Gamma Gulf'));
          expect(sorted[3].name, equals('Zebra Lake'));
        });

        test('does not modify original list', () {
          final firstId = locations[0].id;
          locations.sortedByName();
          expect(locations[0].id, equals(firstId));
        });
      });

      group('sortedByLastVisit', () {
        test('sorts by lastVisit descending with nulls last', () {
          final sorted = locations.sortedByLastVisit();

          expect(sorted[0].lastVisit, equals(DateTime(2024, 6, 15)));
          expect(sorted[1].lastVisit, equals(DateTime(2024, 3, 1)));
          expect(sorted[2].lastVisit, equals(DateTime(2024, 1, 10)));
          expect(sorted[3].lastVisit, isNull);
        });

        test('places null lastVisit at end', () {
          final sorted = locations.sortedByLastVisit();

          expect(sorted.last.lastVisit, isNull);
        });

        test('does not modify original list', () {
          final firstId = locations[0].id;
          locations.sortedByLastVisit();
          expect(locations[0].id, equals(firstId));
        });

        test('handles list with all null lastVisit', () {
          final allNull = [
            FishingLocation(
              id: 1,
              name: 'A',
              lastVisit: null,
              createdAt: DateTime(2024),
            ),
            FishingLocation(
              id: 2,
              name: 'B',
              lastVisit: null,
              createdAt: DateTime(2024),
            ),
          ];

          final sorted = allNull.sortedByLastVisit();

          expect(sorted.length, equals(2));
          expect(sorted[0].lastVisit, isNull);
          expect(sorted[1].lastVisit, isNull);
        });
      });

      group('findByName', () {
        test('returns matching location', () {
          final found = locations.findByName('Alpha River');

          expect(found, isNotNull);
          expect(found!.id, equals(2));
        });

        test('returns null when not found', () {
          final found = locations.findByName('Non Existent');

          expect(found, isNull);
        });

        test('returns first match when duplicates exist', () {
          final withDuplicates = [
            FishingLocation(
              id: 1,
              name: 'Lake',
              latitude: 40.0,
              longitude: -80.0,
              createdAt: DateTime(2024),
            ),
            FishingLocation(
              id: 2,
              name: 'Lake',
              latitude: 41.0,
              longitude: -81.0,
              createdAt: DateTime(2024),
            ),
          ];

          final found = withDuplicates.findByName('Lake');

          expect(found, isNotNull);
          expect(found!.id, equals(1));
        });

        test('is case sensitive', () {
          final found = locations.findByName('alpha river');

          expect(found, isNull);
        });
      });
    });

    group('toString', () {
      test('contains id name and fishCount', () {
        final location = FishingLocation(
          id: 7,
          name: 'Catfish Creek',
          fishCount: 33,
          createdAt: DateTime(2024),
        );

        final str = location.toString();

        expect(str, contains('FishingLocation'));
        expect(str, contains('id: 7'));
        expect(str, contains('name: Catfish Creek'));
        expect(str, contains('fishCount: 33'));
      });
    });
  });
}
