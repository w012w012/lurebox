/// 旧版中文值到英文键的映射
///
/// 旧版将中文显示值直接存入 DB（如 `'正并继'`、`'SS调（超慢调）'`）。
/// 新版使用英文键（如 `'spigot'`、`'SS'`），显示值由 i18n 系统提供。
///
/// 此工具提供：
/// - [migrateValue]：将单个旧值转换为新键
/// - [migrateEquipmentMap]：批量转换 equipment map 中的旧值
class LegacyValueMigrator {
  LegacyValueMigrator._();

  // ===== 节数 (sections) =====
  static const _sections = {
    '1节': '1',
    '2节': '2',
    '3节': '3',
    '多节': 'multi',
  };

  // ===== 插节方式 (joint_type) =====
  static const _jointTypes = {
    '正并继': 'spigot',
    '逆并继': 'reverse_spigot',
    '印龙继': 'dragon_spigot',
    '伸缩': 'telescopic',
  };

  // ===== 调性 (rod_action) =====
  static const _rodActions = {
    'SS调（超慢调）': 'SS',
    'S调（慢调）': 'S',
    'MR调（中慢调）': 'MR',
    'R调（中调）': 'R',
    'RF调（中快调）': 'RF',
    'F调（快调）': 'F',
    'FF调（超快调）': 'FF',
    'XF调（极快调）': 'XF',
  };

  // ===== 刹车类型 (reel_brake_type) =====
  static const _brakeTypes = {
    '传统磁力刹车': 'traditional_magnetic',
    '离心刹车': 'centrifugal',
    'DC刹车': 'dc',
    '浮动磁力刹车': 'floating_magnetic',
    '创新组合刹车': 'innovative',
  };

  /// 所有映射的集合，按字段名索引
  static const _fieldMaps = {
    'sections': _sections,
    'joint_type': _jointTypes,
    'rod_action': _rodActions,
    'reel_brake_type': _brakeTypes,
  };

  /// 将单个旧中文值转换为英文键
  ///
  /// 如果值已经是英文键或不在映射中，原样返回。
  static String migrateValue(String field, String value) {
    final map = _fieldMaps[field];
    if (map == null) return value;
    return map[value] ?? value;
  }

  /// 批量转换 equipment map 中的旧值
  ///
  /// 处理 DB 中存储的旧中文值，将其转换为英文键。
  static Map<String, dynamic> migrateEquipmentMap(Map<String, dynamic> map) {
    final result = Map<String, dynamic>.from(map);
    for (final entry in _fieldMaps.entries) {
      final key = entry.key;
      final mapping = entry.value;
      final value = result[key];
      if (value is String && mapping.containsKey(value)) {
        result[key] = mapping[value];
      }
    }
    return result;
  }
}
