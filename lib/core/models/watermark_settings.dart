import 'dart:convert';

/// 水印样式枚举
enum WatermarkStyle {
  minimal, // 简约左下
  elegant, // 优雅右下
  bold, // 大字居中
}

/// 水印信息类型枚举
enum WatermarkInfoType {
  species, // 品种
  length, // 长度
  weight, // 重量
  location, // 钓点
  rod, // 鱼竿
  reel, // 渔轮
  lure, // 鱼饵
  time, // 时间
  appName, // App名称
  airTemperature, // 气温
  pressure, // 气压
  weather, // 天气
}

/// 水印位置枚举
enum WatermarkPosition {
  topLeft, // 左上
  topRight, // 右上
  bottomLeft, // 左下
  bottomRight, // 右下
  center, // 居中
}

/// 预设样式参数
class WatermarkStylePreset {

  const WatermarkStylePreset({
    required this.blurRadius,
    required this.backgroundOpacity,
    required this.backgroundColor,
    required this.fontSize,
    required this.textColor,
    required this.position,
  });
  final double blurRadius;
  final double backgroundOpacity;
  final int backgroundColor;
  final double fontSize;
  final int textColor;
  final WatermarkPosition position;
}

/// 预设样式参数映射
const watermarkStylePresets = {
  WatermarkStyle.minimal: WatermarkStylePreset(
    blurRadius: 10,
    backgroundOpacity: 0.5,
    backgroundColor: 0xFF000000,
    fontSize: 14,
    textColor: 0xFFFFFFFF,
    position: WatermarkPosition.bottomLeft,
  ),
  WatermarkStyle.elegant: WatermarkStylePreset(
    blurRadius: 16,
    backgroundOpacity: 0.35,
    backgroundColor: 0xFF1A1A2E,
    fontSize: 12,
    textColor: 0xFFE0E0E0,
    position: WatermarkPosition.bottomRight,
  ),
  WatermarkStyle.bold: WatermarkStylePreset(
    blurRadius: 6,
    backgroundOpacity: 0.7,
    backgroundColor: 0xFF000000,
    fontSize: 20,
    textColor: 0xFFFFFFFF,
    position: WatermarkPosition.center,
  ),
};

/// 水印设置
class WatermarkSettings { // 自定义文字

  const WatermarkSettings({
    this.enabled = true,
    this.style = WatermarkStyle.minimal,
    this.infoTypes = const [
      WatermarkInfoType.species,
      WatermarkInfoType.length,
      WatermarkInfoType.location,
      WatermarkInfoType.airTemperature,
      WatermarkInfoType.pressure,
      WatermarkInfoType.weather,
      WatermarkInfoType.appName,
    ],
    this.blurRadius = 10.0,
    this.backgroundOpacity = 0.5,
    this.backgroundColor = 0xFF000000, // 黑色
    this.fontSize = 14.0,
    this.textColor = 0xFFFFFFFF, // 白色
    this.position = WatermarkPosition.bottomLeft,
    this.customText,
  });

  factory WatermarkSettings.fromJson(Map<String, dynamic> json) {
    return WatermarkSettings(
      enabled: json['enabled'] as bool? ?? true,
      style: WatermarkStyle.values.firstWhere(
        (e) => e.name == json['style'],
        orElse: () => WatermarkStyle.minimal,
      ),
      infoTypes: (json['infoTypes'] as List<dynamic>?)
              ?.map((e) {
                try {
                  return WatermarkInfoType.values.firstWhere(
                    (type) => type.name == e,
                  );
                } catch (_) {
                  return null;
                }
              })
              .whereType<WatermarkInfoType>()
              .toList() ??
          [
            WatermarkInfoType.species,
            WatermarkInfoType.length,
            WatermarkInfoType.location,
            WatermarkInfoType.airTemperature,
            WatermarkInfoType.pressure,
            WatermarkInfoType.weather,
            WatermarkInfoType.appName,
          ],
      blurRadius: (json['blurRadius'] as num?)?.toDouble() ?? 10.0,
      backgroundOpacity: (json['backgroundOpacity'] as num?)?.toDouble() ?? 0.5,
      backgroundColor: json['backgroundColor'] as int? ?? 0xFF000000,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      textColor: json['textColor'] as int? ?? 0xFFFFFFFF,
      position: WatermarkPosition.values.firstWhere(
        (e) => e.name == json['position'],
        orElse: () => WatermarkPosition.bottomLeft,
      ),
      customText: json['customText'] as String?,
    );
  }

