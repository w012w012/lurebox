import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/app_theme.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/widgets/common/premium_card.dart';

class MonthlyStatsCard extends ConsumerStatefulWidget {
  const MonthlyStatsCard({
    required this.releaseCount,
    required this.keepCount,
    required this.releaseRate,
    required this.title,
    required this.totalCount,
    super.key,
  });
  final int releaseCount;
  final int keepCount;
  final double releaseRate;
  final String title;
  final int totalCount;

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
      duration: AppTheme.transitionDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppTheme.transitionCurve,
      ),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.transitionCurve,
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
    const accentColor = TeslaColors.electricBlue;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: PremiumCard(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingMicro),
              Text(
                '${widget.totalCount}',
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w500,
                  color: accentColor,
                  height: 1,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                '${widget.totalCount}${strings.fishCountUnit}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AnimatedStatItem(
                    index: 0,
                    label: strings.release,
                    count: widget.releaseCount,
                    color: TeslaColors.electricBlue,
                  ),
                  _AnimatedStatItem(
                    index: 1,
                    label: strings.keep,
                    count: widget.keepCount,
                    color: TeslaColors.electricBlue,
                  ),
                  _AnimatedStatItem(
                    index: 2,
                    label: strings.releaseRate,
                    count: widget.releaseRate.round(),
                    color: TeslaColors.electricBlue,
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
  const _AnimatedStatItem({
    required this.index,
    required this.label,
    required this.count,
    required this.color,
    this.isPercent = false,
  });
  final int index;
  final String label;
  final int count;
  final Color color;
  final bool isPercent;

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
      duration: AppTheme.transitionDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: AppTheme.transitionCurve,
    );

    // Stagger the animation
    Future.delayed(
      AppTheme.transitionDuration * widget.index,
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
              borderRadius: BorderRadius.circular(AppTheme.radiusMicro),
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
              fontWeight: FontWeight.w500,
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
