import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/fish_catch.dart';

/// 统计时间范围
class StatsTimeRange {

  const StatsTimeRange({
    required this.start,
    required this.end,
    required this.label,
  });
  final DateTime start;
  final DateTime end;
  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatsTimeRange &&
          runtimeType == other.runtimeType &&
          start.year == other.start.year &&
          start.month == other.start.month &&
          start.day == other.start.day &&
          end.year == other.end.year &&
          end.month == other.end.month &&
          end.day == other.end.day;

  @override
  int get hashCode =>
      start.year.hashCode ^
      start.month.hashCode ^
      start.day.hashCode ^
      end.year.hashCode ^
      end.month.hashCode ^
      end.day.hashCode;
}

/// 统计时间范围 Provider
final statsTimeRangeProvider = StateProvider<StatsTimeRange>((ref) {
  final now = DateTime.now();
  return StatsTimeRange(
    start: DateTime(2000),
    end: DateTime(now.year + 1),
    label: '全部',
  );
});

/// 时间范围内的鱼获统计
class TimeRangeStats {

  const TimeRangeStats({
    required this.totalCount,
    required this.releaseCount,
    required this.keepCount,
    required this.speciesStats,
  });
  final int totalCount;
  final int releaseCount;
  final int keepCount;
  final Map<String, int> speciesStats;

  double get releaseRate =>
      totalCount > 0 ? (releaseCount / totalCount * 100) : 0;
}

/// 时间范围统计 Provider
final timeRangeStatsProvider =
    FutureProvider.family<TimeRangeStats, StatsTimeRange>((ref, range) async {
  final fishList = await ref
      .read(fishCatchServiceProvider)
      .getByDateRange(range.start, range.end);
  // 过滤掉待识别记录
  final filteredList = fishList.filterPendingRecognition();
  final catches = filteredList.map((f) => f.toMap()).toList();

  var releaseCount = 0;
  var keepCount = 0;
  final speciesMap = <String, int>{};

  for (final fish in catches) {
    final fate = fish['fate'] as int;
    if (fate == FishFateType.release.value) {
      releaseCount++;
    } else {
      keepCount++;
    }

    final species = fish['species'] as String;
    speciesMap[species] = (speciesMap[species] ?? 0) + 1;
  }

  return TimeRangeStats(
    totalCount: catches.length,
    releaseCount: releaseCount,
    keepCount: keepCount,
    speciesStats: speciesMap,
  );
});

/// 今日统计 Provider
final todayStatsProvider = Provider<AsyncValue<TimeRangeStats>>((ref) {
  final now = DateTime.now();
  final range = StatsTimeRange(
    start: DateTime(now.year, now.month, now.day),
    end: DateTime(now.year, now.month, now.day).add(const Duration(days: 1)),
    label: '今日',
  );
  return ref.watch(timeRangeStatsProvider(range));
});

/// 本月统计 Provider
final monthStatsProvider = Provider<AsyncValue<TimeRangeStats>>((ref) {
  final now = DateTime.now();
  final range = StatsTimeRange(
    start: DateTime(now.year, now.month),
    end: DateTime(now.year, now.month + 1),
    label: '本月',
  );
  return ref.watch(timeRangeStatsProvider(range));
});

/// 本年统计 Provider
final yearStatsProvider = Provider<AsyncValue<TimeRangeStats>>((ref) {
  final now = DateTime.now();
  final range = StatsTimeRange(
    start: DateTime(now.year),
    end: DateTime(now.year + 1),
    label: '本年',
  );
  return ref.watch(timeRangeStatsProvider(range));
});

/// 全部统计 Provider
final allTimeStatsProvider = Provider<AsyncValue<TimeRangeStats>>((ref) {
  final now = DateTime.now();
  final range = StatsTimeRange(
    start: DateTime(2000),
    end: DateTime(now.year + 1),
    label: '全部',
  );
  return ref.watch(timeRangeStatsProvider(range));
});

/// 最长3条鱼获 Provider
final top3LongestCatchesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final fishList =
      await ref.read(fishCatchServiceProvider).getTop3LongestCatches();
  return fishList.map((f) => f.toMap()).toList();
});
