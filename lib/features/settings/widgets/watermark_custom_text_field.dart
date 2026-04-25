import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/models/watermark_settings.dart';
import 'package:lurebox/core/providers/watermark_provider.dart';

class WatermarkCustomTextField extends ConsumerStatefulWidget {

  const WatermarkCustomTextField({
    required this.settings, required this.strings, super.key,
  });
  final WatermarkSettings settings;
  final AppStrings strings;

  @override
  ConsumerState<WatermarkCustomTextField> createState() =>
      _WatermarkCustomTextFieldState();
}

class _WatermarkCustomTextFieldState
    extends ConsumerState<WatermarkCustomTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.settings.customText ?? '');
  }

  @override
  void didUpdateWidget(covariant WatermarkCustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.settings.customText != oldWidget.settings.customText &&
        _controller.text != (widget.settings.customText ?? '')) {
      _controller.text = widget.settings.customText ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.strings.watermarkCustomText,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: TeslaTheme.spacingMicro),
        Text(
          widget.strings.watermarkCustomTextHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TeslaColors.graphite,
              ),
        ),
        const SizedBox(height: TeslaTheme.spacingSm),
        TextField(
          decoration: InputDecoration(
            hintText: widget.strings.watermarkCustomTextPlaceholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: TeslaTheme.spacingSm,
              vertical: 10,
            ),
            isDense: true,
          ),
          controller: _controller,
          onChanged: (value) {
            ref
                .read(watermarkSettingsProvider.notifier)
                .updateCustomText(value.isEmpty ? null : value);
          },
        ),
      ],
    );
  }
}
