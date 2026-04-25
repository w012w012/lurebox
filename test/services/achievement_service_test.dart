import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/achievements.dart';
import 'package:lurebox/core/models/achievement.dart';
import 'package:lurebox/core/repositories/stats_repository.dart';
import 'package:lurebox/core/services/achievement_service.dart';
import 'package:mocktail/mocktail.dart';

class MockStatsRepository extends Mock implements StatsRepository {}

void main() {
  group('AchievementService', () {
    late AchievementService achievementService;
    late MockStatsRepository mockStatsRepo;

    setUp(() {
      mockStatsRepo = MockStatsRepository();
      achievementService = AchievementService(mockStatsRepo);
    });

    group('getAllAchievements', () {
      test('returns list of achievements with progress', () async {
        // Setup mock returns
        when(() => mockStatsRepo.getTotalCatchCount())
            .thenAnswer((_) async => 50);
        when(() => mockStatsRepo.getMaxLength()).thenAnswer((_) async => 45.0);
        when(() => mockStatsRepo.getDistinctSpeciesCount())
            .thenAnswer((_) async => 5);
        when(() => mockStatsRepo.getLocationCount()).thenAnswer((_) async => 3);
        when(() => mockStatsRepo.getReleaseCount()).thenAnswer((_) async => 30);
        when(() => mockStatsRepo.getReleaseRate()).thenAnswer((_) async => 0.6);
        when(() => mockStatsRepo.getConsecutiveDays())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getMonthlyMax()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getDailyMax()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getMorningCatchCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getNightCatchCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getPhotoCount()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getTotalWeight()).thenAnswer((_) async => 0.0);
        when(() => mockStatsRepo.getEquipmentFullStatus())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getEquipmentCount())
            .thenAnswer((_) async => 0);

        final achievements = await achievementService.getAllAchievements();

        expect(achievements, isNotEmpty);
        expect(achievements.first, isA<Achievement>());
      });

      test('calculates correct progress for catch count achievements',
          () async {
        when(() => mockStatsRepo.getTotalCatchCount())
            .thenAnswer((_) async => 50);
        when(() => mockStatsRepo.getMaxLength()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getDistinctSpeciesCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getLocationCount()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getReleaseCount()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getReleaseRate()).thenAnswer((_) async => 0.0);
        when(() => mockStatsRepo.getConsecutiveDays())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getMonthlyMax()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getDailyMax()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getMorningCatchCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getNightCatchCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getPhotoCount()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getTotalWeight()).thenAnswer((_) async => 0.0);
        when(() => mockStatsRepo.getEquipmentFullStatus())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getEquipmentCount())
            .thenAnswer((_) async => 0);

        final achievements = await achievementService.getAllAchievements();

        // Find catch_100 achievement (target: 100, current: 50)
        final catch100 = achievements.firstWhere((a) => a.id == 'catch_100');
        expect(catch100.current, equals(50));
        expect(catch100.progress, equals(50.0));

        // Find catch_10 achievement (target: 10, current: 50)
        final catch10 = achievements.firstWhere((a) => a.id == 'catch_10');
        expect(catch10.current, equals(50));
        expect(catch10.progress, equals(100.0)); // clamped
        expect(catch10.isUnlocked, isTrue);
      });

      test('calculates length achievements correctly', () async {
        when(() => mockStatsRepo.getTotalCatchCount())
            .thenAnswer((_) async => 100);
        when(() => mockStatsRepo.getMaxLength()).thenAnswer((_) async => 55.0);
        when(() => mockStatsRepo.getDistinctSpeciesCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getLocationCount()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getReleaseCount()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getReleaseRate()).thenAnswer((_) async => 0.0);
        when(() => mockStatsRepo.getConsecutiveDays())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getMonthlyMax()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getDailyMax()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getMorningCatchCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getNightCatchCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getPhotoCount()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getTotalWeight()).thenAnswer((_) async => 0.0);
        when(() => mockStatsRepo.getEquipmentFullStatus())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getEquipmentCount())
            .thenAnswer((_) async => 0);

        final achievements = await achievementService.getAllAchievements();

        // length_30 should be unlocked (55 >= 30)
        final length30 = achievements.firstWhere((a) => a.id == 'length_30');
        expect(length30.isUnlocked, isTrue);
        expect(length30.current, equals(1));

        // length_50 should be unlocked (55 >= 50)
        final length50 = achievements.firstWhere((a) => a.id == 'length_50');
        expect(length50.isUnlocked, isTrue);
        expect(length50.current, equals(1));

        // length_70 should NOT be unlocked (55 < 70)
        final length70 = achievements.firstWhere((a) => a.id == 'length_70');
        expect(length70.isUnlocked, isFalse);
        expect(length70.current, equals(0));
      });

      test('calculates release rate achievement correctly', () async {
        when(() => mockStatsRepo.getTotalCatchCount())
            .thenAnswer((_) async => 100);
        when(() => mockStatsRepo.getMaxLength()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getDistinctSpeciesCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getLocationCount()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getReleaseCount()).thenAnswer((_) async => 80);
        when(() => mockStatsRepo.getReleaseRate()).thenAnswer((_) async => 0.8);
        when(() => mockStatsRepo.getConsecutiveDays())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getMonthlyMax()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getDailyMax()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getMorningCatchCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getNightCatchCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getPhotoCount()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getTotalWeight()).thenAnswer((_) async => 0.0);
        when(() => mockStatsRepo.getEquipmentFullStatus())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getEquipmentCount())
            .thenAnswer((_) async => 0);

        final achievements = await achievementService.getAllAchievements();

        // release_rate_80 should be unlocked
        final releaseRate80 =
            achievements.firstWhere((a) => a.id == 'release_rate_80');
        expect(releaseRate80.isUnlocked, isTrue);
        expect(releaseRate80.current, equals(1));
      });

      test('returns default metrics on repository error', () async {
        when(() => mockStatsRepo.getTotalCatchCount())
            .thenThrow(Exception('Database error'));
        when(() => mockStatsRepo.getMaxLength()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getDistinctSpeciesCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getLocationCount()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getReleaseCount()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getReleaseRate()).thenAnswer((_) async => 0.0);
        when(() => mockStatsRepo.getConsecutiveDays())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getMonthlyMax()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getDailyMax()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getMorningCatchCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getNightCatchCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getPhotoCount()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getTotalWeight()).thenAnswer((_) async => 0.0);
        when(() => mockStatsRepo.getEquipmentFullStatus())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getEquipmentCount())
            .thenAnswer((_) async => 0);

        // Should not throw, should return achievements with 0 progress
        final achievements = await achievementService.getAllAchievements();

        expect(achievements, isNotEmpty);
        // All achievements should have 0 current value
        for (final a in achievements) {
          expect(a.current, equals(0));
        }
      });

      test('handles new_record achievement', () async {
        when(() => mockStatsRepo.getTotalCatchCount())
            .thenAnswer((_) async => 1);
        when(() => mockStatsRepo.getMaxLength()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getDistinctSpeciesCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getLocationCount()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getReleaseCount()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getReleaseRate()).thenAnswer((_) async => 0.0);
        when(() => mockStatsRepo.getConsecutiveDays())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getMonthlyMax()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getDailyMax()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getMorningCatchCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getNightCatchCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getPhotoCount()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getTotalWeight()).thenAnswer((_) async => 0.0);
        when(() => mockStatsRepo.getEquipmentFullStatus())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getEquipmentCount())
            .thenAnswer((_) async => 0);

        final achievements = await achievementService.getAllAchievements();

        // new_record should be unlocked when totalCatches > 0
        final newRecord = achievements.firstWhere((a) => a.id == 'new_record');
        expect(newRecord.isUnlocked, isTrue);
      });
    });

    group('getAchievementStats', () {
      test('returns correct statistics', () async {
        when(() => mockStatsRepo.getTotalCatchCount())
            .thenAnswer((_) async => 100);
        when(() => mockStatsRepo.getMaxLength()).thenAnswer((_) async => 100);
        when(() => mockStatsRepo.getDistinctSpeciesCount())
            .thenAnswer((_) async => 20);
        when(() => mockStatsRepo.getLocationCount())
            .thenAnswer((_) async => 50);
        when(() => mockStatsRepo.getReleaseCount())
            .thenAnswer((_) async => 200);
        when(() => mockStatsRepo.getReleaseRate()).thenAnswer((_) async => 1.0);
        when(() => mockStatsRepo.getConsecutiveDays())
            .thenAnswer((_) async => 7);
        when(() => mockStatsRepo.getMonthlyMax()).thenAnswer((_) async => 30);
        when(() => mockStatsRepo.getDailyMax()).thenAnswer((_) async => 5);
        when(() => mockStatsRepo.getMorningCatchCount())
            .thenAnswer((_) async => 20);
        when(() => mockStatsRepo.getNightCatchCount())
            .thenAnswer((_) async => 20);
        when(() => mockStatsRepo.getPhotoCount()).thenAnswer((_) async => 100);
        when(() => mockStatsRepo.getTotalWeight())
            .thenAnswer((_) async => 10.0);
        when(() => mockStatsRepo.getEquipmentFullStatus())
            .thenAnswer((_) async => 1);
        when(() => mockStatsRepo.getEquipmentCount())
            .thenAnswer((_) async => 50);

        final stats = await achievementService.getAchievementStats();

        expect(stats['unlockedCount'], greaterThan(0));
        expect(
            stats['totalCount'], equals(AchievementConfig.definitions.length),);
        expect(stats['progress'], greaterThanOrEqualTo(0));
        expect(stats['progress'], lessThanOrEqualTo(100));
      });

      test('calculates progress percentage correctly', () async {
        when(() => mockStatsRepo.getTotalCatchCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getMaxLength()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getDistinctSpeciesCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getLocationCount()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getReleaseCount()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getReleaseRate()).thenAnswer((_) async => 0.0);
        when(() => mockStatsRepo.getConsecutiveDays())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getMonthlyMax()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getDailyMax()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getMorningCatchCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getNightCatchCount())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getPhotoCount()).thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getTotalWeight()).thenAnswer((_) async => 0.0);
        when(() => mockStatsRepo.getEquipmentFullStatus())
            .thenAnswer((_) async => 0);
        when(() => mockStatsRepo.getEquipmentCount())
            .thenAnswer((_) async => 0);

        final stats = await achievementService.getAchievementStats();

        // With no achievements unlocked, progress should be 0
        expect(stats['progress'], equals(0));
      });
    });

    group('achievement categories', () {
      test('all achievement categories are represented', () async {
        when(() => mockStatsRepo.getTotalCatchCount())
            .thenAnswer((_) async => 100);
        when(() => mockStatsRepo.getMaxLength()).thenAnswer((_) async => 100);
        when(() => mockStatsRepo.getDistinctSpeciesCount())
            .thenAnswer((_) async => 20);
        when(() => mockStatsRepo.getLocationCount())
            .thenAnswer((_) async => 50);
        when(() => mockStatsRepo.getReleaseCount())
            .thenAnswer((_) async => 200);
        when(() => mockStatsRepo.getReleaseRate()).thenAnswer((_) async => 1.0);
        when(() => mockStatsRepo.getConsecutiveDays())
            .thenAnswer((_) async => 7);
        when(() => mockStatsRepo.getMonthlyMax()).thenAnswer((_) async => 30);
        when(() => mockStatsRepo.getDailyMax()).thenAnswer((_) async => 5);
        when(() => mockStatsRepo.getMorningCatchCount())
            .thenAnswer((_) async => 20);
        when(() => mockStatsRepo.getNightCatchCount())
            .thenAnswer((_) async => 20);
        when(() => mockStatsRepo.getPhotoCount()).thenAnswer((_) async => 100);
        when(() => mockStatsRepo.getTotalWeight())
            .thenAnswer((_) async => 10.0);
        when(() => mockStatsRepo.getEquipmentFullStatus())
            .thenAnswer((_) async => 1);
        when(() => mockStatsRepo.getEquipmentCount())
            .thenAnswer((_) async => 50);

        final achievements = await achievementService.getAllAchievements();

        final categories = achievements.map((a) => a.category).toSet();
        expect(categories, contains('数量类'));
        expect(categories, contains('尺寸类'));
        expect(categories, contains('品种类'));
        expect(categories, contains('装备类'));
        expect(categories, contains('地点类'));
        expect(categories, contains('环保类'));
        expect(categories, contains('特殊成就'));
      });
    });

    group('progress clamping', () {
      test('progress is clamped to 100 when exceeded', () async {
        // Very high catch count
        when(() => mockStatsRepo.getTotalCatchCount())
            .thenAnswer((_) async => 10000);
        when(() => mockStatsRepo.getMaxLength()).thenAnswer((_) async => 200);
        when(() => mockStatsRepo.getDistinctSpeciesCount())
            .thenAnswer((_) async => 100);
        when(() => mockStatsRepo.getLocationCount())
            .thenAnswer((_) async => 100);
        when(() => mockStatsRepo.getReleaseCount())
            .thenAnswer((_) async => 10000);
        when(() => mockStatsRepo.getReleaseRate()).thenAnswer((_) async => 1.0);
        when(() => mockStatsRepo.getConsecutiveDays())
            .thenAnswer((_) async => 100);
        when(() => mockStatsRepo.getMonthlyMax()).thenAnswer((_) async => 100);
        when(() => mockStatsRepo.getDailyMax()).thenAnswer((_) async => 100);
        when(() => mockStatsRepo.getMorningCatchCount())
            .thenAnswer((_) async => 100);
        when(() => mockStatsRepo.getNightCatchCount())
            .thenAnswer((_) async => 100);
        when(() => mockStatsRepo.getPhotoCount()).thenAnswer((_) async => 1000);
        when(() => mockStatsRepo.getTotalWeight())
            .thenAnswer((_) async => 1000.0);
        when(() => mockStatsRepo.getEquipmentFullStatus())
            .thenAnswer((_) async => 1);
        when(() => mockStatsRepo.getEquipmentCount())
            .thenAnswer((_) async => 100);

        final achievements = await achievementService.getAllAchievements();

        for (final a in achievements) {
          expect(a.progress, lessThanOrEqualTo(100.0));
        }
      });
    });
  });

  group('AchievementConfig', () {
    test('definitions is not empty', () {
      expect(AchievementConfig.definitions, isNotEmpty);
    });

    test('all definitions have required fields', () {
      for (final def in AchievementConfig.definitions) {
        expect(def.id, isNotEmpty);
        expect(def.title, isNotEmpty);
        expect(def.description, isNotEmpty);
        expect(def.icon, isNotEmpty);
        expect(def.target, greaterThan(0));
      }
    });

    test('all definition IDs are unique', () {
      final ids = AchievementConfig.definitions.map((d) => d.id).toList();
      expect(ids.toSet().length, equals(ids.length));
    });

    test('has correct number of achievements by category', () {
      final byCategory = <String, int>{};
      for (final def in AchievementConfig.definitions) {
        byCategory[def.category] = (byCategory[def.category] ?? 0) + 1;
      }

      expect(byCategory['数量类'], equals(5));
      expect(byCategory['尺寸类'], equals(5));
      expect(byCategory['品种类'], equals(5));
      expect(byCategory['装备类'], equals(5));
      expect(byCategory['地点类'], equals(5));
      expect(byCategory['环保类'], equals(5));
      expect(byCategory['特殊成就'], equals(10));
    });
  });
}
