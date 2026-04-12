import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/constants.dart';
import '../../../core/constants/strings.dart';
import '../../../core/design/theme/app_colors.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/models/fish_catch.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/services/weather_service.dart';

String _buildRodDisplay(Map<String, dynamic>? rod, String displayUnit,
    {bool isChinese = true}) {
  if (rod == null) return '';
  final parts = <String>[];
  if (rod['brand'] != null && (rod['brand'] as String).isNotEmpty) {
    parts.add(rod['brand'] as String);
  }
  if (rod['model'] != null && (rod['model'] as String).isNotEmpty) {
    parts.add(rod['model'] as String);
  }
  if (rod['length'] != null && (rod['length'] as String).isNotEmpty) {
    final lengthStr = rod['length'] as String;
    final lengthValue = double.tryParse(lengthStr) ?? 0.0;
    final lengthUnit = rod['length_unit'] ?? 'm';
    if (lengthValue > 0) {
      final convertedLength = UnitConverter.convertLength(
        lengthValue,
        lengthUnit,
        displayUnit,
      );
      parts.add(
        '${convertedLength.toStringAsFixed(2)} ${UnitConverter.getLengthSymbol(displayUnit, isChinese: isChinese)}',
      );
    } else {
      parts.add(lengthStr);
    }
  }
  if (rod['hardness'] != null && (rod['hardness'] as String).isNotEmpty) {
    parts.add(rod['hardness'] as String);
  }
  if (rod['rod_action'] != null && (rod['rod_action'] as String).isNotEmpty) {
    parts.add(rod['rod_action'] as String);
  }
  return parts.join(' / ');
}

String _buildReelDisplay(Map<String, dynamic>? reel) {
  if (reel == null) return '';
  final parts = <String>[];
  if (reel['brand'] != null && (reel['brand'] as String).isNotEmpty) {
    parts.add(reel['brand'] as String);
  }
  if (reel['model'] != null && (reel['model'] as String).isNotEmpty) {
    parts.add(reel['model'] as String);
  }
  if (reel['reel_ratio'] != null && (reel['reel_ratio'] as String).isNotEmpty) {
    parts.add('${reel['reel_ratio']}');
  }
  return parts.join(' / ');
}

String _buildLureDisplay(Map<String, dynamic>? lure, String displayUnit,
    {bool isChinese = true}) {
  if (lure == null) return '';
  final parts = <String>[];
  if (lure['brand'] != null && (lure['brand'] as String).isNotEmpty) {
    parts.add(lure['brand'] as String);
  }
  if (lure['model'] != null && (lure['model'] as String).isNotEmpty) {
    parts.add(lure['model'] as String);
  }
  if (lure['lure_size'] != null && (lure['lure_size'] as String).isNotEmpty) {
    final sizeValue = double.tryParse(lure['lure_size'] as String) ?? 0;
    final sizeUnit = lure['lure_size_unit'] ?? 'cm';
    final convertedSize = UnitConverter.convertLength(
      sizeValue,
      sizeUnit,
      displayUnit,
    );
    parts.add(
        '${convertedSize.toStringAsFixed(1)} ${UnitConverter.getLengthSymbol(displayUnit, isChinese: isChinese)}');
  }
  if (lure['lure_color'] != null && (lure['lure_color'] as String).isNotEmpty) {
    parts.add(lure['lure_color'] as String);
  }
  return parts.join(' / ');
}

class FishInfoCard extends ConsumerWidget {
  final String species;
  final double length;
  final String lengthUnit;
  final double? weight;
  final String weightUnit;
  final int fate;
  final DateTime catchTime;
  final String? locationName;
  final Map<String, dynamic>? rodEquipment;
  final Map<String, dynamic>? reelEquipment;
  final Map<String, dynamic>? lureEquipment;
  final double? airTemperature;
  final double? pressure;
  final int? weatherCode;
  final AppStrings strings;

