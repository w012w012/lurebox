import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/language_provider.dart';

class EquipmentFilterBar extends ConsumerWidget {
  final bool allExpanded;
  final VoidCallback onToggleExpand;

  const EquipmentFilterBar({
    super.key,
    required this.allExpanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: onToggleExpand,
            icon: Icon(
              allExpanded ? Icons.unfold_less : Icons.unfold_more,
              size: 18,
            ),
            label: Text(
              allExpanded ? strings.collapseAll : strings.expandAll,
              style: const TextStyle(fontSize: 13),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
