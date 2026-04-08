import 'package:flutter/material.dart';

import '../../../core/constants/strings.dart';
import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/app_theme.dart';
import '../../../core/design/theme/animation_constants.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../widgets/common/premium_card.dart';

class SpeciesDistributionChart extends StatefulWidget {
  final Map<String, int> speciesStats;
  final Map<String, double>? speciesWeightStats;
  final int totalCount;
  final double totalWeight;
  final bool showByWeight;
  final VoidCallback? onToggleShowByWeight;
  final AppStrings? strings;
  final String weightUnit;

  const SpeciesDistributionChart({
    super.key,
    required this.speciesStats,
    this.speciesWeightStats,
    required this.totalCount,
    this.totalWeight = 0,
    this.showByWeight = false,
    this.onToggleShowByWeight,
    this.strings,
    this.weightUnit = 'kg',
  });

  @override
  State<SpeciesDistributionChart> createState() =>
      _SpeciesDistributionChartState();
}

class _SpeciesDistributionChartState extends State<SpeciesDistributionChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

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
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AnimationConstants.pageTransitionDuration,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AnimationConstants.defaultCurve,
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
    final appStrings = widget.strings;
    if (widget.speciesStats.isEmpty) return const SizedBox();

    final unitLabel =
        widget.showByWeight ? UnitConverter.getWeightSymbol(widget.weightUnit) : (appStrings?.fishCountUnit ?? '');
    final displayTotal =
        widget.showByWeight ? widget.totalWeight : widget.totalCount;

    // Sort by count or weight descending
    final sortedEntries = widget.speciesStats.entries.toList()
      ..sort((a, b) {
        if (widget.showByWeight) {
          final weightA = widget.speciesWeightStats?[a.key] ?? 0.0;
          final weightB = widget.speciesWeightStats?[b.key] ?? 0.0;
          return weightB.compareTo(weightA);
        } else {
          return b.value.compareTo(a.value);
        }
      });

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
                  appStrings?.speciesDistribution ?? 'Species Distribution',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                if (widget.onToggleShowByWeight != null && appStrings != null)
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ToggleOption(
                          label: appStrings.quantity,
                          isSelected: !widget.showByWeight,
                          onTap: () {
                            if (widget.showByWeight) {
                              widget.onToggleShowByWeight!();
                            }
                          },
                        ),
                        _ToggleOption(
                          label: appStrings.weight,
                          isSelected: widget.showByWeight,
                          onTap: () {
                            if (!widget.showByWeight) {
                              widget.onToggleShowByWeight!();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ...sortedEntries.asMap().entries.map((entry) {
              final index = entry.key;
              final e = entry.value;
              final weightValue = widget.speciesWeightStats?[e.key] ?? 0.0;
              final value = widget.showByWeight
                  ? weightValue.toStringAsFixed(2)
                  : '${e.value}';
              final percent = widget.showByWeight
                  ? (displayTotal > 0 ? (weightValue / displayTotal) * 100 : 0)
                      .toStringAsFixed(1)
                  : (e.value / widget.totalCount * 100).toStringAsFixed(1);
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _chartColors[index % _chartColors.length],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Expanded(
                          child: Text(
                            e.key,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          '$percent%',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Text(
                          '$value $unitLabel',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: widget.showByWeight
                            ? (displayTotal > 0
                                ? weightValue / displayTotal
                                : 0)
                            : e.value / widget.totalCount,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                          _chartColors[index % _chartColors.length],
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingXs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
