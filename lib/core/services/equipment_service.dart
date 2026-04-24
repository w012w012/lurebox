import '../constants/pagination_constants.dart';
import '../models/equipment.dart';
import '../repositories/equipment_repository.dart';

/// 装备服务 - 钓具装备的业务逻辑层
///
/// 提供钓具装备的完整管理功能：
/// - CRUD 操作：创建、读取、更新、删除装备记录（支持软删除）
/// - 分页查询：支持按类型、品牌、型号、类别筛选
/// - 默认装备：支持为每种装备类型设置默认装备
/// - 统计分析：品牌分布、类别分布、数量统计
///
/// 装备类型包括：鱼竿（rod）、鱼轮（reel）、鱼饵（lure）等。

class EquipmentService {
  final EquipmentRepository _repository;

  EquipmentService(this._repository);

  Future<List<Equipment>> getAll({String? type}) async {
    return await _repository.getAll(type: type);
  }

  Future<Equipment?> getById(int id) async {
    return await _repository.getById(id);
  }

  Future<Equipment?> getDefaultEquipment(String type) async {
    return await _repository.getDefaultEquipment(type);
  }

  Future<int> create(Equipment equipment) async {
    return await _repository.create(equipment);
  }

  Future<void> update(Equipment equipment) async {
    await _repository.update(equipment);
  }

  Future<void> delete(int id) async {
    await _repository.delete(id);
  }

  Future<PaginatedResult<Equipment>> getPage({
    required int page,
    int pageSize = PaginationConstants.defaultPageSize,
    String? type,
    String orderBy = 'is_default DESC, created_at DESC',
  }) async {
    return await _repository.getPage(
      page: page,
      pageSize: pageSize,
      type: type,
      orderBy: orderBy,
    );
  }

  Future<PaginatedResult<Equipment>> getFilteredPage({
    required int page,
    int pageSize = PaginationConstants.defaultPageSize,
    String? type,
    String? brand,
    String? model,
    String? category,
    String orderBy = 'is_default DESC, created_at DESC',
  }) async {
    return await _repository.getFilteredPage(
      page: page,
      pageSize: pageSize,
      type: type,
      brand: brand,
      model: model,
      category: category,
      orderBy: orderBy,
    );
  }

  Future<void> setDefaultEquipment(int id, String type) async {
    await _repository.setDefaultEquipment(id, type);
  }

  Future<Map<String, int>> getStats() async {
    return await _repository.getStats();
  }

  Future<List<String>> getBrands() async {
    return await _repository.getBrands();
  }

  Future<List<String>> getModelsByBrand(String brand) async {
    return await _repository.getModelsByBrand(brand);
  }

  Future<Map<String, int>> getCategoryDistribution(String type) async {
    return await _repository.getCategoryDistribution(type);
  }
}
