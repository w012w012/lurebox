import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/watermark_settings.dart';
import 'package:lurebox/core/models/equipment.dart';
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
    AiRecognitionSettings settings,
  ) async {}

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
      await tester.pumpWidget(
        _buildPage([
          fishDetailViewModelProvider(1).overrideWith(
            (ref) => MockFishDetailViewModel(
              const FishDetailState(),
            ),
          ),
        ]),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Bass'), findsNothing);
    });

    testWidgets('shows error state with message', (tester) async {
      await tester.pumpWidget(
        _buildPage([
          fishDetailViewModelProvider(1).overrideWith(
            (ref) => MockFishDetailViewModel(
              const FishDetailState(
                isLoading: false,
                errorMessage: 'Fish not found',
              ),
            ),
          ),
        ]),
      );
      await tester.pump();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Fish not found'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows fish data when loaded', (tester) async {
      await tester.pumpWidget(
        _buildPage([
          fishDetailViewModelProvider(1).overrideWith(
            (ref) => MockFishDetailViewModel(
              FishDetailState(
                isLoading: false,
                fish: FishCatch(
                  id: 1,
                  imagePath: '/test/fish.jpg',
                  species: 'Bass',
                  length: 35.5,
                  fate: FishFateType.release,
                  catchTime: DateTime(2024, 1, 15, 10, 30),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  locationName: 'Lake Michigan',
                ),
              ),
            ),
          ),
        ]),
      );
      await tester.pump();

      expect(find.text('Bass'), findsOneWidget);
      expect(find.text('Lake Michigan'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('shows fish with equipment info', (tester) async {
      await tester.pumpWidget(
        _buildPage([
          fishDetailViewModelProvider(1).overrideWith(
            (ref) => MockFishDetailViewModel(
              FishDetailState(
                isLoading: false,
                fish: FishCatch(
                  id: 1,
                  imagePath: '/test/fish.jpg',
                  species: 'Trout',
                  length: 40.0,
                  fate: FishFateType.release,
                  catchTime: DateTime(2024, 1, 15, 10, 30),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  locationName: 'River',
                ),
                rodEquipment: Equipment(
                  id: 1,
                  type: EquipmentType.rod,
                  brand: 'Shimano',
                  model: 'Expride',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ),
            ),
          ),
        ]),
      );
      await tester.pump();

      expect(find.text('Trout'), findsOneWidget);
      expect(find.text('River'), findsOneWidget);
    });

    testWidgets('shows null fish as error state', (tester) async {
      await tester.pumpWidget(
        _buildPage([
          fishDetailViewModelProvider(1).overrideWith(
            (ref) => MockFishDetailViewModel(
              const FishDetailState(
                isLoading: false,
              ),
            ),
          ),
        ]),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Fish not found'), findsOneWidget);
    });

    testWidgets('shows kept catch', (tester) async {
      await tester.pumpWidget(
        _buildPage([
          fishDetailViewModelProvider(1).overrideWith(
            (ref) => MockFishDetailViewModel(
              FishDetailState(
                isLoading: false,
                fish: FishCatch(
                  id: 1,
                  imagePath: '/test/fish.jpg',
                  species: 'Pike',
                  length: 50.0,
                  fate: FishFateType.keep,
                  catchTime: DateTime(2024, 6, 15, 14, 30),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ),
            ),
          ),
        ]),
      );
      await tester.pump();

      expect(find.text('Pike'), findsOneWidget);
      expect(find.text('🍳 Keep'), findsOneWidget);
    });
  });
}
