import '../constants/constants.dart';

/// 钓具装备数据模型
///
/// 定义了 LureBox 应用中所有钓具装备的数据结构。
/// 支持三种主要类型的钓具：
/// - [EquipmentType.rod]: 鱼竿（包含长度、节数、材质、硬度、腰力等属性）
/// - [EquipmentType.reel]: 渔轮（包含轴承数、齿轮比、线杯容量、鱼线信息等）
/// - [EquipmentType.lure]: 鱼饵（包含类型、重量、尺寸、颜色、数量等）
///
/// 使用设计：
/// - 使用单一 [Equipment] 类通过 type 字段区分不同类型
/// - 支持 nullable 字段来区分各类型特有的属性
/// - 提供了 displayName 属性用于友好显示
/// - 支持逻辑删除（isDeleted）和默认装备标记（isDefault）
///
/// 数据用途：
/// - 管理用户的钓具库存
/// - 在渔获记录中关联使用的钓具
/// - 统计分析不同钓具的捕获效果

enum EquipmentType {
  rod('rod', '鱼竿'),
  reel('reel', '渔轮'),
  lure('lure', '鱼饵');

  const EquipmentType(this.value, this.label);
  final String value;
  final String label;

  static EquipmentType fromValue(String value) {
    return EquipmentType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EquipmentType.rod,
    );
  }
}

class Equipment {
  final int id;
  final EquipmentType type;
  final String? brand;
  final String? model;
  final String? length;
  final String lengthUnit; // 鱼竿长度单位 (m, cm, ft, inch)
  final String? sections;
  final String? jointType;
  final String? material;
  final String? hardness;
  final String? weightRange;
  final int? reelBearings;
  final String? reelRatio;
  final String? reelCapacity;
  final String? reelBrakeType;
  final String? lureType;
  final String? lureWeight;
  final String lureWeightUnit; // 假饵重量单位 (g, oz)
  final String? lureSize;
  final String lureSizeUnit; // 假饵尺寸单位 (cm, mm, inch)
  final String? lureColor;
  final int? lureQuantity; // 假饵数量
  final String? lureQuantityUnit; // 假饵数量单位
  final double? price;
  final DateTime? purchaseDate;
  final bool isDefault;
  final bool isDeleted;
  final String? category;
  final String? rodAction;
  final String? reelLine;
  final DateTime? reelLineDate;
  final String? reelLineNumber;
  final String? reelLineLength;
  final String lineLengthUnit; // 鱼线长度单位
  final String lineWeightUnit; // 鱼线拉力单位 (kg, lb)
  final DateTime createdAt;
  final DateTime updatedAt;

  const Equipment({
    required this.id,
    required this.type,
    this.brand,
    this.model,
    this.length,
    this.lengthUnit = 'm',
    this.sections,
    this.jointType,
    this.material,
    this.hardness,
    this.weightRange,
    this.reelBearings,
    this.reelRatio,
    this.reelCapacity,
    this.reelBrakeType,
    this.lureType,
    this.lureWeight,
    this.lureWeightUnit = 'g',
    this.lureSize,
    this.lureSizeUnit = 'cm',
    this.lureColor,
    this.lureQuantity,
    this.lureQuantityUnit,
    this.price,
    this.purchaseDate,
    this.isDefault = false,
    this.isDeleted = false,
    this.category,
    this.rodAction,
    this.reelLine,
    this.reelLineDate,
    this.reelLineNumber,
    this.reelLineLength,
    this.lineLengthUnit = 'm',
    this.lineWeightUnit = 'kg',
    required this.createdAt,
    required this.updatedAt,
  });

  static dynamic _getField(Map<String, dynamic> map, String key) {
    if (map.containsKey(key)) return map[key];
    final altKey = key.replaceAll('_', ' ');
    if (map.containsKey(altKey)) return map[altKey];
    return null;
  }

