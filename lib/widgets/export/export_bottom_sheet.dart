import 'package:flutter/material.dart';
import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/services/export_options.dart';
import '../../core/models/fish_catch.dart';
import '../common/filter_chip.dart';
import '../common/premium_button.dart';

class ExportBottomSheet extends StatefulWidget {
  final List<FishCatch> allCatches;
  final List<String> availableSpecies;
  final AppStrings strings;
  final void Function(ExportOptions options, List<FishCatch> filteredCatches)
      onExport;

  const ExportBottomSheet({
    super.key,
    required this.allCatches,
    required this.availableSpecies,
    required this.strings,
    required this.onExport,
  });

  @override
  State<ExportBottomSheet> createState() => _ExportBottomSheetState();
}

class _ExportBottomSheetState extends State<ExportBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  Set<String> _selectedSpecies = {};
  ExportFormat _format = ExportFormat.csv;
  bool _includeImagePaths = false;
  bool _includeLocation = true;

  List<FishCatch> get _filteredCatches {
    return widget.allCatches.where((fish) {
      if (_startDate != null && fish.catchTime.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null &&
          fish.catchTime.isAfter(_endDate!.add(const Duration(days: 1)))) {
        return false;
      }
      if (_selectedSpecies.isNotEmpty &&
          !_selectedSpecies.contains(fish.species)) {
        return false;
      }
      return true;
    }).toList();
  }

  String get _dateRangeLabel {
    if (_startDate == null && _endDate == null) {
      return widget.strings.allTime;
    }
    final start =
        _startDate?.toString().substring(0, 10) ?? widget.strings.startDate;
    final end = _endDate?.toString().substring(0, 10) ?? widget.strings.now;
    return '$start - $end';
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              widget.strings.catchRecordsExport,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          _buildDateRangeSection(),
          const SizedBox(height: 16),
          _buildSpeciesFilterSection(),
          const SizedBox(height: 16),
          _buildFormatSection(),
          const SizedBox(height: 16),
          _buildOptionsSection(),
          const SizedBox(height: 24),
          _buildExportButton(),
        ],
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.strings.timeRange,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDateRange,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.date_range, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _dateRangeLabel,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                if (_startDate != null || _endDate != null)
                  GestureDetector(
                    onTap: () => setState(() {
                      _startDate = null;
                      _endDate = null;
                    }),
                    child: const Icon(Icons.close, size: 18),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeciesFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.strings.speciesFilter,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (_selectedSpecies.isNotEmpty)
              PremiumButton(
                text: widget.strings.clear,
                variant: PremiumButtonVariant.text,
                onPressed: () => setState(() => _selectedSpecies.clear()),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            AppFilterChip(
              label: widget.strings.all,
              isSelected: _selectedSpecies.isEmpty,
              onTap: () => setState(() => _selectedSpecies.clear()),
            ),
            ...widget.availableSpecies.map(
              (species) => AppFilterChip(
                label: species,
                isSelected: _selectedSpecies.contains(species),
                onTap: () {
                  setState(() {
                    if (_selectedSpecies.contains(species)) {
                      _selectedSpecies.remove(species);
                    } else {
                      _selectedSpecies.add(species);
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.strings.exportFormat,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildFormatOption(
                label: 'CSV',
                icon: Icons.table_chart,
                isSelected: _format == ExportFormat.csv,
                onTap: () => setState(() => _format = ExportFormat.csv),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFormatOption(
                label: 'PDF',
                icon: Icons.picture_as_pdf,
                isSelected: _format == ExportFormat.pdf,
                onTap: () => setState(() => _format = ExportFormat.pdf),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final accentColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.accentDark
        : AppColors.accentLight;
    final accentBackground = Theme.of(context).brightness == Brightness.dark
        ? AppColors.accentDark.withOpacity(0.12)
        : AppColors.accentLight.withOpacity(0.12);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? accentColor
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? accentBackground : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? accentColor
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? accentColor
                        : Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.strings.otherOptions,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: Text(widget.strings.includeImagePaths),
          value: _includeImagePaths,
          onChanged: (value) =>
              setState(() => _includeImagePaths = value ?? false),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        CheckboxListTile(
          title: Text(widget.strings.includeLocationInfo),
          value: _includeLocation,
          onChanged: (value) =>
              setState(() => _includeLocation = value ?? true),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
      ],
    );
  }

  Widget _buildExportButton() {
    final count = _filteredCatches.length;
    return PremiumButton(
      text: count > 0
          ? widget.strings.exportNRecords.replaceFirst(
              '\$count',
              count.toString(),
            )
          : widget.strings.noMatchingRecords,
      variant: PremiumButtonVariant.primary,
      isFullWidth: true,
      borderRadius: 8,
      padding: const EdgeInsets.symmetric(vertical: 14),
      onPressed: count > 0
          ? () {
              final options = ExportOptions(
                startDate: _startDate,
                endDate: _endDate,
                speciesFilter:
                    _selectedSpecies.isEmpty ? null : _selectedSpecies.toList(),
                format: _format,
                includeImagePaths: _includeImagePaths,
                includeLocation: _includeLocation,
              );
              widget.onExport(options, _filteredCatches);
              Navigator.pop(context);
            }
          : null,
    );
  }
}
