import 'package:flutter/material.dart';
import '../../../core/constants/strings.dart';
import '../../../core/design/theme/app_colors.dart';
import '../../../core/models/fish_catch.dart';
import '../../../widgets/common/filter_chip.dart';

class FishFilterPanel extends StatelessWidget {
  final AppStrings strings;
  final String timeFilter;
  final FishFateType? fateFilter;
  final String? speciesFilter;
  final List<String> speciesList;
  final String customDateLabel;
  final VoidCallback onShowDateRangePicker;
  final ValueChanged<String> onTimeFilterChanged;
  final ValueChanged<FishFateType?> onFateFilterChanged;
  final ValueChanged<String?> onSpeciesFilterChanged;

  const FishFilterPanel({
    super.key,
    required this.strings,
    required this.timeFilter,
    this.fateFilter,
    this.speciesFilter,
    required this.speciesList,
    required this.customDateLabel,
    required this.onShowDateRangePicker,
    required this.onTimeFilterChanged,
    required this.onFateFilterChanged,
    required this.onSpeciesFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, strings.time),
          const SizedBox(height: 6),
          _buildTimeChips(),
          const SizedBox(height: 12),
          _buildSectionTitle(context, strings.fate),
          const SizedBox(height: 6),
          _buildFateChips(),
          const SizedBox(height: 12),
          _buildSectionTitle(context, strings.species),
          const SizedBox(height: 6),
          _buildSpeciesChips(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildTimeChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          AppFilterChip(
            label: strings.all,
            isSelected: timeFilter == 'all',
            onTap: () => onTimeFilterChanged('all'),
          ),
          AppFilterChip(
            label: strings.today,
            isSelected: timeFilter == 'today',
            onTap: () => onTimeFilterChanged('today'),
          ),
          AppFilterChip(
            label: strings.thisWeek,
            isSelected: timeFilter == 'week',
            onTap: () => onTimeFilterChanged('week'),
          ),
          AppFilterChip(
            label: strings.thisMonth,
            isSelected: timeFilter == 'month',
            onTap: () => onTimeFilterChanged('month'),
          ),
          AppFilterChip(
            label: strings.thisYear,
            isSelected: timeFilter == 'year',
            onTap: () => onTimeFilterChanged('year'),
          ),
          AppFilterChip(
            label: customDateLabel,
            isSelected: timeFilter == 'custom',
            icon: Icons.date_range,
            onTap: onShowDateRangePicker,
          ),
        ],
      ),
    );
  }

  Widget _buildFateChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          AppFilterChip(
            label: strings.all,
            isSelected: fateFilter == null,
            onTap: () => onFateFilterChanged(null),
          ),
          AppFilterChip(
            label: strings.release,
            isSelected: fateFilter == FishFateType.release,
            color: AppColors.release,
            onTap: () => onFateFilterChanged(FishFateType.release),
          ),
          AppFilterChip(
            label: strings.keep,
            isSelected: fateFilter == FishFateType.keep,
            color: AppColors.keep,
            onTap: () => onFateFilterChanged(FishFateType.keep),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          AppFilterChip(
            label: strings.all,
            isSelected: speciesFilter == null,
            onTap: () => onSpeciesFilterChanged(null),
          ),
          ...speciesList.map(
            (species) => AppFilterChip(
              label: species,
              isSelected: speciesFilter == species,
              onTap: () => onSpeciesFilterChanged(species),
            ),
          ),
        ],
      ),
    );
  }
}

class FishFilterCollapsed extends StatelessWidget {
  final bool hasFilters;
  final String filterLabel;
  final String expandLabel;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const FishFilterCollapsed({
    super.key,
    required this.hasFilters,
    required this.filterLabel,
    required this.expandLabel,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.filter_list,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasFilters ? filterLabel : expandLabel,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (hasFilters && onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
