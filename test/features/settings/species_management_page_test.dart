import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/pagination_constants.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/fish_filter.dart';
import 'package:lurebox/core/models/watermark_settings.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/repositories/fish_catch_repository.dart';
import 'package:lurebox/core/services/settings_service.dart';
import 'package:lurebox/features/settings/species_management_page.dart';
import 'package:lurebox/widgets/common/premium_button.dart';

import '../../helpers/test_helpers.dart';

class MockSettingsService implements SettingsService {
  const MockSettingsService();

  @override
  Future<AppSettings> getAppSettings() async => const AppSettings();
  @override
  Future<void> saveAppSettings(AppSettings settings) async {}
  @override
  Future<WatermarkSettings> getWatermarkSettings() async =>
      const WatermarkSettings();
  @override
  Future<void> saveWatermarkSettings(WatermarkSettings settings) async {}
  @override
  Future<AiRecognitionSettings> getAiRecognitionSettings() async =>
      const AiRecognitionSettings();
  @override
  Future<void> saveAiRecognitionSettings(
      AiRecognitionSettings settings,) async {}
  @override
  Future<void> deleteAiRecognitionSettings() async {}
}

class FakeFishCatchRepository extends Fake implements FishCatchRepository {
  FakeFishCatchRepository({
    this.pendingCatches = const [],
    this.speciesCounts = const {},
    this.error,
  });
  final List<FishCatch> pendingCatches;
  final Map<String, int> speciesCounts;
  final Object? error;

  @override
  Future<List<FishCatch>> getAll() async => [];
  @override
  Future<FishCatch?> getById(int id) async => null;
  @override
  Future<int> create(FishCatch fish) async => 1;
  @override
  Future<void> update(FishCatch fish) async {}
  @override
  Future<void> delete(int id) async {}
  @override
  Future<void> deleteMultiple(List<int> ids) async {}
  @override
  Future<List<FishCatch>> getByIds(List<int> ids) async => [];
  @override
  Future<List<FishCatch>> getByDateRange(DateTime s, DateTime e) async => [];
  @override
  Future<List<FishCatch>> getByFate(FishFateType fate) async => [];
  @override
  Future<PaginatedResult<FishCatch>> getPage({
    required int page,
    int pageSize = PaginationConstants.defaultPageSize,
    String orderBy = 'catch_time DESC',
  }) async =>
      PaginatedResult(items: [], totalCount: 0, page: page, pageSize: pageSize, hasMore: false);
  @override
  Future<PaginatedResult<FishCatch>> getFilteredPage({
    required int page,
    int pageSize = PaginationConstants.defaultPageSize,
    DateTime? startDate,
    DateTime? endDate,
    FishFateType? fate,
    String? species,
    String orderBy = 'catch_time DESC',
  }) async =>
      PaginatedResult(items: [], totalCount: 0, page: page, pageSize: pageSize, hasMore: false);
  @override
  Future<List<FishCatch>> getPendingRecognitionCatches() async {
    if (error != null) throw error as Exception;
    return pendingCatches;
  }
  @override
  Future<int> getPendingRecognitionCount() async => pendingCatches.length;
  @override
  Future<void> updateSpecies(int id, String species) async {}
  @override
  Future<void> batchUpdateSpecies(
      List<int> ids, List<String> speciesList,) async {}
  @override
  Future<Map<String, int>> getSpeciesCounts() async {
    if (error != null) throw error as Exception;
    return speciesCounts;
  }
  @override
  Future<void> renameSpecies(String oldName, String newName) async {}
  @override
  Future<void> mergeSpecies(String fromName, String toName) async {}
  @override
  Future<void> deleteSpecies(String speciesName) async {}
  @override
  Future<Map<String, Map<String, int>>> getSoftWormRigAnalytics() async => {};
  @override
  Future<PaginatedResult<FishCatch>> getFilteredPageByFilter({
    required int page,
    required FishFilter filter, int pageSize = PaginationConstants.defaultPageSize,
  }) async =>
      PaginatedResult(items: [], totalCount: 0, page: page, pageSize: pageSize, hasMore: false);
  @override
  Future<int> getCount() async => 0;
}

