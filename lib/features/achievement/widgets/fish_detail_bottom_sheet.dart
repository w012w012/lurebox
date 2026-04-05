import 'package:flutter/material.dart';
import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/app_theme.dart';
import '../../../core/models/fish_species.dart';
import '../../../core/services/fish_species_stats_service.dart';
import 'alias_selector.dart';
import 'size_distribution_chart.dart';

/// Bottom sheet for displaying fish species details.
///
/// Supports dragging to close, internal scrolling, and shows:
/// - Species info (name, scientific name, category, rarity)
/// - Catch statistics (count, size range, weight)
/// - Size distribution chart
/// - Alias selector
class FishDetailBottomSheet extends StatelessWidget {
  /// Fish species to display
  final FishSpecies species;

  /// Fish species statistics
  final FishSpeciesStats stats;

  /// Callback when close is requested
  final VoidCallback? onClose;

  /// Size distribution buckets
  final List<SizeBucket>? sizeBuckets;

  /// Callback for alias change
  final ValueChanged<String>? onAliasChanged;

  const FishDetailBottomSheet({
    super.key,
    required this.species,
    required this.stats,
    this.onClose,
    this.sizeBuckets,
    this.onAliasChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusLg),
            ),
          ),
          child: Stack(
            children: [
              // Content
              SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingLg,
                  AppTheme.spacingXl,
                  AppTheme.spacingLg,
                  AppTheme.spacingXxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with species icon and basic info
                    _buildHeader(context, isDark),
                    const SizedBox(height: AppTheme.spacingXl),
                    // Stats section
                    _buildStatsSection(context, isDark),
                    const SizedBox(height: AppTheme.spacingXl),
                    // Alias selector
                    if (species.aliases.isNotEmpty) ...[
                      AliasSelector(
                        currentAlias: species.standardName,
                        aliases: [species.standardName, ...species.aliases],
                        onAliasChanged: onAliasChanged,
                      ),
                      const SizedBox(height: AppTheme.spacingXl),
                    ],
                    // Size distribution chart
                    if (sizeBuckets != null && sizeBuckets!.isNotEmpty) ...[
                      SizeDistributionChart(buckets: sizeBuckets!),
                      const SizedBox(height: AppTheme.spacingXl),
                    ],
                    // Description section
                    if (species.description != null) ...[
                      _buildDescriptionSection(context, isDark),
                    ],
                  ],
                ),
              ),
              // Close button
              Positioned(
                top: AppTheme.spacingSm,
                right: AppTheme.spacingSm,
                child: IconButton(
                  onPressed: onClose ?? () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              // Drag handle
              Positioned(
                top: AppTheme.spacingSm,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.grey700 : AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Species emoji/icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.accentDark.withOpacity(0.15)
                : AppColors.accentLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Center(
            child: Text(
              species.iconEmoji ?? '🐟',
              style: const TextStyle(fontSize: 40),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        // Species info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Standard name
              Text(
                species.standardName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingXs),
              // Scientific name
              if (species.scientificName != null)
                Text(
                  species.scientificName!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                ),
              const SizedBox(height: AppTheme.spacingSm),
              // Category and rarity
              Row(
                children: [
                  _buildTag(
                    context,
                    species.category.label,
                    isDark
                        ? AppColors.accentDark.withOpacity(0.2)
                        : AppColors.accentLight.withOpacity(0.1),
                    isDark ? AppColors.accentDark : AppColors.accentLight,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  _buildRarityTag(context, isDark),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTag(
    BuildContext context,
    String label,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildRarityTag(BuildContext context, bool isDark) {
    final rarity = species.rarity;
    Color tagColor;
    switch (rarity) {
      case FishRarity.common:
        tagColor = AppColors.grey500;
        break;
      case FishRarity.uncommon:
        tagColor = AppColors.success;
        break;
      case FishRarity.rare:
        tagColor = AppColors.accentLight;
        break;
      case FishRarity.legendary:
        tagColor = AppColors.gold;
        break;
      case FishRarity.mythical:
        tagColor = AppColors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: tagColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(
            rarity.value,
            (index) => Icon(
              Icons.star_rounded,
              size: 12,
              color: tagColor,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            rarity.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: tagColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        children: [
          // Catch count row
          _buildStatRow(
            context,
            icon: Icons.catching_pokemon,
            label: '捕获次数',
            value: '${stats.totalCount} 次',
            isDark: isDark,
          ),
          const Divider(height: AppTheme.spacingLg),
          // Size range row
          _buildStatRow(
            context,
            icon: Icons.straighten_rounded,
            label: '尺寸范围',
            value: stats.minLength > 0 && stats.maxLength > 0
                ? '${stats.minLength.toStringAsFixed(1)} - ${stats.maxLength.toStringAsFixed(1)} cm'
                : '暂无数据',
            isDark: isDark,
          ),
          const Divider(height: AppTheme.spacingLg),
          // Average size row
          _buildStatRow(
            context,
            icon: Icons.analytics_outlined,
            label: '平均尺寸',
            value: stats.avgLength > 0
                ? '${stats.avgLength.toStringAsFixed(1)} cm'
                : '暂无数据',
            isDark: isDark,
          ),
          // Weight row (if available)
          if (stats.maxWeight != null) ...[
            const Divider(height: AppTheme.spacingLg),
            _buildStatRow(
              context,
              icon: Icons.fitness_center_rounded,
              label: '最大重量',
              value: '${stats.maxWeight!.toStringAsFixed(2)} kg',
              isDark: isDark,
            ),
          ],
          // First caught row
          if (stats.firstCaughtAt != null) ...[
            const Divider(height: AppTheme.spacingLg),
            _buildStatRow(
              context,
              icon: Icons.calendar_today_rounded,
              label: '首次捕获',
              value: _formatDate(stats.firstCaughtAt!),
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.accentDark : AppColors.accentLight,
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: secondaryColor,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context, bool isDark) {
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '简介',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          species.description!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: 1.6,
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}

/// Show fish detail bottom sheet as a modal
Future<void> showFishDetailBottomSheet(
  BuildContext context, {
  required FishSpecies species,
  required FishSpeciesStats stats,
  List<SizeBucket>? sizeBuckets,
  ValueChanged<String>? onAliasChanged,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FishDetailBottomSheet(
      species: species,
      stats: stats,
      sizeBuckets: sizeBuckets,
      onAliasChanged: onAliasChanged,
    ),
  );
}
