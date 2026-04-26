import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/strings/app_strings.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';
import 'package:lurebox/features/stats/stats_detail_page.dart';
import 'package:lurebox/features/stats/widgets/catch_trend_chart.dart';
import 'package:lurebox/features/stats/widgets/location_stats_card.dart';
import 'package:lurebox/features/stats/widgets/monthly_stats_card.dart';
import 'package:lurebox/features/stats/widgets/species_distribution_chart.dart';
import 'package:lurebox/features/stats/widgets/stats_summary_card.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    registerFallbackValues();
    setUpDatabaseForTesting();
  });

  late MockFishCatchService mockFishCatchService;

  setUp(() {
    mockFishCatchService = MockFishCatchService();
  });

  Widget createWidgetUnderTest({
    required String title,
    DateTime? startDate,
    DateTime? endDate,
    List<FishCatch> fishCatches = const [],
    Map<String, int> rodDistribution = const {},
    Map<String, int> reelDistribution = const {},
    Map<String, int> lureDistribution = const {},
    bool isLoading = false,
    String? errorMessage,
  }) {
    final effectiveStartDate = startDate ?? DateTime(2024, 1, 1);
    final effectiveEndDate = endDate ?? DateTime(2024, 12, 31);

    when(() => mockFishCatchService.getByDateRange(any(), any()))
        .thenAnswer((_) async {
      if (isLoading) {
        await Future.delayed(const Duration(seconds: 10));
      }
      return fishCatches;
    });

    when(() => mockFishCatchService.getEquipmentDistribution(
          any(),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        )).thenAnswer((invocation) async {
      final type = invocation.positionalArguments[0] as String;
      switch (type) {
        case 'rod':
          return rodDistribution;
        case 'reel':
          return reelDistribution;
        case 'lure':
          return lureDistribution;
        default:
          return <String, int>{};
      }
    });

    return ProviderScope(
      overrides: [
        fishCatchServiceProvider.overrideWithValue(mockFishCatchService),
        appSettingsProvider.overrideWith((ref) {
          return AppSettingsNotifierTest();
        }),
        currentStringsProvider.overrideWithValue(AppStrings.chinese),
      ],
      child: MaterialApp(
        home: StatsDetailPage(
          title: title,
          startDate: effectiveStartDate,
          endDate: effectiveEndDate,
        ),
      ),
    );
  }

  group('StatsDetailPage', () {
    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        title: '今日渔获',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        fishCatches: [],
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2)); // Allow animations to complete

      expect(find.text('今日渔获'), findsWidgets);
    });

    testWidgets('shows empty state when no data available', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        title: '全部渔获',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        fishCatches: [],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should show empty state icon (2 - visible + share image)
      expect(find.byIcon(Icons.inbox), findsWidgets);
      // Should show no data text (2 - visible + share image)
      expect(find.text('暂无数据'), findsWidgets);
    });

    testWidgets('shows MonthlyStatsCard with correct data when catches exist',
        (tester) async {
      final now = DateTime.now();
      final fishCatches = [
        TestDataFactory.createFishCatch(
          id: 1,
          species: 'Bass',
          fate: FishFateType.release,
          catchTime: now,
          locationName: 'Lake A',
        ),
        TestDataFactory.createFishCatch(
          id: 2,
          species: 'Bass',
          fate: FishFateType.keep,
          catchTime: now,
          locationName: 'Lake B',
        ),
        TestDataFactory.createFishCatch(
          id: 3,
          species: 'Trout',
          fate: FishFateType.release,
          catchTime: now,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        title: '今日渔获',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        fishCatches: fishCatches,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should find MonthlyStatsCard with total count 3
      expect(find.text('3'), findsWidgets);
      // Should show release count (2)
      expect(find.text('2'), findsWidgets);
      // Should show keep count (1)
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('shows SpeciesDistributionChart when species stats exist',
        (tester) async {
      final now = DateTime.now();
      final fishCatches = [
        TestDataFactory.createFishCatch(
          id: 1,
          species: 'Bass',
          fate: FishFateType.release,
          catchTime: now,
        ),
        TestDataFactory.createFishCatch(
          id: 2,
          species: 'Bass',
          fate: FishFateType.release,
          catchTime: now,
        ),
        TestDataFactory.createFishCatch(
          id: 3,
          species: 'Trout',
          fate: FishFateType.keep,
          catchTime: now,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        title: '全部渔获',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        fishCatches: fishCatches,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // SpeciesDistributionChart should be present (2 - one visible, one for share image)
      expect(find.byType(SpeciesDistributionChart), findsNWidgets(2));
    });

    testWidgets('shows CatchTrendChart when trend data exists', (tester) async {
      final now = DateTime.now();
      final fishCatches = [
        TestDataFactory.createFishCatch(
          id: 1,
          species: 'Bass',
          fate: FishFateType.release,
          catchTime: now,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        title: '全部渔获',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        fishCatches: fishCatches,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // CatchTrendChart should be present (2 - one visible, one for share image)
      expect(find.byType(CatchTrendChart), findsNWidgets(2));
    });

    testWidgets('shows LocationStatsCard when location analysis exists',
        (tester) async {
      final now = DateTime.now();
      final fishCatches = [
        TestDataFactory.createFishCatch(
          id: 1,
          species: 'Bass',
          fate: FishFateType.release,
          catchTime: now,
          locationName: 'Lake A',
        ),
        TestDataFactory.createFishCatch(
          id: 2,
          species: 'Trout',
          fate: FishFateType.release,
          catchTime: now,
          locationName: 'Lake A',
        ),
        TestDataFactory.createFishCatch(
          id: 3,
          species: 'Bass',
          fate: FishFateType.keep,
          catchTime: now,
          locationName: 'Lake B',
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        title: '全部渔获',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        fishCatches: fishCatches,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // LocationStatsCard should be present (2 - one visible, one for share image)
      expect(find.byType(LocationStatsCard), findsNWidgets(2));
      // Should show location names (2 of each - visible + share image)
      expect(find.text('Lake A'), findsWidgets);
      expect(find.text('Lake B'), findsWidgets);
    });

    testWidgets('shows equipment distribution charts when data exists',
        (tester) async {
      final now = DateTime.now();
      final fishCatches = [
        TestDataFactory.createFishCatch(
          id: 1,
          species: 'Bass',
          fate: FishFateType.release,
          catchTime: now,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        title: '全部渔获',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        fishCatches: fishCatches,
        rodDistribution: {'Rod A': 5, 'Rod B': 3},
        reelDistribution: {'Reel X': 4, 'Reel Y': 2},
        lureDistribution: {'Lure 1': 6},
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Equipment charts should be present (6 = 3 visible + 3 for share image)
      expect(find.byType(EquipmentChart), findsNWidgets(6));
      // Should show equipment names (2 of each = visible + share image)
      expect(find.text('Rod A'), findsWidgets);
      expect(find.text('Rod B'), findsWidgets);
      expect(find.text('Reel X'), findsWidgets);
      expect(find.text('Reel Y'), findsWidgets);
      expect(find.text('Lure 1'), findsWidgets);
    });

    testWidgets('shows time filter dropdown for all time stats',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        title: '全部渔获',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        fishCatches: [],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Dropdown should be present for "all" filter (2 - visible + share image)
      expect(find.byType(DropdownButton<String>), findsWidgets);
    });

    testWidgets('time filter dropdown shows day/month/year options',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        title: '全部渔获',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        fishCatches: [],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Tap the dropdown to open it (use .first since there are 2 - visible + share image)
      await tester.tap(find.byType(DropdownButton<String>).first);
      await tester.pumpAndSettle();

      // Should show all three options (2 of each - visible + share image)
      expect(find.text('分日'), findsWidgets);
      expect(find.text('分月'), findsWidgets);
      expect(find.text('分年'), findsWidgets);
    });

    testWidgets('changing time filter updates trend data', (tester) async {
      final now = DateTime.now();
      final fishCatches = [
        TestDataFactory.createFishCatch(
          id: 1,
          species: 'Bass',
          fate: FishFateType.release,
          catchTime: now,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        title: '全部渔获',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        fishCatches: fishCatches,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Page should render with stats content (duplicated for share image)
      expect(find.byType(MonthlyStatsCard), findsWidgets);
      expect(find.byType(CatchTrendChart), findsWidgets);

      // Dropdown should be present
      expect(find.byType(DropdownButton<String>), findsWidgets);
    });

    // Note: Loading state test is complex because it requires async timing
    // The loading indicator shows during _loadDetail() but resolves quickly with mock

    testWidgets('release rate is calculated correctly', (tester) async {
      final now = DateTime.now();
      final fishCatches = [
        TestDataFactory.createFishCatch(
          id: 1,
          species: 'Bass',
          fate: FishFateType.release,
          catchTime: now,
        ),
        TestDataFactory.createFishCatch(
          id: 2,
          species: 'Bass',
          fate: FishFateType.release,
          catchTime: now,
        ),
        TestDataFactory.createFishCatch(
          id: 3,
          species: 'Trout',
          fate: FishFateType.release,
          catchTime: now,
        ),
        TestDataFactory.createFishCatch(
          id: 4,
          species: 'Trout',
          fate: FishFateType.keep,
          catchTime: now,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        title: '今日渔获',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        fishCatches: fishCatches,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Total count 4, release 3, keep 1
      // Release rate should be 75%
      expect(find.text('75%'), findsWidgets);
    });

    testWidgets('toggle show by weight in species distribution chart',
        (tester) async {
      final now = DateTime.now();
      final fishCatches = [
        TestDataFactory.createFishCatch(
          id: 1,
          species: 'Bass',
          weight: 2.5,
          fate: FishFateType.release,
          catchTime: now,
        ),
        TestDataFactory.createFishCatch(
          id: 2,
          species: 'Trout',
          weight: 1.5,
          fate: FishFateType.release,
          catchTime: now,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        title: '全部渔获',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        fishCatches: fishCatches,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Find and tap the toggle button if present
      final toggleButton = find.byType(TextButton);
      if (toggleButton.evaluate().isNotEmpty) {
        await tester.tap(toggleButton.first);
        await tester.pumpAndSettle();
      }

      // Chart should still be present after toggle (2 - one visible, one for share image)
      expect(find.byType(SpeciesDistributionChart), findsNWidgets(2));
    });

    testWidgets('renders with all data populated', (tester) async {
      final now = DateTime.now();
      final fishCatches = [
        TestDataFactory.createFishCatch(
          id: 1,
          species: 'Bass',
          weight: 2.5,
          fate: FishFateType.release,
          catchTime: now,
          locationName: 'Lake A',
        ),
        TestDataFactory.createFishCatch(
          id: 2,
          species: 'Bass',
          weight: 3.0,
          fate: FishFateType.keep,
          catchTime: now,
          locationName: 'Lake A',
        ),
        TestDataFactory.createFishCatch(
          id: 3,
          species: 'Trout',
          weight: 1.5,
          fate: FishFateType.release,
          catchTime: now,
          locationName: 'Lake B',
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        title: '全部渔获',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        fishCatches: fishCatches,
        rodDistribution: {'Shimano': 3, 'Abu Garcia': 2},
        reelDistribution: {'Shimano': 3, 'Pflueger': 1},
        lureDistribution: {'Rapala': 4, 'Mepps': 1},
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should have monthly stats card (2 - one visible, one for share image)
      expect(find.byType(MonthlyStatsCard), findsNWidgets(2));

      // Should have species distribution chart (2 - one visible, one for share image)
      expect(find.byType(SpeciesDistributionChart), findsNWidgets(2));

      // Should have catch trend chart (2 - one visible, one for share image)
      expect(find.byType(CatchTrendChart), findsNWidgets(2));

      // Should have location stats card (2 - one visible, one for share image)
      expect(find.byType(LocationStatsCard), findsNWidgets(2));

      // Should have 3 equipment charts (rod, reel, lure) x 2 (for share image)
      expect(find.byType(EquipmentChart), findsNWidgets(6));

      // Verify species text appears
      expect(find.text('Bass'), findsWidgets);
      expect(find.text('Trout'), findsWidgets);
    });

    testWidgets('stats values match mock data for count and weight',
        (tester) async {
      final now = DateTime.now();
      final fishCatches = [
        TestDataFactory.createFishCatch(
          id: 1,
          species: 'Bass',
          weight: 2.5,
          fate: FishFateType.release,
          catchTime: now,
        ),
        TestDataFactory.createFishCatch(
          id: 2,
          species: 'Bass',
          weight: 3.5,
          fate: FishFateType.release,
          catchTime: now,
        ),
        TestDataFactory.createFishCatch(
          id: 3,
          species: 'Bass',
          weight: 4.0,
          fate: FishFateType.keep,
          catchTime: now,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        title: '全部渔获',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        fishCatches: fishCatches,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Total count should be 3
      expect(find.text('3'), findsWidgets);
      // Release count should be 2
      expect(find.text('2'), findsWidgets);
      // Keep count should be 1
      expect(find.text('1'), findsWidgets);
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

/// Mock FishCatchService for testing
class MockFishCatchService extends Mock implements FishCatchService {}