  factory Equipment.fromMap(Map<String, dynamic> map) {
    return Equipment(
      id: _getField(map, 'id') as int,
      type: EquipmentType.fromValue(_getField(map, 'type') as String? ?? 'rod'),
      brand: _getField(map, 'brand') as String?,
      model: _getField(map, 'model') as String?,
      length: _getField(map, 'length') as String?,
      lengthUnit: _getField(map, 'length_unit') as String? ?? 'm',
      sections: _getField(map, 'sections')?.toString(),
      jointType: _getField(map, 'joint_type') as String?,
      material: _getField(map, 'material') as String?,
      hardness: _getField(map, 'hardness') as String?,
      weightRange: _getField(map, 'weight_range') as String?,
      reelBearings: _getField(map, 'reel_bearings') as int?,
      reelRatio: _getField(map, 'reel_ratio') as String?,
      reelCapacity: _getField(map, 'reel_capacity') as String?,
      reelBrakeType: _getField(map, 'reel_brake_type') as String?,
      lureType: _getField(map, 'lure_type') as String?,
      lureWeight: _getField(map, 'lure_weight') as String?,
      lureWeightUnit: _getField(map, 'lure_weight_unit') as String? ?? 'g',
      lureSize: _getField(map, 'lure_size') as String?,
      lureSizeUnit: _getField(map, 'lure_size_unit') as String? ?? 'cm',
      lureColor: _getField(map, 'lure_color') as String?,
      lureQuantity: _getField(map, 'lure_quantity') as int?,
      lureQuantityUnit: _getField(map, 'lure_quantity_unit') as String?,
      price: (_getField(map, 'price') as num?)?.toDouble(),
      purchaseDate: _getField(map, 'purchase_date') != null
          ? DateTime.tryParse(_getField(map, 'purchase_date').toString())
          : null,
      isDefault: _getField(map, 'is_default') == 1,
      isDeleted: _getField(map, 'is_deleted') == 1,
      category: _getField(map, 'category') as String?,
      rodAction: _getField(map, 'rod_action') as String?,
      reelLine: _getField(map, 'reel_line') as String?,
      reelLineDate: _getField(map, 'reel_line_date') != null
          ? DateTime.tryParse(_getField(map, 'reel_line_date').toString())
          : null,
      reelLineNumber: _getField(map, 'reel_line_number') as String?,
      reelLineLength: _getField(map, 'reel_line_length') as String?,
      lineLengthUnit: _getField(map, 'line_length_unit') as String? ?? 'm',
      lineWeightUnit: _getField(map, 'line_weight_unit') as String? ?? 'kg',
      createdAt: DateTime.parse(_getField(map, 'created_at').toString()),
      updatedAt: DateTime.parse(_getField(map, 'updated_at').toString()),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'type': type.value,
      'brand': brand,
      'model': model,
      'length': length,
      'length_unit': lengthUnit,
      'sections': sections,
      'joint_type': jointType,
      'material': material,
      'hardness': hardness,
      'weight_range': weightRange,
      'reel_bearings': reelBearings,
      'reel_ratio': reelRatio,
      'reel_capacity': reelCapacity,
      'reel_brake_type': reelBrakeType,
      'lure_type': lureType,
      'lure_weight': lureWeight,
      'lure_weight_unit': lureWeightUnit,
      'lure_size': lureSize,
      'lure_color': lureColor,
      'lure_quantity': lureQuantity,
      'lure_quantity_unit': lureQuantityUnit,
      'price': price,
      'purchase_date': purchaseDate?.toIso8601String(),
      'is_default': isDefault ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'category': category,
      'rod_action': rodAction,
      'reel_line': reelLine,
      'reel_line_date': reelLineDate?.toIso8601String(),
      'reel_line_number': reelLineNumber,
      'reel_line_length': reelLineLength,
      'line_length_unit': lineLengthUnit,
      'line_weight_unit': lineWeightUnit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    map['lure_size_unit'] = lureSizeUnit;

    return map;
  }

  String get displayName {
    final parts = <String>[];
    if (brand != null && brand!.isNotEmpty) parts.add(brand!);
    if (model != null && model!.isNotEmpty) parts.add(model!);
    return parts.isEmpty ? type.label : parts.join(' ');
  }

  String get rodCategoryName {
    if (type != EquipmentType.rod || category == null) return '';
    return RodCategory.getName(category!);
  }

  String get reelCategoryName {
    if (type != EquipmentType.reel || category == null) return '';
    return ReelCategory.getName(category!);
  }

  Equipment copyWith({
    int? id,
    EquipmentType? type,
    String? Function()? brand,
    String? Function()? model,
    String? Function()? length,
    String? Function()? sections,
    String? Function()? jointType,
    String? Function()? material,
    String? Function()? hardness,
    String? Function()? weightRange,
    int? Function()? reelBearings,
    String? Function()? reelRatio,
    String? Function()? reelCapacity,
    String? Function()? reelBrakeType,
    String? Function()? lureType,
    String? Function()? lureWeight,
    String? Function()? lureSize,
    String Function()? lureSizeUnit,
    String? Function()? lureColor,
    int? Function()? lureQuantity,
    String? Function()? lureQuantityUnit,
    double? Function()? price,
    DateTime? Function()? purchaseDate,
    bool? isDefault,
    bool? isDeleted,
    String? Function()? category,
    String? Function()? rodAction,
    String? Function()? reelLine,
    DateTime? Function()? reelLineDate,
    String? Function()? reelLineNumber,
    String? Function()? reelLineLength,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Equipment(
      id: id ?? this.id,
      type: type ?? this.type,
      brand: brand != null ? brand() : this.brand,
      model: model != null ? model() : this.model,
      length: length != null ? length() : this.length,
      sections: sections != null ? sections() : this.sections,
      jointType: jointType != null ? jointType() : this.jointType,
      material: material != null ? material() : this.material,
      hardness: hardness != null ? hardness() : this.hardness,
      weightRange: weightRange != null ? weightRange() : this.weightRange,
      reelBearings: reelBearings != null ? reelBearings() : this.reelBearings,
      reelRatio: reelRatio != null ? reelRatio() : this.reelRatio,
      reelCapacity: reelCapacity != null ? reelCapacity() : this.reelCapacity,
      reelBrakeType:
          reelBrakeType != null ? reelBrakeType() : this.reelBrakeType,
      lureType: lureType != null ? lureType() : this.lureType,
      lureWeight: lureWeight != null ? lureWeight() : this.lureWeight,
      lureSize: lureSize != null ? lureSize() : this.lureSize,
      lureSizeUnit: lureSizeUnit != null ? lureSizeUnit() : this.lureSizeUnit,
      lureColor: lureColor != null ? lureColor() : this.lureColor,
      lureQuantity: lureQuantity != null ? lureQuantity() : this.lureQuantity,
      lureQuantityUnit:
          lureQuantityUnit != null ? lureQuantityUnit() : this.lureQuantityUnit,
      price: price != null ? price() : this.price,
      purchaseDate: purchaseDate != null ? purchaseDate() : this.purchaseDate,
      isDefault: isDefault ?? this.isDefault,
      isDeleted: isDeleted ?? this.isDeleted,
      category: category != null ? category() : this.category,
      rodAction: rodAction != null ? rodAction() : this.rodAction,
      reelLine: reelLine != null ? reelLine() : this.reelLine,
      reelLineDate: reelLineDate != null ? reelLineDate() : this.reelLineDate,
      reelLineNumber:
          reelLineNumber != null ? reelLineNumber() : this.reelLineNumber,
      reelLineLength:
          reelLineLength != null ? reelLineLength() : this.reelLineLength,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Equipment && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

extension EquipmentListExtension on List<Equipment> {
  List<Equipment> filterByType(EquipmentType type) {
    return where((e) => e.type == type && !e.isDeleted).toList();
  }

  List<Equipment> get rods => filterByType(EquipmentType.rod);
  List<Equipment> get reels => filterByType(EquipmentType.reel);
  List<Equipment> get lures => filterByType(EquipmentType.lure);

  List<Equipment> get active => where((e) => !e.isDeleted).toList();
  List<Equipment> get defaults => where((e) => e.isDefault).toList();
}
