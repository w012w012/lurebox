import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/fish_filter.dart';
import 'package:lurebox/core/services/error_service.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';

class FishListState {

  const FishListState({
    this.catches = const [],
    this.filteredCatches = const [],
    this.filter = const FishFilter(),
    this.isLoading = false,
    this.errorMessage,
    this.selectedIds = const {},
    this.isSelectionMode = false,
    this.filterExpanded = true,
    this.currentPage = 0,
    this.hasMore = true,
    this.totalCount = 0,
    this.displayUnits,
  });
  final List<FishCatch> catches;
  final List<FishCatch> filteredCatches;
  final FishFilter filter;
  final bool isLoading;
  final String? errorMessage;
  final Set<int> selectedIds;
  final bool isSelectionMode;
  final bool filterExpanded;
  final int currentPage;
  final bool hasMore;
  final int totalCount;
  final UnitSettings? displayUnits;

  FishListState copyWith({
    List<FishCatch>? catches,
    List<FishCatch>? filteredCatches,
    FishFilter? filter,
    bool? isLoading,
    String? Function()? errorMessage,
    Set<int>? selectedIds,
    bool? isSelectionMode,
    bool? filterExpanded,
    int? currentPage,
    bool? hasMore,
    int? totalCount,
    UnitSettings? displayUnits,
  }) {
    return FishListState(
      catches: catches ?? this.catches,
      filteredCatches: filteredCatches ?? this.filteredCatches,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      selectedIds: selectedIds ?? this.selectedIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      filterExpanded: filterExpanded ?? this.filterExpanded,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
      displayUnits: displayUnits ?? this.displayUnits,
    );
  }

  List<String> get uniqueSpecies {
    final species = <String>{};
    for (final fish in catches) {
      species.add(fish.species);
    }
    return species.toList()..sort();
  }

  bool get hasFilters =>
      filter.timeFilter != 'all' ||
      filter.fateFilter != null ||
      filter.speciesFilter != null ||
      filter.customStartDate != null ||
      filter.sortBy != 'time' ||
      (filter.searchQuery?.isNotEmpty ?? false);

  String getCustomDateLabel(String Function() getString) {
    final startDate = filter.customStartDate;
    final endDate = filter.customEndDate;
    if (startDate == null || endDate == null) {
      return getString();
    }
    final end = endDate.subtract(const Duration(days: 1));
    return '${startDate.month}/${startDate.day} - ${end.month}/${end.day}';
  }
}

class FishListViewModel extends StateNotifier<FishListState> {

  FishListViewModel(this._fishCatchService) : super(const FishListState());
  static const int _defaultPageSize = 20;

  final FishCatchService _fishCatchService;
  int _loadGeneration = 0;
  Timer? _filterDebounce;

