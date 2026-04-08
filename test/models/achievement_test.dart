import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/achievement.dart';

void main() {
  group('AchievementLevel', () {
    test('name returns correct Chinese name', () {
      expect(AchievementLevel.bronze.name, equals('青铜'));
      expect(AchievementLevel.silver.name, equals('白银'));
      expect(AchievementLevel.gold.name, equals('黄金'));
      expect(AchievementLevel.platinum.name, equals('铂金'));
    });

    test('fromJson parses valid values', () {
      expect(
          AchievementLevel.fromJson('bronze'), equals(AchievementLevel.bronze));
      expect(
          AchievementLevel.fromJson('silver'), equals(AchievementLevel.silver));
      expect(AchievementLevel.fromJson('gold'), equals(AchievementLevel.gold));
      expect(AchievementLevel.fromJson('platinum'),
          equals(AchievementLevel.platinum));
    });

    test('fromJson returns bronze for unknown values', () {
      expect(AchievementLevel.fromJson('unknown'),
          equals(AchievementLevel.bronze));
      expect(AchievementLevel.fromJson(''), equals(AchievementLevel.bronze));
    });
  });

  group('Achievement', () {
    late Achievement achievement;

    setUp(() {
      achievement = Achievement(
        id: 'catch_100',
        title: '百发百中',
        description: '累计捕获100尾鱼',
        icon: '🎣',
        level: AchievementLevel.gold,
        category: 'catch',
        target: 100,
        current: 75,
        progress: 75.0,
      );
    });

    test('creates achievement with required fields', () {
      expect(achievement.id, equals('catch_100'));
      expect(achievement.title, equals('百发百中'));
      expect(achievement.description, equals('累计捕获100尾鱼'));
      expect(achievement.icon, equals('🎣'));
      expect(achievement.level, equals(AchievementLevel.gold));
      expect(achievement.category, equals('catch'));
      expect(achievement.target, equals(100));
      expect(achievement.current, equals(75));
      expect(achievement.unlockedAt, isNull);
      expect(achievement.progress, equals(75.0));
    });

    test('isUnlocked returns true when current >= target', () {
      final unlockedAchievement = Achievement(
        id: 'catch_100',
        title: 'Test',
        description: 'Test',
        icon: '🎣',
        level: AchievementLevel.gold,
        category: 'catch',
        target: 100,
        current: 100,
        progress: 100.0,
      );

      expect(unlockedAchievement.isUnlocked, isTrue);
      expect(unlockedAchievement.isLocked, isFalse);
    });

    test('isUnlocked returns false when current < target', () {
      expect(achievement.isUnlocked, isFalse);
      expect(achievement.isLocked, isTrue);
    });

    test('progressPercent calculates correctly', () {
      expect(achievement.progressPercent, equals(75.0));

      final noProgress = achievement.copyWith(current: 0);
      expect(noProgress.progressPercent, equals(0.0));

      final maxProgress = achievement.copyWith(current: 100);
      expect(maxProgress.progressPercent, equals(100.0));
    });

    test('progressPercent clamps to 100 when current exceeds target', () {
      final overProgress = achievement.copyWith(current: 150);
      expect(overProgress.progressPercent, equals(100.0));
    });

    test('progressPercent clamps to 0 when current is negative', () {
      final negativeProgress = achievement.copyWith(current: -10);
      expect(negativeProgress.progressPercent, equals(0.0));
    });

    test('copyWith creates new instance with updated fields', () {
      final updated = achievement.copyWith(
        current: 100,
        progress: 100.0,
        unlockedAt: DateTime(2024, 6, 15),
      );

      // Original unchanged
      expect(achievement.current, equals(75));
      expect(achievement.unlockedAt, isNull);

      // New instance has updated values
      expect(updated.current, equals(100));
      expect(updated.progress, equals(100.0));
      expect(updated.unlockedAt, equals(DateTime(2024, 6, 15)));

      // Unchanged fields preserved
      expect(updated.id, equals(achievement.id));
      expect(updated.title, equals(achievement.title));
      expect(updated.target, equals(achievement.target));
    });

    test('copyWith preserves all fields when no parameters', () {
      final copy = achievement.copyWith();

      expect(copy.id, equals(achievement.id));
      expect(copy.title, equals(achievement.title));
      expect(copy.description, equals(achievement.description));
      expect(copy.icon, equals(achievement.icon));
      expect(copy.level, equals(achievement.level));
      expect(copy.category, equals(achievement.category));
      expect(copy.target, equals(achievement.target));
      expect(copy.current, equals(achievement.current));
      expect(copy.progress, equals(achievement.progress));
    });

    group('serialization', () {
      test('toJson creates correct map', () {
        final json = achievement.toJson();

        expect(json['id'], equals('catch_100'));
        expect(json['title'], equals('百发百中'));
        expect(json['description'], equals('累计捕获100尾鱼'));
        expect(json['icon'], equals('🎣'));
        expect(json['level'], equals('gold'));
        expect(json['category'], equals('catch'));
        expect(json['target'], equals(100));
        expect(json['current'], equals(75));
        expect(json['unlockedAt'], isNull);
        expect(json['progress'], equals(75.0));
      });

      test('toJson includes unlockedAt when set', () {
        final unlockedAchievement = achievement.copyWith(
          current: 100,
          progress: 100.0,
          unlockedAt: DateTime(2024, 6, 15, 10, 30),
        );

        final json = unlockedAchievement.toJson();
        expect(json['unlockedAt'], equals('2024-06-15T10:30:00.000'));
      });

      test('fromJson creates correct instance', () {
        final json = {
          'id': 'catch_100',
          'title': '百发百中',
          'description': '累计捕获100尾鱼',
          'icon': '🎣',
          'level': 'gold',
          'category': 'catch',
          'target': 100,
          'current': 75,
          'unlockedAt': null,
          'progress': 75.0,
        };

        final fromJsonAchievement = Achievement.fromJson(json);

        expect(fromJsonAchievement.id, equals('catch_100'));
        expect(fromJsonAchievement.title, equals('百发百中'));
        expect(fromJsonAchievement.level, equals(AchievementLevel.gold));
        expect(fromJsonAchievement.target, equals(100));
        expect(fromJsonAchievement.current, equals(75));
        expect(fromJsonAchievement.progress, equals(75.0));
      });

      test('fromJson parses unlockedAt when present', () {
        final json = {
          'id': 'catch_100',
          'title': 'Test',
          'description': 'Test',
          'icon': '🎣',
          'level': 'gold',
          'category': 'catch',
          'target': 100,
          'current': 100,
          'unlockedAt': '2024-06-15T10:30:00.000',
          'progress': 100.0,
        };

        final fromJsonAchievement = Achievement.fromJson(json);
        expect(fromJsonAchievement.unlockedAt,
            equals(DateTime(2024, 6, 15, 10, 30)));
      });

      test('fromJson handles int progress', () {
        final json = {
          'id': 'catch_100',
          'title': 'Test',
          'description': 'Test',
          'icon': '🎣',
          'level': 'gold',
          'category': 'catch',
          'target': 100,
          'current': 100,
          'unlockedAt': null,
          'progress': 100, // int instead of double
        };

        final fromJsonAchievement = Achievement.fromJson(json);
        expect(fromJsonAchievement.progress, equals(100.0));
      });

      test('round-trip serialization preserves data', () {
        final original = Achievement(
          id: 'species_20',
          title: '物种达人',
          description: '解锁20种不同的鱼种',
          icon: '🐟',
          level: AchievementLevel.platinum,
          category: 'species',
          target: 20,
          current: 15,
          unlockedAt: DateTime(2024, 3, 1),
          progress: 75.0,
        );

        final json = original.toJson();
        final restored = Achievement.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.title, equals(original.title));
        expect(restored.description, equals(original.description));
        expect(restored.icon, equals(original.icon));
        expect(restored.level, equals(original.level));
        expect(restored.category, equals(original.category));
        expect(restored.target, equals(original.target));
        expect(restored.current, equals(original.current));
        expect(restored.unlockedAt, equals(original.unlockedAt));
        expect(restored.progress, equals(original.progress));
      });
    });

    test('toString returns readable format', () {
      final str = achievement.toString();

      expect(str, contains('catch_100'));
      expect(str, contains('百发百中'));
      expect(str, contains('current: 75'));
      expect(str, contains('target: 100'));
      expect(str, contains('isUnlocked: false'));
    });

    // Note: Achievement does not override == and hashCode, so default identity comparison is used
  });

  group('Achievement edge cases', () {
    test('handles zero target gracefully', () {
      final achievement = Achievement(
        id: 'test',
        title: 'Test',
        description: 'Test',
        icon: '🎣',
        level: AchievementLevel.bronze,
        category: 'test',
        target: 0,
        current: 0,
        progress: 0.0,
      );

      // Should not divide by zero
      expect(achievement.progressPercent, equals(0.0));
      expect(achievement.isUnlocked, isTrue); // 0 >= 0
    });

    test('handles very large numbers', () {
      final achievement = Achievement(
        id: 'test',
        title: 'Test',
        description: 'Test',
        icon: '🎣',
        level: AchievementLevel.platinum,
        category: 'test',
        target: 1000000,
        current: 999999,
        progress: 99.9999,
      );

      expect(achievement.progressPercent, closeTo(100.0, 0.01));
      expect(achievement.isUnlocked, isFalse);
    });
  });
}
