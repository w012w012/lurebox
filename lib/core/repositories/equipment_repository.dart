import '../models/equipment.dart';
import '../models/paginated_result.dart';

export '../models/paginated_result.dart';

/// 钓具/装备仓储层
///
/// 管理钓鱼装备的数据访问，包括：
/// - 装备的增删改查（支持软删除）
/// - 按类型、品牌、型号、分类筛选
/// - 分页查询
/// - 默认装备设置
/// - 统计分析（各类型数量、品牌列表、型号列表、分类分布）

abstract class EquipmentRepository {
  Future<List<Equipment>> getAll({String? type});
  Future<Equipment?> getById(int id);
  Future<Equipment?> getDefaultEquipment(String type);
  Future<int> create(Equipment equipment);
  Future<void> update(Equipment equipment);
  Future<void> delete(int id);

  Future<PaginatedResult<Equipment>> getPage({
    required int page,
    int pageSize = 20,
    String? type,
    String orderBy = 'is_default DESC, created_at DESC',
  });

  Future<PaginatedResult<Equipment>> getFilteredPage({
    required int page,
    int pageSize = 20,
    String? type,
    String? brand,
    String? model,
    String? category,
    String orderBy = 'is_default DESC, created_at DESC',
  });

  Future<void> setDefaultEquipment(int id, String type);

  Future<Map<String, int>> getStats();

  Future<List<String>> getBrands();

  Future<List<String>> getModelsByBrand(String brand);

  Future<Map<String, int>> getCategoryDistribution(String type);
}
