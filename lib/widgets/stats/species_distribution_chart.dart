import 'package:flutter/material.dart';

import '../../../core/constants/strings.dart';
import '../../../core/design/theme/app_colors.dart';

class SpeciesDistributionChart extends StatelessWidget {
  final Map<String, int> speciesStats;
  final Map<String, double>? speciesWeightStats;
  final int totalCount;
  final double totalWeight;
  final bool showByWeight;
  final VoidCallback? onToggleShowByWeight;
  final AppStrings? strings;

  const SpeciesDistributionChart({
    super.key,
    required this.speciesStats,
    this.speciesWeightStats,
    required this.totalCount,
    this.totalWeight = 0,
    this.showByWeight = false,
    this.onToggleShowByWeight,
    this.strings,
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
  Widget build(BuildContext context) {
    final appStrings = strings;
    if (speciesStats.isEmpty) return const SizedBox();

    final unitLabel = showByWeight ? 'kg' : (appStrings?.fishCountUnit ?? '');
    final displayTotal = showByWeight ? totalWeight : totalCount;

    // 排序：按数量或重量降序排列
    final sortedEntries = speciesStats.entries.toList()
      ..sort((a, b) {
        if (showByWeight) {
          final weightA = speciesWeightStats?[a.key] ?? 0.0;
          final weightB = speciesWeightStats?[b.key] ?? 0.0;
          return weightB.compareTo(weightA);
        } else {
          return b.value.compareTo(a.value);
        }
      });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  appStrings?.speciesDistribution ?? 'Species Distribution',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (onToggleShowByWeight != null && appStrings != null)
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ToggleOption(
                          label: appStrings.quantity,
                          isSelected: !showByWeight,
                          onTap: () {
                            if (showByWeight) onToggleShowByWeight!();
                          },
                        ),
                        _ToggleOption(
                          label: appStrings.weight,
                          isSelected: showByWeight,
                          onTap: () {
                            if (!showByWeight) onToggleShowByWeight!();
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...sortedEntries.map((e) {
              final index = sortedEntries.toList().indexOf(e);
              final weightValue = speciesWeightStats?[e.key] ?? 0.0;
              final value =
                  showByWeight ? weightValue.toStringAsFixed(2) : '${e.value}';
              final percent = showByWeight
                  ? (displayTotal > 0 ? (weightValue / displayTotal) * 100 : 0)
                      .toStringAsFixed(1)
                  : (e.value / totalCount * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            e.key,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          '$percent%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$value $unitLabel',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: showByWeight
                            ? (displayTotal > 0
                                ? weightValue / displayTotal
                                : 0)
                            : e.value / totalCount,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
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
