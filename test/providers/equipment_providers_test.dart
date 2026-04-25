import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/models/paginated_result.dart';
import 'package:lurebox/core/providers/equipment_providers.dart';
import 'package:lurebox/core/services/equipment_service.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:mocktail/mocktail.dart';

class MockEquipmentService extends Mock implements EquipmentService {}

class FakeEquipment extends Fake implements Equipment {}

/// Fake EquipmentService that returns configurable data
class FakeEquipmentService implements EquipmentService {
  List<Equipment> getAllResult = [];
  Equipment? getByIdResult;
  Equipment? getDefaultEquipmentResult;
  PaginatedResult<Equipment> getPageResult = const PaginatedResult(
    items: [],
    totalCount: 0,
    page: 1,
    pageSize: 20,
    hasMore: false,
  );
  Map<String, int> getStatsResult = {};
  List<String> getBrandsResult = [];
  List<String> getModelsByBrandResult = [];
  Map<String, int> getCategoryDistributionResult = {};

  int getAllCalls = 0;
  int getByIdCalls = 0;
  int getDefaultEquipmentCalls = 0;
  int getPageCalls = 0;
  int getStatsCalls = 0;
  int getBrandsCalls = 0;
  int getModelsByBrandCalls = 0;
  int getCategoryDistributionCalls = 0;

  @override
  Future<List<Equipment>> getAll({String? type}) async {
    getAllCalls++;
    return getAllResult;
  }

  @override
  Future<Equipment?> getById(int id) async {
    getByIdCalls++;
    return getByIdResult;
  }

  @override
  Future<Equipment?> getDefaultEquipment(String type) async {
    getDefaultEquipmentCalls++;
    return getDefaultEquipmentResult;
  }

  @override
  Future<int> create(Equipment equipment) async => 1;

  @override
  Future<void> update(Equipment equipment) async {}

  @override
  Future<void> delete(int id) async {}

  @override
  Future<PaginatedResult<Equipment>> getPage({
    required int page,
    int pageSize = 20,
    String? type,
    String orderBy = 'is_default DESC, created_at DESC',
  }) async {
    getPageCalls++;
    return getPageResult;
  }

  @override
  Future<PaginatedResult<Equipment>> getFilteredPage({
    required int page,
    int pageSize = 20,
    String? type,
    String? brand,
    String? model,
    String? category,
    String orderBy = 'is_default DESC, created_at DESC',
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
  Future<void> setDefaultEquipment(int id, String type) async {}

  @override
  Future<Map<String, int>> getStats() async {
    getStatsCalls++;
    return getStatsResult;
  }

  @override
  Future<List<String>> getBrands() async {
    getBrandsCalls++;
    return getBrandsResult;
  }

  @override
  Future<List<String>> getModelsByBrand(String brand) async {
    getModelsByBrandCalls++;
    return getModelsByBrandResult;
  }

  @override
  Future<Map<String, int>> getCategoryDistribution(String type) async {
    getCategoryDistributionCalls++;
    return getCategoryDistributionResult;
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeEquipment());
  });

