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

      const allKept = CatchStats(total: 5, release: 0, keep: 5);
      expect(allKept.releaseRate, equals(0.0));
    });

    test('round-trip: fromMap -> toMap preserves data', () {
      const original = CatchStats(total: 15, release: 10, keep: 5);
      final map = original.toMap();
      final restored = CatchStats.fromMap(map);

      expect(restored.total, equals(original.total));
      expect(restored.release, equals(original.release));
      expect(restored.keep, equals(original.keep));
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

    test('equality: two CatchStats with same values are equal', () {
      const stats1 = CatchStats(total: 10, release: 5, keep: 5);
      const stats2 = CatchStats(total: 10, release: 5, keep: 5);

      expect(stats1, equals(stats2));
    });

    test('equality: two CatchStats with different values are not equal', () {
      const stats1 = CatchStats(total: 10, release: 5, keep: 5);
      const stats2 = CatchStats(total: 10, release: 6, keep: 4);

      expect(stats1, isNot(equals(stats2)));
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

    test('round-trip: fromMap -> toMap preserves data', () {
      const original = EquipmentCatchStats(
        equipmentId: 5,
        catchCount: 25,
        avgLength: 35.5,
        avgWeight: 3.2,
        releaseCount: 18,
      );
      final map = original.toMap();
      final restored = EquipmentCatchStats.fromMap(map);

      expect(restored.equipmentId, equals(original.equipmentId));
      expect(restored.catchCount, equals(original.catchCount));
      expect(restored.avgLength, equals(original.avgLength));
      expect(restored.avgWeight, equals(original.avgWeight));
      expect(restored.releaseCount, equals(original.releaseCount));
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

    test('copyWith creates modified copy', () {
      const original = EquipmentCatchStats(
        equipmentId: 1,
        catchCount: 10,
        avgLength: 30,
        avgWeight: 2,
        releaseCount: 5,
      );

      final copy = original.copyWith(catchCount: 20, releaseCount: 15);

      expect(copy.equipmentId, equals(1));
      expect(copy.catchCount, equals(20));
      expect(copy.avgLength, equals(30.0));
      expect(copy.avgWeight, equals(2.0));
      expect(copy.releaseCount, equals(15));
    });

    test('fromMap handles null optional fields', () {
      final map = {
        'equipment_id': 1,
        'catch_count': 5,
      };

      final result = EquipmentCatchStats.fromMap(map);

      expect(result.avgLength, isNull);
      expect(result.avgWeight, isNull);
    });

    test('equality: two EquipmentCatchStats with same values are equal', () {
      const stats1 = EquipmentCatchStats(
        equipmentId: 1,
        catchCount: 10,
        avgLength: 30,
        avgWeight: 2,
        releaseCount: 5,
      );
      const stats2 = EquipmentCatchStats(
        equipmentId: 1,
        catchCount: 10,
        avgLength: 30,
        avgWeight: 2,
        releaseCount: 5,
      );

      expect(stats1, equals(stats2));
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

    test('aggregates species counts correctly across time periods', () {
      const dashboard = DashboardData(
        todayStats: CatchStats(total: 2, release: 1, keep: 1),
        todaySpecies: {'Bass': 2},
        monthStats: CatchStats(total: 20, release: 15, keep: 5),
        monthSpecies: {'Bass': 15, 'Trout': 5},
        yearStats: CatchStats(total: 100, release: 80, keep: 20),
        yearSpecies: {'Bass': 60, 'Trout': 30, 'Carp': 10},
        allStats: CatchStats(total: 500, release: 350, keep: 150),
        allSpecies: {'Bass': 200, 'Trout': 150, 'Carp': 100, 'Pike': 50},
        top3Longest: [],
      );

      // Verify species counts increase over time periods
      expect(dashboard.todaySpecies.length, lessThan(dashboard.monthSpecies.length));
      expect(dashboard.monthSpecies.length, lessThan(dashboard.yearSpecies.length));
      expect(dashboard.yearSpecies.length, lessThan(dashboard.allSpecies.length));
    });

    test('calculates release rates for all time periods', () {
      const dashboard = DashboardData(
        todayStats: CatchStats(total: 4, release: 3, keep: 1),
        todaySpecies: {'Bass': 4},
        monthStats: CatchStats(total: 20, release: 10, keep: 10),
        monthSpecies: {'Bass': 20},
        yearStats: CatchStats(total: 100, release: 70, keep: 30),
        yearSpecies: {'Bass': 100},
        allStats: CatchStats(total: 200, release: 100, keep: 100),
        allSpecies: {'Bass': 200},
        top3Longest: [],
      );

      expect(dashboard.todayStats.releaseRate, equals(0.75));
      expect(dashboard.monthStats.releaseRate, equals(0.5));
      expect(dashboard.yearStats.releaseRate, equals(0.7));
      expect(dashboard.allStats.releaseRate, equals(0.5));
    });

    test('handles empty top3Longest list', () {
      const dashboard = DashboardData(
        todayStats: CatchStats(total: 0, release: 0, keep: 0),
        todaySpecies: {},
        monthStats: CatchStats(total: 0, release: 0, keep: 0),
        monthSpecies: {},
        yearStats: CatchStats(total: 0, release: 0, keep: 0),
        yearSpecies: {},
        allStats: CatchStats(total: 0, release: 0, keep: 0),
        allSpecies: {},
        top3Longest: [],
      );

      expect(dashboard.top3Longest, isEmpty);
    });

    test('top3Longest contains id and length for each entry', () {
      const top3Longest = [
        {'id': 1, 'length': 50.0},
        {'id': 2, 'length': 45.0},
        {'id': 3, 'length': 40.0},
      ];
      const dashboard = DashboardData(
        todayStats: CatchStats(total: 3, release: 2, keep: 1),
        todaySpecies: {'Bass': 3},
        monthStats: CatchStats(total: 3, release: 2, keep: 1),
        monthSpecies: {'Bass': 3},
        yearStats: CatchStats(total: 3, release: 2, keep: 1),
        yearSpecies: {'Bass': 3},
        allStats: CatchStats(total: 3, release: 2, keep: 1),
        allSpecies: {'Bass': 3},
        top3Longest: top3Longest,
      );

      for (final entry in dashboard.top3Longest) {
        expect(entry.containsKey('id'), isTrue);
        expect(entry.containsKey('length'), isTrue);
        expect(entry['id'], isA<int>());
        expect(entry['length'], isA<double>());
      }
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
      expect(metrics.equipmentFull, isFalse);
      expect(metrics.newRecord, isFalse);
    });

    test('creates AchievementMetrics with custom values', () {
      const metrics = AchievementMetrics(
        totalCatches: 100,
        maxLength: 50,
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

      final copy = original.copyWith(totalCatches: 100, maxLength: 30);

      expect(copy.totalCatches, equals(100));
      expect(copy.maxLength, equals(30.0));
      expect(copy.speciesCount, equals(5));
    });

    test('copyWith preserves unmodified fields', () {
      const original = AchievementMetrics(
        totalCatches: 50,
        maxLength: 25,
        speciesCount: 5,
        equipmentCount: 3,
        locationCount: 2,
        releaseCount: 30,
        releaseRate: 0.6,
        consecutiveDays: 5,
        morningCatches: 10,
        nightCatches: 8,
      );

      final copy = original.copyWith(totalCatches: 100);

      expect(copy.totalCatches, equals(100));
      expect(copy.maxLength, equals(25.0));
      expect(copy.speciesCount, equals(5));
      expect(copy.equipmentCount, equals(3));
      expect(copy.locationCount, equals(2));
      expect(copy.releaseCount, equals(30));
      expect(copy.releaseRate, equals(0.6));
      expect(copy.consecutiveDays, equals(5));
      expect(copy.morningCatches, equals(10));
      expect(copy.nightCatches, equals(8));
    });

    test('handles achievement flags correctly', () {
      const metrics = AchievementMetrics(
        equipmentFull: true,
        newRecord: true,
      );

      expect(metrics.equipmentFull, isTrue);
      expect(metrics.newRecord, isTrue);
    });

    test('handles count-based achievements', () {
      const metrics = AchievementMetrics(
        totalCatches: 1000,
        speciesCount: 50,
        photoCount: 200,
        shareCount: 50,
      );

      expect(metrics.totalCatches, equals(1000));
      expect(metrics.speciesCount, equals(50));
      expect(metrics.photoCount, equals(200));
      expect(metrics.shareCount, equals(50));
    });

    test('handles weight and length achievements', () {
      const metrics = AchievementMetrics(
        maxLength: 120.5,
        totalWeight: 500,
      );

      expect(metrics.maxLength, equals(120.5));
      expect(metrics.totalWeight, equals(500.0));
    });

    test('handles combo achievements', () {
      const metrics = AchievementMetrics(
        equipmentComboMax: 5,
        equipmentFull: true,
      );

      expect(metrics.equipmentComboMax, equals(5));
      expect(metrics.equipmentFull, isTrue);
    });
  });
}
