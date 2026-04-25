import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/fish_filter.dart';
import 'package:lurebox/core/models/paginated_result.dart';
import 'package:lurebox/core/providers/fish_providers.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:mocktail/mocktail.dart';

class FakeFishCatch extends Fake implements FishCatch {}

/// Fake FishCatchService that returns configurable data for testing
class FakeFishCatchService implements FishCatchService {
  List<FishCatch> getAllResult = [];
  List<FishCatch> getByDateRangeResult = [];
  List<FishCatch> getByFateResult = [];
  List<FishCatch> getTop3LongestCatchesResult = [];
  Map<String, int> getSpeciesStatsResult = {};
  int getCountResult = 0;
  int getAllCalls = 0;
  int getByIdCalls = 0;
  int getByDateRangeCalls = 0;
  int getByFateCalls = 0;
  int getPageCalls = 0;
  int getCountCalls = 0;
  int getTop3LongestCalls = 0;
  int getSpeciesStatsCalls = 0;
  Object? getAllError;
  Object? getByIdError;
  Object? getByDateRangeError;
  Object? getByFateError;
  Object? getPageError;
  Object? getCountError;
  Object? getTop3LongestError;
  Object? getSpeciesStatsError;
  FishCatch? getByIdResult;
  PaginatedResult<FishCatch>? getPageResult;

  void reset() {
    getAllResult = [];
    getByDateRangeResult = [];
    getByFateResult = [];
    getTop3LongestCatchesResult = [];
    getSpeciesStatsResult = {};
    getCountResult = 0;
    getAllCalls = 0;
    getByIdCalls = 0;
    getByDateRangeCalls = 0;
    getByFateCalls = 0;
    getPageCalls = 0;
    getCountCalls = 0;
    getTop3LongestCalls = 0;
    getSpeciesStatsCalls = 0;
    getAllError = null;
    getByIdError = null;
    getByDateRangeError = null;
    getByFateError = null;
    getPageError = null;
    getCountError = null;
    getTop3LongestError = null;
    getSpeciesStatsError = null;
    getByIdResult = null;
    getPageResult = null;
  }

  @override
  Future<List<FishCatch>> getAll() async {
    getAllCalls++;
    if (getAllError != null) throw getAllError!;
    return getAllResult;
  }

  @override
  Future<FishCatch?> getById(int id) async {
    getByIdCalls++;
    if (getByIdError != null) throw getByIdError!;
    return getByIdResult;
  }

  @override
  Future<int> create(FishCatch fish) async => 1;

  @override
  Future<void> update(FishCatch fish) async {}

  @override
  Future<void> delete(int id) async {}

  @override
  Future<List<FishCatch>> getByDateRange(DateTime start, DateTime end) async {
    getByDateRangeCalls++;
    if (getByDateRangeError != null) throw getByDateRangeError!;
    return getByDateRangeResult;
  }

  @override
  Future<List<FishCatch>> getByFate(FishFateType fate) async {
    getByFateCalls++;
    if (getByFateError != null) throw getByFateError!;
    return getByFateResult;
  }

