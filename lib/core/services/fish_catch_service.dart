import 'dart:io';
import 'app_logger.dart';
import '../constants/pagination_constants.dart';
import '../models/fish_catch.dart';
import '../models/fish_filter.dart';
import '../repositories/fish_catch_repository.dart';
import '../repositories/species_history_repository.dart';
import '../repositories/stats_repository.dart';

/// 渔获服务 - 渔获记录的业务逻辑层
///
/// 封装渔获数据的完整生命周期管理，包括：
/// - CRUD 操作：创建、读取、更新、删除渔获记录
/// - 分页查询：支持分页和多种筛选条件组合
/// - 统计分析：物种分布、装备使用、尺寸排名等
/// - 物种历史：自动追踪用户钓获的鱼种
///
/// 依赖 [FishCatchRepository]（数据访问）、[SpeciesHistoryRepository]（物种历史）
/// 和 [StatsRepository]（统计数据）。创建/删除渔获时会自动管理关联的图片文件。

class FishCatchService {
  final FishCatchRepository _repository;
  final SpeciesHistoryRepository _speciesHistoryRepo;
  final StatsRepository _statsRepo;

  FishCatchService(this._repository, this._speciesHistoryRepo, this._statsRepo);

  // ===== CRUD Operations =====

  Future<List<FishCatch>> getAll() async {
    return await _repository.getAll();
  }

  Future<FishCatch?> getById(int id) async {
    return await _repository.getById(id);
  }

  Future<int> create(FishCatch fish) async {
    final id = await _repository.create(fish);
    await _speciesHistoryRepo.incrementUseCount(fish.species);
    return id;
  }

  Future<void> update(FishCatch fish) async {
    await _repository.update(fish);
  }

  Future<void> delete(int id) async {
    final fish = await _repository.getById(id);
    if (fish != null) {
      await _deleteImageFiles(fish);
    }
    await _repository.delete(id);
  }

  Future<void> deleteMultiple(List<int> ids) async {
    if (ids.isEmpty) return;
    final fishList = await _repository.getByIds(ids);
    await Future.wait(fishList.map(_deleteImageFiles));
    await _repository.deleteMultiple(ids);
  }

  // ===== Query Operations =====

  Future<List<FishCatch>> getByDateRange(DateTime start, DateTime end) async {
    return await _repository.getByDateRange(start, end);
  }

  Future<List<FishCatch>> getByFate(FishFateType fate) async {
    return await _repository.getByFate(fate);
  }

  Future<PaginatedResult<FishCatch>> getPage({
    required int page,
    int pageSize = PaginationConstants.defaultPageSize,
    String orderBy = 'catch_time DESC',
  }) async {
    return await _repository.getPage(
      page: page,
      pageSize: pageSize,
      orderBy: orderBy,
    );
  }

  Future<PaginatedResult<FishCatch>> getFilteredPage({
    required int page,
    int pageSize = PaginationConstants.defaultPageSize,
    DateTime? startDate,
    DateTime? endDate,
    FishFateType? fate,
    String? species,
    String orderBy = 'catch_time DESC',
  }) async {
    return await _repository.getFilteredPage(
      page: page,
      pageSize: pageSize,
      startDate: startDate,
      endDate: endDate,
      fate: fate,
      species: species,
      orderBy: orderBy,
    );
  }

  /// Get filtered, sorted, paginated fish catches using FishFilter
  ///
  /// Uses SQL-level filtering for all filter fields
  Future<PaginatedResult<FishCatch>> getFilteredPageByFilter({
    required int page,
    int pageSize = PaginationConstants.defaultPageSize,
    required FishFilter filter,
  }) async {
    return await _repository.getFilteredPageByFilter(
      page: page,
      pageSize: pageSize,
      filter: filter,
    );
  }

  Future<int> getCount() async {
    return await _repository.getCount();
  }

  // ===== Stats Operations (delegated to StatsRepository) =====

  Future<List<FishCatch>> getTop3LongestCatches() async {
    return await _statsRepo.getTop3LongestCatches();
  }

  Future<Map<String, int>> getSpeciesStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _statsRepo.getSpeciesStats(
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<Map<int, Map<String, int>>> getAllEquipmentCatchStats() async {
    final stats = await _statsRepo.getEquipmentCatchStats();
    final speciesStats = await _statsRepo.getAllEquipmentSpeciesStats();
    final result = <int, Map<String, int>>{};

    for (final entry in stats.entries) {
      final equipmentId = entry.key;
      final catchStats = entry.value;
      // 添加总捕获数
      result[equipmentId] = {'_total': catchStats.catchCount};
      // 添加鱼种统计
      if (speciesStats.containsKey(equipmentId)) {
        for (final speciesEntry in speciesStats[equipmentId]!.entries) {
          result[equipmentId]![speciesEntry.key] = speciesEntry.value;
        }
      }
    }
    return result;
  }

  Future<Map<String, int>> getEquipmentDistribution(
    String type, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _statsRepo.getEquipmentDistribution(
      type,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<Map<String, int>> getEquipmentCatchStats(int equipmentId) async {
    final allStats = await _statsRepo.getEquipmentCatchStats();
    final stats = allStats[equipmentId];
    if (stats == null) {
      return {'_total': 0};
    }
    return {'_total': stats.catchCount};
  }

  // ===== Species History Operations (delegated to SpeciesHistoryRepository) =====

  Future<void> updateSpeciesHistory(String name) async {
    await _speciesHistoryRepo.incrementUseCount(name);
  }

  Future<List<String>> getSpeciesHistory({int limit = 50}) async {
    final history = await _speciesHistoryRepo.getAll(limit: limit);
    return history.map((h) => h.name).toList();
  }

  Future<void> deleteSpeciesHistory(String name) async {
    await _speciesHistoryRepo.softDelete(name);
  }

  Future<void> restoreSpeciesHistory(String name) async {
    await _speciesHistoryRepo.restore(name);
  }

  // ===== Private Helpers =====

  Future<void> _deleteImageFiles(FishCatch fish) async {
    final files = <String?>[fish.imagePath, fish.watermarkedImagePath];
    for (final path in files.whereType<String>()) {
      if (path.isNotEmpty) {
        try {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
            AppLogger.i('FishCatchService', 'Deleted image: $path');
          }
        } catch (e) {
          AppLogger.e('FishCatchService', 'Failed to delete image file', e);
        }
      }
    }
  }
}
