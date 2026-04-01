import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/models/achievement.dart';
import '../../core/providers/achievement_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../widgets/common/premium_button.dart';
import '../../widgets/common/premium_card.dart';

/// 成就页
class AchievementPage extends ConsumerStatefulWidget {
  const AchievementPage({super.key});

  @override
  ConsumerState<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends ConsumerState<AchievementPage> {
  String _selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    final achievementsAsync = ref.watch(allAchievementsProvider);
    final strings = ref.watch(currentStringsProvider);

    if (_selectedCategory.isEmpty) {
      _selectedCategory = strings.all;
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.achievement), centerTitle: true),
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
          if (achievements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    strings.noAchievementData,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          final categories = [
            strings.all,
            strings.completed,
            ...{
              ...achievements
                  .where((a) => a.category != strings.specialAchievement)
                  .map((a) => a.category),
            },
          ];
          final filteredAchievements = _selectedCategory == strings.all
              ? achievements
                  .where(
                    (a) =>
                        a.category != strings.specialAchievement ||
                        a.isUnlocked,
                  )
                  .toList()
              : _selectedCategory == strings.completed
                  ? achievements.where((a) => a.isUnlocked).toList()
                  : achievements
                      .where((a) => a.category == _selectedCategory)
                      .toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allAchievementsProvider);
              ref.invalidate(achievementStatsProvider);
            },
            child: Column(
              children: [
                // 统计概览卡片
                _buildStatsOverview(strings),

                // 分类标签
                _buildCategoryTabs(categories, strings),

                // 成就列表
                Expanded(
                  child: _buildAchievementList(filteredAchievements, strings),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsOverview(AppStrings strings) {
    final achievementsAsync = ref.watch(allAchievementsProvider);

    return achievementsAsync.when(
      loading: () => const SizedBox(height: 120),
      error: (_, __) => const SizedBox(height: 120),
      data: (achievements) {
        final unlockedCount = achievements.where((a) => a.isUnlocked).length;
        final totalCount = achievements.length;
        final progress =
            totalCount > 0 ? (unlockedCount / totalCount * 100).round() : 0;

        return PremiumCard(
          variant: PremiumCardVariant.elevated,
          padding: const EdgeInsets.all(20),
          showBorder: false,
          backgroundColor: Theme.of(context).colorScheme.primary,
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
                      backgroundColor: AppColors.surfaceLight.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.gold,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$progress%',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.surfaceLight,
                                ),
                          ),
                          Text(
                            strings.completion,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppColors.surfaceLight),
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
                            fontWeight: FontWeight.bold,
                            color: AppColors.surfaceLight,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatItem(
                          strings.unlocked,
                          '$unlockedCount',
                          Icons.emoji_events,
                          AppColors.gold,
                        ),
                        const SizedBox(width: 20),
                        _buildStatItem(
                          strings.totalAchievements,
                          '$totalCount',
                          Icons.stars,
                          AppColors.surfaceLight,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: AppColors.surfaceLight.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.gold,
                      ),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
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
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.surfaceLight),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryTabs(List<String> categories, AppStrings strings) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? AppColors.surfaceLight
                        : AppColors.textPrimaryLight,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchievementList(
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                category,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            ...categoryAchievements.map(
              (achievement) => _buildAchievementCard(achievement, strings),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement, AppStrings strings) {
    final isUnlocked = achievement.isUnlocked;
    final levelColor = _getLevelColor(achievement.level);

    return PremiumCard(
      variant: PremiumCardVariant.elevated,
      showBorder: isUnlocked,
      backgroundColor: isUnlocked
          ? AppColors.surfaceLight
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(16),
      shadows: isUnlocked
          ? [
              BoxShadow(
                color: levelColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
      child: Row(
        children: [
          // 图标
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? levelColor.withOpacity(0.1)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                achievement.icon,
                style: TextStyle(
                  fontSize: 24,
                  color: isUnlocked
                      ? null
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isUnlocked
                                      ? AppColors.textPrimaryLight
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                ),
                      ),
                    ),
                    // 等级标签
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: levelColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        achievement.level.name,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: levelColor,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                // 进度条
                if (!isUnlocked) ...[
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: achievement.progressPercent / 100,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.outline,
                          valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${achievement.current}/${achievement.target}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        strings.achieved,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // 解锁状态图标
          if (isUnlocked)
            Icon(Icons.emoji_events, color: levelColor, size: 28)
          else
            Icon(
              Icons.lock_outline,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
        ],
      ),
    );
  }

  Color _getLevelColor(AchievementLevel level) {
    switch (level) {
      case AchievementLevel.bronze:
        return AppColors.bronze;
      case AchievementLevel.silver:
        return AppColors.silver;
      case AchievementLevel.gold:
        return AppColors.gold;
      case AchievementLevel.platinum:
        return AppColors.info;
    }
  }
}
