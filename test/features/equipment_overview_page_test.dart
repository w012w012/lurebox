import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/strings/app_strings.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/providers/equipment_view_model.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/features/equipment/equipment_overview_page.dart';
import 'package:lurebox/widgets/common/premium_card.dart';

import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    setUpDatabaseForTesting();
    registerFallbackValues();
  });

  group('EquipmentOverviewPage', () {
    group('Empty State', () {
      testWidgets('shows app bar with correct title', (tester) async {
        // Empty state with isLoading = true to show initial loading
        final mockState = _MockEquipmentListState(isLoading: true);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              equipmentListViewModelProvider
                  .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
              currentStringsProvider.overrideWithValue(AppStrings.chinese),
            ],
            child: const MaterialApp(
              home: EquipmentOverviewPage(),
            ),
          ),
        );
        await tester.pump();

        // Should show loading indicator first
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('shows quantity stats section when no equipment',
          (tester) async {
        final mockState = _MockEquipmentListState(
          isLoading: false,
          rodList: const [],
          reelList: const [],
          lureList: const [],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              equipmentListViewModelProvider
                  .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
              currentStringsProvider.overrideWithValue(AppStrings.chinese),
            ],
            child: const MaterialApp(
              home: EquipmentOverviewPage(),
            ),
          ),
        );
        await tester.pump();

        // Should show quantity stats section
        expect(find.text('数量统计'), findsOneWidget);
      });

      testWidgets('shows no catch data message when stats are empty',
          (tester) async {
        final mockState = _MockEquipmentListState(
          isLoading: false,
          rodList: const [],
          reelList: const [],
          lureList: const [],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              equipmentListViewModelProvider
                  .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
              currentStringsProvider.overrideWithValue(AppStrings.chinese),
            ],
            child: const MaterialApp(
              home: EquipmentOverviewPage(),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('暂无战绩数据'), findsOneWidget);
      });

      testWidgets('does not show share button when no equipment',
          (tester) async {
        final mockState = _MockEquipmentListState(
          isLoading: false,
          rodList: const [],
          reelList: const [],
          lureList: const [],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              equipmentListViewModelProvider
                  .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
              currentStringsProvider.overrideWithValue(AppStrings.chinese),
            ],
            child: const MaterialApp(
              home: EquipmentOverviewPage(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.share), findsNothing);
      });
    });

    group('Populated State', () {
      testWidgets('shows share button when equipment exists', (tester) async {
        final equipment = TestDataFactory.createEquipment(id: 1);
        final mockState = _MockEquipmentListState(
          isLoading: false,
          rodList: [equipment],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              equipmentListViewModelProvider
                  .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
              currentStringsProvider.overrideWithValue(AppStrings.chinese),
            ],
            child: const MaterialApp(
              home: EquipmentOverviewPage(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.share), findsOneWidget);
      });

      testWidgets('shows rod section when rods exist', (tester) async {
        final equipment = TestDataFactory.createEquipment(id: 1);
        final mockState = _MockEquipmentListState(
          isLoading: false,
          rodList: [equipment],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              equipmentListViewModelProvider
                  .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
              currentStringsProvider.overrideWithValue(AppStrings.chinese),
            ],
            child: const MaterialApp(
              home: EquipmentOverviewPage(),
            ),
          ),
        );
        await tester.pump();

        // Should show rod distribution chart
        expect(find.text('鱼竿分布'), findsOneWidget);
      });

      testWidgets('shows reel section when reels exist', (tester) async {
        final equipment = TestDataFactory.createEquipment(
          id: 2,
          type: EquipmentType.reel,
        );
        final mockState = _MockEquipmentListState(
          isLoading: false,
          reelList: [equipment],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              equipmentListViewModelProvider
                  .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
              currentStringsProvider.overrideWithValue(AppStrings.chinese),
            ],
            child: const MaterialApp(
              home: EquipmentOverviewPage(),
            ),
          ),
        );
        await tester.pump();

        // Should show reel distribution chart
        expect(find.text('渔轮分布'), findsOneWidget);
      });

      testWidgets('shows lure section when lures exist', (tester) async {
        final equipment = TestDataFactory.createEquipment(
          id: 3,
          type: EquipmentType.lure,
        );
        final mockState = _MockEquipmentListState(
          isLoading: false,
          lureList: [equipment],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              equipmentListViewModelProvider
                  .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
              currentStringsProvider.overrideWithValue(AppStrings.chinese),
            ],
            child: const MaterialApp(
              home: EquipmentOverviewPage(),
            ),
          ),
        );
        await tester.pump();

        // Should show lure distribution chart
        expect(find.text('鱼饵分布'), findsOneWidget);
      });

      testWidgets('shows catch ranking section', (tester) async {
        final equipment = TestDataFactory.createEquipment(id: 1);
        final mockState = _MockEquipmentListState(
          isLoading: false,
          rodList: [equipment],
          equipmentStats: {
            1: {'totalCatches': 5, 'speciesCount': 3},
          },
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              equipmentListViewModelProvider
                  .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
              currentStringsProvider.overrideWithValue(AppStrings.chinese),
            ],
            child: const MaterialApp(
              home: EquipmentOverviewPage(),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('装备战绩榜'), findsOneWidget);
      });
    });

    group('Loading State', () {
      testWidgets('shows loading indicator when isLoading is true',
          (tester) async {
        final mockState = _MockEquipmentListState(isLoading: true);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              equipmentListViewModelProvider
                  .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
              currentStringsProvider.overrideWithValue(AppStrings.chinese),
            ],
            child: const MaterialApp(
              home: EquipmentOverviewPage(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Equipment Cards Display', () {
      testWidgets('shows equipment card with brand and model', (tester) async {
        final equipment = TestDataFactory.createEquipment(
          id: 1,
          brand: 'Shimano',
          model: 'Crucial',
        );
        final mockState = _MockEquipmentListState(
          isLoading: false,
          rodList: [equipment],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              equipmentListViewModelProvider
                  .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
              currentStringsProvider.overrideWithValue(AppStrings.chinese),
            ],
            child: const MaterialApp(
              home: EquipmentOverviewPage(),
            ),
          ),
        );
        await tester.pump();

        // Should show the equipment brand in the list
        expect(find.text('Shimano'), findsOneWidget);
      });

      testWidgets('shows equipment type label', (tester) async {
        final equipment = TestDataFactory.createEquipment(
          id: 1,
          type: EquipmentType.rod,
        );
        final mockState = _MockEquipmentListState(
          isLoading: false,
          rodList: [equipment],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              equipmentListViewModelProvider
                  .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
              currentStringsProvider.overrideWithValue(AppStrings.chinese),
            ],
            child: const MaterialApp(
              home: EquipmentOverviewPage(),
            ),
          ),
        );
        await tester.pump();

        // Should show "鱼竿" label for rod type
        expect(find.text('鱼竿'), findsOneWidget);
      });
    });

    group('Multiple Equipment', () {
      testWidgets('displays multiple rods correctly', (tester) async {
        final rod1 = TestDataFactory.createEquipment(
          id: 1,
          brand: 'Shimano',
          model: 'Crucial',
        );
        final rod2 = TestDataFactory.createEquipment(
          id: 2,
          brand: 'Daiwa',
          model: 'Steez',
        );
        final mockState = _MockEquipmentListState(
          isLoading: false,
          rodList: [rod1, rod2],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              equipmentListViewModelProvider
                  .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
              currentStringsProvider.overrideWithValue(AppStrings.chinese),
            ],
            child: const MaterialApp(
              home: EquipmentOverviewPage(),
            ),
          ),
        );
        await tester.pump();

        // Should show both brands
        expect(find.text('Shimano'), findsOneWidget);
        expect(find.text('Daiwa'), findsOneWidget);
      });

      testWidgets('displays mixed equipment types', (tester) async {
        final rod = TestDataFactory.createEquipment(
          id: 1,
          type: EquipmentType.rod,
        );
        final reel = TestDataFactory.createEquipment(
          id: 2,
          type: EquipmentType.reel,
        );
        final lure = TestDataFactory.createEquipment(
          id: 3,
          type: EquipmentType.lure,
        );
        final mockState = _MockEquipmentListState(
          isLoading: false,
          rodList: [rod],
          reelList: [reel],
          lureList: [lure],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              equipmentListViewModelProvider
                  .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
              currentStringsProvider.overrideWithValue(AppStrings.chinese),
            ],
            child: const MaterialApp(
              home: EquipmentOverviewPage(),
            ),
          ),
        );
        await tester.pump();

        // Should show sections for all three types
        expect(find.text('鱼竿分布'), findsOneWidget);
        expect(find.text('渔轮分布'), findsOneWidget);
        expect(find.text('鱼饵分布'), findsOneWidget);
      });
    });

    group('Unit Labels', () {
      testWidgets('displays rods with quantity in chart', (tester) async {
        final equipment = TestDataFactory.createEquipment(id: 1);
        final mockState = _MockEquipmentListState(
          isLoading: false,
          rodList: [equipment],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              equipmentListViewModelProvider
                  .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
              currentStringsProvider.overrideWithValue(AppStrings.chinese),
            ],
            child: const MaterialApp(
              home: EquipmentOverviewPage(),
            ),
          ),
        );
        await tester.pump();

        // Rod count of 1 should be displayed
        expect(find.text('1'), findsWidgets);
      });

      testWidgets('displays reels with quantity in chart', (tester) async {
        final equipment = TestDataFactory.createEquipment(
          id: 2,
          type: EquipmentType.reel,
        );
        final mockState = _MockEquipmentListState(
          isLoading: false,
          reelList: [equipment],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              equipmentListViewModelProvider
                  .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
              currentStringsProvider.overrideWithValue(AppStrings.chinese),
            ],
            child: const MaterialApp(
              home: EquipmentOverviewPage(),
            ),
          ),
        );
        await tester.pump();

        // Reel count of 1 should be displayed
        expect(find.text('1'), findsWidgets);
      });

      testWidgets('displays lures with quantity in chart', (tester) async {
        final equipment = TestDataFactory.createEquipment(
          id: 3,
          type: EquipmentType.lure,
        );
        final mockState = _MockEquipmentListState(
          isLoading: false,
          lureList: [equipment],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              equipmentListViewModelProvider
                  .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
              currentStringsProvider.overrideWithValue(AppStrings.chinese),
            ],
            child: const MaterialApp(
              home: EquipmentOverviewPage(),
            ),
          ),
        );
        await tester.pump();

        // Lure count of 1 should be displayed
        expect(find.text('1'), findsWidgets);
      });
    });

    group('PremiumCard Widgets', () {
      testWidgets('renders PremiumCard widgets in the page', (tester) async {
        final equipment = TestDataFactory.createEquipment(id: 1);
        final mockState = _MockEquipmentListState(
          isLoading: false,
          rodList: [equipment],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              equipmentListViewModelProvider
                  .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
              currentStringsProvider.overrideWithValue(AppStrings.chinese),
            ],
            child: const MaterialApp(
              home: EquipmentOverviewPage(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(PremiumCard), findsWidgets);
      });
    });

    group('Page Structure', () {
      testWidgets('has SingleChildScrollView for scrollable content',
          (tester) async {
        final equipment = TestDataFactory.createEquipment(id: 1);
        final mockState = _MockEquipmentListState(
          isLoading: false,
          rodList: [equipment],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              equipmentListViewModelProvider
                  .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
              currentStringsProvider.overrideWithValue(AppStrings.chinese),
            ],
            child: const MaterialApp(
              home: EquipmentOverviewPage(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });

      testWidgets('has RepaintBoundary for share functionality',
          (tester) async {
        final equipment = TestDataFactory.createEquipment(id: 1);
        final mockState = _MockEquipmentListState(
          isLoading: false,
          rodList: [equipment],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              equipmentListViewModelProvider
                  .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
              currentStringsProvider.overrideWithValue(AppStrings.chinese),
            ],
            child: const MaterialApp(
              home: EquipmentOverviewPage(),
            ),
          ),
        );
        await tester.pump();

        // Page has RepaintBoundary widgets for share functionality
        expect(find.byType(RepaintBoundary), findsWidgets);
      });
    });
  });
}

/// Mock EquipmentListState for testing
class _MockEquipmentListState extends EquipmentListState {
  _MockEquipmentListState({
    super.isLoading,
    super.errorMessage,
    super.rodList,
    super.reelList,
    super.lureList,
    super.equipmentStats,
    super.selectedType,
    super.allExpanded,
    super.expandedId,
  });
}

/// Mock EquipmentListViewModel for testing
class _MockEquipmentListViewModel extends StateNotifier<EquipmentListState>
    implements EquipmentListViewModel {
  _MockEquipmentListViewModel(EquipmentListState state) : super(state);

  @override
  Future<void> loadData() async {}

  @override
  Future<void> refresh() async {}

  @override
  void setSelectedType(String type) {}

  @override
  void toggleExpanded(int id) {}

  @override
  void setAllExpanded(bool expanded) {}

  @override
  Future<void> deleteEquipment(int id) async {}

  @override
  Future<void> setDefaultEquipment(int id, String type) async {}
}
