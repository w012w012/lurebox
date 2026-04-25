import 'package:flutter/material.dart';

import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';

class WatermarkColorSelector extends StatelessWidget {

  const WatermarkColorSelector({
    required this.selectedColor, required this.strings, required this.onColorChanged, super.key,
  });
  final int selectedColor;
  final AppStrings strings;
  final ValueChanged<int> onColorChanged;

  @override
  Widget build(BuildContext context) {
    final colors = [
      (0xFFFFFFFF, strings.watermarkColorWhite),
      (0xFF000000, strings.watermarkColorBlack),
      (0xFFFF0000, strings.watermarkColorRed),
      (0xFF00FF00, strings.watermarkColorGreen),
      (0xFF0000FF, strings.watermarkColorBlue),
      (0xFFFFFF00, strings.watermarkColorYellow),
      (0xFFFF00FF, strings.watermarkColorPurple),
      (0xFF00FFFF, strings.watermarkColorCyan),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.watermarkFontColor,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: TeslaTheme.spacingSm),
        Wrap(
          spacing: TeslaTheme.spacingSm,
          runSpacing: TeslaTheme.spacingSm,
          children: colors.map((color) {
            final isSelected = selectedColor == color.$1;
            return GestureDetector(
              onTap: () => onColorChanged(color.$1),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(color.$1),
                  borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: color.$1 == 0xFF000000
                            ? Colors.white
                            : Colors.black,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
