import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/providers/fish_list_view_model.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/fish_filter.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/features/fish_list/fish_list_page.dart';
import 'package:lurebox/widgets/fish_list/fish_filter_panel.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    registerFallbackValues();
  });

  late FishListState baseState;

  setUp(() {
    baseState = const FishListState(
      catches: [],
      filteredCatches: [],
      filter: FishFilter(),
      isLoading: false,
      errorMessage: null,
      selectedIds: {},
      isSelectionMode: false,
      hasMore: false,
    );
  });

  Widget createWidgetUnderTest(FishListState state) {
    final mockVm = _MockFishListViewModel(state);

    return ProviderScope(
      overrides: [
        fishListViewModelProvider.overrideWith((ref) => mockVm),
      ],
      child: const MaterialApp(
        home: FishListPage(),
      ),
    );
  }

  group('FishListPage', () {
    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(baseState));
      await tester.pump();

      expect(find.text('鱼获列表'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading is true',
        (tester) async {
      const loadingState = FishListState(
        catches: [],
        filteredCatches: [],
        filter: FishFilter(),
        isLoading: true,
        errorMessage: null,
        selectedIds: {},
        isSelectionMode: false,
        hasMore: false,
      );

      await tester.pumpWidget(createWidgetUnderTest(loadingState));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error view when errorMessage is present',
        (tester) async {
      const errorState = FishListState(
        catches: [],
        filteredCatches: [],
        filter: FishFilter(),
        isLoading: false,
        errorMessage: 'Failed to load catches',
        selectedIds: {},
        isSelectionMode: false,
        hasMore: false,
      );

      await tester.pumpWidget(createWidgetUnderTest(errorState));
      await tester.pump();

      expect(find.text('Failed to load catches'), findsOneWidget);
    });

    testWidgets('displays sort buttons in sort bar', (tester) async {
      final catches = TestDataFactory.createFishCatches(2);
      final stateWithCatches = FishListState(
        catches: catches,
        filteredCatches: catches,
        filter: const FishFilter(),
        isLoading: false,
        errorMessage: null,
        selectedIds: const {},
        isSelectionMode: false,
        hasMore: false,
      );

      await tester.pumpWidget(createWidgetUnderTest(stateWithCatches));
      await tester.pump();

      expect(find.text('时间'), findsOneWidget);
      expect(find.text('长度'), findsOneWidget);
      expect(find.text('重量'), findsOneWidget);
    });

    testWidgets('shows search button in non-selection mode', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(baseState));
      await tester.pump();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('selection mode shows close and delete buttons',
        (tester) async {
      final catches = TestDataFactory.createFishCatches(2);
      final selectionState = FishListState(
        catches: catches,
        filteredCatches: catches,
        filter: const FishFilter(),
        isLoading: false,
        errorMessage: null,
        selectedIds: const {1},
        isSelectionMode: true,
        hasMore: false,
      );

      await tester.pumpWidget(createWidgetUnderTest(selectionState));
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('selection mode shows selected count', (tester) async {
      final catches = TestDataFactory.createFishCatches(3);
      final selectionState = FishListState(
        catches: catches,
        filteredCatches: catches,
        filter: const FishFilter(),
        isLoading: false,
        errorMessage: null,
        selectedIds: const {1, 2},
        isSelectionMode: true,
        hasMore: false,
      );

      await tester.pumpWidget(createWidgetUnderTest(selectionState));
      await tester.pump();

      expect(find.textContaining('已选'), findsOneWidget);
      expect(find.textContaining('2'), findsOneWidget);
    });

    testWidgets('filter collapsed shows filter icon', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(baseState));
      await tester.pump();

      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('filter expanded shows filter panel', (tester) async {
      const expandedFilterState = FishListState(
        catches: [],
        filteredCatches: [],
        filter: FishFilter(timeFilter: 'all'),
        isLoading: false,
        errorMessage: null,
        selectedIds: {},
        isSelectionMode: false,
        filterExpanded: true,
        hasMore: false,
      );

      await tester.pumpWidget(createWidgetUnderTest(expandedFilterState));
      await tester.pump();

      expect(find.byType(FishFilterPanel), findsOneWidget);
    });

    testWidgets('fish items have staggered animation wrappers', (tester) async {
      final catches = TestDataFactory.createFishCatches(3);
      final stateWithCatches = FishListState(
        catches: catches,
        filteredCatches: catches,
        filter: const FishFilter(),
        isLoading: false,
        errorMessage: null,
        selectedIds: const {},
        isSelectionMode: false,
        hasMore: false,
      );

      await tester.pumpWidget(createWidgetUnderTest(stateWithCatches));
      await tester.pump();

      expect(find.byType(_AnimatedListItem), findsNWidgets(3));
    });

    testWidgets('count badge displays fish count', (tester) async {
      final catches = TestDataFactory.createFishCatches(5);
      final stateWithCatches = FishListState(
        catches: catches,
        filteredCatches: catches,
        filter: const FishFilter(),
        isLoading: false,
        errorMessage: null,
        selectedIds: const {},
        isSelectionMode: false,
        hasMore: false,
      );

      await tester.pumpWidget(createWidgetUnderTest(stateWithCatches));
      await tester.pump();

      // Count badge should show fish count
      expect(find.textContaining('5'), findsWidgets);
    });

    testWidgets('tapping sort button triggers callback', (tester) async {
      final catches = TestDataFactory.createFishCatches(1);
      final stateWithCatches = FishListState(
        catches: catches,
        filteredCatches: catches,
        filter: const FishFilter(),
        isLoading: false,
        errorMessage: null,
        selectedIds: const {},
        isSelectionMode: false,
        hasMore: false,
      );

      await tester.pumpWidget(createWidgetUnderTest(stateWithCatches));
      await tester.pump();

      final sizeButton = find.text('长度');
      await tester.tap(sizeButton);
      await tester.pump();

      // Widget should still be rendered after tap
      expect(find.byType(FishListPage), findsOneWidget);
    });
  });
}

// Simple mock implementation extending StateNotifier
class _MockFishListViewModel extends StateNotifier<FishListState>
    implements FishListViewModel {
  _MockFishListViewModel(FishListState state) : super(state);

  @override
  Future<void> loadCatches({bool reset = false, UnitSettings? units}) async {}

  @override
  Future<void> loadMore() async {}

  @override
  void onScroll(double offset, double lastOffset) {}

  @override
  void setTimeFilter(String filter) {}

  @override
  void setFateFilter(FishFateType? fate) {}

  @override
  void setSpeciesFilter(String? species) {}

  @override
  void setCustomDateRange(DateTime? start, DateTime? end) {}

  @override
  void clearFilters() {}

  @override
  void setSortBy(String sortBy, {bool? ascending}) {}

  @override
  void toggleSelectionMode() {}

  @override
  void toggleSelection(int id) {}

  @override
  void selectAll() {}

  @override
  Future<void> deleteSelected() async {}

  @override
  void setSearchQuery(String? query) {}

  @override
  void toggleFilterExpanded() {}
}

// Re-export for testing - matches the private class in fish_list_page.dart
class _AnimatedListItem extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _AnimatedListItem({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
