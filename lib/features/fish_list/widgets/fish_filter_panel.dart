import 'package:flutter/material.dart';
import '../../../core/constants/strings.dart';
import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/tesla_theme.dart';
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

  /// Show the filter panel as a modal bottom sheet.
  static void show({
    required BuildContext context,
    required AppStrings strings,
    required String timeFilter,
    required FishFateType? fateFilter,
    required String? speciesFilter,
    required List<String> speciesList,
    required String customDateLabel,
    required VoidCallback onShowDateRangePicker,
    required ValueChanged<String> onTimeFilterChanged,
    required ValueChanged<FishFateType?> onFateFilterChanged,
    required ValueChanged<String?> onSpeciesFilterChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        strings: strings,
        timeFilter: timeFilter,
        fateFilter: fateFilter,
        speciesFilter: speciesFilter,
        speciesList: speciesList,
        customDateLabel: customDateLabel,
        onShowDateRangePicker: onShowDateRangePicker,
        onTimeFilterChanged: onTimeFilterChanged,
        onFateFilterChanged: onFateFilterChanged,
        onSpeciesFilterChanged: onSpeciesFilterChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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
        const SizedBox(height: 16),
      ],
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
  final VoidCallback? onShowSheet;

  const FishFilterCollapsed({
    super.key,
    required this.hasFilters,
    required this.filterLabel,
    required this.expandLabel,
    required this.onTap,
    this.onClear,
    this.onShowSheet,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onShowSheet ?? onTap,
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

/// Bottom sheet wrapper for FishFilterPanel — Tesla-style sheet.
class _FilterBottomSheet extends StatelessWidget {
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

  const _FilterBottomSheet({
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? TeslaColors.carbonDark : TeslaColors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(TeslaTheme.radiusCard),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF5C5E62) : TeslaColors.cloudGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Text(
                    strings.filter,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      strings.done,
                      style: const TextStyle(
                        color: TeslaColors.electricBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Filter content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: FishFilterPanel(
                strings: strings,
                timeFilter: timeFilter,
                fateFilter: fateFilter,
                speciesFilter: speciesFilter,
                speciesList: speciesList,
                customDateLabel: customDateLabel,
                onShowDateRangePicker: onShowDateRangePicker,
                onTimeFilterChanged: onTimeFilterChanged,
                onFateFilterChanged: onFateFilterChanged,
                onSpeciesFilterChanged: onSpeciesFilterChanged,
              ),
            ),
            // Bottom padding
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
