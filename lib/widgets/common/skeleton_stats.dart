import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonStats extends StatelessWidget {
  const SkeletonStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 8),
            Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.outline,
              highlightColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              child: Container(
                width: 80,
                height: 28,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.outline,
              highlightColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              child: Container(
                width: 100,
                height: 14,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
