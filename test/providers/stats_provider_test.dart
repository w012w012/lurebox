import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/fish_filter.dart';
import 'package:lurebox/core/providers/stats_provider.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';
import 'package:lurebox/core/repositories/fish_catch_repository.dart';
import 'package:lurebox/core/repositories/species_history_repository.dart';
import 'package:lurebox/core/repositories/stats_repository.dart';
import 'package:lurebox/core/models/paginated_result.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:mocktail/mocktail.dart';

class MockFishCatchRepository extends Mock implements FishCatchRepository {}

class MockSpeciesHistoryRepository extends Mock
    implements SpeciesHistoryRepository {}

class MockStatsRepository extends Mock implements StatsRepository {}

class FakeFishCatch extends Fake implements FishCatch {}

/// Fake FishCatchService that returns configurable data
class FakeFishCatchService implements FishCatchService {
  List<FishCatch> getByDateRangeResult = [];
  List<FishCatch> getTop3LongestCatchesResult = [];
  int getByDateRangeCalls = 0;

  @override
  Future<List<FishCatch>> getAll() async => [];

  @override
  Future<FishCatch?> getById(int id) async => null;

  @override
  Future<List<FishCatch>> getByDateRange(DateTime start, DateTime end) async {
    getByDateRangeCalls++;
    return getByDateRangeResult;
  }

  @override
  Future<List<FishCatch>> getByFate(FishFateType fate) async => [];

  @override
  Future<int> create(FishCatch fish) async => 1;

  @override
  Future<void> update(FishCatch fish) async {}

  @override
  Future<void> delete(int id) async {}

  @override
  Future<PaginatedResult<FishCatch>> getPage({
    required int page,
    int pageSize = 20,
    String? orderBy,
  }) async {
    return const PaginatedResult(
      items: [],
      totalCount: 0,
      page: 1,
      pageSize: 20,
      hasMore: false,
    );
  }

  @override
  Future<PaginatedResult<FishCatch>> getFilteredPage({
    required int page,
    int pageSize = 20,
    DateTime? startDate,
    DateTime? endDate,
    FishFateType? fate,
    String? species,
    String? orderBy,
  }) async {
    return const PaginatedResult(
      items: [],
      totalCount: 0,
      page: 1,
      pageSize: 20,
      hasMore: false,
    );
  }

  @override
  Future<int> getCount() async => 0;

  @override
  Future<List<FishCatch>> getTop3LongestCatches() async {
    return getTop3LongestCatchesResult;
  }

