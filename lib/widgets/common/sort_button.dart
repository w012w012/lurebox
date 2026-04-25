import 'package:flutter/material.dart';

import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';

/// 可复用的排序按钮组件
class AppSortButton extends StatelessWidget {

  const AppSortButton({
    required this.label, required this.isSelected, required this.isAsc, required this.onTap, super.key,
    this.strings,
  });
  final String label;
  final bool isSelected;
  final bool isAsc;
  final VoidCallback onTap;
  final AppStrings? strings;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      hint: isSelected
          ? (isAsc
              ? (strings?.ascending ?? 'Ascending')
              : (strings?.descending ?? 'Descending'))
          : null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.teal
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.teal
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Icon(
                  isAsc ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
