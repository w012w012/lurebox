import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/repositories/equipment_repository.dart';

final equipmentProviderV2 = FutureProvider.family<List<Equipment>, String?>((
  ref,
  type,
) async {
  final service = ref.watch(equipmentServiceProvider);
  return service.getAll(type: type);
});

final equipmentByIdProvider = FutureProvider.family<Equipment?, int>((
  ref,
  id,
) async {
  final service = ref.watch(equipmentServiceProvider);
  return service.getById(id);
});

final defaultEquipmentProvider = FutureProvider.family<Equipment?, String>((
  ref,
  type,
) async {
  final service = ref.watch(equipmentServiceProvider);
  return service.getDefaultEquipment(type);
});

final paginatedEquipmentProvider = FutureProvider.family<
    PaginatedResult<Equipment>,
    ({
      int page,
      int pageSize,
      String? type,
      String? orderBy
    })>((ref, params) async {
  final service = ref.watch(equipmentServiceProvider);
  return service.getPage(
    page: params.page,
    pageSize: params.pageSize,
    type: params.type,
    orderBy: params.orderBy ?? 'is_default DESC, created_at DESC',
  );
});

final filteredPaginatedEquipmentProvider = FutureProvider.family<
    PaginatedResult<Equipment>,
    ({
      int page,
      int pageSize,
      String? type,
      String? brand,
      String? model,
      String? category,
      String? orderBy,
    })>((ref, params) async {
  final service = ref.watch(equipmentServiceProvider);
  return service.getFilteredPage(
    page: params.page,
    pageSize: params.pageSize,
    type: params.type,
    brand: params.brand,
    model: params.model,
    category: params.category,
    orderBy: params.orderBy ?? 'is_default DESC, created_at DESC',
  );
});

final equipmentStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(equipmentServiceProvider);
  return service.getStats();
});

final brandsProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(equipmentServiceProvider);
  return service.getBrands();
});

final modelsByBrandProvider = FutureProvider.family<List<String>, String>((
  ref,
  brand,
) async {
  final service = ref.watch(equipmentServiceProvider);
  return service.getModelsByBrand(brand);
});

final categoryDistributionProvider =
    FutureProvider.family<Map<String, int>, String>((ref, type) async {
  final service = ref.watch(equipmentServiceProvider);
  return service.getCategoryDistribution(type);
});
