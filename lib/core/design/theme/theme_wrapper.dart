import 'package:flutter/material.dart';

/// 主题切换动画包装器
/// 提供平滑的主题过渡效果
class ThemeWrapper extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const ThemeWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: AnimatedDefaultTextStyle(
        duration: duration,
        curve: curve,
        style: DefaultTextStyle.of(context).style,
        child: child,
      ),
    );
  }
}

/// 主题过渡动画 - 用于整个应用
class AppThemeTransition extends StatelessWidget {
  final Widget child;
  final ThemeMode themeMode;

  const AppThemeTransition({
    super.key,
    required this.child,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: KeyedSubtree(key: ValueKey<ThemeMode>(themeMode), child: child),
    );
  }
}

/// 渐变背景动画 - 用于平滑的背景颜色过渡
class AnimatedThemeBackground extends StatelessWidget {
  final Widget child;
  final Color? lightColor;
  final Color? darkColor;

  const AnimatedThemeBackground({
    super.key,
    required this.child,
    this.lightColor,
    this.darkColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? (darkColor ?? Theme.of(context).scaffoldBackgroundColor)
        : (lightColor ?? Theme.of(context).scaffoldBackgroundColor);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      color: backgroundColor,
      child: child,
    );
  }
}

/// 主题感知颜色包装器
class ThemeAwareColor extends StatelessWidget {
  final Widget child;
  final Color Function(BuildContext) lightColor;
  final Color Function(BuildContext) darkColor;

  const ThemeAwareColor({
    super.key,
    required this.child,
    required this.lightColor,
    required this.darkColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? darkColor(context) : lightColor(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
