import 'package:flutter/material.dart';

import '../../../core/constants/strings.dart';
import '../../../core/design/theme/app_colors.dart';
import '../../../core/models/fish_catch.dart';
import '../../../core/camera/camera_state.dart';
import '../../../core/camera/camera_view_model.dart';

/// A reusable fate selection button component.
class FateButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const FateButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      checked: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Theme.of(context).colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? color
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ),
    );
  }
}

/// Fate selector card displaying release/keep options.
class FateSelectorCard extends StatelessWidget {
  final CameraState state;
  final CameraViewModel vm;
  final AppStrings strings;

  const FateSelectorCard({
    super.key,
    required this.state,
    required this.vm,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.fate, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FateButton(
                label: '🐟 ${strings.release}',
                isSelected: state.fate == FishFateType.release,
                color: AppColors.success,
                onTap: () => vm.setFate(FishFateType.release),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FateButton(
                label: '🍳 ${strings.keep}',
                isSelected: state.fate == FishFateType.keep,
                color: AppColors.warning,
                onTap: () => vm.setFate(FishFateType.keep),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
