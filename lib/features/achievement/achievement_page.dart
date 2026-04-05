import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/models/achievement.dart';
import '../../core/providers/achievement_provider.dart';
import '../../core/providers/fish_guide_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../widgets/common/premium_button.dart';
import '../../widgets/common/premium_card.dart';
import 'widgets/achievement_overview_card.dart';
import 'widgets/achievement_collapse_card.dart';
import 'widgets/fish_detail_bottom_sheet.dart';

/// 成就页
///
/// Features:
/// - Tabs for fish collection and achievements
/// - Fish collection progress overview
/// - Achievement progress overview
/// - AchievementCollapseCard in list mode
class AchievementPage extends ConsumerStatefulWidget {
  const AchievementPage({super.key});

  @override
  ConsumerState<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends ConsumerState<AchievementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievementsAsync = ref.watch(allAchievementsProvider);
    final fishGuideState = ref.watch(fishGuideProvider);
    final strings = ref.watch(currentStringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('成就 · 图鉴'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '鱼类收藏'),
            Tab(text: '成就'),
          ],
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textSecondaryLight,
          indicatorColor: AppColors.accentLight,
        ),
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
          // Always show tabs and fish guide, even if achievements are empty
          // Tab 1 (鱼类收藏) shows fish guide from fishGuideProvider
          // Tab 2 (成就) shows original achievement content

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: 鱼类收藏 - 显示鱼种图鉴网格/列表视图（无概览卡片）
              _buildFishCollectionContent(
                  fishGuideState, achievements, strings),
              // Tab 2: 成就 - 显示原有成就内容（成就统计概览卡片在方法内部）
              _buildAchievementsContent(achievements, strings),
            ],
          );
        },
      ),
    );
  }

  /// 构建鱼种图鉴概览卡片
  /// 基于 FishGuideState 显示鱼种解锁进度
  Widget _buildFishGuideOverviewCard(
      FishGuideState fishGuideState, AppStrings strings) {
    final unlockedCount = fishGuideState.unlockedCount;
    final totalCount = fishGuideState.totalCount;

    // 计算本月新增
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthlyNewCount = fishGuideState.speciesList
        .where((s) =>
            s.stats.isUnlocked &&
            s.stats.firstCaughtAt != null &&
            s.stats.firstCaughtAt!.isAfter(monthStart))
        .length;

    AchievementProgressStatus status;
    if (unlockedCount == 0) {
      status = AchievementProgressStatus.locked;
    } else if (unlockedCount == totalCount && totalCount > 0) {
      status = AchievementProgressStatus.completed;
    } else {
      status = AchievementProgressStatus.inProgress;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AchievementOverviewCard(
        unlockedCount: unlockedCount,
        totalCount: totalCount,
        monthlyNewCount: monthlyNewCount,
        status: status,
      ),
    );
  }

  Widget _buildFishCollectionContent(
    FishGuideState fishGuideState,
    List<Achievement> achievements,
    AppStrings strings,
  ) {
    // 如果正在加载，显示加载指示器
    if (fishGuideState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在加载鱼种数据...'),
          ],
        ),
      );
    }

    // 如果有错误，显示错误信息
    if (fishGuideState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败: ${fishGuideState.error}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(fishGuideProvider.notifier).refresh();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 鱼种图鉴进度概览卡片
        _buildFishGuideOverviewCard(fishGuideState, strings),
        // 筛选标签
        _buildCategoryFilterChips(fishGuideState),
        // 列表视图
        Expanded(
          child: _buildFishListView(fishGuideState),
        ),
      ],
    );
  }

  /// 构建分类筛选标签
  Widget _buildCategoryFilterChips(FishGuideState fishGuideState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: FishGuideCategoryFilter.values.map((filter) {
            final isSelected = fishGuideState.categoryFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter.label),
                selected: isSelected,
                onSelected: (selected) {
                  ref
                      .read(fishGuideProvider.notifier)
                      .setCategoryFilter(filter);
                },
                backgroundColor: AppColors.grey100,
                selectedColor: AppColors.accentLight.withOpacity(0.2),
                checkmarkColor: AppColors.accentLight,
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppColors.accentLight
                      : AppColors.textSecondaryLight,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                  color:
                      isSelected ? AppColors.accentLight : Colors.transparent,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 构建鱼种列表视图
  Widget _buildFishListView(FishGuideState fishGuideState) {
    if (fishGuideState.speciesList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.water_outlined,
              size: 64,
              color: AppColors.grey500,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无鱼种数据',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fishGuideState.speciesList.length,
      itemBuilder: (context, index) {
        final speciesWithStats = fishGuideState.speciesList[index];
        final species = speciesWithStats.species;
        final stats = speciesWithStats.stats;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: stats.isUnlocked
                    ? AppColors.accentLight.withOpacity(0.1)
                    : AppColors.grey200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                stats.isUnlocked ? Icons.check_circle : Icons.lock_outline,
                color: stats.isUnlocked
                    ? AppColors.accentLight
                    : AppColors.grey500,
              ),
            ),
            title: Text(
              species.standardName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: stats.isUnlocked
                    ? AppColors.textPrimaryLight
                    : AppColors.textSecondaryLight,
              ),
            ),
            subtitle: Text(
              '${stats.totalCount} 次捕获 · ${species.category.label}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: speciesWithStats.stats.isUnlocked
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '已解锁',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
            onTap: () {
              showFishDetailBottomSheet(
                context,
                species: species,
                stats: stats,
              );
            },
          ),
        );
      },
    );
  }

  /// 构建成就内容（显示成就统计概览和成就列表）
  Widget _buildAchievementsContent(
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            unlockedCount, totalCount, progress, strings),
        // 成就列表
        Expanded(
          child: _buildAchievementListView(achievements, strings),
        ),
      ],
    );
  }

  /// 构建成就统计概览卡片（原始设计）
  Widget _buildAchievementStatsOverview(
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
                    backgroundColor: AppColors.surfaceLight.withOpacity(0.2),
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
                        '已解锁',
                        '$unlockedCount',
                        Icons.emoji_events,
                        AppColors.gold,
                      ),
                      const SizedBox(width: 20),
                      _buildAchievementStatItem(
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
                    backgroundColor: AppColors.surfaceLight.withOpacity(0.2),
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
