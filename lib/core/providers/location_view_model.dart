import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/services/error_service.dart';
import 'package:lurebox/core/services/location_service.dart';

class LocationGroup {

  const LocationGroup({required this.representative, required this.locations});
  final String representative;
  final List<String> locations;
}

class LocationManagementState {

  const LocationManagementState({
    this.isLoading = true,
    this.errorMessage,
    this.locations = const [],
    this.locationGroups = const [],
    this.selectedLocations = const {},
    this.isMerging = false,
    this.mergeTargetName,
  });
  final bool isLoading;
  final String? errorMessage;
  final List<Map<String, dynamic>> locations;
  final List<LocationGroup> locationGroups;
  final Set<String> selectedLocations;
  final bool isMerging;
  final String? mergeTargetName;

  LocationManagementState copyWith({
    bool? isLoading,
    String? Function()? errorMessage,
    List<Map<String, dynamic>>? locations,
    List<LocationGroup>? locationGroups,
    Set<String>? selectedLocations,
    bool? isMerging,
    String? mergeTargetName,
  }) {
    return LocationManagementState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
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

  LocationManagementViewModel(this._locationService)
      : super(const LocationManagementState()) {
    loadData();
  }
  final LocationService _locationService;

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final locations = await _locationService.getAllLocations();
      if (!mounted) return;

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
    } on Exception catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: () => ErrorService.toUserMessage(e));
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

    state = state.copyWith(isMerging: true, errorMessage: () => null);
    try {
      await _locationService.mergeLocations(
        state.selectedLocations.toList(),
        targetName,
      );
      if (!mounted) return true;
      state = state.copyWith(isMerging: false, selectedLocations: {});
      await loadData();
      return true;
    } on Exception catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isMerging: false, errorMessage: () => ErrorService.toUserMessage(e));
      return false;
    }
  }

  Future<bool> autoMergeGroup(LocationGroup group) async {
    if (group.locations.length < 2) return false;

    state = state.copyWith(isMerging: true, errorMessage: () => null);
    try {
      await _locationService.mergeLocations(
        group.locations,
        group.representative,
      );
      if (!mounted) return true;
      await loadData();
      state = state.copyWith(isMerging: false);
      return true;
    } on Exception catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isMerging: false, errorMessage: () => ErrorService.toUserMessage(e));
      return false;
    }
  }

  Future<bool> renameLocation(String oldName, String newName) async {
    if (oldName.isEmpty || newName.isEmpty || oldName == newName) return false;

    state = state.copyWith(isMerging: true, errorMessage: () => null);
    try {
      await _locationService.renameLocation(oldName, newName);
      if (!mounted) return true;
      state = state.copyWith(isMerging: false);
      await loadData();
      return true;
    } on Exception catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isMerging: false, errorMessage: () => ErrorService.toUserMessage(e));
      return false;
    }
  }

  Future<void> refresh() => loadData();
}

final locationManagementViewModelProvider =
    StateNotifierProvider<LocationManagementViewModel, LocationManagementState>(
  (ref) => LocationManagementViewModel(ref.read(locationServiceProvider)),
);
