import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/language_provider.dart';

class EquipmentTypeTabs extends ConsumerWidget {
  final String selectedType;
  final int rodCount;
  final int reelCount;
  final int lureCount;
  final ValueChanged<String> onTypeChanged;

  const EquipmentTypeTabs({
    super.key,
    required this.selectedType,
    required this.rodCount,
    required this.reelCount,
    required this.lureCount,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          _TypeButton(
            label: '${strings.rod} $rodCount',
            isSelected: selectedType == 'rod',
            onTap: () => onTypeChanged('rod'),
          ),
          const SizedBox(width: 8),
          _TypeButton(
            label: '${strings.reel} $reelCount',
            isSelected: selectedType == 'reel',
            onTap: () => onTypeChanged('reel'),
          ),
          const SizedBox(width: 8),
          _TypeButton(
            label: '${strings.lure} $lureCount',
            isSelected: selectedType == 'lure',
            onTap: () => onTypeChanged('lure'),
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
