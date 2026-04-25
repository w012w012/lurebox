import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/design/theme/animation_constants.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/app_theme.dart';
import 'package:lurebox/core/providers/language_provider.dart';

class EquipmentTypeTabs extends ConsumerWidget {

  const EquipmentTypeTabs({
    required this.selectedType, required this.rodCount, required this.reelCount, required this.lureCount, required this.onTypeChanged, super.key,
  });
  final String selectedType;
  final int rodCount;
  final int reelCount;
  final int lureCount;
  final ValueChanged<String> onTypeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingLg,
        AppTheme.spacingLg,
        AppTheme.spacingLg,
        AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          _TypeButton(
            label: '${strings.rod} $rodCount',
            isSelected: selectedType == 'rod',
            onTap: () => onTypeChanged('rod'),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          _TypeButton(
            label: '${strings.reel} $reelCount',
            isSelected: selectedType == 'reel',
            onTap: () => onTypeChanged('reel'),
          ),
          const SizedBox(width: AppTheme.spacingSm),
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

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AnimationConstants.touchFeedbackDuration,
          curve: AnimationConstants.defaultCurve,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor
                : (isDark ? AppColors.surfaceDark : AppColors.grey100),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight),
            ),
          ),
        ),
      ),
    );
  }
}
