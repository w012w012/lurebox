import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/fish_filter.dart';
import 'package:lurebox/core/models/paginated_result.dart';
import 'package:lurebox/core/providers/fish_list_view_model.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_helpers.dart';

void main() {
  setUpAll(registerFallbackValues);

  group('Provider Integration Tests', () {
    group('FishListViewModel State Transitions', () {
      late ProviderContainer container;
      late MockFishCatchRepository mockRepository;
      late MockSpeciesHistoryRepository mockSpeciesHistoryRepo;
      late MockStatsRepository mockStatsRepo;

      setUp(() {
        mockRepository = MockFishCatchRepository();
        mockSpeciesHistoryRepo = MockSpeciesHistoryRepository();
        mockStatsRepo = MockStatsRepository();

        // Override the service provider with mock
        container = ProviderContainer(
          overrides: [
            fishCatchServiceProvider.overrideWithValue(
              FishCatchService(
                mockRepository,
                mockSpeciesHistoryRepo,
                mockStatsRepo,
              ),
            ),
          ],
        );

        // Setup default mock behavior
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer((_) async => const PaginatedResult(
              items: [],
              totalCount: 0,
              page: 1,
              pageSize: 20,
              hasMore: false,
            ),);

        when(() => mockRepository.getFilteredPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              fate: any(named: 'fate'),
              species: any(named: 'species'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer((_) async => const PaginatedResult(
              items: [],
              totalCount: 0,
              page: 1,
              pageSize: 20,
              hasMore: false,
            ),);

        when(() => mockRepository.deleteMultiple(any()))
            .thenAnswer((_) async {});
      });

      tearDown(() {
        container.dispose();
      });

      test('initial state is correct', () {
        final state = container.read(fishListViewModelProvider);
        expect(state.catches, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.errorMessage, isNull);
        expect(state.selectedIds, isEmpty);
        expect(state.isSelectionMode, isFalse);
        expect(state.currentPage, 0);
        expect(state.hasMore, isTrue);
        expect(state.totalCount, 0);
        expect(state.filter, const FishFilter());
      });

      test('loadCatches transitions: initial → loading → loaded', () async {
        final fish = TestDataFactory.createFishCatch();
        when(() => mockRepository.getPage(
              page: 1,
            ),).thenAnswer((_) async => PaginatedResult(
              items: [fish],
              totalCount: 1,
              page: 1,
              pageSize: 20,
              hasMore: false,
            ),);

        final viewModel = container.read(fishListViewModelProvider.notifier);

        // Initial state
        expect(container.read(fishListViewModelProvider).isLoading, isFalse);

        // Load
        final loadFuture = viewModel.loadCatches();
        expect(container.read(fishListViewModelProvider).isLoading, isTrue);

        await loadFuture;
        expect(container.read(fishListViewModelProvider).isLoading, isFalse);
        expect(container.read(fishListViewModelProvider).catches, [fish]);
        expect(container.read(fishListViewModelProvider).currentPage, 1);
        expect(container.read(fishListViewModelProvider).hasMore, isFalse);
      });

      test('loadCatches with reset=true clears existing catches', () async {
        final fish1 = TestDataFactory.createFishCatch();
        final fish2 = TestDataFactory.createFishCatch(id: 2);

        // First load
        when(() => mockRepository.getPage(
              page: 1,
            ),).thenAnswer((_) async => PaginatedResult(
              items: [fish1],
              totalCount: 1,
              page: 1,
              pageSize: 20,
              hasMore: true,
            ),);

        final viewModel = container.read(fishListViewModelProvider.notifier);
        await viewModel.loadCatches();
        expect(container.read(fishListViewModelProvider).catches, [fish1]);

        // Second load with reset
        when(() => mockRepository.getPage(
              page: 1,
            ),).thenAnswer((_) async => PaginatedResult(
              items: [fish2],
              totalCount: 1,
              page: 1,
              pageSize: 20,
              hasMore: false,
            ),);

        await viewModel.loadCatches(reset: true);
        expect(container.read(fishListViewModelProvider).catches, [fish2]);
        expect(container.read(fishListViewModelProvider).currentPage, 1);
      });

      test('error state is preserved', () async {
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).thenThrow(Exception('Database error'));

        final viewModel = container.read(fishListViewModelProvider.notifier);
        await viewModel.loadCatches();

        expect(
          container.read(fishListViewModelProvider).errorMessage,
          contains('Database error'),
        );
        expect(container.read(fishListViewModelProvider).isLoading, isFalse);
      });

      test('error state is cleared on subsequent load', () async {
        // First load fails
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).thenThrow(Exception('Database error'));

        final viewModel = container.read(fishListViewModelProvider.notifier);
        await viewModel.loadCatches();
        expect(
          container.read(fishListViewModelProvider).errorMessage,
          isNotNull,
        );

        // Second load succeeds
        final fish = TestDataFactory.createFishCatch();
        when(() => mockRepository.getPage(
              page: 1,
            ),).thenAnswer((_) async => PaginatedResult(
              items: [fish],
              totalCount: 1,
              page: 1,
              pageSize: 20,
              hasMore: false,
            ),);

        await viewModel.loadCatches();
        expect(
          container.read(fishListViewModelProvider).errorMessage,
          isNull,
        );
      });

      test('selection mode toggles correctly', () {
        final viewModel = container.read(fishListViewModelProvider.notifier);

        viewModel.toggleSelectionMode();
        expect(
          container.read(fishListViewModelProvider).isSelectionMode,
          true,
        );

        viewModel.toggleSelectionMode();
        expect(
          container.read(fishListViewModelProvider).isSelectionMode,
          false,
        );
      });

      test('exiting selection mode clears selectedIds', () {
        final viewModel = container.read(fishListViewModelProvider.notifier);

        // Enter selection mode and select some items
        viewModel.toggleSelectionMode();
        viewModel.toggleSelection(1);
        viewModel.toggleSelection(2);
        expect(
          container.read(fishListViewModelProvider).selectedIds,
          {1, 2},
        );

        // Exit selection mode
        viewModel.toggleSelectionMode();
        expect(
          container.read(fishListViewModelProvider).selectedIds,
          isEmpty,
        );
        expect(
          container.read(fishListViewModelProvider).isSelectionMode,
          false,
        );
      });

      test('toggleSelection adds and removes ids', () {
        final viewModel = container.read(fishListViewModelProvider.notifier);

        viewModel.toggleSelection(1);
        expect(container.read(fishListViewModelProvider).selectedIds, {1});

        viewModel.toggleSelection(2);
        expect(container.read(fishListViewModelProvider).selectedIds, {1, 2});

        viewModel.toggleSelection(1);
        expect(container.read(fishListViewModelProvider).selectedIds, {2});
      });

      test('selectAll selects all filtered catches', () async {
        final fish1 = TestDataFactory.createFishCatch();
        final fish2 = TestDataFactory.createFishCatch(id: 2);
        final fish3 = TestDataFactory.createFishCatch(id: 3);

        when(() => mockRepository.getPage(
              page: 1,
            ),).thenAnswer((_) async => PaginatedResult(
              items: [fish1, fish2, fish3],
              totalCount: 3,
              page: 1,
              pageSize: 20,
              hasMore: false,
            ),);

        final viewModel = container.read(fishListViewModelProvider.notifier);
        await viewModel.loadCatches();

        viewModel.selectAll();
        expect(
          container.read(fishListViewModelProvider).selectedIds,
          {1, 2, 3},
        );
      });

      test('deleteSelected removes items and exits selection mode', () async {
        final fish1 = TestDataFactory.createFishCatch();
        final fish2 = TestDataFactory.createFishCatch(id: 2);

        when(() => mockRepository.getPage(
              page: 1,
            ),).thenAnswer((_) async => PaginatedResult(
              items: [fish1, fish2],
              totalCount: 2,
              page: 1,
              pageSize: 20,
              hasMore: false,
            ),);

        when(() => mockRepository.getByIds(any()))
            .thenAnswer((_) async => [fish1]);

        when(() => mockRepository.deleteMultiple(any()))
            .thenAnswer((_) async {});

        final viewModel = container.read(fishListViewModelProvider.notifier);
        await viewModel.loadCatches();

        // Enter selection mode and select fish1
        viewModel.toggleSelectionMode();
        viewModel.toggleSelection(1);

        // Delete selected
        await viewModel.deleteSelected();

        // Verify delete was called
        verify(() => mockRepository.deleteMultiple([1])).called(1);

        // Verify state
        expect(
          container.read(fishListViewModelProvider).selectedIds,
          isEmpty,
        );
        expect(
          container.read(fishListViewModelProvider).isSelectionMode,
          false,
        );
      });

      test('filterExpanded toggles correctly', () {
        final viewModel = container.read(fishListViewModelProvider.notifier);
        expect(
          container.read(fishListViewModelProvider).filterExpanded,
          true,
        );

        viewModel.toggleFilterExpanded();
        expect(
          container.read(fishListViewModelProvider).filterExpanded,
          false,
        );

        viewModel.toggleFilterExpanded();
        expect(
          container.read(fishListViewModelProvider).filterExpanded,
          true,
        );
      });

      test('setTimeFilter updates filter and reloads', () async {
        final fish = TestDataFactory.createFishCatch();
        when(() => mockRepository.getFilteredPage(
              page: 1,
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              fate: any(named: 'fate'),
              species: any(named: 'species'),
            ),).thenAnswer((_) async => PaginatedResult(
              items: [fish],
              totalCount: 1,
              page: 1,
              pageSize: 20,
              hasMore: false,
            ),);

        final viewModel = container.read(fishListViewModelProvider.notifier);
        viewModel.setTimeFilter('today');

        // Wait for async loadCatches triggered by setTimeFilter
        await Future.delayed(const Duration(milliseconds: 100));

        expect(
          container.read(fishListViewModelProvider).filter.timeFilter,
          'today',
        );
      });

      test('setFateFilter updates filter correctly', () async {
        final viewModel = container.read(fishListViewModelProvider.notifier);
        viewModel.setFateFilter(FishFateType.release);

        await Future.delayed(const Duration(milliseconds: 100));

        expect(
          container.read(fishListViewModelProvider).filter.fateFilter,
          FishFateType.release,
        );
      });

      test('clearFilters resets to default filter', () async {
        final viewModel = container.read(fishListViewModelProvider.notifier);

        // Apply some filters
        viewModel.setTimeFilter('month');
        await Future.delayed(const Duration(milliseconds: 50));
        viewModel.setFateFilter(FishFateType.keep);
        await Future.delayed(const Duration(milliseconds: 50));

        // Clear filters
        viewModel.clearFilters();
        await Future.delayed(const Duration(milliseconds: 100));

        expect(
          container.read(fishListViewModelProvider).filter.timeFilter,
          'all',
        );
        expect(
          container.read(fishListViewModelProvider).filter.fateFilter,
          isNull,
        );
      });

      test('loadMore does not trigger when already loading', () async {
        final viewModel = container.read(fishListViewModelProvider.notifier);

        // Start loading
        final loadFuture = viewModel.loadCatches();
        expect(container.read(fishListViewModelProvider).isLoading, isTrue);

        // Try loadMore while loading
        viewModel.loadMore();

        // Should still be loading, not start another load
        expect(container.read(fishListViewModelProvider).isLoading, isTrue);

        await loadFuture;
      });

      test('loadMore does not trigger when no more data', () async {
        // Setup with hasMore = false (0 items returned, less than pageSize)
        when(() => mockRepository.getPage(
              page: 1,
            ),).thenAnswer((_) async => const PaginatedResult(
              items: [],
              totalCount: 0,
              page: 1,
              pageSize: 20,
              hasMore: false,
            ),);

        final viewModel = container.read(fishListViewModelProvider.notifier);
        await viewModel.loadCatches();

        // Verify hasMore is false (because 0 items < pageSize of 20)
        expect(container.read(fishListViewModelProvider).hasMore, isFalse);

        // Get current state
        final stateBefore = container.read(fishListViewModelProvider);

        // loadMore should return early since hasMore is false
        viewModel.loadMore();

        // State should remain unchanged
        expect(
          container.read(fishListViewModelProvider).currentPage,
          stateBefore.currentPage,
        );
        expect(
          container.read(fishListViewModelProvider).catches,
          stateBefore.catches,
        );
      });

      test('hasFilters returns true when filters are active', () async {
        final viewModel = container.read(fishListViewModelProvider.notifier);

        expect(
          container.read(fishListViewModelProvider).hasFilters,
          false,
        );

        viewModel.setTimeFilter('today');
        await Future.delayed(const Duration(milliseconds: 100));

        expect(
          container.read(fishListViewModelProvider).hasFilters,
          true,
        );
      });

      test('uniqueSpecies returns sorted unique species', () async {
        final fish1 = TestDataFactory.createFishCatch();
        final fish2 = TestDataFactory.createFishCatch(id: 2, species: 'Trout');
        final fish3 = TestDataFactory.createFishCatch(id: 3);

        when(() => mockRepository.getPage(
              page: 1,
            ),).thenAnswer((_) async => PaginatedResult(
              items: [fish1, fish2, fish3],
              totalCount: 3,
              page: 1,
              pageSize: 20,
              hasMore: false,
            ),);

        final viewModel = container.read(fishListViewModelProvider.notifier);
        await viewModel.loadCatches();

        final uniqueSpecies =
            container.read(fishListViewModelProvider).uniqueSpecies;
        expect(uniqueSpecies, ['Bass', 'Trout']);
      });
    });

    group('fishCatchServiceProvider', () {
      late ProviderContainer container;
      late MockFishCatchRepository mockRepository;
      late MockSpeciesHistoryRepository mockSpeciesHistoryRepo;
      late MockStatsRepository mockStatsRepo;

      setUp(() {
        mockRepository = MockFishCatchRepository();
        mockSpeciesHistoryRepo = MockSpeciesHistoryRepository();
        mockStatsRepo = MockStatsRepository();

        container = ProviderContainer(
          overrides: [
            fishCatchServiceProvider.overrideWithValue(
              FishCatchService(
                mockRepository,
                mockSpeciesHistoryRepo,
                mockStatsRepo,
              ),
            ),
          ],
        );
      });

      tearDown(() {
        container.dispose();
      });

      test('getAll returns list of catches', () async {
        final fish1 = TestDataFactory.createFishCatch();
        final fish2 = TestDataFactory.createFishCatch(id: 2);

        when(() => mockRepository.getAll())
            .thenAnswer((_) async => [fish1, fish2]);

        final service = container.read(fishCatchServiceProvider);
        final result = await service.getAll();

        expect(result, [fish1, fish2]);
        verify(() => mockRepository.getAll()).called(1);
      });

      test('getById returns fish catch', () async {
        final fish = TestDataFactory.createFishCatch();

        when(() => mockRepository.getById(1)).thenAnswer((_) async => fish);

        final service = container.read(fishCatchServiceProvider);
        final result = await service.getById(1);

        expect(result, fish);
        verify(() => mockRepository.getById(1)).called(1);
      });

      test('getById returns null for non-existent id', () async {
        when(() => mockRepository.getById(999)).thenAnswer((_) async => null);

        final service = container.read(fishCatchServiceProvider);
        final result = await service.getById(999);

        expect(result, isNull);
      });

      test('create increments species use count', () async {
        final fish = TestDataFactory.createFishCatch();

        when(() => mockRepository.create(fish)).thenAnswer((_) async => 1);
        when(() => mockSpeciesHistoryRepo.incrementUseCount('Bass'))
            .thenAnswer((_) async {});

        final service = container.read(fishCatchServiceProvider);
        final id = await service.create(fish);

        expect(id, 1);
        verify(() => mockRepository.create(fish)).called(1);
        verify(() => mockSpeciesHistoryRepo.incrementUseCount('Bass'))
            .called(1);
      });

      test('deleteMultiple deletes from repository', () async {
        when(() => mockRepository.getByIds([1, 2]))
            .thenAnswer((_) async => [
                  TestDataFactory.createFishCatch(),
                  TestDataFactory.createFishCatch(id: 2),
                ],);
        when(() => mockRepository.deleteMultiple([1, 2]))
            .thenAnswer((_) async {});

        final service = container.read(fishCatchServiceProvider);
        await service.deleteMultiple([1, 2]);

        verify(() => mockRepository.deleteMultiple([1, 2])).called(1);
      });
    });
  });
}