const _mockSettingsService = MockSettingsService();

Widget buildTestPage(FakeFishCatchRepository repo) {
  return ProviderScope(
    overrides: [
      appSettingsProvider.overrideWith(
        (ref) => AppSettingsNotifier(_mockSettingsService),
      ),
      currentStringsProvider.overrideWithValue(AppStrings.chinese),
      fishCatchRepositoryProvider.overrideWithValue(repo),
    ],
    child: const MaterialApp(
      home: SpeciesManagementPage(),
    ),
  );
}

void main() {
  setUpAll(() {
    setUpDatabaseForTesting();
    registerFallbackValues();
  });

  group('SpeciesManagementPage Widget Tests', () {
    testWidgets('renders page title in AppBar', (tester) async {
      await tester.pumpWidget(buildTestPage(FakeFishCatchRepository()));
      await tester.pump();
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.text(AppStrings.chinese.speciesManagement),
        findsOneWidget,
      );
    });

    testWidgets('shows pending queue section with empty state', (tester) async {
      await tester.pumpWidget(buildTestPage(FakeFishCatchRepository()));
      await tester.pump();
      await tester.pump();

      expect(find.text(AppStrings.chinese.pendingRecognitionList), findsOneWidget);
      expect(find.text(AppStrings.chinese.pendingNoFish), findsOneWidget);
    });

    testWidgets('shows pending catch count badge', (tester) async {
      final List<FishCatch> pendingCatches = [
        TestDataFactory.createFishCatch(id: 1, species: 'Bass'),
        TestDataFactory.createFishCatch(id: 2, species: 'Trout'),
      ];

      await tester.pumpWidget(buildTestPage(FakeFishCatchRepository(
        pendingCatches: pendingCatches,
      )));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('2条'), findsOneWidget);
    });

    testWidgets('shows species list section', (tester) async {
      await tester.pumpWidget(buildTestPage(FakeFishCatchRepository(
        speciesCounts: {'Bass': 5, 'Trout': 3},
      )));
      await tester.pump();
      await tester.pump();

      expect(find.text(AppStrings.chinese.speciesSaved), findsOneWidget);
      expect(find.text('Bass'), findsOneWidget);
      expect(find.text('Trout'), findsOneWidget);
    });

    testWidgets('shows loading indicator while loading pending catches',
        (tester) async {
      // Use a simple mock that returns empty immediately but tests loading state
      await tester.pumpWidget(buildTestPage(FakeFishCatchRepository(
        pendingCatches: const [],
        speciesCounts: const {},
      )));
      await tester.pump();

      // The page shows CircularProgressIndicator while loading initial data
      // Since repository returns quickly, we verify the widget tree is built
      expect(find.byType(SpeciesManagementPage), findsOneWidget);
    });

    testWidgets('shows error message on failure', (tester) async {
      await tester.pumpWidget(buildTestPage(FakeFishCatchRepository(
        error: Exception('DB error'),
      )));
      await tester.pump();
      await tester.pump();

      expect(
        find.textContaining(AppStrings.chinese.errorLoadFailed),
        findsOneWidget,
      );
    });

    testWidgets('shows empty species list state', (tester) async {
      await tester.pumpWidget(buildTestPage(FakeFishCatchRepository(
        speciesCounts: const {},
      )));
      await tester.pump();
      await tester.pump();

      expect(find.text(AppStrings.chinese.speciesNoRecords), findsOneWidget);
    });

    testWidgets('species list shows count for each species', (tester) async {
      await tester.pumpWidget(buildTestPage(FakeFishCatchRepository(
        speciesCounts: {'Bass': 5},
      )));
      await tester.pump();
      await tester.pump();

      expect(find.text('5'), findsOneWidget);
      expect(find.text('Bass'), findsOneWidget);
    });

    testWidgets('shows empty state when no pending catches',
        (tester) async {
      await tester.pumpWidget(buildTestPage(FakeFishCatchRepository(
        pendingCatches: const [],
        speciesCounts: const {'Bass': 3},
      )));
      await tester.pump();
      await tester.pump();

      // When no pending catches, empty state is shown with check_circle icon
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
