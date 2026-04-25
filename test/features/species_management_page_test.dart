import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/watermark_settings.dart';
import 'package:lurebox/core/models/paginated_result.dart';
import 'package:lurebox/core/models/fish_filter.dart';
import 'package:lurebox/core/constants/pagination_constants.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/providers/pending_recognition_providers.dart';
import 'package:lurebox/core/services/settings_service.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/repositories/fish_catch_repository.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/features/settings/species_management_page.dart';
import '../helpers/test_helpers.dart';

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
      AiRecognitionSettings settings) async {}
  @override
  Future<void> deleteAiRecognitionSettings() async {}
}

class FakeFishCatchRepository extends Fake implements FishCatchRepository {
  final List<FishCatch> _pending;
  final Map<String, int> _speciesCounts;
  final Object? _error;

  FakeFishCatchRepository({
    List<FishCatch> pending = const [],
    Map<String, int> speciesCounts = const {},
    Object? error,
  })  : _pending = pending,
        _speciesCounts = speciesCounts,
        _error = error;

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
    if (_error != null) throw _error!;
    return _pending;
  }
  @override
  Future<int> getPendingRecognitionCount() async => _pending.length;
  @override
  Future<void> updateSpecies(int id, String species) async {}
  @override
  Future<void> batchUpdateSpecies(
      List<int> ids, List<String> speciesList) async {}
  @override
  Future<Map<String, int>> getSpeciesCounts() async {
    if (_error != null) throw _error!;
    return _speciesCounts;
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
    int pageSize = PaginationConstants.defaultPageSize,
    required FishFilter filter,
  }) async =>
      PaginatedResult(items: [], totalCount: 0, page: page, pageSize: pageSize, hasMore: false);
  @override
  Future<int> getCount() async => 0;
}

const _mockSettingsService = MockSettingsService();

Widget _buildPage(FakeFishCatchRepository repo) {
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

  group('SpeciesManagementPage', () {
    testWidgets('renders AppBar with title', (tester) async {
      await tester.pumpWidget(_buildPage(FakeFishCatchRepository()));
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.text(AppStrings.chinese.speciesManagement),
        findsOneWidget,
      );
    });

    testWidgets('shows species list when data loaded', (tester) async {
      await tester.pumpWidget(_buildPage(FakeFishCatchRepository(
        speciesCounts: {'Bass': 5, 'Trout': 3},
      )));
      await tester.pump();
      await tester.pump();

      expect(find.text('Bass'), findsOneWidget);
      expect(find.text('Trout'), findsOneWidget);
    });

    testWidgets('shows error message on failure', (tester) async {
      await tester.pumpWidget(_buildPage(FakeFishCatchRepository(
        error: Exception('DB error'),
      )));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining(AppStrings.chinese.errorLoadFailed), findsOneWidget);
    });
  });
}
