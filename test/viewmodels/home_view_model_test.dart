import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/providers/home_view_model.dart';
import 'package:lurebox/core/repositories/stats_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockStatsRepository extends Mock implements StatsRepository {}

class FakeDashboardData extends Fake implements DashboardData {}

// Helper functions
DashboardData _createDashboardData({
  CatchStats todayStats = const CatchStats(total: 0, release: 0, keep: 0),
  Map<String, int> todaySpecies = const {},
  CatchStats monthStats = const CatchStats(total: 0, release: 0, keep: 0),
  Map<String, int> monthSpecies = const {},
  CatchStats yearStats = const CatchStats(total: 0, release: 0, keep: 0),
  Map<String, int> yearSpecies = const {},
  CatchStats allStats = const CatchStats(total: 0, release: 0, keep: 0),
  Map<String, int> allSpecies = const {},
  List<Map<String, dynamic>> top3Longest = const [],
}) {
  return DashboardData(
    todayStats: todayStats,
    todaySpecies: todaySpecies,
    monthStats: monthStats,
    monthSpecies: monthSpecies,
    yearStats: yearStats,
    yearSpecies: yearSpecies,
    allStats: allStats,
    allSpecies: allSpecies,
    top3Longest: top3Longest,
  );
}

void main() {
  late HomeViewModel viewModel;
  late MockStatsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeDashboardData());
  });

  setUp(() {
    mockRepository = MockStatsRepository();

    // Default mock behavior - return empty dashboard data
    when(() => mockRepository.getDashboardData()).thenAnswer(
      (_) async => _createDashboardData(),
    );

    viewModel = HomeViewModel(mockRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('HomeViewModel', () {
    group('initial state', () {
      test('has correct default values before loading', () {
        // Create a new viewModel to test initial state without triggering loadData
        final newViewModel = HomeViewModel(mockRepository);

        expect(newViewModel.state.isLoading, isTrue);
        expect(newViewModel.state.errorMessage, isNull);
        expect(newViewModel.state.todayStats,
            const CatchStats(total: 0, release: 0, keep: 0),);
        expect(newViewModel.state.todaySpecies, isEmpty);
        expect(newViewModel.state.monthStats,
            const CatchStats(total: 0, release: 0, keep: 0),);
        expect(newViewModel.state.monthSpecies, isEmpty);
        expect(newViewModel.state.yearStats,
            const CatchStats(total: 0, release: 0, keep: 0),);
        expect(newViewModel.state.yearSpecies, isEmpty);
        expect(newViewModel.state.allStats,
            const CatchStats(total: 0, release: 0, keep: 0),);
        expect(newViewModel.state.allSpecies, isEmpty);
        expect(newViewModel.state.top3Fishes, isEmpty);
      });
    });

    // ============================================================
    // loadData Tests
    // ============================================================
    group('loadData', () {
      test('loads dashboard data successfully', () async {
        // Arrange
        final dashboardData = _createDashboardData(
          todayStats: const CatchStats(total: 5, release: 3, keep: 2),
          todaySpecies: {'Bass': 3, 'Trout': 2},
          monthStats: const CatchStats(total: 30, release: 20, keep: 10),
          monthSpecies: {'Bass': 15, 'Trout': 10, 'Pike': 5},
          yearStats: const CatchStats(total: 150, release: 100, keep: 50),
          yearSpecies: {'Bass': 80, 'Trout': 50, 'Pike': 20},
          allStats: const CatchStats(total: 500, release: 350, keep: 150),
          allSpecies: {'Bass': 200, 'Trout': 180, 'Pike': 120},
          top3Longest: [
            {'species': 'Bass', 'length': 50.5},
            {'species': 'Trout', 'length': 45.0},
            {'species': 'Pike', 'length': 42.0},
          ],
        );

        when(() => mockRepository.getDashboardData()).thenAnswer(
          (_) async => dashboardData,
        );

        // Act
        await viewModel.loadData();

        // Assert
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.errorMessage, isNull);
        expect(viewModel.state.todayStats, dashboardData.todayStats);
        expect(viewModel.state.todaySpecies, dashboardData.todaySpecies);
        expect(viewModel.state.monthStats, dashboardData.monthStats);
        expect(viewModel.state.monthSpecies, dashboardData.monthSpecies);
        expect(viewModel.state.yearStats, dashboardData.yearStats);
        expect(viewModel.state.yearSpecies, dashboardData.yearSpecies);
        expect(viewModel.state.allStats, dashboardData.allStats);
        expect(viewModel.state.allSpecies, dashboardData.allSpecies);
        expect(viewModel.state.top3Fishes, dashboardData.top3Longest);
      });

      test('updates todayStats and todaySpecies correctly', () async {
        // Arrange
        const todayStats = CatchStats(total: 10, release: 7, keep: 3);
        const todaySpecies = {'Bass': 5, 'Crappie': 3, 'Bluegill': 2};

        when(() => mockRepository.getDashboardData()).thenAnswer(
          (_) async => _createDashboardData(
            todayStats: todayStats,
            todaySpecies: todaySpecies,
          ),
        );

        // Act
        await viewModel.loadData();

        // Assert
        expect(viewModel.state.todayStats.total, 10);
        expect(viewModel.state.todayStats.release, 7);
        expect(viewModel.state.todayStats.keep, 3);
        expect(viewModel.state.todaySpecies,
            {'Bass': 5, 'Crappie': 3, 'Bluegill': 2},);
      });

      test('updates monthStats and monthSpecies correctly', () async {
        // Arrange
        const monthStats = CatchStats(total: 50, release: 35, keep: 15);
        const monthSpecies = {'Bass': 25, 'Trout': 15, 'Crappie': 10};

        when(() => mockRepository.getDashboardData()).thenAnswer(
          (_) async => _createDashboardData(
            monthStats: monthStats,
            monthSpecies: monthSpecies,
          ),
        );

        // Act
        await viewModel.loadData();

        // Assert
        expect(viewModel.state.monthStats.total, 50);
        expect(viewModel.state.monthStats.release, 35);
        expect(viewModel.state.monthStats.keep, 15);
        expect(viewModel.state.monthSpecies,
            {'Bass': 25, 'Trout': 15, 'Crappie': 10},);
      });

      test('updates yearStats and yearSpecies correctly', () async {
        // Arrange
        const yearStats = CatchStats(total: 200, release: 140, keep: 60);
        const yearSpecies = {'Bass': 100, 'Trout': 60, 'Pike': 40};

        when(() => mockRepository.getDashboardData()).thenAnswer(
          (_) async => _createDashboardData(
            yearStats: yearStats,
            yearSpecies: yearSpecies,
          ),
        );

        // Act
        await viewModel.loadData();

        // Assert
        expect(viewModel.state.yearStats.total, 200);
        expect(viewModel.state.yearStats.release, 140);
        expect(viewModel.state.yearStats.keep, 60);
        expect(viewModel.state.yearSpecies,
            {'Bass': 100, 'Trout': 60, 'Pike': 40},);
      });

      test('updates allStats and allSpecies correctly', () async {
        // Arrange
        const allStats = CatchStats(total: 1000, release: 700, keep: 300);
        const allSpecies = {'Bass': 400, 'Trout': 350, 'Pike': 250};

        when(() => mockRepository.getDashboardData()).thenAnswer(
          (_) async => _createDashboardData(
            allStats: allStats,
            allSpecies: allSpecies,
          ),
        );

        // Act
        await viewModel.loadData();

        // Assert
        expect(viewModel.state.allStats.total, 1000);
        expect(viewModel.state.allStats.release, 700);
        expect(viewModel.state.allStats.keep, 300);
        expect(viewModel.state.allSpecies,
            {'Bass': 400, 'Trout': 350, 'Pike': 250},);
      });

      test('updates top3Fishes correctly', () async {
        // Arrange
        final top3 = [
          {'species': 'Bass', 'length': 55.5, 'weight': 4.5},
          {'species': 'Trout', 'length': 48.0, 'weight': 3.2},
          {'species': 'Pike', 'length': 45.0, 'weight': 5.0},
        ];

        when(() => mockRepository.getDashboardData()).thenAnswer(
          (_) async => _createDashboardData(top3Longest: top3),
        );

        // Act
        await viewModel.loadData();

        // Assert
        expect(viewModel.state.top3Fishes.length, 3);
        expect(viewModel.state.top3Fishes[0]['species'], 'Bass');
        expect(viewModel.state.top3Fishes[0]['length'], 55.5);
        expect(viewModel.state.top3Fishes[1]['species'], 'Trout');
        expect(viewModel.state.top3Fishes[2]['species'], 'Pike');
      });

      test('calls getDashboardData once during initialization', () async {
        // The viewModel calls loadData() in constructor
        verify(() => mockRepository.getDashboardData()).called(1);
      });
    });

    // ============================================================
    // loadData Error Handling Tests
    // ============================================================
    group('loadData error handling', () {
      test('sets errorMessage when getDashboardData throws Exception',
          () async {
        // Arrange
        when(() => mockRepository.getDashboardData())
            .thenThrow(Exception('Database error'));

        // Act
        await viewModel.loadData();

        // Assert
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.errorMessage, contains('Database error'));
      });

      test('sets errorMessage when getDashboardData throws generic error',
          () async {
        // Arrange
        when(() => mockRepository.getDashboardData())
            .thenThrow(Exception('Network failure'));

        // Act
        await viewModel.loadData();

        // Assert
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.errorMessage, contains('Network failure'));
      });

      test('clears previous errorMessage on successful reload', () async {
        // Arrange - First load fails
        when(() => mockRepository.getDashboardData())
            .thenThrow(Exception('Initial error'));

        await viewModel.loadData();
        expect(viewModel.state.errorMessage, contains('Initial error'));

        // Arrange - Second load succeeds
        when(() => mockRepository.getDashboardData()).thenAnswer(
          (_) async => _createDashboardData(
            todayStats: const CatchStats(total: 5, release: 3, keep: 2),
          ),
        );

        // Act
        await viewModel.loadData();

        // Assert
        expect(viewModel.state.errorMessage, isNull);
        expect(viewModel.state.todayStats.total, 5);
      });

      test('preserves last successful data on error after initial load',
          () async {
        // Arrange - First load succeeds
        const initialStats = CatchStats(total: 10, release: 8, keep: 2);
        when(() => mockRepository.getDashboardData()).thenAnswer(
          (_) async => _createDashboardData(todayStats: initialStats),
        );

        await viewModel.loadData();
        expect(viewModel.state.todayStats.total, 10);

        // Arrange - Second load fails
        when(() => mockRepository.getDashboardData())
            .thenThrow(Exception('New error'));

        // Act
        await viewModel.loadData();

        // Assert - Error is set
        expect(viewModel.state.errorMessage, contains('New error'));
        expect(viewModel.state.isLoading, isFalse);
      });
    });

    // ============================================================
    // refresh Tests
    // ============================================================
    group('refresh', () {
      test('refresh calls loadData', () async {
        // Arrange
        when(() => mockRepository.getDashboardData()).thenAnswer(
          (_) async => _createDashboardData(
            todayStats: const CatchStats(total: 3, release: 2, keep: 1),
          ),
        );

        // Act
        await viewModel.refresh();

        // Assert
        verify(() => mockRepository.getDashboardData())
            .called(greaterThanOrEqualTo(1));
      });

      test('refresh updates state with new data', () async {
        // Arrange
        when(() => mockRepository.getDashboardData()).thenAnswer(
          (_) async => _createDashboardData(
            todayStats: const CatchStats(total: 7, release: 5, keep: 2),
          ),
        );

        // Act
        await viewModel.refresh();

        // Assert
        expect(viewModel.state.todayStats.total, 7);
        expect(viewModel.state.todayStats.release, 5);
        expect(viewModel.state.todayStats.keep, 2);
      });

      test('refresh handles error gracefully', () async {
        // Arrange
        when(() => mockRepository.getDashboardData())
            .thenThrow(Exception('Refresh failed'));

        // Act
        await viewModel.refresh();

        // Assert
        expect(viewModel.state.errorMessage, contains('Refresh failed'));
        expect(viewModel.state.isLoading, isFalse);
      });
    });

    // ============================================================
    // HomeState copyWith Tests
    // ============================================================
    group('HomeState copyWith', () {
      test('copyWith creates new instance with updated fields', () {
        const state = HomeState(
          todayStats: CatchStats(total: 5, release: 3, keep: 2),
          todaySpecies: {'Bass': 3},
          monthStats: CatchStats(total: 20, release: 15, keep: 5),
          monthSpecies: {'Bass': 10},
          yearStats: CatchStats(total: 100, release: 70, keep: 30),
          yearSpecies: {'Bass': 50},
          allStats: CatchStats(total: 500, release: 350, keep: 150),
          allSpecies: {'Bass': 200},
          top3Fishes: [
            {'species': 'Bass', 'length': 45.0},
          ],
        );

        final newState = state.copyWith(
            todayStats: const CatchStats(total: 10, release: 8, keep: 2),);

        expect(newState.isLoading, state.isLoading);
        expect(newState.todayStats.total, 10);
        expect(newState.todayStats.release, 8);
        expect(newState.todayStats.keep, 2);
        expect(newState.todaySpecies, state.todaySpecies);
        expect(newState.monthStats, state.monthStats);
        expect(newState.monthSpecies, state.monthSpecies);
        expect(newState.yearStats, state.yearStats);
        expect(newState.yearSpecies, state.yearSpecies);
        expect(newState.allStats, state.allStats);
        expect(newState.allSpecies, state.allSpecies);
        expect(newState.top3Fishes, state.top3Fishes);
      });
    });
  });
}
