import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/di.dart';
import '../models/fish_catch.dart';
import '../repositories/fish_catch_repository.dart';

final fishCatchesProviderV2 = FutureProvider<List<FishCatch>>((ref) async {
  final service = ref.watch(fishCatchServiceProvider);
  return await service.getAll();
});

final fishCatchByIdProvider = FutureProvider.family<FishCatch?, int>((
  ref,
  id,
) async {
  final service = ref.watch(fishCatchServiceProvider);
  return await service.getById(id);
});

final fishCatchesByDateRangeProvider =
    FutureProvider.family<List<FishCatch>, ({DateTime start, DateTime end})>((
  ref,
  params,
) async {
  final service = ref.watch(fishCatchServiceProvider);
  return await service.getByDateRange(params.start, params.end);
});

final fishCatchesByFateProvider =
    FutureProvider.family<List<FishCatch>, FishFateType>((ref, fate) async {
  final service = ref.watch(fishCatchServiceProvider);
  return await service.getByFate(fate);
});

final paginatedFishCatchesProvider = FutureProvider.family<
    PaginatedResult<FishCatch>,
    ({int page, int pageSize, String? orderBy})>((ref, params) async {
  final service = ref.watch(fishCatchServiceProvider);
  return await service.getPage(
    page: params.page,
    pageSize: params.pageSize,
    orderBy: params.orderBy ?? 'catch_time DESC',
  );
});

final filteredPaginatedFishCatchesProvider = FutureProvider.family<
    PaginatedResult<FishCatch>,
    ({
      int page,
      int pageSize,
      DateTime? startDate,
      DateTime? endDate,
      FishFateType? fate,
      String? species,
      String? orderBy,
    })>((ref, params) async {
  final service = ref.watch(fishCatchServiceProvider);
  return await service.getFilteredPage(
    page: params.page,
    pageSize: params.pageSize,
    startDate: params.startDate,
    endDate: params.endDate,
    fate: params.fate,
    species: params.species,
    orderBy: params.orderBy ?? 'catch_time DESC',
  );
});

final fishCatchCountProviderV2 = FutureProvider<int>((ref) async {
  final service = ref.watch(fishCatchServiceProvider);
  return await service.getCount();
});

final top3LongestCatchesProvider = FutureProvider<List<FishCatch>>((ref) async {
  final service = ref.watch(fishCatchServiceProvider);
  return await service.getTop3LongestCatches();
});

final speciesStatsProvider =
    FutureProvider.family<Map<String, int>, ({DateTime start, DateTime end})>((
  ref,
  params,
) async {
  final service = ref.watch(fishCatchServiceProvider);
  return await service.getSpeciesStats(
    startDate: params.start,
    endDate: params.end,
  );
});

final equipmentCatchStatsProvider = FutureProvider<Map<int, Map<String, int>>>((
  ref,
) async {
  final service = ref.watch(fishCatchServiceProvider);
  return await service.getAllEquipmentCatchStats();
});

final equipmentDistributionProvider = FutureProvider.family<Map<String, int>,
    ({String type, DateTime start, DateTime end})>((ref, params) async {
  final service = ref.watch(fishCatchServiceProvider);
  return await service.getEquipmentDistribution(
    params.type,
    startDate: params.start,
    endDate: params.end,
  );
});
