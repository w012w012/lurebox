import 'package:flutter/material.dart';

import '../../../core/constants/strings.dart';
import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/tesla_theme.dart';
import '../../../core/models/watermark_settings.dart';
import '../../../widgets/common/premium_card.dart';
import '../../common/watermarked_image.dart';

class WatermarkPreviewCard extends StatelessWidget {
  final WatermarkSettings settings;
  final AppStrings strings;

  const WatermarkPreviewCard({
    super.key,
    required this.settings,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: TeslaTheme.spacingSm),
              Text(
                strings.watermarkPreview,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: TeslaTheme.spacingSm),
          _LiveWatermarkPreview(settings: settings, strings: strings),
          const SizedBox(height: TeslaTheme.spacingSm),
          Text(
            _getPositionDesc(settings.position, strings),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: TeslaColors.graphite),
          ),
        ],
      ),
    );
  }

  String _getPositionDesc(WatermarkPosition position, AppStrings strings) {
    return switch (position) {
      WatermarkPosition.topLeft => strings.watermarkPositionTopLeft,
      WatermarkPosition.topRight => strings.watermarkPositionTopRight,
      WatermarkPosition.bottomLeft => strings.watermarkPositionBottomLeft,
      WatermarkPosition.bottomRight => strings.watermarkPositionBottomRight,
      WatermarkPosition.center => strings.watermarkPositionCenter,
    };
  }
}

class _LiveWatermarkPreview extends StatelessWidget {
  final WatermarkSettings settings;
  final AppStrings strings;

  const _LiveWatermarkPreview({
    required this.settings,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CustomPaint(
          painter: _WatermarkPreviewPainter(
            settings: settings,
            strings: strings,
          ),
          child: Container(),
        ),
      ),
    );
  }
}

class _WatermarkPreviewPainter extends CustomPainter {
  final WatermarkSettings settings;
  final AppStrings strings;

  _WatermarkPreviewPainter({
    required this.settings,
    required this.strings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2E7D6A),
          Color(0xFF1565C0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    if (!settings.enabled) return;

    final painter = _buildWatermarkPainter(size, strings);
    painter.paint(canvas, size);
  }

  WatermarkPainter _buildWatermarkPainter(Size size, AppStrings strings) {
    const length = 52.0;
    const airTemperature = 25.0;
    const pressure = 1013.0;
    const weatherCode = 0;
    const displayLength = 52.0;
    const displayWeight = 1.2;
    const displayLengthUnit = 'cm';
    const displayWeightUnit = 'kg';
    const displayTemperatureUnit = 'C';

    final previewSettings = WatermarkSettings(
      enabled: true,
      style: settings.style,
      infoTypes: settings.infoTypes,
      blurRadius: settings.blurRadius,
      backgroundOpacity: settings.backgroundOpacity,
      backgroundColor: settings.backgroundColor,
      fontSize: settings.fontSize * (size.width / 400).clamp(0.5, 1.5),
      textColor: settings.textColor,
      position: settings.position,
      customText: settings.customText,
    );

    return WatermarkPainter(
      species: strings.watermarkPreviewSpecies,
      length: length,
      locationName: strings.watermarkPreviewLocation,
      airTemperature: airTemperature,
      pressure: pressure,
      weatherCode: weatherCode,
      settings: previewSettings,
      strings: strings,
      displayLength: displayLength,
      displayWeight: displayWeight,
      displayLengthUnit: displayLengthUnit,
      displayWeightUnit: displayWeightUnit,
      displayTemperatureUnit: displayTemperatureUnit,
    );
  }

  @override
  bool shouldRepaint(covariant _WatermarkPreviewPainter oldDelegate) {
    return settings != oldDelegate.settings ||
        strings != oldDelegate.strings;
  }
}
