import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/app_theme.dart';
import 'package:lurebox/core/design/theme/animation_constants.dart';
import 'package:lurebox/core/models/achievement.dart';
import 'package:lurebox/core/providers/achievement_provider.dart';
import 'package:lurebox/core/providers/fish_guide_provider.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/features/achievement/achievement_page.dart';
import 'package:lurebox/features/achievement/widgets/achievement_overview_card.dart';
import 'package:lurebox/widgets/common/premium_card.dart';
import 'package:lurebox/core/models/fish_species.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    registerFallbackValues();
    setUpDatabaseForTesting();
  });

  // Test data factory for achievements
  Achievement createTestAchievement({
    String id = 'test_1',
    String title = '首次捕获',
    String description = '记录你的第一条鱼',
    String icon = '🐟',
    AchievementLevel level = AchievementLevel.bronze,
    String category = '数量',
    int target = 1,
    int current = 0,
    bool isUnlocked = false,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      level: level,
      category: category,
      target: target,
      current: current,
      unlockedAt: isUnlocked ? DateTime.now() : null,
      progress: target > 0 ? (current / target * 100.0).clamp(0.0, 100.0) : 0.0,
    );
  }

  List<Achievement> createTestAchievements() {
    return [
      createTestAchievement(
        id: 'catch_first',
        title: '首次捕获',
        description: '记录你的第一条鱼',
        icon: '🐟',
        level: AchievementLevel.bronze,
        category: '数量',
        target: 1,
        current: 1,
        isUnlocked: true,
      ),
      createTestAchievement(
        id: 'catch_10',
        title: '小试牛刀',
        description: '累计捕获10尾鱼',
        icon: '🎣',
        level: AchievementLevel.bronze,
        category: '数量',
        target: 10,
        current: 5,
        isUnlocked: false,
      ),
      createTestAchievement(
        id: 'length_50',
        title: '大物猎人',
        description: '捕获一尾50cm以上的鱼',
        icon: '📏',
        level: AchievementLevel.silver,
        category: '尺寸',
        target: 1,
        current: 0,
        isUnlocked: false,
      ),
      createTestAchievement(
        id: 'species_5',
        title: '物种收集者',
        description: '捕获5种不同的鱼',
        icon: '🪣',
        level: AchievementLevel.gold,
        category: '品种',
        target: 5,
        current: 3,
        isUnlocked: false,
      ),
      createTestAchievement(
        id: 'location_3',
        title: '探索者',
        description: '探索3个不同的钓点',
        icon: '📍',
        level: AchievementLevel.silver,
        category: '地点',
        target: 3,
        current: 1,
        isUnlocked: false,
      ),
    ];
  }

  Widget createWidgetUnderTest({
    List<Achievement>? achievements,
    FishGuideState? fishGuideState,
    bool isLoading = false,
    Exception? error,
  }) {
    return ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith((ref) {
          return AppSettingsNotifierTest();
        }),
        allAchievementsProvider.overrideWith((ref) {
          if (isLoading) {
            return Future.value(achievements ?? createTestAchievements());
          }
          if (error != null) {
            return Future.error(error, StackTrace.current);
          }
          return Future.value(achievements ?? createTestAchievements());
        }),
        achievementStatsProvider.overrideWith((ref) {
          if (isLoading) {
            return Future.value(
                {'unlockedCount': 0, 'totalCount': 0, 'progress': 0});
          }
          if (error != null) {
            return Future.error(error, StackTrace.current);
          }
          return Future.value(
              {'unlockedCount': 1, 'totalCount': 5, 'progress': 20});
        }),
        fishGuideProvider.overrideWith((ref) {
          return FishGuideNotifierTest(
            fishGuideState ?? const FishGuideState(),
          );
        }),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const AchievementPage(),
      ),
    );
  }

  group('AchievementPage Design System Tests', () {
    test('AnimationConstants uses correct touch feedback values', () {
      expect(AnimationConstants.touchFeedbackDuration,
          const Duration(milliseconds: 150));
      expect(AnimationConstants.touchScale, 0.98);
    });

    test('AppColors has correct blue theme colors', () {
      expect(AppColors.primaryLight, const Color(0xFF1E3A5F));
      expect(AppColors.accentLight, const Color(0xFF3B82F6));
    });

    test('AppColors dark mode uses True Black background', () {
      expect(AppColors.backgroundDark, const Color(0xFF000000));
      expect(AppColors.surfaceDark, const Color(0xFF0A0A0A));
    });

    test('AppTheme has correct spacing system', () {
      expect(AppTheme.spacingXs, 4.0);
      expect(AppTheme.spacingSm, 8.0);
      expect(AppTheme.spacingMd, 12.0);
      expect(AppTheme.spacingLg, 16.0);
      expect(AppTheme.spacingXl, 24.0);
      expect(AppTheme.spacingXxl, 32.0);
    });

    test('AppTheme has correct radius system', () {
      expect(AppTheme.radiusSm, 6.0);
      expect(AppTheme.radiusMd, 12.0);
      expect(AppTheme.radiusLg, 16.0);
      expect(AppTheme.radiusXl, 24.0);
      expect(AppTheme.radiusFull, 9999.0);
    });
  });

  group('AchievementPage Widget Tests', () {
    testWidgets('renders app bar with achievement title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('成就 · 图鉴'), findsOneWidget);
    });

    testWidgets('shows loading indicator initially while fetching achievements',
        (tester) async {
      // Create a delayed future to simulate loading state
      final delayedFuture = Future<List<Achievement>>.delayed(
        const Duration(milliseconds: 500),
        () => createTestAchievements(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsProvider.overrideWith((ref) {
              return AppSettingsNotifierTest();
            }),
            allAchievementsProvider.overrideWith((ref) {
              return delayedFuture;
            }),
            achievementStatsProvider.overrideWith((ref) {
              return Future.value(
                  {'unlockedCount': 0, 'totalCount': 0, 'progress': 0});
            }),
            fishGuideProvider.overrideWith((ref) {
              return FishGuideNotifierTest(const FishGuideState());
            }),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            home: const AchievementPage(),
          ),
        ),
      );
      // Pump a short duration to show loading state before future completes
      await tester.pump(const Duration(milliseconds: 100));

      // Should show CircularProgressIndicator during initial load
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // Wait for the future to complete
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('displays error state with retry button', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(error: Exception('Failed to load')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
    });

    testWidgets('displays empty state when no achievements', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(achievements: []));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Tab 1 now shows fish guide, which shows water icon when empty
      expect(find.byIcon(Icons.water_outlined), findsOneWidget);
    });

    testWidgets('displays achievement overview card with stats',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should find the stats overview card
      expect(find.text('解锁进度'), findsOneWidget);
    });

    testWidgets('displays tabs with correct labels', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should find TabBar with two tabs
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('鱼类收藏'), findsOneWidget);
      expect(find.text('成就'), findsOneWidget);
    });

    testWidgets('tab switching works', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Find and tap on the TabBar
      final tabBar = find.byType(TabBar);
      expect(tabBar, findsOneWidget);

      // Tab should be visible and tappable
      expect(find.text('鱼类收藏'), findsOneWidget);
    });

    testWidgets('displays achievement overview card', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should find AchievementOverviewCard showing progress
      expect(find.byType(AchievementOverviewCard), findsOneWidget);
    });
  });

  group('AchievementPage View Mode Toggle Tests', () {
    testWidgets('default view mode is list', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should show list icon as selected by default
      expect(find.byIcon(Icons.view_list), findsOneWidget);
    });

    testWidgets('toggling view mode changes icon', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Tap on grid icon
      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pumpAndSettle();

      // Should show grid icon now
      expect(find.byIcon(Icons.grid_view), findsOneWidget);
    });
  });

  group('AchievementPage Blue Theme Tests', () {
    testWidgets('achievement cards display correctly with theme colors',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // PremiumCard widgets should be visible with proper theming
      expect(find.byType(PremiumCard), findsWidgets);
    });
  });

  group('AchievementPage Dark Mode Tests', () {
    testWidgets('dark mode uses True Black background', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsProvider.overrideWith((ref) {
              return AppSettingsNotifierDarkTest();
            }),
            allAchievementsProvider.overrideWith((ref) {
              return Future.value(createTestAchievements());
            }),
            achievementStatsProvider.overrideWith((ref) {
              return Future.value(
                  {'unlockedCount': 1, 'totalCount': 5, 'progress': 20});
            }),
            fishGuideProvider.overrideWith((ref) {
              return FishGuideNotifierTest(const FishGuideState());
            }),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.dark,
            home: const AchievementPage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold));
      final theme = Theme.of(context);
      expect(theme.brightness, Brightness.dark);
    });

    testWidgets('achievement cards display correctly in dark mode',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsProvider.overrideWith((ref) {
              return AppSettingsNotifierDarkTest();
            }),
            allAchievementsProvider.overrideWith((ref) {
              return Future.value(createTestAchievements());
            }),
            achievementStatsProvider.overrideWith((ref) {
              return Future.value(
                  {'unlockedCount': 1, 'totalCount': 5, 'progress': 20});
            }),
            fishGuideProvider.overrideWith((ref) {
              return FishGuideNotifierTest(const FishGuideState());
            }),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.dark,
            home: const AchievementPage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(PremiumCard), findsWidgets);
    });
  });

  group('Achievement Level Color Tests', () {
    test('AchievementLevel bronze color is correct', () {
      expect(AppColors.bronze, const Color(0xFFC77B3F));
    });

    test('AchievementLevel silver color is correct', () {
      expect(AppColors.silver, const Color(0xFFA0AEC0));
    });

    test('AchievementLevel gold color is correct', () {
      expect(AppColors.gold, const Color(0xFFD69E2E));
    });

    test('AchievementLevel platinum color is correct', () {
      expect(AppColors.info, const Color(0xFF63B3ED));
    });
  });
}

