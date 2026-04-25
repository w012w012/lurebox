import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/achievements.dart';
import 'package:lurebox/core/models/achievement.dart';

void main() {
  group('AchievementDefinition', () {
    test('creates instance with all required fields', () {
      const definition = AchievementDefinition(
        id: 'test_id',
        title: 'Test Title',
        description: 'Test Description',
        icon: '🎣',
        level: AchievementLevel.bronze,
        category: 'Test Category',
        target: 10,
      );

      expect(definition.id, equals('test_id'));
      expect(definition.title, equals('Test Title'));
      expect(definition.description, equals('Test Description'));
      expect(definition.icon, equals('🎣'));
      expect(definition.level, equals(AchievementLevel.bronze));
      expect(definition.category, equals('Test Category'));
      expect(definition.target, equals(10));
    });
  });

  group('AchievementConfig', () {
    test('definitions list is not empty', () {
      expect(AchievementConfig.definitions, isNotEmpty);
    });

    test('all definitions have unique ids', () {
      final ids = AchievementConfig.definitions.map((d) => d.id).toList();
      final uniqueIds = ids.toSet();
      expect(uniqueIds.length, equals(ids.length),
          reason: 'All achievement IDs should be unique',);
    });

    test('all definitions have non-empty required fields', () {
      for (final definition in AchievementConfig.definitions) {
        expect(definition.id, isNotEmpty,
            reason: 'Definition ${definition.id} has empty id',);
        expect(definition.title, isNotEmpty,
            reason: 'Definition ${definition.id} has empty title',);
        expect(definition.description, isNotEmpty,
            reason: 'Definition ${definition.id} has empty description',);
        expect(definition.icon, isNotEmpty,
            reason: 'Definition ${definition.id} has empty icon',);
        expect(definition.category, isNotEmpty,
            reason: 'Definition ${definition.id} has empty category',);
      }
    });

    test('all definitions have valid AchievementLevel', () {
      for (final definition in AchievementConfig.definitions) {
        expect(AchievementLevel.values, contains(definition.level),
            reason: 'Definition ${definition.id} has invalid level',);
      }
    });

    test('all definitions have positive target', () {
      for (final definition in AchievementConfig.definitions) {
        expect(definition.target, greaterThan(0),
            reason: 'Definition ${definition.id} has non-positive target',);
      }
    });

    test('definitions cover all expected categories', () {
      final categories =
          AchievementConfig.definitions.map((d) => d.category).toSet();

      expect(categories, contains('数量类'));
      expect(categories, contains('尺寸类'));
      expect(categories, contains('品种类'));
      expect(categories, contains('装备类'));
      expect(categories, contains('地点类'));
      expect(categories, contains('环保类'));
      expect(categories, contains('特殊成就'));
    });

    group('数量类 (Catch Count) achievements', () {
      final catchAchievements = AchievementConfig.definitions
          .where((d) => d.category == '数量类')
          .toList();

      test('has correct count of achievements', () {
        expect(catchAchievements.length, equals(5));
      });

      test('has correct targets', () {
        expect(
            catchAchievements
                .any((d) => d.id == 'catch_first' && d.target == 1),
            isTrue,);
        expect(
            catchAchievements.any((d) => d.id == 'catch_10' && d.target == 10),
            isTrue,);
        expect(
            catchAchievements
                .any((d) => d.id == 'catch_100' && d.target == 100),
            isTrue,);
        expect(
            catchAchievements
                .any((d) => d.id == 'catch_500' && d.target == 500),
            isTrue,);
        expect(
            catchAchievements
                .any((d) => d.id == 'catch_1000' && d.target == 1000),
            isTrue,);
      });

      test('targets are in ascending order', () {
        final targets = catchAchievements.map((d) => d.target).toList();
        expect(targets, equals([1, 10, 100, 500, 1000]));
      });

      test('has all required levels', () {
        final levels = catchAchievements.map((d) => d.level).toSet();
        expect(levels, contains(AchievementLevel.bronze));
        expect(levels, contains(AchievementLevel.silver));
        expect(levels, contains(AchievementLevel.gold));
        expect(levels, contains(AchievementLevel.platinum));
      });
    });

    group('尺寸类 (Length) achievements', () {
      final lengthAchievements = AchievementConfig.definitions
          .where((d) => d.category == '尺寸类')
          .toList();

      test('has correct count of achievements', () {
        expect(lengthAchievements.length, equals(5));
      });

      test('all have target of 1 (one-time achievements)', () {
        for (final achievement in lengthAchievements) {
          expect(achievement.target, equals(1),
              reason: '${achievement.id} should have target of 1',);
        }
      });

      test('covers length thresholds', () {
        expect(lengthAchievements.any((d) => d.id == 'length_30'), isTrue);
        expect(lengthAchievements.any((d) => d.id == 'length_50'), isTrue);
        expect(lengthAchievements.any((d) => d.id == 'length_70'), isTrue);
        expect(lengthAchievements.any((d) => d.id == 'length_90'), isTrue);
        expect(lengthAchievements.any((d) => d.id == 'length_120'), isTrue);
      });
    });

    group('品种类 (Species) achievements', () {
      final speciesAchievements = AchievementConfig.definitions
          .where((d) => d.category == '品种类')
          .toList();

      test('has correct count of achievements', () {
        expect(speciesAchievements.length, equals(5));
      });

      test('targets are correct', () {
        final targets = speciesAchievements.map((d) => d.target).toList();
        expect(targets, equals([3, 5, 10, 15, 20]));
      });
    });

    group('装备类 (Equipment) achievements', () {
      final equipmentAchievements = AchievementConfig.definitions
          .where((d) => d.category == '装备类')
          .toList();

      test('has correct count of achievements', () {
        expect(equipmentAchievements.length, equals(5));
      });

      test('targets are correct', () {
        final targets = equipmentAchievements.map((d) => d.target).toList();
        expect(targets, equals([1, 10, 20, 30, 50]));
      });
    });

    group('地点类 (Location) achievements', () {
      final locationAchievements = AchievementConfig.definitions
          .where((d) => d.category == '地点类')
          .toList();

      test('has correct count of achievements', () {
        expect(locationAchievements.length, equals(5));
      });

      test('targets are correct', () {
        final targets = locationAchievements.map((d) => d.target).toList();
        expect(targets, equals([3, 10, 20, 30, 50]));
      });
    });

    group('环保类 (Release) achievements', () {
      final releaseAchievements = AchievementConfig.definitions
          .where((d) => d.category == '环保类')
          .toList();

      test('has correct count of achievements', () {
        expect(releaseAchievements.length, equals(5));
      });

      test('has release count and rate achievements', () {
        final ids = releaseAchievements.map((d) => d.id).toList();
        expect(ids, contains('release_10'));
        expect(ids, contains('release_50'));
        expect(ids, contains('release_100'));
        expect(ids, contains('release_200'));
        expect(ids, contains('release_rate_80'));
      });
    });

    group('特殊成就 (Special) achievements', () {
      final specialAchievements = AchievementConfig.definitions
          .where((d) => d.category == '特殊成就')
          .toList();

      test('has correct count of achievements', () {
        expect(specialAchievements.length, equals(10));
      });

      test('covers various special achievement types', () {
        final ids = specialAchievements.map((d) => d.id).toSet();

        expect(ids, contains('consecutive_7'));
        expect(ids, contains('monthly_30'));
        expect(ids, contains('share_5'));
        expect(ids, contains('new_record'));
        expect(ids, contains('daily_5'));
        expect(ids, contains('morning_20'));
        expect(ids, contains('night_20'));
        expect(ids, contains('photos_100'));
        expect(ids, contains('total_weight_10'));
        expect(ids, contains('equipment_combo_20'));
      });
    });

    group('achievement levels distribution', () {
      test('bronze level achievements exist', () {
        final bronzeAchievements = AchievementConfig.definitions
            .where((d) => d.level == AchievementLevel.bronze)
            .toList();
        expect(bronzeAchievements, isNotEmpty);
      });

      test('silver level achievements exist', () {
        final silverAchievements = AchievementConfig.definitions
            .where((d) => d.level == AchievementLevel.silver)
            .toList();
        expect(silverAchievements, isNotEmpty);
      });

      test('gold level achievements exist', () {
        final goldAchievements = AchievementConfig.definitions
            .where((d) => d.level == AchievementLevel.gold)
            .toList();
        expect(goldAchievements, isNotEmpty);
      });

      test('platinum level achievements exist', () {
        final platinumAchievements = AchievementConfig.definitions
            .where((d) => d.level == AchievementLevel.platinum)
            .toList();
        expect(platinumAchievements, isNotEmpty);
      });

      test('each category has non-decreasing level progression', () {
        final categories = [
          '数量类',
          '品种类',
          '装备类',
          '地点类',
        ];

        for (final category in categories) {
          final categoryDefs = AchievementConfig.definitions
              .where((d) => d.category == category)
              .toList();

          // Sort by target ascending
          categoryDefs.sort((a, b) => a.target.compareTo(b.target));

          // Each subsequent achievement should have >= level (allowing same level)
          for (var i = 0; i < categoryDefs.length - 1; i++) {
            final current = categoryDefs[i];
            final next = categoryDefs[i + 1];
            expect(
              current.level.index <= next.level.index,
              isTrue,
              reason:
                  '$category: ${current.id} (${current.level}) should not have higher level than ${next.id} (${next.level})',
            );
          }
        }
      });

      test('环保类 has valid structure with rate achievement', () {
        final releaseAchievements = AchievementConfig.definitions
            .where((d) => d.category == '环保类')
            .toList();

        // release_rate_80 is a special one-time achievement with target=1
        // It's designed to be harder than release_10 (silver vs bronze)
        final rate80 =
            releaseAchievements.firstWhere((d) => d.id == 'release_rate_80');
        expect(rate80.level, equals(AchievementLevel.silver));
        expect(rate80.target, equals(1));
      });
    });

    group('specific achievement validation', () {
      test('catch_first has correct bronze level and target', () {
        final def = AchievementConfig.definitions
            .firstWhere((d) => d.id == 'catch_first');
        expect(def.level, equals(AchievementLevel.bronze));
        expect(def.target, equals(1));
        expect(def.icon, equals('🎣'));
      });

      test('catch_1000 has platinum level', () {
        final def = AchievementConfig.definitions
            .firstWhere((d) => d.id == 'catch_1000');
        expect(def.level, equals(AchievementLevel.platinum));
        expect(def.target, equals(1000));
      });

      test('equipment_full is the equipment milestone', () {
        final def = AchievementConfig.definitions
            .firstWhere((d) => d.id == 'equipment_full');
        expect(def.target, equals(1));
        expect(def.level, equals(AchievementLevel.bronze));
      });

      test('new_record is a special one-time achievement', () {
        final def = AchievementConfig.definitions
            .firstWhere((d) => d.id == 'new_record');
        expect(def.target, equals(1));
        expect(def.level, equals(AchievementLevel.gold));
      });
    });
  });

  group('AchievementLevel from imported model', () {
    test('all level values are accessible', () {
      expect(AchievementLevel.values.length, equals(4));
    });

    test('jsonName returns correct English names', () {
      expect(AchievementLevel.bronze.jsonName, equals('bronze'));
      expect(AchievementLevel.silver.jsonName, equals('silver'));
      expect(AchievementLevel.gold.jsonName, equals('gold'));
      expect(AchievementLevel.platinum.jsonName, equals('platinum'));
    });
  });
}
