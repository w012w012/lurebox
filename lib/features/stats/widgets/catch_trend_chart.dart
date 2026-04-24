import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/tesla_theme.dart';
import '../../../core/providers/language_provider.dart';
import '../../../widgets/common/premium_card.dart';

class CatchTrendChart extends ConsumerStatefulWidget {
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
  ConsumerState<CatchTrendChart> createState() => _CatchTrendChartState();
}

class _CatchTrendChartState extends ConsumerState<CatchTrendChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: TeslaTheme.transitionDuration,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: TeslaTheme.transitionCurve,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(currentStringsProvider);
    if (widget.trendData.isEmpty) return const SizedBox();

    const accentColor = TeslaColors.electricBlue;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: PremiumCard(
        variant: PremiumCardVariant.standard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.trendTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                if (widget.showDropdown &&
                    widget.trendType != null &&
                    widget.onTrendTypeChanged != null)
                  Container(
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
                    ),
                    child: DropdownButton<String>(
                      value: widget.trendType,
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
                      onChanged: (v) => widget.onTrendTypeChanged!(v!),
                      underline: const SizedBox(),
                      isDense: true,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: TeslaTheme.spacingMicro),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (widget.trendData.values.isEmpty ||
                          widget.trendData.values.every((v) => v == 0))
                      ? 10
                      : (widget.trendData.values
                                      .reduce((a, b) => a > b ? a : b) *
                                  1.3 +
                              1)
                          .toDouble(),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (touchedGroup) => Theme.of(
                        context,
                      ).colorScheme.inverseSurface,
                      tooltipRoundedRadius: TeslaTheme.radiusMicro,
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: TeslaTheme.spacingSm,
                        vertical: TeslaTheme.spacingMicro,
                      ),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final keys = widget.trendData.keys.toList();
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
                          final keys = widget.trendData.keys.toList();
                          if (value.toInt() < keys.length) {
                            final step = (keys.length / 6).ceil();
                            if (value.toInt() % step == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    top: TeslaTheme.spacingMicro),
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
                  barGroups:
                      widget.trendData.entries.toList().asMap().entries.map((
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
                          width: widget.trendData.length > 15 ? 6 : 14,
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
