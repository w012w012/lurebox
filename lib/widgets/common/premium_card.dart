import 'package:flutter/material.dart';
import '../../core/design/theme/app_theme.dart';
import '../../core/design/theme/app_colors.dart';

/// 高级极简卡片组件
/// 提供统一的卡片样式，支持多种变体
class PremiumCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final PremiumCardVariant variant;
  final bool showBorder;
  final Color? backgroundColor;
  final double? borderRadius;
  final List<BoxShadow>? shadows;

  const PremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.variant = PremiumCardVariant.standard,
    this.showBorder = true,
    this.backgroundColor,
    this.borderRadius,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = showBorder
        ? BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          )
        : BorderSide.none;

    final effectiveBorderRadius = borderRadius ?? AppTheme.radiusMd;
    final effectivePadding =
        padding ?? const EdgeInsets.all(AppTheme.spacingLg);
    final effectiveMargin = margin ??
        const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLg,
          vertical: AppTheme.spacingSm,
        );

    Widget card = Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBg,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        border: Border.fromBorderSide(border),
        boxShadow: shadows ?? _getShadows(),
      ),
      child: child,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          child: card,
        ),
      );
    }

    return Padding(padding: effectiveMargin, child: card);
  }

  List<BoxShadow> _getShadows() {
    switch (variant) {
      case PremiumCardVariant.flat:
        return [];
      case PremiumCardVariant.standard:
        return AppTheme.shadowSm;
      case PremiumCardVariant.elevated:
        return AppTheme.shadowMd;
      case PremiumCardVariant.floating:
        return AppTheme.shadowLg;
    }
  }
}

/// 卡片变体
enum PremiumCardVariant {
  flat, // 无阴影
  standard, // 标准阴影
  elevated, // 提升阴影
  floating, // 悬浮阴影
}

/// 带标题的卡片
class PremiumCardWithTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback? onTap;
  final Widget? trailing;
  final EdgeInsets? padding;
  final PremiumCardVariant variant;

  const PremiumCardWithTitle({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.onTap,
    this.trailing,
    this.padding,
    this.variant = PremiumCardVariant.standard,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      variant: variant,
      onTap: onTap,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          child,
        ],
      ),
    );
  }
}

/// 统计卡片
class PremiumStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const PremiumStatCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;

    return PremiumCard(
      variant: PremiumCardVariant.standard,
      onTap: onTap,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: (iconColor ?? accentColor).withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(icon, color: iconColor ?? accentColor, size: 24),
            ),
            const SizedBox(width: AppTheme.spacingMd),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (unit != null) ...[
                      const SizedBox(width: 4),
                      Text(unit!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 图片卡片
class PremiumImageCard extends StatelessWidget {
  final String imageUrl;
  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;
  final double? height;
  final BoxFit fit;

  const PremiumImageCard({
    super.key,
    required this.imageUrl,
    this.title,
    this.subtitle,
    this.onTap,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      variant: PremiumCardVariant.standard,
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusMd),
              topRight: Radius.circular(AppTheme.radiusMd),
            ),
            child: Image.network(
              imageUrl,
              height: height ?? 160,
              width: double.infinity,
              fit: fit,
              errorBuilder: (context, error, stackTrace) => Container(
                height: height ?? 160,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(
                  child: Icon(Icons.image_not_supported_outlined, size: 48),
                ),
              ),
            ),
          ),
          if (title != null || subtitle != null)
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(title!, style: Theme.of(context).textTheme.titleSmall),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// 列表项卡片
class PremiumListCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  const PremiumListCard({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      variant: PremiumCardVariant.flat,
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      showBorder: true,
      child: Row(
        children: [
          leading,
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppTheme.spacingSm),
            trailing!,
          ],
        ],
      ),
    );
  }
}
