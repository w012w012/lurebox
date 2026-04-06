import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/di.dart';
import '../models/species_profile.dart';
import '../services/fish_catch_service.dart';
import '../services/equipment_service.dart';
import '../services/species_profile_service.dart';

class FishDetailState {
  final bool isLoading;
  final String? errorMessage;
  final Map<String, dynamic>? fish;
  final Map<String, dynamic>? rodEquipment;
  final Map<String, dynamic>? reelEquipment;
  final Map<String, dynamic>? lureEquipment;
  final SpeciesProfile? speciesProfile;
  final bool isDeleting;
  final bool isSharing;

  const FishDetailState({
    this.isLoading = true,
    this.errorMessage,
    this.fish,
    this.rodEquipment,
    this.reelEquipment,
    this.lureEquipment,
    this.speciesProfile,
    this.isDeleting = false,
    this.isSharing = false,
  });

  FishDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    Map<String, dynamic>? fish,
    Map<String, dynamic>? rodEquipment,
    Map<String, dynamic>? reelEquipment,
    Map<String, dynamic>? lureEquipment,
    SpeciesProfile? speciesProfile,
    bool? isDeleting,
    bool? isSharing,
  }) {
    return FishDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      fish: fish ?? this.fish,
      rodEquipment: rodEquipment ?? this.rodEquipment,
      reelEquipment: reelEquipment ?? this.reelEquipment,
      lureEquipment: lureEquipment ?? this.lureEquipment,
      speciesProfile: speciesProfile ?? this.speciesProfile,
      isDeleting: isDeleting ?? this.isDeleting,
      isSharing: isSharing ?? this.isSharing,
    );
  }
}

class FishDetailViewModel extends StateNotifier<FishDetailState> {
  final int fishId;
  final FishCatchService _fishCatchService;
  final EquipmentService _equipmentService;
  final SpeciesProfileService _speciesProfileService;

  FishDetailViewModel(
    this.fishId,
    this._fishCatchService,
    this._equipmentService,
    this._speciesProfileService,
  ) : super(const FishDetailState()) {
    loadFish();
  }

  Future<void> loadFish() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final fishModel = await _fishCatchService.getById(fishId);
      if (fishModel == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Fish not found',
        );
        return;
      }
      final fish = fishModel.toMap();

      final rodId = fish['rod_id'] as int?;
      final reelId = fish['reel_id'] as int?;
      final lureId = fish['lure_id'] as int?;

      Map<String, dynamic>? rodEquipment;
      Map<String, dynamic>? reelEquipment;
      Map<String, dynamic>? lureEquipment;

      if (rodId != null) {
        final eq = await _equipmentService.getById(rodId);
        rodEquipment = eq?.toMap();
      }
      if (reelId != null) {
        final eq = await _equipmentService.getById(reelId);
        reelEquipment = eq?.toMap();
      }
      if (lureId != null) {
        final eq = await _equipmentService.getById(lureId);
        lureEquipment = eq?.toMap();
      }

      if ((rodId == null && reelId == null && lureId == null) &&
          fish['equipment_id'] != null) {
        final equipmentId = fish['equipment_id'] as int;
        final eq = await _equipmentService.getById(equipmentId);
        if (eq != null) {
          final equipment = eq.toMap();
          final type = equipment['type'] as String;
          if (type == 'rod') {
            rodEquipment = equipment;
          } else if (type == 'reel') {
            reelEquipment = equipment;
          } else if (type == 'lure') {
            lureEquipment = equipment;
          }
        }
      }

      // Load species profile based on species name
      SpeciesProfile? speciesProfile;
      final speciesName = fish['species'] as String?;
      if (speciesName != null && speciesName.isNotEmpty) {
        // First try to find by exact species name through fish_species lookup
        speciesProfile =
            await _speciesProfileService.getBySpeciesName(speciesName);
        // If not found, try to find by aliases or partial match
        speciesProfile ??= await _findSpeciesProfileByName(speciesName);
      }

      state = state.copyWith(
        isLoading: false,
        fish: fish,
        rodEquipment: rodEquipment,
        reelEquipment: reelEquipment,
        lureEquipment: lureEquipment,
        speciesProfile: speciesProfile,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Find species profile by name, trying various matching strategies
  Future<SpeciesProfile?> _findSpeciesProfileByName(String speciesName) async {
    final allProfiles = await _speciesProfileService.getAll();
    final lowerName = speciesName.toLowerCase();

    for (final profile in allProfiles) {
      // Match by aliases (comma-separated list)
      if (profile.aliases != null) {
        final aliases = profile.aliases!.toLowerCase().split(',');
        for (final alias in aliases) {
          if (alias.trim() == lowerName) {
            return profile;
          }
        }
      }
    }

    // Try partial match
    for (final profile in allProfiles) {
      if (profile.aliases != null &&
          profile.aliases!.toLowerCase().contains(lowerName)) {
        return profile;
      }
      if (profile.speciesId.toLowerCase() == lowerName) {
        return profile;
      }
    }

    return null;
  }

  Future<bool> deleteFish() async {
    state = state.copyWith(isDeleting: true);
    try {
      await _fishCatchService.delete(fishId);
      return true;
    } catch (e) {
      state = state.copyWith(isDeleting: false, errorMessage: e.toString());
      return false;
    }
  }

  void setSharing(bool value) {
    state = state.copyWith(isSharing: value);
  }

  Future<void> refresh() => loadFish();
}

final fishDetailViewModelProvider =
    StateNotifierProvider.family<FishDetailViewModel, FishDetailState, int>(
  (ref, fishId) => FishDetailViewModel(
    fishId,
    ref.read(fishCatchServiceProvider),
    ref.read(equipmentServiceProvider),
    ref.read(speciesProfileServiceProvider),
  ),
);
