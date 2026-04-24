/// 钓点位置与统计数据模型
///
/// 定义了与钓鱼位置相关的两类数据模型：
/// - [LocationWithStats]: 包含钓点基本信息（名称、坐标）和捕获统计
///   用于展示钓点列表时显示捕获数量和最后捕获时间
///
/// - [LocationStats]: 包含钓点的详细统计数据
///   用于分析特定钓点的捕获情况，包括：
///   - 总捕获数、放流数、保留数
///   - 鱼种分布（speciesDistribution）
///   - 平均长度和平均重量
///   - 放流率（releaseRate）
///
/// 典型用途：
/// - 在地图上显示钓点标记
/// - 统计各钓点的捕获数据
/// - 分析不同钓点的鱼类分布
library;

class LocationWithStats {
  final String name;
  final double latitude;
  final double longitude;
  final int fishCount;
  final DateTime? lastCatchTime;

  const LocationWithStats({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.fishCount,
    this.lastCatchTime,
  });

  factory LocationWithStats.fromMap(Map<String, dynamic> map) {
    return LocationWithStats(
      name: map['location_name'] as String? ?? 'Unknown',
      latitude: map['latitude'] as double? ?? 0.0,
      longitude: map['longitude'] as double? ?? 0.0,
      fishCount: map['fish_count'] as int? ?? 0,
      lastCatchTime: map['last_catch_time'] != null
          ? DateTime.tryParse(map['last_catch_time'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'location_name': name,
      'latitude': latitude,
      'longitude': longitude,
      'fish_count': fishCount,
      'last_catch_time': lastCatchTime?.toIso8601String(),
    };
  }

  LocationWithStats copyWith({
    String? name,
    double? latitude,
    double? longitude,
    int? fishCount,
    DateTime? lastCatchTime,
  }) {
    return LocationWithStats(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fishCount: fishCount ?? this.fishCount,
      lastCatchTime: lastCatchTime ?? this.lastCatchTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationWithStats &&
        other.name == name &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(name, latitude, longitude);

  @override
  String toString() {
    return 'LocationWithStats(name: $name, lat: $latitude, lng: $longitude, fishCount: $fishCount)';
  }
}

class LocationStats {
  final int totalCatches;
  final int releaseCount;
  final int keepCount;
  final Map<String, int> speciesDistribution;
  final double? avgLength;
  final double? avgWeight;

  const LocationStats({
    required this.totalCatches,
    required this.releaseCount,
    required this.keepCount,
    required this.speciesDistribution,
    this.avgLength,
    this.avgWeight,
  });

  double get releaseRate =>
      totalCatches > 0 ? releaseCount / totalCatches : 0.0;

  factory LocationStats.fromMap(Map<String, dynamic> map) {
    return LocationStats(
      totalCatches: map['total_catches'] as int? ?? 0,
      releaseCount: map['release_count'] as int? ?? 0,
      keepCount: map['keep_count'] as int? ?? 0,
      speciesDistribution: _safeIntMap(map['species_distribution']),
      avgLength: map['avg_length'] as double?,
      avgWeight: map['avg_weight'] as double?,
    );
  }

  /// 安全地将 dynamic Map 转换为 Map<String, int>
  ///
  /// JSON 解码后数值可能为 num/double，需要安全转换
  static Map<String, int> _safeIntMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, int>) return value;
    if (value is Map) {
      final result = <String, int>{};
      for (final entry in value.entries) {
        final v = entry.value;
        if (v is num) {
          result[entry.key.toString()] = v.toInt();
        }
      }
      return result;
    }
    return {};
  }

  Map<String, dynamic> toMap() {
    return {
      'total_catches': totalCatches,
      'release_count': releaseCount,
      'keep_count': keepCount,
      'species_distribution': speciesDistribution,
      'avg_length': avgLength,
      'avg_weight': avgWeight,
    };
  }

  LocationStats copyWith({
    int? totalCatches,
    int? releaseCount,
    int? keepCount,
    Map<String, int>? speciesDistribution,
    double? avgLength,
    double? avgWeight,
  }) {
    return LocationStats(
      totalCatches: totalCatches ?? this.totalCatches,
      releaseCount: releaseCount ?? this.releaseCount,
      keepCount: keepCount ?? this.keepCount,
      speciesDistribution: speciesDistribution ?? this.speciesDistribution,
      avgLength: avgLength ?? this.avgLength,
      avgWeight: avgWeight ?? this.avgWeight,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationStats &&
        other.totalCatches == totalCatches &&
        other.releaseCount == releaseCount &&
        other.keepCount == keepCount &&
        _mapEquals(other.speciesDistribution, speciesDistribution) &&
        other.avgLength == avgLength &&
        other.avgWeight == avgWeight;
  }

  static bool _mapEquals(Map<String, int>? a, Map<String, int>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        totalCatches,
        releaseCount,
        keepCount,
        Object.hashAll(speciesDistribution.entries
            .map((e) => Object.hash(e.key, e.value))),
        avgLength,
        avgWeight,
      );
}
