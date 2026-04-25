import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/widgets/common/filter_chip.dart';

class FishFilterPanel extends StatelessWidget {

  const FishFilterPanel({
    required this.strings, required this.timeFilter, required this.speciesList, required this.customDateLabel, required this.onShowDateRangePicker, required this.onTimeFilterChanged, required this.onFateFilterChanged, required this.onSpeciesFilterChanged, super.key,
    this.fateFilter,
    this.speciesFilter,
  });
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet._(
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

/// Tesla-style bottom sheet for fish filter — watches state to update chip visuals.
class _FilterBottomSheet extends ConsumerStatefulWidget {
  const _FilterBottomSheet._({
    required this.strings,
    required this.timeFilter,
    required this.speciesList, required this.customDateLabel, required this.onShowDateRangePicker, required this.onTimeFilterChanged, required this.onFateFilterChanged, required this.onSpeciesFilterChanged, this.fateFilter,
    this.speciesFilter,
  });

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

  @override
  ConsumerState<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<_FilterBottomSheet> {
  // Hold local state that mirrors the sheet-level filter state
  // These are only used for UI display; the actual filtering is via the callbacks
  String _timeFilter = 'all';
  FishFateType? _fateFilter;
  String? _speciesFilter;

  @override
  void initState() {
    super.initState();
    _timeFilter = widget.timeFilter;
    _fateFilter = widget.fateFilter;
    _speciesFilter = widget.speciesFilter;
  }

  void _onTimeFilterChanged(String filter) {
    setState(() => _timeFilter = filter);
    widget.onTimeFilterChanged(filter);
  }

  void _onFateFilterChanged(FishFateType? fate) {
    setState(() => _fateFilter = fate);
    widget.onFateFilterChanged(fate);
  }

  void _onSpeciesFilterChanged(String? species) {
    setState(() => _speciesFilter = species);
    widget.onSpeciesFilterChanged(species);
  }

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
                    widget.strings.filter,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      widget.strings.done,
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
                strings: widget.strings,
                timeFilter: _timeFilter,
                fateFilter: _fateFilter,
                speciesFilter: _speciesFilter,
                speciesList: widget.speciesList,
                customDateLabel: widget.customDateLabel,
                onShowDateRangePicker: widget.onShowDateRangePicker,
                onTimeFilterChanged: _onTimeFilterChanged,
                onFateFilterChanged: _onFateFilterChanged,
                onSpeciesFilterChanged: _onSpeciesFilterChanged,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class FishFilterCollapsed extends StatelessWidget {

  const FishFilterCollapsed({
    required this.hasFilters, required this.filterLabel, required this.expandLabel, required this.onTap, super.key,
    this.onClear,
    this.onShowSheet,
  });
  final bool hasFilters;
  final String filterLabel;
  final String expandLabel;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final VoidCallback? onShowSheet;

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
