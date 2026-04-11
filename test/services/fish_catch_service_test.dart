import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/fish_filter.dart';
import 'package:lurebox/core/models/paginated_result.dart';
import 'package:lurebox/core/repositories/fish_catch_repository.dart';
import 'package:lurebox/core/repositories/species_history_repository.dart';
import 'package:lurebox/core/repositories/stats_repository.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';

class MockFishCatchRepository extends Mock implements FishCatchRepository {}

class MockSpeciesHistoryRepository extends Mock
    implements SpeciesHistoryRepository {}

class MockStatsRepository extends Mock implements StatsRepository {}

class FakeFishCatch extends Fake implements FishCatch {}

class FakeSpeciesHistory extends Fake implements SpeciesHistory {}

void main() {
  late FishCatchService service;
  late MockFishCatchRepository mockRepository;
  late MockSpeciesHistoryRepository mockSpeciesHistoryRepo;
  late MockStatsRepository mockStatsRepo;

  setUpAll(() {
    registerFallbackValue(FakeFishCatch());
    registerFallbackValue(FakeSpeciesHistory());
    registerFallbackValue(const FishFilter());
  });

  setUp(() {
    mockRepository = MockFishCatchRepository();
    mockSpeciesHistoryRepo = MockSpeciesHistoryRepository();
    mockStatsRepo = MockStatsRepository();
    service = FishCatchService(
      mockRepository,
      mockSpeciesHistoryRepo,
      mockStatsRepo,
    );
  });

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
  }) {
    return FishCatch(
      id: id,
      imagePath: '/test/fish_$id.jpg',
      species: species,
      length: length,
      weight: weight,
      fate: fate,
      catchTime: catchTime ?? DateTime.now(),
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  group('FishCatchService', () {
    group('create', () {
      test(
          'calls repository.create() and speciesHistoryRepo.incrementUseCount()',
          () async {
        // Arrange
        final fish = _createFishCatch(species: 'Bass');
        when(() => mockRepository.create(any())).thenAnswer((_) async => 1);
        when(() => mockSpeciesHistoryRepo.incrementUseCount(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await service.create(fish);

        // Assert
        expect(result, equals(1));
        verify(() => mockRepository.create(fish)).called(1);
        verify(() => mockSpeciesHistoryRepo.incrementUseCount('Bass'))
            .called(1);
      });

      test('does not throw when repository.create() succeeds', () async {
        // Arrange
        final fish = _createFishCatch(species: 'Trout');
        when(() => mockRepository.create(any())).thenAnswer((_) async => 2);
        when(() => mockSpeciesHistoryRepo.incrementUseCount(any()))
            .thenAnswer((_) async {});

        // Act & Assert
        expect(await service.create(fish), equals(2));
        verify(() => mockRepository.create(fish)).called(1);
      });
    });

    group('delete', () {
      test('calls repository.delete() when fish exists', () async {
        // Arrange
        final fish = _createFishCatch(id: 5, species: 'Bass');
        when(() => mockRepository.getById(5)).thenAnswer((_) async => fish);
        when(() => mockRepository.delete(5)).thenAnswer((_) async {});

        // Act
        await service.delete(5);

        // Assert
        verify(() => mockRepository.getById(5)).called(1);
        verify(() => mockRepository.delete(5)).called(1);
      });

      test('does not throw when image cleanup fails during delete', () async {
        // Arrange
        final fish = _createFishCatch(id: 10, species: 'Bass');
        when(() => mockRepository.getById(10)).thenAnswer((_) async => fish);
        when(() => mockRepository.delete(10)).thenAnswer((_) async {});

        // Act & Assert - should not throw even if image file operations fail
        await expectLater(service.delete(10), completes);
        verify(() => mockRepository.delete(10)).called(1);
      });

      test('calls repository.delete() when fish does not exist', () async {
        // Arrange
        when(() => mockRepository.getById(999)).thenAnswer((_) async => null);
        when(() => mockRepository.delete(999)).thenAnswer((_) async {});

        // Act
        await service.delete(999);

        // Assert
        verify(() => mockRepository.getById(999)).called(1);
        verify(() => mockRepository.delete(999)).called(1);
      });
    });

    group('deleteMultiple', () {
      test('deletes multiple records', () async {
        // Arrange
        final fish1 = _createFishCatch(id: 1, species: 'Bass');
        final fish2 = _createFishCatch(id: 2, species: 'Trout');
        final fish3 = _createFishCatch(id: 3, species: 'Pike');

        when(() => mockRepository.getById(1)).thenAnswer((_) async => fish1);
        when(() => mockRepository.getById(2)).thenAnswer((_) async => fish2);
        when(() => mockRepository.getById(3)).thenAnswer((_) async => fish3);
        when(() => mockRepository.deleteMultiple([1, 2, 3]))
            .thenAnswer((_) async {});

        // Act
        await service.deleteMultiple([1, 2, 3]);

        // Assert
        verify(() => mockRepository.getById(1)).called(1);
        verify(() => mockRepository.getById(2)).called(1);
        verify(() => mockRepository.getById(3)).called(1);
        verify(() => mockRepository.deleteMultiple([1, 2, 3])).called(1);
      });

      test('handles null fish in deleteMultiple', () async {
        // Arrange
        when(() => mockRepository.getById(1)).thenAnswer((_) async => null);
        when(() => mockRepository.getById(2))
            .thenAnswer((_) async => _createFishCatch(id: 2));
        when(() => mockRepository.deleteMultiple([1, 2]))
            .thenAnswer((_) async {});

        // Act
        await service.deleteMultiple([1, 2]);

        // Assert
        verify(() => mockRepository.deleteMultiple([1, 2])).called(1);
      });
    });

    group('update', () {
      test('delegates to repository.update()', () async {
        // Arrange
        final fish = _createFishCatch(id: 5, species: 'Bass');
        when(() => mockRepository.update(any())).thenAnswer((_) async {});

        // Act
        await service.update(fish);

        // Assert
        verify(() => mockRepository.update(fish)).called(1);
      });
    });

    group('getFilteredPage', () {
      test('delegates to repository.getFilteredPage()', () async {
        // Arrange
        final paginatedResult = PaginatedResult<FishCatch>(
          items: [
            _createFishCatch(id: 1, species: 'Bass'),
            _createFishCatch(id: 2, species: 'Trout'),
          ],
          totalCount: 2,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );

        when(() => mockRepository.getFilteredPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              fate: any(named: 'fate'),
              species: any(named: 'species'),
              orderBy: any(named: 'orderBy'),
            )).thenAnswer((_) async => paginatedResult);

        // Act
        final result = await service.getFilteredPage(
          page: 1,
          pageSize: 20,
          species: 'Bass',
        );

        // Assert
        expect(result.items.length, equals(2));
        expect(result.totalCount, equals(2));
        verify(() => mockRepository.getFilteredPage(
              page: 1,
              pageSize: 20,
              startDate: null,
              endDate: null,
              fate: null,
              species: 'Bass',
              orderBy: 'catch_time DESC',
            )).called(1);
      });

      test('passes all filter parameters to repository', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 12, 31);
        final paginatedResult = PaginatedResult<FishCatch>(
          items: [],
          totalCount: 0,
          page: 2,
          pageSize: 10,
          hasMore: false,
        );

        when(() => mockRepository.getFilteredPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              fate: any(named: 'fate'),
              species: any(named: 'species'),
              orderBy: any(named: 'orderBy'),
            )).thenAnswer((_) async => paginatedResult);

        // Act
        await service.getFilteredPage(
          page: 2,
          pageSize: 10,
          startDate: startDate,
          endDate: endDate,
          fate: FishFateType.keep,
          species: 'Trout',
          orderBy: 'length DESC',
        );

        // Assert
        verify(() => mockRepository.getFilteredPage(
              page: 2,
              pageSize: 10,
              startDate: startDate,
              endDate: endDate,
              fate: FishFateType.keep,
              species: 'Trout',
              orderBy: 'length DESC',
            )).called(1);
      });
    });

    group('getById', () {
      test('returns fish when exists', () async {
        final fish = _createFishCatch(id: 5, species: 'Bass');
        when(() => mockRepository.getById(5)).thenAnswer((_) async => fish);

        final result = await service.getById(5);

        expect(result, equals(fish));
        verify(() => mockRepository.getById(5)).called(1);
      });

      test('returns null when not found', () async {
        when(() => mockRepository.getById(999)).thenAnswer((_) async => null);

        final result = await service.getById(999);

        expect(result, isNull);
        verify(() => mockRepository.getById(999)).called(1);
      });
    });

    group('getAll', () {
      test('returns all fish from repository', () async {
        final fishList = [
          _createFishCatch(id: 1, species: 'Bass'),
          _createFishCatch(id: 2, species: 'Trout'),
        ];
        when(() => mockRepository.getAll()).thenAnswer((_) async => fishList);

        final result = await service.getAll();

        expect(result.length, equals(2));
        verify(() => mockRepository.getAll()).called(1);
      });

      test('returns empty list when no fish', () async {
        when(() => mockRepository.getAll()).thenAnswer((_) async => []);

        final result = await service.getAll();

        expect(result, isEmpty);
        verify(() => mockRepository.getAll()).called(1);
      });
    });

    group('getByDateRange', () {
      test('delegates to repository', () async {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 12, 31);
        final fishList = [_createFishCatch(id: 1)];
        when(() => mockRepository.getByDateRange(start, end))
            .thenAnswer((_) async => fishList);

        final result = await service.getByDateRange(start, end);

        expect(result, equals(fishList));
        verify(() => mockRepository.getByDateRange(start, end)).called(1);
      });
    });

    group('getByFate', () {
      test('delegates to repository with release fate', () async {
        final fishList = [
          _createFishCatch(id: 1, fate: FishFateType.release),
          _createFishCatch(id: 2, fate: FishFateType.release),
        ];
        when(() => mockRepository.getByFate(FishFateType.release))
            .thenAnswer((_) async => fishList);

        final result = await service.getByFate(FishFateType.release);

        expect(result.length, equals(2));
        verify(() => mockRepository.getByFate(FishFateType.release)).called(1);
      });

      test('delegates to repository with keep fate', () async {
        final fishList = [_createFishCatch(id: 1, fate: FishFateType.keep)];
        when(() => mockRepository.getByFate(FishFateType.keep))
            .thenAnswer((_) async => fishList);

        final result = await service.getByFate(FishFateType.keep);

        expect(result.length, equals(1));
        verify(() => mockRepository.getByFate(FishFateType.keep)).called(1);
      });
    });

    group('getPage', () {
      test('delegates to repository with default parameters', () async {
        final paginatedResult = PaginatedResult<FishCatch>(
          items: [_createFishCatch(id: 1)],
          totalCount: 1,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            )).thenAnswer((_) async => paginatedResult);

        final result = await service.getPage(page: 1);

        expect(result.items.length, equals(1));
        verify(() => mockRepository.getPage(
              page: 1,
              pageSize: 20,
              orderBy: 'catch_time DESC',
            )).called(1);
      });

      test('passes custom parameters to repository', () async {
        final paginatedResult = PaginatedResult<FishCatch>(
          items: [],
          totalCount: 0,
          page: 2,
          pageSize: 10,
          hasMore: false,
        );
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            )).thenAnswer((_) async => paginatedResult);

        await service.getPage(
          page: 2,
          pageSize: 10,
          orderBy: 'length ASC',
        );

        verify(() => mockRepository.getPage(
              page: 2,
              pageSize: 10,
              orderBy: 'length ASC',
            )).called(1);
      });
    });

    group('getCount', () {
      test('delegates to repository', () async {
        when(() => mockRepository.getCount()).thenAnswer((_) async => 42);

        final result = await service.getCount();

        expect(result, equals(42));
        verify(() => mockRepository.getCount()).called(1);
      });
    });

    group('getTop3LongestCatches', () {
      test('delegates to stats repository', () async {
        final fishList = [
          _createFishCatch(id: 1, length: 50.0),
          _createFishCatch(id: 2, length: 45.0),
          _createFishCatch(id: 3, length: 40.0),
        ];
        when(() => mockStatsRepo.getTop3LongestCatches())
            .thenAnswer((_) async => fishList);

        final result = await service.getTop3LongestCatches();

        expect(result.length, equals(3));
        verify(() => mockStatsRepo.getTop3LongestCatches()).called(1);
      });

      test('returns empty list when no catches', () async {
        when(() => mockStatsRepo.getTop3LongestCatches())
            .thenAnswer((_) async => []);

        final result = await service.getTop3LongestCatches();

        expect(result, isEmpty);
      });
    });

    group('getSpeciesStats', () {
      test('delegates to stats repository without date range', () async {
        final stats = {'Bass': 10, 'Trout': 5};
        when(() => mockStatsRepo.getSpeciesStats(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => stats);

        final result = await service.getSpeciesStats();

        expect(result, equals(stats));
        verify(() => mockStatsRepo.getSpeciesStats(
              startDate: null,
              endDate: null,
            )).called(1);
      });

      test('passes date range to stats repository', () async {
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 6, 30);
        when(() => mockStatsRepo.getSpeciesStats(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => {});

        await service.getSpeciesStats(startDate: startDate, endDate: endDate);

        verify(() => mockStatsRepo.getSpeciesStats(
              startDate: startDate,
              endDate: endDate,
            )).called(1);
      });
    });

    group('getAllEquipmentCatchStats', () {
      test('builds combined stats map', () async {
        when(() => mockStatsRepo.getEquipmentCatchStats())
            .thenAnswer((_) async => {
                  1: EquipmentCatchStats(
                    equipmentId: 1,
                    catchCount: 5,
                    avgLength: 30.0,
                    avgWeight: 2.0,
                    releaseCount: 3,
                  ),
                });
        when(() => mockStatsRepo.getAllEquipmentSpeciesStats())
            .thenAnswer((_) async => {
                  1: {'Bass': 3, 'Trout': 2},
                });

        final result = await service.getAllEquipmentCatchStats();

        expect(result[1], equals({'_total': 5, 'Bass': 3, 'Trout': 2}));
      });

      test('handles empty stats', () async {
        when(() => mockStatsRepo.getEquipmentCatchStats())
            .thenAnswer((_) async => {});
        when(() => mockStatsRepo.getAllEquipmentSpeciesStats())
            .thenAnswer((_) async => {});

        final result = await service.getAllEquipmentCatchStats();

        expect(result, isEmpty);
      });
    });

    group('getEquipmentDistribution', () {
      test('delegates to stats repository', () async {
        final distribution = {'spinning': 10, 'casting': 5};
        when(() => mockStatsRepo.getEquipmentDistribution(
              any(),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => distribution);

        final result = await service.getEquipmentDistribution('rod');

        expect(result, equals(distribution));
      });
    });

    group('getEquipmentCatchStats', () {
      test('delegates to stats repository', () async {
        when(() => mockStatsRepo.getEquipmentCatchStats())
            .thenAnswer((_) async => {
                  1: EquipmentCatchStats(
                    equipmentId: 1,
                    catchCount: 5,
                    avgLength: 30.0,
                    avgWeight: 2.0,
                    releaseCount: 3,
                  ),
                });

        final result = await service.getEquipmentCatchStats(1);

        expect(result, equals({'_total': 5}));
      });

      test('returns zero count for unknown equipment', () async {
        when(() => mockStatsRepo.getEquipmentCatchStats())
            .thenAnswer((_) async => {});

        final result = await service.getEquipmentCatchStats(999);

        expect(result, equals({'_total': 0}));
      });
    });

    group('getSpeciesHistory', () {
      test('returns species names from repository', () async {
        final now = DateTime.now();
        final history = [
          SpeciesHistory(id: 1, name: 'Bass', useCount: 10, createdAt: now),
          SpeciesHistory(id: 2, name: 'Trout', useCount: 5, createdAt: now),
        ];
        when(() => mockSpeciesHistoryRepo.getAll(limit: any(named: 'limit')))
            .thenAnswer((_) async => history);

        final result = await service.getSpeciesHistory();

        expect(result, equals(['Bass', 'Trout']));
      });

      test('passes limit to repository', () async {
        when(() => mockSpeciesHistoryRepo.getAll(limit: any(named: 'limit')))
            .thenAnswer((_) async => []);

        await service.getSpeciesHistory(limit: 100);

        verify(() => mockSpeciesHistoryRepo.getAll(limit: 100)).called(1);
      });
    });

    group('updateSpeciesHistory', () {
      test('calls speciesHistoryRepo.incrementUseCount', () async {
        when(() => mockSpeciesHistoryRepo.incrementUseCount(any()))
            .thenAnswer((_) async {});

        await service.updateSpeciesHistory('Bass');

        verify(() => mockSpeciesHistoryRepo.incrementUseCount('Bass')).called(1);
      });
    });

    group('deleteSpeciesHistory', () {
      test('calls speciesHistoryRepo.softDelete', () async {
        when(() => mockSpeciesHistoryRepo.softDelete(any()))
            .thenAnswer((_) async {});

        await service.deleteSpeciesHistory('Bass');

        verify(() => mockSpeciesHistoryRepo.softDelete('Bass')).called(1);
      });
    });

    group('restoreSpeciesHistory', () {
      test('calls speciesHistoryRepo.restore', () async {
        when(() => mockSpeciesHistoryRepo.restore(any()))
            .thenAnswer((_) async {});

        await service.restoreSpeciesHistory('Bass');

        verify(() => mockSpeciesHistoryRepo.restore('Bass')).called(1);
      });
    });

    group('getFilteredPageByFilter', () {
      test('delegates to repository with FishFilter', () async {
        final filter = FishFilter(
          timeFilter: 'month',
          fateFilter: FishFateType.release,
          speciesFilter: 'Bass',
        );
        final paginatedResult = PaginatedResult<FishCatch>(
          items: [_createFishCatch(id: 1, species: 'Bass')],
          totalCount: 1,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );
        when(() => mockRepository.getFilteredPageByFilter(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              filter: any(named: 'filter'),
            )).thenAnswer((_) async => paginatedResult);

        final result = await service.getFilteredPageByFilter(
          page: 1,
          filter: filter,
        );

        expect(result.items.length, equals(1));
        verify(() => mockRepository.getFilteredPageByFilter(
              page: 1,
              pageSize: 20,
              filter: filter,
            )).called(1);
      });
    });
  });
}
