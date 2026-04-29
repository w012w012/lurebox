import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/repositories/stats_repository.dart';
import 'package:lurebox/core/services/error_service.dart';

class HomeState {
  const HomeState({
    this.isLoading = true,
    this.errorMessage,
    this.todayStats = const CatchStats(total: 0, release: 0, keep: 0),
    this.todaySpecies = const {},
    this.monthStats = const CatchStats(total: 0, release: 0, keep: 0),
    this.monthSpecies = const {},
    this.yearStats = const CatchStats(total: 0, release: 0, keep: 0),
    this.yearSpecies = const {},
    this.allStats = const CatchStats(total: 0, release: 0, keep: 0),
    this.allSpecies = const {},
    this.top3Fishes = const [],
    this.monthTrend = const [],
  });
  final bool isLoading;
  final String? errorMessage;

  final CatchStats todayStats;
  final Map<String, int> todaySpecies;

  final CatchStats monthStats;
  final Map<String, int> monthSpecies;

  final CatchStats yearStats;
  final Map<String, int> yearSpecies;

  final CatchStats allStats;
  final Map<String, int> allSpecies;

  final List<FishCatch> top3Fishes;
  final List<DailyTrend> monthTrend;

  int get todayCount => todayStats.total;
  int get todayRelease => todayStats.release;
  int get todayKeep => todayStats.keep;

  int get monthCount => monthStats.total;
  int get monthRelease => monthStats.release;
  int get monthKeep => monthStats.keep;

  int get yearCount => yearStats.total;
  int get yearRelease => yearStats.release;
  int get yearKeep => yearStats.keep;

  int get allCount => allStats.total;
  int get allRelease => allStats.release;
  int get allKeep => allStats.keep;

  HomeState copyWith({
    bool? isLoading,
    String? Function()? errorMessage,
    CatchStats? todayStats,
    Map<String, int>? todaySpecies,
    CatchStats? monthStats,
    Map<String, int>? monthSpecies,
    CatchStats? yearStats,
    Map<String, int>? yearSpecies,
    CatchStats? allStats,
    Map<String, int>? allSpecies,
    List<FishCatch>? top3Fishes,
    List<DailyTrend>? monthTrend,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      todayStats: todayStats ?? this.todayStats,
      todaySpecies: todaySpecies ?? this.todaySpecies,
      monthStats: monthStats ?? this.monthStats,
      monthSpecies: monthSpecies ?? this.monthSpecies,
      yearStats: yearStats ?? this.yearStats,
      yearSpecies: yearSpecies ?? this.yearSpecies,
      allStats: allStats ?? this.allStats,
      allSpecies: allSpecies ?? this.allSpecies,
      top3Fishes: top3Fishes ?? this.top3Fishes,
      monthTrend: monthTrend ?? this.monthTrend,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel(this._statsRepo) : super(const HomeState()) {
    loadData();
  }
  final StatsRepository _statsRepo;

  Future<void> loadData() async {
    // 如果已经在加载中，跳过（防止重复调用）
    // 但初始状态isLoading=true是为了显示加载UI，需要特殊处理
    if (state.isLoading && state.todayStats.total != 0) return;

    state = state.copyWith(isLoading: true, errorMessage: () => null);

    try {
      final dashboard = await _statsRepo.getDashboardData();
      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        todayStats: dashboard.todayStats,
        todaySpecies: dashboard.todaySpecies,
        monthStats: dashboard.monthStats,
        monthSpecies: dashboard.monthSpecies,
        yearStats: dashboard.yearStats,
        yearSpecies: dashboard.yearSpecies,
        allStats: dashboard.allStats,
        allSpecies: dashboard.allSpecies,
        top3Fishes: dashboard.top3Longest,
        monthTrend: dashboard.monthTrend,
      );
    } on Exception catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: () => ErrorService.toUserMessage(e));
    }
  }

  Future<void> refresh() => loadData();
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((
  ref,
) {
  return HomeViewModel(ref.read(statsRepositoryProvider));
});
