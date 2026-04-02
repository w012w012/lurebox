import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/stats_models.dart';

void main() {
  group('CatchStats', () {
    late CatchStats testInstance;

    setUp(() {
      testInstance = const CatchStats(total: 10, release: 7, keep: 3);
    });

    test('creates CatchStats with required fields', () {
      expect(testInstance.total, equals(10));
      expect(testInstance.release, equals(7));
      expect(testInstance.keep, equals(3));
    });

    test('releaseRate calculates correctly', () {
      expect(testInstance.releaseRate, closeTo(0.7, 0.001));

      const zeroStats = CatchStats(total: 0, release: 0, keep: 0);
      expect(zeroStats.releaseRate, equals(0.0));

      const allReleased = CatchStats(total: 5, release: 5, keep: 0);
      expect(allReleased.releaseRate, equals(1.0));
    });

    test('fromMap creates CatchStats from map', () {
      final map = {'total': 20, 'release': 15, 'keep': 5};

      final result = CatchStats.fromMap(map);

      expect(result.total, equals(20));
      expect(result.release, equals(15));
      expect(result.keep, equals(5));
    });

    test('fromMap handles null values', () {
      final map = <String, dynamic>{};

      final result = CatchStats.fromMap(map);

      expect(result.total, equals(0));
      expect(result.release, equals(0));
      expect(result.keep, equals(0));
    });

    test('toMap converts CatchStats to map', () {
      final map = testInstance.toMap();

      expect(map['total'], equals(10));
      expect(map['release'], equals(7));
      expect(map['keep'], equals(3));
    });

    test('copyWith creates modified copy', () {
      final copy = testInstance.copyWith(total: 20, release: 15);

      expect(copy.total, equals(20));
      expect(copy.release, equals(15));
      expect(copy.keep, equals(3));
    });
  });

  group('EquipmentCatchStats', () {
    test('creates EquipmentCatchStats with required fields', () {
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

    test('fromMap creates EquipmentCatchStats from map', () {
      final map = {
        'equipment_id': 2,
        'catch_count': 5,
        'avg_length': 25.0,
        'avg_weight': 1.5,
        'release_count': 3,
      };

      final result = EquipmentCatchStats.fromMap(map);

      expect(result.equipmentId, equals(2));
      expect(result.catchCount, equals(5));
      expect(result.avgLength, equals(25.0));
      expect(result.avgWeight, equals(1.5));
      expect(result.releaseCount, equals(3));
    });

    test('toMap converts EquipmentCatchStats to map', () {
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

  group('DashboardData', () {
    test('creates DashboardData with all fields', () {
      const todaySpecies = {'Bass': 3, 'Trout': 2};
      const monthSpecies = {'Bass': 30, 'Trout': 20};
      const yearSpecies = {'Bass': 120, 'Trout': 80};
      const allSpecies = {'Bass': 300, 'Trout': 200};
      const top3Longest = [
        {'id': 1, 'length': 50.0},
        {'id': 2, 'length': 45.0},
        {'id': 3, 'length': 40.0},
      ];
      const dashboard = DashboardData(
        todayStats: CatchStats(total: 5, release: 3, keep: 2),
        todaySpecies: todaySpecies,
        monthStats: CatchStats(total: 50, release: 35, keep: 15),
        monthSpecies: monthSpecies,
        yearStats: CatchStats(total: 200, release: 140, keep: 60),
        yearSpecies: yearSpecies,
        allStats: CatchStats(total: 500, release: 350, keep: 150),
        allSpecies: allSpecies,
        top3Longest: top3Longest,
      );

      expect(dashboard.todayStats.total, equals(5));
      expect(dashboard.todaySpecies['Bass'], equals(3));
      expect(dashboard.monthStats.total, equals(50));
      expect(dashboard.yearStats.total, equals(200));
      expect(dashboard.allStats.total, equals(500));
      expect(dashboard.top3Longest.length, equals(3));
    });
  });

  group('AchievementMetrics', () {
    test('creates AchievementMetrics with default values', () {
      const metrics = AchievementMetrics();

      expect(metrics.totalCatches, equals(0));
      expect(metrics.maxLength, equals(0.0));
      expect(metrics.speciesCount, equals(0));
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
      );

      expect(metrics.totalCatches, equals(100));
      expect(metrics.maxLength, equals(50.0));
      expect(metrics.speciesCount, equals(10));
      expect(metrics.equipmentCount, equals(5));
      expect(metrics.locationCount, equals(3));
      expect(metrics.releaseCount, equals(70));
      expect(metrics.releaseRate, equals(0.7));
      expect(metrics.consecutiveDays, equals(7));
    });

    test('copyWith creates modified copy', () {
      const original = AchievementMetrics(totalCatches: 50, speciesCount: 5);

      final copy = original.copyWith(totalCatches: 100, maxLength: 30.0);

      expect(copy.totalCatches, equals(100));
      expect(copy.maxLength, equals(30.0));
      expect(copy.speciesCount, equals(5));
    });
  });
}
