import 'package:flutter/material.dart';

import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/models/watermark_settings.dart';

class WatermarkStyleSelector extends StatelessWidget {

  const WatermarkStyleSelector({
    required this.settings, required this.strings, required this.onStyleChanged, super.key,
  });
  final WatermarkSettings settings;
  final AppStrings strings;
  final ValueChanged<WatermarkStyle> onStyleChanged;

  @override
  Widget build(BuildContext context) {
    final styles = [
      (
        WatermarkStyle.minimal,
        strings.watermarkTemplateSimple,
        strings.watermarkTemplateSimpleDesc,
      ),
      (
        WatermarkStyle.elegant,
        strings.watermarkTemplateElegant,
        strings.watermarkTemplateElegantDesc,
      ),
      (
        WatermarkStyle.bold,
        strings.watermarkTemplateBold,
        strings.watermarkTemplateBoldDesc,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.watermarkTemplate,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: TeslaTheme.spacingSm),
        Row(
          children: styles.map((s) {
            final isSelected = settings.style == s.$1;
            return Expanded(
              child: GestureDetector(
                onTap: () => onStyleChanged(s.$1),
                child: Container(
                  margin: EdgeInsets.only(
                    right: s != styles.last ? TeslaTheme.spacingSm : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.15)
                        : Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        s.$2,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.$3,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: TeslaColors.graphite,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
