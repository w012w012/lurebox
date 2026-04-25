import 'package:flutter/material.dart';

import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/models/watermark_settings.dart';
import 'package:lurebox/widgets/common/premium_card.dart';

class WatermarkEnableSwitch extends StatelessWidget {

  const WatermarkEnableSwitch({
    required this.settings, required this.strings, required this.onToggle, super.key,
  });
  final WatermarkSettings settings;
  final AppStrings strings;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Row(
        children: [
          Icon(
            settings.enabled
                ? Icons.branding_watermark
                : Icons.branding_watermark_outlined,
            color: settings.enabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: TeslaTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.enableWatermark,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  settings.enabled
                      ? strings.watermarkPositionLabel
                      : strings.watermarkDisabled,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: settings.enabled,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}