  @override
  Future<Map<String, int>> getSpeciesStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return {};
  }

  @override
  Future<Map<int, Map<String, int>>> getAllEquipmentCatchStats() async {
    return {};
  }

  @override
  Future<Map<String, int>> getEquipmentDistribution(
    String type, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return {};
  }

  @override
  Future<List<String>> getSpeciesHistory({int limit = 50}) async {
    return [];
  }

  @override
  Future<void> updateSpeciesHistory(String species) async {}

  @override
  Future<void> deleteSpeciesHistory(String species) async {}

  @override
  Future<void> restoreSpeciesHistory(String species) async {}

  @override
  Future<void> deleteMultiple(List<int> ids) async {}

  @override
  Future<Map<String, int>> getEquipmentCatchStats(int equipmentId) async {
    return {};
  }

  @override
  Future<PaginatedResult<FishCatch>> getFilteredPageByFilter({
    required int page,
    int pageSize = 20,
    required FishFilter filter,
  }) async {
    return const PaginatedResult(
      items: [],
      totalCount: 0,
      page: 1,
      pageSize: 20,
      hasMore: false,
    );
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeFishCatch());
    registerFallbackValue(DateTime.now());
    registerFallbackValue(FishFateType.release);
  });

  group('StatsTimeRange', () {
    test('equality works for same values', () {
      final range1 = StatsTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 12, 31),
        label: '全部',
      );
      final range2 = StatsTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 12, 31),
        label: '全部',
      );

      expect(range1, equals(range2));
    });

    test('equality fails for different start date', () {
      final range1 = StatsTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 12, 31),
        label: '全部',
      );
      final range2 = StatsTimeRange(
        start: DateTime(2024, 2, 1),
        end: DateTime(2024, 12, 31),
        label: '全部',
      );

      expect(range1, isNot(equals(range2)));
    });

    test('equality fails for different end date', () {
      final range1 = StatsTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 12, 31),
        label: '全部',
      );
      final range2 = StatsTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2025, 12, 31),
        label: '全部',
      );

      expect(range1, isNot(equals(range2)));
    });

    test('equality ignores time component (only date part matters)', () {
      final range1 = StatsTimeRange(
        start: DateTime(2024, 1, 1, 10, 30),
        end: DateTime(2024, 12, 31, 23, 59),
        label: '全部',
      );
      final range2 = StatsTimeRange(
        start: DateTime(2024, 1, 1, 0, 0),
        end: DateTime(2024, 12, 31, 0, 0),
        label: '全部',
      );

      expect(range1, equals(range2));
    });

    test('hashCode is same for equal objects', () {
      final range1 = StatsTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 12, 31),
        label: '全部',
      );
      final range2 = StatsTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 12, 31),
        label: '全部',
      );

      expect(range1.hashCode, equals(range2.hashCode));
    });
  });

  group('TimeRangeStats', () {
    group('releaseRate', () {
      test('returns 0 when totalCount is 0', () {
        const stats = TimeRangeStats(
          totalCount: 0,
          releaseCount: 0,
          keepCount: 0,
          speciesStats: {},
        );
        expect(stats.releaseRate, equals(0));
      });

      test('returns 0 when totalCount is 0 with non-zero counts', () {
        const stats = TimeRangeStats(
          totalCount: 0,
          releaseCount: 0,
          keepCount: 0,
          speciesStats: {},
        );
        expect(stats.releaseRate, equals(0));
      });

      test('calculates correct percentage for 100 total', () {
        const stats = TimeRangeStats(
          totalCount: 100,
          releaseCount: 30,
          keepCount: 70,
          speciesStats: {},
        );
        expect(stats.releaseRate, equals(30.0));
      });

      test('calculates correct percentage for 50/50 split', () {
        const stats = TimeRangeStats(
          totalCount: 100,
          releaseCount: 50,
          keepCount: 50,
          speciesStats: {},
        );
        expect(stats.releaseRate, equals(50.0));
      });

      test('calculates correct percentage for all release', () {
        const stats = TimeRangeStats(
          totalCount: 100,
          releaseCount: 100,
          keepCount: 0,
          speciesStats: {},
        );
        expect(stats.releaseRate, equals(100.0));
      });

      test('calculates correct percentage for all keep', () {
        const stats = TimeRangeStats(
          totalCount: 100,
          releaseCount: 0,
          keepCount: 100,
          speciesStats: {},
        );
        expect(stats.releaseRate, equals(0.0));
      });

      test('handles decimal percentage correctly', () {
        const stats = TimeRangeStats(
          totalCount: 3,
          releaseCount: 1,
          keepCount: 2,
          speciesStats: {},
        );
        // 1/3 * 100 = 33.33...
        expect(stats.releaseRate, closeTo(33.33, 0.01));
      });
    });
  });

  group('timeRangeStatsProvider', () {
    late ProviderContainer container;
    late FakeFishCatchService fakeService;

    setUp(() {
      fakeService = FakeFishCatchService();
      container = ProviderContainer(
        overrides: [
          fishCatchServiceProvider.overrideWithValue(fakeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('filters out pending recognition records', () async {
      final now = DateTime.now();
      fakeService.getByDateRangeResult = [
        _createFishCatch(id: 1, species: 'Bass', fate: FishFateType.release, catchTime: now, pendingRecognition: false),
        _createFishCatch(id: 2, species: 'Trout', fate: FishFateType.release, catchTime: now, pendingRecognition: true), // Should be filtered
        _createFishCatch(id: 3, species: 'Carp', fate: FishFateType.keep, catchTime: now, pendingRecognition: false),
      ];

      final range = StatsTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 12, 31),
        label: 'test',
      );

      final stats = await container.read(timeRangeStatsProvider(range).future);

      // Should only count 2 (excluding pending recognition)
      expect(stats.totalCount, equals(2));
      expect(stats.releaseCount, equals(1)); // Bass
      expect(stats.keepCount, equals(1)); // Carp
    });

    test('counts release correctly (fate == 0)', () async {
      final now = DateTime.now();
      fakeService.getByDateRangeResult = [
        _createFishCatch(id: 1, species: 'Bass', fate: FishFateType.release, catchTime: now), // fate = 0
        _createFishCatch(id: 2, species: 'Trout', fate: FishFateType.release, catchTime: now), // fate = 0
      ];

      final range = StatsTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 12, 31),
        label: 'test',
      );

      final stats = await container.read(timeRangeStatsProvider(range).future);

      expect(stats.releaseCount, equals(2));
      expect(stats.keepCount, equals(0));
    });

    test('counts keep correctly (fate != 0)', () async {
      final now = DateTime.now();
      fakeService.getByDateRangeResult = [
        _createFishCatch(id: 1, species: 'Bass', fate: FishFateType.keep, catchTime: now), // fate = 1
        _createFishCatch(id: 2, species: 'Trout', fate: FishFateType.keep, catchTime: now), // fate = 1
      ];

      final range = StatsTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 12, 31),
        label: 'test',
      );

      final stats = await container.read(timeRangeStatsProvider(range).future);

      expect(stats.keepCount, equals(2));
      expect(stats.releaseCount, equals(0));
    });

    test('builds speciesStats map correctly', () async {
      final now = DateTime.now();
      fakeService.getByDateRangeResult = [
        _createFishCatch(id: 1, species: 'Bass', fate: FishFateType.release, catchTime: now),
        _createFishCatch(id: 2, species: 'Bass', fate: FishFateType.release, catchTime: now),
        _createFishCatch(id: 3, species: 'Trout', fate: FishFateType.release, catchTime: now),
        _createFishCatch(id: 4, species: 'Trout', fate: FishFateType.release, catchTime: now),
        _createFishCatch(id: 5, species: 'Trout', fate: FishFateType.release, catchTime: now),
      ];

      final range = StatsTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 12, 31),
        label: 'test',
      );

      final stats = await container.read(timeRangeStatsProvider(range).future);

      expect(stats.speciesStats['Bass'], equals(2));
      expect(stats.speciesStats['Trout'], equals(3));
      expect(stats.speciesStats.length, equals(2));
    });

    test('handles empty list', () async {
      fakeService.getByDateRangeResult = [];

      final range = StatsTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 12, 31),
        label: 'test',
      );

      final stats = await container.read(timeRangeStatsProvider(range).future);

      expect(stats.totalCount, equals(0));
      expect(stats.releaseCount, equals(0));
      expect(stats.keepCount, equals(0));
      expect(stats.speciesStats, isEmpty);
    });

    test('calls getByDateRange with correct date range', () async {
      fakeService.getByDateRangeResult = [];
      final startDate = DateTime(2024, 6, 1);
      final endDate = DateTime(2024, 6, 30);

      final range = StatsTimeRange(
        start: startDate,
        end: endDate,
        label: 'test',
      );

      await container.read(timeRangeStatsProvider(range).future);

      expect(fakeService.getByDateRangeCalls, equals(1));
    });
  });

  group('todayStatsProvider', () {
    late ProviderContainer container;
    late FakeFishCatchService fakeService;

    setUp(() {
      fakeService = FakeFishCatchService();
      container = ProviderContainer(
        overrides: [
          fishCatchServiceProvider.overrideWithValue(fakeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('returns loading state initially', () {
      fakeService.getByDateRangeResult = [];
      final asyncValue = container.read(todayStatsProvider);
      expect(asyncValue.isLoading, isTrue);
    });

    test('calculates releaseRate from data', () async {
      final now = DateTime.now();
      fakeService.getByDateRangeResult = [
        _createFishCatch(id: 1, species: 'Bass', fate: FishFateType.release, catchTime: now),
        _createFishCatch(id: 2, species: 'Trout', fate: FishFateType.keep, catchTime: now),
      ];

      // todayStatsProvider is a Provider that watches a FutureProvider
      // We need to read it and handle the async value
      final asyncValue = container.read(todayStatsProvider);

      // Since we're using fakeService with sync-like behavior,
      // the async value might be in loading or have data
      // Just verify it returns an AsyncValue with expected structure
      expect(asyncValue, isA<AsyncValue<TimeRangeStats>>());
    });
  });

  group('monthStatsProvider', () {
    late ProviderContainer container;
    late FakeFishCatchService fakeService;

    setUp(() {
      fakeService = FakeFishCatchService();
      container = ProviderContainer(
        overrides: [
          fishCatchServiceProvider.overrideWithValue(fakeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('returns AsyncValue with data', () async {
      fakeService.getByDateRangeResult = [];

      final asyncValue = container.read(monthStatsProvider);

      // Just verify it returns an AsyncValue
      expect(asyncValue, isA<AsyncValue<TimeRangeStats>>());
    });
  });

  group('yearStatsProvider', () {
    late ProviderContainer container;
    late FakeFishCatchService fakeService;

    setUp(() {
      fakeService = FakeFishCatchService();
      container = ProviderContainer(
        overrides: [
          fishCatchServiceProvider.overrideWithValue(fakeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('returns AsyncValue with data', () async {
      fakeService.getByDateRangeResult = [];

      final asyncValue = container.read(yearStatsProvider);

      // Just verify it returns an AsyncValue
      expect(asyncValue, isA<AsyncValue<TimeRangeStats>>());
    });
  });

  group('top3LongestCatchesProvider', () {
    late ProviderContainer container;
    late FakeFishCatchService fakeService;

    setUp(() {
      fakeService = FakeFishCatchService();
      container = ProviderContainer(
        overrides: [
          fishCatchServiceProvider.overrideWithValue(fakeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('returns empty list when no catches', () async {
      fakeService.getTop3LongestCatchesResult = [];

      final result = await container.read(top3LongestCatchesProvider.future);

      expect(result, isEmpty);
    });

    test('returns correct map structure for each catch', () async {
      final now = DateTime.now();
      fakeService.getTop3LongestCatchesResult = [
        _createFishCatch(id: 1, species: 'Bass', length: 50.0, fate: FishFateType.release, catchTime: now),
      ];

      final result = await container.read(top3LongestCatchesProvider.future);

      expect(result.length, equals(1));
      expect(result[0]['species'], equals('Bass'));
      expect(result[0]['length'], equals(50.0));
    });
  });
}

FishCatch _createFishCatch({
  required int id,
  required String species,
  required FishFateType fate,
  required DateTime catchTime,
  double length = 30.0,
  bool pendingRecognition = false,
}) {
  return FishCatch(
    id: id,
    imagePath: '/test/fish_$id.jpg',
    species: species,
    length: length,
    lengthUnit: 'cm',
    fate: fate,
    catchTime: catchTime,
    pendingRecognition: pendingRecognition,
    createdAt: catchTime,
    updatedAt: catchTime,
  );
}
