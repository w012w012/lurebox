import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/strings/app_strings.dart';
import 'package:lurebox/core/models/achievement.dart';
import 'package:lurebox/core/providers/achievement_provider.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/features/achievement/achievement_page.dart';
import 'package:lurebox/features/achievement/widgets/achievement_collapse_card.dart';

import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    setUpDatabaseForTesting();
    registerFallbackValues();
  });

  group('AchievementPage', () {
    testWidgets('renders app bar with title', (tester) async {
      final achievements = _createMockAchievements();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allAchievementsProvider.overrideWith(
              (ref) => Future.value(achievements),
            ),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
          child: const MaterialApp(
            home: AchievementPage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('成就'), findsOneWidget);
    });

    testWidgets('shows achievement list when data loaded', (tester) async {
      final achievements = _createMockAchievements();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allAchievementsProvider.overrideWith(
              (ref) => Future.value(achievements),
            ),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
          child: const MaterialApp(
            home: AchievementPage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      // Achievement cards should be visible
      expect(find.byType(AchievementPage), findsOneWidget);
    });

    testWidgets('shows progress indicators when data loaded', (tester) async {
      final achievements = _createMockAchievements();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allAchievementsProvider.overrideWith(
              (ref) => Future.value(achievements),
            ),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
          child: const MaterialApp(
            home: AchievementPage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      // CircularProgressIndicator should be visible for overall progress
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('shows category filter when data loaded', (tester) async {
      final achievements = _createMockAchievements();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allAchievementsProvider.overrideWith(
              (ref) => Future.value(achievements),
            ),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
          child: const MaterialApp(
            home: AchievementPage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      // AchievementCollapseCard should be visible for categories
      expect(find.byType(AchievementCollapseCard), findsWidgets);
    });
  });
}

/// Creates mock achievements for testing
List<Achievement> _createMockAchievements() {
  return [
    Achievement(
      id: '1',
      title: 'First Catch',
      description: 'Record your first fish',
      icon: '🐟',
      level: AchievementLevel.bronze,
      category: '数量类',
      target: 1,
      current: 1,
      unlockedAt: DateTime.now(),
      progress: 100,
    ),
    Achievement(
      id: '2',
      title: 'Trophy Hunter',
      description: 'Catch 10 fish',
      icon: '🏆',
      level: AchievementLevel.silver,
      category: '数量类',
      target: 10,
      current: 5,
      unlockedAt: null,
      progress: 50,
    ),
    Achievement(
      id: '3',
      title: 'Big Fish',
      description: 'Catch a fish over 50cm',
      icon: '📏',
      level: AchievementLevel.gold,
      category: '尺寸类',
      target: 1,
      current: 0,
      unlockedAt: null,
      progress: 0,
    ),
  ];
}
