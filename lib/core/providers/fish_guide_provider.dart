import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fish_species.dart';
import '../services/fish_species_matcher.dart';
import '../services/fish_species_stats_service.dart';
import '../../features/achievement/fish_guide_data.dart';
import '../di/di.dart';

/// 鱼种筛选分类
enum FishGuideCategoryFilter {
  all('全部'),
  unlocked('已解锁'),
  freshwater('淡水'),
  saltwater('海水');

  const FishGuideCategoryFilter(this.label);
  final String label;
}

/// 鱼种展示项（包含统计信息）
class FishSpeciesWithStats {
  final FishSpecies species;
  final FishSpeciesStats stats;

  const FishSpeciesWithStats({
    required this.species,
    required this.stats,
  });

  @override
  String toString() =>
      'FishSpeciesWithStats(species: ${species.standardName}, stats: $stats)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FishSpeciesWithStats &&
          runtimeType == other.runtimeType &&
          species.id == other.species.id;

  @override
  int get hashCode => species.id.hashCode;

  FishSpeciesWithStats copyWith({
    FishSpecies? species,
    FishSpeciesStats? stats,
  }) {
    return FishSpeciesWithStats(
      species: species ?? this.species,
      stats: stats ?? this.stats,
    );
  }
}

/// 鱼种图鉴状态
class FishGuideState {
  final FishGuideCategoryFilter categoryFilter;
  final FishSpecies? selectedSpecies;
  final List<FishSpeciesWithStats> speciesList;
  final bool isLoading;
  final String? error;
  final int unlockedCount;
  final int totalCount;

  const FishGuideState({
    this.categoryFilter = FishGuideCategoryFilter.all,
    this.selectedSpecies,
    this.speciesList = const [],
    this.isLoading = false,
    this.error,
    this.unlockedCount = 0,
    this.totalCount = 0,
  });

  FishGuideState copyWith({
    FishGuideCategoryFilter? categoryFilter,
    FishSpecies? Function()? selectedSpecies,
    List<FishSpeciesWithStats>? speciesList,
    bool? isLoading,
    String? Function()? error,
    int? unlockedCount,
    int? totalCount,
  }) {
    return FishGuideState(
      categoryFilter: categoryFilter ?? this.categoryFilter,
      selectedSpecies:
          selectedSpecies != null ? selectedSpecies() : this.selectedSpecies,
      speciesList: speciesList ?? this.speciesList,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      unlockedCount: unlockedCount ?? this.unlockedCount,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

/// 鱼种图鉴状态管理
class FishGuideNotifier extends StateNotifier<FishGuideState> {
  final FishSpeciesStatsService _statsService;

  FishGuideNotifier(this._statsService) : super(const FishGuideState()) {
    // 初始化时加载鱼种数据
    _loadSpeciesList();
  }

  /// 设置分类筛选
  void setCategoryFilter(FishGuideCategoryFilter filter) {
    state = state.copyWith(categoryFilter: filter);
    _loadSpeciesList();
  }

  /// 选择鱼种查看详情
  void selectSpecies(FishSpecies? species) {
    state = state.copyWith(selectedSpecies: () => species);
  }

  /// 清除选择
  void clearSelection() {
    state = state.copyWith(selectedSpecies: () => null);
  }

  /// 加载鱼种列表
  Future<void> _loadSpeciesList() async {
    state = state.copyWith(isLoading: true, error: () => null);

    try {
      final allSpecies = FishGuideData.allSpecies;
      final speciesWithStats = <FishSpeciesWithStats>[];

      for (final species in allSpecies) {
        final stats = await _statsService.getStats(species.standardName);
        speciesWithStats.add(FishSpeciesWithStats(
          species: species,
          stats: stats,
        ));
      }

      // 根据筛选条件过滤
      final filtered = _filterSpecies(speciesWithStats);

      final unlockedCount =
          speciesWithStats.where((s) => s.stats.isUnlocked).length;

      state = state.copyWith(
        speciesList: filtered,
        isLoading: false,
        unlockedCount: unlockedCount,
        totalCount: allSpecies.length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    await _loadSpeciesList();
  }

  List<FishSpeciesWithStats> _filterSpecies(List<FishSpeciesWithStats> list) {
    switch (state.categoryFilter) {
      case FishGuideCategoryFilter.all:
        return list;
      case FishGuideCategoryFilter.unlocked:
        return list.where((s) => s.stats.isUnlocked).toList();
      case FishGuideCategoryFilter.freshwater:
        return list
            .where((s) =>
                s.species.category == FishCategory.freshwaterLure ||
                s.species.category == FishCategory.freshwaterGeneral)
            .toList();
      case FishGuideCategoryFilter.saltwater:
        return list
            .where((s) => s.species.category == FishCategory.saltwaterLure)
            .toList();
    }
  }
}

/// 鱼种统计服务Provider
final fishSpeciesStatsServiceProvider =
    Provider<FishSpeciesStatsService>((ref) {
  final catchRepo = ref.watch(fishCatchRepositoryProvider);
  return FishSpeciesStatsService(catchRepo, FishSpeciesMatcher());
});

/// 鱼种图鉴Provider
final fishGuideProvider =
    StateNotifierProvider<FishGuideNotifier, FishGuideState>((ref) {
  final statsService = ref.watch(fishSpeciesStatsServiceProvider);
  return FishGuideNotifier(statsService);
});
