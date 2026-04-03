import 'package:flutter/material.dart';

import '../../core/design/theme/app_colors.dart';

/// 可复用的排序按钮组件
class AppSortButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isAsc;
  final VoidCallback onTap;

  const AppSortButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.isAsc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      hint: isSelected ? (isAsc ? '升序' : '降序') : null,
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
