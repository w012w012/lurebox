import 'package:flutter/material.dart';
import '../../core/constants/strings.dart';
import '../../core/services/export_options.dart';
import '../../core/models/fish_catch.dart';
import '../common/premium_button.dart';

class ExportPreviewDialog extends StatelessWidget {
  final ExportOptions options;
  final List<FishCatch> catches;
  final AppStrings strings;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ExportPreviewDialog({
    super.key,
    required this.options,
    required this.catches,
    required this.strings,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(strings.exportConfirm),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummary(context),
              const Divider(height: 24),
              _buildOptions(context),
              const Divider(height: 24),
              _buildPreview(context),
            ],
          ),
        ),
      ),
      actions: [
        PremiumButton(
          text: strings.cancel,
          variant: PremiumButtonVariant.text,
          onPressed: onCancel,
        ),
        PremiumButton(
          text: strings.confirmExport,
          variant: PremiumButtonVariant.primary,
          onPressed: onConfirm,
        ),
      ],
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.willExportNRecords.replaceFirst(
            '\$count',
            catches.length.toString(),
          ),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.exportOptions,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        _buildOptionRow(
          context,
          strings.format,
          options.format == ExportFormat.csv ? 'CSV' : 'PDF',
        ),
        if (options.startDate != null || options.endDate != null)
          _buildOptionRow(
            context,
            strings.timeRange,
            '${options.startDate?.toString().substring(0, 10) ?? strings.startDate} - ${options.endDate?.toString().substring(0, 10) ?? strings.now}',
          ),
        if (options.speciesFilter != null && options.speciesFilter!.isNotEmpty)
          _buildOptionRow(
            context,
            strings.species,
            options.speciesFilter!.join(', '),
          ),
        _buildOptionRow(
          context,
          strings.includeImagePaths,
          options.includeImagePaths ? strings.yes : strings.no,
        ),
        _buildOptionRow(
          context,
          strings.includeLocationInfo,
          options.includeLocation ? strings.yes : strings.no,
        ),
      ],
    );
  }

  Widget _buildOptionRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    final previewCount = catches.length > 5 ? 5 : catches.length;
    final previewItems = catches.take(previewCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.previewFirstN.replaceFirst(
            '\$count',
            previewCount.toString(),
          ),
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: previewItems.length,
            itemBuilder: (context, index) {
              final fish = previewItems[index];
              return ListTile(
                dense: true,
                title: Text(
                  fish.species,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                subtitle: Text(
                  '${fish.length}cm | ${fish.fate.label}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                trailing: Text(
                  fish.catchTime.toString().substring(0, 10),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              );
            },
          ),
        ),
        if (catches.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              strings.moreRecordsRemaining.replaceFirst(
                '\$count',
                (catches.length - 5).toString(),
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
      ],
    );
  }
}
