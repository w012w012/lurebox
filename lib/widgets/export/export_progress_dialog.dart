import 'package:flutter/material.dart';
import '../../core/constants/strings.dart';
import '../../core/services/export_options.dart';

class ExportProgressDialog extends StatelessWidget {
  final ExportFormat format;
  final AppStrings strings;
  final VoidCallback onCancel;

  const ExportProgressDialog({
    super.key,
    required this.format,
    required this.strings,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(width: 16),
          Text(strings.exporting),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            format == ExportFormat.csv
                ? strings.generatingCsvFile
                : strings.generatingPdfFile,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
          ),
        ],
      ),
      actions: [TextButton(onPressed: onCancel, child: Text(strings.cancel))],
    );
  }

  static Future<void> show(
    BuildContext context, {
    required ExportFormat format,
    required AppStrings strings,
    required VoidCallback onCancel,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExportProgressDialog(
        format: format,
        strings: strings,
        onCancel: () {
          onCancel();
          Navigator.pop(context);
        },
      ),
    );
  }

  static void dismiss(BuildContext context) {
    Navigator.pop(context);
  }
}
