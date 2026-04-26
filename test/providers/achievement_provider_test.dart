import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/achievement.dart';
import 'package:lurebox/core/providers/achievement_provider.dart';
import 'package:lurebox/core/services/achievement_service.dart';

class MockAchievementService extends Mock implements AchievementService {}

void main() {
  late MockAchievementService mockService;

  setUpAll(() {
    registerFallbackValue(const Achievement(
      id: 'test',
      title: 'Test',
      description: 'Test',
      icon: 'test',
      level: AchievementLevel.bronze,
      category: 'test',
      target: 1,
      current: 0,
      progress: 0,
    ));
  });

  setUp(() {
    mockService = MockAchievementService();
    when(() => mockService.getAllAchievements())
        .thenAnswer((_) async => <Achievement>[]);
    when(() => mockService.getAchievementStats())
        .thenAnswer((_) async => <String, dynamic>{});
  });

  group('allAchievementsProvider', () {
    test('returns list of achievements from service', () async {
      final achievements = [
        Achievement(
          id: 'catch_first',
          title: '首次钓获',
          description: '记录你的第一条鱼',
          icon: 'fish',
          level: AchievementLevel.bronze,
          category: 'catch',
          target: 1,
          current: 1,
          progress: 100,
        ),
      ];
      when(() => mockService.getAllAchievements())
          .thenAnswer((_) async => achievements);

      final container = ProviderContainer(
        overrides: [
          achievementServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(allAchievementsProvider.future);

      expect(result, achievements);
      expect(result.length, 1);
      expect(result.first.id, 'catch_first');
    });

    test('returns empty list when no achievements', () async {
      when(() => mockService.getAllAchievements())
          .thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [
          achievementServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(allAchievementsProvider.future);

      expect(result, isEmpty);
    });

    test('service is called exactly once due to caching', () async {
      when(() => mockService.getAllAchievements())
          .thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [
          achievementServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      // Read twice - service should only be called once due to FutureProvider caching
      await container.read(allAchievementsProvider.future);
      await container.read(allAchievementsProvider.future);

      verify(() => mockService.getAllAchievements()).called(1);
    });
  });

  group('achievementStatsProvider', () {
    test('returns stats map from service', () async {
      final stats = {
        'unlockedCount': 5,
        'totalCount': 20,
        'progress': 25,
      };
      when(() => mockService.getAchievementStats())
          .thenAnswer((_) async => stats);

      final container = ProviderContainer(
        overrides: [
          achievementServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(achievementStatsProvider.future);

      expect(result['unlockedCount'], 5);
      expect(result['totalCount'], 20);
      expect(result['progress'], 25);
    });

    test('returns empty map when service returns empty stats', () async {
      when(() => mockService.getAchievementStats())
          .thenAnswer((_) async => <String, dynamic>{});

      final container = ProviderContainer(
        overrides: [
          achievementServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(achievementStatsProvider.future);

      expect(result, isA<Map<String, dynamic>>());
      expect(result, isEmpty);
    });
  });

  group('achievement unlock state', () {
    test('achievement isUnlocked returns true when current >= target',
        () {
      final achievement = Achievement(
        id: 'catch_10',
        title: '10尾钓获',
        description: '累计钓获10尾鱼',
        icon: 'fish',
        level: AchievementLevel.silver,
        category: 'catch',
        target: 10,
        current: 10,
        progress: 100,
      );

      expect(achievement.isUnlocked, isTrue);
      expect(achievement.isLocked, isFalse);
    });

    test('achievement isLocked returns true when current < target', () {
      final achievement = Achievement(
        id: 'catch_10',
        title: '10尾钓获',
        description: '累计钓获10尾鱼',
        icon: 'fish',
        level: AchievementLevel.silver,
        category: 'catch',
        target: 10,
        current: 5,
        progress: 50,
      );

      expect(achievement.isLocked, isTrue);
      expect(achievement.isUnlocked, isFalse);
    });

    test('progressPercent calculates correctly', () {
      final achievement = Achievement(
        id: 'catch_10',
        title: '10尾钓获',
        description: '累计钓获10尾鱼',
        icon: 'fish',
        level: AchievementLevel.silver,
        category: 'catch',
        target: 10,
        current: 5,
        progress: 50,
      );

      expect(achievement.progressPercent, 50.0);
    });
  });
}
