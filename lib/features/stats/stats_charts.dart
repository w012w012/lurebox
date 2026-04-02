import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/design/theme/app_colors.dart';
import '../../core/providers/language_provider.dart';

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
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
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
      color.withOpacity(0.7),
      color.withOpacity(0.5),
      color.withOpacity(0.3),
      AppColors.grey700,
      AppColors.teal,
      AppColors.indigo,
      AppColors.brown,
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.entries.toList().asMap().entries.map((e) {
                      final index = e.key;
                      final entry = e.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
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
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.value}',
                              style: const TextStyle(
                                fontSize: 12,
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
    AppColors.grey700,
    AppColors.teal,
    AppColors.cyan,
    AppColors.indigo,
    AppColors.blue,
    AppColors.purple,
    AppColors.pink,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);
    if (speciesStats.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.speciesDistribution,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            ...speciesStats.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(e.key, style: const TextStyle(fontSize: 14)),
                    ),
                    Text(
                      '${e.value}${strings.fishCountUnit}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  trendTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (showDropdown &&
                    trendType != null &&
                    onTrendTypeChanged != null)
                  DropdownButton<String>(
                    value: trendType,
                    items: [
                      DropdownMenuItem(
                        value: 'day',
                        child: Text(
                          strings.byDay,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'month',
                        child: Text(
                          strings.byMonth,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'year',
                        child: Text(
                          strings.byYear,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                    onChanged: (v) => onTrendTypeChanged!(v!),
                    underline: const SizedBox(),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (trendData.values.isEmpty ||
                          trendData.values.every((v) => v == 0))
                      ? 10
                      : (trendData.values.reduce((a, b) => a > b ? a : b) *
                                  1.3 +
                              1)
                          .toDouble(),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Theme.of(
                        context,
                      ).colorScheme.inverseSurface,
                      tooltipRoundedRadius: 6,
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final keys = trendData.keys.toList();
                        final label = keys[group.x.toInt()];
                        final value = rod.toY.toInt();
                        return BarTooltipItem(
                          '$label\n$value ${strings.fishCountUnit}',
                          const TextStyle(
                            color: Colors.white,
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
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  keys[value.toInt()],
                                  style: TextStyle(
                                    fontSize: 9,
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
                              ? Theme.of(context).colorScheme.primary
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
      ),
    );
  }
}
