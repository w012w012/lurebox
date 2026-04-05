import 'dart:math';
import '../repositories/fish_catch_repository.dart';
import 'fish_species_matcher.dart';

/// 尺寸分布桶
class SizeBucket {
  final String range;
  final int count;

  const SizeBucket({
    required this.range,
    required this.count,
  });

  @override
  String toString() => 'SizeBucket(range: $range, count: $count)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SizeBucket &&
          runtimeType == other.runtimeType &&
          range == other.range &&
          count == other.count;

  @override
  int get hashCode => range.hashCode ^ count.hashCode;
}

/// 鱼种统计 (动态计算，不存储)
class FishSpeciesStats {
  final String speciesId;
  final String speciesName;
  final int totalCount;
  final double maxLength;
  final double minLength;
  final double avgLength;
  final double? maxWeight;
  final DateTime? firstCaughtAt;
  final bool isUnlocked;

  const FishSpeciesStats({
    required this.speciesId,
    required this.speciesName,
    required this.totalCount,
    required this.maxLength,
    required this.minLength,
    required this.avgLength,
    this.maxWeight,
    this.firstCaughtAt,
    required this.isUnlocked,
  });

  /// 创建空统计（未解锁/未找到鱼种）
  ///
  /// [speciesId] 鱼种ID（未知时为空字符串）
  /// [speciesName] 鱼种名称
  factory FishSpeciesStats.empty({
    String speciesId = '',
    required String speciesName,
  }) {
    return FishSpeciesStats(
      speciesId: speciesId,
      speciesName: speciesName,
      totalCount: 0,
      maxLength: 0,
      minLength: 0,
      avgLength: 0,
      maxWeight: null,
      firstCaughtAt: null,
      isUnlocked: false,
    );
  }

  @override
  String toString() =>
      'FishSpeciesStats(speciesId: $speciesId, speciesName: $speciesName, '
      'totalCount: $totalCount, maxLength: $maxLength, minLength: $minLength, '
      'avgLength: $avgLength, maxWeight: $maxWeight, firstCaughtAt: $firstCaughtAt, '
      'isUnlocked: $isUnlocked)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FishSpeciesStats &&
          runtimeType == other.runtimeType &&
          speciesId == other.speciesId &&
          speciesName == other.speciesName &&
          totalCount == other.totalCount &&
          maxLength == other.maxLength &&
          minLength == other.minLength &&
          avgLength == other.avgLength &&
          maxWeight == other.maxWeight &&
          firstCaughtAt == other.firstCaughtAt &&
          isUnlocked == other.isUnlocked;

  @override
  int get hashCode =>
      speciesId.hashCode ^
      speciesName.hashCode ^
      totalCount.hashCode ^
      maxLength.hashCode ^
      minLength.hashCode ^
      avgLength.hashCode ^
      maxWeight.hashCode ^
      firstCaughtAt.hashCode ^
      isUnlocked.hashCode;
}

/// 鱼种统计服务
///
/// 提供鱼种的动态统计信息，包括：
/// - 总捕获数量
/// - 尺寸统计（最大、最小、平均）
/// - 重量统计（最大）
/// - 首次捕获时间
/// - 尺寸分布
///
/// 所有统计均为动态计算，不存储数据。
class FishSpeciesStatsService {
  final FishCatchRepository _catchRepo;
  final FishSpeciesMatcher _matcher;

  FishSpeciesStatsService(this._catchRepo, this._matcher);

  /// 获取鱼种统计信息
  ///
  /// 根据别名或名称查找鱼种，然后计算该鱼种的所有统计信息。
  /// 如果找不到鱼种或没有捕获记录，返回空的统计对象。
  ///
  /// [aliasOrName] 别名或标准名称
  /// 返回鱼种统计信息
  Future<FishSpeciesStats> getStats(String aliasOrName) async {
    // 1. 找到标准鱼种
    final species = _matcher.findSpeciesByName(aliasOrName);
    if (species == null) {
      return FishSpeciesStats.empty(speciesName: aliasOrName);
    }

    // 2. 查询所有相关渔获
    final catches = await _catchRepo.getAll();
    // 过滤出该鱼种的渔获（通过标准名称或别名匹配）
    final speciesCatches = catches.where((c) {
      return c.species == species.standardName ||
          species.aliases.any((alias) => c.species == alias);
    }).toList();

    if (speciesCatches.isEmpty) {
      return FishSpeciesStats.empty(
        speciesId: species.id,
        speciesName: species.standardName,
      );
    }

    // 3. 计算统计
    final lengths = speciesCatches.map((c) => c.length).toList();
    final maxLength = lengths.reduce(max);
    final minLength = lengths.reduce(min);
    final avgLength = lengths.average;

    final weightsWithValue = speciesCatches
        .where((c) => c.weight != null)
        .map((c) => c.weight!)
        .toList();
    final maxWeight =
        weightsWithValue.isEmpty ? null : weightsWithValue.reduce(max);

    final catchTimes = speciesCatches.map((c) => c.catchTime).toList();
    final firstCaughtAt = catchTimes.reduce(_minDateTime);

    return FishSpeciesStats(
      speciesId: species.id,
      speciesName: species.standardName,
      totalCount: speciesCatches.length,
      maxLength: maxLength,
      minLength: minLength,
      avgLength: avgLength,
      maxWeight: maxWeight,
      firstCaughtAt: firstCaughtAt,
      isUnlocked: true,
    );
  }

  static DateTime _minDateTime(DateTime a, DateTime b) => a.isBefore(b) ? a : b;

  /// 获取鱼种尺寸分布
  ///
  /// [speciesId] 鱼种ID
  /// 返回尺寸分布桶列表
  Future<List<SizeBucket>> getSizeDistribution(String speciesId) async {
    final catches = await _catchRepo.getAll();

    // 查找该鱼种
    final species = _matcher.findSpeciesByName(speciesId);
    if (species == null) {
      return _emptySizeBuckets();
    }

    // 过滤该鱼种的渔获
    final speciesCatches = catches.where((c) {
      return c.species == species.standardName ||
          species.aliases.any((alias) => c.species == alias);
    }).toList();

    return [
      SizeBucket(
        range: '10-20',
        count:
            speciesCatches.where((c) => c.length >= 10 && c.length < 20).length,
      ),
      SizeBucket(
        range: '20-30',
        count:
            speciesCatches.where((c) => c.length >= 20 && c.length < 30).length,
      ),
      SizeBucket(
        range: '30-40',
        count:
            speciesCatches.where((c) => c.length >= 30 && c.length < 40).length,
      ),
      SizeBucket(
        range: '40-50',
        count:
            speciesCatches.where((c) => c.length >= 40 && c.length < 50).length,
      ),
      SizeBucket(
        range: '50+',
        count: speciesCatches.where((c) => c.length >= 50).length,
      ),
    ];
  }

  List<SizeBucket> _emptySizeBuckets() {
    return const [
      SizeBucket(range: '10-20', count: 0),
      SizeBucket(range: '20-30', count: 0),
      SizeBucket(range: '30-40', count: 0),
      SizeBucket(range: '40-50', count: 0),
      SizeBucket(range: '50+', count: 0),
    ];
  }
}

extension DoubleListAverage on List<double> {
  double get average {
    if (isEmpty) return 0;
    return reduce((a, b) => a + b) / length;
  }
}
