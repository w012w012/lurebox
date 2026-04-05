import 'package:flutter/material.dart';
import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/app_theme.dart';

/// Alias selector widget for selecting a user's preferred name for a fish species.
///
/// Shows a dropdown with radio button selection for aliases.
class AliasSelector extends StatefulWidget {
  /// Current selected alias
  final String currentAlias;

  /// Available aliases for the fish species
  final List<String> aliases;

  /// Callback when alias is changed
  final ValueChanged<String>? onAliasChanged;

  const AliasSelector({
    super.key,
    required this.currentAlias,
    required this.aliases,
    this.onAliasChanged,
  });

  @override
  State<AliasSelector> createState() => _AliasSelectorState();
}

class _AliasSelectorState extends State<AliasSelector> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current alias display
        _buildCurrentAliasButton(isDark),
        // Expanded alias list
        if (_isExpanded) _buildExpandedList(isDark),
      ],
    );
  }

  Widget _buildCurrentAliasButton(bool isDark) {
    final backgroundColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLg,
          vertical: AppTheme.spacingMd,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '你的叫法',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    widget.currentAlias,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedList(bool isDark) {
    final backgroundColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(top: AppTheme.spacingSm),
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg,
              vertical: AppTheme.spacingSm,
            ),
            child: Text(
              '选择你在使用的名称',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
            ),
          ),
          const Divider(height: 1),
          ...widget.aliases.map((alias) => _buildAliasOption(alias, isDark)),
        ],
      ),
    );
  }

  Widget _buildAliasOption(String alias, bool isDark) {
    final isSelected = alias == widget.currentAlias;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return InkWell(
      onTap: () {
        widget.onAliasChanged?.call(alias);
        setState(() => _isExpanded = false);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLg,
          vertical: AppTheme.spacingMd,
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? accentColor : AppColors.grey500,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppTheme.spacingMd),
            // Alias text
            Expanded(
              child: Text(
                alias,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: textColor,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ),
            // Selected indicator
            if (isSelected)
              Icon(
                Icons.check_rounded,
                color: accentColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
