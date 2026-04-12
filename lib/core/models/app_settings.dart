import 'dart:convert';

/// 应用全局设置数据模型
///
/// 定义了应用的用户偏好设置。
///
/// 组成结构：
/// - [UnitSettings]: 单位制设置
///   覆盖应用中所有需要单位的场景：
///   * 渔获：鱼长(cm/m/inch/ft)、鱼重(kg/lb/oz/g)
///   * 装备：鱼竿长度、鱼线长度
///   * 假饵：重量(g/oz)、长度(cm/mm/inch)、数量(条/只/个/包/盒)
///   * 其他：距离(m/km/ft/mile)、温度(C/F)
///
/// - [DarkMode]: 深色模式枚举
///   system（跟随系统）、light（浅色）、dark（深色）
///
/// - [AppLanguage]: 应用语言枚举
///   chinese（中文）、english（英文）
///
/// - [AppSettings]: 应用设置聚合类
///   组合单位、主题、语言三项设置
///
/// 序列化支持：
/// - toJson(): 转换为 JSON
/// - fromJson(): 从 JSON 创建
/// - encode(): 编码为字符串
/// - decode(): 从字符串解码
///
/// 典型用途：
/// - 用户偏好持久化
/// - 单位换算参考
/// - 主题切换
/// - 多语言支持

/// 单位设置 - 按物品类型分组
class UnitSettings {
  // 渔获相关
  final String fishLengthUnit; // cm, m, inch, ft
  final String fishWeightUnit; // kg, lb, oz, g

  // 装备相关（鱼竿/渔轮/鱼线）
  final String rodLengthUnit; // m, cm, ft, inch
  final String lineLengthUnit; // m, cm, ft, inch

  // 假饵相关
  final String lureWeightUnit; // g, oz
  final String lureLengthUnit; // cm, mm, inch
  final String lureQuantityUnit; // 条、只、个、包、盒

  // 温度
  final String temperatureUnit; // C, F

  const UnitSettings({
    this.fishLengthUnit = 'cm',
    this.fishWeightUnit = 'kg',
    this.rodLengthUnit = 'm',
    this.lineLengthUnit = 'm',
    this.lureWeightUnit = 'g',
    this.lureLengthUnit = 'cm',
    this.lureQuantityUnit = '个',
    this.temperatureUnit = 'C',
  });

  UnitSettings copyWith({
    String? fishLengthUnit,
    String? fishWeightUnit,
    String? rodLengthUnit,
    String? lineLengthUnit,
    String? lureWeightUnit,
    String? lureLengthUnit,
    String? lureQuantityUnit,
    String? temperatureUnit,
  }) {
    return UnitSettings(
      fishLengthUnit: fishLengthUnit ?? this.fishLengthUnit,
      fishWeightUnit: fishWeightUnit ?? this.fishWeightUnit,
      rodLengthUnit: rodLengthUnit ?? this.rodLengthUnit,
      lineLengthUnit: lineLengthUnit ?? this.lineLengthUnit,
      lureWeightUnit: lureWeightUnit ?? this.lureWeightUnit,
      lureLengthUnit: lureLengthUnit ?? this.lureLengthUnit,
      lureQuantityUnit: lureQuantityUnit ?? this.lureQuantityUnit,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
    );
  }

  Map<String, dynamic> toJson() => {
        'fishLengthUnit': fishLengthUnit,
        'fishWeightUnit': fishWeightUnit,
        'rodLengthUnit': rodLengthUnit,
        'lineLengthUnit': lineLengthUnit,
        'lureWeightUnit': lureWeightUnit,
        'lureLengthUnit': lureLengthUnit,
        'lureQuantityUnit': lureQuantityUnit,
        'temperatureUnit': temperatureUnit,
      };

  factory UnitSettings.fromJson(Map<String, dynamic> json) {
    return UnitSettings(
      fishLengthUnit: json['fishLengthUnit'] as String? ?? 'cm',
      fishWeightUnit: json['fishWeightUnit'] as String? ?? 'kg',
      rodLengthUnit: json['rodLengthUnit'] as String? ?? 'm',
      lineLengthUnit: json['lineLengthUnit'] as String? ?? 'm',
      lureWeightUnit: json['lureWeightUnit'] as String? ?? 'g',
      lureLengthUnit: json['lureLengthUnit'] as String? ?? 'cm',
      lureQuantityUnit: json['lureQuantityUnit'] as String? ?? '个',
      temperatureUnit: json['temperatureUnit'] as String? ?? 'C',
    );
  }

  String encode() => jsonEncode(toJson());
  factory UnitSettings.decode(String source) =>
      UnitSettings.fromJson(jsonDecode(source));
}

/// 深色模式
enum DarkMode { system, light, dark }

/// 语言设置
enum AppLanguage { chinese, english }

/// 应用设置
class AppSettings {
  final UnitSettings units;
  final DarkMode darkMode;
  final AppLanguage language;
  final bool hasCompletedOnboarding;

  const AppSettings({
    this.units = const UnitSettings(),
    this.darkMode = DarkMode.system,
    this.language = AppLanguage.chinese,
    this.hasCompletedOnboarding = false,
  });

  AppSettings copyWith({
    UnitSettings? units,
    DarkMode? darkMode,
    AppLanguage? language,
    bool? hasCompletedOnboarding,
  }) {
    return AppSettings(
      units: units ?? this.units,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  Map<String, dynamic> toJson() => {
        'units': units.toJson(),
        'darkMode': darkMode.name,
        'language': language.name,
        'hasCompletedOnboarding': hasCompletedOnboarding,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      units: json['units'] != null
          ? UnitSettings.fromJson(json['units'] as Map<String, dynamic>)
          : const UnitSettings(),
      darkMode: DarkMode.values.firstWhere(
        (e) => e.name == json['darkMode'],
        orElse: () => DarkMode.system,
      ),
      language: AppLanguage.values.firstWhere(
        (e) => e.name == json['language'],
        orElse: () => AppLanguage.chinese,
      ),
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
    );
  }

  String encode() => jsonEncode(toJson());
  factory AppSettings.decode(String source) =>
      AppSettings.fromJson(jsonDecode(source));
}
