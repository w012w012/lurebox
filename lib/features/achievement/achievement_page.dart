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
class AchievementPage extends ConsumerWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(allAchievementsProvider);
    final strings = ref.watch(currentStringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('成就'),
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
                    size: 64, color: AppColors.error),
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
                  onPressed: () {
                    ref.invalidate(allAchievementsProvider);
                    ref.invalidate(achievementStatsProvider);
                  },
                ),
              ],
            ),
          ),
        ),
        data: (achievements) {
          return _buildAchievementsContent(context, achievements, strings);
        },
      ),
    );
  }

  /// 构建成就内容（显示成就统计概览和成就列表）
  Widget _buildAchievementsContent(
    BuildContext context,
    List<Achievement> achievements,
    AppStrings strings,
  ) {
    // 显示所有成就
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: AppColors.grey500,
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
      );
    }

    // 计算成就统计
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final totalCount = achievements.length;
    final progress =
        totalCount > 0 ? (unlockedCount / totalCount * 100).round() : 0;

    return Column(
      children: [
        // 成就统计概览卡片（使用原始设计）
        _buildAchievementStatsOverview(
            context, unlockedCount, totalCount, progress, strings),
        // 成就列表
        Expanded(
          child: _buildAchievementListView(context, achievements, strings),
        ),
      ],
    );
  }

  /// 构建成就统计概览卡片（原始设计）
  Widget _buildAchievementStatsOverview(
    BuildContext context,
    int unlockedCount,
    int totalCount,
    int progress,
    AppStrings strings,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: PremiumCard(
        variant: PremiumCardVariant.elevated,
        padding: const EdgeInsets.all(20),
        showBorder: false,
        backgroundColor: AppColors.primaryLight,
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
                        AppColors.surfaceLight.withValues(alpha: 0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.gold),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$progress%',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.surfaceLight,
                                  ),
                        ),
                        Text(
                          '完成',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.surfaceLight,
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
                    '成就概览',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.surfaceLight,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildAchievementStatItem(
                        context,
                        '已解锁',
                        '$unlockedCount',
                        Icons.emoji_events,
                        AppColors.gold,
                      ),
                      const SizedBox(width: 20),
                      _buildAchievementStatItem(
                        context,
                        '总成就',
                        '$totalCount',
                        Icons.stars,
                        AppColors.surfaceLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor:
                        AppColors.surfaceLight.withValues(alpha: 0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.gold),
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
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.surfaceLight,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementListView(
    BuildContext context,
    List<Achievement> achievements,
    AppStrings strings,
  ) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: AppColors.grey500,
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
      );
    }

    // 按分类分组
    final groupedAchievements = <String, List<Achievement>>{};
    for (final achievement in achievements) {
      groupedAchievements.putIfAbsent(achievement.category, () => []);
      groupedAchievements[achievement.category]!.add(achievement);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedAchievements.length,
      itemBuilder: (context, index) {
        final category = groupedAchievements.keys.elementAt(index);
        final categoryAchievements = groupedAchievements[category]!;

        final completedCount =
            categoryAchievements.where((a) => a.isUnlocked).length;
        final isCompleted = completedCount == categoryAchievements.length;

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
    );
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case '数量':
        return '🐟';
      case '尺寸':
        return '📏';
      case '品种':
        return '🪣';
      case '地点':
        return '📍';
      default:
        return '🏆';
    }
  }
}
