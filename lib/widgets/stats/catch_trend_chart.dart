import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/design/theme/app_colors.dart';
import '../../../core/providers/language_provider.dart';

class CatchTrendChart extends ConsumerWidget {
  final Map<String, int> trendData;
  final String trendTitle;
  final bool showDropdown;
  final String? trendType;
  final ValueChanged<String>? onTrendTypeChanged;

  const CatchTrendChart({
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
                              ? AppColors.grey700
                              : AppColors.grey300,
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
