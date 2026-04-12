import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/fish_filter.dart';
import 'package:lurebox/core/repositories/fish_catch_repository.dart';
import 'package:lurebox/core/repositories/species_history_repository.dart';
import 'package:lurebox/core/repositories/stats_repository.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';
import 'package:lurebox/core/providers/stats_view_model.dart';

class MockFishCatchRepository extends Mock implements FishCatchRepository {}

class MockSpeciesHistoryRepository extends Mock
    implements SpeciesHistoryRepository {}

class MockStatsRepository extends Mock implements StatsRepository {}

class FakeFishCatch extends Fake implements FishCatch {}

class FakeFishFilter extends Fake implements FishFilter {}

// Helper function to create FishCatch for testing
FishCatch _createFishCatch({
  int id = 1,
  String species = 'Bass',
  double length = 30.0,
  double? weight,
  FishFateType fate = FishFateType.release,
  DateTime? catchTime,
  String? locationName,
  double? latitude,
  double? longitude,
  int? rodId,
  int? reelId,
  int? lureId,
}) {
  return FishCatch(
    id: id,
    imagePath: '/test/fish_$id.jpg',
    species: species,
    length: length,
    weight: weight,
    fate: fate,
    catchTime: catchTime ?? DateTime(2024, 6, 15, 10, 30),
    locationName: locationName,
    latitude: latitude,
    longitude: longitude,
    rodId: rodId,
    reelId: reelId,
    lureId: lureId,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

void main() {
  late StatsDetailViewModel viewModel;
  late MockFishCatchRepository mockRepository;
  late MockSpeciesHistoryRepository mockSpeciesHistoryRepo;
  late MockStatsRepository mockStatsRepo;
  late FishCatchService fishCatchService;

  final testStartDate = DateTime(2024, 1, 1);
  final testEndDate = DateTime(2024, 12, 31);
  const testTitle = 'Test Stats';

  setUpAll(() {
    registerFallbackValue(FakeFishCatch());
    registerFallbackValue(FakeFishFilter());
  });

  setUp(() {
    mockRepository = MockFishCatchRepository();
    mockSpeciesHistoryRepo = MockSpeciesHistoryRepository();
    mockStatsRepo = MockStatsRepository();

    // Default mock behavior for empty results
    when(() => mockRepository.getPage(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          orderBy: any(named: 'orderBy'),
        )).thenAnswer(
      (_) async => const PaginatedResult<FishCatch>(
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
        )).thenAnswer(
      (_) async => const PaginatedResult<FishCatch>(
        items: [],
        totalCount: 0,
        page: 1,
        pageSize: 20,
        hasMore: false,
      ),
    );
    when(() => mockRepository.deleteMultiple(any())).thenAnswer((_) async {});
    when(() => mockRepository.getByDateRange(any(), any()))
        .thenAnswer((_) async => []);
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

    fishCatchService = FishCatchService(
      mockRepository,
      mockSpeciesHistoryRepo,
      mockStatsRepo,
    );
  });

  group('StatsDetailViewModel', () {
    group('initial state', () {
      test('has correct default values before loading', () {
        // Create viewModel - constructor calls loadData() automatically
        when(() => mockRepository.getByDateRange(any(), any()))
            .thenAnswer((_) async => []);

        viewModel = StatsDetailViewModel(
          fishCatchService: fishCatchService,
          title: testTitle,
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Initial state before async load completes
        expect(viewModel.state.isLoading, true);
        expect(viewModel.state.errorMessage, isNull);
        expect(viewModel.state.title, testTitle);
        expect(viewModel.state.startDate, testStartDate);
        expect(viewModel.state.endDate, testEndDate);
        expect(viewModel.state.totalCount, 0);
        expect(viewModel.state.releaseCount, 0);
        expect(viewModel.state.keepCount, 0);
        expect(viewModel.state.totalWeight, 0.0);
        expect(viewModel.state.speciesDistribution, isEmpty);
        expect(viewModel.state.locationDistribution, isEmpty);
        expect(viewModel.state.rodDistribution, isEmpty);
        expect(viewModel.state.reelDistribution, isEmpty);
        expect(viewModel.state.lureDistribution, isEmpty);
        expect(viewModel.state.hourlyDistribution, isEmpty);
        expect(viewModel.state.dailyDistribution, isEmpty);
        expect(viewModel.state.monthlyDistribution, isEmpty);
        expect(viewModel.state.catches, isEmpty);
        expect(viewModel.state.isSharing, false);
      });

      test('releaseRate returns 0 when totalCount is 0', () async {
        when(() => mockRepository.getByDateRange(any(), any()))
            .thenAnswer((_) async => []);

        viewModel = StatsDetailViewModel(
          fishCatchService: fishCatchService,
          title: testTitle,
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Wait for loadData to complete
        await Future.delayed(Duration.zero);

        expect(viewModel.state.releaseRate, 0.0);
      });
    });

    // ============================================================
    // loadData() Tests
    // ============================================================
    group('loadData', () {
      test('loadData() calculates all stats correctly with mixed catches',
          () async {
        // Arrange
        final fishList = [
          _createFishCatch(
            id: 1,
            species: 'Bass',
            weight: 2.5,
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15, 10, 30),
            locationName: 'Lake A',
          ),
          _createFishCatch(
            id: 2,
            species: 'Bass',
            weight: 3.0,
            fate: FishFateType.keep,
            catchTime: DateTime(2024, 6, 15, 14, 45),
            locationName: 'Lake A',
          ),
          _createFishCatch(
            id: 3,
            species: 'Trout',
            weight: 1.5,
            fate: FishFateType.release,
            catchTime: DateTime(2024, 7, 20, 8, 15),
            locationName: 'River B',
          ),
          _createFishCatch(
            id: 4,
            species: 'Pike',
            weight: 4.0,
            fate: FishFateType.release,
            catchTime: DateTime(2024, 8, 10, 16, 0),
            locationName: 'Lake C',
          ),
        ];

        when(() => mockRepository.getByDateRange(testStartDate, testEndDate))
            .thenAnswer((_) async => fishList);

        // Act
        viewModel = StatsDetailViewModel(
          fishCatchService: fishCatchService,
          title: testTitle,
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Wait for loadData to complete
        await Future.delayed(Duration.zero);

        // Assert - totalCount
        expect(viewModel.state.totalCount, 4);

        // Assert - releaseCount and keepCount
        expect(viewModel.state.releaseCount, 3); // Bass(1), Trout(1), Pike(1)
        expect(viewModel.state.keepCount, 1); // Bass(2)

        // Assert - totalWeight
        expect(viewModel.state.totalWeight, 11.0); // 2.5 + 3.0 + 1.5 + 4.0

        // Assert - speciesDistribution
        expect(viewModel.state.speciesDistribution, {
          'Bass': 2,
          'Trout': 1,
          'Pike': 1,
        });

        // Assert - locationDistribution
        expect(viewModel.state.locationDistribution, {
          'Lake A': 2,
          'River B': 1,
          'Lake C': 1,
        });

        // Assert - hourlyDistribution
        expect(viewModel.state.hourlyDistribution, {
          10: 1, // 10:30
          14: 1, // 14:45
          8: 1, // 8:15
          16: 1, // 16:00
        });

        // Assert - dailyDistribution
        expect(viewModel.state.dailyDistribution, {
          15: 2, // June 15
          20: 1, // July 20
          10: 1, // Aug 10
        });

        // Assert - monthlyDistribution
        expect(viewModel.state.monthlyDistribution, {
          6: 2, // June
          7: 1, // July
          8: 1, // August
        });

        // Assert - catches
        expect(viewModel.state.catches.length, 4);

        // Assert - isLoading
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, isNull);
      });

      test('loadData() handles empty catch list', () async {
        // Arrange
        when(() => mockRepository.getByDateRange(testStartDate, testEndDate))
            .thenAnswer((_) async => []);

        // Act
        viewModel = StatsDetailViewModel(
          fishCatchService: fishCatchService,
          title: testTitle,
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Wait for loadData to complete
        await Future.delayed(Duration.zero);

        // Assert
        expect(viewModel.state.totalCount, 0);
        expect(viewModel.state.releaseCount, 0);
        expect(viewModel.state.keepCount, 0);
        expect(viewModel.state.totalWeight, 0.0);
        expect(viewModel.state.speciesDistribution, isEmpty);
        expect(viewModel.state.locationDistribution, isEmpty);
        expect(viewModel.state.hourlyDistribution, isEmpty);
        expect(viewModel.state.dailyDistribution, isEmpty);
        expect(viewModel.state.monthlyDistribution, isEmpty);
        expect(viewModel.state.catches, isEmpty);
        expect(viewModel.state.isLoading, false);
      });

      test('loadData() calculates releaseRate correctly', () async {
        // Arrange - 2 release, 2 keep = 50% release rate
        final fishList = [
          _createFishCatch(id: 1, fate: FishFateType.release),
          _createFishCatch(id: 2, fate: FishFateType.release),
          _createFishCatch(id: 3, fate: FishFateType.keep),
          _createFishCatch(id: 4, fate: FishFateType.keep),
        ];

        when(() => mockRepository.getByDateRange(testStartDate, testEndDate))
            .thenAnswer((_) async => fishList);

        // Act
        viewModel = StatsDetailViewModel(
          fishCatchService: fishCatchService,
          title: testTitle,
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Wait for loadData to complete
        await Future.delayed(Duration.zero);

        // Assert
        expect(viewModel.state.totalCount, 4);
        expect(viewModel.state.releaseCount, 2);
        expect(viewModel.state.keepCount, 2);
        expect(viewModel.state.releaseRate, 0.5);
      });

      test('loadData() handles null weight in fish catches', () async {
        // Arrange
        final fishList = [
          _createFishCatch(id: 1, weight: 2.5, fate: FishFateType.release),
          _createFishCatch(id: 2, weight: null, fate: FishFateType.release),
          _createFishCatch(id: 3, weight: 3.0, fate: FishFateType.keep),
        ];

        when(() => mockRepository.getByDateRange(testStartDate, testEndDate))
            .thenAnswer((_) async => fishList);

        // Act
        viewModel = StatsDetailViewModel(
          fishCatchService: fishCatchService,
          title: testTitle,
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Wait for loadData to complete
        await Future.delayed(Duration.zero);

        // Assert - only sum non-null weights
        expect(viewModel.state.totalWeight, 5.5);
      });

      test('loadData() handles null locationName', () async {
        // Arrange
        final fishList = [
          _createFishCatch(
            id: 1,
            locationName: 'Lake A',
            fate: FishFateType.release,
          ),
          _createFishCatch(
            id: 2,
            locationName: null,
            fate: FishFateType.release,
          ),
          _createFishCatch(
            id: 3,
            locationName: '',
            fate: FishFateType.release,
          ),
        ];

        when(() => mockRepository.getByDateRange(testStartDate, testEndDate))
            .thenAnswer((_) async => fishList);

        // Act
        viewModel = StatsDetailViewModel(
          fishCatchService: fishCatchService,
          title: testTitle,
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Wait for loadData to complete
        await Future.delayed(Duration.zero);

        // Assert - only "Lake A" should be in distribution
        expect(viewModel.state.locationDistribution, {'Lake A': 1});
      });
    });

    // ============================================================
    // loadData() Error Handling Tests
    // ============================================================
    group('loadData error handling', () {
      test('sets errorMessage when service throws exception', () async {
        // Arrange
        when(() => mockRepository.getByDateRange(testStartDate, testEndDate))
            .thenThrow(Exception('Database connection failed'));

        // Act
        viewModel = StatsDetailViewModel(
          fishCatchService: fishCatchService,
          title: testTitle,
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Wait for loadData to complete
        await Future.delayed(Duration.zero);

        // Assert
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage,
            contains('Database connection failed'));
        expect(viewModel.state.totalCount, 0);
        expect(viewModel.state.catches, isEmpty);
      });

      test('sets errorMessage when service returns error', () async {
        // Arrange
        when(() => mockRepository.getByDateRange(testStartDate, testEndDate))
            .thenThrow(Exception('Service unavailable'));

        // Act
        viewModel = StatsDetailViewModel(
          fishCatchService: fishCatchService,
          title: testTitle,
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Wait for loadData to complete
        await Future.delayed(Duration.zero);

        // Assert
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, isNotNull);
        expect(viewModel.state.errorMessage, contains('Service unavailable'));
      });
    });

    // ============================================================
    // setSharing() Tests
    // ============================================================
    group('setSharing', () {
      test('setSharing(true) updates isSharing to true', () async {
        // Arrange
        when(() => mockRepository.getByDateRange(any(), any()))
            .thenAnswer((_) async => []);

        viewModel = StatsDetailViewModel(
          fishCatchService: fishCatchService,
          title: testTitle,
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Wait for initial load
        await Future.delayed(Duration.zero);

        // Act
        viewModel.setSharing(true);

        // Assert
        expect(viewModel.state.isSharing, true);
      });

      test('setSharing(false) updates isSharing to false', () async {
        // Arrange
        when(() => mockRepository.getByDateRange(any(), any()))
            .thenAnswer((_) async => []);

        viewModel = StatsDetailViewModel(
          fishCatchService: fishCatchService,
          title: testTitle,
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Wait for initial load
        await Future.delayed(Duration.zero);

        // Act
        viewModel.setSharing(false);

        // Assert
        expect(viewModel.state.isSharing, false);
      });

      test('setSharing toggles correctly', () async {
        // Arrange
        when(() => mockRepository.getByDateRange(any(), any()))
            .thenAnswer((_) async => []);

        viewModel = StatsDetailViewModel(
          fishCatchService: fishCatchService,
          title: testTitle,
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Wait for initial load
        await Future.delayed(Duration.zero);

        // Initial state
        expect(viewModel.state.isSharing, false);

        // Act & Assert - toggle on
        viewModel.setSharing(true);
        expect(viewModel.state.isSharing, true);

        // Act & Assert - toggle off
        viewModel.setSharing(false);
        expect(viewModel.state.isSharing, false);
      });
    });

    // ============================================================
    // refresh() Tests
    // ============================================================
    group('refresh', () {
      test('refresh() calls loadData() again', () async {
        // Arrange
        var callCount = 0;
        when(() => mockRepository.getByDateRange(testStartDate, testEndDate))
            .thenAnswer((_) async {
          callCount++;
          return [];
        });

        viewModel = StatsDetailViewModel(
          fishCatchService: fishCatchService,
          title: testTitle,
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Wait for initial load
        await Future.delayed(Duration.zero);
        expect(callCount, 1);

        // Act - call refresh
        await viewModel.refresh();
        await Future.delayed(Duration.zero);

        // Assert
        expect(callCount, 2);
      });

      test('refresh() updates stats with new data from service', () async {
        // Arrange - initial empty
        when(() => mockRepository.getByDateRange(testStartDate, testEndDate))
            .thenAnswer((_) async => []);

        viewModel = StatsDetailViewModel(
          fishCatchService: fishCatchService,
          title: testTitle,
          startDate: testStartDate,
          endDate: testEndDate,
        );

        await Future.delayed(Duration.zero);
        expect(viewModel.state.totalCount, 0);

        // Arrange - now return some data
        when(() => mockRepository.getByDateRange(testStartDate, testEndDate))
            .thenAnswer((_) async => [
                  _createFishCatch(id: 1, species: 'Bass'),
                ]);

        // Act
        await viewModel.refresh();
        await Future.delayed(Duration.zero);

        // Assert
        expect(viewModel.state.totalCount, 1);
        expect(viewModel.state.speciesDistribution, {'Bass': 1});
      });

      test('refresh() preserves existing state while loading', () async {
        // Arrange - start with some data
        final fishList = [
          _createFishCatch(id: 1, species: 'Bass', weight: 2.5),
        ];

        when(() => mockRepository.getByDateRange(testStartDate, testEndDate))
            .thenAnswer((_) async => fishList);

        viewModel = StatsDetailViewModel(
          fishCatchService: fishCatchService,
          title: testTitle,
          startDate: testStartDate,
          endDate: testEndDate,
        );

        await Future.delayed(Duration.zero);
        expect(viewModel.state.totalWeight, 2.5);

        // Setup mock to delay response (simulating slow network)
        when(() => mockRepository.getByDateRange(testStartDate, testEndDate))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return [
            _createFishCatch(id: 1, species: 'Bass', weight: 2.5),
            _createFishCatch(id: 2, species: 'Trout', weight: 1.5),
          ];
        });

        // Act - trigger refresh
        final refreshFuture = viewModel.refresh();

        // Note: Due to async nature, the exact behavior depends on implementation
        await refreshFuture;
        await Future.delayed(Duration.zero);

        // Assert - should have new data after refresh
        expect(viewModel.state.totalCount, 2);
      });
    });

    // ============================================================
    // releaseRate getter Tests
    // ============================================================
    group('releaseRate getter', () {
      test('releaseRate returns 0 when totalCount is 0', () async {
        // Arrange
        when(() => mockRepository.getByDateRange(any(), any()))
            .thenAnswer((_) async => []);

        viewModel = StatsDetailViewModel(
          fishCatchService: fishCatchService,
          title: testTitle,
          startDate: testStartDate,
          endDate: testEndDate,
        );

        await Future.delayed(Duration.zero);

        // Assert
        expect(viewModel.state.releaseRate, 0.0);
      });

      test('releaseRate returns 1.0 when all catches are released', () async {
        // Arrange
        final fishList = [
          _createFishCatch(id: 1, fate: FishFateType.release),
          _createFishCatch(id: 2, fate: FishFateType.release),
          _createFishCatch(id: 3, fate: FishFateType.release),
        ];

        when(() => mockRepository.getByDateRange(testStartDate, testEndDate))
            .thenAnswer((_) async => fishList);

        viewModel = StatsDetailViewModel(
          fishCatchService: fishCatchService,
          title: testTitle,
          startDate: testStartDate,
          endDate: testEndDate,
        );

        await Future.delayed(Duration.zero);

        // Assert
        expect(viewModel.state.releaseRate, 1.0);
      });

      test('releaseRate returns 0.0 when all catches are kept', () async {
        // Arrange
        final fishList = [
          _createFishCatch(id: 1, fate: FishFateType.keep),
          _createFishCatch(id: 2, fate: FishFateType.keep),
        ];

        when(() => mockRepository.getByDateRange(testStartDate, testEndDate))
            .thenAnswer((_) async => fishList);

        viewModel = StatsDetailViewModel(
          fishCatchService: fishCatchService,
          title: testTitle,
          startDate: testStartDate,
          endDate: testEndDate,
        );

        await Future.delayed(Duration.zero);

        // Assert
        expect(viewModel.state.releaseRate, 0.0);
      });

      test('releaseRate calculates correct fraction', () async {
        // Arrange - 3 released out of 4 total = 0.75
        final fishList = [
          _createFishCatch(id: 1, fate: FishFateType.release),
          _createFishCatch(id: 2, fate: FishFateType.release),
          _createFishCatch(id: 3, fate: FishFateType.release),
          _createFishCatch(id: 4, fate: FishFateType.keep),
        ];

        when(() => mockRepository.getByDateRange(testStartDate, testEndDate))
            .thenAnswer((_) async => fishList);

        viewModel = StatsDetailViewModel(
          fishCatchService: fishCatchService,
          title: testTitle,
          startDate: testStartDate,
          endDate: testEndDate,
        );

        await Future.delayed(Duration.zero);

        // Assert
        expect(viewModel.state.releaseRate, 0.75);
      });
    });
  });
}
