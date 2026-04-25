/// 分享模板配置 - 分享卡片展示选项
///
/// 定义分享卡片的视觉和行为配置：
/// - 模板类型：经典、卡片、简约三种风格
/// - 内容开关：统计、标签、水印的显示控制
/// - 自定义数据：统计数据和自定义标签
///
/// 提供 [copyWith] 方法用于创建修改后的副本。
/// 预定义默认标签和水印用于无配置时的展示。
library;

enum ShareTemplate { classic, card, minimal }

class ShareCardConfig {

  const ShareCardConfig({
    this.template = ShareTemplate.card,
    this.showStats = true,
    this.showHashtags = true,
    this.showWatermark = true,
    this.statsData,
    this.customHashtags = const [],
  });
  final ShareTemplate template;
  final bool showStats;
  final bool showHashtags;
  final bool showWatermark;
  final Map<String, dynamic>? statsData;
  final List<String> customHashtags;

  ShareCardConfig copyWith({
    ShareTemplate? template,
    bool? showStats,
    bool? showHashtags,
    bool? showWatermark,
    Map<String, dynamic>? statsData,
    List<String>? customHashtags,
  }) {
    return ShareCardConfig(
      template: template ?? this.template,
      showStats: showStats ?? this.showStats,
      showHashtags: showHashtags ?? this.showHashtags,
      showWatermark: showWatermark ?? this.showWatermark,
      statsData: statsData ?? this.statsData,
      customHashtags: customHashtags ?? this.customHashtags,
    );
  }

  static const List<String> defaultHashtags = [
    '#lurebox',
    '#fishing',
    '#catchandrelease',
  ];

  static const String watermark = 'Lurebox';
}
