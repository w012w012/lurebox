import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/app_theme.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/providers/stats_provider.dart';
import 'package:lurebox/widgets/common/premium_card.dart';
import 'package:lurebox/widgets/common/staggered_reveal.dart';

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
            horizontal: TeslaTheme.spacingMd,
            vertical: TeslaTheme.spacingMicro,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 今日渔获卡片
              StaggeredReveal(
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
              const SizedBox(height: TeslaTheme.spacingMd),

              // 本月渔获卡片
              StaggeredReveal(
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
                      startOfDay: DateTime(now.year, now.month),
                      endOfDay: DateTime(now.year, now.month + 1),
                    );
                  },
                ),
              ),
              const SizedBox(height: TeslaTheme.spacingMd),

              // 本年渔获卡片
              StaggeredReveal(
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
                      startOfDay: DateTime(now.year),
                      endOfDay: DateTime(now.year + 1),
                    );
                  },
                ),
              ),
              const SizedBox(height: TeslaTheme.spacingMd),

              // 全部渔获卡片
              StaggeredReveal(
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
                      startOfDay: DateTime(2000),
                      endOfDay: DateTime(now.year + 1),
                    );
                  },
                ),
              ),
              const SizedBox(height: TeslaTheme.spacingLg),
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


/// Loading state for stat card
class _StatCardLoading extends StatelessWidget {

  const _StatCardLoading({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const Spacer(),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: TeslaColors.electricBlue,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state for stat card
class _StatCardError extends StatelessWidget {

  const _StatCardError({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const Spacer(),
          const Icon(Icons.error_outline, color: TeslaColors.electricBlue),
        ],
      ),
    );
  }
}

class _StatCard extends StatefulWidget {

  const _StatCard({
    required this.title,
    required this.count,
    required this.release,
    required this.keep,
    required this.onTap, required this.strings, this.species,
  });
  final String title;
  final int count;
  final int release;
  final int keep;
  final Map<String, int>? species;
  final VoidCallback onTap;
  final AppStrings strings;

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final releaseRate = widget.count > 0
        ? (widget.release / widget.count * 100).toStringAsFixed(0)
        : '0';
    const accentColor = TeslaColors.electricBlue;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: TeslaTheme.transitionDuration,
        curve: TeslaTheme.transitionCurve,
        child: PremiumCard(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: TeslaColors.carbonDark,
                        ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    color: accentColor,
                  ),
                ],
              ),
              const SizedBox(height: TeslaTheme.spacingLg),
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
                    color: TeslaColors.electricBlue,
                  ),
                  _StatItem(
                    icon: Icons.restaurant,
                    count: widget.keep,
                    label: widget.strings.keep,
                    color: TeslaColors.electricBlue,
                  ),
                  _StatItem(
                    icon: Icons.percent,
                    count: int.parse(releaseRate),
                    label: widget.strings.releaseRate,
                    color: TeslaColors.electricBlue,
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

  const _StatItem({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingSm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: TeslaTheme.spacingSm),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
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
