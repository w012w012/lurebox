import 'package:flutter/material.dart';

import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/animation_constants.dart';
import '../../../widgets/common/premium_card.dart';

/// Collapsible achievement card with expand/collapse functionality.
/// Displays category title, count, icon, and expandable child items.
class AchievementCollapseCard extends StatefulWidget {
  final String title;
  final int currentCount;
  final int totalCount;
  final String icon;
  final bool isCompleted;
  final List<Widget> children;
  final bool initiallyExpanded;

  const AchievementCollapseCard({
    super.key,
    required this.title,
    required this.currentCount,
    required this.totalCount,
    required this.icon,
    this.isCompleted = false,
    this.children = const [],
    this.initiallyExpanded = false,
  });

  @override
  State<AchievementCollapseCard> createState() =>
      _AchievementCollapseCardState();
}

class _AchievementCollapseCardState extends State<AchievementCollapseCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _rotationController = AnimationController(
      duration: AnimationConstants.pageTransitionDuration,
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: AnimationConstants.defaultCurve,
    ));

    if (_isExpanded) {
      _rotationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _rotationController.forward();
      } else {
        _rotationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      variant: PremiumCardVariant.elevated,
      padding: EdgeInsets.zero,
      onTap: _toggleExpanded,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Expand/Collapse icon
                RotationTransition(
                  turns: _rotationAnimation,
                  child: const Icon(
                    Icons.expand_more,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(width: 8),

                // Icon
                Text(
                  widget.icon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),

                // Title and count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryLight,
                            ),
                      ),
                      Text(
                        '${widget.children.length}个成就',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                    ],
                  ),
                ),

                // Count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isCompleted
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.grey200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.currentCount}/${widget.totalCount}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: widget.isCompleted
                                  ? AppColors.success
                                  : AppColors.textSecondaryLight,
                            ),
                      ),
                      const SizedBox(width: 4),
                      if (widget.isCompleted)
                        const Icon(
                          Icons.check_circle,
                          size: 14,
                          color: AppColors.success,
                        )
                      else
                        const Text(
                          '🐟',
                          style: TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedContent(context),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: AnimationConstants.pageTransitionDuration,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    if (widget.children.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Text(
          '还需要 ${widget.totalCount - widget.currentCount} 种鱼',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(
                  milliseconds: 300 +
                      (index * AnimationConstants.staggerDelay.inMilliseconds),
                ),
                curve: AnimationConstants.defaultCurve,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 10 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: child,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Child achievement item for use within AchievementCollapseCard
class AchievementChildItem extends StatelessWidget {
  final String title;
  final int currentCount;
  final int totalCount;
  final bool isCompleted;
  final String? subtitle;

  const AchievementChildItem({
    super.key,
    required this.title,
    required this.currentCount,
    required this.totalCount,
    this.isCompleted = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Status indicator
        Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isCompleted ? AppColors.success : AppColors.grey400,
        ),
        const SizedBox(width: 8),

        // Title and subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isCompleted
                          ? AppColors.textPrimaryLight
                          : AppColors.textSecondaryLight,
                    ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
            ],
          ),
        ),

        // Count badge
        Text(
          '$currentCount/$totalCount',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isCompleted
                    ? AppColors.success
                    : AppColors.textSecondaryLight,
              ),
        ),
      ],
    );
  }
}
