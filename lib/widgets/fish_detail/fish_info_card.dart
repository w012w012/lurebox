import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/constants.dart';
import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/models/fish_catch.dart';
import '../../core/providers/app_settings_provider.dart';
import '../../core/utils/unit_converter.dart';
import '../../core/services/weather_service.dart';

String _buildRodDisplay(Map<String, dynamic>? rod, String displayUnit) {
  if (rod == null) return '';
  final parts = <String>[];
  if (rod['brand'] != null && (rod['brand'] as String).isNotEmpty)
    parts.add(rod['brand'] as String);
  if (rod['model'] != null && (rod['model'] as String).isNotEmpty)
    parts.add(rod['model'] as String);
  if (rod['length'] != null && (rod['length'] as String).isNotEmpty) {
    final lengthStr = rod['length'] as String;
    final lengthValue = double.tryParse(lengthStr) ?? 0.0;
    final lengthUnit = rod['length_unit'] ?? 'm';
    if (lengthValue > 0) {
      // 直接使用存储的单位显示，保留 2 位小数
      parts.add('${lengthValue.toStringAsFixed(2)} $lengthUnit');
    } else {
      parts.add(lengthStr);
    }
  }
  if (rod['hardness'] != null && (rod['hardness'] as String).isNotEmpty)
    parts.add(rod['hardness'] as String);
  if (rod['rod_action'] != null && (rod['rod_action'] as String).isNotEmpty)
    parts.add(rod['rod_action'] as String);
  return parts.join(' / ');
}

String _buildReelDisplay(Map<String, dynamic>? reel) {
  if (reel == null) return '';
  final parts = <String>[];
  if (reel['brand'] != null && (reel['brand'] as String).isNotEmpty)
    parts.add(reel['brand'] as String);
  if (reel['model'] != null && (reel['model'] as String).isNotEmpty)
    parts.add(reel['model'] as String);
  if (reel['reel_ratio'] != null && (reel['reel_ratio'] as String).isNotEmpty)
    parts.add('${reel['reel_ratio']}');
  return parts.join(' / ');
}

String _buildLureDisplay(Map<String, dynamic>? lure, String displayUnit) {
  if (lure == null) return '';
  final parts = <String>[];
  if (lure['brand'] != null && (lure['brand'] as String).isNotEmpty)
    parts.add(lure['brand'] as String);
  if (lure['model'] != null && (lure['model'] as String).isNotEmpty)
    parts.add(lure['model'] as String);
  if (lure['lure_size'] != null && (lure['lure_size'] as String).isNotEmpty) {
    final sizeValue = double.tryParse(lure['lure_size'] as String ?? '') ?? 0;
    final sizeUnit = lure['lure_size_unit'] ?? 'cm';
    final convertedSize = UnitConverter.convertLength(
      sizeValue,
      sizeUnit,
      displayUnit,
    );
    parts.add('${convertedSize.toStringAsFixed(1)} $displayUnit');
  }
  if (lure['lure_color'] != null && (lure['lure_color'] as String).isNotEmpty)
    parts.add(lure['lure_color'] as String);
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            icon: Icons.set_meal,
            label: strings.species,
            value: species,
          ),
          const Divider(height: 24),
          _InfoRow(
            icon: Icons.straighten,
            label: strings.length,
            value:
                '${displayLength.toStringAsFixed(1)} ${UnitConverter.getLengthSymbol(displayUnits.fishLengthUnit)}',
          ),
          if (displayWeight != null) ...[
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.scale,
              label: strings.weight,
              value:
                  '${displayWeight.toStringAsFixed(2)} ${UnitConverter.getWeightSymbol(displayUnits.fishWeightUnit)}',
            ),
          ],
          const Divider(height: 24),
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
          ),
          const Divider(height: 24),
          _InfoRow(
            icon: Icons.access_time,
            label: strings.catchTime,
            value: DateFormat(DateFormats.dateTime).format(catchTime),
          ),
          if (locationName != null && locationName!.isNotEmpty) ...[
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.location_on,
              label: strings.catchLocation,
              value: locationName!,
            ),
          ],
          if (airTemperature != null ||
              pressure != null ||
              weatherCode != null) ...[
            const Divider(height: 24),
            Text(
              '天气信息',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (airTemperature != null)
              _InfoRow(
                icon: Icons.thermostat,
                label: '气温',
                value: '${airTemperature!.toStringAsFixed(1)}°C',
              ),
            if (pressure != null)
              _InfoRow(
                icon: Icons.speed,
                label: '气压',
                value: '${pressure!.toStringAsFixed(0)}hPa',
              ),
            if (weatherCode != null)
              _InfoRow(
                icon: Icons.wb_sunny,
                label: '天气',
                value: getWeatherDescription(weatherCode),
              ),
          ],
          if (rodEquipment != null ||
              reelEquipment != null ||
              lureEquipment != null) ...[
            const Divider(height: 24),
            Text(
              strings.useEquipment,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (rodEquipment != null)
              _EquipmentInfoRow(
                label: strings.rod,
                value: _buildRodDisplay(
                  rodEquipment,
                  displayUnits.rodLengthUnit,
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
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
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
