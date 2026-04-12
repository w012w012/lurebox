import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';
import '../di/di.dart';

enum AchievementCategory {
  all(''),
  catchCount('catch'),
  species('species'),
  equipment('equipment'),
  location('location'),
  release('release'),
  special('special');

  const AchievementCategory(this.value);
  final String value;
}

class AchievementState {
  final List<Achievement> achievements;
  final List<Achievement> filteredAchievements;
  final AchievementCategory category;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, int> progress;

  const AchievementState({
    this.achievements = const [],
    this.filteredAchievements = const [],
    this.category = AchievementCategory.all,
    this.isLoading = false,
    this.errorMessage,
    this.progress = const {},
  });

  AchievementState copyWith({
    List<Achievement>? achievements,
    List<Achievement>? filteredAchievements,
    AchievementCategory? category,
    bool? isLoading,
    String? Function()? errorMessage,
    Map<String, int>? progress,
  }) {
    return AchievementState(
      achievements: achievements ?? this.achievements,
      filteredAchievements: filteredAchievements ?? this.filteredAchievements,
      category: category ?? this.category,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      progress: progress ?? this.progress,
    );
  }

  int get unlockedCount => achievements.where((a) => a.isUnlocked).length;
  int get lockedCount => achievements.where((a) => !a.isUnlocked).length;
  double get unlockProgress =>
      achievements.isEmpty ? 0 : unlockedCount / achievements.length;
}

class AchievementViewModel extends StateNotifier<AchievementState> {
  final AchievementService _service;

  AchievementViewModel(this._service) : super(const AchievementState());

  Future<void> loadAchievements() async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final achievements = await _service.getAllAchievements();
      final progress = <String, int>{};
      for (final a in achievements) {
        progress[a.id] = a.current;
      }

      final filtered = _filterByCategory(achievements, state.category);

      state = state.copyWith(
        achievements: achievements,
        filteredAchievements: filtered,
        progress: progress,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => e.toString(),
      );
    }
  }

  void setCategory(AchievementCategory category) {
    final filtered = _filterByCategory(state.achievements, category);
    state = state.copyWith(category: category, filteredAchievements: filtered);
  }

  List<Achievement> _filterByCategory(
    List<Achievement> achievements,
    AchievementCategory category,
  ) {
    if (category == AchievementCategory.all) {
      return achievements;
    }
    return achievements.where((a) => a.category == category.value).toList();
  }

  int getProgress(String id) {
    return state.progress[id] ?? 0;
  }

  bool isUnlocked(String id) {
    try {
      final achievement = state.achievements.firstWhere((a) => a.id == id);
      return achievement.isUnlocked;
    } catch (_) {
      // Achievement not found
      return false;
    }
  }
}

final achievementViewModelProvider =
    StateNotifierProvider<AchievementViewModel, AchievementState>((ref) {
  return AchievementViewModel(ref.read(achievementServiceProvider));
});
