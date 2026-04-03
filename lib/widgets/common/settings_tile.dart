import 'package:flutter/material.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/design/theme/app_theme.dart';
import '../../core/design/theme/animation_constants.dart';
import 'premium_card.dart';

/// iOS-style Settings Tile widget.
/// Provides consistent iOS settings app appearance with blue accent colors,
/// touch feedback animations, and proper dark mode support.
class SettingsTile extends StatefulWidget {
  /// Icon displayed on the left side of the tile.
  final IconData icon;

  /// Primary title text.
  final String title;

  /// Optional subtitle text displayed below the title.
  final String? subtitle;

  /// Optional trailing widget (switch, dropdown, chevron, etc.)
  final Widget? trailing;

  /// Callback when tile is tapped.
  final VoidCallback? onTap;

  /// Whether to show chevron icon on the right.
  /// Automatically set to true if onTap is provided and no trailing widget.
  final bool showChevron;

  /// Card variant for the underlying PremiumCard.
  final PremiumCardVariant variant;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = false,
    this.variant = PremiumCardVariant.flat,
  });

  @override
  State<SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<SettingsTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    // Determine if chevron should be shown
    final shouldShowChevron =
        widget.showChevron || (widget.trailing == null && widget.onTap != null);

    Widget tileContent = Row(
      children: [
        // Icon container with blue accent
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingSm),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(
            widget.icon,
            color: accentColor,
            size: 22,
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),

        // Title and subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  widget.subtitle!,
                  style: TextStyle(
                    fontSize: 13,
                    color: subtitleColor,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Trailing widget or chevron
        if (widget.trailing != null) ...[
          const SizedBox(width: AppTheme.spacingSm),
          widget.trailing!,
        ] else if (shouldShowChevron) ...[
          Icon(
            Icons.chevron_right,
            color: subtitleColor,
            size: 24,
          ),
        ],
      ],
    );

    // Wrap with animated scale for touch feedback
    tileContent = AnimatedScale(
      scale: _isPressed ? AnimationConstants.touchScale : 1.0,
      duration: AnimationConstants.touchFeedbackDuration,
      curve: AnimationConstants.defaultCurve,
      child: tileContent,
    );

    // Wrap with PremiumCard
    tileContent = PremiumCard(
      variant: widget.variant,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLg,
        vertical: AppTheme.spacingMd,
      ),
      onTap: widget.onTap,
      showBorder: true,
      child: tileContent,
    );

    // Add InkWell for touch feedback if using custom onTap
    if (widget.onTap != null) {
      tileContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          splashColor: accentColor.withOpacity(0.1),
          highlightColor: accentColor.withOpacity(0.05),
          child: tileContent,
        ),
      );
    }

    return tileContent;
  }
}

/// A settings section header with optional action.
class SettingsSectionHeader extends StatelessWidget {
  /// The header title text.
  final String title;

  /// Optional action widget displayed on the right.
  final Widget? action;

  const SettingsSectionHeader({
    super.key,
    required this.title,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppTheme.spacingLg,
        right: AppTheme.spacingLg,
        top: AppTheme.spacingLg,
        bottom: AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
          if (action != null) ...[
            const Spacer(),
            action!,
          ],
        ],
      ),
    );
  }
}

/// A simple divider for separating settings groups.
class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Divider(
      height: 1,
      thickness: 1,
      color: dividerColor,
      indent: AppTheme.spacingLg + 22 + AppTheme.spacingMd, // Icon area width
    );
  }
}
