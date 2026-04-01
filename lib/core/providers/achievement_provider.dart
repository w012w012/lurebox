import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import '../di/di.dart';

final allAchievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final service = ref.watch(achievementServiceProvider);
  return await service.getAllAchievements();
});

final achievementStatsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final service = ref.watch(achievementServiceProvider);
  return await service.getAchievementStats();
});