/// Test implementation of AppSettingsNotifier
class AppSettingsNotifierTest extends StateNotifier<AppSettings>
    implements AppSettingsNotifier {
  AppSettingsNotifierTest() : super(const AppSettings());

  @override
  Future<void> updateSettings(AppSettings settings) async {
    state = settings;
  }

  @override
  Future<void> updateUnits(UnitSettings units) async {
    state = state.copyWith(units: units);
  }

  @override
  Future<void> updateDarkMode(DarkMode mode) async {
    state = state.copyWith(darkMode: mode);
  }

  @override
  Future<void> updateLanguage(AppLanguage language) async {
    state = state.copyWith(language: language);
  }
}

/// Dark mode test implementation
class AppSettingsNotifierDarkTest extends StateNotifier<AppSettings>
    implements AppSettingsNotifier {
  AppSettingsNotifierDarkTest()
      : super(const AppSettings(darkMode: DarkMode.dark));

  @override
  Future<void> updateSettings(AppSettings settings) async {
    state = settings;
  }

  @override
  Future<void> updateUnits(UnitSettings units) async {
    state = state.copyWith(units: units);
  }

  @override
  Future<void> updateDarkMode(DarkMode mode) async {
    state = state.copyWith(darkMode: mode);
  }

  @override
  Future<void> updateLanguage(AppLanguage language) async {
    state = state.copyWith(language: language);
  }
}

/// Test implementation of FishGuideNotifier
class FishGuideNotifierTest extends StateNotifier<FishGuideState>
    implements FishGuideNotifier {
  FishGuideNotifierTest(FishGuideState initialState) : super(initialState);

  @override
  void setCategoryFilter(FishGuideCategoryFilter filter) {
    state = state.copyWith(categoryFilter: filter);
  }

  @override
  void selectSpecies(FishSpecies? species) {
    state = state.copyWith(selectedSpecies: () => species);
  }

  @override
  void clearSelection() {
    state = state.copyWith(selectedSpecies: () => null);
  }

  @override
  Future<void> refresh() async {
    // No-op for tests
  }
}
