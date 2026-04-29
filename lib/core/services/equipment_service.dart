import 'package:lurebox/core/constants/pagination_constants.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/repositories/equipment_repository.dart';
import 'package:lurebox/core/utils/input_validator.dart';

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

  EquipmentService(this._repository);
  final EquipmentRepository _repository;

  Future<List<Equipment>> getAll({String? type}) async {
    return _repository.getAll(type: type);
  }

  Future<Equipment?> getById(int id) async {
    return _repository.getById(id);
  }

  Future<Equipment?> getDefaultEquipment(String type) async {
    return _repository.getDefaultEquipment(type);
  }

  Future<int> create(Equipment equipment) async {
    final validated = _validateEquipment(equipment);
    return _repository.create(validated);
  }

  Future<void> update(Equipment equipment) async {
    final validated = _validateEquipment(equipment);
    await _repository.update(validated);
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
    return _repository.getPage(
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
    return _repository.getFilteredPage(
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
    return _repository.getStats();
  }

  Future<List<String>> getBrands() async {
    return _repository.getBrands();
  }

  Future<List<String>> getModelsByBrand(String brand) async {
    return _repository.getModelsByBrand(brand);
  }

  Future<Map<String, int>> getCategoryDistribution(String type) async {
    return _repository.getCategoryDistribution(type);
  }

  Equipment _validateEquipment(Equipment equipment) {
    final brand = InputValidator.validateOptionalName(
      equipment.brand,
      fieldName: 'brand',
    );
    final model = InputValidator.validateOptionalName(
      equipment.model,
      fieldName: 'model',
    );
    final notes = InputValidator.validateDescription(
      equipment.notes,
      fieldName: 'notes',
    );
    final category = InputValidator.validateOptionalName(
      equipment.category,
      fieldName: 'category',
    );

    if (brand == equipment.brand &&
        model == equipment.model &&
        notes == equipment.notes &&
        category == equipment.category) {
      return equipment;
    }
    return Equipment(
      id: equipment.id,
      type: equipment.type,
      createdAt: equipment.createdAt,
      updatedAt: equipment.updatedAt,
      brand: brand,
      model: model,
      notes: notes,
      category: category,
      length: equipment.length,
      lengthUnit: equipment.lengthUnit,
      sections: equipment.sections,
      jointType: equipment.jointType,
      material: equipment.material,
      hardness: equipment.hardness,
      weightRange: equipment.weightRange,
      rodPower: equipment.rodPower,
      reelBearings: equipment.reelBearings,
      reelRatio: equipment.reelRatio,
      reelCapacity: equipment.reelCapacity,
      reelBrakeType: equipment.reelBrakeType,
      reelDrag: equipment.reelDrag,
      reelDragUnit: equipment.reelDragUnit,
      reelWeight: equipment.reelWeight,
      reelWeightUnit: equipment.reelWeightUnit,
      lureType: equipment.lureType,
      lureWeight: equipment.lureWeight,
      lureWeightUnit: equipment.lureWeightUnit,
      lureSize: equipment.lureSize,
      lureSizeUnit: equipment.lureSizeUnit,
      lureColor: equipment.lureColor,
      lureQuantity: equipment.lureQuantity,
      lureQuantityUnit: equipment.lureQuantityUnit,
      price: equipment.price,
      purchaseDate: equipment.purchaseDate,
      isDefault: equipment.isDefault,
      isDeleted: equipment.isDeleted,
      rodAction: equipment.rodAction,
      reelLine: equipment.reelLine,
      reelLineDate: equipment.reelLineDate,
      reelLineNumber: equipment.reelLineNumber,
      reelLineLength: equipment.reelLineLength,
      lineLengthUnit: equipment.lineLengthUnit,
      lineWeightUnit: equipment.lineWeightUnit,
    );
  }
}
