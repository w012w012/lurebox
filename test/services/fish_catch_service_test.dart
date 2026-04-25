import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/fish_filter.dart';
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

  FishCatch createFishCatch({
    int id = 1,
    String species = 'Bass',
    double length = 30.0,
    double? weight,
    FishFateType fate = FishFateType.release,
    DateTime? catchTime,
    String? locationName,
    double? latitude,
    double? longitude,
    String? imagePath,
  }) {
    return FishCatch(
      id: id,
      imagePath: imagePath ?? '/test/fish_$id.jpg',
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
        final fish = createFishCatch();
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
        final fish = createFishCatch(species: 'Trout');
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
        final fish = createFishCatch(id: 5);
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
        final fish = createFishCatch(id: 10);
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

    group('delete — image file cleanup', () {
      late Directory tempDir;

      setUp(() async {
        tempDir = await Directory.systemTemp.createTemp('lurebox_test_');
      });

      tearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      test('deletes imagePath file when fish has a non-empty image path', () async {
        // Arrange — create a real temp file
        final imageFile = File('${tempDir.path}/fish_5.jpg');
        await imageFile.writeAsString('fake image data');
        expect(await imageFile.exists(), isTrue);

        final fish = createFishCatch(
          id: 5,
          imagePath: imageFile.path,
        );
        when(() => mockRepository.getById(5)).thenAnswer((_) async => fish);
        when(() => mockRepository.delete(5)).thenAnswer((_) async {});

        // Act
        await service.delete(5);

        // Assert — file should be gone
        expect(await imageFile.exists(), isFalse);
        verify(() => mockRepository.delete(5)).called(1);
      });

      test('deletes both imagePath and watermarkedImagePath when both exist', () async {
        final imageFile = File('${tempDir.path}/fish_6.jpg');
        final watermarkedFile = File('${tempDir.path}/fish_6_wm.jpg');
        await imageFile.writeAsString('original');
        await watermarkedFile.writeAsString('watermarked');
        expect(await imageFile.exists(), isTrue);
        expect(await watermarkedFile.exists(), isTrue);

        final now = DateTime.now();
        final fish = FishCatch(
          id: 6,
          imagePath: imageFile.path,
          watermarkedImagePath: watermarkedFile.path,
          species: 'Trout',
          length: 30,
          fate: FishFateType.release,
          catchTime: now,
          createdAt: now,
          updatedAt: now,
        );

        when(() => mockRepository.getById(6)).thenAnswer((_) async => fish);
        when(() => mockRepository.delete(6)).thenAnswer((_) async {});

        await service.delete(6);

        expect(await imageFile.exists(), isFalse);
        expect(await watermarkedFile.exists(), isFalse);
      });

      test('skips deletion when imagePath is empty string', () async {
        // FishCatch allows empty imagePath; _deleteImageFiles skips empty strings
        final fish = createFishCatch(
          id: 7,
          imagePath: '', // empty — no file to delete
        );
        when(() => mockRepository.getById(7)).thenAnswer((_) async => fish);
        when(() => mockRepository.delete(7)).thenAnswer((_) async {});

        // Should complete without error
        await service.delete(7);

        verify(() => mockRepository.delete(7)).called(1);
      });

      test('does not throw when image file does not exist on disk', () async {
        // File referenced in imagePath doesn't exist — should not throw
        final fish = createFishCatch(
          id: 8,
          species: 'Pike',
          imagePath: '${tempDir.path}/nonexistent_8.jpg',
        );
        expect(await File(fish.imagePath).exists(), isFalse);

        when(() => mockRepository.getById(8)).thenAnswer((_) async => fish);
        when(() => mockRepository.delete(8)).thenAnswer((_) async {});

        // Should not throw even though file doesn't exist
        await service.delete(8);
        verify(() => mockRepository.delete(8)).called(1);
      });

      test('deletes files before calling repository.delete()', () async {
        // Verifies the order: file deletion happens first, then DB deletion
        final imageFile = File('${tempDir.path}/fish_9.jpg');
        await imageFile.writeAsString('data');

        final fish = createFishCatch(id: 9, imagePath: imageFile.path);

        var repositoryDeleteCalled = false;
        when(() => mockRepository.getById(9)).thenAnswer((_) async => fish);
        when(() => mockRepository.delete(9)).thenAnswer((_) async {
          // When repository.delete is called, the file should already be gone
          repositoryDeleteCalled = true;
          expect(await imageFile.exists(), isFalse,
              reason: 'image should be deleted BEFORE repository.delete()',);
        });

        await service.delete(9);
        expect(repositoryDeleteCalled, isTrue);
      });
    });

    group('deleteMultiple', () {
      test('deletes multiple records', () async {
        // Arrange
        final fish1 = createFishCatch();
        final fish2 = createFishCatch(id: 2, species: 'Trout');
        final fish3 = createFishCatch(id: 3, species: 'Pike');

        when(() => mockRepository.getByIds([1, 2, 3]))
            .thenAnswer((_) async => [fish1, fish2, fish3]);
        when(() => mockRepository.deleteMultiple([1, 2, 3]))
            .thenAnswer((_) async {});

        // Act
        await service.deleteMultiple([1, 2, 3]);

        // Assert
        verify(() => mockRepository.getByIds([1, 2, 3])).called(1);
        verify(() => mockRepository.deleteMultiple([1, 2, 3])).called(1);
      });

      test('does nothing when ids is empty', () async {
        await service.deleteMultiple([]);
        verifyNever(() => mockRepository.getByIds(any()));
        verifyNever(() => mockRepository.deleteMultiple(any()));
      });
    });

    group('deleteMultiple — image file cleanup', () {
      late Directory tempDir;

      setUp(() async {
        tempDir = await Directory.systemTemp.createTemp('lurebox_test_multi_');
      });

      tearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      test('deletes image files for all fish before deleting records', () async {
        final file1 = File('${tempDir.path}/fish_1.jpg');
        final file2 = File('${tempDir.path}/fish_2.jpg');
        await file1.writeAsString('img1');
        await file2.writeAsString('img2');
        expect(await file1.exists(), isTrue);
        expect(await file2.exists(), isTrue);

        final now = DateTime.now();
        final fish1 = FishCatch(
          id: 1, imagePath: file1.path, species: 'Bass',
          length: 30, fate: FishFateType.release,
          catchTime: now, createdAt: now, updatedAt: now,
        );
        final fish2 = FishCatch(
          id: 2, imagePath: file2.path, species: 'Trout',
          length: 25, fate: FishFateType.release,
          catchTime: now, createdAt: now, updatedAt: now,
        );

        when(() => mockRepository.getByIds([1, 2]))
            .thenAnswer((_) async => [fish1, fish2]);
        when(() => mockRepository.deleteMultiple([1, 2]))
            .thenAnswer((_) async {});

        await service.deleteMultiple([1, 2]);

        expect(await file1.exists(), isFalse);
        expect(await file2.exists(), isFalse);
        verify(() => mockRepository.deleteMultiple([1, 2])).called(1);
      });

      test('skips deletion for fish not returned by getByIds', () async {
        // getByIds returns only fish that exist — fish 1 and 2, not 3
        when(() => mockRepository.getByIds([1, 2, 3]))
            .thenAnswer((_) async => [
                  createFishCatch(),
                  createFishCatch(id: 2, species: 'Trout'),
                ],);
        when(() => mockRepository.deleteMultiple([1, 2, 3]))
            .thenAnswer((_) async {});

        await service.deleteMultiple([1, 2, 3]);

        verify(() => mockRepository.deleteMultiple([1, 2, 3])).called(1);
      });

      test('deletes only files for existing fish', () async {
        final file1 = File('${tempDir.path}/fish_4.jpg');
        await file1.writeAsString('img4');

        final fish1 = createFishCatch(id: 4, imagePath: file1.path);

        when(() => mockRepository.getByIds([4, 5]))
            .thenAnswer((_) async => [fish1]);
        when(() => mockRepository.deleteMultiple([4, 5]))
            .thenAnswer((_) async {});

        await service.deleteMultiple([4, 5]);

        expect(await file1.exists(), isFalse);
        verify(() => mockRepository.deleteMultiple([4, 5])).called(1);
      });
    });

    group('update', () {
      test('delegates to repository.update()', () async {
        // Arrange
        final fish = createFishCatch(id: 5);
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
            createFishCatch(),
            createFishCatch(id: 2, species: 'Trout'),
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
            ),).thenAnswer((_) async => paginatedResult);

        // Act
        final result = await service.getFilteredPage(
          page: 1,
          species: 'Bass',
        );

        // Assert
        expect(result.items.length, equals(2));
        expect(result.totalCount, equals(2));
        verify(() => mockRepository.getFilteredPage(
              page: 1,
              species: 'Bass',
            ),).called(1);
      });

      test('passes all filter parameters to repository', () async {
        // Arrange
        final startDate = DateTime(2024);
        final endDate = DateTime(2024, 12, 31);
        const paginatedResult = PaginatedResult<FishCatch>(
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
            ),).thenAnswer((_) async => paginatedResult);

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
            ),).called(1);
      });
    });

    group('getById', () {
      test('returns fish when exists', () async {
        final fish = createFishCatch(id: 5);
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
          createFishCatch(),
          createFishCatch(id: 2, species: 'Trout'),
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
        final start = DateTime(2024);
        final end = DateTime(2024, 12, 31);
        final fishList = [createFishCatch()];
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
          createFishCatch(),
          createFishCatch(id: 2),
        ];
        when(() => mockRepository.getByFate(FishFateType.release))
            .thenAnswer((_) async => fishList);

        final result = await service.getByFate(FishFateType.release);

        expect(result.length, equals(2));
        verify(() => mockRepository.getByFate(FishFateType.release)).called(1);
      });

      test('delegates to repository with keep fate', () async {
        final fishList = [createFishCatch(fate: FishFateType.keep)];
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
          items: [createFishCatch()],
          totalCount: 1,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              orderBy: any(named: 'orderBy'),
            ),).thenAnswer((_) async => paginatedResult);

        final result = await service.getPage(page: 1);

        expect(result.items.length, equals(1));
        verify(() => mockRepository.getPage(
              page: 1,
            ),).called(1);
      });

      test('passes custom parameters to repository', () async {
        const paginatedResult = PaginatedResult<FishCatch>(
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
            ),).thenAnswer((_) async => paginatedResult);

        await service.getPage(
          page: 2,
          pageSize: 10,
          orderBy: 'length ASC',
        );

        verify(() => mockRepository.getPage(
              page: 2,
              pageSize: 10,
              orderBy: 'length ASC',
            ),).called(1);
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
          createFishCatch(length: 50),
          createFishCatch(id: 2, length: 45),
          createFishCatch(id: 3, length: 40),
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
            ),).thenAnswer((_) async => stats);

        final result = await service.getSpeciesStats();

        expect(result, equals(stats));
        verify(() => mockStatsRepo.getSpeciesStats(
              
            ),).called(1);
      });

      test('passes date range to stats repository', () async {
        final startDate = DateTime(2024);
        final endDate = DateTime(2024, 6, 30);
        when(() => mockStatsRepo.getSpeciesStats(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            ),).thenAnswer((_) async => {});

        await service.getSpeciesStats(startDate: startDate, endDate: endDate);

        verify(() => mockStatsRepo.getSpeciesStats(
              startDate: startDate,
              endDate: endDate,
            ),).called(1);
      });
    });

    group('getAllEquipmentCatchStats', () {
      test('builds combined stats map', () async {
        when(() => mockStatsRepo.getEquipmentCatchStats())
            .thenAnswer((_) async => {
                  1: const EquipmentCatchStats(
                    equipmentId: 1,
                    catchCount: 5,
                    avgLength: 30,
                    avgWeight: 2,
                    releaseCount: 3,
                  ),
                },);
        when(() => mockStatsRepo.getAllEquipmentSpeciesStats())
            .thenAnswer((_) async => {
                  1: {'Bass': 3, 'Trout': 2},
                },);

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
            ),).thenAnswer((_) async => distribution);

        final result = await service.getEquipmentDistribution('rod');

        expect(result, equals(distribution));
      });
    });

    group('getEquipmentCatchStats', () {
      test('delegates to stats repository', () async {
        when(() => mockStatsRepo.getEquipmentCatchStats())
            .thenAnswer((_) async => {
                  1: const EquipmentCatchStats(
                    equipmentId: 1,
                    catchCount: 5,
                    avgLength: 30,
                    avgWeight: 2,
                    releaseCount: 3,
                  ),
                },);

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

        verify(() => mockSpeciesHistoryRepo.getAll()).called(1);
      });
    });

    group('updateSpeciesHistory', () {
      test('calls speciesHistoryRepo.incrementUseCount', () async {
        when(() => mockSpeciesHistoryRepo.incrementUseCount(any()))
            .thenAnswer((_) async {});

        await service.updateSpeciesHistory('Bass');

        verify(() => mockSpeciesHistoryRepo.incrementUseCount('Bass'))
            .called(1);
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
        const filter = FishFilter(
          timeFilter: 'month',
          fateFilter: FishFateType.release,
          speciesFilter: 'Bass',
        );
        final paginatedResult = PaginatedResult<FishCatch>(
          items: [createFishCatch()],
          totalCount: 1,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );
        when(() => mockRepository.getFilteredPageByFilter(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              filter: any(named: 'filter'),
            ),).thenAnswer((_) async => paginatedResult);

        final result = await service.getFilteredPageByFilter(
          page: 1,
          filter: filter,
        );

        expect(result.items.length, equals(1));
        verify(() => mockRepository.getFilteredPageByFilter(
              page: 1,
              filter: filter,
            ),).called(1);
      });
    });
  });
}
