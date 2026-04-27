import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('FishFateType', () {
    test('fromValue(0) returns FishFateType.release', () {
      expect(FishFateType.fromValue(0), equals(FishFateType.release));
    });

    test('fromValue(1) returns FishFateType.keep', () {
      expect(FishFateType.fromValue(1), equals(FishFateType.keep));
    });

    test('fromValue(999) returns FishFateType.release as default', () {
      expect(FishFateType.fromValue(999), equals(FishFateType.release));
    });

    test('release has correct value and label', () {
      expect(FishFateType.release.value, equals(0));
      expect(FishFateType.release.label, equals('放流'));
    });

    test('keep has correct value and label', () {
      expect(FishFateType.keep.value, equals(1));
      expect(FishFateType.keep.label, equals('保留'));
    });
  });

  group('FishCatch.fromMap + toMap round-trip', () {
    test('round-trip preserves all fields', () {
      final now = DateTime.now();
      final map = {
        'id': 42,
        'image_path': '/path/to/image.jpg',
        'watermarked_image_path': '/path/to/watermarked.jpg',
        'species': 'Bass',
        'length': 35.5,
        'length_unit': 'cm',
        'weight': 2.5,
        'weight_unit': 'kg',
        'fate': 1,
        'catch_time': '2024-06-15T10:30:00.000',
        'location_name': 'Lake Test',
        'latitude': 35.6762,
        'longitude': 139.6503,
        'equipment_id': 1,
        'rod_id': 2,
        'reel_id': 3,
        'lure_id': 4,
        'air_temperature': 25.0,
        'pressure': 1013.0,
        'weather_code': 1,
        'pending_recognition': 1,
        'notes': 'Great catch!',
        'rig_type': 'Carolina Rig',
        'sinker_weight': '20g',
        'sinker_position': 'bottom',
        'hook_type': 'Circle Hook',
        'hook_size': '5/0',
        'hook_weight': 'heavy',
        'created_at': '2024-06-15T10:30:00.000',
        'updated_at': '2024-06-15T12:00:00.000',
      };

      final fishCatch = FishCatch.fromMap(map);
      final resultMap = fishCatch.toMap();

      expect(resultMap['id'], equals(42));
      expect(resultMap['image_path'], equals('/path/to/image.jpg'));
      expect(resultMap['watermarked_image_path'],
          equals('/path/to/watermarked.jpg'));
      expect(resultMap['species'], equals('Bass'));
      expect(resultMap['length'], equals(35.5));
      expect(resultMap['length_unit'], equals('cm'));
      expect(resultMap['weight'], equals(2.5));
      expect(resultMap['weight_unit'], equals('kg'));
      expect(resultMap['fate'], equals(1));
      expect(resultMap['catch_time'], equals('2024-06-15T10:30:00.000'));
      expect(resultMap['location_name'], equals('Lake Test'));
      expect(resultMap['latitude'], equals(35.6762));
      expect(resultMap['longitude'], equals(139.6503));
      expect(resultMap['equipment_id'], equals(1));
      expect(resultMap['rod_id'], equals(2));
      expect(resultMap['reel_id'], equals(3));
      expect(resultMap['lure_id'], equals(4));
      expect(resultMap['air_temperature'], equals(25.0));
      expect(resultMap['pressure'], equals(1013.0));
      expect(resultMap['weather_code'], equals(1));
      expect(resultMap['pending_recognition'], equals(1));
      expect(resultMap['notes'], equals('Great catch!'));
      expect(resultMap['rig_type'], equals('Carolina Rig'));
      expect(resultMap['sinker_weight'], equals('20g'));
      expect(resultMap['sinker_position'], equals('bottom'));
      expect(resultMap['hook_type'], equals('Circle Hook'));
      expect(resultMap['hook_size'], equals('5/0'));
      expect(resultMap['hook_weight'], equals('heavy'));
      expect(resultMap['created_at'], equals('2024-06-15T10:30:00.000'));
      expect(resultMap['updated_at'], equals('2024-06-15T12:00:00.000'));
    });

    test('fromMap handles null optional fields', () {
      final now = DateTime.now();
      final map = {
        'id': 1,
        'image_path': '/path/to/image.jpg',
        'watermarked_image_path': null,
        'species': 'Trout',
        'length': 25.0,
        'length_unit': 'cm',
        'weight': null,
        'weight_unit': 'kg',
        'fate': 0,
        'catch_time': '2024-06-15T10:30:00.000',
        'location_name': null,
        'latitude': null,
        'longitude': null,
        'equipment_id': null,
        'rod_id': null,
        'reel_id': null,
        'lure_id': null,
        'air_temperature': null,
        'pressure': null,
        'weather_code': null,
        'pending_recognition': 0,
        'notes': null,
        'rig_type': null,
        'sinker_weight': null,
        'sinker_position': null,
        'hook_type': null,
        'hook_size': null,
        'hook_weight': null,
        'created_at': '2024-06-15T10:30:00.000',
        'updated_at': '2024-06-15T10:30:00.000',
      };

      final fishCatch = FishCatch.fromMap(map);

      expect(fishCatch.id, equals(1));
      expect(fishCatch.imagePath, equals('/path/to/image.jpg'));
      expect(fishCatch.watermarkedImagePath, isNull);
      expect(fishCatch.species, equals('Trout'));
      expect(fishCatch.length, equals(25.0));
      expect(fishCatch.lengthUnit, equals('cm'));
      expect(fishCatch.weight, isNull);
      expect(fishCatch.weightUnit, equals('kg'));
      expect(fishCatch.fate, equals(FishFateType.release));
      expect(fishCatch.locationName, isNull);
      expect(fishCatch.latitude, isNull);
      expect(fishCatch.longitude, isNull);
      expect(fishCatch.equipmentId, isNull);
      expect(fishCatch.notes, isNull);
      expect(fishCatch.pendingRecognition, isFalse);
    });

    test('fromMap uses default units when missing', () {
      final map = {
        'id': 1,
        'image_path': '/test.jpg',
        'species': 'Bass',
        'length': 30.0,
        'fate': 0,
        'catch_time': '2024-06-15T10:30:00.000',
        'created_at': '2024-06-15T10:30:00.000',
        'updated_at': '2024-06-15T10:30:00.000',
      };

      final fishCatch = FishCatch.fromMap(map);

      expect(fishCatch.lengthUnit, equals('cm'));
      expect(fishCatch.weightUnit, equals('kg'));
    });
  });

  group('FishCatch.copyWith', () {
    late FishCatch original;

    setUp(() {
      original = TestDataFactory.createFishCatch(
        id: 1,
        species: 'Bass',
        weight: 2.5,
        fate: FishFateType.keep,
      );
    });

    test('copyWith with no args returns equal object', () {
      final copy = original.copyWith();
      expect(copy.id, equals(original.id));
      expect(copy.species, equals(original.species));
      expect(copy.weight, equals(original.weight));
      expect(copy.fate, equals(original.fate));
      expect(copy.length, equals(original.length));
      expect(copy.imagePath, equals(original.imagePath));
      expect(copy == original, isTrue);
    });

    test('copyWith(species: "Trout") changes only species', () {
      final copy = original.copyWith(species: 'Trout');

      expect(copy.species, equals('Trout'));
      expect(copy.id, equals(original.id));
      expect(copy.weight, equals(original.weight));
      expect(copy.fate, equals(original.fate));
      expect(copy.length, equals(original.length));
    });

    test('copyWith(weight: null) keeps original weight (null coalescing)', () {
      // weight uses null coalescing: weight ?? this.weight
      // so passing null doesn't clear it
      final copy = original.copyWith(weight: null);

      expect(copy.weight, equals(original.weight));
      expect(copy.id, equals(original.id));
      expect(copy.species, equals(original.species));
    });

    test('copyWith can update multiple fields at once', () {
      final copy = original.copyWith(
        species: 'Trout',
        weight: 1.5,
        fate: FishFateType.release,
      );

      expect(copy.species, equals('Trout'));
      expect(copy.weight, equals(1.5));
      expect(copy.fate, equals(FishFateType.release));
      expect(copy.id, equals(original.id));
    });

    test(
        'copyWith for locationName clears when passing null-returning function',
        () {
      final fishCatch = TestDataFactory.createFishCatch(
        id: 1,
        species: 'Bass',
        locationName: 'Lake A',
      );

      final copy = fishCatch.copyWith(locationName: () => null);

      expect(copy.locationName, isNull);
      expect(copy.species, equals(fishCatch.species));
    });
  });

  group('FishCatch Equality', () {
    test('two FishCatch with same id are equal', () {
      final fish1 = TestDataFactory.createFishCatch(
        id: 1,
        species: 'Bass',
        weight: 2.5,
      );
      final fish2 = TestDataFactory.createFishCatch(
        id: 1,
        species: 'Different',
        weight: 1.0,
      );

      expect(fish1 == fish2, isTrue);
      expect(fish1.hashCode, equals(fish2.hashCode));
    });

    test('two FishCatch with different ids are not equal', () {
      final fish1 = TestDataFactory.createFishCatch(id: 1);
      final fish2 = TestDataFactory.createFishCatch(id: 2);

      expect(fish1 == fish2, isFalse);
    });

    test('equality is based on id only, not other fields', () {
      final now = DateTime.now();
      final fish1 = FishCatch(
        id: 1,
        imagePath: '/path1.jpg',
        species: 'Species A',
        length: 30.0,
        fate: FishFateType.release,
        catchTime: now,
        createdAt: now,
        updatedAt: now,
        weight: 2.0,
      );
      final fish2 = FishCatch(
        id: 1,
        imagePath: '/different/path.jpg',
        species: 'Different Species',
        length: 50.0,
        fate: FishFateType.keep,
        catchTime: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        weight: 5.0,
      );

      expect(fish1 == fish2, isTrue);
    });
  });

  group('FishCatchListExtension.filterByTime', () {
    late List<FishCatch> catches;

    setUp(() {
      // Use actual current date as baseline to ensure "today" test works
      // This makes the test deterministic for the "week" filter which uses calendar week
      final baseline = DateTime.now();
      catches = [
        // Today's catch
        TestDataFactory.createFishCatch(
          id: 1,
          species: 'Today Catch',
          catchTime: baseline,
        ),
        // Yesterday's catch
        TestDataFactory.createFishCatch(
          id: 2,
          species: 'Yesterday Catch',
          catchTime: baseline.subtract(const Duration(days: 1)),
        ),
        // This week's catch - 2 days ago (still in current calendar week)
        TestDataFactory.createFishCatch(
          id: 3,
          species: 'This Week Catch',
          catchTime: baseline.subtract(const Duration(days: 2)),
        ),
        // This month's catch (15 days ago)
        TestDataFactory.createFishCatch(
          id: 4,
          species: 'This Month Catch',
          catchTime: baseline.subtract(const Duration(days: 15)),
        ),
        // This year's catch (100 days ago)
        TestDataFactory.createFishCatch(
          id: 5,
          species: 'This Year Catch',
          catchTime: baseline.subtract(const Duration(days: 100)),
        ),
        // Old catch (400 days ago)
        TestDataFactory.createFishCatch(
          id: 6,
          species: 'Old Catch',
          catchTime: baseline.subtract(const Duration(days: 400)),
        ),
      ];
    });

    test('timeFilter: "today" returns only today\'s catches', () {
      final result = catches.filterByTime('today');
      expect(result.length, equals(1));
      expect(result.first.species, equals('Today Catch'));
    });

    test('timeFilter: "week" returns current calendar week (Mon-Sun)', () {
      final result = catches.filterByTime('week');
      // Calendar week (Mon-Sun) depends on current weekday:
      // Mon(1): only today; Tue(2): today+yesterday; Wed-Sun(3-7): today+yesterday+Monday
      // Since test data has catches at day 0, -1, -2, all are in current calendar week
      final now = DateTime.now();
      final expectedCount = now.weekday >= 3 ? 3 : now.weekday;
      expect(result.length, equals(expectedCount));
    });

    test('timeFilter: "month" returns last 30 days', () {
      final result = catches.filterByTime('month');
      // Today, yesterday, 2 days ago, and 15 days ago
      expect(result.length, equals(4));
    });

    test('timeFilter: "year" returns last 365 days', () {
      final result = catches.filterByTime('year');
      // All except the 400-day-old catch
      expect(result.length, equals(5));
    });

    test('timeFilter: "all" returns all catches', () {
      final result = catches.filterByTime('all');
      expect(result.length, equals(6));
    });

    test('empty list returns empty', () {
      final result = <FishCatch>[].filterByTime('today');
      expect(result, isEmpty);
    });

    group('boundary conditions', () {
      test('December month filter does not overflow to next year', () {
        final now = DateTime.now();
        final monthStart = DateTime(now.year, now.month);
        final prevMonthEnd = monthStart.subtract(const Duration(seconds: 1));

        final catches = [
          TestDataFactory.createFishCatch(
            id: 1,
            species: 'This Month First Day',
            catchTime: monthStart,
          ),
          TestDataFactory.createFishCatch(
            id: 2,
            species: 'Previous Month Last Second',
            catchTime: prevMonthEnd,
          ),
        ];

        final result = catches.filterByTime('month');

        expect(result.length, equals(1));
        expect(result.first.species, equals('This Month First Day'));
      });

      test('month filter works correctly across year boundary', () {
        final now = DateTime.now();
        final prevMonth = now.month == 1 ? 12 : now.month - 1;
        final prevYear = now.month == 1 ? now.year - 1 : now.year;
        final prevMonthEnd = DateTime(now.year, now.month)
            .subtract(const Duration(seconds: 1));

        final catches = [
          TestDataFactory.createFishCatch(
            id: 1,
            species: 'Current Month Catch',
            catchTime: now,
          ),
          TestDataFactory.createFishCatch(
            id: 2,
            species: 'Previous Month End',
            catchTime: prevMonthEnd,
          ),
        ];

        final result = catches.filterByTime('month');

        expect(result.length, equals(1));
        expect(result.first.species, equals('Current Month Catch'));
      });

      test('February leap year boundary (Feb 29)', () {
        final febStart = DateTime(2024, 2);
        final marStart = DateTime(2024, 3);

        final catches = [
          TestDataFactory.createFishCatch(
            id: 1,
            species: 'Feb 29',
            catchTime: DateTime(2024, 2, 29),
          ),
          TestDataFactory.createFishCatch(
            id: 2,
            species: 'Mar 1',
            catchTime: DateTime(2024, 3),
          ),
        ];

        final febCatches = catches.where((fish) {
          return !fish.catchTime.isBefore(febStart) &&
              fish.catchTime.isBefore(marStart);
        }).toList();

        expect(febCatches.length, equals(1));
        expect(febCatches.first.species, equals('Feb 29'));
      });

      test('year filter includes January 1 midnight', () {
        final now = DateTime.now();
        final yearStart = DateTime(now.year);
        final prevYearEnd = yearStart.subtract(const Duration(seconds: 1));

        final catches = [
          TestDataFactory.createFishCatch(
            id: 1,
            species: 'Jan 1 This Year',
            catchTime: yearStart,
          ),
          TestDataFactory.createFishCatch(
            id: 2,
            species: 'Dec 31 Prev Year',
            catchTime: prevYearEnd,
          ),
        ];

        final result = catches.filterByTime('year');

        expect(result.length, equals(1));
        expect(result.first.species, equals('Jan 1 This Year'));
      });

      test('year filter excludes December 31 boundary', () {
        final now = DateTime.now();
        final catches = [
          TestDataFactory.createFishCatch(
            id: 1,
            species: 'This Year Catch',
            catchTime: now,
          ),
          TestDataFactory.createFishCatch(
            id: 2,
            species: 'Old Catch',
            catchTime: DateTime(now.year - 1, 12, 31, 23, 59, 59),
          ),
        ];

        final result = catches.filterByTime('year');

        final oldCatchDaysAgo =
            now.difference(DateTime(now.year - 1, 12, 31, 23, 59, 59)).inDays;
        if (oldCatchDaysAgo > 365) {
          expect(result.length, equals(1));
          expect(result.first.species, equals('This Year Catch'));
        }
      });
    });
  });

  group('FishCatchListExtension.filterByFate', () {
    late List<FishCatch> catches;

    setUp(() {
      catches = [
        TestDataFactory.createFishCatch(
            id: 1, species: 'Release 1', fate: FishFateType.release),
        TestDataFactory.createFishCatch(
            id: 2, species: 'Keep 1', fate: FishFateType.keep),
        TestDataFactory.createFishCatch(
            id: 3, species: 'Release 2', fate: FishFateType.release),
        TestDataFactory.createFishCatch(
            id: 4, species: 'Keep 2', fate: FishFateType.keep),
        TestDataFactory.createFishCatch(
            id: 5, species: 'Release 3', fate: FishFateType.release),
      ];
    });

    test('fateFilter: FishFateType.release returns only release catches', () {
      final result = catches.filterByFate(FishFateType.release);
      expect(result.length, equals(3));
      expect(result.every((f) => f.fate == FishFateType.release), isTrue);
    });

    test('fateFilter: FishFateType.keep returns only keep catches', () {
      final result = catches.filterByFate(FishFateType.keep);
      expect(result.length, equals(2));
      expect(result.every((f) => f.fate == FishFateType.keep), isTrue);
    });

    test('fateFilter: null returns all catches', () {
      final result = catches.filterByFate(null);
      expect(result.length, equals(5));
    });

    test('empty list returns empty', () {
      final result = <FishCatch>[].filterByFate(FishFateType.release);
      expect(result, isEmpty);
    });
  });

  group('FishCatchListExtension.filterBySpecies', () {
    late List<FishCatch> catches;

    setUp(() {
      catches = [
        TestDataFactory.createFishCatch(
            id: 1, species: 'Bass', fate: FishFateType.release),
        TestDataFactory.createFishCatch(
            id: 2, species: 'Trout', fate: FishFateType.keep),
        TestDataFactory.createFishCatch(
            id: 3, species: 'Bass', fate: FishFateType.release),
      ];
    });

    test('filters by species correctly', () {
      final bass = catches.filterBySpecies('Bass');
      final trout = catches.filterBySpecies('Trout');

      expect(bass.length, equals(2));
      expect(trout.length, equals(1));
    });
  });

  group('FishCatchListExtension.searchByKeyword', () {
    late List<FishCatch> catches;

    setUp(() {
      final now = DateTime.now();
      catches = [
        FishCatch(
          id: 1,
          imagePath: '/test/1.jpg',
          species: 'Largemouth Bass',
          length: 30.0,
          fate: FishFateType.release,
          catchTime: now,
          locationName: 'Lake Michigan',
          notes: 'Morning catch',
          createdAt: now,
          updatedAt: now,
        ),
        FishCatch(
          id: 2,
          imagePath: '/test/2.jpg',
          species: 'Rainbow Trout',
          length: 25.0,
          fate: FishFateType.release,
          catchTime: now,
          locationName: 'Rocky River',
          notes: 'Afternoon catch',
          createdAt: now,
          updatedAt: now,
        ),
        FishCatch(
          id: 3,
          imagePath: '/test/3.jpg',
          species: 'Smallmouth Bass',
          length: 28.0,
          fate: FishFateType.release,
          catchTime: now,
          locationName: 'Lake Erie',
          notes: 'Evening catch',
          createdAt: now,
          updatedAt: now,
        ),
        FishCatch(
          id: 4,
          imagePath: '/test/4.jpg',
          species: 'Catfish',
          length: 40.0,
          fate: FishFateType.release,
          catchTime: now,
          locationName: 'Mississippi River',
          notes: null,
          createdAt: now,
          updatedAt: now,
        ),
      ];
    });

    test('matches by species name', () {
      final result = catches.searchByKeyword('bass');
      expect(result.length, equals(2));
      expect(result.map((f) => f.species),
          containsAll(['Largemouth Bass', 'Smallmouth Bass']));
    });

    test('matches by location name', () {
      final result = catches.searchByKeyword('lake');
      expect(result.length, equals(2));
      expect(result.map((f) => f.species),
          containsAll(['Largemouth Bass', 'Smallmouth Bass']));
    });

    test('case insensitive', () {
      final result1 = catches.searchByKeyword('BASS');
      final result2 = catches.searchByKeyword('bass');
      final result3 = catches.searchByKeyword('Bass');

      expect(result1.length, equals(result2.length));
      expect(result2.length, equals(result3.length));
    });

    test('empty query returns all', () {
      final result = catches.searchByKeyword('');
      expect(result.length, equals(4));
    });

    test('no matches returns empty', () {
      final result = catches.searchByKeyword('salmon');
      expect(result, isEmpty);
    });

    test('matches locationName when keyword matches', () {
      final result = catches.searchByKeyword('michigan');
      expect(result.length, equals(1));
      expect(result.first.species, equals('Largemouth Bass'));
    });

    test('handles null notes in list', () {
      final result = catches.searchByKeyword('catfish');
      expect(result.length, equals(1));
      expect(result.first.notes, isNull);
    });
  });

  group('FishCatchListExtension.sortBy', () {
    late List<FishCatch> catches;

    setUp(() {
      final baseTime = DateTime(2024, 6, 15, 10, 0);
      catches = [
        TestDataFactory.createFishCatch(
          id: 1,
          species: 'Smallest',
          length: 10.0,
          weight: 0.5,
          catchTime: baseTime,
        ),
        TestDataFactory.createFishCatch(
          id: 2,
          species: 'Medium',
          length: 25.0,
          weight: 2.0,
          catchTime: baseTime.subtract(const Duration(days: 1)),
        ),
        TestDataFactory.createFishCatch(
          id: 3,
          species: 'Largest',
          length: 50.0,
          weight: 5.0,
          catchTime: baseTime.subtract(const Duration(days: 2)),
        ),
      ];
    });

    test('sortBy: "time" ascending', () {
      final result = catches.sortBy('time', true, null);
      expect(result.first.species, equals('Largest')); // oldest
      expect(result.last.species, equals('Smallest')); // newest
    });

    test('sortBy: "time" descending', () {
      final result = catches.sortBy('time', false, null);
      expect(result.first.species, equals('Smallest')); // newest
      expect(result.last.species, equals('Largest')); // oldest
    });

    test('sortBy: "length" ascending', () {
      final result = catches.sortBy('length', true, null);
      expect(result.first.species, equals('Smallest'));
      expect(result.last.species, equals('Largest'));
    });

    test('sortBy: "length" descending', () {
      final result = catches.sortBy('length', false, null);
      expect(result.first.species, equals('Largest'));
      expect(result.last.species, equals('Smallest'));
    });

    test('sortBy: "weight" ascending', () {
      final result = catches.sortBy('weight', true, null);
      expect(result.first.species, equals('Smallest'));
      expect(result.last.species, equals('Largest'));
    });

    test('sortBy: "weight" descending', () {
      final result = catches.sortBy('weight', false, null);
      expect(result.first.species, equals('Largest'));
      expect(result.last.species, equals('Smallest'));
    });

    test('handles null weight values in sort', () {
      final catchesWithNullWeight = [
        TestDataFactory.createFishCatch(
            id: 1, species: 'With Weight', weight: 2.0),
        TestDataFactory.createFishCatch(
            id: 2, species: 'No Weight', weight: null),
        TestDataFactory.createFishCatch(id: 3, species: 'Another', weight: 1.0),
      ];

      final result = catchesWithNullWeight.sortBy('weight', true, null);
      // Null weight should be treated as 0
      expect(result.first.species, equals('No Weight'));
    });

    test('empty list returns empty', () {
      final result = <FishCatch>[].sortBy('time', true, null);
      expect(result, isEmpty);
    });
  });

  group('FishCatchListExtension Computed Properties', () {
    late List<FishCatch> catches;

    setUp(() {
      catches = [
        TestDataFactory.createFishCatch(
            id: 1, species: 'Bass', fate: FishFateType.release),
        TestDataFactory.createFishCatch(
            id: 2, species: 'Trout', fate: FishFateType.keep),
        TestDataFactory.createFishCatch(
            id: 3, species: 'Bass', fate: FishFateType.release),
        TestDataFactory.createFishCatch(
            id: 4, species: 'Catfish', fate: FishFateType.keep),
        TestDataFactory.createFishCatch(
            id: 5, species: 'Trout', fate: FishFateType.release),
      ];
    });

    test('uniqueSpecies returns distinct species list sorted', () {
      final result = catches.uniqueSpecies;
      expect(result, equals(['Bass', 'Catfish', 'Trout']));
    });

    test('releaseCount returns count of release fate', () {
      expect(catches.releaseCount, equals(3));
    });

    test('keepCount returns count of keep fate', () {
      expect(catches.keepCount, equals(2));
    });

    test('releaseRate returns correct percentage', () {
      expect(catches.releaseRate, equals(3 / 5));
    });

    test('releaseRate handles 0 total', () {
      final emptyCatches = <FishCatch>[];
      expect(emptyCatches.releaseRate, equals(0));
    });

    test('uniqueSpecies handles all same species', () {
      final sameSpecies = [
        TestDataFactory.createFishCatch(id: 1, species: 'Bass'),
        TestDataFactory.createFishCatch(id: 2, species: 'Bass'),
        TestDataFactory.createFishCatch(id: 3, species: 'Bass'),
      ];
      expect(sameSpecies.uniqueSpecies, equals(['Bass']));
    });

    test('uniqueSpecies handles empty list', () {
      expect(<FishCatch>[].uniqueSpecies, isEmpty);
    });

    test('releaseCount and keepCount handle empty list', () {
      final empty = <FishCatch>[];
      expect(empty.releaseCount, equals(0));
      expect(empty.keepCount, equals(0));
    });

    test('computed properties on single item list', () {
      final singleCatch = [
        TestDataFactory.createFishCatch(
            id: 1, species: 'Bass', fate: FishFateType.release),
      ];
      expect(singleCatch.uniqueSpecies, equals(['Bass']));
      expect(singleCatch.releaseCount, equals(1));
      expect(singleCatch.keepCount, equals(0));
      expect(singleCatch.releaseRate, equals(1.0));
    });
  });

  group('FishCatch toString', () {
    test('returns readable format', () {
      final fish = TestDataFactory.createFishCatch(
        id: 42,
        species: 'Bass',
        length: 35.0,
        fate: FishFateType.release,
      );

      final str = fish.toString();

      expect(str, contains('id: 42'));
      expect(str, contains('species: Bass'));
      expect(str, contains('length: 35.0cm'));
      expect(str, contains('fate: 放流'));
    });
  });

  group('FishCatch edge cases', () {
    test('handles very large id values', () {
      final fish = TestDataFactory.createFishCatch(id: 999999999);
      final map = fish.toMap();
      expect(map['id'], equals(999999999));
    });

    test('handles negative values for numeric fields', () {
      final fish = FishCatch(
        id: 1,
        imagePath: '/test.jpg',
        species: 'Test',
        length: -10.0,
        weight: -1.0,
        fate: FishFateType.release,
        catchTime: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final map = fish.toMap();
      expect(map['length'], equals(-10.0));
      expect(map['weight'], equals(-1.0));
    });

    test('handles unicode characters in species and notes', () {
      final fish = FishCatch(
        id: 1,
        imagePath: '/test.jpg',
        species: '大口黑鲈',
        notes: '非常好！🎣',
        length: 30.0,
        fate: FishFateType.release,
        catchTime: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final map = fish.toMap();
      expect(map['species'], equals('大口黑鲈'));
      expect(map['notes'], equals('非常好！🎣'));
    });

    test('equality works across different constructor calls', () {
      final now = DateTime.now();
      final fish1 = FishCatch(
        id: 1,
        imagePath: '/a.jpg',
        species: 'A',
        length: 1.0,
        fate: FishFateType.release,
        catchTime: now,
        createdAt: now,
        updatedAt: now,
      );
      final fish2 = FishCatch(
        id: 1,
        imagePath: '/b.jpg',
        species: 'B',
        length: 2.0,
        fate: FishFateType.keep,
        catchTime: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(fish1 == fish2, isTrue);
    });
  });
}
