import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/models/watermark_settings.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/providers/fish_detail_view_model.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/services/settings_service.dart';
import 'package:lurebox/features/fish_detail/fish_detail_page.dart';

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
      AiRecognitionSettings settings,) async {}

  @override
  Future<void> deleteAiRecognitionSettings() async {}
}

class MockFishDetailViewModel extends StateNotifier<FishDetailState>
    implements FishDetailViewModel {
  MockFishDetailViewModel(super.initialState);

  @override
  int get fishId => 1;

  @override
  Future<void> loadFish() async {}

  @override
  Future<bool> deleteFish() async => true;

  @override
  void setSharing(bool value) {}

  @override
  Future<void> refresh() async {}
}

const _mockSettingsService = MockSettingsService();

Widget _buildPage(List<Override> overrides) {
  return ProviderScope(
    overrides: [
      appSettingsProvider.overrideWith(
        (ref) => AppSettingsNotifier(_mockSettingsService),
      ),
      currentStringsProvider.overrideWithValue(AppStrings.english),
      ...overrides,
    ],
    child: const MaterialApp(
      home: FishDetailPage(fishId: 1),
    ),
  );
}

void main() {
  setUpAll(() {
    setUpDatabaseForTesting();
    registerFallbackValues();
  });

  group('FishDetailPage', () {
    testWidgets('shows loading indicator when state is loading',
        (tester) async {
      await tester.pumpWidget(_buildPage([
        fishDetailViewModelProvider(1).overrideWith(
          (ref) => MockFishDetailViewModel(
            const FishDetailState(),
          ),
        ),
      ]),);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Bass'), findsNothing);
    });

    testWidgets('shows error state with message', (tester) async {
      await tester.pumpWidget(_buildPage([
        fishDetailViewModelProvider(1).overrideWith(
          (ref) => MockFishDetailViewModel(
            const FishDetailState(
              isLoading: false,
              errorMessage: 'Fish not found',
            ),
          ),
        ),
      ]),);
      await tester.pump();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Fish not found'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows fish data when loaded', (tester) async {
      await tester.pumpWidget(_buildPage([
        fishDetailViewModelProvider(1).overrideWith(
          (ref) => MockFishDetailViewModel(
            const FishDetailState(
              isLoading: false,
              fish: {
                'id': 1,
                'species': 'Bass',
                'length': 35.5,
                'length_unit': 'cm',
                'weight': 2.5,
                'weight_unit': 'kg',
                'fate': 0,
                'catch_time': '2024-01-15T10:30:00.000',
                'location_name': 'Lake Michigan',
                'image_path': '/test/fish.jpg',
              },
            ),
          ),
        ),
      ]),);
      await tester.pump();

      expect(find.text('Bass'), findsOneWidget);
      expect(find.text('Lake Michigan'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('shows fish with equipment info', (tester) async {
      await tester.pumpWidget(_buildPage([
        fishDetailViewModelProvider(1).overrideWith(
          (ref) => MockFishDetailViewModel(
            const FishDetailState(
              isLoading: false,
              fish: {
                'id': 1,
                'species': 'Trout',
                'length': 40.0,
                'length_unit': 'cm',
                'weight': 3.0,
                'weight_unit': 'kg',
                'fate': 0,
                'catch_time': '2024-01-15T10:30:00.000',
                'location_name': 'River',
                'image_path': '/test/fish.jpg',
              },
              rodEquipment: {
                'type': 'rod',
                'brand': 'Shimano',
                'model': 'Expride',
              },
            ),
          ),
        ),
      ]),);
      await tester.pump();

      expect(find.text('Trout'), findsOneWidget);
      expect(find.text('River'), findsOneWidget);
    });

    testWidgets('shows null fish as error state', (tester) async {
      await tester.pumpWidget(_buildPage([
        fishDetailViewModelProvider(1).overrideWith(
          (ref) => MockFishDetailViewModel(
            const FishDetailState(
              isLoading: false,
            ),
          ),
        ),
      ]),);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Fish not found'), findsOneWidget);
    });

    testWidgets('shows kept catch', (tester) async {
      await tester.pumpWidget(_buildPage([
        fishDetailViewModelProvider(1).overrideWith(
          (ref) => MockFishDetailViewModel(
            const FishDetailState(
              isLoading: false,
              fish: {
                'id': 1,
                'species': 'Pike',
                'length': 50.0,
                'length_unit': 'cm',
                'weight': 5.0,
                'weight_unit': 'kg',
                'fate': 1,
                'catch_time': '2024-06-15T14:30:00.000',
                'image_path': '/test/fish.jpg',
              },
            ),
          ),
        ),
      ]),);
      await tester.pump();

      expect(find.text('Pike'), findsOneWidget);
      expect(find.text('🍳 Keep'), findsOneWidget);
    });
  });
}
