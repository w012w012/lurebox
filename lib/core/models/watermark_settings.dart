import 'dart:convert';

/// 水印设置数据模型
///
/// 定义了渔获图片水印功能的配置结构。
///
/// 组成元素：
/// - [WatermarkStyle]: 水印样式枚举（当前仅支持 minimal 简约风格）
///
/// - [WatermarkInfoType]: 可显示的水印信息类型
///   品种、长度、重量、钓点、鱼竿、渔轮、鱼饵、时间、App名称
///
/// - [WatermarkSettings]: 水印配置类
///   控制水印是否启用、使用的样式以及显示哪些信息
///   支持 JSON 序列化和反序列化
///
/// - [WatermarkInfoTypeInfo]: 水印信息类型的元数据
///   包含类型的显示名称和图标，用于 UI 展示
///
/// 默认配置：
/// - 启用状态：true
/// - 样式：minimal（简约左下）
/// - 默认显示：品种、长度、钓点、App名称
///
/// 使用场景：
/// - 用户拍摄渔获照片后添加水印
/// - 在分享图片时嵌入渔获信息

/// 水印样式枚举
enum WatermarkStyle {
  minimal, // 简约左下
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

/// 水印设置
class WatermarkSettings {
  final bool enabled;
  final WatermarkStyle style;
  final List<WatermarkInfoType> infoTypes;

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
  });

  WatermarkSettings copyWith({
    bool? enabled,
    WatermarkStyle? style,
    List<WatermarkInfoType>? infoTypes,
  }) {
    return WatermarkSettings(
      enabled: enabled ?? this.enabled,
      style: style ?? this.style,
      infoTypes: infoTypes ?? this.infoTypes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'style': style.name,
      'infoTypes': infoTypes.map((e) => e.name).toList(),
    };
  }

  factory WatermarkSettings.fromJson(Map<String, dynamic> json) {
    return WatermarkSettings(
      enabled: json['enabled'] as bool? ?? true,
      style: WatermarkStyle.minimal,
      infoTypes: (json['infoTypes'] as List<dynamic>?)
              ?.map(
                (e) => WatermarkInfoType.values.firstWhere(
                  (type) => type.name == e,
                  orElse: () => WatermarkInfoType.species,
                ),
              )
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
    );
  }

  String encode() => jsonEncode(toJson());

  factory WatermarkSettings.decode(String source) =>
      WatermarkSettings.fromJson(jsonDecode(source));
}

/// 水印信息类型信息
class WatermarkInfoTypeInfo {
  final WatermarkInfoType type;
  final String name;
  final String icon;

  const WatermarkInfoTypeInfo({
    required this.type,
    required this.name,
    required this.icon,
  });

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
