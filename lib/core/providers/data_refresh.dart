import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/providers/achievement_provider.dart';
import 'package:lurebox/core/providers/fish_providers.dart';
import 'package:lurebox/core/providers/home_view_model.dart';
import 'package:lurebox/core/providers/pending_recognition_providers.dart';
import 'package:lurebox/core/providers/stats_provider.dart' as stats;

/// 渔获数据写操作后的统一失效入口。
///
/// 历史 bug（H-12）：保存/编辑/删除/恢复渔获后，没有任何地方失效派生数据
/// provider，导致首页仪表盘、统计、成就、待识别角标长期显示旧值，只能靠
/// 下拉刷新。此处集中失效所有「从 fish_catches 派生」的 provider。
///
/// 通过传入 `ref.invalidate` 闭包以同时兼容 [WidgetRef] 与 [Ref]
///（两者的 `invalidate(ProviderOrFamily)` 签名一致）。
///
/// 故意【不】失效：
/// - [stats.statsTimeRangeProvider]：用户选择的统计时间范围（UI 状态）
/// - `fishListViewModelProvider`：持有用户的筛选/多选/滚动状态；列表页在
///   进入时通过 `loadCatches(reset: true)` 自行刷新，避免清空用户筛选。
void invalidateDerivedFishData(void Function(ProviderOrFamily) invalidate) {
  // 原始渔获数据
  invalidate(fishCatchesProviderV2);
  invalidate(fishCatchByIdProvider);
  invalidate(fishCatchesByDateRangeProvider);
  invalidate(fishCatchesByFateProvider);
  invalidate(paginatedFishCatchesProvider);
  invalidate(filteredPaginatedFishCatchesProvider);
  invalidate(fishCatchCountProviderV2);
  invalidate(top3LongestCatchesProvider);
  invalidate(speciesStatsProvider);
  invalidate(equipmentCatchStatsProvider);
  invalidate(equipmentDistributionProvider);

  // 待识别角标
  invalidate(pendingRecognitionCountProvider);
  invalidate(pendingRecognitionCatchesProvider);

  // 统计（keep-alive family，历史上从不失效 —— H-12 核心）
  invalidate(stats.timeRangeStatsProvider);
  invalidate(stats.top3LongestCatchesProvider);

  // 成就（保存/删除后里程碑可能变化）
  invalidate(allAchievementsProvider);
  invalidate(achievementStatsProvider);

  // 首页仪表盘（StateNotifier：失效后下次读取重建并重新 loadData）
  invalidate(homeViewModelProvider);
}
