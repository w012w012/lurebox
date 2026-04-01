import '../models/species_history.dart';

export '../models/species_history.dart';

/// 物种历史记录仓储层
///
/// 管理钓鱼时记录的鱼类物种历史数据，包括：
/// - 物种的使用次数追踪
/// - 物种的增删改查
/// - 软删除和恢复功能
/// - 按使用次数排序查询

abstract class SpeciesHistoryRepository {
  Future<List<SpeciesHistory>> getAll({
    int limit = 100,
    bool includeDeleted = false,
  });

  Future<SpeciesHistory?> getByName(String name);

  Future<void> upsert(String name);

  Future<void> incrementUseCount(String name);

  Future<void> softDelete(String name);

  Future<void> restore(String name);

  Future<bool> exists(String name);

  Future<int> getCount();
}
