import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.outline,
              highlightColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.outline,
                    highlightColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.outline,
                    highlightColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Container(
                      width: 80,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.outline,
                    highlightColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.outline,
                  highlightColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  child: Container(
                    width: 40,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.outline,
                  highlightColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  child: Container(
                    width: 50,
                    height: 11,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
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
