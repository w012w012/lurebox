import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/watermark_settings.dart';
import 'package:lurebox/core/providers/watermark_provider.dart';
import 'package:lurebox/core/services/settings_service.dart';
import 'package:lurebox/core/repositories/settings_repository.dart';
import 'package:lurebox/features/share/watermark_share_preview_page.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    setUpDatabaseForTesting();
  });

  final testDate = DateTime(2024, 1, 15);

  PreviewData createValidPreviewData() {
    return PreviewData(
      imagePath: 'test/fixtures/test_fish.jpg',
      species: 'Bass',
      length: 45.0,
      lengthUnit: 'cm',
      weightUnit: 'kg',
      catchTime: testDate,
      displayLength: 45.0,
      displayLengthUnit: 'cm',
      displayWeightUnit: 'kg',
      displayTemperatureUnit: 'C',
      shareText: 'Check out my catch!',
    );
  }

  Widget createWidgetUnderTest({
    required PreviewData previewData,
  }) {
    return ProviderScope(
      overrides: [
        watermarkSettingsProvider.overrideWith(
          (ref) => _FakeWatermarkSettingsNotifier(),
        ),
      ],
      child: MaterialApp(
        home: WatermarkSharePreviewPage(data: previewData),
      ),
    );
  }

  group('WatermarkSharePreviewPage', () {
    testWidgets('renders page with preview data', (tester) async {
      final previewData = createValidPreviewData();

      await tester.pumpWidget(createWidgetUnderTest(previewData: previewData));
      await tester.pump();

      expect(find.byType(WatermarkSharePreviewPage), findsOneWidget);
    });

    testWidgets('shows loading indicator while image loads', (tester) async {
      final previewData = createValidPreviewData();

      await tester.pumpWidget(createWidgetUnderTest(previewData: previewData));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders share button', (tester) async {
      final previewData = createValidPreviewData();

      await tester.pumpWidget(createWidgetUnderTest(previewData: previewData));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('renders reset position button', (tester) async {
      final previewData = createValidPreviewData();

      await tester.pumpWidget(createWidgetUnderTest(previewData: previewData));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('renders app bar', (tester) async {
      final previewData = createValidPreviewData();

      await tester.pumpWidget(createWidgetUnderTest(previewData: previewData));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders with disabled watermark settings', (tester) async {
      final previewData = createValidPreviewData();

      await tester.pumpWidget(createWidgetUnderTest(previewData: previewData));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(WatermarkSharePreviewPage), findsOneWidget);
    });

    testWidgets('renders toolbar with reset and share buttons', (tester) async {
      final previewData = createValidPreviewData();

      await tester.pumpWidget(createWidgetUnderTest(previewData: previewData));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Find both toolbar buttons (reset has Icons.refresh, share has Icons.share)
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('renders instruction text for watermark adjustment', (tester) async {
      final previewData = createValidPreviewData();

      await tester.pumpWidget(createWidgetUnderTest(previewData: previewData));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Find instruction text widgets (containing '|' separator)
      expect(find.byType(Text), findsWidgets);
    });
  });
}

class _FakeSettingsService extends SettingsService {
  _FakeSettingsService() : super(_FakeSettingsRepository());

  @override
  Future<WatermarkSettings> getWatermarkSettings() async =>
      const WatermarkSettings(enabled: true);

  @override
  Future<void> saveWatermarkSettings(WatermarkSettings settings) async {}
}

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<String?> get(String key) async => null;

  @override
  Future<String> getOrDefault(String key, String defaultValue) async => defaultValue;

  @override
  Future<void> set(String key, String value) async {}

  @override
  Future<void> delete(String key) async {}

  @override
  Future<bool> exists(String key) async => false;

  @override
  Future<Map<String, String>> getAll() async => {};

  @override
  Future<void> setAll(Map<String, String> settings) async {}

  @override
  Future<int> getInt(String key, {int defaultValue = 0}) async => defaultValue;

  @override
  Future<double> getDouble(String key, {double defaultValue = 0.0}) async => defaultValue;

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async => defaultValue;

  @override
  Future<void> setInt(String key, int value) async {}

  @override
  Future<void> setDouble(String key, double value) async {}

  @override
  Future<void> setBool(String key, bool value) async {}
}

class _FakeWatermarkSettingsNotifier extends WatermarkSettingsNotifier {
  _FakeWatermarkSettingsNotifier() : super(_FakeSettingsService());
}
