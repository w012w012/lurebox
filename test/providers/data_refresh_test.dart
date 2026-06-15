import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/providers/achievement_provider.dart';
import 'package:lurebox/core/providers/data_refresh.dart';
import 'package:lurebox/core/providers/fish_providers.dart';
import 'package:lurebox/core/providers/pending_recognition_providers.dart';
import 'package:lurebox/core/providers/stats_provider.dart' as stats;

void main() {
  group('invalidateDerivedFishData', () {
    test('失效所有派生渔获 provider（写操作后统一刷新入口）', () {
      final invalidated = <ProviderOrFamily>[];

      invalidateDerivedFishData(invalidated.add);

      // 原始渔获数据
      expect(invalidated, contains(fishCatchesProviderV2));
      expect(invalidated, contains(fishCatchByIdProvider));
      expect(invalidated, contains(paginatedFishCatchesProvider));
      expect(invalidated, contains(filteredPaginatedFishCatchesProvider));
      expect(invalidated, contains(fishCatchCountProviderV2));
      expect(invalidated, contains(top3LongestCatchesProvider));
      expect(invalidated, contains(equipmentCatchStatsProvider));
      // 待识别角标
      expect(invalidated, contains(pendingRecognitionCountProvider));
      expect(invalidated, contains(pendingRecognitionCatchesProvider));
      // 统计 family（H-12 核心：历史上从不失效）
      expect(invalidated, contains(stats.timeRangeStatsProvider));
      expect(invalidated, contains(stats.top3LongestCatchesProvider));
      // 成就
      expect(invalidated, contains(allAchievementsProvider));
      expect(invalidated, contains(achievementStatsProvider));
    });

    test('不失效用户的统计时间范围选择（UI 状态）', () {
      final invalidated = <ProviderOrFamily>[];

      invalidateDerivedFishData(invalidated.add);

      expect(invalidated, isNot(contains(stats.statsTimeRangeProvider)));
    });

    test('兼容 WidgetRef/Ref 的 invalidate 闭包签名', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // container.invalidate 与 Ref.invalidate / WidgetRef.invalidate 同签名，
      // 用它验证闭包不抛异常即可证明类型兼容。
      expect(
        () => invalidateDerivedFishData(container.invalidate),
        returnsNormally,
      );
    });
  });
}
