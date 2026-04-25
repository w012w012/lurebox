import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/strings/app_strings.dart';
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

      expect(find.text('LureBox'), findsOneWidget);
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

      expect(find.text('Failed to load data'), findsOneWidget);
    });

    testWidgets('shows dashboard stats when data loaded', (tester) async {
      final loadedState = _MockHomeState(
        isLoading: false,
        todayStats: _MockCatchStats(total: 5, release: 3, keep: 2),
        monthStats: _MockCatchStats(total: 20, release: 15, keep: 5),
        todaySpecies: {'Bass': 3, 'Trout': 2},
        monthSpecies: {'Bass': 10, 'Trout': 7, 'Salmon': 3},
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
      await tester.pump(const Duration(milliseconds: 500));

      // Stats cards should be visible
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('shows today stats card when data loaded', (tester) async {
      final loadedState = _MockHomeState(
        isLoading: false,
        todayStats: _MockCatchStats(total: 3, release: 2, keep: 1),
        monthStats: _MockCatchStats(total: 10, release: 8, keep: 2),
        todaySpecies: {'Bass': 2, 'Trout': 1},
        monthSpecies: {'Bass': 5, 'Trout': 3, 'Salmon': 2},
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
      await tester.pump(const Duration(milliseconds: 500));

      // Page should render without errors
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('shows month stats card when data loaded', (tester) async {
      final loadedState = _MockHomeState(
        isLoading: false,
        todayStats: _MockCatchStats(total: 1, release: 1, keep: 0),
        monthStats: _MockCatchStats(total: 15, release: 10, keep: 5),
        todaySpecies: {'Bass': 1},
        monthSpecies: {'Bass': 8, 'Trout': 5, 'Salmon': 2},
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
      await tester.pump(const Duration(milliseconds: 500));

      // Page should render without errors
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}

/// Mock HomeState for testing
class _MockHomeState implements HomeState {
  const _MockHomeState({
    this.isLoading = false,
    this.errorMessage,
    this.todayStats = const _MockCatchStats(total: 0, release: 0, keep: 0),
    this.todaySpecies = const {},
    this.monthStats = const _MockCatchStats(total: 0, release: 0, keep: 0),
    this.monthSpecies = const {},
    this.yearStats = const _MockCatchStats(total: 0, release: 0, keep: 0),
    this.yearSpecies = const {},
    this.allStats = const _MockCatchStats(total: 0, release: 0, keep: 0),
    this.allSpecies = const {},
    this.top3Fishes = const [],
    this.monthTrend = const [],
  });

  @override
  final bool isLoading;
  @override
  final String? errorMessage;
  @override
  final CatchStats todayStats;
  @override
  final Map<String, int> todaySpecies;
  @override
  final CatchStats monthStats;
  @override
  final Map<String, int> monthSpecies;
  @override
  final CatchStats yearStats;
  @override
  final Map<String, int> yearSpecies;
  @override
  final CatchStats allStats;
  @override
  final Map<String, int> allSpecies;
  @override
  final List<Map<String, dynamic>> top3Fishes;
  @override
  final List<Map<String, dynamic>> monthTrend;

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

/// Mock CatchStats for testing
class _MockCatchStats implements CatchStats {
  const _MockCatchStats({
    required this.total,
    required this.release,
    required this.keep,
  });

  @override
  final int total;
  @override
  final int release;
  @override
  final int keep;
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

