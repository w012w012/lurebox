import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/widgets/common/premium_card.dart';

/// Collapsible achievement card with expand/collapse functionality.
/// Displays category title, count, icon, and expandable child items.
class AchievementCollapseCard extends ConsumerStatefulWidget {

  const AchievementCollapseCard({
    required this.title, required this.currentCount, required this.totalCount, required this.icon, super.key,
    this.isCompleted = false,
    this.children = const [],
    this.initiallyExpanded = false,
  });
  final String title;
  final int currentCount;
  final int totalCount;
  final String icon;
  final bool isCompleted;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  ConsumerState<AchievementCollapseCard> createState() =>
      _AchievementCollapseCardState();
}

class _AchievementCollapseCardState
    extends ConsumerState<AchievementCollapseCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _rotationController = AnimationController(
      duration: TeslaTheme.transitionDuration,
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: TeslaTheme.transitionCurve,
    ),);

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
    final strings = ref.watch(currentStringsProvider);
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
                    color: TeslaColors.graphite,
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
                              fontWeight: FontWeight.w500,
                              color: TeslaColors.carbonDark,
                            ),
                      ),
                      Text(
                        '${widget.children.length}${strings.achievementUnit}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: TeslaColors.graphite,
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
                        ? TeslaColors.electricBlue.withValues(alpha: 0.1)
                        : TeslaColors.cloudGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.currentCount}/${widget.totalCount}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: widget.isCompleted
                                  ? TeslaColors.electricBlue
                                  : TeslaColors.graphite,
                            ),
                      ),
                      const SizedBox(width: 4),
                      if (widget.isCompleted)
                        const Icon(
                          Icons.check_circle,
                          size: 14,
                          color: TeslaColors.electricBlue,
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
            duration: TeslaTheme.transitionDuration,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    final strings = ref.watch(currentStringsProvider);
    if (widget.children.isEmpty) {
      final remaining = widget.totalCount - widget.currentCount;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Text(
          strings.remainingAchievements.replaceAll(r'$count', '$remaining'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TeslaColors.graphite,
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
                tween: Tween(begin: 0, end: 1),
                duration: Duration(
                  milliseconds:
                      TeslaTheme.transitionDuration.inMilliseconds * (index + 1),
                ),
                curve: TeslaTheme.transitionCurve,
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

  const AchievementChildItem({
    required this.title, required this.currentCount, required this.totalCount, super.key,
    this.isCompleted = false,
    this.subtitle,
  });
  final String title;
  final int currentCount;
  final int totalCount;
  final bool isCompleted;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Status indicator
        Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isCompleted ? TeslaColors.electricBlue : TeslaColors.paleSilver,
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
                          ? TeslaColors.carbonDark
                          : TeslaColors.graphite,
                    ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TeslaColors.graphite,
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
                    ? TeslaColors.electricBlue
                    : TeslaColors.graphite,
              ),
        ),
      ],
    );
  }
}
