import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/app_theme.dart';
import '../../../core/design/theme/animation_constants.dart';
import '../../../core/providers/language_provider.dart';
import '../../../widgets/common/premium_card.dart';

class MonthlyStatsCard extends ConsumerStatefulWidget {
  final int releaseCount;
  final int keepCount;
  final double releaseRate;
  final String title;
  final int totalCount;

  const MonthlyStatsCard({
    super.key,
    required this.releaseCount,
    required this.keepCount,
    required this.releaseRate,
    required this.title,
    required this.totalCount,
  });

  @override
  ConsumerState<MonthlyStatsCard> createState() => _MonthlyStatsCardState();
}

class _MonthlyStatsCardState extends ConsumerState<MonthlyStatsCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AnimationConstants.pageTransitionDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AnimationConstants.defaultCurve,
    ));
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AnimationConstants.defaultCurve,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(currentStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: PremiumCard(
          variant: PremiumCardVariant.standard,
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          child: Column(
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                '${widget.totalCount}',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                '${widget.totalCount}${strings.fishCountUnit}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingXl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AnimatedStatItem(
                    index: 0,
                    label: strings.release,
                    count: widget.releaseCount,
                    color: AppColors.release,
                  ),
                  _AnimatedStatItem(
                    index: 1,
                    label: strings.keep,
                    count: widget.keepCount,
                    color: AppColors.keep,
                  ),
                  _AnimatedStatItem(
                    index: 2,
                    label: strings.releaseRate,
                    count: widget.releaseRate.round(),
                    color: AppColors.teal,
                    isPercent: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedStatItem extends StatefulWidget {
  final int index;
  final String label;
  final int count;
  final Color color;
  final bool isPercent;

  const _AnimatedStatItem({
    required this.index,
    required this.label,
    required this.count,
    required this.color,
    this.isPercent = false,
  });

  @override
  State<_AnimatedStatItem> createState() => _AnimatedStatItemState();
}

class _AnimatedStatItemState extends State<_AnimatedStatItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationConstants.pageTransitionDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: AnimationConstants.defaultCurve,
    );

    // Stagger the animation
    Future.delayed(
      AnimationConstants.staggerDelay * widget.index,
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(
              widget.isPercent ? Icons.percent : Icons.set_meal,
              color: widget.color,
              size: 20,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            '${widget.count}${widget.isPercent ? '%' : ''}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: widget.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
