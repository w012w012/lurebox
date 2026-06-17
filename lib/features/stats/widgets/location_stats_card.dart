import 'package:flutter/material.dart';

import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/app_theme.dart';
import 'package:lurebox/widgets/common/premium_card.dart';

class LocationStatsCard extends StatefulWidget {
  const LocationStatsCard({
    required this.locationAnalysis,
    required this.strings,
    super.key,
    this.showDetails = true,
    this.onToggleDetails,
  });
  final Map<String, Map<String, int>> locationAnalysis;
  final bool showDetails;
  final VoidCallback? onToggleDetails;
  final AppStrings strings;

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
      duration: AppTheme.transitionDuration,
      vsync: this,
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

  /// 对钓点名称脱敏：保留前 2 个字符，其余以固定 *** 掩码替换，
  /// 既隐藏大部分位置信息，又不泄露名称长度。
  /// 长度 <= 2 时整体以等长 * 替换，避免 substring 越界。
  String _blurLocation(String location) {
    if (location.length <= 2) {
      return '*' * location.length;
    }
    return '${location.substring(0, 2)}***';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.locationAnalysis.isEmpty) return const SizedBox();

    const accentColor = TeslaColors.electricBlue;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.strings.locationAnalysis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
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
                  tooltip: 'Show/hide details',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMicro),
            ...widget.locationAnalysis.entries.map((locationEntry) {
              final location = locationEntry.key;
              final speciesMap = locationEntry.value;
              final total = speciesMap.values.fold(0, (a, b) => a + b);

              return Container(
                margin: const EdgeInsets.only(bottom: AppTheme.spacingMicro),
                padding: const EdgeInsets.all(AppTheme.spacingMicro),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
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
                        const Icon(
                          Icons.location_on,
                          size: 18,
                          color: accentColor,
                        ),
                        const SizedBox(width: AppTheme.spacingMicro),
                        Expanded(
                          child: Text(
                            widget.showDetails
                                ? location
                                : _blurLocation(location),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: accentColor,
                                ),
                          ),
                        ),
                        Text(
                          widget.strings.totalCountPattern
                              .replaceAll('%d', total.toString()),
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
                      runSpacing: AppTheme.spacingMicro,
                      children: speciesMap.entries.map((speciesEntry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingSm,
                            vertical: AppTheme.spacingMicro,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusCard),
                          ),
                          child: Text(
                            widget.strings.speciesCountPattern
                                .replaceAll('%s', speciesEntry.key)
                                .replaceAll(
                                    '%d', speciesEntry.value.toString(),),
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
