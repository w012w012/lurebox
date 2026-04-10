import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/models/fish_catch.dart';
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

void main() {
  late FishCatchService service;
  late MockFishCatchRepository mockRepository;
  late MockSpeciesHistoryRepository mockSpeciesHistoryRepo;
  late MockStatsRepository mockStatsRepo;

  setUpAll(() {
    registerFallbackValue(FakeFishCatch());
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
  });
}
