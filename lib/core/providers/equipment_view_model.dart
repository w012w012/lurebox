import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/services/equipment_service.dart';
import 'package:lurebox/core/services/error_service.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';

class EquipmentListState {

  const EquipmentListState({
    this.isLoading = true,
    this.errorMessage,
    this.rodList = const [],
    this.reelList = const [],
    this.lureList = const [],
    this.equipmentStats = const {},
    this.selectedType = 'rod',
    this.allExpanded = true,
    this.expandedId,
  });
  final bool isLoading;
  final String? errorMessage;
  final List<Equipment> rodList;
  final List<Equipment> reelList;
  final List<Equipment> lureList;
  final Map<int, Map<String, int>> equipmentStats;
  final String selectedType;
  final bool allExpanded;
  final int? expandedId;

  EquipmentListState copyWith({
    bool? isLoading,
    String? Function()? errorMessage,
    List<Equipment>? rodList,
    List<Equipment>? reelList,
    List<Equipment>? lureList,
    Map<int, Map<String, int>>? equipmentStats,
    String? selectedType,
    bool? allExpanded,
    int? expandedId,
  }) {
    return EquipmentListState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      rodList: rodList ?? this.rodList,
      reelList: reelList ?? this.reelList,
      lureList: lureList ?? this.lureList,
      equipmentStats: equipmentStats ?? this.equipmentStats,
      selectedType: selectedType ?? this.selectedType,
      allExpanded: allExpanded ?? this.allExpanded,
      expandedId: expandedId,
    );
  }

  List<Equipment> get currentList {
    switch (selectedType) {
      case 'rod':
        return rodList;
      case 'reel':
        return reelList;
      case 'lure':
        return lureList;
      default:
        return [];
    }
  }
}

class EquipmentListViewModel extends StateNotifier<EquipmentListState> {

  EquipmentListViewModel(this._equipmentService, this._fishCatchService)
      : super(const EquipmentListState()) {
    loadData();
  }
  final EquipmentService _equipmentService;
  final FishCatchService _fishCatchService;

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final results = await Future.wait([
        _equipmentService.getAll(type: 'rod'),
        _equipmentService.getAll(type: 'reel'),
        _equipmentService.getAll(type: 'lure'),
        _fishCatchService.getAllEquipmentCatchStats(),
      ]);
      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        rodList: results[0] as List<Equipment>,
        reelList: results[1] as List<Equipment>,
        lureList: results[2] as List<Equipment>,
        equipmentStats: (results[3] as Map).cast<int, Map<String, int>>(),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: () => ErrorService.toUserMessage(e));
    }
  }

  void setSelectedType(String type) {
    state = state.copyWith(selectedType: type);
  }

  void toggleExpanded(int id) {
    if (state.expandedId == id) {
      state = state.copyWith();
    } else {
      state = state.copyWith(expandedId: id);
    }
  }

  void setAllExpanded(bool expanded) {
    state = state.copyWith(allExpanded: expanded);
  }

  Future<void> deleteEquipment(int id) async {
    try {
      await _equipmentService.delete(id);
      if (!mounted) return;
      await loadData();
    } on Exception catch (e) {
      if (!mounted) return;
      state = state.copyWith(errorMessage: () => ErrorService.toUserMessage(e));
    }
  }

  Future<void> refresh() => loadData();

  Future<void> setDefaultEquipment(int id, String type) async {
    try {
      await _equipmentService.setDefaultEquipment(id, type);
      if (!mounted) return;
      await loadData();
    } on Exception catch (e) {
      if (!mounted) return;
      state = state.copyWith(errorMessage: () => ErrorService.toUserMessage(e));
    }
  }
}

final equipmentListViewModelProvider =
    StateNotifierProvider<EquipmentListViewModel, EquipmentListState>((ref) {
  return EquipmentListViewModel(
    ref.read(equipmentServiceProvider),
    ref.read(fishCatchServiceProvider),
  );
});
