import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/tesla_theme.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/watermark_provider.dart';
import 'widgets/watermark_color_selector.dart';
import 'widgets/watermark_custom_text_field.dart';
import '../../core/models/watermark_settings.dart';
import '../../widgets/common/premium_card.dart';
import 'widgets/watermark_enable_switch.dart';
import 'widgets/watermark_info_section.dart';
import 'widgets/watermark_position_selector.dart';
import 'widgets/watermark_preview_card.dart';
import 'widgets/watermark_style_selector.dart';
import 'widgets/labeled_slider.dart';

/// 水印设置页面
class WatermarkSettingsPage extends ConsumerWidget {
  const WatermarkSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(watermarkSettingsProvider);
    final strings = ref.watch(currentStringsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.watermarkSettings), centerTitle: true),
      body: ListView(
        children: [
          WatermarkEnableSwitch(
            settings: settings,
            strings: strings,
            onToggle: (value) {
              ref
                  .read(watermarkSettingsProvider.notifier)
                  .updateEnabled(value);
            },
          ),
          const SizedBox(height: TeslaTheme.spacingMicro),
          if (settings.enabled) ...[
            WatermarkInfoSection(
              settings: settings,
              strings: strings,
              onToggle: (type) {
                ref
                    .read(watermarkSettingsProvider.notifier)
                    .toggleInfoType(type);
              },
              onReorder: (oldIndex, newIndex) {
                ref
                    .read(watermarkSettingsProvider.notifier)
                    .reorderInfoTypes(oldIndex, newIndex);
              },
            ),
            const SizedBox(height: TeslaTheme.spacingMd),
            _buildStyleSection(context, ref, settings, strings),
            const SizedBox(height: TeslaTheme.spacingMd),
            WatermarkPreviewCard(settings: settings, strings: strings),
          ],
        ],
      ),
    );
  }

  Widget _buildStyleSection(
    BuildContext context,
    WidgetRef ref,
    WatermarkSettings settings,
    AppStrings strings,
  ) {
    return PremiumCard(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.style,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: TeslaTheme.spacingSm),
                Text(
                  strings.watermarkStyle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: TeslaTheme.spacingMd),
            WatermarkStyleSelector(
              settings: settings,
              strings: strings,
              onStyleChanged: (style) {
                ref
                    .read(watermarkSettingsProvider.notifier)
                    .updateStyle(style);
              },
            ),
            const SizedBox(height: TeslaTheme.spacingMd),
            WatermarkPositionSelector(
              settings: settings,
              strings: strings,
              onPositionChanged: (position) {
                ref
                    .read(watermarkSettingsProvider.notifier)
                    .updatePosition(position);
              },
            ),
            const SizedBox(height: TeslaTheme.spacingMd),
            LabeledSlider(
              label: strings.watermarkBgRadius,
              value: settings.blurRadius,
              min: 0,
              max: 20,
              onChanged: (value) {
                ref
                    .read(watermarkSettingsProvider.notifier)
                    .updateBlurRadius(value);
              },
            ),
            const SizedBox(height: TeslaTheme.spacingSm),
            LabeledSlider(
              label: strings.watermarkBgOpacity,
              value: settings.backgroundOpacity * 100,
              min: 0,
              max: 100,
              onChanged: (value) {
                ref
                    .read(watermarkSettingsProvider.notifier)
                    .updateBackgroundOpacity(value / 100);
              },
              valueFormatter: (v) => '${v.toInt()}%',
            ),
            const SizedBox(height: TeslaTheme.spacingSm),
            LabeledSlider(
              label: strings.watermarkFontSize,
              value: settings.fontSize,
              min: 10,
              max: 24,
              onChanged: (value) {
                ref
                    .read(watermarkSettingsProvider.notifier)
                    .updateFontSize(value);
              },
            ),
            const SizedBox(height: TeslaTheme.spacingMd),
            WatermarkColorSelector(
              selectedColor: settings.textColor,
              strings: strings,
              onColorChanged: (color) {
                ref
                    .read(watermarkSettingsProvider.notifier)
                    .updateTextColor(color);
              },
            ),
            const SizedBox(height: TeslaTheme.spacingSm),
            WatermarkCustomTextField(settings: settings, strings: strings),
          ],
        ),
      );
  }
}
