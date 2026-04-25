import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fish_catch.dart';
import '../di/di.dart';
import '../services/fish_catch_service.dart';

class StatsDetailState {
  final bool isLoading;
  final String? errorMessage;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final int totalCount;
  final int releaseCount;
  final int keepCount;
  final double totalWeight;
  final Map<String, int> speciesDistribution;
  final Map<String, int> locationDistribution;
  final Map<int, int> rodDistribution;
  final Map<int, int> reelDistribution;
  final Map<int, int> lureDistribution;
  final Map<int, int> hourlyDistribution;
  final Map<int, int> dailyDistribution;
  final Map<int, int> monthlyDistribution;
  final List<Map<String, dynamic>> catches;
  final bool isSharing;

  const StatsDetailState({
    this.isLoading = true,
    this.errorMessage,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.totalCount = 0,
    this.releaseCount = 0,
    this.keepCount = 0,
    this.totalWeight = 0.0,
    this.speciesDistribution = const {},
    this.locationDistribution = const {},
    this.rodDistribution = const {},
    this.reelDistribution = const {},
    this.lureDistribution = const {},
    this.hourlyDistribution = const {},
    this.dailyDistribution = const {},
    this.monthlyDistribution = const {},
    this.catches = const [],
    this.isSharing = false,
  });

  StatsDetailState copyWith({
    bool? isLoading,
    String? Function()? errorMessage,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    int? totalCount,
    int? releaseCount,
    int? keepCount,
    double? totalWeight,
    Map<String, int>? speciesDistribution,
    Map<String, int>? locationDistribution,
    Map<int, int>? rodDistribution,
    Map<int, int>? reelDistribution,
    Map<int, int>? lureDistribution,
    Map<int, int>? hourlyDistribution,
    Map<int, int>? dailyDistribution,
    Map<int, int>? monthlyDistribution,
    List<Map<String, dynamic>>? catches,
    bool? isSharing,
  }) {
    return StatsDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalCount: totalCount ?? this.totalCount,
      releaseCount: releaseCount ?? this.releaseCount,
      keepCount: keepCount ?? this.keepCount,
      totalWeight: totalWeight ?? this.totalWeight,
      speciesDistribution: speciesDistribution ?? this.speciesDistribution,
      locationDistribution: locationDistribution ?? this.locationDistribution,
      rodDistribution: rodDistribution ?? this.rodDistribution,
      reelDistribution: reelDistribution ?? this.reelDistribution,
      lureDistribution: lureDistribution ?? this.lureDistribution,
      hourlyDistribution: hourlyDistribution ?? this.hourlyDistribution,
      dailyDistribution: dailyDistribution ?? this.dailyDistribution,
      monthlyDistribution: monthlyDistribution ?? this.monthlyDistribution,
      catches: catches ?? this.catches,
      isSharing: isSharing ?? this.isSharing,
    );
  }

  double get releaseRate {
    if (totalCount == 0) return 0;
    return releaseCount / totalCount;
  }
}

class StatsDetailViewModel extends StateNotifier<StatsDetailState> {
  final FishCatchService _fishCatchService;

  StatsDetailViewModel({
    required FishCatchService fishCatchService,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
  })  : _fishCatchService = fishCatchService,
        super(
          StatsDetailState(
              title: title, startDate: startDate, endDate: endDate),
        ) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);

    try {
      final fishList = await _fishCatchService.getByDateRange(
        state.startDate,
        state.endDate,
      );
      final catches = fishList.map((f) => f.toMap()).toList();

      int releaseCount = 0;
      int keepCount = 0;
      double totalWeight = 0;
      final speciesMap = <String, int>{};
      final locationMap = <String, int>{};
      final hourlyMap = <int, int>{};
      final dailyMap = <int, int>{};
      final monthlyMap = <int, int>{};

      for (final fish in fishList) {
        if (fish.fate == FishFateType.release) {
          releaseCount++;
        } else {
          keepCount++;
        }

        if (fish.weight != null) totalWeight += fish.weight!;

        final species = fish.species;
        speciesMap[species] = (speciesMap[species] ?? 0) + 1;

        final location = fish.locationName;
        if (location != null && location.isNotEmpty) {
          locationMap[location] = (locationMap[location] ?? 0) + 1;
        }

        final catchTime = fish.catchTime;
        hourlyMap[catchTime.hour] = (hourlyMap[catchTime.hour] ?? 0) + 1;
        dailyMap[catchTime.day] = (dailyMap[catchTime.day] ?? 0) + 1;
        monthlyMap[catchTime.month] = (monthlyMap[catchTime.month] ?? 0) + 1;
      }

      state = state.copyWith(
        isLoading: false,
        catches: catches,
        totalCount: catches.length,
        releaseCount: releaseCount,
        keepCount: keepCount,
        totalWeight: totalWeight,
        speciesDistribution: speciesMap,
        locationDistribution: locationMap,
        hourlyDistribution: hourlyMap,
        dailyDistribution: dailyMap,
        monthlyDistribution: monthlyMap,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: () => e.toString());
    }
  }

  void setSharing(bool value) {
    state = state.copyWith(isSharing: value);
  }

  Future<void> refresh() => loadData();
}

final statsDetailViewModelProvider = StateNotifierProvider.family<
    StatsDetailViewModel,
    StatsDetailState,
    ({String title, DateTime startDate, DateTime endDate})>(
  (ref, params) => StatsDetailViewModel(
    fishCatchService: ref.read(fishCatchServiceProvider),
    title: params.title,
    startDate: params.startDate,
    endDate: params.endDate,
  ),
);
