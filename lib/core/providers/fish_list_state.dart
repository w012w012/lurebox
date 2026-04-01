import '../models/fish_catch.dart';
import '../models/fish_filter.dart';

class FishListData {
  final List<FishCatch> catches;
  final int currentPage;
  final bool hasMore;
  final int totalCount;

  const FishListData({
    this.catches = const [],
    this.currentPage = 0,
    this.hasMore = true,
    this.totalCount = 0,
  });

  FishListData copyWith({
    List<FishCatch>? catches,
    int? currentPage,
    bool? hasMore,
    int? totalCount,
  }) {
    return FishListData(
      catches: catches ?? this.catches,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class FishListFilterState {
  final FishFilter filter;
  final bool filterExpanded;
  final List<FishCatch> filteredCatches;

  const FishListFilterState({
    this.filter = const FishFilter(),
    this.filterExpanded = true,
    this.filteredCatches = const [],
  });

  FishListFilterState copyWith({
    FishFilter? filter,
    bool? filterExpanded,
    List<FishCatch>? filteredCatches,
  }) {
    return FishListFilterState(
      filter: filter ?? this.filter,
      filterExpanded: filterExpanded ?? this.filterExpanded,
      filteredCatches: filteredCatches ?? this.filteredCatches,
    );
  }

  List<String> get uniqueSpecies {
    final species = <String>{};
    for (final fish in filteredCatches) {
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
}

class FishListSelectionState {
  final Set<int> selectedIds;
  final bool isSelectionMode;

  const FishListSelectionState({
    this.selectedIds = const {},
    this.isSelectionMode = false,
  });

  FishListSelectionState copyWith({
    Set<int>? selectedIds,
    bool? isSelectionMode,
  }) {
    return FishListSelectionState(
      selectedIds: selectedIds ?? this.selectedIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }
}

class FishListState {
  final FishListData data;
  final FishListFilterState filter;
  final FishListSelectionState selection;
  final bool isLoading;
  final String? errorMessage;

  const FishListState({
    this.data = const FishListData(),
    this.filter = const FishListFilterState(),
    this.selection = const FishListSelectionState(),
    this.isLoading = false,
    this.errorMessage,
  });

  List<FishCatch> get catches => data.catches;
  List<FishCatch> get filteredCatches => filter.filteredCatches;
  Set<int> get selectedIds => selection.selectedIds;
  bool get isSelectionMode => selection.isSelectionMode;
  bool get filterExpanded => filter.filterExpanded;
  FishFilter get filterState => filter.filter;
  int get currentPage => data.currentPage;
  bool get hasMore => data.hasMore;
  int get totalCount => data.totalCount;

  FishListState copyWith({
    FishListData? data,
    FishListFilterState? filter,
    FishListSelectionState? selection,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return FishListState(
      data: data ?? this.data,
      filter: filter ?? this.filter,
      selection: selection ?? this.selection,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  String getCustomDateLabel(String Function() getString) {
    if (filterState.customStartDate == null ||
        filterState.customEndDate == null) {
      return getString();
    }
    final start = filterState.customStartDate!;
    final end = filterState.customEndDate!.subtract(const Duration(days: 1));
    return '${start.month}/${start.day} - ${end.month}/${end.day}';
  }
}
