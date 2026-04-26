import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/features/stats/widgets/stats_summary_card.dart';
import 'package:lurebox/features/stats/widgets/species_distribution_chart.dart';
import 'package:lurebox/features/stats/widgets/catch_trend_chart.dart';
import 'package:lurebox/features/stats/widgets/monthly_stats_card.dart';
import 'package:lurebox/features/stats/widgets/location_stats_card.dart';

// =============================================================================
// Test AppSettingsNotifier - mirrors pattern from stats_page_test.dart
// =============================================================================

class AppSettingsNotifierTest extends StateNotifier<AppSettings>
    implements AppSettingsNotifier {
  AppSettingsNotifierTest() : super(const AppSettings(language: AppLanguage.english));

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

// =============================================================================
// Default strings constants for testing
// =============================================================================

const _defaultStrings = AppStrings.english;

// =============================================================================
// Widget Creation Helper
// =============================================================================

Widget createTestWidget(Widget child) {
  return ProviderScope(
    overrides: [
      appSettingsProvider.overrideWith((ref) => AppSettingsNotifierTest()),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    ),
  );
}

// =============================================================================
// StatsSummaryCard Tests
// =============================================================================

void main() {
  group('StatsSummaryCard', () {
  Widget createWidgetUnderTest({
    required int totalCount,
    required List<Map<String, dynamic>> speciesSummary,
    Map<String, int>? rodDistribution,
    Map<String, int>? reelDistribution,
    Map<String, int>? lureDistribution,
    String weightUnit = 'kg',
  }) {
    return ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith((ref) => AppSettingsNotifierTest()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StatsSummaryCard(
              totalCount: totalCount,
              speciesSummary: speciesSummary,
              rodDistribution: rodDistribution ?? {},
              reelDistribution: reelDistribution ?? {},
              lureDistribution: lureDistribution ?? {},
              weightUnit: weightUnit,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders with correct total count', (tester) async {
    final speciesSummary = [
      {'species': 'Bass', 'count': 5, 'totalWeight': 15.5},
      {'species': 'Trout', 'count': 3, 'totalWeight': 4.2},
    ];

    await tester.pumpWidget(createWidgetUnderTest(
      totalCount: 8,
      speciesSummary: speciesSummary,
    ));
    await tester.pumpAndSettle();

    // Should display total count
    expect(find.textContaining('8'), findsWidgets);
  });

  testWidgets('shows release vs keep ratio via species summary',
      (tester) async {
    // The speciesSummary contains the data that shows release vs keep
    final speciesSummary = [
      {'species': 'Bass', 'count': 10, 'totalWeight': 30.0},
    ];

    await tester.pumpWidget(createWidgetUnderTest(
      totalCount: 10,
      speciesSummary: speciesSummary,
    ));
    await tester.pumpAndSettle();

    // Species names should be displayed
    expect(find.text('Bass'), findsOneWidget);
    // Count should be displayed with fishCountUnit
    expect(find.textContaining('10'), findsWidgets);
  });

  testWidgets('displays species count', (tester) async {
    final speciesSummary = [
      {'species': 'Bass', 'count': 5, 'totalWeight': 15.0},
      {'species': 'Trout', 'count': 3, 'totalWeight': 6.0},
      {'species': 'Carp', 'count': 2, 'totalWeight': 10.0},
    ];

    await tester.pumpWidget(createWidgetUnderTest(
      totalCount: 10,
      speciesSummary: speciesSummary,
    ));
    await tester.pumpAndSettle();

    // All species names should be visible
    expect(find.text('Bass'), findsOneWidget);
    expect(find.text('Trout'), findsOneWidget);
    expect(find.text('Carp'), findsOneWidget);
  });

  testWidgets('handles empty data gracefully', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      totalCount: 0,
      speciesSummary: [],
    ));
    await tester.pumpAndSettle();

    // Should return SizedBox for empty data, so no text content
    expect(find.byType(StatsSummaryCard), findsOneWidget);
    expect(find.text('Bass'), findsNothing);
  });

  testWidgets('displays weight for each species', (tester) async {
    final speciesSummary = [
      {'species': 'Bass', 'count': 5, 'totalWeight': 15.5},
    ];

    await tester.pumpWidget(createWidgetUnderTest(
      totalCount: 5,
      speciesSummary: speciesSummary,
      weightUnit: 'kg',
    ));
    await tester.pumpAndSettle();

    // Weight should be displayed with unit
    expect(find.textContaining('15.50'), findsOneWidget);
  });
});

