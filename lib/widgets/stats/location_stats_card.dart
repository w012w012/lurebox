import 'package:flutter/material.dart';

class LocationStatsCard extends StatelessWidget {
  final Map<String, Map<String, int>> locationAnalysis;
  final bool showDetails;
  final VoidCallback? onToggleDetails;

  const LocationStatsCard({
    super.key,
    required this.locationAnalysis,
    this.showDetails = true,
    this.onToggleDetails,
  });

  String _blurLocation(String location) {
    if (location.length <= 4) {
      return '*' * location.length;
    }
    final visiblePart = location.substring(0, 6);
    final blurredPart = '*' * (location.length - 6);
    return visiblePart + blurredPart;
  }

  @override
  Widget build(BuildContext context) {
    if (locationAnalysis.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '钓点分析',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(
                    showDetails ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: onToggleDetails,
                  tooltip: showDetails ? '隐藏钓点' : '显示钓点',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...locationAnalysis.entries.map((locationEntry) {
              final location = locationEntry.key;
              final speciesMap = locationEntry.value;
              final total = speciesMap.values.fold(0, (a, b) => a + b);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            showDetails ? location : _blurLocation(location),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        Text(
                          '合计 $total 条',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: speciesMap.entries.map((speciesEntry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${speciesEntry.key}: ${speciesEntry.value}条',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
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
