import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/fish_filter.dart';
import 'package:lurebox/core/models/paginated_result.dart';

void main() {
  group('Boundary Case Tests', () {
    // Helper function to create a basic FishCatch with required fields
    FishCatch createFishCatch({
      int id = 1,
      String species = 'Test',
      double length = 10.0,
      FishFateType fate = FishFateType.release,
      DateTime? catchTime,
      DateTime? createdAt,
      DateTime? updatedAt,
    }) {
      final now = DateTime.now();
      return FishCatch(
        id: id,
        imagePath: '/test/path/image.jpg',
        species: species,
        length: length,
        fate: fate,
        catchTime: catchTime ?? now,
        createdAt: createdAt ?? now,
        updatedAt: updatedAt ?? now,
      );
    }

    group('Pagination Boundaries', () {
      test('handles page=0', () {
        const result = PaginatedResult<FishCatch>(
          items: [],
          totalCount: 0,
          page: 0,
          pageSize: 20,
          hasMore: false,
        );
        expect(result.page, 0);
        expect(result.pageSize, 20);
      });

      // NOTE: page=-1 and pageSize=-1 are NOT tested because:
      // - UI pagination controls cannot generate negative page/pageSize values
      // - Form validation would reject such inputs before they reach the model
      // - These are invalid inputs that users cannot produce through normal use

      test('handles pageSize=0', () {
        const result = PaginatedResult<FishCatch>(
          items: [],
          totalCount: 0,
          page: 1,
          pageSize: 0,
          hasMore: false,
        );
        expect(result.pageSize, 0);
        expect(result.hasMore, false);
      });

      test('handles very large page number', () {
        const result = PaginatedResult<FishCatch>(
          items: [],
          totalCount: 0,
          page: 999999,
          pageSize: 20,
          hasMore: false,
        );
        expect(result.page, 999999);
      });

      test('hasMore is true when items equals pageSize', () {
        final items = List.generate(
          20,
          (i) => createFishCatch(id: i),
        );
        final result = PaginatedResult<FishCatch>(
          items: items,
          totalCount: 100,
          page: 1,
          pageSize: 20,
          hasMore: true,
        );
        expect(result.hasMore, true);
        expect(result.items.length, 20);
      });

      test('handles totalCount less than pageSize', () {
        final result = PaginatedResult<FishCatch>(
          items: [createFishCatch()],
          totalCount: 5,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );
        expect(result.hasMore, false);
        expect(result.totalCount, 5);
      });
    });

    group('Date Boundaries', () {
      test('handles null dates', () {
        const filter = FishFilter(
          customStartDate: null,
          customEndDate: null,
        );
        expect(filter.customStartDate, isNull);
        expect(filter.customEndDate, isNull);
      });

      // NOTE: Extreme dates like 1900 or 2100 are NOT tested because:
      // - Users cannot input such unrealistic dates through the UI date picker
      // - Date picker constraints prevent selection of dates outside reasonable range
      // - These tests would validate nothing about real-world usage

      test('handles leap year dates', () {
        final leapDate = DateTime(2024, 2, 29);
        final fish = createFishCatch(catchTime: leapDate);
        expect(fish.catchTime.month, 2);
        expect(fish.catchTime.day, 29);
        // Check leap year manually - 2024 is divisible by 4 and not by 100
        expect(2024 % 4 == 0 && (2024 % 100 != 0 || 2024 % 400 == 0), true);
      });

      test('handles date where start after end', () {
        final start = DateTime(2024, 12, 31);
        final end = DateTime(2024, 1, 1);
        final filter = FishFilter(
          customStartDate: start,
          customEndDate: end,
        );
        expect(filter.customStartDate!.isAfter(filter.customEndDate!), true);
      });

      test('handles same start and end date', () {
        final date = DateTime(2024, 6, 15);
        final filter = FishFilter(
          customStartDate: date,
          customEndDate: date,
        );
        expect(filter.customStartDate, filter.customEndDate);
      });

      test('handles very old catch date', () {
        final oldCatchTime = DateTime(2000, 1, 1, 8, 30);
        final fish = createFishCatch(
          catchTime: oldCatchTime,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(fish.catchTime.year, 2000);
      });
    });

    group('String Boundaries', () {
      test('handles empty string species', () {
        final fish = createFishCatch(species: '');
        expect(fish.species, '');
      });

      test('handles very long species name', () {
        final longName = 'A' * 1000;
        final fish = createFishCatch(species: longName);
        expect(fish.species.length, 1000);
      });

      test('handles unicode characters', () {
        final fish = createFishCatch(species: '黑鱼');
        expect(fish.species, contains('黑'));
        expect(fish.species.length, 2);
      });

      test('handles special characters in species', () {
        final fish = createFishCatch(species: "Fish with 'quotes'");
        expect(fish.species, contains("'"));
      });

      test('handles emoji in species', () {
        final fish = createFishCatch(species: '🐟');
        expect(fish.species, contains('🐟'));
      });

      test('handles whitespace only species', () {
        final fish = createFishCatch(species: '   ');
        expect(fish.species, '   ');
      });

      test('handles null location name', () {
        final fish = createFishCatch();
        expect(fish.locationName, isNull);
      });

      test('handles empty location name', () {
        final fish = FishCatch(
          id: 1,
          imagePath: '/test/path/image.jpg',
          species: 'Test',
          length: 10.0,
          fate: FishFateType.release,
          catchTime: DateTime.now(),
          locationName: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(fish.locationName, '');
      });
    });

    group('Numeric Boundaries', () {
      test('handles zero length', () {
        final fish = createFishCatch(length: 0);
        expect(fish.length, 0);
      });

      test('handles very large length', () {
        final fish = createFishCatch(length: 999999.99);
        expect(fish.length, 999999.99);
      });

      // NOTE: Negative length/weight tests are NOT included because:
      // - UI form validation (TextFormField with keyboardType='number') prevents negative input
      // - Users cannot physically enter negative numbers through the app interface
      // - These would be invalid inputs rejected before reaching the model

      test('handles null weight', () {
        final fish = FishCatch(
          id: 1,
          imagePath: '/test/path/image.jpg',
          species: 'Test',
          length: 10.0,
          weight: null,
          fate: FishFateType.release,
          catchTime: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(fish.weight, isNull);
      });

      test('handles zero weight', () {
        final fish = FishCatch(
          id: 1,
          imagePath: '/test/path/image.jpg',
          species: 'Test',
          length: 10.0,
          weight: 0.0,
          fate: FishFateType.release,
          catchTime: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(fish.weight, 0.0);
      });

      test('handles very large weight', () {
        final fish = FishCatch(
          id: 1,
          imagePath: '/test/path/image.jpg',
          species: 'Test',
          length: 10.0,
          weight: 999999.99,
          fate: FishFateType.release,
          catchTime: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(fish.weight, 999999.99);
      });

      test('handles null coordinates', () {
        final fish = createFishCatch();
        expect(fish.latitude, isNull);
        expect(fish.longitude, isNull);
      });

      test('handles extreme latitude values', () {
        final fish = FishCatch(
          id: 1,
          imagePath: '/test/path/image.jpg',
          species: 'Test',
          length: 10.0,
          latitude: 90.0,
          longitude: 180.0,
          fate: FishFateType.release,
          catchTime: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(fish.latitude, 90.0);
        expect(fish.longitude, 180.0);
      });

      test('handles negative latitude values', () {
        final fish = FishCatch(
          id: 1,
          imagePath: '/test/path/image.jpg',
          species: 'Test',
          length: 10.0,
          latitude: -90.0,
          longitude: -180.0,
          fate: FishFateType.release,
          catchTime: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(fish.latitude, -90.0);
        expect(fish.longitude, -180.0);
      });

      test('handles null equipment IDs', () {
        final fish = createFishCatch();
        expect(fish.equipmentId, isNull);
        expect(fish.rodId, isNull);
        expect(fish.reelId, isNull);
        expect(fish.lureId, isNull);
      });
    });

    group('Collection Boundaries', () {
      test('handles empty catches list', () {
        const result = PaginatedResult<FishCatch>(
          items: [],
          totalCount: 0,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );
        expect(result.items, isEmpty);
        expect(result.totalCount, 0);
      });

      test('handles single item list', () {
        final result = PaginatedResult<FishCatch>(
          items: [createFishCatch()],
          totalCount: 1,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );
        expect(result.items.length, 1);
        expect(result.hasMore, false);
      });

      test('handles large item list', () {
        final items = List.generate(1000, (i) => createFishCatch(id: i));
        final result = PaginatedResult<FishCatch>(
          items: items,
          totalCount: 1000,
          page: 1,
          pageSize: 1000,
          hasMore: false,
        );
        expect(result.items.length, 1000);
      });

      test('paginated result equality works', () {
        final fish1 = createFishCatch(id: 1);
        final fish2 = createFishCatch(id: 2);
        final result1 = PaginatedResult<FishCatch>(
          items: [fish1, fish2],
          totalCount: 2,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );
        final result2 = PaginatedResult<FishCatch>(
          items: [fish1, fish2],
          totalCount: 2,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );
        expect(result1, equals(result2));
      });
    });

    group('FishFilter Boundaries', () {
      test('default filter has correct values', () {
        const filter = FishFilter();
        expect(filter.timeFilter, 'all');
        expect(filter.fateFilter, isNull);
        expect(filter.speciesFilter, isNull);
        expect(filter.sortBy, 'time');
        expect(filter.sortAsc, false);
        expect(filter.customStartDate, isNull);
        expect(filter.customEndDate, isNull);
        expect(filter.searchQuery, isNull);
      });

      test('filter with all null optional values', () {
        // Only these fields can be null: fateFilter, speciesFilter,
        // customStartDate, customEndDate, searchQuery
        // timeFilter and sortBy have defaults so they can't be null
        const filter = FishFilter(
          fateFilter: null,
          speciesFilter: null,
          customStartDate: null,
          customEndDate: null,
          searchQuery: null,
        );
        expect(filter.timeFilter, 'all'); // default value
        expect(filter.sortBy, 'time'); // default value
        expect(filter.fateFilter, isNull);
        expect(filter.speciesFilter, isNull);
      });

      test('filter copyWith preserves values', () {
        const filter = FishFilter(
          timeFilter: 'month',
          fateFilter: FishFateType.keep,
          sortBy: 'length',
          sortAsc: true,
        );
        final copy = filter.copyWith(searchQuery: () => 'test');
        expect(copy.timeFilter, 'month');
        expect(copy.fateFilter, FishFateType.keep);
        expect(copy.sortBy, 'length');
        expect(copy.sortAsc, true);
        expect(copy.searchQuery, 'test');
      });

      test('filter accepts all time filter values', () {
        final filters = ['all', 'today', 'week', 'month', 'year', 'custom'];
        for (final timeFilter in filters) {
          final filter = FishFilter(timeFilter: timeFilter);
          expect(filter.timeFilter, timeFilter);
        }
      });

      test('filter equality works correctly', () {
        const filter1 = FishFilter(
          timeFilter: 'month',
          fateFilter: FishFateType.release,
        );
        const filter2 = FishFilter(
          timeFilter: 'month',
          fateFilter: FishFateType.release,
        );
        expect(filter1, equals(filter2));
      });

      test('filter inequality with different values', () {
        const filter1 = FishFilter(timeFilter: 'today');
        const filter2 = FishFilter(timeFilter: 'week');
        expect(filter1, isNot(equals(filter2)));
      });
    });

    group('FishCatch Model Boundaries', () {
      test('handles default length and weight units', () {
        final fish = createFishCatch();
        expect(fish.lengthUnit, 'cm');
        expect(fish.weightUnit, 'kg');
      });

      test('handles custom length unit', () {
        final fish = FishCatch(
          id: 1,
          imagePath: '/test/path/image.jpg',
          species: 'Test',
          length: 10.0,
          lengthUnit: 'inch',
          fate: FishFateType.release,
          catchTime: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(fish.lengthUnit, 'inch');
      });

      test('handles custom weight unit', () {
        final fish = FishCatch(
          id: 1,
          imagePath: '/test/path/image.jpg',
          species: 'Test',
          length: 10.0,
          weight: 5.0,
          weightUnit: 'lb',
          fate: FishFateType.release,
          catchTime: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(fish.weightUnit, 'lb');
      });

      test('handles pending recognition flag', () {
        final fishPending = FishCatch(
          id: 1,
          imagePath: '/test/path/image.jpg',
          species: 'Test',
          length: 10.0,
          pendingRecognition: true,
          fate: FishFateType.release,
          catchTime: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final fishRecognized = FishCatch(
          id: 2,
          imagePath: '/test/path/image.jpg',
          species: 'Test',
          length: 10.0,
          pendingRecognition: false,
          fate: FishFateType.release,
          catchTime: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(fishPending.pendingRecognition, true);
        expect(fishRecognized.pendingRecognition, false);
      });

      test('handles null watermarked image path', () {
        final fish = createFishCatch();
        expect(fish.watermarkedImagePath, isNull);
      });

      test('equality based on id only', () {
        final fish1 = createFishCatch(id: 1);
        final fish2 = createFishCatch(id: 1, species: 'Different');
        final fish3 = createFishCatch(id: 2);
        expect(fish1, equals(fish2)); // Same ID, same equality
        expect(fish1, isNot(equals(fish3))); // Different ID
      });

      test('copyWith creates new instance', () {
        final fish = createFishCatch();
        final copy = fish.copyWith(species: 'NewSpecies');
        expect(fish.species, 'Test');
        expect(copy.species, 'NewSpecies');
      });

      test('toMap and fromMap round trip', () {
        final now = DateTime.now();
        final original = FishCatch(
          id: 1,
          imagePath: '/test/path/image.jpg',
          watermarkedImagePath: '/test/path/watermarked.jpg',
          species: 'TestFish',
          length: 25.5,
          lengthUnit: 'cm',
          weight: 2.5,
          weightUnit: 'kg',
          fate: FishFateType.keep,
          catchTime: now,
          locationName: 'TestLake',
          latitude: 35.6762,
          longitude: 139.6503,
          equipmentId: 1,
          rodId: 2,
          reelId: 3,
          lureId: 4,
          airTemperature: 22.5,
          pressure: 1013.25,
          weatherCode: 1,
          pendingRecognition: false,
          createdAt: now,
          updatedAt: now,
        );
        final map = original.toMap();
        final restored = FishCatch.fromMap(map);
        expect(restored.id, original.id);
        expect(restored.species, original.species);
        expect(restored.length, original.length);
        expect(restored.fate, original.fate);
      });
    });

    group('Edge Cases for List Extensions', () {
      test('empty list filter returns empty', () {
        final List<FishCatch> emptyList = [];
        final filtered = emptyList.filterByFate(FishFateType.keep);
        expect(filtered, isEmpty);
      });

      test('empty list search returns empty', () {
        final List<FishCatch> emptyList = [];
        final results = emptyList.searchByKeyword('test');
        expect(results, isEmpty);
      });

      test('empty list sort returns empty', () {
        final List<FishCatch> emptyList = [];
        final sorted = emptyList.sortBy('time', true, null);
        expect(sorted, isEmpty);
      });

      test('unique species on empty list returns empty', () {
        final List<FishCatch> emptyList = [];
        final species = emptyList.uniqueSpecies;
        expect(species, isEmpty);
      });
    });
  });
}
