import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/constants.dart';
import '../../core/constants/strings.dart';
import '../../core/camera/camera_state.dart';
import '../../core/camera/camera_view_model.dart';
import '../../core/services/weather_service.dart';

/// An expanded info row displaying location, weather, and time.
/// Each item is displayed in a card-like container with clear icon and text.
class AuxiliaryInfoRow extends StatelessWidget {
  final CameraState state;
  final CameraViewModel vm;
  final AppStrings strings;
  final VoidCallback? onEditLocation;
  final VoidCallback? onEditTime;
  final VoidCallback? onEditWeather;

  const AuxiliaryInfoRow({
    super.key,
    required this.state,
    required this.vm,
    required this.strings,
    this.onEditLocation,
    this.onEditTime,
    this.onEditWeather,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Location row
            _buildInfoRow(
              context: context,
              icon: Icons.location_on,
              label: '地址',
              text: state.locationName?.isNotEmpty == true
                  ? state.locationName!
                  : '点击设置',
              onTap: onEditLocation,
            ),
            const Divider(height: 16),
            // Weather row
            _buildInfoRow(
              context: context,
              icon: Icons.wb_sunny,
              label: '天气',
              text: _getWeatherText(),
              onTap: onEditWeather,
            ),
            const Divider(height: 16),
            // Time row
            _buildInfoRow(
              context: context,
              icon: Icons.access_time,
              label: '时间',
              text: state.catchTime != null
                  ? DateFormat(DateFormats.dateTime).format(state.catchTime!)
                  : '点击设置',
              onTap: onEditTime,
            ),
          ],
        ),
      ),
    );
  }

  String _getWeatherText() {
    final parts = <String>[];
    if (state.weatherCode != null) {
      final weatherDesc = getWeatherDescription(state.weatherCode);
      if (weatherDesc.isNotEmpty) {
        parts.add(weatherDesc);
      }
    }
    if (state.airTemperature != null) {
      parts.add('${state.airTemperature!.toStringAsFixed(1)}°C');
    }
    if (parts.isEmpty) return '点击设置';
    return parts.join(' · ');
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String text,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.end,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
