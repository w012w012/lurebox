import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/design/theme/app_theme.dart';
import '../../core/design/theme/animation_constants.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/stats_provider.dart';
import '../../widgets/common/premium_card.dart';

/// 统计页
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);
    final todayStats = ref.watch(todayStatsProvider);
    final monthStats = ref.watch(monthStatsProvider);
    final yearStats = ref.watch(yearStatsProvider);
    final allTimeStats = ref.watch(allTimeStatsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.statistics), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayStatsProvider);
          ref.invalidate(monthStatsProvider);
          ref.invalidate(yearStatsProvider);
          ref.invalidate(allTimeStatsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLg,
            vertical: AppTheme.spacingMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 今日渔获卡片
              _AnimatedStatCard(
                index: 0,
                child: _buildStatCard(
                  context,
                  ref,
                  strings.todayCatch,
                  todayStats,
                  () {
                    final now = DateTime.now();
                    _navigateToDetail(
                      context,
                      strings.todayCatch,
                      startOfDay: DateTime(now.year, now.month, now.day),
                      endOfDay: DateTime(
                        now.year,
                        now.month,
                        now.day,
                      ).add(const Duration(days: 1)),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // 本月渔获卡片
              _AnimatedStatCard(
                index: 1,
                child: _buildStatCard(
                  context,
                  ref,
                  strings.monthCatch,
                  monthStats,
                  () {
                    final now = DateTime.now();
                    _navigateToDetail(
                      context,
                      strings.monthCatch,
                      startOfDay: DateTime(now.year, now.month, 1),
                      endOfDay: DateTime(now.year, now.month + 1, 1),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // 本年渔获卡片
              _AnimatedStatCard(
                index: 2,
                child: _buildStatCard(
                  context,
                  ref,
                  strings.yearCatch,
                  yearStats,
                  () {
                    final now = DateTime.now();
                    _navigateToDetail(
                      context,
                      strings.yearCatch,
                      startOfDay: DateTime(now.year, 1, 1),
                      endOfDay: DateTime(now.year + 1, 1, 1),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // 全部渔获卡片
              _AnimatedStatCard(
                index: 3,
                child: _buildStatCard(
                  context,
                  ref,
                  strings.allCatch,
                  allTimeStats,
                  () {
                    final now = DateTime.now();
                    _navigateToDetail(
                      context,
                      strings.allCatch,
                      startOfDay: DateTime(2000, 1, 1),
                      endOfDay: DateTime(now.year + 1, 1, 1),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spacingXl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    WidgetRef ref,
    String title,
    AsyncValue<TimeRangeStats> statsAsync,
    VoidCallback onTap,
  ) {
    final strings = ref.watch(currentStringsProvider);
    return statsAsync.when(
      loading: () => _StatCardLoading(title: title),
      error: (error, stack) => _StatCardError(title: title),
      data: (stats) => _StatCard(
        title: title,
        count: stats.totalCount,
        release: stats.releaseCount,
        keep: stats.keepCount,
        species: stats.speciesStats,
        onTap: onTap,
        strings: strings,
      ),
    );
  }

  void _navigateToDetail(
    BuildContext context,
    String title, {
    required DateTime startOfDay,
    required DateTime endOfDay,
  }) {
    context.push(
      '/stats?title=${Uri.encodeComponent(title)}&start=${startOfDay.toIso8601String()}&end=${endOfDay.toIso8601String()}',
    );
  }
}

/// Staggered animation wrapper for stat cards
class _AnimatedStatCard extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedStatCard({
    required this.index,
    required this.child,
  });

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationConstants.pageTransitionDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationConstants.defaultCurve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationConstants.defaultCurve,
    ));

    // Stagger the animation start
    Future.delayed(
      AnimationConstants.staggerDelay * widget.index,
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Loading state for stat card
class _StatCardLoading extends StatelessWidget {
  final String title;

  const _StatCardLoading({required this.title});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: null,
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accentLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state for stat card
class _StatCardError extends StatelessWidget {
  final String title;

  const _StatCardError({required this.title});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: null,
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          const Icon(Icons.error_outline, color: AppColors.error),
        ],
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  final String title;
  final int count;
  final int release;
  final int keep;
  final Map<String, int>? species;
  final VoidCallback onTap;
  final AppStrings strings;

  const _StatCard({
    required this.title,
    required this.count,
    required this.release,
    required this.keep,
    this.species,
    required this.onTap,
    required this.strings,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final releaseRate = widget.count > 0
        ? (widget.release / widget.count * 100).toStringAsFixed(0)
        : '0';
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? AnimationConstants.touchScale : 1.0,
        duration: AnimationConstants.touchFeedbackDuration,
        curve: AnimationConstants.defaultCurve,
        child: PremiumCard(
          variant: PremiumCardVariant.standard,
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: accentColor,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.set_meal,
                    count: widget.count,
                    label: widget.strings.total,
                    color: accentColor,
                  ),
                  _StatItem(
                    icon: Icons.water_drop,
                    count: widget.release,
                    label: widget.strings.release,
                    color: AppColors.release,
                  ),
                  _StatItem(
                    icon: Icons.restaurant,
                    count: widget.keep,
                    label: widget.strings.keep,
                    color: AppColors.keep,
                  ),
                  _StatItem(
                    icon: Icons.percent,
                    count: int.parse(releaseRate),
                    label: widget.strings.releaseRate,
                    color: AppColors.teal,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingSm),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
