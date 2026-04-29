import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/fish_filter.dart';
import 'package:lurebox/core/providers/fish_list_view_model.dart';
import 'package:lurebox/core/repositories/fish_catch_repository.dart';
import 'package:lurebox/core/repositories/species_history_repository.dart';
import 'package:lurebox/core/repositories/stats_repository.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFishCatchRepository extends Mock implements FishCatchRepository {}

class MockSpeciesHistoryRepository extends Mock
    implements SpeciesHistoryRepository {}

class MockStatsRepository extends Mock implements StatsRepository {}

class FakeFishCatch extends Fake implements FishCatch {}

class FakeDateTime extends Fake implements DateTime {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeFishCatch());
    registerFallbackValue(FakeDateTime());
    registerFallbackValue(FishFateType.release);
  });

  late FishListViewModel viewModel;
  late MockFishCatchRepository mockRepository;
  late MockSpeciesHistoryRepository mockSpeciesHistoryRepo;
  late MockStatsRepository mockStatsRepo;
  late FishCatchService service;

  final testCatches = [
    _createFishCatch(id: 1, species: 'Bass', length: 30, catchTime: DateTime(2024)),
    _createFishCatch(id: 2, species: 'Trout', length: 25, catchTime: DateTime(2024, 1, 2)),
    _createFishCatch(id: 3, species: 'Bass', length: 35, catchTime: DateTime(2024, 1, 3)),
  ];

  setUp(() {
    mockRepository = MockFishCatchRepository();
    mockSpeciesHistoryRepo = MockSpeciesHistoryRepository();
    mockStatsRepo = MockStatsRepository();
    service = FishCatchService(
      mockRepository,
      mockSpeciesHistoryRepo,
      mockStatsRepo,
    );
    viewModel = FishListViewModel(service);

    // Default mock behavior
    when(() => mockRepository.getAll()).thenAnswer((_) async => []);
    when(() => mockRepository.getById(any())).thenAnswer((_) async => null);
    when(() => mockRepository.getByDateRange(any(), any()))
        .thenAnswer((_) async => []);
    when(() => mockRepository.getByFate(any())).thenAnswer((_) async => []);
    when(() => mockRepository.getPage(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          orderBy: any(named: 'orderBy'),
        ),).thenAnswer(
      (_) async => const PaginatedResult(
        items: [],
        totalCount: 0,
        page: 1,
        pageSize: 20,
        hasMore: false,
      ),
    );
    when(() => mockRepository.getFilteredPage(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          fate: any(named: 'fate'),
          species: any(named: 'species'),
          orderBy: any(named: 'orderBy'),
        ),).thenAnswer(
      (_) async => const PaginatedResult(
        items: [],
        totalCount: 0,
        page: 1,
        pageSize: 20,
        hasMore: false,
      ),
    );
    when(() => mockRepository.create(any())).thenAnswer((_) async => 1);
    when(() => mockRepository.update(any())).thenAnswer((_) async {});
    when(() => mockRepository.delete(any())).thenAnswer((_) async {});
    when(() => mockRepository.deleteMultiple(any())).thenAnswer((_) async {});

    when(() => mockSpeciesHistoryRepo.incrementUseCount(any()))
        .thenAnswer((_) async {});
    when(() => mockSpeciesHistoryRepo.getAll()).thenAnswer((_) async => []);

    when(() => mockStatsRepo.getTop3LongestCatches())
        .thenAnswer((_) async => []);
    when(() => mockStatsRepo.getSpeciesStats()).thenAnswer((_) async => {});
    when(() => mockStatsRepo.getEquipmentCatchStats())
        .thenAnswer((_) async => {});
    when(() => mockStatsRepo.getEquipmentDistribution(any()))
        .thenAnswer((_) async => {});
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('FishListViewModel', () {
    group('initial state', () {
      test('is correct', () {
        expect(viewModel.state.catches, isEmpty);
        expect(viewModel.state.filteredCatches, isEmpty);
        expect(viewModel.state.filter, const FishFilter());
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, isNull);
        expect(viewModel.state.selectedIds, isEmpty);
        expect(viewModel.state.isSelectionMode, false);
        expect(viewModel.state.filterExpanded, true);
        expect(viewModel.state.currentPage, 0);
        expect(viewModel.state.hasMore, true);
        expect(viewModel.state.totalCount, 0);
      });
    });

    group('loadCatches', () {
      test('loads catches successfully with pagination', () async {
        final paginatedResult = PaginatedResult(
          items: testCatches,
          totalCount: 3,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer((_) async => paginatedResult);

        await viewModel.loadCatches(reset: true);

        // filteredCatches preserves order from SQL (sorting handled at DB layer)
        expect(viewModel.state.catches.length, equals(3));
        expect(viewModel.state.filteredCatches.length, equals(3));
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.currentPage, 1);
        expect(viewModel.state.hasMore, false);
        expect(viewModel.state.totalCount, 3);
        expect(viewModel.state.errorMessage, isNull);
      });

      test('sets isLoading during fetch', () async {
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 10));
          return const PaginatedResult(
            items: [],
            totalCount: 0,
            page: 1,
            pageSize: 20,
            hasMore: false,
          );
        });

        final future = viewModel.loadCatches(reset: true);
        expect(viewModel.state.isLoading, true);
        await future;
        expect(viewModel.state.isLoading, false);
      });

      test('resets pagination when reset is true', () async {
        // First load
        final paginatedResult1 = PaginatedResult(
          items: [testCatches[0]],
          totalCount: 1,
          page: 1,
          pageSize: 20,
          hasMore: true,
        );
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer((_) async => paginatedResult1);

        await viewModel.loadCatches(reset: true);
        expect(viewModel.state.currentPage, 1);

        // Second load with reset
        final paginatedResult2 = PaginatedResult(
          items: testCatches,
          totalCount: 3,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer((_) async => paginatedResult2);

        await viewModel.loadCatches(reset: true);
        expect(viewModel.state.currentPage, 1);
        expect(viewModel.state.catches.length, 3);
      });

      test('appends catches when loading more (reset is false)', () async {
        // First load
        final paginatedResult1 = PaginatedResult(
          items: [testCatches[0]],
          totalCount: 3,
          page: 1,
          pageSize: 20,
          hasMore: true,
        );
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer((_) async => paginatedResult1);

        await viewModel.loadCatches(reset: true);

        // Second load (load more)
        final paginatedResult2 = PaginatedResult(
          items: [testCatches[1], testCatches[2]],
          totalCount: 3,
          page: 2,
          pageSize: 20,
          hasMore: false,
        );
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer((_) async => paginatedResult2);

        await viewModel.loadCatches();

        expect(viewModel.state.catches.length, 3);
        expect(viewModel.state.currentPage, 2);
        expect(viewModel.state.hasMore, false);
      });

      test('sets errorMessage on failure', () async {
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).thenThrow(Exception('Network error'));

        await viewModel.loadCatches(reset: true);

        expect(viewModel.state.errorMessage, contains('Network error'));
        expect(viewModel.state.isLoading, false);
      });

      test('uses filtered page when filters are active', () async {
        // Set up filtered page mock
        when(() => mockRepository.getFilteredPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              fate: any(named: 'fate'),
              species: any(named: 'species'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer(
            (_) async => const PaginatedResult(
              items: [],
              totalCount: 0,
              page: 1,
              pageSize: 20,
              hasMore: false,
            ),
          );

        // setTimeFilter triggers loadCatches internally
        // Verify filter was updated before async load
        viewModel.setTimeFilter('week');
        expect(viewModel.state.filter.timeFilter, equals('week'));
      });
    });

    group('setTimeFilter', () {
      test('updates filter in state', () {
        viewModel.setTimeFilter('week');
        expect(viewModel.state.filter.timeFilter, equals('week'));
      });

      test('updates filter to month', () {
        viewModel.setTimeFilter('month');
        expect(viewModel.state.filter.timeFilter, equals('month'));
      });
    });

    group('setFateFilter', () {
      test('updates fate filter in state', () async {
        when(() => mockRepository.getFilteredPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              fate: any(named: 'fate'),
              species: any(named: 'species'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer(
          (_) async => const PaginatedResult(
            items: [],
            totalCount: 0,
            page: 1,
            pageSize: 20,
            hasMore: false,
          ),
        );

        viewModel.setFateFilter(FishFateType.release);

        expect(viewModel.state.filter.fateFilter, equals(FishFateType.release));
      });

      test('can clear fate filter by passing null', () async {
        when(() => mockRepository.getFilteredPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              fate: any(named: 'fate'),
              species: any(named: 'species'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer(
          (_) async => const PaginatedResult(
            items: [],
            totalCount: 0,
            page: 1,
            pageSize: 20,
            hasMore: false,
          ),
        );

        viewModel.setFateFilter(null);

        expect(viewModel.state.filter.fateFilter, isNull);
      });
    });

    group('setSpeciesFilter', () {
      test('updates species filter', () async {
        when(() => mockRepository.getFilteredPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              fate: any(named: 'fate'),
              species: any(named: 'species'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer(
          (_) async => const PaginatedResult(
            items: [],
            totalCount: 0,
            page: 1,
            pageSize: 20,
            hasMore: false,
          ),
        );

        viewModel.setSpeciesFilter('Bass');

        expect(viewModel.state.filter.speciesFilter, equals('Bass'));
      });
    });

    group('setSortBy', () {
      test('updates sort settings', () async {
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer(
          (_) async => const PaginatedResult(
            items: [],
            totalCount: 0,
            page: 1,
            pageSize: 20,
            hasMore: false,
          ),
        );

        viewModel.setSortBy('length');

        expect(viewModel.state.filter.sortBy, equals('length'));
      });

      test('toggles sort direction when same sort field is selected', () async {
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer(
          (_) async => const PaginatedResult(
            items: [],
            totalCount: 0,
            page: 1,
            pageSize: 20,
            hasMore: false,
          ),
        );

        // Initial state: sortBy='time', sortAsc=false
        expect(viewModel.state.filter.sortAsc, false);

        // First call with 'length': different field, so sortAsc stays false
        viewModel.setSortBy('length');
        expect(viewModel.state.filter.sortBy, equals('length'));
        expect(viewModel.state.filter.sortAsc, false);

        // Second call with 'length': same field, so toggles to true
        viewModel.setSortBy('length');
        expect(viewModel.state.filter.sortAsc, true);
      });
    });

    group('setSearchQuery', () {
      test('updates searchQuery in filter', () async {
        when(() => mockRepository.getFilteredPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              fate: any(named: 'fate'),
              species: any(named: 'species'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer(
          (_) async => const PaginatedResult(
            items: [],
            totalCount: 0,
            page: 1,
            pageSize: 20,
            hasMore: false,
          ),
        );

        viewModel.setSearchQuery('bass');

        expect(viewModel.state.filter.searchQuery, equals('bass'));
      });

      test('clears searchQuery when null is passed', () async {
        when(() => mockRepository.getFilteredPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              fate: any(named: 'fate'),
              species: any(named: 'species'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer(
          (_) async => const PaginatedResult(
            items: [],
            totalCount: 0,
            page: 1,
            pageSize: 20,
            hasMore: false,
          ),
        );

        viewModel.setSearchQuery(null);

        expect(viewModel.state.filter.searchQuery, isNull);
      });

      test('hasFilters returns true when searchQuery is set', () async {
        when(() => mockRepository.getFilteredPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              fate: any(named: 'fate'),
              species: any(named: 'species'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer(
          (_) async => const PaginatedResult(
            items: [],
            totalCount: 0,
            page: 1,
            pageSize: 20,
            hasMore: false,
          ),
        );

        viewModel.setSearchQuery('test');

        expect(viewModel.state.hasFilters, isTrue);
      });
    });

    group('setCustomDateRange', () {
      test('sets custom date range and timeFilter to custom', () async {
        when(() => mockRepository.getFilteredPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              fate: any(named: 'fate'),
              species: any(named: 'species'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer(
          (_) async => const PaginatedResult(
            items: [],
            totalCount: 0,
            page: 1,
            pageSize: 20,
            hasMore: false,
          ),
        );

        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 12, 31);

        viewModel.setCustomDateRange(startDate, endDate);

        expect(viewModel.state.filter.timeFilter, equals('custom'));
        expect(viewModel.state.filter.customStartDate, equals(startDate));
        expect(viewModel.state.filter.customEndDate, equals(endDate));
      });

      test('can clear custom date range by passing nulls', () async {
        when(() => mockRepository.getFilteredPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              fate: any(named: 'fate'),
              species: any(named: 'species'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer(
          (_) async => const PaginatedResult(
            items: [],
            totalCount: 0,
            page: 1,
            pageSize: 20,
            hasMore: false,
          ),
        );

        viewModel.setCustomDateRange(null, null);

        expect(viewModel.state.filter.timeFilter, equals('custom'));
        expect(viewModel.state.filter.customStartDate, isNull);
        expect(viewModel.state.filter.customEndDate, isNull);
      });
    });

    group('clearFilters', () {
      test('resets all filters to default', () {
        // clearFilters directly sets state.filter to FishFilter()
        viewModel.clearFilters();
        expect(viewModel.state.filter, const FishFilter());
      });
    });

    group('selection mode', () {
      test('toggleSelectionMode enters selection mode', () {
        expect(viewModel.state.isSelectionMode, false);
        expect(viewModel.state.selectedIds, isEmpty);

        viewModel.toggleSelectionMode();

        expect(viewModel.state.isSelectionMode, true);
        expect(viewModel.state.selectedIds, isEmpty);
      });

      test('toggleSelectionMode exits selection mode and clears selectedIds',
          () {
        viewModel.toggleSelectionMode();
        viewModel.toggleSelection(1);
        viewModel.toggleSelection(2);

        expect(viewModel.state.isSelectionMode, true);
        expect(viewModel.state.selectedIds.length, 2);

        viewModel.toggleSelectionMode();

        expect(viewModel.state.isSelectionMode, false);
        expect(viewModel.state.selectedIds, isEmpty);
      });

      test('toggleSelection adds id when not selected', () {
        viewModel.toggleSelectionMode();

        viewModel.toggleSelection(1);
        expect(viewModel.state.selectedIds, contains(1));

        viewModel.toggleSelection(2);
        expect(viewModel.state.selectedIds, contains(2));
        expect(viewModel.state.selectedIds.length, 2);
      });

      test('toggleSelection removes id when already selected', () {
        viewModel.toggleSelectionMode();
        viewModel.toggleSelection(1);
        viewModel.toggleSelection(2);

        expect(viewModel.state.selectedIds.length, 2);

        viewModel.toggleSelection(1);
        expect(viewModel.state.selectedIds, isNot(contains(1)));
        expect(viewModel.state.selectedIds.length, 1);
      });

      test('selectAll selects all filtered catches', () async {
        final paginatedResult = PaginatedResult(
          items: testCatches,
          totalCount: 3,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer((_) async => paginatedResult);

        await viewModel.loadCatches(reset: true);
        viewModel.toggleSelectionMode();
        viewModel.selectAll();

        expect(viewModel.state.selectedIds.length, 3);
        expect(viewModel.state.selectedIds, equals({1, 2, 3}));
      });
    });

    group('deleteSelected', () {
      test('deletes selected catches and clears selection', () async {
        final paginatedResult = PaginatedResult(
          items: testCatches,
          totalCount: 3,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer((_) async => paginatedResult);

        await viewModel.loadCatches(reset: true);
        viewModel.toggleSelectionMode();
        viewModel.toggleSelection(1);
        viewModel.toggleSelection(2);

        expect(viewModel.state.selectedIds.length, 2);

        // Reload after delete
        final emptyResult = PaginatedResult(
          items: [testCatches[2]],
          totalCount: 1,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );
        when(() => mockRepository.getByIds([1, 2]))
            .thenAnswer((_) async => [
                  _createFishCatch(id: 1, species: 'Bass', length: 30),
                  _createFishCatch(id: 2, species: 'Trout', length: 25),
                ],);
        when(() => mockRepository.deleteMultiple([1, 2]))
            .thenAnswer((_) async {});
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer((_) async => emptyResult);

        await viewModel.deleteSelected();

        verify(() => mockRepository.deleteMultiple([1, 2])).called(1);
        expect(viewModel.state.selectedIds, isEmpty);
        expect(viewModel.state.isSelectionMode, false);
      });

      test('does nothing when no catches are selected', () async {
        viewModel.toggleSelectionMode();
        expect(viewModel.state.selectedIds, isEmpty);

        await viewModel.deleteSelected();

        verifyNever(() => mockRepository.deleteMultiple(any()));
      });

      test('sets errorMessage on delete failure', () async {
        viewModel.toggleSelectionMode();
        viewModel.toggleSelection(1);

        when(() => mockRepository.getByIds([1]))
            .thenAnswer((_) async => [_createFishCatch(id: 1, species: 'Bass', length: 30)]);
        when(() => mockRepository.deleteMultiple([1]))
            .thenThrow(Exception('Delete failed'));

        await viewModel.deleteSelected();

        expect(viewModel.state.errorMessage, contains('Delete failed'));
      });
    });

    group('loadMore', () {
      test('does nothing when already loading', () async {
        final completer = Completer<PaginatedResult<FishCatch>>();
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer((_) => completer.future);

        final load1 = viewModel.loadCatches(reset: true);
        // loadMore should be skipped because isLoading is true
        await viewModel.loadMore();

        // Now complete the first load
        completer.complete(const PaginatedResult(
          items: [],
          totalCount: 0,
          page: 1,
          pageSize: 20,
          hasMore: false,
        ));
        await load1;

        // Should only be called once because loadMore should be skipped during loading
        verify(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).called(1);
      });

      test('does nothing when hasMore is false', () async {
        // Set up state with hasMore = false
        final paginatedResult = PaginatedResult(
          items: testCatches,
          totalCount: 3,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer((_) async => paginatedResult);

        await viewModel.loadCatches(reset: true);
        verify(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).called(1);

        // Reset call count
        clearInteractions(mockRepository);

        await viewModel.loadMore();

        // Should not call repository again
        verifyNever(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),);
      });
    });

    group('toggleFilterExpanded', () {
      test('toggles filterExpanded state', () {
        expect(viewModel.state.filterExpanded, true);

        viewModel.toggleFilterExpanded();
        expect(viewModel.state.filterExpanded, false);

        viewModel.toggleFilterExpanded();
        expect(viewModel.state.filterExpanded, true);
      });
    });

    group('onScroll', () {
      test('expands filter when scrolling up past threshold', () {
        viewModel.state = viewModel.state.copyWith(filterExpanded: false);

        viewModel.onScroll(-10, 0);

        expect(viewModel.state.filterExpanded, true);
      });

      test('collapses filter when scrolling down past threshold', () {
        expect(viewModel.state.filterExpanded, true);

        // offset > lastOffset + 5 means 11 > 10 is true
        viewModel.onScroll(11, 5);

        expect(viewModel.state.filterExpanded, false);
      });

      test('does nothing when threshold not met', () {
        viewModel.state = viewModel.state.copyWith(filterExpanded: true);

        viewModel.onScroll(3, 0); // offset 3, lastOffset 0, threshold is 5

        expect(viewModel.state.filterExpanded, true);
      });
    });

    group('hasFilters', () {
      test('returns false for default filter', () {
        expect(viewModel.state.hasFilters, false);
      });

      test('returns true when timeFilter is not all', () {
        viewModel.state = viewModel.state.copyWith(
          filter: const FishFilter(timeFilter: 'week'),
        );
        expect(viewModel.state.hasFilters, true);
      });

      test('returns true when fateFilter is set', () {
        viewModel.state = viewModel.state.copyWith(
          filter: const FishFilter(fateFilter: FishFateType.release),
        );
        expect(viewModel.state.hasFilters, true);
      });

      test('returns true when speciesFilter is set', () {
        viewModel.state = viewModel.state.copyWith(
          filter: const FishFilter(speciesFilter: 'Bass'),
        );
        expect(viewModel.state.hasFilters, true);
      });

      test('returns true when searchQuery is not empty', () {
        viewModel.state = viewModel.state.copyWith(
          filter: const FishFilter(searchQuery: 'search term'),
        );
        expect(viewModel.state.hasFilters, true);
      });
    });

    group('uniqueSpecies', () {
      test('returns sorted list of unique species', () async {
        final paginatedResult = PaginatedResult(
          items: testCatches,
          totalCount: 3,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer((_) async => paginatedResult);

        await viewModel.loadCatches(reset: true);

        expect(viewModel.state.uniqueSpecies, equals(['Bass', 'Trout']));
      });

      test('returns empty list when no catches', () {
        expect(viewModel.state.uniqueSpecies, isEmpty);
      });
    });
  });
}

FishCatch _createFishCatch({
  required int id,
  required String species,
  required double length,
  FishFateType fate = FishFateType.release,
  DateTime? catchTime,
}) {
  final now = catchTime ?? DateTime.now();
  return FishCatch(
    id: id,
    imagePath: '/test/fish_$id.jpg',
    species: species,
    length: length,
    fate: fate,
    catchTime: now,
    createdAt: now,
    updatedAt: now,
  );
}