  const FishInfoCard({
    super.key,
    required this.species,
    required this.length,
    required this.lengthUnit,
    required this.weight,
    required this.weightUnit,
    required this.fate,
    required this.catchTime,
    required this.locationName,
    this.rodEquipment,
    this.reelEquipment,
    this.lureEquipment,
    this.airTemperature,
    this.pressure,
    this.weatherCode,
    required this.strings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider);
    final displayUnits = appSettings.units;
    final isChinese = appSettings.language == AppLanguage.chinese;

    final displayLength = UnitConverter.convertLength(
      length,
      lengthUnit,
      displayUnits.fishLengthUnit,
    );
    final displayWeight = weight != null
        ? UnitConverter.convertWeight(
            weight!,
            weightUnit,
            displayUnits.fishWeightUnit,
          )
        : null;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(
              icon: Icons.set_meal,
              label: strings.species,
              value: species,
              iconColor: AppColors.accentLight,
            ),
            _IOSDivider(),
            _InfoRow(
              icon: Icons.straighten,
              label: strings.length,
              value:
                  '${displayLength.toStringAsFixed(1)} ${UnitConverter.getLengthSymbol(displayUnits.fishLengthUnit, isChinese: isChinese)}',
              iconColor: AppColors.accentLight,
            ),
            if (displayWeight != null) ...[
              _IOSDivider(),
              _InfoRow(
                icon: Icons.scale,
                label: strings.weight,
                value:
                    '${displayWeight.toStringAsFixed(2)} ${UnitConverter.getWeightSymbol(displayUnits.fishWeightUnit, isChinese: isChinese)}',
                iconColor: AppColors.accentLight,
              ),
            ],
            _IOSDivider(),
            _InfoRow(
              icon: fate == FishFateType.release.value
                  ? Icons.water_drop
                  : Icons.restaurant,
              label: strings.fate,
              value: fate == FishFateType.release.value
                  ? '🐟 ${strings.release}'
                  : '🍳 ${strings.keep}',
              valueColor: fate == FishFateType.release.value
                  ? AppColors.release
                  : AppColors.keep,
              iconColor: AppColors.accentLight,
            ),
            _IOSDivider(),
            _InfoRow(
              icon: Icons.access_time,
              label: strings.catchTime,
              value: DateFormat(DateFormats.dateTime).format(catchTime),
              iconColor: AppColors.accentLight,
            ),
            if (locationName != null && locationName!.isNotEmpty) ...[
              _IOSDivider(),
              _InfoRow(
                icon: Icons.location_on,
                label: strings.catchLocation,
                value: locationName!,
                iconColor: AppColors.accentLight,
              ),
            ],
            if (airTemperature != null ||
                pressure != null ||
                weatherCode != null) ...[
              _IOSDivider(),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  '天气信息',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              if (airTemperature != null)
                _InfoRow(
                  icon: Icons.thermostat,
                  label: '气温',
                  value: UnitConverter.formatTemperature(
                    airTemperature!,
                    displayUnits.temperatureUnit,
                    isChinese: isChinese,
                  ),
                  iconColor: AppColors.accentLight,
                ),
              if (pressure != null)
                _InfoRow(
                  icon: Icons.speed,
                  label: '气压',
                  value: '${pressure!.toStringAsFixed(0)}hPa',
                  iconColor: AppColors.accentLight,
                ),
              if (weatherCode != null)
                _InfoRow(
                  icon: Icons.wb_sunny,
                  label: '天气',
                  value: getWeatherDescription(weatherCode),
                  iconColor: AppColors.accentLight,
                ),
            ],
            if (rodEquipment != null ||
                reelEquipment != null ||
                lureEquipment != null) ...[
              _IOSDivider(),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  strings.useEquipment,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              if (rodEquipment != null)
                _EquipmentInfoRow(
                  label: strings.rod,
                  value: _buildRodDisplay(
                    rodEquipment,
                    displayUnits.rodLengthUnit,
                    isChinese: isChinese,
                  ),
                ),
              if (reelEquipment != null)
                _EquipmentInfoRow(
                  label: strings.reel,
                  value: _buildReelDisplay(reelEquipment),
                ),
              if (lureEquipment != null)
                _EquipmentInfoRow(
                  label: strings.lure,
                  value: _buildLureDisplay(
                    lureEquipment,
                    displayUnits.lureLengthUnit,
                    isChinese: isChinese,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Color? iconColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor ?? AppColors.accentLight, size: 24),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}

class _IOSDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: AppColors.borderLight),
    );
  }
}

class _EquipmentInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _EquipmentInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
