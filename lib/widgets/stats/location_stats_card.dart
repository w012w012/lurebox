import 'package:flutter/material.dart';

import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/app_theme.dart';
import '../../../core/design/theme/animation_constants.dart';
import '../../../widgets/common/premium_card.dart';

class LocationStatsCard extends StatefulWidget {
  final Map<String, Map<String, int>> locationAnalysis;
  final bool showDetails;
  final VoidCallback? onToggleDetails;

  const LocationStatsCard({
    super.key,
    required this.locationAnalysis,
    this.showDetails = true,
    this.onToggleDetails,
  });

  @override
  State<LocationStatsCard> createState() => _LocationStatsCardState();
}

class _LocationStatsCardState extends State<LocationStatsCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AnimationConstants.pageTransitionDuration,
      vsync: this,
    );
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

  String _blurLocation(String location) {
    if (location.length <= 4) {
      return '*' * location.length;
    }
    final visiblePart = location.substring(0, 6);
    final blurredPart = '*' * (location.length - 6);
    return visiblePart + blurredPart;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.locationAnalysis.isEmpty) return const SizedBox();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: PremiumCard(
        variant: PremiumCardVariant.standard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '钓点分析',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  icon: Icon(
                    widget.showDetails
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: accentColor,
                  ),
                  onPressed: widget.onToggleDetails,
                  tooltip: widget.showDetails ? '隐藏钓点' : '显示钓点',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ...widget.locationAnalysis.entries.map((locationEntry) {
              final location = locationEntry.key;
              final speciesMap = locationEntry.value;
              final total = speciesMap.values.fold(0, (a, b) => a + b);

              return Container(
                margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: accentColor,
                        ),
                        const SizedBox(width: AppTheme.spacingXs),
                        Expanded(
                          child: Text(
                            widget.showDetails
                                ? location
                                : _blurLocation(location),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: accentColor,
                                ),
                          ),
                        ),
                        Text(
                          '合计 $total 条',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Wrap(
                      spacing: AppTheme.spacingSm,
                      runSpacing: AppTheme.spacingXs,
                      children: speciesMap.entries.map((speciesEntry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingSm,
                            vertical: AppTheme.spacingXs,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: Text(
                            '${speciesEntry.key}: ${speciesEntry.value}条',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