  @override
  Future<PaginatedResult<FishCatch>> getPage({
    required int page,
    int pageSize = 20,
    String? orderBy,
  }) async {
    getPageCalls++;
    if (getPageError != null) throw getPageError!;
    return getPageResult ??
        PaginatedResult(
          items: const [],
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
    return PaginatedResult(
      items: const [],
      totalCount: 0,
      page: 1,
      pageSize: 20,
      hasMore: false,
    );
  }

  @override
  Future<PaginatedResult<FishCatch>> getFilteredPageByFilter({
    required int page,
    required FishFilter filter,
    int pageSize = 20,
  }) async {
    return PaginatedResult(
      items: const [],
      totalCount: 0,
      page: 1,
      pageSize: 20,
      hasMore: false,
    );
  }

  @override
  Future<int> getCount() async {
    getCountCalls++;
    if (getCountError != null) throw getCountError!;
    return getCountResult;
  }

  @override
  Future<List<FishCatch>> getTop3LongestCatches() async {
    getTop3LongestCalls++;
    if (getTop3LongestError != null) throw getTop3LongestError!;
    return getTop3LongestCatchesResult;
  }

  @override
  Future<Map<String, int>> getSpeciesStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    getSpeciesStatsCalls++;
    if (getSpeciesStatsError != null) throw getSpeciesStatsError!;
    return getSpeciesStatsResult;
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
}

FishCatch _createFishCatch({
  required int id,
  required String species,
  required FishFateType fate,
  required DateTime catchTime,
  double length = 30.0,
  double? weight,
}) {
  return FishCatch(
    id: id,
    imagePath: '/test/fish_$id.jpg',
    species: species,
    length: length,
    weight: weight,
    fate: fate,
    catchTime: catchTime,
    pendingRecognition: false,
    createdAt: catchTime,
    updatedAt: catchTime,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeFishCatch());
    registerFallbackValue(DateTime.now());
    registerFallbackValue(FishFateType.release);
  });

  group('fishCatchesProviderV2', () {
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

    test('returns list of fish catches from service', () async {
      final now = DateTime.now();
      fakeService.getAllResult = [
        _createFishCatch(id: 1, species: 'Bass', fate: FishFateType.release, catchTime: now),
        _createFishCatch(id: 2, species: 'Trout', fate: FishFateType.keep, catchTime: now),
      ];

      final result = await container.read(fishCatchesProviderV2.future);

      expect(result.length, equals(2));
      expect(result[0].species, equals('Bass'));
      expect(result[1].species, equals('Trout'));
      expect(fakeService.getAllCalls, equals(1));
    });

    test('returns empty list when no catches', () async {
      fakeService.getAllResult = [];

      final result = await container.read(fishCatchesProviderV2.future);

      expect(result, isEmpty);
      expect(fakeService.getAllCalls, equals(1));
    });

    test('returns loading state initially', () {
      fakeService.getAllResult = [];
      final asyncValue = container.read(fishCatchesProviderV2);
      expect(asyncValue.isLoading, isTrue);
    });

    test('handles service error', () async {
      fakeService.getAllError = Exception('Database error');

      container = ProviderContainer(
        overrides: [
          fishCatchServiceProvider.overrideWithValue(fakeService),
        ],
      );

      await expectLater(
        container.read(fishCatchesProviderV2.future),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('fishCatchByIdProvider', () {
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

    test('returns fish catch when found', () async {
      final now = DateTime.now();
      fakeService.getByIdResult = _createFishCatch(
        id: 1,
        species: 'Bass',
        fate: FishFateType.release,
        catchTime: now,
      );

      final result = await container.read(fishCatchByIdProvider(1).future);

      expect(result, isNotNull);
      expect(result!.species, equals('Bass'));
      expect(fakeService.getByIdCalls, equals(1));
    });

    test('returns null when fish catch not found', () async {
      fakeService.getByIdResult = null;

      final result = await container.read(fishCatchByIdProvider(999).future);

      expect(result, isNull);
      expect(fakeService.getByIdCalls, equals(1));
    });

    test('returns loading state initially', () {
      fakeService.getByIdResult = null;
      final asyncValue = container.read(fishCatchByIdProvider(1));
      expect(asyncValue.isLoading, isTrue);
    });

    test('handles service error', () async {
      fakeService.getByIdError = Exception('Database error');

      container = ProviderContainer(
        overrides: [
          fishCatchServiceProvider.overrideWithValue(fakeService),
        ],
      );

      await expectLater(
        container.read(fishCatchByIdProvider(1).future),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('fishCatchesByDateRangeProvider', () {
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

    test('returns catches within date range', () async {
      final start = DateTime(2024, 6, 1);
      final end = DateTime(2024, 6, 30);
      final now = DateTime(2024, 6, 15);
      fakeService.getByDateRangeResult = [
        _createFishCatch(id: 1, species: 'Bass', fate: FishFateType.release, catchTime: now),
        _createFishCatch(id: 2, species: 'Trout', fate: FishFateType.keep, catchTime: now),
      ];

      final result = await container.read(
        fishCatchesByDateRangeProvider((start: start, end: end)).future,
      );

      expect(result.length, equals(2));
      expect(fakeService.getByDateRangeCalls, equals(1));
    });

    test('returns empty list when no matches', () async {
      final start = DateTime(2024, 6, 1);
      final end = DateTime(2024, 6, 30);
      fakeService.getByDateRangeResult = [];

      final result = await container.read(
        fishCatchesByDateRangeProvider((start: start, end: end)).future,
      );

      expect(result, isEmpty);
    });

    test('returns loading state initially', () {
      fakeService.getByDateRangeResult = [];
      final start = DateTime(2024, 6, 1);
      final end = DateTime(2024, 6, 30);
      final asyncValue = container.read(
        fishCatchesByDateRangeProvider((start: start, end: end)),
      );
      expect(asyncValue.isLoading, isTrue);
    });

    test('handles service error', () async {
      fakeService.getByDateRangeError = Exception('Database error');
      final start = DateTime(2024, 6, 1);
      final end = DateTime(2024, 6, 30);

      container = ProviderContainer(
        overrides: [
          fishCatchServiceProvider.overrideWithValue(fakeService),
        ],
      );

      await expectLater(
        container.read(
          fishCatchesByDateRangeProvider((start: start, end: end)).future,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('fishCatchesByFateProvider', () {
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

    test('returns catches with release fate', () async {
      final now = DateTime.now();
      fakeService.getByFateResult = [
        _createFishCatch(id: 1, species: 'Bass', fate: FishFateType.release, catchTime: now),
        _createFishCatch(id: 2, species: 'Trout', fate: FishFateType.release, catchTime: now),
      ];

      final result = await container.read(
        fishCatchesByFateProvider(FishFateType.release).future,
      );

      expect(result.length, equals(2));
      expect(fakeService.getByFateCalls, equals(1));
    });

    test('returns catches with keep fate', () async {
      final now = DateTime.now();
      fakeService.getByFateResult = [
        _createFishCatch(id: 1, species: 'Bass', fate: FishFateType.keep, catchTime: now),
      ];

      final result = await container.read(
        fishCatchesByFateProvider(FishFateType.keep).future,
      );

      expect(result.length, equals(1));
      expect(result[0].fate, equals(FishFateType.keep));
    });

    test('returns empty list when no matches', () async {
      fakeService.getByFateResult = [];

      final result = await container.read(
        fishCatchesByFateProvider(FishFateType.release).future,
      );

      expect(result, isEmpty);
    });

    test('returns loading state initially', () {
      fakeService.getByFateResult = [];
      final asyncValue = container.read(fishCatchesByFateProvider(FishFateType.release));
      expect(asyncValue.isLoading, isTrue);
    });

    test('handles service error', () async {
      fakeService.getByFateError = Exception('Database error');

      container = ProviderContainer(
        overrides: [
          fishCatchServiceProvider.overrideWithValue(fakeService),
        ],
      );

      await expectLater(
        container.read(fishCatchesByFateProvider(FishFateType.release).future),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('paginatedFishCatchesProvider', () {
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

    test('returns paginated results with default orderBy', () async {
      final now = DateTime.now();
      fakeService.getPageResult = PaginatedResult(
        items: [
          _createFishCatch(id: 1, species: 'Bass', fate: FishFateType.release, catchTime: now),
          _createFishCatch(id: 2, species: 'Trout', fate: FishFateType.keep, catchTime: now),
        ],
        totalCount: 10,
        page: 1,
        pageSize: 20,
        hasMore: true,
      );

      final result = await container.read(
        paginatedFishCatchesProvider((page: 1, pageSize: 20, orderBy: null)).future,
      );

      expect(result.items.length, equals(2));
      expect(result.totalCount, equals(10));
      expect(result.hasMore, isTrue);
      expect(fakeService.getPageCalls, equals(1));
    });

    test('respects page and pageSize params', () async {
      fakeService.getPageResult = PaginatedResult(
        items: const [],
        totalCount: 100,
        page: 3,
        pageSize: 10,
        hasMore: false,
      );

      final result = await container.read(
        paginatedFishCatchesProvider((page: 3, pageSize: 10, orderBy: null)).future,
      );

      expect(result.page, equals(3));
      expect(result.pageSize, equals(10));
    });

    test('returns empty list when no catches', () async {
      fakeService.getPageResult = PaginatedResult(
        items: const [],
        totalCount: 0,
        page: 1,
        pageSize: 20,
        hasMore: false,
      );

      final result = await container.read(
        paginatedFishCatchesProvider((page: 1, pageSize: 20, orderBy: null)).future,
      );

      expect(result.items, isEmpty);
      expect(result.totalCount, equals(0));
    });

    test('returns loading state initially', () {
      fakeService.getPageResult = PaginatedResult(
        items: const [],
        totalCount: 0,
        page: 1,
        pageSize: 20,
        hasMore: false,
      );
      final asyncValue = container.read(
        paginatedFishCatchesProvider((page: 1, pageSize: 20, orderBy: null)),
      );
      expect(asyncValue.isLoading, isTrue);
    });

    test('handles service error', () async {
      fakeService.getPageError = Exception('Database error');

      container = ProviderContainer(
        overrides: [
          fishCatchServiceProvider.overrideWithValue(fakeService),
        ],
      );

      await expectLater(
        container.read(
          paginatedFishCatchesProvider((page: 1, pageSize: 20, orderBy: null)).future,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('fishCatchCountProviderV2', () {
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

    test('returns count of all catches', () async {
      fakeService.getCountResult = 42;

      final result = await container.read(fishCatchCountProviderV2.future);

      expect(result, equals(42));
      expect(fakeService.getCountCalls, equals(1));
    });

    test('returns zero when no catches', () async {
      fakeService.getCountResult = 0;

      final result = await container.read(fishCatchCountProviderV2.future);

      expect(result, equals(0));
    });

    test('returns loading state initially', () {
      fakeService.getCountResult = 0;
      final asyncValue = container.read(fishCatchCountProviderV2);
      expect(asyncValue.isLoading, isTrue);
    });

    test('handles service error', () async {
      fakeService.getCountError = Exception('Database error');

      container = ProviderContainer(
        overrides: [
          fishCatchServiceProvider.overrideWithValue(fakeService),
        ],
      );

      await expectLater(
        container.read(fishCatchCountProviderV2.future),
        throwsA(isA<Exception>()),
      );
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

    test('returns top 3 longest catches', () async {
      final now = DateTime.now();
      fakeService.getTop3LongestCatchesResult = [
        _createFishCatch(id: 1, species: 'Bass', length: 50, fate: FishFateType.release, catchTime: now),
        _createFishCatch(id: 2, species: 'Trout', length: 45, fate: FishFateType.release, catchTime: now),
        _createFishCatch(id: 3, species: 'Carp', length: 40, fate: FishFateType.keep, catchTime: now),
      ];

      final result = await container.read(top3LongestCatchesProvider.future);

      expect(result.length, equals(3));
      expect(result[0].length, equals(50));
      expect(result[1].length, equals(45));
      expect(result[2].length, equals(40));
      expect(fakeService.getTop3LongestCalls, equals(1));
    });

    test('returns empty list when no catches', () async {
      fakeService.getTop3LongestCatchesResult = [];

      final result = await container.read(top3LongestCatchesProvider.future);

      expect(result, isEmpty);
    });

    test('returns loading state initially', () {
      fakeService.getTop3LongestCatchesResult = [];
      final asyncValue = container.read(top3LongestCatchesProvider);
      expect(asyncValue.isLoading, isTrue);
    });

    test('handles service error', () async {
      fakeService.getTop3LongestError = Exception('Database error');

      container = ProviderContainer(
        overrides: [
          fishCatchServiceProvider.overrideWithValue(fakeService),
        ],
      );

      await expectLater(
        container.read(top3LongestCatchesProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('speciesStatsProvider', () {
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

    test('returns species distribution stats', () async {
      fakeService.getSpeciesStatsResult = {
        'Bass': 10,
        'Trout': 5,
        'Carp': 3,
      };

      final result = await container.read(
        speciesStatsProvider((start: DateTime(2024), end: DateTime(2024, 12, 31))).future,
      );

      expect(result['Bass'], equals(10));
      expect(result['Trout'], equals(5));
      expect(result['Carp'], equals(3));
      expect(fakeService.getSpeciesStatsCalls, equals(1));
    });

    test('returns empty map when no catches', () async {
      fakeService.getSpeciesStatsResult = {};

      final result = await container.read(
        speciesStatsProvider((start: DateTime(2024), end: DateTime(2024, 12, 31))).future,
      );

      expect(result, isEmpty);
    });

    test('returns loading state initially', () {
      fakeService.getSpeciesStatsResult = {};
      final asyncValue = container.read(
        speciesStatsProvider((start: DateTime(2024), end: DateTime(2024, 12, 31))),
      );
      expect(asyncValue.isLoading, isTrue);
    });

    test('handles service error', () async {
      fakeService.getSpeciesStatsError = Exception('Database error');

      container = ProviderContainer(
        overrides: [
          fishCatchServiceProvider.overrideWithValue(fakeService),
        ],
      );

      await expectLater(
        container.read(
          speciesStatsProvider((start: DateTime(2024), end: DateTime(2024, 12, 31))).future,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
