import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/models/fish_filter.dart';
import 'package:lurebox/core/models/fish_catch.dart';

void main() {
  group('FishFilter', () {
    group('default values', () {
      test('timeFilter defaults to all', () {
        const filter = FishFilter();
        expect(filter.timeFilter, equals('all'));
      });

      test('fateFilter defaults to null', () {
        const filter = FishFilter();
        expect(filter.fateFilter, isNull);
      });

      test('speciesFilter defaults to null', () {
        const filter = FishFilter();
        expect(filter.speciesFilter, isNull);
      });

      test('sortBy defaults to time', () {
        const filter = FishFilter();
        expect(filter.sortBy, equals('time'));
      });

      test('sortAsc defaults to false', () {
        const filter = FishFilter();
        expect(filter.sortAsc, isFalse);
      });

      test('customStartDate defaults to null', () {
        const filter = FishFilter();
        expect(filter.customStartDate, isNull);
      });

      test('customEndDate defaults to null', () {
        const filter = FishFilter();
        expect(filter.customEndDate, isNull);
      });

      test('searchQuery defaults to null', () {
        const filter = FishFilter();
        expect(filter.searchQuery, isNull);
      });
    });

    group('copyWith', () {
      test('copyWith with no args returns equal object', () {
        final original = FishFilter(
          timeFilter: 'today',
          fateFilter: FishFateType.release,
          speciesFilter: 'bass',
          sortBy: 'length',
          sortAsc: true,
          customStartDate: DateTime(2024, 1, 1),
          customEndDate: DateTime(2024, 12, 31),
          searchQuery: 'test',
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
      });

      test('copyWith(timeFilter: today) changes only timeFilter', () {
        const original = FishFilter();
        final copy = original.copyWith(timeFilter: 'today');

        expect(copy.timeFilter, equals('today'));
        expect(copy.fateFilter, equals(original.fateFilter));
        expect(copy.speciesFilter, equals(original.speciesFilter));
        expect(copy.sortBy, equals(original.sortBy));
        expect(copy.sortAsc, equals(original.sortAsc));
        expect(copy.customStartDate, equals(original.customStartDate));
        expect(copy.customEndDate, equals(original.customEndDate));
        expect(copy.searchQuery, equals(original.searchQuery));
      });

      test('copyWith(fateFilter: () => FishFateType.release) sets fateFilter', () {
        const original = FishFilter();
        final copy = original.copyWith(fateFilter: () => FishFateType.release);

        expect(copy.fateFilter, equals(FishFateType.release));
      });

      test('copyWith(fateFilter: () => null) clears fateFilter', () {
        final original = FishFilter(
          fateFilter: FishFateType.keep,
        );
        final copy = original.copyWith(fateFilter: () => null);

        expect(copy.fateFilter, isNull);
      });

      test('copyWith(customStartDate: () => DateTime(2024)) sets customStartDate', () {
        const original = FishFilter();
        final date = DateTime(2024, 6, 15);
        final copy = original.copyWith(customStartDate: () => date);

        expect(copy.customStartDate, equals(date));
      });

      test('copyWith(customStartDate: () => null) clears customStartDate', () {
        final original = FishFilter(
          customStartDate: DateTime(2024, 1, 1),
        );
        final copy = original.copyWith(customStartDate: () => null);

        expect(copy.customStartDate, isNull);
      });

      test('copyWith(customEndDate: () => DateTime(2024)) sets customEndDate', () {
        const original = FishFilter();
        final date = DateTime(2024, 12, 31);
        final copy = original.copyWith(customEndDate: () => date);

        expect(copy.customEndDate, equals(date));
      });

      test('copyWith(customEndDate: () => null) clears customEndDate', () {
        final original = FishFilter(
          customEndDate: DateTime(2024, 12, 31),
        );
        final copy = original.copyWith(customEndDate: () => null);

        expect(copy.customEndDate, isNull);
      });

      test('copyWith(searchQuery: () => query) sets searchQuery', () {
        const original = FishFilter();
        final copy = original.copyWith(searchQuery: () => 'bass');

        expect(copy.searchQuery, equals('bass'));
      });

      test('copyWith(searchQuery: () => null) clears searchQuery', () {
        const original = FishFilter(searchQuery: 'bass');
        final copy = original.copyWith(searchQuery: () => null);

        expect(copy.searchQuery, isNull);
      });

      test('copyWith(speciesFilter: () => species) sets speciesFilter', () {
        const original = FishFilter();
        final copy = original.copyWith(speciesFilter: () => 'pike');

        expect(copy.speciesFilter, equals('pike'));
      });

      test('copyWith(speciesFilter: () => null) clears speciesFilter', () {
        const original = FishFilter(speciesFilter: 'pike');
        final copy = original.copyWith(speciesFilter: () => null);

        expect(copy.speciesFilter, isNull);
      });

      test('copyWith preserves other fields when changing multiple', () {
        const original = FishFilter(
          timeFilter: 'week',
          sortBy: 'weight',
          sortAsc: true,
        );

        final copy = original.copyWith(
          timeFilter: 'month',
          sortBy: 'length',
        );

        expect(copy.timeFilter, equals('month'));
        expect(copy.sortBy, equals('length'));
        expect(copy.sortAsc, equals(true)); // preserved
      });
    });

    group('equality', () {
      test('two FishFilter with same values are equal', () {
        const filter1 = FishFilter(
          timeFilter: 'today',
          fateFilter: FishFateType.release,
          sortBy: 'time',
          sortAsc: false,
        );

        const filter2 = FishFilter(
          timeFilter: 'today',
          fateFilter: FishFateType.release,
          sortBy: 'time',
          sortAsc: false,
        );

        expect(filter1, equals(filter2));
      });

      test('two FishFilter with different timeFilter are not equal', () {
        const filter1 = FishFilter(timeFilter: 'today');
        const filter2 = FishFilter(timeFilter: 'week');

        expect(filter1, isNot(equals(filter2)));
      });

      test('two FishFilter with different fateFilter are not equal', () {
        const filter1 = FishFilter(fateFilter: FishFateType.release);
        const filter2 = FishFilter(fateFilter: FishFateType.keep);

        expect(filter1, isNot(equals(filter2)));
      });

      test('two FishFilter with different speciesFilter are not equal', () {
        const filter1 = FishFilter(speciesFilter: 'bass');
        const filter2 = FishFilter(speciesFilter: 'pike');

        expect(filter1, isNot(equals(filter2)));
      });

      test('two FishFilter with different sortBy are not equal', () {
        const filter1 = FishFilter(sortBy: 'time');
        const filter2 = FishFilter(sortBy: 'length');

        expect(filter1, isNot(equals(filter2)));
      });

      test('two FishFilter with different sortAsc are not equal', () {
        const filter1 = FishFilter(sortAsc: true);
        const filter2 = FishFilter(sortAsc: false);

        expect(filter1, isNot(equals(filter2)));
      });

      test('two FishFilter with different customStartDate are not equal', () {
        final filter1 = FishFilter(customStartDate: DateTime(2024, 1, 1));
        final filter2 = FishFilter(customStartDate: DateTime(2024, 6, 15));

        expect(filter1, isNot(equals(filter2)));
      });

      test('two FishFilter with different customEndDate are not equal', () {
        final filter1 = FishFilter(customEndDate: DateTime(2024, 6, 15));
        final filter2 = FishFilter(customEndDate: DateTime(2024, 12, 31));

        expect(filter1, isNot(equals(filter2)));
      });

      test('two FishFilter with different searchQuery are not equal', () {
        const filter1 = FishFilter(searchQuery: 'bass');
        const filter2 = FishFilter(searchQuery: 'pike');

        expect(filter1, isNot(equals(filter2)));
      });

      test('one with customStartDate and one without are not equal', () {
        const filter1 = FishFilter();
        final filter2 = FishFilter(customStartDate: DateTime(2024, 1, 1));

        expect(filter1, isNot(equals(filter2)));
      });

      test('one with searchQuery and one without are not equal', () {
        const filter1 = FishFilter();
        const filter2 = FishFilter(searchQuery: 'test');

        expect(filter1, isNot(equals(filter2)));
      });
    });
  });

  group('FishFilterNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is const FishFilter()', () {
      final notifier = container.read(fishFilterProvider.notifier);
      final state = container.read(fishFilterProvider);

      expect(state, equals(const FishFilter()));
      expect(state.timeFilter, equals('all'));
      expect(state.fateFilter, isNull);
      expect(state.sortBy, equals('time'));
      expect(state.sortAsc, isFalse);
    });

    test('setTimeFilter(today) updates state.timeFilter', () {
      final notifier = container.read(fishFilterProvider.notifier);

      notifier.setTimeFilter('today');

      final state = container.read(fishFilterProvider);
      expect(state.timeFilter, equals('today'));
    });

    test('setTimeFilter(month) updates state.timeFilter', () {
      final notifier = container.read(fishFilterProvider.notifier);

      notifier.setTimeFilter('month');

      final state = container.read(fishFilterProvider);
      expect(state.timeFilter, equals('month'));
    });

    test('setFateFilter(FishFateType.release) updates state.fateFilter', () {
      final notifier = container.read(fishFilterProvider.notifier);

      notifier.setFateFilter(FishFateType.release);

      final state = container.read(fishFilterProvider);
      expect(state.fateFilter, equals(FishFateType.release));
    });

    test('setFateFilter(FishFateType.keep) updates state.fateFilter', () {
      final notifier = container.read(fishFilterProvider.notifier);

      notifier.setFateFilter(FishFateType.keep);

      final state = container.read(fishFilterProvider);
      expect(state.fateFilter, equals(FishFateType.keep));
    });

    test('setFateFilter(null) clears fateFilter', () {
      final notifier = container.read(fishFilterProvider.notifier);

      notifier.setFateFilter(FishFateType.release);
      notifier.setFateFilter(null);

      final state = container.read(fishFilterProvider);
      expect(state.fateFilter, isNull);
    });

    test('setSpeciesFilter(bass) updates state.speciesFilter', () {
      final notifier = container.read(fishFilterProvider.notifier);

      notifier.setSpeciesFilter('bass');

      final state = container.read(fishFilterProvider);
      expect(state.speciesFilter, equals('bass'));
    });

    test('setSpeciesFilter(null) clears speciesFilter', () {
      final notifier = container.read(fishFilterProvider.notifier);

      notifier.setSpeciesFilter('bass');
      notifier.setSpeciesFilter(null);

      final state = container.read(fishFilterProvider);
      expect(state.speciesFilter, isNull);
    });

    test('setSortBy(time) toggles sortAsc when same field', () {
      final notifier = container.read(fishFilterProvider.notifier);

      // Default sortBy is 'time' with sortAsc false
      // First call toggles to true
      notifier.setSortBy('time');
      expect(container.read(fishFilterProvider).sortAsc, isTrue);

      // Second call toggles back to false
      notifier.setSortBy('time');
      expect(container.read(fishFilterProvider).sortAsc, isFalse);
    });

    test('setSortBy preserves sortAsc when switching fields', () {
      final notifier = container.read(fishFilterProvider.notifier);

      // Set to length with sortAsc true
      notifier.setSortBy('length', sortAsc: true);
      expect(container.read(fishFilterProvider).sortBy, equals('length'));
      expect(container.read(fishFilterProvider).sortAsc, isTrue);

      // Switching to different field preserves sortAsc (does not reset)
      notifier.setSortBy('weight');
      expect(container.read(fishFilterProvider).sortBy, equals('weight'));
      expect(container.read(fishFilterProvider).sortAsc, isTrue);
    });

    test('setSortBy with explicit sortAsc preserves value', () {
      final notifier = container.read(fishFilterProvider.notifier);

      notifier.setSortBy('length', sortAsc: true);

      final state = container.read(fishFilterProvider);
      expect(state.sortBy, equals('length'));
      expect(state.sortAsc, isTrue);
    });

    test('setCustomDateRange updates timeFilter and dates', () {
      final notifier = container.read(fishFilterProvider.notifier);

      notifier.setCustomDateRange(DateTime(2024, 1, 1), DateTime(2024, 12, 31));

      final state = container.read(fishFilterProvider);
      expect(state.timeFilter, equals('custom'));
      expect(state.customStartDate, equals(DateTime(2024, 1, 1)));
      expect(state.customEndDate, equals(DateTime(2024, 12, 31)));
    });

    test('setCustomDateRange with null end sets only start', () {
      final notifier = container.read(fishFilterProvider.notifier);

      notifier.setCustomDateRange(DateTime(2024, 6, 15), null);

      final state = container.read(fishFilterProvider);
      expect(state.timeFilter, equals('custom'));
      expect(state.customStartDate, equals(DateTime(2024, 6, 15)));
      expect(state.customEndDate, isNull);
    });

    test('setSearchQuery(bass) updates state.searchQuery', () {
      final notifier = container.read(fishFilterProvider.notifier);

      notifier.setSearchQuery('bass');

      final state = container.read(fishFilterProvider);
      expect(state.searchQuery, equals('bass'));
    });

    test('setSearchQuery(null) clears searchQuery', () {
      final notifier = container.read(fishFilterProvider.notifier);

      notifier.setSearchQuery('bass');
      notifier.setSearchQuery(null);

      final state = container.read(fishFilterProvider);
      expect(state.searchQuery, isNull);
    });

    test('clearAll() resets to default FishFilter', () {
      final notifier = container.read(fishFilterProvider.notifier);

      // Set various filters
      notifier.setTimeFilter('month');
      notifier.setFateFilter(FishFateType.keep);
      notifier.setSpeciesFilter('bass');
      notifier.setSortBy('length', sortAsc: true);
      notifier.setSearchQuery('test');

      // Clear all
      notifier.clearAll();

      final state = container.read(fishFilterProvider);
      expect(state, equals(const FishFilter()));
    });

    test('clearAll works from non-default state', () {
      final notifier = container.read(fishFilterProvider.notifier);

      notifier.setCustomDateRange(DateTime(2024, 1, 1), DateTime(2024, 12, 31));
      notifier.setSearchQuery('search term');

      notifier.clearAll();

      final state = container.read(fishFilterProvider);
      expect(state.timeFilter, equals('all'));
      expect(state.customStartDate, isNull);
      expect(state.customEndDate, isNull);
      expect(state.searchQuery, isNull);
    });
  });
}