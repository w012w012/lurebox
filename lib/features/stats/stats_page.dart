import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/stats_provider.dart';
import 'stats_detail_page.dart';

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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 今日渔获卡片
              _buildStatCard(context, ref, strings.todayCatch, todayStats, () {
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
              }),
              const SizedBox(height: 12),

              // 本月渔获卡片
              _buildStatCard(context, ref, strings.monthCatch, monthStats, () {
                final now = DateTime.now();
                _navigateToDetail(
                  context,
                  strings.monthCatch,
                  startOfDay: DateTime(now.year, now.month, 1),
                  endOfDay: DateTime(now.year, now.month + 1, 1),
                );
              }),
              const SizedBox(height: 12),

              // 本年渔获卡片
              _buildStatCard(context, ref, strings.yearCatch, yearStats, () {
                final now = DateTime.now();
                _navigateToDetail(
                  context,
                  strings.yearCatch,
                  startOfDay: DateTime(now.year, 1, 1),
                  endOfDay: DateTime(now.year + 1, 1, 1),
                );
              }),
              const SizedBox(height: 12),

              // 全部渔获卡片
              _buildStatCard(context, ref, strings.allCatch, allTimeStats, () {
                final now = DateTime.now();
                _navigateToDetail(
                  context,
                  strings.allCatch,
                  startOfDay: DateTime(2000, 1, 1),
                  endOfDay: DateTime(now.year + 1, 1, 1),
                );
              }),
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
      loading: () => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(Icons.error_outline, color: AppColors.error),
            ],
          ),
        ),
      ),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatsDetailPage(
          title: title,
          startDate: startOfDay,
          endDate: endOfDay,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final releaseRate =
        count > 0 ? (release / count * 100).toStringAsFixed(0) : '0';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.set_meal,
                    count: count,
                    label: strings.total,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  _StatItem(
                    icon: Icons.water_drop,
                    count: release,
                    label: strings.release,
                    color: AppColors.release,
                  ),
                  _StatItem(
                    icon: Icons.restaurant,
                    count: keep,
                    label: strings.keep,
                    color: AppColors.keep,
                  ),
                  _StatItem(
                    icon: Icons.percent,
                    count: int.parse(releaseRate),
                    label: strings.releaseRate,
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
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
