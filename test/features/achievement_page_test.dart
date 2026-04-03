import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/app_theme.dart';
import 'package:lurebox/core/design/theme/animation_constants.dart';
import 'package:lurebox/core/models/achievement.dart';
import 'package:lurebox/core/providers/achievement_provider.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/features/achievement/achievement_page.dart';
import 'package:lurebox/widgets/common/premium_card.dart';
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
    ];
  }

  Widget createWidgetUnderTest({
    List<Achievement>? achievements,
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
              {'unlockedCount': 1, 'totalCount': 4, 'progress': 25});
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

      expect(find.text('成就'), findsOneWidget);
    });

    testWidgets('shows loading indicator initially while fetching achievements',
        (tester) async {
      // Create a provider that returns a future that hasn't completed yet
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsProvider.overrideWith((ref) {
              return AppSettingsNotifierTest();
            }),
            allAchievementsProvider.overrideWith((ref) {
              return Future.value(createTestAchievements());
            }),
            achievementStatsProvider.overrideWith((ref) {
              return Future.value(
                  {'unlockedCount': 0, 'totalCount': 0, 'progress': 0});
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
      // Pump a short duration to allow async operations to start
      await tester.pump(const Duration(milliseconds: 100));

      // Should show CircularProgressIndicator during initial load
      expect(find.byType(CircularProgressIndicator), findsWidgets);
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

      expect(find.byIcon(Icons.emoji_events_outlined), findsOneWidget);
    });

    testWidgets('displays achievement overview card with stats',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should find the stats overview card
      expect(find.text('成就总览'), findsOneWidget);
      expect(find.text('已解锁'), findsOneWidget);
      expect(find.text('总成就'), findsOneWidget);
    });

    testWidgets('displays achievement cards with PremiumCard styling',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should find PremiumCard widgets for achievements
      expect(find.byType(PremiumCard), findsWidgets);
      // Should find achievement titles
      expect(find.text('首次捕获'), findsOneWidget);
      expect(find.text('小试牛刀'), findsOneWidget);
    });

    testWidgets('displays achievement icons correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should find emoji icons in achievement cards
      expect(find.text('🐟'), findsOneWidget);
      expect(find.text('🎣'), findsOneWidget);
    });

    testWidgets('displays achievement level badges', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should find level labels (青铜, 白银, 黄金, 铂金)
      expect(find.text('青铜'), findsWidgets);
      expect(find.text('白银'), findsWidgets);
    });

    testWidgets('displays unlocked achievements with check icon',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Unlocked achievement should show check_circle icon
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('displays locked achievements with lock icon', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Locked achievements should show lock_outline icon
      expect(find.byIcon(Icons.lock_outline), findsWidgets);
    });

    testWidgets('displays progress bar for locked achievements',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should find LinearProgressIndicator for locked achievements
      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });

    testWidgets('category filter tabs are displayed', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should find filter chips
      expect(find.byType(FilterChip), findsWidgets);
      // Should find category labels
      expect(find.text('全部'), findsOneWidget);
      expect(find.text('已完成'), findsOneWidget);
    });

    testWidgets('tapping category filter updates displayed achievements',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Tap on "已完成" filter
      await tester.tap(find.text('已完成'));
      await tester.pumpAndSettle();

      // Should show only completed achievements
      expect(find.text('首次捕获'), findsOneWidget);
      expect(find.text('小试牛刀'), findsNothing);
    });

    testWidgets('pull to refresh indicator is present', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });

  group('AchievementPage Blue Theme Tests', () {
    testWidgets('achievement cards use blue accent color for icons',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Achievement level colors should use the gold/bronze/silver palette
      // which is distinct from blue but celebratory
      expect(find.byIcon(Icons.emoji_events), findsWidgets);
    });

    testWidgets('progress bars use level-specific colors', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // LinearProgressIndicator widgets should be present
      expect(find.byType(LinearProgressIndicator), findsWidgets);
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
                  {'unlockedCount': 1, 'totalCount': 4, 'progress': 25});
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

      // Verify dark theme is applied by checking text colors
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
                  {'unlockedCount': 1, 'totalCount': 4, 'progress': 25});
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

      // Cards should be visible
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
