import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/strings/app_strings.dart';
import 'package:lurebox/core/models/stats_models.dart';
import 'package:lurebox/core/providers/home_view_model.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/features/home/home_page.dart';

import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    setUpDatabaseForTesting();
    registerFallbackValues();
  });

  group('HomePage', () {
    testWidgets('renders app bar with title', (tester) async {
      final mockState = _MockHomeState();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeViewModelProvider.overrideWith((ref) => _MockHomeViewModel(mockState)),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('路亚鱼护'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      final loadingState = _MockHomeState(isLoading: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeViewModelProvider.overrideWith((ref) => _MockHomeViewModel(loadingState)),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state when errorMessage is present', (tester) async {
      final errorState = _MockHomeState(
        errorMessage: 'Failed to load data',
        isLoading: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeViewModelProvider.overrideWith((ref) => _MockHomeViewModel(errorState)),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Failed to load data'), findsOneWidget);
    });

    testWidgets('shows dashboard stats when data loaded', (tester) async {
      final loadedState = _MockHomeState(
        isLoading: false,
        todayStats: const CatchStats(total: 5, release: 3, keep: 2),
        monthStats: const CatchStats(total: 20, release: 15, keep: 5),
        todaySpecies: const {'Bass': 3, 'Trout': 2},
        monthSpecies: const {'Bass': 10, 'Trout': 7, 'Salmon': 3},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeViewModelProvider.overrideWith((ref) => _MockHomeViewModel(loadedState)),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify today stats are displayed: total "5 条", release "放流: 3", keep "保留: 2"
      expect(find.text('5 条'), findsOneWidget);
      expect(find.text('放流: 3'), findsOneWidget);
      expect(find.text('保留: 2'), findsOneWidget);
      // Verify month stats are displayed: total "20 条", release "放流: 15", keep "保留: 5"
      expect(find.text('20 条'), findsOneWidget);
      expect(find.text('放流: 15'), findsOneWidget);
      expect(find.text('保留: 5'), findsOneWidget);
    });

    testWidgets('shows today stats card when data loaded', (tester) async {
      final loadedState = _MockHomeState(
        isLoading: false,
        todayStats: const CatchStats(total: 3, release: 2, keep: 1),
        monthStats: const CatchStats(total: 10, release: 8, keep: 2),
        todaySpecies: const {'Bass': 2, 'Trout': 1},
        monthSpecies: const {'Bass': 5, 'Trout': 3, 'Salmon': 2},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeViewModelProvider.overrideWith((ref) => _MockHomeViewModel(loadedState)),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify today stats are displayed: total "3 条", release "放流: 2", keep "保留: 1"
      expect(find.text('3 条'), findsOneWidget);
      expect(find.text('放流: 2'), findsOneWidget);
      expect(find.text('保留: 1'), findsOneWidget);
    });

    testWidgets('shows month stats card when data loaded', (tester) async {
      final loadedState = _MockHomeState(
        isLoading: false,
        todayStats: const CatchStats(total: 1, release: 1, keep: 0),
        monthStats: const CatchStats(total: 15, release: 10, keep: 5),
        todaySpecies: const {'Bass': 1},
        monthSpecies: const {'Bass': 8, 'Trout': 5, 'Salmon': 2},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeViewModelProvider.overrideWith((ref) => _MockHomeViewModel(loadedState)),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify month stats are displayed: total "15 条", release "放流: 10", keep "保留: 5"
      expect(find.text('15 条'), findsOneWidget);
      expect(find.text('放流: 10'), findsOneWidget);
      expect(find.text('保留: 5'), findsOneWidget);
    });
  });
}

/// Mock HomeState for testing
class _MockHomeState extends HomeState {
  const _MockHomeState({
    super.isLoading = false,
    super.errorMessage,
    super.todayStats = const CatchStats(total: 0, release: 0, keep: 0),
    super.todaySpecies = const {},
    super.monthStats = const CatchStats(total: 0, release: 0, keep: 0),
    super.monthSpecies = const {},
    super.yearStats = const CatchStats(total: 0, release: 0, keep: 0),
    super.yearSpecies = const {},
    super.allStats = const CatchStats(total: 0, release: 0, keep: 0),
    super.allSpecies = const {},
    super.top3Fishes = const [],
    super.monthTrend = const [],
  });

  @override
  int get todayCount => todayStats.total;
  @override
  int get todayRelease => todayStats.release;
  @override
  int get todayKeep => todayStats.keep;
  @override
  int get monthCount => monthStats.total;
  @override
  int get monthRelease => monthStats.release;
  @override
  int get monthKeep => monthStats.keep;
  @override
  int get yearCount => yearStats.total;
  @override
  int get yearRelease => yearStats.release;
  @override
  int get yearKeep => yearStats.keep;
  @override
  int get allCount => allStats.total;
  @override
  int get allRelease => allStats.release;
  @override
  int get allKeep => allStats.keep;
}

/// Mock HomeViewModel for testing
class _MockHomeViewModel extends StateNotifier<HomeState>
    implements HomeViewModel {
  _MockHomeViewModel(HomeState state) : super(state);

  @override
  Future<void> loadData() async {}

  @override
  Future<void> refresh() async {}
}
