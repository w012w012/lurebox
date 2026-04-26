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
    test('definitions list has a reasonable number of achievements', () {
      expect(
        AchievementConfig.definitions.length,
        greaterThanOrEqualTo(10),
      );
    });

    test('all definitions have unique ids', () {
      final ids = AchievementConfig.definitions.map((d) => d.id).toList();
      final uniqueIds = ids.toSet();
      expect(
        uniqueIds.length,
        equals(ids.length),
        reason: 'All achievement IDs should be unique',
      );
    });

    test('all definitions have non-empty required fields', () {
      for (final definition in AchievementConfig.definitions) {
        expect(
          definition.id,
          isNotEmpty,
          reason: 'Definition has empty id',
        );
        expect(
          definition.title,
          isNotEmpty,
          reason: 'Definition ${definition.id} has empty title',
        );
        expect(
          definition.description,
          isNotEmpty,
          reason: 'Definition ${definition.id} has empty description',
        );
        expect(
          definition.icon,
          isNotEmpty,
          reason: 'Definition ${definition.id} has empty icon',
        );
        expect(
          definition.category,
          isNotEmpty,
          reason: 'Definition ${definition.id} has empty category',
        );
      }
    });

    test('all definitions have valid AchievementLevel', () {
      for (final definition in AchievementConfig.definitions) {
        expect(
          AchievementLevel.values,
          contains(definition.level),
          reason: 'Definition ${definition.id} has invalid level',
        );
      }
    });

    test('all definitions have positive target', () {
      for (final definition in AchievementConfig.definitions) {
        expect(
          definition.target,
          greaterThan(0),
          reason: 'Definition ${definition.id} has non-positive target',
        );
      }
    });

    test('all definitions use a known category from the valid set', () {
      final allCategories =
          AchievementConfig.definitions.map((d) => d.category).toSet();

      expect(allCategories, isNotEmpty);
      for (final category in allCategories) {
        expect(category, isNotEmpty);
      }

      for (final definition in AchievementConfig.definitions) {
        expect(
          allCategories,
          contains(definition.category),
          reason:
              'Definition ${definition.id} has unknown category: '
              '${definition.category}',
        );
      }
    });

    test('at least 3 distinct categories are represented', () {
      final categories =
          AchievementConfig.definitions.map((d) => d.category).toSet();
      expect(
        categories.length,
        greaterThanOrEqualTo(3),
        reason: 'Expected at least 3 distinct achievement categories',
      );
    });

    group('per-category invariants', () {
      final allCategories =
          AchievementConfig.definitions.map((d) => d.category).toSet();

      for (final category in allCategories) {
        final categoryDefs = AchievementConfig.definitions
            .where((d) => d.category == category)
            .toList();

        group(category, () {
          test('has at least 2 achievements', () {
            expect(
              categoryDefs.length,
              greaterThanOrEqualTo(2),
              reason: 'Category $category has too few achievements',
            );
          });

          test('all achievements have non-empty IDs', () {
            for (final def in categoryDefs) {
              expect(
                def.id,
                isNotEmpty,
                reason: '$category achievement has empty id',
              );
            }
          });

          test('all achievements have positive targets', () {
            for (final def in categoryDefs) {
              expect(
                def.target,
                greaterThan(0),
                reason: '${def.id} has non-positive target',
              );
            }
          });

          test('at least 2 distinct levels are represented', () {
            final levels = categoryDefs.map((d) => d.level).toSet();
            expect(
              levels.length,
              greaterThanOrEqualTo(2),
              reason:
                  '$category should have at least 2 distinct '
                  'achievement levels',
            );
          });
        });
      }
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

      test('progressive categories have non-decreasing level progression',
          () {
        // Progressive categories are those whose achievements form a
        // single ascending ladder of milestones — each achievement is
        // strictly harder than the last. Categories with mixed-type
        // achievements (e.g. 环保类 with count + rate, or 特殊成就
        // with heterogeneous goals) are excluded because their levels
        // are not monotonic by design.
        final progressiveCategories = [
          '数量类',
          '品种类',
          '装备类',
          '地点类',
        ];

        for (final category in progressiveCategories) {
          final categoryDefs = AchievementConfig.definitions
              .where((d) => d.category == category)
              .toList()
            ..sort((a, b) => a.target.compareTo(b.target));

          for (var i = 0; i < categoryDefs.length - 1; i++) {
            final current = categoryDefs[i];
            final next = categoryDefs[i + 1];
            expect(
              current.level.index <= next.level.index,
              isTrue,
              reason:
                  '$category: ${current.id} (${current.level}) '
                  'should not have higher level than ${next.id} '
                  '(${next.level})',
            );
          }
        }
      });
    });
  });

  group('AchievementLevel from imported model', () {
    test('all level values are accessible', () {
      expect(
        AchievementLevel.values.length,
        greaterThanOrEqualTo(4),
      );
    });

    test('jsonName returns a non-empty string for every level', () {
      for (final level in AchievementLevel.values) {
        expect(
          level.jsonName,
          isNotEmpty,
          reason: '${level.name} has empty jsonName',
        );
      }
    });

    test('jsonName values are unique across all levels', () {
      final names = AchievementLevel.values.map((l) => l.jsonName).toList();
      final uniqueNames = names.toSet();
      expect(
        uniqueNames.length,
        equals(names.length),
        reason: 'jsonName values must be unique across all levels',
      );
    });

    test('fromJson round-trips every level via its jsonName', () {
      for (final level in AchievementLevel.values) {
        final restored = AchievementLevel.fromJson(level.jsonName);
        expect(
          restored,
          equals(level),
          reason:
              'fromJson(${level.jsonName}) did not return $level',
        );
      }
    });
  });
}
