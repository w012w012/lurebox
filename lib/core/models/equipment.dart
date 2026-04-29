
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
library;

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

  const Equipment({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.brand,
    this.model,
    this.length,
    this.lengthUnit = 'm',
    this.sections,
    this.jointType,
    this.material,
    this.hardness,
    this.weightRange,
    this.rodPower,
    this.notes,
    this.reelBearings,
    this.reelRatio,
    this.reelCapacity,
    this.reelBrakeType,
    this.reelDrag,
    this.reelDragUnit = 'kg',
    this.reelWeight,
    this.reelWeightUnit = 'g',
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
  });

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
      rodPower: _getField(map, 'rod_power') as String?,
      notes: _getField(map, 'notes') as String?,
      reelBearings: _getField(map, 'reel_bearings') as int?,
      reelRatio: _getField(map, 'reel_ratio') as String?,
      reelCapacity: _getField(map, 'reel_capacity') as String?,
      reelBrakeType: _getField(map, 'reel_brake_type') as String?,
      reelDrag: _getField(map, 'reel_drag') as String?,
      reelDragUnit: _getField(map, 'reel_drag_unit') as String? ?? 'kg',
      reelWeight: _getField(map, 'reel_weight') as String?,
      reelWeightUnit: _getField(map, 'reel_weight_unit') as String? ?? 'g',
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
  final String? rodPower;
  final String? notes;
  final int? reelBearings;
  final String? reelRatio;
  final String? reelCapacity;
  final String? reelBrakeType;
  final String? reelDrag;
  final String reelDragUnit; // 渔轮卸力单位 (kg, lb)
  final String? reelWeight;
  final String reelWeightUnit; // 渔轮重量单位 (g, oz)
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

  static dynamic _getField(Map<String, dynamic> map, String key) {
    if (map.containsKey(key)) return map[key];
    final altKey = key.replaceAll('_', ' ');
    if (map.containsKey(altKey)) return map[altKey];
    return null;
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
      'rod_power': rodPower,
      'notes': notes,
      'reel_bearings': reelBearings,
      'reel_ratio': reelRatio,
      'reel_capacity': reelCapacity,
      'reel_brake_type': reelBrakeType,
      'reel_drag': reelDrag,
      'reel_drag_unit': reelDragUnit,
      'reel_weight': reelWeight,
      'reel_weight_unit': reelWeightUnit,
      'lure_type': lureType,
      'lure_weight': lureWeight,
      'lure_weight_unit': lureWeightUnit,
      'lure_size': lureSize,
      'lure_size_unit': lureSizeUnit,
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

    return map;
  }

  String get displayName {
    final parts = <String>[];
    if (brand != null && brand!.isNotEmpty) parts.add(brand!);
    if (model != null && model!.isNotEmpty) parts.add(model!);
    return parts.isEmpty ? type.label : parts.join(' ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Equipment && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Equipment(id: $id, type: ${type.label}, brand: $brand, model: $model)';
  }
}

/// Type-safe accessor for rod-specific parameters.
/// Returns null if the equipment type is not rod.
class RodParams {

  const RodParams({
    this.length,
    this.lengthUnit = 'm',
    this.sections,
    this.jointType,
    this.material,
    this.hardness,
    this.rodAction,
    this.weightRange,
    this.rodPower,
  });
  final String? length;
  final String lengthUnit;
  final String? sections;
  final String? jointType;
  final String? material;
  final String? hardness;
  final String? rodAction;
  final String? weightRange;
  final String? rodPower;
}

/// Type-safe accessor for reel-specific parameters.
/// Returns null if the equipment type is not reel.
class ReelParams {

  const ReelParams({
    this.bearings,
    this.ratio,
    this.capacity,
    this.brakeType,
    this.drag,
    this.dragUnit = 'kg',
    this.weight,
    this.weightUnit = 'g',
    this.line,
    this.lineDate,
    this.lineNumber,
    this.lineLength,
    this.lineLengthUnit = 'm',
    this.lineWeightUnit = 'kg',
  });
  final int? bearings;
  final String? ratio;
  final String? capacity;
  final String? brakeType;
  final String? drag;
  final String dragUnit;
  final String? weight;
  final String weightUnit;
  final String? line;
  final DateTime? lineDate;
  final String? lineNumber;
  final String? lineLength;
  final String lineLengthUnit;
  final String lineWeightUnit;
}

/// Type-safe accessor for lure-specific parameters.
/// Returns null if the equipment type is not lure.
class LureParams {

  const LureParams({
    this.type,
    this.weight,
    this.weightUnit = 'g',
    this.size,
    this.sizeUnit = 'cm',
    this.color,
    this.quantity,
    this.quantityUnit,
  });
  final String? type;
  final String? weight;
  final String weightUnit;
  final String? size;
  final String sizeUnit;
  final String? color;
  final int? quantity;
  final String? quantityUnit;
}

/// Type-safe parameter accessors on Equipment.
extension EquipmentParamsX on Equipment {
  /// Returns rod-specific parameters, or null if not a rod.
  RodParams? get rodParams => type == EquipmentType.rod
      ? RodParams(
          length: length,
          lengthUnit: lengthUnit,
          sections: sections,
          jointType: jointType,
          material: material,
          hardness: hardness,
          rodAction: rodAction,
          weightRange: weightRange,
          rodPower: rodPower,
        )
      : null;

  /// Returns reel-specific parameters, or null if not a reel.
  ReelParams? get reelParams => type == EquipmentType.reel
      ? ReelParams(
          bearings: reelBearings,
          ratio: reelRatio,
          capacity: reelCapacity,
          brakeType: reelBrakeType,
          drag: reelDrag,
          dragUnit: reelDragUnit,
          weight: reelWeight,
          weightUnit: reelWeightUnit,
          line: reelLine,
          lineDate: reelLineDate,
          lineNumber: reelLineNumber,
          lineLength: reelLineLength,
          lineLengthUnit: lineLengthUnit,
          lineWeightUnit: lineWeightUnit,
        )
      : null;

  /// Returns lure-specific parameters, or null if not a lure.
  LureParams? get lureParams => type == EquipmentType.lure
      ? LureParams(
          type: lureType,
          weight: lureWeight,
          weightUnit: lureWeightUnit,
          size: lureSize,
          sizeUnit: lureSizeUnit,
          color: lureColor,
          quantity: lureQuantity,
          quantityUnit: lureQuantityUnit,
        )
      : null;
}
