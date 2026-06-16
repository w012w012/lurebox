import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/achievements.dart';
import 'package:lurebox/core/models/achievement.dart';
import 'package:lurebox/core/repositories/settings_repository.dart';
import 'package:lurebox/core/repositories/stats_repository.dart';
import 'package:lurebox/core/services/achievement_service.dart';
import 'package:mocktail/mocktail.dart';

class MockStatsRepository extends Mock implements StatsRepository {}

/// 内存版 SettingsRepository fake，用于成就持久化测试。
class FakeSettingsRepository implements SettingsRepository {
  final Map<String, String> store = {};

  /// 注入读取异常（用于测试写失败容错时不复用）。
  Object? getError;

  /// 注入写入异常（用于测试写失败容错）。
  Object? setError;

  @override
  Future<String?> get(String key) async {
    if (getError != null) throw getError!;
    return store[key];
  }

  @override
  Future<String> getOrDefault(String key, String defaultValue) async =>
      store[key] ?? defaultValue;

  @override
  Future<void> set(String key, String value) async {
    if (setError != null) throw setError!;
    store[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    store.remove(key);
  }

  @override
  Future<bool> exists(String key) async => store.containsKey(key);

  @override
  Future<Map<String, String>> getAll() async => Map.of(store);

  @override
  Future<void> setAll(Map<String, String> settings) async {
    store.addAll(settings);
  }

  @override
  Future<int> getInt(String key, {int defaultValue = 0}) async {
    final v = store[key];
    if (v == null) return defaultValue;
    return int.tryParse(v) ?? defaultValue;
  }

  @override
  Future<double> getDouble(String key, {double defaultValue = 0.0}) async {
    final v = store[key];
    if (v == null) return defaultValue;
    return double.tryParse(v) ?? defaultValue;
  }

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final v = store[key];
    if (v == null) return defaultValue;
    return v == 'true';
  }

  @override
  Future<void> setInt(String key, int value) async {
    if (setError != null) throw setError!;
    store[key] = value.toString();
  }

  @override
  Future<void> setDouble(String key, double value) async {
    store[key] = value.toString();
  }

  @override
  Future<void> setBool(String key, bool value) async {
    store[key] = value.toString();
  }
}

/// 为 mock 安装默认（全 0）返回，便于在每个用例中按需覆盖。
void _stubDefaults(MockStatsRepository repo) {
  when(repo.getTotalCatchCount).thenAnswer((_) async => 0);
  when(repo.getMaxLength).thenAnswer((_) async => 0);
  when(repo.getDistinctSpeciesCount).thenAnswer((_) async => 0);
  when(repo.getLocationCount).thenAnswer((_) async => 0);
  when(repo.getReleaseCount).thenAnswer((_) async => 0);
  when(repo.getReleaseRate).thenAnswer((_) async => 0.0);
  when(repo.getConsecutiveDays).thenAnswer((_) async => 0);
  when(repo.getMonthlyMax).thenAnswer((_) async => 0);
  when(repo.getDailyMax).thenAnswer((_) async => 0);
  when(repo.getMorningCatchCount).thenAnswer((_) async => 0);
  when(repo.getNightCatchCount).thenAnswer((_) async => 0);
  when(repo.getPhotoCount).thenAnswer((_) async => 0);
  when(repo.getTotalWeight).thenAnswer((_) async => 0.0);
  when(repo.getEquipmentFullStatus).thenAnswer((_) async => 0);
  when(repo.getEquipmentCount).thenAnswer((_) async => 0);
  when(repo.getOwnedEquipmentCount).thenAnswer((_) async => 0);
  when(repo.getEquipmentCatchStats).thenAnswer((_) async => {});
}