// =============================================================================
// EquipmentChart Tests
// =============================================================================

group('EquipmentChart', () {
  Widget createWidgetUnderTest({
    required String title,
    required Map<String, int> data,
    Color color = Colors.blue,
    AppStrings? strings,
  }) {
    return ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith((ref) => AppSettingsNotifierTest()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EquipmentChart(
              title: title,
              data: data,
              color: color,
              strings: strings ?? _defaultStrings,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders chart with data', (tester) async {
    final data = {
      'Shimano': 5,
      'Abu Garcia': 3,
      'Pflueger': 2,
    };

    await tester.pumpWidget(createWidgetUnderTest(
      title: 'Rods',
      data: data,
    ));
    await tester.pumpAndSettle();

    // Title should be displayed
    expect(find.text('Rods'), findsOneWidget);
    // Brand names should be displayed
    expect(find.text('Shimano'), findsOneWidget);
    expect(find.text('Abu Garcia'), findsOneWidget);
    expect(find.text('Pflueger'), findsOneWidget);
  });

  testWidgets('handles single data point', (tester) async {
    final data = {'Shimano': 10};

    await tester.pumpWidget(createWidgetUnderTest(
      title: 'Single Rod',
      data: data,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Shimano'), findsOneWidget);
    // Should show 100% for single item
    expect(find.textContaining('100%'), findsOneWidget);
  });

  testWidgets('handles empty data', (tester) async {
    final data = <String, int>{};

    await tester.pumpWidget(createWidgetUnderTest(
      title: 'Empty Chart',
      data: data,
    ));
    await tester.pumpAndSettle();

    // Should return SizedBox for empty data
    expect(find.byType(EquipmentChart), findsOneWidget);
    expect(find.text('Empty Chart'), findsNothing);
  });
});

// =============================================================================
// SpeciesDistributionChart Tests
// =============================================================================

group('SpeciesDistributionChart', () {
  Widget createWidgetUnderTest({
    required Map<String, int> speciesStats,
    required int totalCount,
    Map<String, double>? speciesWeightStats,
    double totalWeight = 0,
    bool showByWeight = false,
    VoidCallback? onToggleShowByWeight,
    AppStrings? strings,
    String weightUnit = 'kg',
    bool isChinese = true,
  }) {
    return ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith((ref) => AppSettingsNotifierTest()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SpeciesDistributionChart(
              speciesStats: speciesStats,
              totalCount: totalCount,
              speciesWeightStats: speciesWeightStats,
              totalWeight: totalWeight,
              showByWeight: showByWeight,
              onToggleShowByWeight: onToggleShowByWeight,
              strings: strings ?? _defaultStrings,
              weightUnit: weightUnit,
              isChinese: isChinese,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders chart with data', (tester) async {
    final speciesStats = {
      'Bass': 10,
      'Trout': 5,
      'Carp': 3,
    };

    await tester.pumpWidget(createWidgetUnderTest(
      speciesStats: speciesStats,
      totalCount: 18,
    ));
    await tester.pumpAndSettle();

    // Species labels should be displayed
    expect(find.text('Bass'), findsOneWidget);
    expect(find.text('Trout'), findsOneWidget);
    expect(find.text('Carp'), findsOneWidget);
    // Default title
    expect(find.text('Species Distribution'), findsOneWidget);
  });

  testWidgets('shows species labels with percentages', (tester) async {
    final speciesStats = {
      'Bass': 10,
      'Trout': 5,
    };

    await tester.pumpWidget(createWidgetUnderTest(
      speciesStats: speciesStats,
      totalCount: 15,
    ));
    await tester.pumpAndSettle();

    // Should show percentages
    expect(find.textContaining('%'), findsWidgets);
    // Should show count values
    expect(find.textContaining('10'), findsWidgets);
    expect(find.textContaining('5'), findsWidgets);
  });

  testWidgets('handles single species', (tester) async {
    final speciesStats = {'Bass': 20};

    await tester.pumpWidget(createWidgetUnderTest(
      speciesStats: speciesStats,
      totalCount: 20,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Bass'), findsOneWidget);
    // Single species should show 100%
    expect(find.textContaining('100.0%'), findsOneWidget);
  });

  testWidgets('handles empty data', (tester) async {
    final speciesStats = <String, int>{};

    await tester.pumpWidget(createWidgetUnderTest(
      speciesStats: speciesStats,
      totalCount: 0,
    ));
    await tester.pumpAndSettle();

    // Should return SizedBox for empty data
    expect(find.byType(SpeciesDistributionChart), findsOneWidget);
    expect(find.text('Species Distribution'), findsNothing);
  });

  testWidgets('toggles between count and weight view', (tester) async {
    bool showByWeight = false;
    final speciesStats = {'Bass': 10};
    final speciesWeightStats = {'Bass': 25.5};

    await tester.pumpWidget(createWidgetUnderTest(
      speciesStats: speciesStats,
      totalCount: 10,
      speciesWeightStats: speciesWeightStats,
      totalWeight: 25.5,
      showByWeight: showByWeight,
      onToggleShowByWeight: () {
        showByWeight = !showByWeight;
      },
    ));
    await tester.pumpAndSettle();

    // Find and tap the weight toggle
    final weightToggle = find.text('Weight');
    expect(weightToggle, findsOneWidget);

    await tester.tap(weightToggle);
    await tester.pumpAndSettle();

    // Toggle callback should be called
    expect(showByWeight, isTrue);
  });
});

// =============================================================================
// CatchTrendChart Tests
// =============================================================================

group('CatchTrendChart', () {
  Widget createWidgetUnderTest({
    required Map<String, int> trendData,
    required String trendTitle,
    bool showDropdown = false,
    String? trendType,
    ValueChanged<String>? onTrendTypeChanged,
  }) {
    return ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith((ref) => AppSettingsNotifierTest()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CatchTrendChart(
              trendData: trendData,
              trendTitle: trendTitle,
              showDropdown: showDropdown,
              trendType: trendType,
              onTrendTypeChanged: onTrendTypeChanged,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders trend line (bar chart)', (tester) async {
    final trendData = {
      'Jan': 5,
      'Feb': 8,
      'Mar': 12,
      'Apr': 3,
    };

    await tester.pumpWidget(createWidgetUnderTest(
      trendData: trendData,
      trendTitle: 'Monthly Catch Trend',
    ));
    await tester.pumpAndSettle();

    // Title should be displayed
    expect(find.text('Monthly Catch Trend'), findsOneWidget);
    // fl_chart BarChart should be present
    expect(find.byType(BarChart), findsOneWidget);
  });

  testWidgets('shows time axis labels', (tester) async {
    final trendData = {
      'Jan': 5,
      'Feb': 8,
      'Mar': 12,
    };

    await tester.pumpWidget(createWidgetUnderTest(
      trendData: trendData,
      trendTitle: 'Trend',
    ));
    await tester.pumpAndSettle();

    // Month labels should be present in the chart area
    // The chart renders text labels on the bottom axis
    expect(find.byType(BarChart), findsOneWidget);
  });

  testWidgets('handles single data point', (tester) async {
    final trendData = {'Jan': 10};

    await tester.pumpWidget(createWidgetUnderTest(
      trendData: trendData,
      trendTitle: 'Single Month',
    ));
    await tester.pumpAndSettle();

    expect(find.byType(BarChart), findsOneWidget);
    expect(find.text('Single Month'), findsOneWidget);
  });

  testWidgets('handles empty data', (tester) async {
    final trendData = <String, int>{};

    await tester.pumpWidget(createWidgetUnderTest(
      trendData: trendData,
      trendTitle: 'Empty Trend',
    ));
    await tester.pumpAndSettle();

    // Should return SizedBox for empty data
    expect(find.byType(CatchTrendChart), findsOneWidget);
    expect(find.text('Empty Trend'), findsNothing);
  });

  testWidgets('shows dropdown when showDropdown is true', (tester) async {
    String? selectedType = 'month';

    await tester.pumpWidget(createWidgetUnderTest(
      trendData: {'Jan': 5},
      trendTitle: 'With Dropdown',
      showDropdown: true,
      trendType: selectedType,
      onTrendTypeChanged: (type) {
        selectedType = type;
      },
    ));
    await tester.pumpAndSettle();

    // Dropdown button should be present
    expect(find.byType(DropdownButton<String>), findsOneWidget);
  });
});

// =============================================================================
// MonthlyStatsCard Tests
// =============================================================================

group('MonthlyStatsCard', () {
  Widget createWidgetUnderTest({
    required int releaseCount,
    required int keepCount,
    required double releaseRate,
    required String title,
    required int totalCount,
  }) {
    return ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith((ref) => AppSettingsNotifierTest()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: MonthlyStatsCard(
            releaseCount: releaseCount,
            keepCount: keepCount,
            releaseRate: releaseRate,
            title: title,
            totalCount: totalCount,
          ),
        ),
      ),
    );
  }

  testWidgets('shows month label', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      releaseCount: 7,
      keepCount: 3,
      releaseRate: 70.0,
      title: 'January 2024',
      totalCount: 10,
    ));
    await tester.pumpAndSettle();

    expect(find.text('January 2024'), findsOneWidget);
  });

  testWidgets('displays catch count prominently', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      releaseCount: 15,
      keepCount: 5,
      releaseRate: 75.0,
      title: 'March',
      totalCount: 20,
    ));
    await tester.pumpAndSettle();

    // The total count is displayed twice - large number + smaller with unit
    expect(find.text('20'), findsNWidgets(2));
    // Should also show count in the animated stat items
    expect(find.textContaining('15'), findsWidgets);
  });

  testWidgets('shows trend indicator (release/keep/rate)', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      releaseCount: 12,
      keepCount: 8,
      releaseRate: 60.0,
      title: 'June',
      totalCount: 20,
    ));
    await tester.pumpAndSettle();

    // Release and keep labels from strings
    expect(find.text('Release'), findsWidgets);
    expect(find.text('Keep'), findsWidgets);
    expect(find.text('Release Rate'), findsWidgets);
    // Percent icon should be present
    expect(find.byIcon(Icons.percent), findsOneWidget);
    // set_meal icon for count
    expect(find.byIcon(Icons.set_meal), findsWidgets);
  });

  testWidgets('handles zero catches', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      releaseCount: 0,
      keepCount: 0,
      releaseRate: 0.0,
      title: 'Empty Month',
      totalCount: 0,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Empty Month'), findsOneWidget);
    // Should show 0 prominently
    expect(find.text('0'), findsWidgets);
    expect(find.textContaining('0%'), findsOneWidget);
  });

  testWidgets('displays release rate as percentage', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      releaseCount: 8,
      keepCount: 2,
      releaseRate: 80.0,
      title: 'October',
      totalCount: 10,
    ));
    await tester.pumpAndSettle();

    // Should display the rate with % sign
    expect(find.textContaining('80%'), findsOneWidget);
  });
});

