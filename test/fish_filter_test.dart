import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/fish_filter.dart';

void main() {
  group('FishFilter', () {
    test('default values are correct', () {
      const filter = FishFilter();
      expect(filter.timeFilter, equals('all'));
      expect(filter.fateFilter, isNull);
      expect(filter.speciesFilter, isNull);
      expect(filter.sortBy, equals('time'));
      expect(filter.sortAsc, isFalse);
    });

    test('copyWith updates only specified values', () {
      const original = FishFilter();
      final updated = original.copyWith(
        timeFilter: 'today',
        fateFilter: () => FishFateType.release,
      );

      expect(updated.timeFilter, equals('today'));
      expect(updated.fateFilter, equals(FishFateType.release));
      expect(updated.speciesFilter, isNull);
      expect(updated.sortBy, equals('time'));
    });

    test('copyWith can clear nullable values', () {
      final original = FishFilter(
        timeFilter: 'today',
        fateFilter: FishFateType.release,
      );
      final updated = original.copyWith(fateFilter: () => null);

      expect(updated.fateFilter, isNull);
      expect(updated.timeFilter, equals('today'));
    });

    test('equality works correctly', () {
      const filter1 = FishFilter(
        timeFilter: 'today',
        fateFilter: FishFateType.release,
      );
      const filter2 = FishFilter(
        timeFilter: 'today',
        fateFilter: FishFateType.release,
      );
      const filter3 = FishFilter(timeFilter: 'month');

      expect(filter1, equals(filter2));
      expect(filter1, isNot(equals(filter3)));
    });

    test('hashCode is consistent with equality', () {
      const filter1 = FishFilter(
        timeFilter: 'today',
        fateFilter: FishFateType.release,
      );
      const filter2 = FishFilter(
        timeFilter: 'today',
        fateFilter: FishFateType.release,
      );

      expect(filter1.hashCode, equals(filter2.hashCode));
    });
  });

  group('FishFilterNotifier', () {
    late FishFilterNotifier notifier;

    setUp(() {
      notifier = FishFilterNotifier();
    });

    test('initial state has default values', () {
      expect(notifier.state.timeFilter, equals('all'));
      expect(notifier.state.fateFilter, isNull);
    });

    test('setTimeFilter updates time filter', () {
      notifier.setTimeFilter('today');
      expect(notifier.state.timeFilter, equals('today'));
    });

    test('setFateFilter updates fate filter', () {
      notifier.setFateFilter(FishFateType.release);
      expect(notifier.state.fateFilter, equals(FishFateType.release));
    });

    test('setFateFilter with null clears fate filter', () {
      notifier.setFateFilter(FishFateType.release);
      notifier.setFateFilter(null);
      expect(notifier.state.fateFilter, isNull);
    });

    test('setSpeciesFilter updates species filter', () {
      notifier.setSpeciesFilter('Bass');
      expect(notifier.state.speciesFilter, equals('Bass'));
    });

    test('setSortBy toggles direction on same field', () {
      expect(notifier.state.sortBy, equals('time'));
      expect(notifier.state.sortAsc, isFalse);

      notifier.setSortBy('time');
      expect(notifier.state.sortAsc, isFalse);
    });

    test('setSortBy resets direction on new field', () {
      notifier.setSortBy('time');
      notifier.setSortBy('length');
      expect(notifier.state.sortBy, equals('length'));
      expect(notifier.state.sortAsc, isFalse);
    });

    test('setCustomDateRange sets all date-related fields', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 12, 31);

      notifier.setCustomDateRange(start, end);

      expect(notifier.state.timeFilter, equals('custom'));
      expect(notifier.state.customStartDate, equals(start));
      expect(notifier.state.customEndDate, equals(end));
    });

    test('setSearchQuery updates search query', () {
      notifier.setSearchQuery('search term');
      expect(notifier.state.searchQuery, equals('search term'));
    });

    test('clearAll resets to default', () {
      notifier.setTimeFilter('today');
      notifier.setFateFilter(FishFateType.release);
      notifier.setSpeciesFilter('Bass');
      notifier.setSearchQuery('test');

      notifier.clearAll();

      expect(notifier.state.timeFilter, equals('all'));
      expect(notifier.state.fateFilter, isNull);
      expect(notifier.state.speciesFilter, isNull);
      expect(notifier.state.searchQuery, isNull);
    });
  });
}
