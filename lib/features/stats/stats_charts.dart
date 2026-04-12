import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/design/theme/app_colors.dart';
import '../../core/design/theme/app_theme.dart';
import '../../core/providers/language_provider.dart';
import '../../widgets/common/premium_card.dart';

/// 概览项组件
class OverviewItem extends ConsumerWidget {
  final String label;
  final int count;
  final Color color;
  final bool isPercent;

  const OverviewItem({
    super.key,
    required this.label,
    required this.count,
    required this.color,
    this.isPercent = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Text(
          '$count${isPercent ? '%' : ''}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXs),
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

/// 装备饼图组件
class EquipmentPieChart extends StatelessWidget {
  final String title;
  final Map<String, int> data;
  final Color color;

  const EquipmentPieChart({
    super.key,
    required this.title,
    required this.data,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox();

    final colors = [
      color,
      color.withValues(alpha: 0.7),
      color.withValues(alpha: 0.5),
      color.withValues(alpha: 0.3),
      AppColors.grey700,
      AppColors.teal,
      AppColors.indigo,
      AppColors.brown,
    ];

    return PremiumCard(
      variant: PremiumCardVariant.standard,
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 20,
                    sections: data.entries.toList().asMap().entries.map((e) {
                      final index = e.key;
                      final entry = e.value;
                      final pct = (entry.value / total * 100).toStringAsFixed(
                        0,
                      );
                      return PieChartSectionData(
                        value: entry.value.toDouble(),
                        title: '$pct%',
                        color: colors[index % colors.length],
                        titleStyle: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        radius: 35,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.entries.toList().asMap().entries.map((e) {
                    final index = e.key;
                    final entry = e.value;
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppTheme.spacingXs),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors[index % colors.length],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingXs),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingXs),
                          Text(
                            '${entry.value}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 品种分布饼图组件
class SpeciesPieChart extends ConsumerWidget {
  final Map<String, int> speciesStats;
  final int totalCount;

  const SpeciesPieChart({
    super.key,
    required this.speciesStats,
    required this.totalCount,
  });

  static const _chartColors = [
    AppColors.accentLight,
    AppColors.teal,
    AppColors.cyan,
    AppColors.indigo,
    AppColors.primaryLight,
    AppColors.purple,
    AppColors.pink,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);
    if (speciesStats.isEmpty) return const SizedBox();

    return PremiumCard(
      variant: PremiumCardVariant.standard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.speciesDistribution,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: speciesStats.entries.toList().asMap().entries.map((
                  e,
                ) {
                  final count = e.value.value;
                  final percent = (count / totalCount * 100).toStringAsFixed(
                    1,
                  );
                  return PieChartSectionData(
                    value: count.toDouble(),
                    color: _chartColors[e.key % _chartColors.length],
                    title: '$percent%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          ...speciesStats.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.key,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '${e.value}${strings.fishCountUnit}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 趋势柱状图组件
class TrendBarChart extends ConsumerWidget {
  final Map<String, int> trendData;
  final String trendTitle;
  final bool showDropdown;
  final String? trendType;
  final ValueChanged<String>? onTrendTypeChanged;

  const TrendBarChart({
    super.key,
    required this.trendData,
    required this.trendTitle,
    this.showDropdown = false,
    this.trendType,
    this.onTrendTypeChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);
    if (trendData.isEmpty) return const SizedBox();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;

    return PremiumCard(
      variant: PremiumCardVariant.standard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                trendTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              if (showDropdown &&
                  trendType != null &&
                  onTrendTypeChanged != null)
                Container(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: DropdownButton<String>(
                    value: trendType,
                    items: [
                      DropdownMenuItem(
                        value: 'day',
                        child: Text(
                          strings.byDay,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'month',
                        child: Text(
                          strings.byMonth,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'year',
                        child: Text(
                          strings.byYear,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                    onChanged: (v) => onTrendTypeChanged!(v!),
                    underline: const SizedBox(),
                    isDense: true,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (trendData.values.isEmpty ||
                        trendData.values.every((v) => v == 0))
                    ? 10
                    : (trendData.values.reduce((a, b) => a > b ? a : b) * 1.3 +
                            1)
                        .toDouble(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (touchedGroup) => Theme.of(
                      context,
                    ).colorScheme.inverseSurface,
                    tooltipRoundedRadius: AppTheme.radiusSm,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingSm,
                      vertical: AppTheme.spacingXs,
                    ),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final keys = trendData.keys.toList();
                      final label = keys[group.x.toInt()];
                      final value = rod.toY.toInt();
                      return BarTooltipItem(
                        '$label\n$value ${strings.fishCountUnit}',
                        TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onInverseSurface,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final keys = trendData.keys.toList();
                        if (value.toInt() < keys.length) {
                          final step = (keys.length / 6).ceil();
                          if (value.toInt() % step == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  top: AppTheme.spacingXs),
                              child: Text(
                                keys[value.toInt()],
                                style: Theme.of(
                                  context,
                                ).textTheme.labelSmall?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            );
                          }
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: trendData.entries.toList().asMap().entries.map((
                  e,
                ) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.value.toDouble(),
                        color: e.value.value > 0
                            ? accentColor
                            : Theme.of(context).colorScheme.outline,
                        width: trendData.length > 15 ? 6 : 14,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
