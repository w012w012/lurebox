import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';

import '../models/fishing_location.dart';
import '../services/database_service.dart';

class LocationMapState {
  final List<FishingLocation> locations;
  final FishingLocation? selectedLocation;
  final LatLng mapCenter;
  final double zoom;
  final LatLng? userLocation;
  final bool isLoading;
  final String? errorMessage;

  const LocationMapState({
    this.locations = const [],
    this.selectedLocation,
    this.mapCenter = const LatLng(35.6762, 139.6503),
    this.zoom = 10.0,
    this.userLocation,
    this.isLoading = false,
    this.errorMessage,
  });

  List<FishingLocation> get locationsWithCoordinates =>
      locations.where((loc) => loc.hasCoordinates).toList();

  double? get userLatitude => userLocation?.latitude;
  double? get userLongitude => userLocation?.longitude;

  LocationMapState copyWith({
    List<FishingLocation>? locations,
    FishingLocation? Function()? selectedLocation,
    LatLng? mapCenter,
    double? zoom,
    LatLng? Function()? userLocation,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return LocationMapState(
      locations: locations ?? this.locations,
      selectedLocation:
          selectedLocation != null ? selectedLocation() : this.selectedLocation,
      mapCenter: mapCenter ?? this.mapCenter,
      zoom: zoom ?? this.zoom,
      userLocation: userLocation != null ? userLocation() : this.userLocation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

class LocationMapViewModel extends StateNotifier<LocationMapState> {
  LocationMapViewModel() : super(const LocationMapState());

  Future<void> loadLocations() async {
    debugPrint('📍 Loading locations...');
    state = state.copyWith(isLoading: true, errorMessage: () => null);

    try {
      final db = await DatabaseService.database;
      final results = await db.rawQuery('''
SELECT
  location_name,
  latitude,
  longitude,
  COUNT(*) as fish_count,
  MAX(catch_time) as last_visit
FROM fish_catches
WHERE latitude IS NOT NULL
AND longitude IS NOT NULL
AND location_name IS NOT NULL
AND location_name != ''
GROUP BY location_name, latitude, longitude
ORDER BY fish_count DESC
''').timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⚠️ Database query timeout');
          return <Map<String, dynamic>>[];
        },
      );

      final locations = results.map((data) {
        return FishingLocation(
          id: '${data['location_name']}_${data['latitude']}_${data['longitude']}'
              .hashCode,
          name: data['location_name'] as String,
          latitude: (data['latitude'] as num).toDouble(),
          longitude: (data['longitude'] as num).toDouble(),
          fishCount: data['fish_count'] as int,
          lastVisit: data['last_visit'] != null
              ? DateTime.parse(data['last_visit'] as String)
              : null,
          createdAt: DateTime.now(),
        );
      }).toList();

      debugPrint('✅ Loaded ${locations.length} locations');
      state = state.copyWith(locations: locations, isLoading: false);
    } catch (e) {
      debugPrint('❌ Failed to load locations: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Failed to load locations: $e',
      );
    }
  }

  void selectLocation(int locationId) {
    final location =
        state.locations.where((loc) => loc.id == locationId).firstOrNull;
    state = state.copyWith(selectedLocation: () => location);

    if (location != null && location.hasCoordinates) {
      centerOnLocation(location.latitude!, location.longitude!);
    }
  }

  void centerOnLocation(double lat, double lng) {
    state = state.copyWith(mapCenter: LatLng(lat, lng), zoom: 15.0);
  }

  void centerOnUser() {
    if (state.userLocation != null) {
      state = state.copyWith(mapCenter: state.userLocation, zoom: 14.0);
    }
  }

  void updateZoom(double zoom) {
    state = state.copyWith(zoom: zoom.clamp(1.0, 18.0));
  }

  void setUserLocation(double lat, double lng) {
    state = state.copyWith(userLocation: () => LatLng(lat, lng));
  }

  void clearSelection() {
    state = state.copyWith(selectedLocation: () => null);
  }
}

final locationMapViewModelProvider =
    StateNotifierProvider<LocationMapViewModel, LocationMapState>(
  (ref) => LocationMapViewModel(),
);
