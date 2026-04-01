import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';
import '../di/di.dart';

class LocationGroup {
  final String representative;
  final List<String> locations;

  const LocationGroup({required this.representative, required this.locations});
}

class LocationManagementState {
  final bool isLoading;
  final String? errorMessage;
  final List<Map<String, dynamic>> locations;
  final List<LocationGroup> locationGroups;
  final Set<String> selectedLocations;
  final bool isMerging;
  final String? mergeTargetName;

  const LocationManagementState({
    this.isLoading = true,
    this.errorMessage,
    this.locations = const [],
    this.locationGroups = const [],
    this.selectedLocations = const {},
    this.isMerging = false,
    this.mergeTargetName,
  });

  LocationManagementState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Map<String, dynamic>>? locations,
    List<LocationGroup>? locationGroups,
    Set<String>? selectedLocations,
    bool? isMerging,
    String? mergeTargetName,
  }) {
    return LocationManagementState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      locations: locations ?? this.locations,
      locationGroups: locationGroups ?? this.locationGroups,
      selectedLocations: selectedLocations ?? this.selectedLocations,
      isMerging: isMerging ?? this.isMerging,
      mergeTargetName: mergeTargetName ?? this.mergeTargetName,
    );
  }
}

class LocationManagementViewModel
    extends StateNotifier<LocationManagementState> {
  final LocationService _locationService;

  LocationManagementViewModel(this._locationService)
      : super(const LocationManagementState()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final locations = await _locationService.getAllLocations();

      final locationNames =
          locations.map((l) => l['location_name'] as String).toList();
      final similarGroups = _locationService.findSimilarLocations(
        locationNames,
      );

      final groups = similarGroups.map((list) {
        return LocationGroup(
          representative: _locationService.getBestLocationName(list),
          locations: list,
        );
      }).toList();

      state = state.copyWith(
        isLoading: false,
        locations: locations,
        locationGroups: groups,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void toggleSelection(String locationName) {
    final newSet = Set<String>.from(state.selectedLocations);
    if (newSet.contains(locationName)) {
      newSet.remove(locationName);
    } else {
      newSet.add(locationName);
    }
    state = state.copyWith(selectedLocations: newSet);
  }

  void clearSelection() {
    state = state.copyWith(selectedLocations: {});
  }

  void selectAll() {
    final allNames =
        state.locations.map((l) => l['location_name'] as String).toSet();
    state = state.copyWith(selectedLocations: allNames);
  }

  void setMergeTarget(String name) {
    state = state.copyWith(mergeTargetName: name);
  }

  Future<bool> mergeLocations(String targetName) async {
    if (state.selectedLocations.length < 2) return false;

    state = state.copyWith(isMerging: true, errorMessage: null);
    try {
      await _locationService.mergeLocations(
        state.selectedLocations.toList(),
        targetName,
      );
      state = state.copyWith(isMerging: false, selectedLocations: {});
      await loadData();
      return true;
    } catch (e) {
      state = state.copyWith(isMerging: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> autoMergeGroup(LocationGroup group) async {
    if (group.locations.length < 2) return false;

    state = state.copyWith(isMerging: true, errorMessage: null);
    try {
      await _locationService.mergeLocations(
        group.locations,
        group.representative,
      );
      await loadData();
      state = state.copyWith(isMerging: false);
      return true;
    } catch (e) {
      state = state.copyWith(isMerging: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> renameLocation(String oldName, String newName) async {
    if (oldName.isEmpty || newName.isEmpty || oldName == newName) return false;

    state = state.copyWith(isMerging: true, errorMessage: null);
    try {
      await _locationService.renameLocation(oldName, newName);
      state = state.copyWith(isMerging: false);
      await loadData();
      return true;
    } catch (e) {
      state = state.copyWith(isMerging: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> refresh() => loadData();
}

final locationManagementViewModelProvider =
    StateNotifierProvider<LocationManagementViewModel, LocationManagementState>(
  (ref) => LocationManagementViewModel(ref.read(locationServiceProvider)),
);
