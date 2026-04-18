import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/models/achievement.dart';
import '../../core/providers/achievement_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../widgets/common/premium_button.dart';
import '../../widgets/common/premium_card.dart';
import 'widgets/achievement_collapse_card.dart';

/// 成就页
///
/// Features:
/// - Achievement progress overview
/// - Achievement progress by category
/// - AchievementCollapseCard in list mode
/// - Pull-to-refresh support
class AchievementPage extends ConsumerStatefulWidget {
  const AchievementPage({super.key});

  @override
  ConsumerState<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends ConsumerState<AchievementPage> {
  Future<void> _onRefresh() async {
    ref.invalidate(allAchievementsProvider);
    ref.invalidate(achievementStatsProvider);
    await ref.read(allAchievementsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final achievementsAsync = ref.watch(allAchievementsProvider);
    final strings = ref.watch(currentStringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.achievement),
        centerTitle: true,
      ),
      body: achievementsAsync.when(
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                strings.loading,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 64, color: TeslaColors.electricBlue),
                const SizedBox(height: 16),
                Text(
                  strings.error,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),
                PremiumButton(
                  text: strings.retry,
                  variant: PremiumButtonVariant.primary,
                  icon: Icons.refresh,
                  onPressed: _onRefresh,
                ),
              ],
            ),
          ),
        ),
        data: (achievements) => RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildAchievementStatsOverview(
                  context,
                  achievements,
                  strings,
                ),
              ),
              _buildAchievementListView(
                context,
                achievements,
                strings,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建成就统计概览卡片（原始设计）
  Widget _buildAchievementStatsOverview(
    BuildContext context,
    List<Achievement> achievements,
    AppStrings strings,
  ) {
    if (achievements.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events_outlined,
                size: 64,
                color: TeslaColors.pewter,
              ),
              const SizedBox(height: 16),
              Text(
                strings.noAchievements,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final totalCount = achievements.length;
    final progress =
        totalCount > 0 ? (unlockedCount / totalCount * 100).round() : 0;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: PremiumCard(
        variant: PremiumCardVariant.elevated,
        padding: const EdgeInsets.all(20),
        showBorder: false,
        backgroundColor: TeslaColors.electricBlue,
        child: Row(
          children: [
            // 圆形进度指示器
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: progress / 100,
                    strokeWidth: 8,
                    backgroundColor:
                        TeslaColors.white.withValues(alpha: 0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$progress%',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: TeslaColors.white,
                                  ),
                        ),
                        Text(
                          strings.completion,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: TeslaColors.white,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // 统计信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.achievementOverview,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: TeslaColors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildAchievementStatItem(
                        context,
                        strings.unlocked,
                        '$unlockedCount',
                        Icons.emoji_events,
                        const Color(0xFFD4AF37),
                      ),
                      const SizedBox(width: 20),
                      _buildAchievementStatItem(
                        context,
                        strings.totalAchievements,
                        '$totalCount',
                        Icons.stars,
                        TeslaColors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor:
                        TeslaColors.white.withValues(alpha: 0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: TeslaColors.white,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建成就列表视图（使用 Sliver 实现）
  Widget _buildAchievementListView(
    BuildContext context,
    List<Achievement> achievements,
    AppStrings strings,
  ) {
    if (achievements.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events_outlined,
                  size: 64,
                  color: TeslaColors.pewter,
                ),
                const SizedBox(height: 16),
                Text(
                  strings.noAchievements,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 按分类分组
    final groupedAchievements = <String, List<Achievement>>{};
    for (final achievement in achievements) {
      groupedAchievements.putIfAbsent(achievement.category, () => []);
      groupedAchievements[achievement.category]!.add(achievement);
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = groupedAchievements.keys.elementAt(index);
                final categoryAchievements = groupedAchievements[category]!;

                final completedCount =
                    categoryAchievements.where((a) => a.isUnlocked).length;
                final isCompleted =
                    completedCount == categoryAchievements.length;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AchievementCollapseCard(
                    title: category,
                    currentCount: completedCount,
                    totalCount: categoryAchievements.length,
                    icon: _getCategoryIcon(category),
                    isCompleted: isCompleted,
                    initiallyExpanded: index == 0,
                    children: categoryAchievements.map((achievement) {
                      return AchievementChildItem(
                        title: achievement.title,
                        currentCount: achievement.current,
                        totalCount: achievement.target,
                        isCompleted: achievement.isUnlocked,
                        subtitle: achievement.description,
                      );
                    }).toList(),
                  ),
                );
              },
              childCount: groupedAchievements.length,
            ),
          ),
        ),
      ],
    );
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case '数量类':
        return '🐟';
      case '尺寸类':
        return '📏';
      case '品种类':
        return '🪣';
      case '地点类':
        return '📍';
      case '装备类':
        return '🎣';
      case '环保类':
        return '🌿';
      case '特殊成就':
        return '🏆';
      default:
        return '🏆';
    }
  }
}
