import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/utils/unit_converter.dart';
import 'package:lurebox/widgets/common/premium_card.dart';

class StatsSummaryCard extends ConsumerStatefulWidget {

  const StatsSummaryCard({
    required this.totalCount, required this.speciesSummary, required this.rodDistribution, required this.reelDistribution, required this.lureDistribution, required this.weightUnit, super.key,
  });
  final int totalCount;
  final List<Map<String, dynamic>> speciesSummary;
  final Map<String, int> rodDistribution;
  final Map<String, int> reelDistribution;
  final Map<String, int> lureDistribution;
  final String weightUnit;

  @override
  ConsumerState<StatsSummaryCard> createState() => _StatsSummaryCardState();
}

class _StatsSummaryCardState extends ConsumerState<StatsSummaryCard>
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
    final isChinese = ref.watch(
        appSettingsProvider.select((s) => s.language == AppLanguage.chinese),);
    if (widget.speciesSummary.isEmpty) return const SizedBox();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  strings.fishDetail,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const Spacer(),
                Text(
                  '${strings.total} ${widget.totalCount} ${strings.fishCountUnit}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: TeslaTheme.spacingMicro),
            Container(
              padding: const EdgeInsets.symmetric(vertical: TeslaTheme.spacingSm),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      strings.species,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                  const SizedBox(width: TeslaTheme.spacingSm),
                  Expanded(
                    child: Text(
                      strings.quantity,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      strings.totalWeight,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            ...widget.speciesSummary.map(
              (item) => Container(
                padding:
                    const EdgeInsets.symmetric(vertical: TeslaTheme.spacingMicro),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        item['species'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    const SizedBox(width: TeslaTheme.spacingSm),
                    Expanded(
                      child: Text(
                        '${item['count']}${strings.fishCountUnit}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        (item['totalWeight'] as double) > 0
                            ? '${(item['totalWeight'] as double).toStringAsFixed(2)} ${UnitConverter.getWeightSymbol(widget.weightUnit, isChinese: isChinese)}'
                            : '-',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
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

class EquipmentChart extends StatefulWidget {

  const EquipmentChart({
    required this.title, required this.data, required this.color, super.key,
    this.strings,
  });
  final String title;
  final Map<String, int> data;
  final Color color;
  final AppStrings? strings;

  @override
  State<EquipmentChart> createState() => _EquipmentChartState();
}

class _EquipmentChartState extends State<EquipmentChart>
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
    final total = widget.data.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox();

    final colors = [
      widget.color,
      widget.color.withValues(alpha: 0.7),
      widget.color.withValues(alpha: 0.5),
      widget.color.withValues(alpha: 0.3),
      TeslaColors.pewter,
      TeslaColors.electricBlue,
      Colors.indigo,
      Colors.brown,
    ];

    // Sort by count descending
    final sortedEntries = widget.data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return FadeTransition(
      opacity: _fadeAnimation,
      child: PremiumCard(
        margin: const EdgeInsets.only(bottom: TeslaTheme.spacingMicro),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: TeslaTheme.spacingMicro),
            ...sortedEntries.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final pct = (item.value / total * 100).toStringAsFixed(0);
              return Padding(
                padding: const EdgeInsets.only(bottom: TeslaTheme.spacingMicro),
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
                    const SizedBox(width: TeslaTheme.spacingMicro),
                    Expanded(
                      child: Text(
                        item.key,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: TeslaTheme.spacingMicro),
                    Text(
                      '$pct%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(width: TeslaTheme.spacingMicro),
                    Text(
                      '${item.value}${widget.strings?.countSuffix ?? '条'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
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