void main() {
  group('AchievementService', () {
    late AchievementService achievementService;
    late MockStatsRepository mockStatsRepo;
    late FakeSettingsRepository fakeSettingsRepo;

    setUp(() {
      mockStatsRepo = MockStatsRepository();
      fakeSettingsRepo = FakeSettingsRepository();
      _stubDefaults(mockStatsRepo);
      achievementService = AchievementService(mockStatsRepo, fakeSettingsRepo);
    });

    tearDown(() {
      // No resources to clean up - mocks are garbage collected
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

    // ─── FIX A: 永久解锁（不可撤销） ───
    group('permanent unlock persistence (FIX A)', () {
      test('newly unlocked achievement persists unlockedAt to settings',
          () async {
        when(mockStatsRepo.getTotalCatchCount).thenAnswer((_) async => 10);

        final achievements = await achievementService.getAllAchievements();

        final catch10 = achievements.firstWhere((a) => a.id == 'catch_10');
        expect(catch10.isUnlocked, isTrue);
        expect(catch10.unlockedAt, isNotNull);

        // 持久化映射应包含 catch_first 与 catch_10。
        final raw = fakeSettingsRepo.store['unlocked_achievements'];
        expect(raw, isNotNull);
        final map = jsonDecode(raw!) as Map<String, dynamic>;
        expect(map.containsKey('catch_10'), isTrue);
        expect(map.containsKey('catch_first'), isTrue);
      });

      test('stays unlocked after metric drops below target', () async {
        // 首次：10 条解锁 catch_10。
        when(mockStatsRepo.getTotalCatchCount).thenAnswer((_) async => 10);
        final first = await achievementService.getAllAchievements();
        final firstCatch10 = first.firstWhere((a) => a.id == 'catch_10');
        expect(firstCatch10.isUnlocked, isTrue);
        final unlockedAt = firstCatch10.unlockedAt;
        expect(unlockedAt, isNotNull);

        // 删除鱼获后掉到目标值以下。
        when(mockStatsRepo.getTotalCatchCount).thenAnswer((_) async => 2);
        final second = await achievementService.getAllAchievements();
        final secondCatch10 = second.firstWhere((a) => a.id == 'catch_10');

        // 仍解锁，进度满格，且 unlockedAt 沿用首次解锁时间。
        expect(secondCatch10.isUnlocked, isTrue);
        expect(secondCatch10.current, equals(10));
        expect(secondCatch10.progress, equals(100.0));
        expect(secondCatch10.unlockedAt, equals(unlockedAt));
      });

      test('never-unlocked achievement stays locked with live progress',
          () async {
        when(mockStatsRepo.getTotalCatchCount).thenAnswer((_) async => 50);

        final achievements = await achievementService.getAllAchievements();
        final catch100 = achievements.firstWhere((a) => a.id == 'catch_100');

        expect(catch100.isUnlocked, isFalse);
        expect(catch100.current, equals(50)); // live progress preserved
        expect(catch100.progress, equals(50.0));
        expect(catch100.unlockedAt, isNull);
      });

      test('corrupt JSON in settings does not throw and is treated as empty',
          () async {
        fakeSettingsRepo.store['unlocked_achievements'] = '{not valid json';
        when(mockStatsRepo.getTotalCatchCount).thenAnswer((_) async => 10);

        // Should not throw.
        final achievements = await achievementService.getAllAchievements();

        final catch10 = achievements.firstWhere((a) => a.id == 'catch_10');
        // Live metric still unlocks it; corrupt payload was ignored.
        expect(catch10.isUnlocked, isTrue);
      });

      test('persisted map is only written when something newly unlocks',
          () async {
        // 全 0：无任何解锁 → 不应写入。
        await achievementService.getAllAchievements();
        expect(fakeSettingsRepo.store.containsKey('unlocked_achievements'),
            isFalse,);

        // 解锁后写入。
        when(mockStatsRepo.getTotalCatchCount).thenAnswer((_) async => 1);
        await achievementService.getAllAchievements();
        expect(fakeSettingsRepo.store.containsKey('unlocked_achievements'),
            isTrue,);
      });

      test('write failure during persist does not throw', () async {
        fakeSettingsRepo.setError = Exception('disk full');
        when(mockStatsRepo.getTotalCatchCount).thenAnswer((_) async => 10);

        // Should not throw despite persist failure.
        final achievements = await achievementService.getAllAchievements();
        final catch10 = achievements.firstWhere((a) => a.id == 'catch_10');
        expect(catch10.isUnlocked, isTrue);
      });
    });

    // ─── FIX B: equipment_combo_20 ───
    group('equipment combo (FIX B)', () {
      test('equipmentComboMax is max catchCount across equipment', () async {
        when(mockStatsRepo.getEquipmentCatchStats).thenAnswer(
          (_) async => {
            1: const EquipmentCatchStats(equipmentId: 1, catchCount: 8),
            2: const EquipmentCatchStats(equipmentId: 2, catchCount: 25),
            3: const EquipmentCatchStats(equipmentId: 3, catchCount: 12),
          },
        );

        final achievements = await achievementService.getAllAchievements();
        final combo =
            achievements.firstWhere((a) => a.id == 'equipment_combo_20');
        // max(8,25,12)=25 >= target 20 → unlocked.
        expect(combo.isUnlocked, isTrue);
      });

      test('equipmentComboMax is 0 when no equipment stats', () async {
        when(mockStatsRepo.getEquipmentCatchStats).thenAnswer((_) async => {});

        final achievements = await achievementService.getAllAchievements();
        final combo =
            achievements.firstWhere((a) => a.id == 'equipment_combo_20');
        expect(combo.current, equals(0));
        expect(combo.isUnlocked, isFalse);
      });
    });

    // ─── FIX C: release_rate_80 最小样本量 ───
    group('release rate sample size (FIX C)', () {
      test('single released catch does NOT unlock release_rate_80', () async {
        when(mockStatsRepo.getTotalCatchCount).thenAnswer((_) async => 1);
        when(mockStatsRepo.getReleaseCount).thenAnswer((_) async => 1);
        when(mockStatsRepo.getReleaseRate).thenAnswer((_) async => 1.0);

        final achievements = await achievementService.getAllAchievements();
        final rate = achievements.firstWhere((a) => a.id == 'release_rate_80');
        expect(rate.isUnlocked, isFalse);
      });

      test('5 catches with rate >= 0.8 unlocks release_rate_80', () async {
        when(mockStatsRepo.getTotalCatchCount).thenAnswer((_) async => 5);
        when(mockStatsRepo.getReleaseCount).thenAnswer((_) async => 4);
        when(mockStatsRepo.getReleaseRate).thenAnswer((_) async => 0.8);

        final achievements = await achievementService.getAllAchievements();
        final rate = achievements.firstWhere((a) => a.id == 'release_rate_80');
        expect(rate.isUnlocked, isTrue);
      });
    });

    // ─── FIX E: 装备成就计 "拥有" 数量 ───
    group('owned equipment count (FIX E)', () {
      test('equipment achievements use getOwnedEquipmentCount', () async {
        when(mockStatsRepo.getOwnedEquipmentCount).thenAnswer((_) async => 10);

        final achievements = await achievementService.getAllAchievements();
        final equipment5 =
            achievements.firstWhere((a) => a.id == 'equipment_5');
        // target 10, owned 10 → unlocked.
        expect(equipment5.isUnlocked, isTrue);
        verify(mockStatsRepo.getOwnedEquipmentCount).called(1);
      });
    });

    // ─── FIX H: share_5 分享计数 ───
    group('share count (FIX H)', () {
      test('shareCount metric reflects stored share_count', () async {
        fakeSettingsRepo.store['share_count'] = '5';

        final achievements = await achievementService.getAllAchievements();
        final share5 = achievements.firstWhere((a) => a.id == 'share_5');
        expect(share5.isUnlocked, isTrue);
      });

      test('share_5 locked when no shares recorded', () async {
        final achievements = await achievementService.getAllAchievements();
        final share5 = achievements.firstWhere((a) => a.id == 'share_5');
        expect(share5.isUnlocked, isFalse);
        expect(share5.current, equals(0));
      });

      test('incrementShareCount bumps the stored counter', () async {
        expect(await fakeSettingsRepo.getInt('share_count'), equals(0));

        await AchievementService.incrementShareCount(fakeSettingsRepo);
        expect(await fakeSettingsRepo.getInt('share_count'), equals(1));

        await AchievementService.incrementShareCount(fakeSettingsRepo);
        expect(await fakeSettingsRepo.getInt('share_count'), equals(2));
      });

      test('incrementShareCount tolerates write failure', () async {
        fakeSettingsRepo.setError = Exception('disk full');
        // Should not throw.
        await AchievementService.incrementShareCount(fakeSettingsRepo);
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
          stats['totalCount'],
          equals(AchievementConfig.definitions.length),
        );
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

    // ─── FIX D: 晨钓/夜钓描述与实现窗口一致 ───
    test('morning/night descriptions match query windows (FIX D)', () {
      final morning =
          AchievementConfig.definitions.firstWhere((d) => d.id == 'morning_20');
      final night =
          AchievementConfig.definitions.firstWhere((d) => d.id == 'night_20');
      expect(morning.description, equals('上午5-9点记录20条鱼获'));
      expect(night.description, equals('晚上8点至次日5点记录20条鱼获'));
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
