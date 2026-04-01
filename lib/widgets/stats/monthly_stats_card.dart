import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/theme/app_colors.dart';
import '../../../core/providers/language_provider.dart';

class MonthlyStatsCard extends ConsumerWidget {
  final int releaseCount;
  final int keepCount;
  final double releaseRate;
  final String title;
  final int totalCount;

  const MonthlyStatsCard({
    super.key,
    required this.releaseCount,
    required this.keepCount,
    required this.releaseRate,
    required this.title,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              '$totalCount',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              '$totalCount${strings.fishCountUnit}',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  label: strings.release,
                  count: releaseCount,
                  color: AppColors.release,
                ),
                _StatItem(
                  label: strings.keep,
                  count: keepCount,
                  color: AppColors.keep,
                ),
                _StatItem(
                  label: strings.releaseRate,
                  count: releaseRate.round(),
                  color: AppColors.teal,
                  isPercent: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isPercent;

  const _StatItem({
    required this.label,
    required this.count,
    required this.color,
    this.isPercent = false,
  });

  @override
  Widget build(BuildContext context) {
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
