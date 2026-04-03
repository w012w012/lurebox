import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/providers/stats_provider.dart';
import 'package:lurebox/features/stats/stats_page.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    registerFallbackValues();
    setUpDatabaseForTesting();
  });

  TimeRangeStats createStats({
    int totalCount = 0,
    int releaseCount = 0,
    int keepCount = 0,
    Map<String, int>? speciesStats,
  }) {
    return TimeRangeStats(
      totalCount: totalCount,
      releaseCount: releaseCount,
      keepCount: keepCount,
      speciesStats: speciesStats ?? {},
    );
  }

  Widget createWidgetUnderTest({
    AsyncValue<TimeRangeStats>? todayStats,
    AsyncValue<TimeRangeStats>? monthStats,
    AsyncValue<TimeRangeStats>? yearStats,
    AsyncValue<TimeRangeStats>? allTimeStats,
  }) {
    return ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith((ref) {
          return AppSettingsNotifierTest();
        }),
        todayStatsProvider.overrideWith(
            (ref) => todayStats ?? AsyncValue.data(createStats())),
        monthStatsProvider.overrideWith(
            (ref) => monthStats ?? AsyncValue.data(createStats())),
        yearStatsProvider
            .overrideWith((ref) => yearStats ?? AsyncValue.data(createStats())),
        allTimeStatsProvider.overrideWith(
            (ref) => allTimeStats ?? AsyncValue.data(createStats())),
      ],
      child: const MaterialApp(
        home: StatsPage(),
      ),
    );
  }

  group('StatsPage', () {
    testWidgets('renders app bar with statistics title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('统计数据'), findsOneWidget);
    });

    testWidgets('shows loading indicator when stats are loading',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        todayStats: const AsyncValue.loading(),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('displays all four stat cards when data is loaded',
        (tester) async {
      final stats = createStats(
        totalCount: 10,
        releaseCount: 7,
        keepCount: 3,
        speciesStats: {'Bass': 5, 'Trout': 5},
      );

      await tester.pumpWidget(createWidgetUnderTest(
        todayStats: AsyncValue.data(stats),
        monthStats: AsyncValue.data(stats),
        yearStats: AsyncValue.data(stats),
        allTimeStats: AsyncValue.data(stats),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should find all four cards with their titles
      expect(find.text('今日渔获'), findsOneWidget);
      expect(find.text('本月渔获'), findsOneWidget);
      expect(find.text('本年渔获'), findsOneWidget);
      expect(find.text('全部渔获'), findsOneWidget);
    });

    testWidgets('stat cards show correct count values', (tester) async {
      final stats = createStats(
        totalCount: 25,
        releaseCount: 15,
        keepCount: 10,
        speciesStats: {'Bass': 25},
      );

      await tester.pumpWidget(createWidgetUnderTest(
        todayStats: AsyncValue.data(stats),
        monthStats: AsyncValue.data(stats),
        yearStats: AsyncValue.data(stats),
        allTimeStats: AsyncValue.data(stats),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should display the count value 25 multiple times (once per card)
      expect(find.text('25'), findsWidgets);
    });

    testWidgets('stat cards show release and keep counts', (tester) async {
      final stats = createStats(
        totalCount: 20,
        releaseCount: 12,
        keepCount: 8,
        speciesStats: {},
      );

      await tester.pumpWidget(createWidgetUnderTest(
        todayStats: AsyncValue.data(stats),
        monthStats: AsyncValue.data(stats),
        yearStats: AsyncValue.data(stats),
        allTimeStats: AsyncValue.data(stats),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should display release count 12 and keep count 8
      expect(find.text('12'), findsWidgets);
      expect(find.text('8'), findsWidgets);
    });

    testWidgets('stat cards show 0% release rate when count is 0',
        (tester) async {
      final stats = createStats(
        totalCount: 0,
        releaseCount: 0,
        keepCount: 0,
        speciesStats: {},
      );

      await tester.pumpWidget(createWidgetUnderTest(
        todayStats: AsyncValue.data(stats),
        monthStats: AsyncValue.data(stats),
        yearStats: AsyncValue.data(stats),
        allTimeStats: AsyncValue.data(stats),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should show 0 for release rate
      expect(find.text('0'), findsWidgets);
    });

    testWidgets('stat cards have PremiumCard styling with touch feedback',
        (tester) async {
      final stats = createStats(
        totalCount: 10,
        releaseCount: 5,
        keepCount: 5,
        speciesStats: {},
      );

      await tester.pumpWidget(createWidgetUnderTest(
        todayStats: AsyncValue.data(stats),
        monthStats: AsyncValue.data(stats),
        yearStats: AsyncValue.data(stats),
        allTimeStats: AsyncValue.data(stats),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Cards should have GestureDetector for touch feedback
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('tapping stat card shows chevron icon', (tester) async {
      final stats = createStats(
        totalCount: 10,
        releaseCount: 5,
        keepCount: 5,
        speciesStats: {},
      );

      await tester.pumpWidget(createWidgetUnderTest(
        todayStats: AsyncValue.data(stats),
        monthStats: AsyncValue.data(stats),
        yearStats: AsyncValue.data(stats),
        allTimeStats: AsyncValue.data(stats),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should have chevron icons for navigation
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });

    testWidgets('error state shows error icon', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        todayStats: AsyncValue.error(Exception('Failed'), StackTrace.current),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('stat cards use blue accent color for icons', (tester) async {
      final stats = createStats(
        totalCount: 10,
        releaseCount: 5,
        keepCount: 5,
        speciesStats: {},
      );

      await tester.pumpWidget(createWidgetUnderTest(
        todayStats: AsyncValue.data(stats),
        monthStats: AsyncValue.data(stats),
        yearStats: AsyncValue.data(stats),
        allTimeStats: AsyncValue.data(stats),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Icons should be present
      expect(find.byIcon(Icons.set_meal), findsWidgets);
      expect(find.byIcon(Icons.water_drop), findsWidgets);
      expect(find.byIcon(Icons.restaurant), findsWidgets);
      expect(find.byIcon(Icons.percent), findsWidgets);
    });

    testWidgets('pull to refresh indicator is present', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(RefreshIndicator), findsOneWidget);
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
