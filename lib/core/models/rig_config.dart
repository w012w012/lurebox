/// 自由铅形状
class FreeSinkerShape {
  static const String teardrop = '水滴型';
  static const String cylindrical = '圆柱型';
  static const String willow = '柳叶型';
  static const String spherical = '球型';

  static const List<String> presets = [
    teardrop,
    cylindrical,
    willow,
    spherical
  ];
}

/// 钓组配置数据模型
///
/// 记录钓组搭配信息，包括钓组类型、插铅、自由铅、鱼钩等配置。
/// 用于在记录渔获时关联使用的钓组细节。
class RigConfig {
  final String? rigType; // 钓组及鱼钩类型
  final String? sinkerWeight; // 插铅重量（数值字符串）
  final String? sinkerPosition; // 插铅位置（头/腹）
  final String? freeSinkerWeight; // 自由铅重量（数值字符串）
  final String? freeSinkerShape; // 自由铅形状
  final String? hookType; // 鱼钩类型
  final String? hookSize; // 钩号
  final String? hookWeight; // 重量（数值字符串）

  const RigConfig({
    this.rigType,
    this.sinkerWeight,
    this.sinkerPosition,
    this.freeSinkerWeight,
    this.freeSinkerShape,
    this.hookType,
    this.hookSize,
    this.hookWeight,
  });

  factory RigConfig.fromMap(Map<String, dynamic> map) {
    return RigConfig(
      rigType: map['rig_type'] as String?,
      sinkerWeight: map['sinker_weight'] as String?,
      sinkerPosition: map['sinker_position'] as String?,
      freeSinkerWeight: map['free_sinker_weight'] as String?,
      freeSinkerShape: map['free_sinker_shape'] as String?,
      hookType: map['hook_type'] as String?,
      hookSize: map['hook_size'] as String?,
      hookWeight: map['hook_weight'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rig_type': rigType,
      'sinker_weight': sinkerWeight,
      'sinker_position': sinkerPosition,
      'free_sinker_weight': freeSinkerWeight,
      'free_sinker_shape': freeSinkerShape,
      'hook_type': hookType,
      'hook_size': hookSize,
      'hook_weight': hookWeight,
    };
  }

  RigConfig copyWith({
    String? rigType,
    String? sinkerWeight,
    String? sinkerPosition,
    String? freeSinkerWeight,
    String? freeSinkerShape,
    String? hookType,
    String? hookSize,
    String? hookWeight,
  }) {
    return RigConfig(
      rigType: rigType ?? this.rigType,
      sinkerWeight: sinkerWeight ?? this.sinkerWeight,
      sinkerPosition: sinkerPosition ?? this.sinkerPosition,
      freeSinkerWeight: freeSinkerWeight ?? this.freeSinkerWeight,
      freeSinkerShape: freeSinkerShape ?? this.freeSinkerShape,
      hookType: hookType ?? this.hookType,
      hookSize: hookSize ?? this.hookSize,
      hookWeight: hookWeight ?? this.hookWeight,
    );
  }

  bool get isEmpty =>
      rigType == null &&
      sinkerWeight == null &&
      sinkerPosition == null &&
      freeSinkerWeight == null &&
      freeSinkerShape == null &&
      hookType == null &&
      hookSize == null &&
      hookWeight == null;

  bool get isNotEmpty => !isEmpty;
}

/// 钓组类型
class RigType {
  static const String jigHead = '铅头钩钓组';
  static const String texas = '德州钓组';
  static const String carolina = '卡罗莱纳钓组';
  static const String weightless = '无铅钓组';
  static const String dropShot = '倒吊钓组';
  static const String wacky = 'WACKY钓组';
  static const String free = '自由钓组';
  static const String ned = '内德钓组';
  static const String neko = 'NEKO钓组';

  static const List<String> presets = [
    jigHead,
    texas,
    carolina,
    weightless,
    dropShot,
    wacky,
    free,
    ned,
    neko,
  ];

  static String label(String value) => value;
}

/// 插铅位置
class SinkerPosition {
  static const String head = '头';
  static const String belly = '腹';

  static const List<String> presets = [head, belly];
}

/// 鱼钩类型
class HookType {
  static const String jigHead = '铅头钩';
  static const String dropShotHook = '根钓钩';
  static const String offsetHook = '直柄钩';
  static const String wormHook = '曲柄钩';
  static const String wackyHook = 'WACKY钩';
  static const String inchWackyHook = 'inch wacky钩';
  static const String straightHook = '直角钩';

  static const List<String> presets = [
    jigHead,
    dropShotHook,
    offsetHook,
    wormHook,
    wackyHook,
    inchWackyHook,
    straightHook,
  ];
}

/// 钩号
class HookSize {
  static const String size6 = '6号';
  static const String size5 = '5号';
  static const String size4 = '4号';
  static const String size3 = '3号';
  static const String size2 = '2号';
  static const String size1 = '1号';
  static const String size1_0 = '1/0号';
  static const String size2_0 = '2/0号';
  static const String size3_0 = '3/0号';
  static const String size4_0 = '4/0号';
  static const String size5_0 = '5/0号';

  static const List<String> presets = [
    size6,
    size5,
    size4,
    size3,
    size2,
    size1,
    size1_0,
    size2_0,
    size3_0,
    size4_0,
    size5_0,
  ];
}
