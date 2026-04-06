import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/di.dart';
import '../services/fish_catch_service.dart';
import '../services/equipment_service.dart';

class FishDetailState {
  final bool isLoading;
  final String? errorMessage;
  final Map<String, dynamic>? fish;
  final Map<String, dynamic>? rodEquipment;
  final Map<String, dynamic>? reelEquipment;
  final Map<String, dynamic>? lureEquipment;
  final bool isDeleting;
  final bool isSharing;

  const FishDetailState({
    this.isLoading = true,
    this.errorMessage,
    this.fish,
    this.rodEquipment,
    this.reelEquipment,
    this.lureEquipment,
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
      isDeleting: isDeleting ?? this.isDeleting,
      isSharing: isSharing ?? this.isSharing,
    );
  }
}

class FishDetailViewModel extends StateNotifier<FishDetailState> {
  final int fishId;
  final FishCatchService _fishCatchService;
  final EquipmentService _equipmentService;

  FishDetailViewModel(
    this.fishId,
    this._fishCatchService,
    this._equipmentService,
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

      state = state.copyWith(
        isLoading: false,
        fish: fish,
        rodEquipment: rodEquipment,
        reelEquipment: reelEquipment,
        lureEquipment: lureEquipment,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
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
  ),
);
