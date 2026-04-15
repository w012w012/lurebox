import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/models/paginated_result.dart';
import 'package:lurebox/core/repositories/equipment_repository.dart';
import 'package:lurebox/core/services/equipment_service.dart';

/// In-memory fake implementing EquipmentRepository for unit testing.
class FakeEquipmentRepository implements EquipmentRepository {
  final Map<int, Equipment> _store = {};
  int _nextId = 1;

  void reset() {
    _store.clear();
    _nextId = 1;
  }

  @override
  Future<List<Equipment>> getAll({String? type}) async {
    return _store.values
        .where((e) =>
            !e.isDeleted && (type == null || e.type.name == _typeStr(type)))
        .toList();
  }

  @override
  Future<Equipment?> getById(int id) async {
    return _store[id];
  }

  @override
  Future<Equipment?> getDefaultEquipment(String type) async {
    try {
      return _store.values.firstWhere(
        (e) => !e.isDeleted && e.type.name == type && e.isDefault,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> create(Equipment equipment) async {
    final id = _nextId++;
    _store[id] = equipment.copyWith(id: id);
    return id;
  }

  @override
  Future<void> update(Equipment equipment) async {
    _store[equipment.id] = equipment;
  }

  @override
  Future<void> delete(int id) async {
    _store.remove(id);
  }

  @override
  Future<PaginatedResult<Equipment>> getPage({
    required int page,
    int pageSize = 20,
    String? type,
    String orderBy = 'is_default DESC, created_at DESC',
  }) async {
    final all = await getAll(type: type);
    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    return PaginatedResult(
      items: all.sublist(start, end.clamp(0, all.length)),
      totalCount: all.length,
      page: page,
      pageSize: pageSize,
      hasMore: end < all.length,
    );
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
    var all = await getAll(type: type);
    if (brand != null) all = all.where((e) => e.brand == brand).toList();
    if (model != null) all = all.where((e) => e.model == model).toList();
    if (category != null) {
      all = all.where((e) => e.category == category).toList();
    }
    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    return PaginatedResult(
      items: all.sublist(start, end.clamp(0, all.length)),
      totalCount: all.length,
      page: page,
      pageSize: pageSize,
      hasMore: end < all.length,
    );
  }

  @override
  Future<void> setDefaultEquipment(int id, String type) async {
    // Clear existing default for this type
    for (final entry in _store.entries) {
      if (entry.value.type.name == type && entry.value.isDefault) {
        _store[entry.key] = entry.value.copyWith(isDefault: false);
      }
    }
    // Set new default
    if (_store.containsKey(id)) {
      _store[id] = _store[id]!.copyWith(isDefault: true);
    }
  }

  @override
  Future<Map<String, int>> getStats() async {
    final stats = <String, int>{};
    for (final e in _store.values.where((e) => !e.isDeleted)) {
      stats[e.type.name] = (stats[e.type.name] ?? 0) + 1;
    }
    return stats;
  }

  @override
  Future<List<String>> getBrands() async {
    final brands = <String>{};
    for (final e in _store.values.where((e) => !e.isDeleted)) {
      if (e.brand != null) brands.add(e.brand!);
    }
    return brands.toList()..sort();
  }

  @override
  Future<List<String>> getModelsByBrand(String brand) async {
    final models = <String>{};
    for (final e in _store.values
        .where((e) => !e.isDeleted && e.brand == brand && e.model != null)) {
      models.add(e.model!);
    }
    return models.toList()..sort();
  }

  @override
  Future<Map<String, int>> getCategoryDistribution(String type) async {
    final dist = <String, int>{};
    for (final e in _store.values.where(
        (e) => !e.isDeleted && e.type.name == type && e.category != null)) {
      dist[e.category!] = (dist[e.category!] ?? 0) + 1;
    }
    return dist;
  }

  String _typeStr(String t) {
    return EquipmentType.values
        .firstWhere((e) => e.value == t, orElse: () => EquipmentType.rod)
        .name;
  }
}

void main() {
  late FakeEquipmentRepository repository;
  late EquipmentService service;

  setUp(() {
    repository = FakeEquipmentRepository();
    service = EquipmentService(repository);
  });

  group('EquipmentService delegation', () {
    test('getAll delegates to repository', () async {
      await repository.create(_makeRod(id: 1, brand: 'Shimano'));
      await repository.create(_makeRod(id: 2, brand: 'Daiwa'));

      final result = await service.getAll();

      expect(result.length, equals(2));
      expect(result.map((e) => e.brand), containsAll(['Shimano', 'Daiwa']));
    });

    test('getAll with type filter delegates to repository', () async {
      await repository.create(_makeRod(id: 1));
      await repository.create(_makeReel(id: 2));
      await repository.create(_makeLure(id: 3));

      final result = await service.getAll(type: 'rod');

      expect(result.length, equals(1));
      expect(result.first.type, equals(EquipmentType.rod));
    });

    test('getById returns equipment when found', () async {
      await repository.create(_makeRod(id: 1, brand: 'Shimano'));

      final result = await service.getById(1);

      expect(result, isNotNull);
      expect(result!.brand, equals('Shimano'));
    });

    test('getById returns null when not found', () async {
      final result = await service.getById(999);
      expect(result, isNull);
    });

    test('create delegates to repository and returns new id', () async {
      final id = await service.create(_makeRod(id: 0));
      expect(id, greaterThan(0));
      expect(await repository.getById(id), isNotNull);
    });

    test('update delegates to repository', () async {
      await repository.create(_makeRod(id: 1, brand: 'Old'));

      await service.update(_makeRod(id: 1, brand: 'New'));

      expect((await repository.getById(1))!.brand, equals('New'));
    });

    test('delete delegates to repository', () async {
      await repository.create(_makeRod(id: 1));

      await service.delete(1);

      expect(await repository.getById(1), isNull);
    });
  });

  group('EquipmentService.getPage', () {
    test('returns PaginatedResult structure', () async {
      for (int i = 0; i < 5; i++) {
        await repository.create(_makeRod(id: 0));
      }

      final result = await service.getPage(page: 1, pageSize: 3);

      expect(result, isA<PaginatedResult<Equipment>>());
      expect(result.items.length, equals(3));
      expect(result.totalCount, equals(5));
      expect(result.page, equals(1));
      expect(result.pageSize, equals(3));
      expect(result.hasMore, isTrue);
    });

    test('page 2 returns remaining items', () async {
      for (int i = 0; i < 5; i++) {
        await repository.create(_makeRod(id: 0));
      }

      final result = await service.getPage(page: 2, pageSize: 3);

      expect(result.items.length, equals(2));
      expect(result.hasMore, isFalse);
    });

    test('getFilteredPage with brand filter', () async {
      await repository.create(_makeRod(id: 0, brand: 'Shimano'));
      await repository.create(_makeRod(id: 0, brand: 'Shimano'));
      await repository.create(_makeRod(id: 0, brand: 'Daiwa'));

      final result = await service.getFilteredPage(
        page: 1,
        brand: 'Shimano',
      );

      expect(result.totalCount, equals(2));
    });
  });

  group('EquipmentService.setDefaultEquipment', () {
    test('sets new default and clears previous default for same type',
        () async {
      await repository.create(_makeRod(id: 1, isDefault: true));
      await repository.create(_makeRod(id: 2));

      await service.setDefaultEquipment(2, 'rod');

      expect((await repository.getById(2))!.isDefault, isTrue);
      expect((await repository.getById(1))!.isDefault, isFalse);
    });

    test('setting same equipment as default is idempotent', () async {
      await repository.create(_makeRod(id: 1, isDefault: true));

      await service.setDefaultEquipment(1, 'rod');

      expect((await repository.getById(1))!.isDefault, isTrue);
    });

    test('default for one type does not affect other types', () async {
      await repository.create(_makeRod(id: 1, isDefault: true));
      await repository.create(_makeReel(id: 2));

      await service.setDefaultEquipment(2, 'reel');

      expect((await repository.getById(1))!.isDefault, isTrue);
      expect((await repository.getById(2))!.isDefault, isTrue);
    });

    test('setting non-existent equipment does not throw', () async {
      await service.setDefaultEquipment(999, 'rod');
    });

    test('getDefaultEquipment returns current default', () async {
      await repository.create(_makeRod(id: 1));
      await repository.create(_makeRod(id: 2, isDefault: true));

      final result = await service.getDefaultEquipment('rod');

      expect(result, isNotNull);
      expect(result!.id, equals(2));
    });

    test('getDefaultEquipment returns null when no default', () async {
      await repository.create(_makeRod(id: 1));

      final result = await service.getDefaultEquipment('rod');

      expect(result, isNull);
    });
  });

  group('EquipmentService statistics', () {
    test('getStats returns count per type', () async {
      await repository.create(_makeRod(id: 0));
      await repository.create(_makeRod(id: 0));
      await repository.create(_makeReel(id: 0));
      await repository.create(_makeLure(id: 0));

      final stats = await service.getStats();

      expect(stats['rod'], equals(2));
      expect(stats['reel'], equals(1));
      expect(stats['lure'], equals(1));
    });

    test('getStats returns empty map when no equipment', () async {
      final stats = await service.getStats();
      expect(stats, isEmpty);
    });

    test('getBrands returns sorted list of unique brands', () async {
      await repository.create(_makeRod(id: 0, brand: 'Zebco'));
      await repository.create(_makeRod(id: 0, brand: 'Shimano'));
      await repository.create(_makeRod(id: 0, brand: 'Shimano'));

      final brands = await service.getBrands();

      expect(brands, equals(['Shimano', 'Zebco']));
    });

    test('getBrands returns empty list when no brands', () async {
      final brands = await service.getBrands();
      expect(brands, isEmpty);
    });

    test('getModelsByBrand returns sorted models for brand', () async {
      await repository
          .create(_makeRod(id: 0, brand: 'Shimano', model: 'Stradic'));
      await repository
          .create(_makeRod(id: 0, brand: 'Shimano', model: 'Curado'));
      await repository.create(_makeRod(id: 0, brand: 'Daiwa', model: 'BG'));

      final models = await service.getModelsByBrand('Shimano');

      expect(models, equals(['Curado', 'Stradic']));
    });

    test('getCategoryDistribution returns count per category', () async {
      await repository.create(_makeLure(id: 0, category: 'Crankbait'));
      await repository.create(_makeLure(id: 0, category: 'Crankbait'));
      await repository.create(_makeLure(id: 0, category: 'Spinnerbait'));

      final dist = await service.getCategoryDistribution('lure');

      expect(dist['Crankbait'], equals(2));
      expect(dist['Spinnerbait'], equals(1));
    });
  });
}

// ----- Test data helpers -----

late final _now = DateTime.now();

Equipment _makeRod(
    {int id = 1, String? brand, String? model, bool isDefault = false}) {
  return Equipment(
    id: id,
    type: EquipmentType.rod,
    brand: brand,
    model: model,
    isDefault: isDefault,
    createdAt: _now,
    updatedAt: _now,
  );
}

Equipment _makeReel({int id = 1, bool isDefault = false}) {
  return Equipment(
    id: id,
    type: EquipmentType.reel,
    isDefault: isDefault,
    createdAt: _now,
    updatedAt: _now,
  );
}

Equipment _makeLure({int id = 1, String? category, bool isDefault = false}) {
  return Equipment(
    id: id,
    type: EquipmentType.lure,
    category: category,
    isDefault: isDefault,
    createdAt: _now,
    updatedAt: _now,
  );
}
