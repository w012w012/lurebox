import 'package:flutter/material.dart';

import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/utils/unit_converter.dart';
import 'package:lurebox/widgets/common/premium_card.dart';

class SpeciesDistributionChart extends StatefulWidget {

  const SpeciesDistributionChart({
    required this.speciesStats, required this.totalCount, super.key,
    this.speciesWeightStats,
    this.totalWeight = 0,
    this.showByWeight = false,
    this.onToggleShowByWeight,
    this.strings,
    this.weightUnit = 'kg',
    this.isChinese = true,
  });
  final Map<String, int> speciesStats;
  final Map<String, double>? speciesWeightStats;
  final int totalCount;
  final double totalWeight;
  final bool showByWeight;
  final VoidCallback? onToggleShowByWeight;
  final AppStrings? strings;
  final String weightUnit;
  final bool isChinese;

  @override
  State<SpeciesDistributionChart> createState() =>
      _SpeciesDistributionChartState();
}

class _SpeciesDistributionChartState extends State<SpeciesDistributionChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  static const _chartColors = [
    TeslaColors.electricBlue,
    TeslaColors.electricBlue,
    TeslaColors.electricBlue,
    TeslaColors.electricBlue,
    TeslaColors.electricBlue,
    TeslaColors.electricBlue,
    TeslaColors.electricBlue,
  ];

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
    final appStrings = widget.strings;
    if (widget.speciesStats.isEmpty) return const SizedBox();

    final unitLabel = widget.showByWeight
        ? UnitConverter.getWeightSymbol(widget.weightUnit,
            isChinese: widget.isChinese,)
        : (appStrings?.fishCountUnit ?? '');
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  appStrings?.speciesDistribution ?? 'Species Distribution',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const Spacer(),
                if (widget.onToggleShowByWeight != null && appStrings != null)
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
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
            const SizedBox(height: TeslaTheme.spacingMicro),
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
                    const EdgeInsets.symmetric(vertical: TeslaTheme.spacingSm),
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
                        const SizedBox(width: TeslaTheme.spacingSm),
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
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(width: TeslaTheme.spacingSm),
                        Text(
                          '$value $unitLabel',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TeslaTheme.spacingMicro),
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

  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accentColor = TeslaColors.electricBlue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TeslaTheme.spacingMicro,
          vertical: TeslaTheme.spacingMicro,
        ),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
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
