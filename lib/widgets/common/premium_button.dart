import 'package:flutter/material.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/design/theme/animation_constants.dart';
import '../../core/design/theme/tesla_theme.dart';

/// 高级极简按钮组件
/// 提供多种样式的按钮，符合Premium Minimalist设计系统
class PremiumButton extends StatefulWidget {
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
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _ButtonColors {
  const _ButtonColors({
    required this.background,
    required this.foreground,
    this.borderColor,
  });

  final Color background;
  final Color foreground;
  final Color? borderColor;
}

class _PremiumButtonState extends State<PremiumButton> {
  bool _isPressed = false;

  static const _textStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const _defaultPadding = EdgeInsets.symmetric(
    horizontal: TeslaTheme.spacingLg,
    vertical: TeslaTheme.spacingMicro,
  );

  static const _textPadding = EdgeInsets.symmetric(
    horizontal: TeslaTheme.spacingMd,
    vertical: TeslaTheme.spacingSm,
  );

  _ButtonColors _resolveColors() => switch (widget.variant) {
        PremiumButtonVariant.primary => const _ButtonColors(
            background: TeslaColors.electricBlue,
            foreground: TeslaColors.white,
          ),
        PremiumButtonVariant.secondary => _ButtonColors(
            background: TeslaColors.electricBlue.withValues(alpha: 0.12),
            foreground: TeslaColors.electricBlue,
          ),
        PremiumButtonVariant.outline => const _ButtonColors(
            background: Colors.transparent,
            foreground: TeslaColors.electricBlue,
            borderColor: TeslaColors.electricBlue,
          ),
        PremiumButtonVariant.text => const _ButtonColors(
            background: Colors.transparent,
            foreground: TeslaColors.electricBlue,
          ),
        PremiumButtonVariant.danger => const _ButtonColors(
            background: TeslaColors.danger,
            foreground: Colors.white,
          ),
        PremiumButtonVariant.success => const _ButtonColors(
            background: Color(0xFF3E6AE1),
            foreground: Colors.white,
          ),
      };

  EdgeInsets get _effectivePadding =>
      widget.padding ??
      (widget.variant == PremiumButtonVariant.text ? _textPadding : _defaultPadding);

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? TeslaTheme.radiusMicro;
    final colors = _resolveColors();

    Widget button;

    if (widget.variant == PremiumButtonVariant.outline) {
      button = Semantics(
        button: true,
        label: widget.text,
        child: OutlinedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.foreground,
            elevation: 0,
            padding: _effectivePadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            side: BorderSide(color: colors.borderColor!, width: 1),
            textStyle: _textStyle,
          ),
          child: _buildButtonChild(),
        ),
      );
    } else if (widget.variant == PremiumButtonVariant.text) {
      button = Semantics(
        button: true,
        label: widget.text,
        child: TextButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: colors.foreground,
            padding: _effectivePadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            textStyle: _textStyle,
          ),
          child: _buildButtonChild(),
        ),
      );
    } else {
      button = Semantics(
        button: true,
        label: widget.text,
        child: ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.background,
            foregroundColor: colors.foreground,
            elevation: 0,
            padding: _effectivePadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            textStyle: _textStyle,
          ),
          child: _buildButtonChild(),
        ),
      );
    }

    return GestureDetector(
      onTapDown: widget.onPressed != null ? _handleTapDown : null,
      onTapUp: widget.onPressed != null ? _handleTapUp : null,
      onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
      child: AnimatedScale(
        scale: _isPressed ? AnimationConstants.touchScale : 1.0,
        duration: TeslaTheme.transitionDuration,
        curve: TeslaTheme.transitionCurve,
        child: button,
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  Widget _buildButtonChild() {
    if (widget.isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 20),
          const SizedBox(width: TeslaTheme.spacingSm),
          Text(widget.text),
        ],
      );
    }

    return Text(widget.text);
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
    final iconColor = color ?? TeslaColors.electricBlue;

    Widget button;

    switch (variant) {
      case PremiumButtonVariant.primary:
        button = Semantics(
          button: true,
          label: accessibilityLabel ?? tooltip ?? 'Icon button',
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ?? TeslaColors.electricBlue,
              borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(
                icon,
                color: isDark ? TeslaColors.carbonDark : TeslaColors.white,
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
          label: accessibilityLabel ?? tooltip ?? 'Icon button',
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ??
                  TeslaColors.electricBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(
                icon,
                color: TeslaColors.electricBlue,
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
          label: accessibilityLabel ?? tooltip ?? 'Icon button',
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              border: Border.all(
                color: TeslaColors.electricBlue,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
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
          label: accessibilityLabel ?? tooltip ?? 'Icon button',
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
          label: accessibilityLabel ?? tooltip ?? 'Icon button',
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ?? TeslaColors.danger,
              borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
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
          label: accessibilityLabel ?? tooltip ?? 'Icon button',
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ?? const Color(0xFF3E6AE1),
              borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
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
      label: tooltip ?? 'Floating action button',
      child: FloatingActionButton(
        onPressed: onPressed,
        tooltip: tooltip,
        mini: mini,
        backgroundColor: backgroundColor ?? TeslaColors.electricBlue,
        foregroundColor: foregroundColor ??
            (isDark ? TeslaColors.carbonDark : TeslaColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            mini ? TeslaTheme.radiusMicro : TeslaTheme.radiusCard,
          ),
        ),
        child: Icon(icon, size: mini ? 20 : 24),
      ),
    );
  }
}
