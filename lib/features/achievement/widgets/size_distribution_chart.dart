import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/app_theme.dart';
import '../../../core/services/fish_species_stats_service.dart';

/// Size distribution chart widget showing bar chart of fish sizes.
///
/// Displays size buckets as animated bars growing from bottom up.
class SizeDistributionChart extends StatelessWidget {
  /// Size distribution buckets
  final List<SizeBucket> buckets;

  const SizeDistributionChart({
    super.key,
    required this.buckets,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxCount = buckets.fold<int>(
      0,
      (max, bucket) => bucket.count > max ? bucket.count : max,
    );

    if (maxCount == 0) {
      return _buildEmptyState(context, isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart title
        Text(
          '尺寸分布',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        // Bar chart
        SizedBox(
          height: 160,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxCount.toDouble() * 1.2,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor:
                      isDark ? AppColors.grey800 : AppColors.grey700,
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final bucket = buckets[group.x.toInt()];
                    return BarTooltipItem(
                      '${bucket.range}cm\n${bucket.count}条',
                      TextStyle(
                        color: AppColors.surfaceLight,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
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
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < buckets.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            buckets[index].range,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 30,
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
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: _buildBarGroups(maxCount, isDark),
            ),
            swapAnimationDuration: const Duration(milliseconds: 300),
            swapAnimationCurve: Curves.easeOutCubic,
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups(int maxCount, bool isDark) {
    return List.generate(buckets.length, (index) {
      final bucket = buckets[index];

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: bucket.count.toDouble(),
            width: 24,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.accentLight.withOpacity(0.6),
                AppColors.accentLight,
              ],
            ),
          ),
        ],
        showingTooltipIndicators: bucket.count > 0 ? [0] : [],
      );
    });
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      height: 160,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 48,
            color: AppColors.grey500,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            '暂无尺寸数据',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey500,
                ),
          ),
        ],
      ),
    );
  }
}
