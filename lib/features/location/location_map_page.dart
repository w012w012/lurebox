import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../core/design/theme/app_colors.dart';
import '../../core/providers/location_map_view_model.dart';
import '../../core/models/fishing_location.dart';
import '../../core/constants/strings.dart';
import '../../core/providers/language_provider.dart';
import '../../widgets/common/premium_button.dart';

class LocationMapPage extends ConsumerStatefulWidget {
  const LocationMapPage({super.key});

  @override
  ConsumerState<LocationMapPage> createState() => _LocationMapPageState();
}

class _LocationMapPageState extends ConsumerState<LocationMapPage> {
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(35.6762, 139.6503);
  double _currentZoom = 10.0;
  FishingLocation? _selectedLocation;

  @override
  void initState() {
    super.initState();
    // Load locations without awaiting to avoid blocking UI
    ref.read(locationMapViewModelProvider.notifier).loadLocations();
    // Load user location (fire‑and‑forget) – any errors are handled inside
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    try {
      final permission = await Geolocator.checkPermission().timeout(
        const Duration(seconds: 5),
        onTimeout: () => LocationPermission.denied,
      );
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await Geolocator.requestPermission().timeout(
          const Duration(seconds: 5),
          onTimeout: () => LocationPermission.denied,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Location timeout'),
      );

      if (mounted) {
        ref
            .read(locationMapViewModelProvider.notifier)
            .setUserLocation(position.latitude, position.longitude);
        _animateToPosition(position.latitude, position.longitude, 12.0);
      }
    } catch (_) {}
  }

  void _animateToPosition(double lat, double lng, double zoom) {
    _currentCenter = LatLng(lat, lng);
    _currentZoom = zoom;
    _mapController.move(_currentCenter, _currentZoom);
  }

  void _centerOnUser() {
    final state = ref.read(locationMapViewModelProvider);
    if (state.userLatitude != null && state.userLongitude != null) {
      _animateToPosition(state.userLatitude!, state.userLongitude!, 14.0);
    } else {
      _loadUserLocation();
    }
  }

  void _showLocationDetails(FishingLocation location, AppStrings strings) {
    setState(() => _selectedLocation = location);
    _animateToPosition(location.latitude!, location.longitude!, 15.0);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _LocationDetailSheet(
        location: location,
        strings: strings,
        onClose: () {
          Navigator.pop(context);
          setState(() => _selectedLocation = null);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationMapViewModelProvider);
    final strings = ref.watch(currentStringsProvider);
    final locationsWithCoords = state.locations;

    return Scaffold(
      appBar: AppBar(title: Text(strings.mapLocation), centerTitle: true),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : locationsWithCoords.isEmpty
              ? _buildEmptyState(strings)
              : _buildMap(context, state, locationsWithCoords, strings),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PremiumFAB(
            key: const ValueKey('zoom_in'),
            tooltip: strings.zoomIn,
            mini: true,
            onPressed: () {
              final newZoom = (_currentZoom + 1).clamp(1.0, 18.0);
              _currentZoom = newZoom;
              _mapController.move(_currentCenter, _currentZoom);
            },
            icon: Icons.add,
          ),
          const SizedBox(height: 8),
          PremiumFAB(
            key: const ValueKey('zoom_out'),
            tooltip: strings.zoomOut,
            mini: true,
            onPressed: () {
              final newZoom = (_currentZoom - 1).clamp(1.0, 18.0);
              _currentZoom = newZoom;
              _mapController.move(_currentCenter, _currentZoom);
            },
            icon: Icons.remove,
          ),
          const SizedBox(height: 8),
          PremiumFAB(
            key: const ValueKey('center'),
            tooltip: strings.locateMe,
            onPressed: _centerOnUser,
            icon: Icons.my_location,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppStrings strings) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            strings.noLocationCoordinates,
            style: TextStyle(
              fontSize: 18,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.noLocationCoordinatesHint,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(
    BuildContext context,
    LocationMapState state,
    List<FishingLocation> locations,
    AppStrings strings,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentCenter,
        initialZoom: _currentZoom,
        onPositionChanged: (position, hasGesture) {
          if (hasGesture && position.center != null) {
            _currentCenter = position.center!;
            if (position.zoom != null) {
              _currentZoom = position.zoom!;
            }
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://wprd01.is.autonavi.com/appmaptile?style=7&x={x}&y={y}&z={z}',
          userAgentPackageName: 'com.example.lurebox',
          maxZoom: 18,
        ),
        MarkerLayer(
          markers: [
            if (state.userLatitude != null && state.userLongitude != null)
              Marker(
                point: LatLng(state.userLatitude!, state.userLongitude!),
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.info.withAlpha(77),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.info, width: 2),
                  ),
                  child:
                      const Icon(Icons.person, color: AppColors.info, size: 24),
                ),
              ),
            ...locations.map((location) {
              final isSelected = _selectedLocation?.id == location.id;
              return Marker(
                point: LatLng(location.latitude!, location.longitude!),
                width: isSelected ? 50 : 40,
                height: isSelected ? 50 : 40,
                child: GestureDetector(
                  onTap: () => _showLocationDetails(location, strings),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.warning : AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        width: isSelected ? 3 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(77),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
                      size: isSelected ? 30 : 24,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}

class _LocationDetailSheet extends StatelessWidget {
  final FishingLocation location;
  final AppStrings strings;
  final VoidCallback onClose;

  const _LocationDetailSheet({
    required this.location,
    required this.strings,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  location.name,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PremiumIconButton(icon: Icons.close, onPressed: onClose),
            ],
          ),
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.set_meal,
            label: strings.catchCount,
            value: '${location.fishCount}${strings.fishCountUnit}',
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.access_time,
            label: strings.lastVisit,
            value: location.lastVisit != null
                ? dateFormat.format(location.lastVisit!)
                : strings.noRecords,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.location_on,
            label: strings.coordinates,
            value: location.coordinateString,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: PremiumButton(
              onPressed: () {
                Navigator.pop(context);
                _openInMaps(context, location);
              },
              text: strings.navigate,
              icon: Icons.navigation,
              variant: PremiumButtonVariant.primary,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _openInMaps(
    BuildContext context,
    FishingLocation location,
  ) async {
    final lat = location.latitude!;
    final lng = location.longitude!;
    final name = Uri.encodeComponent(location.name);

    final appleMapsUrl = 'https://maps.apple.com/?ll=$lat,$lng&q=$name';
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    try {
      final appleUri = Uri.parse(appleMapsUrl);
      if (await canLaunchUrl(appleUri)) {
        await launchUrl(appleUri, mode: LaunchMode.externalApplication);
      } else {
        final googleUri = Uri.parse(googleMapsUrl);
        if (await canLaunchUrl(googleUri)) {
          await launchUrl(googleUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.cannotOpenMapApp)));
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }
}
