import 'package:flutter/material.dart';
import '../../core/design/theme/app_theme.dart';
import '../../core/design/theme/app_colors.dart';

/// 高级极简按钮组件
/// 提供多种样式的按钮，符合Premium Minimalist设计系统
class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final PremiumButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsets? padding;
  final double? borderRadius;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = PremiumButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorderRadius = borderRadius ?? AppTheme.radiusMd;

    Widget button;

    switch (variant) {
      case PremiumButtonVariant.primary:
        button = _buildPrimaryButton(context, isDark, effectiveBorderRadius);
        break;
      case PremiumButtonVariant.secondary:
        button = _buildSecondaryButton(context, isDark, effectiveBorderRadius);
        break;
      case PremiumButtonVariant.outline:
        button = _buildOutlineButton(context, isDark, effectiveBorderRadius);
        break;
      case PremiumButtonVariant.text:
        button = _buildTextButton(context, isDark, effectiveBorderRadius);
        break;
      case PremiumButtonVariant.danger:
        button = _buildDangerButton(context, isDark, effectiveBorderRadius);
        break;
      case PremiumButtonVariant.success:
        button = _buildSuccessButton(context, isDark, effectiveBorderRadius);
        break;
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildPrimaryButton(
    BuildContext context,
    bool isDark,
    double borderRadius,
  ) {
    return Semantics(
      button: true,
      label: text,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDark ? AppColors.primaryDark : AppColors.primaryLight,
          foregroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          elevation: 0,
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXl,
                vertical: AppTheme.spacingMd,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        child: _buildButtonChild(),
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context,
    bool isDark,
    double borderRadius,
  ) {
    return Semantics(
      button: true,
      label: text,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark
              ? AppColors.accentDark.withOpacity(0.12)
              : AppColors.accentLight.withOpacity(0.12),
          foregroundColor:
              isDark ? AppColors.accentDark : AppColors.accentLight,
          elevation: 0,
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXl,
                vertical: AppTheme.spacingMd,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        child: _buildButtonChild(),
      ),
    );
  }

  Widget _buildOutlineButton(
    BuildContext context,
    bool isDark,
    double borderRadius,
  ) {
    return Semantics(
      button: true,
      label: text,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor:
              isDark ? AppColors.primaryDark : AppColors.primaryLight,
          elevation: 0,
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXl,
                vertical: AppTheme.spacingMd,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        child: _buildButtonChild(),
      ),
    );
  }

  Widget _buildTextButton(
    BuildContext context,
    bool isDark,
    double borderRadius,
  ) {
    return Semantics(
      button: true,
      label: text,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor:
              isDark ? AppColors.primaryDark : AppColors.primaryLight,
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
                vertical: AppTheme.spacingSm,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        child: _buildButtonChild(),
      ),
    );
  }

  Widget _buildDangerButton(
    BuildContext context,
    bool isDark,
    double borderRadius,
  ) {
    return Semantics(
      button: true,
      label: text,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXl,
                vertical: AppTheme.spacingMd,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        child: _buildButtonChild(),
      ),
    );
  }

  Widget _buildSuccessButton(
    BuildContext context,
    bool isDark,
    double borderRadius,
  ) {
    return Semantics(
      button: true,
      label: text,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXl,
                vertical: AppTheme.spacingMd,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        child: _buildButtonChild(),
      ),
    );
  }

  Widget _buildButtonChild() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: AppTheme.spacingSm),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}

/// 按钮变体
enum PremiumButtonVariant {
  primary, // 主要按钮 - 实心填充
  secondary, // 次要按钮 - 浅色填充
  outline, // 描边按钮
  text, // 文字按钮
  danger, // 危险按钮 - 红色
  success, // 成功按钮 - 绿色
}

/// 图标按钮
class PremiumIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final String? accessibilityLabel;
  final PremiumButtonVariant variant;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const PremiumIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.accessibilityLabel,
    this.variant = PremiumButtonVariant.text,
    this.size = 40,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        color ?? (isDark ? AppColors.primaryDark : AppColors.primaryLight);

    Widget button;

    switch (variant) {
      case PremiumButtonVariant.primary:
        button = Semantics(
          button: true,
          label: accessibilityLabel ?? tooltip ?? '图标按钮',
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ??
                  (isDark ? AppColors.primaryDark : AppColors.primaryLight),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(
                icon,
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              ),
              iconSize: size * 0.5,
              padding: EdgeInsets.zero,
            ),
          ),
        );
        break;
      case PremiumButtonVariant.secondary:
        button = Semantics(
          button: true,
          label: accessibilityLabel ?? tooltip ?? '图标按钮',
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ??
                  (isDark
                      ? AppColors.accentDark.withOpacity(0.12)
                      : AppColors.accentLight.withOpacity(0.12)),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(
                icon,
                color: isDark ? AppColors.accentDark : AppColors.accentLight,
              ),
              iconSize: size * 0.5,
              padding: EdgeInsets.zero,
            ),
          ),
        );
        break;
      case PremiumButtonVariant.outline:
        button = Semantics(
          button: true,
          label: accessibilityLabel ?? tooltip ?? '图标按钮',
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(icon, color: iconColor),
              iconSize: size * 0.5,
              padding: EdgeInsets.zero,
            ),
          ),
        );
        break;
      case PremiumButtonVariant.text:
        button = Semantics(
          button: true,
          label: accessibilityLabel ?? tooltip ?? '图标按钮',
          child: SizedBox(
            width: size,
            height: size,
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(icon, color: iconColor),
              iconSize: size * 0.5,
              padding: EdgeInsets.zero,
            ),
          ),
        );
        break;
      case PremiumButtonVariant.danger:
        button = Semantics(
          button: true,
          label: accessibilityLabel ?? tooltip ?? '图标按钮',
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.error,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(icon, color: Colors.white),
              iconSize: size * 0.5,
              padding: EdgeInsets.zero,
            ),
          ),
        );
        break;
      case PremiumButtonVariant.success:
        button = Semantics(
          button: true,
          label: accessibilityLabel ?? tooltip ?? '图标按钮',
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.success,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(icon, color: Colors.white),
              iconSize: size * 0.5,
              padding: EdgeInsets.zero,
            ),
          ),
        );
        break;
    }

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}

/// 浮动操作按钮
class PremiumFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool mini;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const PremiumFAB({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.mini = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: tooltip ?? '浮动操作按钮',
      child: FloatingActionButton(
        onPressed: onPressed,
        tooltip: tooltip,
        mini: mini,
        backgroundColor: backgroundColor ??
            (isDark ? AppColors.primaryDark : AppColors.primaryLight),
        foregroundColor: foregroundColor ??
            (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            mini ? AppTheme.radiusMd : AppTheme.radiusLg,
          ),
        ),
        child: Icon(icon, size: mini ? 20 : 24),
      ),
    );
  }
}
