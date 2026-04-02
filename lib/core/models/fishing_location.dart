/// 钓点位置数据模型
///
/// 定义了钓鱼位置的基础数据结构 [FishingLocation]。
/// 用于管理和存储用户常去的钓点信息。
///
/// 字段说明：
/// - id: 钓点唯一标识
/// - name: 钓点名称
/// - latitude/longitude: GPS 坐标
/// - lastVisit: 最后访问时间
/// - fishCount: 在此钓点的捕获总数
/// - createdAt: 记录创建时间
///
/// 提供的功能：
/// - hasCoordinates: 检查是否有有效的 GPS 坐标
/// - coordinateString: 获取格式化的坐标字符串
///
/// 列表扩展 [FishingLocationListExtension]：
/// - sortedByFishCount(): 按捕获数降序排序
/// - sortedByName(): 按名称字母排序
/// - sortedByLastVisit(): 按最后访问时间降序排序
/// - findByName(): 根据名称查找钓点
///
/// 典型用途：
/// - 钓点管理（增删改查）
/// - 在地图上显示钓点
/// - 统计各钓点的捕获记录
library;

class FishingLocation {
  final int id;
  final String name;
  final double? latitude;
  final double? longitude;
  final DateTime? lastVisit;
  final int fishCount;
  final DateTime createdAt;

  const FishingLocation({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
    this.lastVisit,
    this.fishCount = 0,
    required this.createdAt,
  });

  factory FishingLocation.fromMap(Map<String, dynamic> map) {
    return FishingLocation(
      id: map['id'] as int,
      name: map['name'] as String,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      lastVisit: map['last_visit'] != null
          ? DateTime.parse(map['last_visit'] as String)
          : null,
      fishCount: map['fish_count'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'last_visit': lastVisit?.toIso8601String(),
      'fish_count': fishCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  FishingLocation copyWith({
    int? id,
    String? name,
    double? Function()? latitude,
    double? Function()? longitude,
    DateTime? Function()? lastVisit,
    int? fishCount,
    DateTime? createdAt,
  }) {
    return FishingLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude != null ? latitude() : this.latitude,
      longitude: longitude != null ? longitude() : this.longitude,
      lastVisit: lastVisit != null ? lastVisit() : this.lastVisit,
      fishCount: fishCount ?? this.fishCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get hasCoordinates => latitude != null && longitude != null;

  String get coordinateString {
    if (!hasCoordinates) return '';
    return '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FishingLocation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'FishingLocation(id: $id, name: $name, fishCount: $fishCount)';
}

extension FishingLocationListExtension on List<FishingLocation> {
  List<FishingLocation> sortedByFishCount() {
    final sorted = List<FishingLocation>.from(this);
    sorted.sort((a, b) => b.fishCount.compareTo(a.fishCount));
    return sorted;
  }

  List<FishingLocation> sortedByName() {
    final sorted = List<FishingLocation>.from(this);
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  List<FishingLocation> sortedByLastVisit() {
    final sorted = List<FishingLocation>.from(this);
    sorted.sort((a, b) {
      if (a.lastVisit == null && b.lastVisit == null) return 0;
      if (a.lastVisit == null) return 1;
      if (b.lastVisit == null) return -1;
      return b.lastVisit!.compareTo(a.lastVisit!);
    });
    return sorted;
  }

  FishingLocation? findByName(String name) {
    try {
      return firstWhere((l) => l.name == name);
    } catch (_) {
      return null;
    }
  }
}
