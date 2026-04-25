/// 统计数据模型集合
///
/// 定义了应用中各类统计和指标的数据模型：
///
/// - [CatchStats]: 基础的捕获统计（总数、放流数、保留数、放流率）
///   用于简单的统计展示场景
///
/// - [DashboardData]: 仪表盘综合数据
///   聚合了今日、本月、本年、全部的统计数据和鱼种分布
///   以及最大的3条渔获记录
///
/// - [EquipmentCatchStats]: 单个钓具的捕获统计
///   用于分析特定钓具的捕获效果
///
/// - [AchievementMetrics]: 成就系统指标集合
///   包含30+个指标字段，用于追踪用户成就进度
///   涵盖：捕获数量、尺寸、物种、装备、时间段、早晚捕获等多维度数据
///
/// 设计特点：
/// - CatchStats 使用简单的数值字段，便于计算和展示
/// - AchievementMetrics 使用默认值，支持增量更新
library;

class CatchStats {

  const CatchStats({
    required this.total,
    required this.release,
    required this.keep,
  });

  factory CatchStats.fromMap(Map<String, dynamic> map) {
    return CatchStats(
      total: map['total'] as int? ?? 0,
      release: map['release'] as int? ?? 0,
      keep: map['keep'] as int? ?? 0,
    );
  }
  final int total;
  final int release;
  final int keep;

  double get releaseRate => total > 0 ? release / total : 0.0;

  Map<String, dynamic> toMap() {
    return {'total': total, 'release': release, 'keep': keep};
  }

  CatchStats copyWith({int? total, int? release, int? keep}) {
    return CatchStats(
      total: total ?? this.total,
      release: release ?? this.release,
      keep: keep ?? this.keep,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CatchStats &&
        other.total == total &&
        other.release == release &&
        other.keep == keep;
  }

  @override
  int get hashCode => Object.hash(total, release, keep);
}

class DashboardData {

  const DashboardData({
    required this.todayStats,
    required this.todaySpecies,
    required this.monthStats,
    required this.monthSpecies,
    required this.yearStats,
    required this.yearSpecies,
    required this.allStats,
    required this.allSpecies,
    required this.top3Longest,
    this.monthTrend = const [],
  });
  final CatchStats todayStats;
  final Map<String, int> todaySpecies;
  final CatchStats monthStats;
  final Map<String, int> monthSpecies;
  final CatchStats yearStats;
  final Map<String, int> yearSpecies;
  final CatchStats allStats;
  final Map<String, int> allSpecies;
  final List<Map<String, dynamic>> top3Longest;
  final List<Map<String, dynamic>> monthTrend;
}

class EquipmentCatchStats {

  const EquipmentCatchStats({
    required this.equipmentId,
    required this.catchCount,
    this.avgLength,
    this.avgWeight,
    this.releaseCount = 0,
  });

  factory EquipmentCatchStats.fromMap(Map<String, dynamic> map) {
    return EquipmentCatchStats(
      equipmentId: map['equipment_id'] as int? ?? 0,
      catchCount: map['catch_count'] as int? ?? 0,
      avgLength: map['avg_length'] as double?,
      avgWeight: map['avg_weight'] as double?,
      releaseCount: map['release_count'] as int? ?? 0,
    );
  }
  final int equipmentId;
  final int catchCount;
  final double? avgLength;
  final double? avgWeight;
  final int releaseCount;

  Map<String, dynamic> toMap() {
    return {
      'equipment_id': equipmentId,
      'catch_count': catchCount,
      'avg_length': avgLength,
      'avg_weight': avgWeight,
      'release_count': releaseCount,
    };
  }

  EquipmentCatchStats copyWith({
    int? equipmentId,
    int? catchCount,
    double? avgLength,
    double? avgWeight,
    int? releaseCount,
  }) {
    return EquipmentCatchStats(
      equipmentId: equipmentId ?? this.equipmentId,
      catchCount: catchCount ?? this.catchCount,
      avgLength: avgLength ?? this.avgLength,
      avgWeight: avgWeight ?? this.avgWeight,
      releaseCount: releaseCount ?? this.releaseCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EquipmentCatchStats &&
        other.equipmentId == equipmentId &&
        other.catchCount == catchCount &&
        other.avgLength == avgLength &&
        other.avgWeight == avgWeight &&
        other.releaseCount == releaseCount;
  }

  @override
  int get hashCode => Object.hash(
        equipmentId,
        catchCount,
        avgLength,
        avgWeight,
        releaseCount,
      );
}

class AchievementMetrics {

  const AchievementMetrics({
    this.totalCatches = 0,
    this.maxLength = 0.0,
    this.speciesCount = 0,
    this.equipmentCount = 0,
    this.locationCount = 0,
    this.releaseCount = 0,
    this.releaseRate = 0.0,
    this.consecutiveDays = 0,
    this.monthlyMax = 0,
    this.dailyMax = 0,
    this.morningCatches = 0,
    this.nightCatches = 0,
    this.photoCount = 0,
    this.totalWeight = 0.0,
    this.equipmentComboMax = 0,
    this.equipmentFull = false,
    this.newRecord = false,
    this.shareCount = 0,
  });
  final int totalCatches;
  final double maxLength;
  final int speciesCount;
  final int equipmentCount;
  final int locationCount;
  final int releaseCount;
  final double releaseRate;
  final int consecutiveDays;
  final int monthlyMax;
  final int dailyMax;
  final int morningCatches;
  final int nightCatches;
  final int photoCount;
  final double totalWeight;
  final int equipmentComboMax;
  final bool equipmentFull;
  final bool newRecord;
  final int shareCount;

  AchievementMetrics copyWith({
    int? totalCatches,
    double? maxLength,
    int? speciesCount,
    int? equipmentCount,
    int? locationCount,
    int? releaseCount,
    double? releaseRate,
    int? consecutiveDays,
    int? monthlyMax,
    int? dailyMax,
    int? morningCatches,
    int? nightCatches,
    int? photoCount,
    double? totalWeight,
    int? equipmentComboMax,
    bool? equipmentFull,
    bool? newRecord,
    int? shareCount,
  }) {
    return AchievementMetrics(
      totalCatches: totalCatches ?? this.totalCatches,
      maxLength: maxLength ?? this.maxLength,
      speciesCount: speciesCount ?? this.speciesCount,
      equipmentCount: equipmentCount ?? this.equipmentCount,
      locationCount: locationCount ?? this.locationCount,
      releaseCount: releaseCount ?? this.releaseCount,
      releaseRate: releaseRate ?? this.releaseRate,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      monthlyMax: monthlyMax ?? this.monthlyMax,
      dailyMax: dailyMax ?? this.dailyMax,
      morningCatches: morningCatches ?? this.morningCatches,
      nightCatches: nightCatches ?? this.nightCatches,
      photoCount: photoCount ?? this.photoCount,
      totalWeight: totalWeight ?? this.totalWeight,
      equipmentComboMax: equipmentComboMax ?? this.equipmentComboMax,
      equipmentFull: equipmentFull ?? this.equipmentFull,
      newRecord: newRecord ?? this.newRecord,
      shareCount: shareCount ?? this.shareCount,
    );
  }
}