  Future<void> loadCatches({bool reset = false, UnitSettings? units}) async {
    final generation = ++_loadGeneration;

    if (reset) {
      state = state.copyWith(
        currentPage: 0,
        hasMore: true,
        filteredCatches: const [],
        catches: const [],
        displayUnits: units,
      );
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: () => null,
      displayUnits: units,
    );
    try {
      const pageSize = _defaultPageSize;
      final page = reset ? 1 : state.currentPage + 1;

      if (generation != _loadGeneration) return;

      List<FishCatch> newCatches;
      int totalCount;
      if (state.hasFilters) {
        final result = await _fishCatchService.getFilteredPageByFilter(
          page: page,
          filter: state.filter,
        );
        newCatches = result.items;
        totalCount = result.totalCount;
      } else {
        final result = await _fishCatchService.getPage(
          page: page,
          orderBy: _getOrderBy(state.filter.sortBy, state.filter.sortAsc),
        );
        newCatches = result.items;
        totalCount = result.totalCount;
      }
      if (!mounted) return;
      final allCatches = reset ? newCatches : [...state.catches, ...newCatches];
      if (generation != _loadGeneration) return;
      final filtered = _applyFilters(
        allCatches,
        state.filter,
        state.displayUnits,
      );

      state = state.copyWith(
        catches: allCatches,
        filteredCatches: filtered,
        isLoading: false,
        currentPage: reset ? 1 : state.currentPage + 1,
        hasMore: newCatches.length == pageSize,
        totalCount: totalCount,
      );
    } on Exception catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => ErrorService.toUserMessage(e),
      );
    }
  }

  static const _sortToColumn = {
    'length': 'length',
    'weight': 'weight',
    'time': 'catch_time',
  };

  String _getOrderBy(String sortBy, bool sortAsc) {
    final column = _sortToColumn[sortBy] ?? 'catch_time';
    return '$column ${sortAsc ? 'ASC' : 'DESC'}';
  }

  // Apply keyword search to catches (other filters handled at SQL layer)
  List<FishCatch> _applyFilters(
    List<FishCatch> catches,
    FishFilter filter,
    UnitSettings? units,
  ) {
    var result = catches;

    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      result = result.searchByKeyword(filter.searchQuery!);
    }

    return result;
  }

  void setTimeFilter(String filter) {
    final newFilter = state.filter.copyWith(timeFilter: filter);
    _updateFilter(newFilter);
  }

  void setFateFilter(FishFateType? fate) {
    final newFilter = state.filter.copyWith(fateFilter: () => fate);
    _updateFilter(newFilter);
  }

  void setSpeciesFilter(String? species) {
    final newFilter = state.filter.copyWith(speciesFilter: () => species);
    _updateFilter(newFilter);
  }

  void setSortBy(String sortBy, {bool? ascending}) {
    final newFilter = state.filter.copyWith(
      sortBy: sortBy,
      sortAsc: ascending ??
          (state.filter.sortBy == sortBy && !state.filter.sortAsc),
    );
    _updateFilter(newFilter);
  }

  void setCustomDateRange(DateTime? start, DateTime? end) {
    final newFilter = state.filter.copyWith(
      timeFilter: 'custom',
      customStartDate: () => start,
      customEndDate: () => end,
    );
    _updateFilter(newFilter);
  }

  void setSearchQuery(String? query) {
    final newFilter = state.filter.copyWith(searchQuery: () => query);
    _updateFilter(newFilter);
  }

  void toggleFilterExpanded() {
    state = state.copyWith(filterExpanded: !state.filterExpanded);
  }

  void clearFilters() {
    _updateFilter(const FishFilter());
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    await loadCatches(units: state.displayUnits);
  }

  void _updateFilter(FishFilter filter) {
    _filterDebounce?.cancel();
    state = state.copyWith(filter: filter);
    _filterDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) loadCatches(reset: true);
    });
  }

  @override
  void dispose() {
    _filterDebounce?.cancel();
    super.dispose();
  }

  void toggleSelectionMode() {
    state = state.copyWith(
      isSelectionMode: !state.isSelectionMode,
      selectedIds: state.isSelectionMode ? <int>{} : state.selectedIds,
    );
  }

  void toggleSelection(int id) {
    final newSelected = Set<int>.from(state.selectedIds);
    if (newSelected.contains(id)) {
      newSelected.remove(id);
    } else {
      newSelected.add(id);
    }
    state = state.copyWith(selectedIds: newSelected);
  }

  void selectAll() {
    final allIds = state.filteredCatches.map((f) => f.id).toSet();
    state = state.copyWith(selectedIds: allIds);
  }

  Future<void> deleteSelected() async {
    if (state.selectedIds.isEmpty) return;

    try {
      await _fishCatchService.deleteMultiple(state.selectedIds.toList());
      state = state.copyWith(selectedIds: <int>{}, isSelectionMode: false);
      await loadCatches(units: state.displayUnits);
    } on Exception catch (e) {
      if (!mounted) return;
      state = state.copyWith(errorMessage: () => ErrorService.toUserMessage(e));
    }
  }

  void onScroll(double offset, double lastOffset) {
    if (offset <= 0) {
      if (!state.filterExpanded) {
        state = state.copyWith(filterExpanded: true);
      }
    } else if (offset > lastOffset + 5) {
      if (state.filterExpanded) {
        state = state.copyWith(filterExpanded: false);
      }
    }
  }
}

final fishListViewModelProvider =
    StateNotifierProvider<FishListViewModel, FishListState>((ref) {
  return FishListViewModel(ref.read(fishCatchServiceProvider));
});
