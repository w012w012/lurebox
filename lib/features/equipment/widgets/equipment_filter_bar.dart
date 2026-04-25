import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/providers/language_provider.dart';

class EquipmentFilterBar extends ConsumerWidget {

  const EquipmentFilterBar({
    required this.allExpanded, required this.onToggleExpand, super.key,
  });
  final bool allExpanded;
  final VoidCallback onToggleExpand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? TeslaColors.electricBlue : TeslaColors.electricBlue;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TeslaTheme.spacingMd,
        vertical: TeslaTheme.spacingMicro,
      ),
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
              foregroundColor: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
