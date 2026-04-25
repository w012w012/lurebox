import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/achievement.dart';

final allAchievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final service = ref.watch(achievementServiceProvider);
  return service.getAllAchievements();
});

final achievementStatsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final service = ref.watch(achievementServiceProvider);
  return service.getAchievementStats();
});