  group('equipmentProviderV2', () {
    late ProviderContainer container;
    late FakeEquipmentService fakeService;

    setUp(() {
      fakeService = FakeEquipmentService();
      container = ProviderContainer(
        overrides: [
          equipmentServiceProvider.overrideWithValue(fakeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('returns list of equipment when type is null', () async {
      final rod = _createEquipment(id: 1, type: EquipmentType.rod, brand: 'Shimano');
      final reel = _createEquipment(id: 2, type: EquipmentType.reel, brand: 'Shimano');
      fakeService.getAllResult = [rod, reel];

      final result = await container.read(equipmentProviderV2(null).future);

      expect(result.length, equals(2));
      expect(fakeService.getAllCalls, equals(1));
    });

    test('returns list of equipment filtered by type', () async {
      final rod = _createEquipment(id: 1, type: EquipmentType.rod, brand: 'Shimano');
      fakeService.getAllResult = [rod];

      final result = await container.read(equipmentProviderV2('rod').future);

      expect(result.length, equals(1));
      expect(result.first.type, equals(EquipmentType.rod));
    });

    test('returns empty list when no equipment', () async {
      fakeService.getAllResult = [];

      final result = await container.read(equipmentProviderV2(null).future);

      expect(result, isEmpty);
    });

    test('returns loading state initially', () {
      fakeService.getAllResult = [];
      final asyncValue = container.read(equipmentProviderV2(null));
      expect(asyncValue.isLoading, isTrue);
    });
  });

  group('equipmentByIdProvider', () {
    late ProviderContainer container;
    late FakeEquipmentService fakeService;

    setUp(() {
      fakeService = FakeEquipmentService();
      container = ProviderContainer(
        overrides: [
          equipmentServiceProvider.overrideWithValue(fakeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('returns Equipment when found', () async {
      final equipment = _createEquipment(id: 1, type: EquipmentType.rod, brand: 'Shimano');
      fakeService.getByIdResult = equipment;

      final result = await container.read(equipmentByIdProvider(1).future);

      expect(result, isNotNull);
      expect(result!.id, equals(1));
      expect(fakeService.getByIdCalls, equals(1));
    });

    test('returns null when not found', () async {
      fakeService.getByIdResult = null;

      final result = await container.read(equipmentByIdProvider(999).future);

      expect(result, isNull);
    });

    test('returns loading state initially', () {
      fakeService.getByIdResult = null;
      final asyncValue = container.read(equipmentByIdProvider(1));
      expect(asyncValue.isLoading, isTrue);
    });
  });

  group('defaultEquipmentProvider', () {
    late ProviderContainer container;
    late FakeEquipmentService fakeService;

    setUp(() {
      fakeService = FakeEquipmentService();
      container = ProviderContainer(
        overrides: [
          equipmentServiceProvider.overrideWithValue(fakeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('returns default equipment for type', () async {
      final defaultRod = _createEquipment(
        id: 1,
        type: EquipmentType.rod,
        brand: 'Shimano',
        isDefault: true,
      );
      fakeService.getDefaultEquipmentResult = defaultRod;

      final result = await container.read(defaultEquipmentProvider('rod').future);

      expect(result, isNotNull);
      expect(result!.isDefault, isTrue);
      expect(fakeService.getDefaultEquipmentCalls, equals(1));
    });

    test('returns null when no default exists for type', () async {
      fakeService.getDefaultEquipmentResult = null;

      final result = await container.read(defaultEquipmentProvider('lure').future);

      expect(result, isNull);
    });

    test('returns loading state initially', () {
      fakeService.getDefaultEquipmentResult = null;
      final asyncValue = container.read(defaultEquipmentProvider('rod'));
      expect(asyncValue.isLoading, isTrue);
    });
  });

  group('paginatedEquipmentProvider', () {
    late ProviderContainer container;
    late FakeEquipmentService fakeService;

    setUp(() {
      fakeService = FakeEquipmentService();
      container = ProviderContainer(
        overrides: [
          equipmentServiceProvider.overrideWithValue(fakeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('returns paginated results', () async {
      final equipment = _createEquipment(id: 1, type: EquipmentType.rod);
      fakeService.getPageResult = PaginatedResult(
        items: [equipment],
        totalCount: 1,
        page: 1,
        pageSize: 20,
        hasMore: false,
      );

      final result = await container.read(
        paginatedEquipmentProvider((page: 1, pageSize: 20, type: null, orderBy: null))
            .future,
      );

      expect(result.items.length, equals(1));
      expect(result.totalCount, equals(1));
      expect(result.page, equals(1));
      expect(result.hasMore, isFalse);
    });

    test('respects page and pageSize params', () async {
      fakeService.getPageResult = const PaginatedResult(
        items: [],
        totalCount: 50,
        page: 2,
        pageSize: 10,
        hasMore: true,
      );

      final result = await container.read(
        paginatedEquipmentProvider((page: 2, pageSize: 10, type: null, orderBy: null))
            .future,
      );

      expect(result.page, equals(2));
      expect(result.pageSize, equals(10));
      expect(result.hasMore, isTrue);
    });

    test('returns empty paginated result when no data', () async {
      fakeService.getPageResult = const PaginatedResult(
        items: [],
        totalCount: 0,
        page: 1,
        pageSize: 20,
        hasMore: false,
      );

      final result = await container.read(
        paginatedEquipmentProvider((page: 1, pageSize: 20, type: null, orderBy: null))
            .future,
      );

      expect(result.items, isEmpty);
      expect(result.totalCount, equals(0));
    });

    test('returns loading state initially', () {
      fakeService.getPageResult = const PaginatedResult(
        items: [],
        totalCount: 0,
        page: 1,
        pageSize: 20,
        hasMore: false,
      );
      final asyncValue = container.read(
        paginatedEquipmentProvider((page: 1, pageSize: 20, type: null, orderBy: null)),
      );
      expect(asyncValue.isLoading, isTrue);
    });
  });

  group('equipmentStatsProvider', () {
    late ProviderContainer container;
    late FakeEquipmentService fakeService;

    setUp(() {
      fakeService = FakeEquipmentService();
      container = ProviderContainer(
        overrides: [
          equipmentServiceProvider.overrideWithValue(fakeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('returns equipment stats map', () async {
      fakeService.getStatsResult = {
        'rod': 5,
        'reel': 3,
        'lure': 20,
      };

      final result = await container.read(equipmentStatsProvider.future);

      expect(result['rod'], equals(5));
      expect(result['reel'], equals(3));
      expect(result['lure'], equals(20));
      expect(fakeService.getStatsCalls, equals(1));
    });

    test('returns empty map when no stats', () async {
      fakeService.getStatsResult = {};

      final result = await container.read(equipmentStatsProvider.future);

      expect(result, isEmpty);
    });

    test('returns loading state initially', () {
      fakeService.getStatsResult = {};
      final asyncValue = container.read(equipmentStatsProvider);
      expect(asyncValue.isLoading, isTrue);
    });
  });

  group('brandsProvider', () {
    late ProviderContainer container;
    late FakeEquipmentService fakeService;

    setUp(() {
      fakeService = FakeEquipmentService();
      container = ProviderContainer(
        overrides: [
          equipmentServiceProvider.overrideWithValue(fakeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('returns list of brand strings', () async {
      fakeService.getBrandsResult = ['Shimano', 'Abu Garcia', ' Daiwa'];

      final result = await container.read(brandsProvider.future);

      expect(result.length, equals(3));
      expect(result, contains('Shimano'));
      expect(fakeService.getBrandsCalls, equals(1));
    });

    test('returns empty list when no brands', () async {
      fakeService.getBrandsResult = [];

      final result = await container.read(brandsProvider.future);

      expect(result, isEmpty);
    });

    test('returns loading state initially', () {
      fakeService.getBrandsResult = [];
      final asyncValue = container.read(brandsProvider);
      expect(asyncValue.isLoading, isTrue);
    });
  });

  group('modelsByBrandProvider', () {
    late ProviderContainer container;
    late FakeEquipmentService fakeService;

    setUp(() {
      fakeService = FakeEquipmentService();
      container = ProviderContainer(
        overrides: [
          equipmentServiceProvider.overrideWithValue(fakeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('returns models for specific brand', () async {
      fakeService.getModelsByBrandResult = ['Stella', 'Stradivair', 'Nasci'];

      final result = await container.read(modelsByBrandProvider('Shimano').future);

      expect(result.length, equals(3));
      expect(result, contains('Stella'));
      expect(fakeService.getModelsByBrandCalls, equals(1));
    });

    test('returns empty list when brand has no models', () async {
      fakeService.getModelsByBrandResult = [];

      final result = await container.read(modelsByBrandProvider('Unknown').future);

      expect(result, isEmpty);
    });

    test('returns loading state initially', () {
      fakeService.getModelsByBrandResult = [];
      final asyncValue = container.read(modelsByBrandProvider('Shimano'));
      expect(asyncValue.isLoading, isTrue);
    });
  });
}

Equipment _createEquipment({
  required int id,
  required EquipmentType type,
  String? brand,
  String? model,
  bool isDefault = false,
}) {
  final now = DateTime.now();
  return Equipment(
    id: id,
    type: type,
    brand: brand,
    model: model,
    isDefault: isDefault,
    createdAt: now,
    updatedAt: now,
  );
}