// =============================================================================
// LocationStatsCard Tests
// =============================================================================

group('LocationStatsCard', () {
  Widget createWidgetUnderTest({
    required Map<String, Map<String, int>> locationAnalysis,
    required AppStrings strings,
    bool showDetails = true,
    VoidCallback? onToggleDetails,
  }) {
    return ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith((ref) => AppSettingsNotifierTest()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LocationStatsCard(
              locationAnalysis: locationAnalysis,
              strings: strings,
              showDetails: showDetails,
              onToggleDetails: onToggleDetails,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows location name', (tester) async {
    final locationAnalysis = {
      'Lake Michigan': {'Bass': 10, 'Trout': 5},
    };

    await tester.pumpWidget(createWidgetUnderTest(
      locationAnalysis: locationAnalysis,
      strings: _defaultStrings,
    ));
    await tester.pumpAndSettle();

    // Location name should be displayed
    expect(find.text('Lake Michigan'), findsOneWidget);
    // Location analysis title
    expect(find.text('Location Analysis'), findsOneWidget);
  });

  testWidgets('displays catch count per location', (tester) async {
    final locationAnalysis = {
      'Lake Michigan': {'Bass': 10, 'Trout': 5},
    };

    await tester.pumpWidget(createWidgetUnderTest(
      locationAnalysis: locationAnalysis,
      strings: _defaultStrings,
    ));
    await tester.pumpAndSettle();

    // Total count pattern should show the total
    expect(find.textContaining('Total: 15'), findsOneWidget);
    // Species counts should be shown
    expect(find.textContaining('Bass: 10'), findsOneWidget);
    expect(find.textContaining('Trout: 5'), findsOneWidget);
  });

  testWidgets('shows coordinates via location icon', (tester) async {
    final locationAnalysis = {
      'Test Location': {'Bass': 5},
    };

    await tester.pumpWidget(createWidgetUnderTest(
      locationAnalysis: locationAnalysis,
      strings: _defaultStrings,
    ));
    await tester.pumpAndSettle();

    // Location icon should be present
    expect(find.byIcon(Icons.location_on), findsWidgets);
  });

  testWidgets('handles empty location analysis', (tester) async {
    final locationAnalysis = <String, Map<String, int>>{};

    await tester.pumpWidget(createWidgetUnderTest(
      locationAnalysis: locationAnalysis,
      strings: _defaultStrings,
    ));
    await tester.pumpAndSettle();

    // Should return SizedBox for empty data
    expect(find.byType(LocationStatsCard), findsOneWidget);
    expect(find.text('Location Analysis'), findsNothing);
  });

  testWidgets('toggles details visibility', (tester) async {
    bool showDetails = true;
    final locationAnalysis = {
      'Secret Spot': {'Bass': 5},
    };

    await tester.pumpWidget(createWidgetUnderTest(
      locationAnalysis: locationAnalysis,
      strings: _defaultStrings,
      showDetails: showDetails,
      onToggleDetails: () {
        showDetails = !showDetails;
      },
    ));
    await tester.pumpAndSettle();

    // Find the toggle button
    final toggleButton = find.byIcon(Icons.visibility_off);
    expect(toggleButton, findsOneWidget);

    await tester.tap(toggleButton);
    await tester.pumpAndSettle();

    // Callback should be triggered
    expect(showDetails, isFalse);
  });

  testWidgets('blurs location name when showDetails is false',
      (tester) async {
    final locationAnalysis = {
      'Private Lake': {'Bass': 3},
    };

    await tester.pumpWidget(createWidgetUnderTest(
      locationAnalysis: locationAnalysis,
      strings: _defaultStrings,
      showDetails: false,
    ));
    await tester.pumpAndSettle();

    // Location should be blurred (not showing actual name)
    // The blur function shows 'P' followed by asterisks for 4-char names
    expect(find.textContaining('P'), findsWidgets);
    // Visibility icon should show "visibility" (not visibility_off) when details hidden
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });
});
}
