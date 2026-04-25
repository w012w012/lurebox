import 'package:flutter/material.dart';

import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/models/watermark_settings.dart';

class WatermarkPositionSelector extends StatelessWidget {

  const WatermarkPositionSelector({
    required this.settings, required this.strings, required this.onPositionChanged, super.key,
  });
  final WatermarkSettings settings;
  final AppStrings strings;
  final ValueChanged<WatermarkPosition> onPositionChanged;

  @override
  Widget build(BuildContext context) {
    final positions = [
      (
        WatermarkPosition.topLeft,
        strings.watermarkPositionTopLeftLabel,
        Icons.north_west,
      ),
      (
        WatermarkPosition.topRight,
        strings.watermarkPositionTopRightLabel,
        Icons.north_east,
      ),
      (
        WatermarkPosition.bottomLeft,
        strings.watermarkPositionBottomLeftLabel,
        Icons.south_west,
      ),
      (
        WatermarkPosition.bottomRight,
        strings.watermarkPositionBottomRightLabel,
        Icons.south_east,
      ),
      (
        WatermarkPosition.center,
        strings.watermarkPositionCenterLabel,
        Icons.center_focus_strong,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.watermarkPositionLabel,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: TeslaTheme.spacingSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: positions.map((pos) {
            final isSelected = settings.position == pos.$1;
            return GestureDetector(
              onTap: () => onPositionChanged(pos.$1),
              child: Container(
                padding: const EdgeInsets.all(TeslaTheme.spacingSm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      pos.$3,
                      size: 20,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pos.$2,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
