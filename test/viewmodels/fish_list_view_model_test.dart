import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/providers/fish_list_view_model.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/fish_filter.dart';
import 'package:lurebox/core/repositories/fish_catch_repository.dart';
import 'package:lurebox/core/repositories/species_history_repository.dart';
import 'package:lurebox/core/repositories/stats_repository.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';

class MockFishCatchRepository extends Mock implements FishCatchRepository {}

class MockSpeciesHistoryRepository extends Mock
    implements SpeciesHistoryRepository {}

class MockStatsRepository extends Mock implements StatsRepository {}

class FakeFishCatch extends Fake implements FishCatch {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeFishCatch());
  });

  late FishListViewModel viewModel;
  late MockFishCatchRepository mockRepository;
  late MockSpeciesHistoryRepository mockSpeciesHistoryRepo;
  late MockStatsRepository mockStatsRepo;

  setUp(() {
    mockRepository = MockFishCatchRepository();
    mockSpeciesHistoryRepo = MockSpeciesHistoryRepository();
    mockStatsRepo = MockStatsRepository();

    when(() => mockRepository.getAll()).thenAnswer((_) async => []);
    when(() => mockRepository.getById(any())).thenAnswer((_) async => null);
    when(
      () => mockRepository.getByDateRange(any(), any()),
    ).thenAnswer((_) async => []);
    when(
      () => mockRepository.getByFate(FishFateType.release),
    ).thenAnswer((_) async => []);
    when(
      () => mockRepository.getByFate(FishFateType.keep),
    ).thenAnswer((_) async => []);
    when(
      () => mockRepository.getPage(
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
        orderBy: any(named: 'orderBy'),
      ),
    ).thenAnswer(
      (_) async => const PaginatedResult(
        items: [],
        totalCount: 0,
        page: 1,
        pageSize: 20,
        hasMore: false,
      ),
    );
    when(
      () => mockRepository.getFilteredPage(
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        fate: any(named: 'fate'),
        species: any(named: 'species'),
        orderBy: any(named: 'orderBy'),
      ),
    ).thenAnswer(
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

    when(
      () => mockSpeciesHistoryRepo.incrementUseCount(any()),
    ).thenAnswer((_) async {});
    when(() => mockSpeciesHistoryRepo.getAll()).thenAnswer((_) async => []);

    when(
      () => mockStatsRepo.getTop3LongestCatches(),
    ).thenAnswer((_) async => []);
    when(() => mockStatsRepo.getSpeciesStats()).thenAnswer((_) async => {});
    when(
      () => mockStatsRepo.getEquipmentCatchStats(),
    ).thenAnswer((_) async => {});
    when(
      () => mockStatsRepo.getEquipmentDistribution(any()),
    ).thenAnswer((_) async => {});

    final service = FishCatchService(
      mockRepository,
      mockSpeciesHistoryRepo,
      mockStatsRepo,
    );
    viewModel = FishListViewModel(service);
  });

  group('FishListViewModel', () {
    test('initial state is correct', () {
      expect(viewModel.state.catches, isEmpty);
      expect(viewModel.state.filteredCatches, isEmpty);
      expect(viewModel.state.filter, const FishFilter());
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.errorMessage, isNull);
      expect(viewModel.state.selectedIds, isEmpty);
      expect(viewModel.state.isSelectionMode, false);
    });
  });
}
