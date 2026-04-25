import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/models/fish_catch.dart';

/// 渔获过滤与排序数据模型
///
/// 定义了渔获列表的过滤、排序和搜索功能。
/// 使用 Riverpod 进行状态管理。
///
/// [FishFilter] 过滤器支持的过滤条件：
/// - timeFilter: 时间过滤（today/week/month/year/all/custom）
/// - fateFilter: 命运过滤（放流/保留）
/// - speciesFilter: 鱼种过滤
/// - customStartDate/customEndDate: 自定义日期范围
/// - searchQuery: 关键词搜索
///
/// 排序支持：
/// - sortBy: 排序字段（time/length/weight）
/// - sortAsc: 升序/降序
///
/// [FishFilterNotifier] 状态管理：
/// - 提供流式 API 设置各过滤条件
/// - clearAll(): 重置所有过滤器
///
/// [fishFilterProvider] Riverpod Provider：
/// - 全局可访问的过滤器状态
///
/// 设计模式：
/// - 使用 StateNotifier 模式管理可变状态
/// - 使用 copyWith 实现不可变更新
/// - 支持空值清除（通过函数回调）

class FishFilter {

  const FishFilter({
    this.timeFilter = 'all',
    this.fateFilter,
    this.speciesFilter,
    this.sortBy = 'time',
    this.sortAsc = false,
    this.customStartDate,
    this.customEndDate,
    this.searchQuery,
  });
  final String timeFilter;
  final FishFateType? fateFilter;
  final String? speciesFilter;
  final String sortBy;
  final bool sortAsc;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final String? searchQuery;

  FishFilter copyWith({
    String? timeFilter,
    FishFateType? Function()? fateFilter,
    String? Function()? speciesFilter,
    String? sortBy,
    bool? sortAsc,
    DateTime? Function()? customStartDate,
    DateTime? Function()? customEndDate,
    String? Function()? searchQuery,
  }) {
    return FishFilter(
      timeFilter: timeFilter ?? this.timeFilter,
      fateFilter: fateFilter != null ? fateFilter() : this.fateFilter,
      speciesFilter:
          speciesFilter != null ? speciesFilter() : this.speciesFilter,
      sortBy: sortBy ?? this.sortBy,
      sortAsc: sortAsc ?? this.sortAsc,
      customStartDate:
          customStartDate != null ? customStartDate() : this.customStartDate,
      customEndDate:
          customEndDate != null ? customEndDate() : this.customEndDate,
      searchQuery: searchQuery != null ? searchQuery() : this.searchQuery,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FishFilter &&
          runtimeType == other.runtimeType &&
          timeFilter == other.timeFilter &&
          fateFilter == other.fateFilter &&
          speciesFilter == other.speciesFilter &&
          sortBy == other.sortBy &&
          sortAsc == other.sortAsc &&
          customStartDate == other.customStartDate &&
          customEndDate == other.customEndDate &&
          searchQuery == other.searchQuery;

  @override
  int get hashCode => Object.hash(
        timeFilter,
        fateFilter,
        speciesFilter,
        sortBy,
        sortAsc,
        customStartDate,
        customEndDate,
        searchQuery,
      );
}

class FishFilterNotifier extends StateNotifier<FishFilter> {
  FishFilterNotifier() : super(const FishFilter());

  void setTimeFilter(String filter) {
    state = state.copyWith(timeFilter: filter);
  }

  void setFateFilter(FishFateType? fate) {
    state = state.copyWith(fateFilter: () => fate);
  }

  void setSpeciesFilter(String? species) {
    state = state.copyWith(speciesFilter: () => species);
  }

  void setSortBy(String sortBy, {bool? sortAsc}) {
    if (state.sortBy == sortBy) {
      // Toggle sort direction when selecting the same field
      state = state.copyWith(sortAsc: !state.sortAsc);
    } else {
      state = state.copyWith(sortBy: sortBy, sortAsc: sortAsc ?? state.sortAsc);
    }
  }

  void setCustomDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(
      timeFilter: 'custom',
      customStartDate: () => start,
      customEndDate: () => end,
    );
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: () => query);
  }

  void clearAll() {
    state = const FishFilter();
  }
}

final fishFilterProvider =
    StateNotifierProvider<FishFilterNotifier, FishFilter>(
  (ref) => FishFilterNotifier(),
);
