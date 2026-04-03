import '../models/fish_catch.dart';
import '../models/fish_filter.dart';
import '../models/paginated_result.dart';

export '../models/paginated_result.dart';

/// 渔获记录仓储层
///
/// 管理钓鱼捕获记录的数据访问，包括：
/// - 渔获记录的增删改查
/// - 按日期范围查询
/// - 按命运类型（放生/保留）筛选
/// - 按物种名称搜索
/// - 分页查询和多条件筛选

abstract class FishCatchRepository {
  Future<List<FishCatch>> getAll();
  Future<FishCatch?> getById(int id);
  Future<int> create(FishCatch fish);
  Future<void> update(FishCatch fish);
  Future<void> delete(int id);
  Future<void> deleteMultiple(List<int> ids);
  Future<List<FishCatch>> getByDateRange(DateTime start, DateTime end);
  Future<List<FishCatch>> getByFate(FishFateType fate);
  Future<PaginatedResult<FishCatch>> getPage({
    required int page,
    int pageSize = 20,
    String orderBy = 'catch_time DESC',
  });
  Future<PaginatedResult<FishCatch>> getFilteredPage({
    required int page,
    int pageSize = 20,
    DateTime? startDate,
    DateTime? endDate,
    FishFateType? fate,
    String? species,
    String orderBy = 'catch_time DESC',
  });

  /// 获取待识别鱼种的所有渔获记录
  Future<List<FishCatch>> getPendingRecognitionCatches();

  /// 获取待识别鱼种的数量
  Future<int> getPendingRecognitionCount();

  /// 更新单条渔获的鱼种，并清除待识别标记
  Future<void> updateSpecies(int id, String species);

  /// 批量更新渔获的鱼种，并清除待识别标记
  Future<void> batchUpdateSpecies(List<int> ids, List<String> speciesList);

  /// 获取所有物种及其出现次数
  /// 返回 Map<物种名称, 出现次数>，按次数降序排列
  Future<Map<String, int>> getSpeciesCounts();

  /// 重命名物种名称
  /// 将所有 oldName 的渔获记录更新为 newName
  Future<void> renameSpecies(String oldName, String newName);

  /// 合并物种名称
  /// 将所有 fromName 的渔获记录合并到 toName
  Future<void> mergeSpecies(String fromName, String toName);

  /// 删除物种
  /// 删除所有指定物种名称的渔获记录
  Future<void> deleteSpecies(String speciesName);

  /// 获取软虫钓组分析数据
  /// 返回软虫关联渔获的钓组、鱼钩、钩号、重量统计数据
  Future<Map<String, Map<String, int>>> getSoftWormRigAnalytics();

  /// 使用 FishFilter 获取过滤、分页、排序的渔获
  ///
  /// [filter] 包含所有过滤条件（timeFilter/fateFilter/speciesFilter/searchQuery/sortBy/sortAsc）
  Future<PaginatedResult<FishCatch>> getFilteredPageByFilter({
    required int page,
    int pageSize = 20,
    required FishFilter filter,
  });
}