  factory WatermarkSettings.decode(String source) =>
      WatermarkSettings.fromJson(jsonDecode(source) as Map<String, dynamic>);
  final bool enabled;
  final WatermarkStyle style;
  final List<WatermarkInfoType> infoTypes;
  // 样式设置
  final double blurRadius; // 背景圆角程度
  final double backgroundOpacity; // 背景透明度（0.0-1.0）
  final int backgroundColor; // 背景色（RGB）
  final double fontSize; // 字体大小
  final int textColor; // 字体颜色（ARGB）
  final WatermarkPosition position; // 水印位置
  final String? customText;

  WatermarkSettings copyWith({
    bool? enabled,
    WatermarkStyle? style,
    List<WatermarkInfoType>? infoTypes,
    double? blurRadius,
    double? backgroundOpacity,
    int? backgroundColor,
    double? fontSize,
    int? textColor,
    WatermarkPosition? position,
    String? customText,
  }) {
    return WatermarkSettings(
      enabled: enabled ?? this.enabled,
      style: style ?? this.style,
      infoTypes: infoTypes ?? this.infoTypes,
      blurRadius: blurRadius ?? this.blurRadius,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      position: position ?? this.position,
      customText: customText ?? this.customText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'style': style.name,
      'infoTypes': infoTypes.map((e) => e.name).toList(),
      'blurRadius': blurRadius,
      'backgroundOpacity': backgroundOpacity,
      'backgroundColor': backgroundColor,
      'fontSize': fontSize,
      'textColor': textColor,
      'position': position.name,
      if (customText != null) 'customText': customText,
    };
  }

  String encode() => jsonEncode(toJson());
}

/// 水印信息类型信息
class WatermarkInfoTypeInfo {

  const WatermarkInfoTypeInfo({
    required this.type,
    required this.name,
    required this.icon,
  });
  final WatermarkInfoType type;
  final String name;
  final String icon;

  static const List<WatermarkInfoTypeInfo> allTypes = [
    WatermarkInfoTypeInfo(
      type: WatermarkInfoType.species,
      name: '品种',
      icon: '🐟',
    ),
    WatermarkInfoTypeInfo(
      type: WatermarkInfoType.length,
      name: '长度(cm)',
      icon: '📏',
    ),
    WatermarkInfoTypeInfo(
      type: WatermarkInfoType.weight,
      name: '重量(kg)',
      icon: '⚖️',
    ),
    WatermarkInfoTypeInfo(
      type: WatermarkInfoType.location,
      name: '钓点',
      icon: '📍',
    ),
    WatermarkInfoTypeInfo(type: WatermarkInfoType.rod, name: '鱼竿', icon: '🎣'),
    WatermarkInfoTypeInfo(type: WatermarkInfoType.reel, name: '渔轮', icon: '⚙️'),
    WatermarkInfoTypeInfo(type: WatermarkInfoType.lure, name: '鱼饵', icon: '🪝'),
    WatermarkInfoTypeInfo(type: WatermarkInfoType.time, name: '时间', icon: '🕐'),
    WatermarkInfoTypeInfo(
      type: WatermarkInfoType.airTemperature,
      name: '气温(°C)',
      icon: '🌡️',
    ),
    WatermarkInfoTypeInfo(
      type: WatermarkInfoType.pressure,
      name: '气压(hPa)',
      icon: '📊',
    ),
    WatermarkInfoTypeInfo(
      type: WatermarkInfoType.weather,
      name: '天气',
      icon: '🌤️',
    ),
    WatermarkInfoTypeInfo(
      type: WatermarkInfoType.appName,
      name: 'App名称',
      icon: '📱',
    ),
  ];
}
