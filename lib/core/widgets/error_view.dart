import 'package:flutter/material.dart';
import '../design/theme/app_colors.dart';
import '../constants/strings.dart';
import '../../widgets/common/premium_button.dart';

/// 通用的空状态组件，支持插画图标、文字描述和操作按钮。
class AppEmptyState extends StatelessWidget {
  /// 主提示文字
  final String message;

  /// 副标题描述（可选）
  final String? description;

  /// 左侧图标（可选，默认显示图标）
  final IconData? icon;

  /// 自定义插画图片路径（可选，覆盖 icon）
  final String? imageAsset;

  /// 操作按钮文字（可选，与 onAction 配对使用）
  final String? actionLabel;

  /// 操作按钮回调
  final VoidCallback? onAction;

  /// 背景色（默认透明）
  final Color? backgroundColor;

  const AppEmptyState({
    super.key,
    required this.message,
    this.description,
    this.icon,
    this.imageAsset,
    this.actionLabel,
    this.onAction,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: backgroundColor ?? (isDark ? TeslaColors.carbonDark : Colors.transparent),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 插画或图标
              if (imageAsset != null)
                Image.asset(
                  imageAsset!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _buildIcon(context),
                )
              else
                _buildIcon(context),

              const SizedBox(height: 24),

              // 主文字
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : TeslaColors.carbonDark,
                    ),
              ),

              // 副标题描述
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? const Color(0xFF9A9A9A) : TeslaColors.graphite,
                      ),
                ),
              ],

              // 操作按钮
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 32),
                PremiumButton(
                  text: actionLabel!,
                  onPressed: onAction,
                  icon: icon ?? Icons.add,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Icon(
      icon ?? Icons.inbox_outlined,
      size: 72,
      color: Theme.of(context).colorScheme.outline,
    );
  }
}

/// 错误视图（保留向后兼容）
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? title;
  final IconData? icon;
  final AppStrings? strings;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
    this.icon,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStrings = strings;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: TeslaColors.electricBlue,
            ),
            const SizedBox(height: 16),
            Text(
              title ?? (effectiveStrings?.error ?? 'Error'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              PremiumButton(
                text: effectiveStrings?.retry ?? 'Retry',
                onPressed: onRetry,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 加载视图
class LoadingView extends StatelessWidget {
  final String? message;

  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: TeslaColors.electricBlue,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 保留旧 EmptyView 别名以兼容现有代码
typedef EmptyView = AppEmptyState;
