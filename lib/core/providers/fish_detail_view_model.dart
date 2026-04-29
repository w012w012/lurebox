import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/services/equipment_service.dart';
import 'package:lurebox/core/services/error_service.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';

class FishDetailState {
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
  final bool isLoading;
  final String? errorMessage;
  final FishCatch? fish;
  final Equipment? rodEquipment;
  final Equipment? reelEquipment;
  final Equipment? lureEquipment;
  final bool isDeleting;
  final bool isSharing;

  FishDetailState copyWith({
    bool? isLoading,
    String? Function()? errorMessage,
    FishCatch? fish,
    Equipment? rodEquipment,
    Equipment? reelEquipment,
    Equipment? lureEquipment,
    bool? isDeleting,
    bool? isSharing,
  }) {
    return FishDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
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
  FishDetailViewModel(
    this.fishId,
    this._fishCatchService,
    this._equipmentService,
  ) : super(const FishDetailState()) {
    loadFish();
  }
  final int fishId;
  final FishCatchService _fishCatchService;
  final EquipmentService _equipmentService;

  Future<void> loadFish() async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);

    try {
      final fishModel = await _fishCatchService.getById(fishId);
      if (!mounted) return;
      if (fishModel == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: () => 'Fish not found',
        );
        return;
      }

      final rodId = fishModel.rodId;
      final reelId = fishModel.reelId;
      final lureId = fishModel.lureId;

      Equipment? rodEquipment;
      Equipment? reelEquipment;
      Equipment? lureEquipment;

      final futures = <Future<Equipment?>>[];
      final futureLabels = <String>[];
      if (rodId != null) {
        futures.add(_equipmentService.getById(rodId));
        futureLabels.add('rod');
      }
      if (reelId != null) {
        futures.add(_equipmentService.getById(reelId));
        futureLabels.add('reel');
      }
      if (lureId != null) {
        futures.add(_equipmentService.getById(lureId));
        futureLabels.add('lure');
      }

      if (futures.isNotEmpty) {
        final results = await Future.wait(futures);
        if (!mounted) return;
        for (var i = 0; i < results.length; i++) {
          switch (futureLabels[i]) {
            case 'rod':
              rodEquipment = results[i];
            case 'reel':
              reelEquipment = results[i];
            case 'lure':
              lureEquipment = results[i];
          }
        }
      }

      if ((rodId == null && reelId == null && lureId == null) &&
          fishModel.equipmentId != null) {
        final equipmentId = fishModel.equipmentId!;
        final eq = await _equipmentService.getById(equipmentId);
        if (!mounted) return;
        if (eq != null) {
          final type = eq.type;
          if (type == EquipmentType.rod) {
            rodEquipment = eq;
          } else if (type == EquipmentType.reel) {
            reelEquipment = eq;
          } else if (type == EquipmentType.lure) {
            lureEquipment = eq;
          }
        }
      }

      state = state.copyWith(
        isLoading: false,
        fish: fishModel,
        rodEquipment: rodEquipment,
        reelEquipment: reelEquipment,
        lureEquipment: lureEquipment,
      );
    } on Exception catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: () => ErrorService.toUserMessage(e));
    }
  }

  Future<bool> deleteFish() async {
    state = state.copyWith(isDeleting: true);
    try {
      await _fishCatchService.delete(fishId);
      if (!mounted) return true;
      state = state.copyWith(isDeleting: false);
      return true;
    } on Exception catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isDeleting: false, errorMessage: () => ErrorService.toUserMessage(e));
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
