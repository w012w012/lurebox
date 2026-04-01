import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lurebox/core/models/stats_models.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('CatchStats', () {
    test('creates CatchStats with correct values', () {
      const stats = CatchStats(total: 10, release: 7, keep: 3);

      expect(stats.total, equals(10));
      expect(stats.release, equals(7));
      expect(stats.keep, equals(3));
    });

    test('releaseRate calculates correctly', () {
      const stats = CatchStats(total: 10, release: 7, keep: 3);
      expect(stats.releaseRate, closeTo(0.7, 0.01));

      const emptyStats = CatchStats(total: 0, release: 0, keep: 0);
      expect(emptyStats.releaseRate, equals(0.0));

      const allReleased = CatchStats(total: 5, release: 5, keep: 0);
      expect(allReleased.releaseRate, equals(1.0));

      const halfReleased = CatchStats(total: 8, release: 4, keep: 4);
      expect(halfReleased.releaseRate, equals(0.5));
    });

    test('copyWith works correctly', () {
      const original = CatchStats(total: 10, release: 7, keep: 3);

      final copyTotal = original.copyWith(total: 20);
      expect(copyTotal.total, equals(20));
      expect(copyTotal.release, equals(7));
      expect(copyTotal.keep, equals(3));

      final copyRelease = original.copyWith(release: 10);
      expect(copyRelease.total, equals(10));
      expect(copyRelease.release, equals(10));
      expect(copyRelease.keep, equals(3));

      final copyAll = original.copyWith(total: 30, release: 20, keep: 10);
      expect(copyAll.total, equals(30));
      expect(copyAll.release, equals(20));
      expect(copyAll.keep, equals(10));
    });

    test('fromMap handles valid data', () {
      final map = {'total': 15, 'release': 10, 'keep': 5};
      final stats = CatchStats.fromMap(map);

      expect(stats.total, equals(15));
      expect(stats.release, equals(10));
      expect(stats.keep, equals(5));
    });

    test('fromMap handles null values', () {
      final map = <String, dynamic>{};
      final stats = CatchStats.fromMap(map);

      expect(stats.total, equals(0));
      expect(stats.release, equals(0));
      expect(stats.keep, equals(0));
    });

    test('fromMap handles partial null values', () {
      final map = {'total': null, 'release': 5, 'keep': null};
      final stats = CatchStats.fromMap(map);

      expect(stats.total, equals(0));
      expect(stats.release, equals(5));
      expect(stats.keep, equals(0));
    });

    test('toMap converts correctly', () {
      const stats = CatchStats(total: 10, release: 7, keep: 3);
      final map = stats.toMap();

      expect(map['total'], equals(10));
      expect(map['release'], equals(7));
      expect(map['keep'], equals(3));
    });
  });

  group('EquipmentCatchStats', () {
    test('creates EquipmentCatchStats with correct values', () {
      const stats = EquipmentCatchStats(
        equipmentId: 1,
        catchCount: 10,
        avgLength: 30.5,
        avgWeight: 2.3,
        releaseCount: 7,
      );

      expect(stats.equipmentId, equals(1));
      expect(stats.catchCount, equals(10));
      expect(stats.avgLength, equals(30.5));
      expect(stats.avgWeight, equals(2.3));
      expect(stats.releaseCount, equals(7));
    });

    test('fromMap handles valid data', () {
      final map = {
        'equipment_id': 2,
        'catch_count': 5,
        'avg_length': 25.0,
        'avg_weight': 1.5,
        'release_count': 3,
      };

      final stats = EquipmentCatchStats.fromMap(map);

      expect(stats.equipmentId, equals(2));
      expect(stats.catchCount, equals(5));
      expect(stats.avgLength, equals(25.0));
      expect(stats.avgWeight, equals(1.5));
      expect(stats.releaseCount, equals(3));
    });

    test('fromMap handles null values', () {
      final map = <String, dynamic>{};
      final stats = EquipmentCatchStats.fromMap(map);

      expect(stats.equipmentId, equals(0));
      expect(stats.catchCount, equals(0));
      expect(stats.avgLength, isNull);
      expect(stats.avgWeight, isNull);
      expect(stats.releaseCount, equals(0));
    });

    test('toMap converts correctly', () {
      const stats = EquipmentCatchStats(
        equipmentId: 1,
        catchCount: 10,
        releaseCount: 7,
      );

      final map = stats.toMap();

      expect(map['equipment_id'], equals(1));
      expect(map['catch_count'], equals(10));
      expect(map['release_count'], equals(7));
    });
  });

  group('AchievementMetrics', () {
    test('creates AchievementMetrics with default values', () {
      const metrics = AchievementMetrics();

      expect(metrics.totalCatches, equals(0));
      expect(metrics.maxLength, equals(0.0));
      expect(metrics.speciesCount, equals(0));
      expect(metrics.equipmentCount, equals(0));
      expect(metrics.locationCount, equals(0));
      expect(metrics.releaseCount, equals(0));
      expect(metrics.releaseRate, equals(0.0));
      expect(metrics.consecutiveDays, equals(0));
      expect(metrics.monthlyMax, equals(0));
      expect(metrics.dailyMax, equals(0));
      expect(metrics.morningCatches, equals(0));
      expect(metrics.nightCatches, equals(0));
      expect(metrics.photoCount, equals(0));
      expect(metrics.totalWeight, equals(0.0));
      expect(metrics.equipmentComboMax, equals(0));
      expect(metrics.equipmentFull, equals(false));
      expect(metrics.newRecord, equals(false));
      expect(metrics.shareCount, equals(0));
    });

    test('creates AchievementMetrics with custom values', () {
      const metrics = AchievementMetrics(
        totalCatches: 100,
        maxLength: 50.0,
        speciesCount: 10,
        equipmentCount: 5,
        locationCount: 3,
        releaseCount: 70,
        releaseRate: 0.7,
        consecutiveDays: 7,
        monthlyMax: 30,
        dailyMax: 10,
        morningCatches: 20,
        nightCatches: 15,
        photoCount: 80,
        totalWeight: 125.5,
        equipmentComboMax: 25,
        equipmentFull: true,
        newRecord: true,
        shareCount: 10,
      );

      expect(metrics.totalCatches, equals(100));
      expect(metrics.maxLength, equals(50.0));
      expect(metrics.speciesCount, equals(10));
      expect(metrics.equipmentCount, equals(5));
      expect(metrics.locationCount, equals(3));
      expect(metrics.releaseCount, equals(70));
      expect(metrics.releaseRate, equals(0.7));
      expect(metrics.consecutiveDays, equals(7));
      expect(metrics.monthlyMax, equals(30));
      expect(metrics.dailyMax, equals(10));
      expect(metrics.morningCatches, equals(20));
      expect(metrics.nightCatches, equals(15));
      expect(metrics.photoCount, equals(80));
      expect(metrics.totalWeight, equals(125.5));
      expect(metrics.equipmentComboMax, equals(25));
      expect(metrics.equipmentFull, equals(true));
      expect(metrics.newRecord, equals(true));
      expect(metrics.shareCount, equals(10));
    });

    test('copyWith creates modified copy', () {
      const original = AchievementMetrics(totalCatches: 50, speciesCount: 5);

      final copy = original.copyWith(totalCatches: 100, maxLength: 30.0);

      expect(copy.totalCatches, equals(100));
      expect(copy.maxLength, equals(30.0));
      expect(copy.speciesCount, equals(5));
    });

    test('copyWith preserves unmodified fields', () {
      const original = AchievementMetrics(
        totalCatches: 50,
        speciesCount: 5,
        locationCount: 3,
      );

      final copy = original.copyWith(totalCatches: 100);

      expect(copy.totalCatches, equals(100));
      expect(copy.speciesCount, equals(5));
      expect(copy.locationCount, equals(3));
    });
  });

  group('DashboardData', () {
    test('creates DashboardData with all fields', () {
      final dashboard = DashboardData(
        todayStats: const CatchStats(total: 5, release: 3, keep: 2),
        todaySpecies: {'Bass': 3, 'Trout': 2},
        monthStats: const CatchStats(total: 50, release: 35, keep: 15),
        monthSpecies: {'Bass': 30, 'Trout': 20},
        yearStats: const CatchStats(total: 200, release: 140, keep: 60),
        yearSpecies: {'Bass': 120, 'Trout': 80},
        allStats: const CatchStats(total: 500, release: 350, keep: 150),
        allSpecies: {'Bass': 300, 'Trout': 200},
        top3Longest: [
          {'id': 1, 'length': 50.0},
          {'id': 2, 'length': 45.0},
          {'id': 3, 'length': 40.0},
        ],
      );

      expect(dashboard.todayStats.total, equals(5));
      expect(dashboard.todaySpecies['Bass'], equals(3));
      expect(dashboard.monthStats.total, equals(50));
      expect(dashboard.yearStats.total, equals(200));
      expect(dashboard.allStats.total, equals(500));
      expect(dashboard.top3Longest.length, equals(3));
    });
  });
}
