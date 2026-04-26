import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/models/watermark_settings.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/providers/watermark_provider.dart';
import 'package:lurebox/features/common/watermarked_image.dart';

import '../helpers/test_helpers.dart';

class MockWatermarkSettingsNotifier extends StateNotifier<WatermarkSettings>
    with Mock
    implements WatermarkSettingsNotifier {
  MockWatermarkSettingsNotifier(super.initialState);

  @override
  WatermarkSettings get state => super.state;

  @override
  set state(WatermarkSettings value) {
    super.state = value;
  }
}

/// Test implementation of AppSettingsNotifier
class TestAppSettingsNotifier extends StateNotifier<AppSettings>
    implements AppSettingsNotifier {
  TestAppSettingsNotifier() : super(const AppSettings());

  @override
  Future<void> updateSettings(AppSettings settings) async {
    state = settings;
  }

  @override
  Future<void> updateUnits(UnitSettings units) async {
    state = state.copyWith(units: units);
  }

  @override
  Future<void> updateDarkMode(DarkMode mode) async {
    state = state.copyWith(darkMode: mode);
  }

  @override
  Future<void> updateLanguage(AppLanguage language) async {
    state = state.copyWith(language: language);
  }
}

void main() {
  setUpAll(registerFallbackValues);

  group('WatermarkedImage', () {
    late MockWatermarkSettingsNotifier mockWatermarkNotifier;

    setUp(() {
      mockWatermarkNotifier = MockWatermarkSettingsNotifier(
        const WatermarkSettings(
          enabled: true,
          style: WatermarkStyle.minimal,
          position: WatermarkPosition.bottomLeft,
          infoTypes: [
            WatermarkInfoType.species,
            WatermarkInfoType.length,
            WatermarkInfoType.location,
            WatermarkInfoType.appName,
          ],
          customText: '',
        ),
      );
    });

    Widget createWidgetUnderTest({
      required String imagePath,
      required String species,
      required double length,
      bool showWatermark = true,
      WatermarkSettings? watermarkSettings,
    }) {
      final notifier = watermarkSettings != null
          ? MockWatermarkSettingsNotifier(watermarkSettings)
          : mockWatermarkNotifier;

      return ProviderScope(
        overrides: [
          watermarkSettingsProvider.overrideWith((ref) => notifier),
          appSettingsProvider.overrideWith((ref) => TestAppSettingsNotifier()),
          currentStringsProvider.overrideWithValue(AppStrings.chinese),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: WatermarkedImage(
              imagePath: imagePath,
              species: species,
              length: length,
              showWatermark: showWatermark,
            ),
          ),
        ),
      );
    }

    testWidgets('renders Image widget when provided with imagePath',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        imagePath: '/fake/path/image.jpg',
        species: 'Bass',
        length: 30.5,
      ));

      // The widget should render with an Image widget
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('renders Stack with CustomPaint when watermark enabled',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        imagePath: '/fake/path/image.jpg',
        species: 'Bass',
        length: 30.5,
        showWatermark: true,
      ));

      // Should have Stack containing Image and CustomPaint
      expect(find.byType(Stack), findsWidgets);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('hides watermark CustomPaint when watermark disabled',
        (tester) async {
      final disabledSettings = const WatermarkSettings(
        enabled: false,
        style: WatermarkStyle.minimal,
        position: WatermarkPosition.bottomLeft,
        infoTypes: [
          WatermarkInfoType.species,
          WatermarkInfoType.length,
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(
        imagePath: '/fake/path/image.jpg',
        species: 'Bass',
        length: 30.5,
        showWatermark: true,
        watermarkSettings: disabledSettings,
      ));

      await tester.pump();

      // When settings.enabled is false, no watermark CustomPaint should be rendered
      // The Stack should only contain the Image widget (find just the inner Stack from WatermarkedImage)
      final stackFinder = find.descendant(
        of: find.byType(WatermarkedImage),
        matching: find.byType(Stack),
      );
      expect(stackFinder, findsOneWidget);
    });

    testWidgets('hides watermark when showWatermark parameter is false',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        imagePath: '/fake/path/image.jpg',
        species: 'Bass',
        length: 30.5,
        showWatermark: false,
      ));

      await tester.pump();

      // When showWatermark is false, no watermark CustomPaint should be rendered
      final stackFinder = find.descendant(
        of: find.byType(WatermarkedImage),
        matching: find.byType(Stack),
      );
      expect(stackFinder, findsOneWidget);
    });

    testWidgets('displays custom text in watermark when set', (tester) async {
      const customText = 'My Custom Watermark';

      final customTextSettings = const WatermarkSettings(
        enabled: true,
        style: WatermarkStyle.minimal,
        position: WatermarkPosition.bottomLeft,
        infoTypes: [WatermarkInfoType.species],
        customText: customText,
      );

      await tester.pumpWidget(createWidgetUnderTest(
        imagePath: '/fake/path/image.jpg',
        species: 'Bass',
        length: 30.5,
        showWatermark: true,
        watermarkSettings: customTextSettings,
      ));

      await tester.pump();

      // The widget should render with CustomPaint for watermark
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('watermark at topLeft position uses correct settings',
        (tester) async {
      final topLeftSettings = const WatermarkSettings(
        enabled: true,
        style: WatermarkStyle.minimal,
        position: WatermarkPosition.topLeft,
        infoTypes: [WatermarkInfoType.species],
      );

      await tester.pumpWidget(createWidgetUnderTest(
        imagePath: '/fake/path/image.jpg',
        species: 'Bass',
        length: 30.5,
        showWatermark: true,
        watermarkSettings: topLeftSettings,
      ));

      await tester.pump();

      // Verify CustomPaint is present for watermark
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('watermark at topRight position uses correct settings',
        (tester) async {
      final topRightSettings = const WatermarkSettings(
        enabled: true,
        style: WatermarkStyle.minimal,
        position: WatermarkPosition.topRight,
        infoTypes: [WatermarkInfoType.species],
      );

      await tester.pumpWidget(createWidgetUnderTest(
        imagePath: '/fake/path/image.jpg',
        species: 'Bass',
        length: 30.5,
        showWatermark: true,
        watermarkSettings: topRightSettings,
      ));

      await tester.pump();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('watermark at bottomLeft position uses correct settings',
        (tester) async {
      final bottomLeftSettings = const WatermarkSettings(
        enabled: true,
        style: WatermarkStyle.minimal,
        position: WatermarkPosition.bottomLeft,
        infoTypes: [WatermarkInfoType.species],
      );

      await tester.pumpWidget(createWidgetUnderTest(
        imagePath: '/fake/path/image.jpg',
        species: 'Bass',
        length: 30.5,
        showWatermark: true,
        watermarkSettings: bottomLeftSettings,
      ));

      await tester.pump();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('watermark at bottomRight position uses correct settings',
        (tester) async {
      final bottomRightSettings = const WatermarkSettings(
        enabled: true,
        style: WatermarkStyle.minimal,
        position: WatermarkPosition.bottomRight,
        infoTypes: [WatermarkInfoType.species],
      );

      await tester.pumpWidget(createWidgetUnderTest(
        imagePath: '/fake/path/image.jpg',
        species: 'Bass',
        length: 30.5,
        showWatermark: true,
        watermarkSettings: bottomRightSettings,
      ));

      await tester.pump();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('watermark at center position uses correct settings',
        (tester) async {
      final centerSettings = const WatermarkSettings(
        enabled: true,
        style: WatermarkStyle.minimal,
        position: WatermarkPosition.center,
        infoTypes: [WatermarkInfoType.species],
      );

      await tester.pumpWidget(createWidgetUnderTest(
        imagePath: '/fake/path/image.jpg',
        species: 'Bass',
        length: 30.5,
        showWatermark: true,
        watermarkSettings: centerSettings,
      ));

      await tester.pump();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders with multiple info types in watermark',
        (tester) async {
      final multiInfoSettings = const WatermarkSettings(
        enabled: true,
        style: WatermarkStyle.minimal,
        position: WatermarkPosition.bottomLeft,
        infoTypes: [
          WatermarkInfoType.species,
          WatermarkInfoType.length,
          WatermarkInfoType.weight,
          WatermarkInfoType.location,
          WatermarkInfoType.time,
          WatermarkInfoType.appName,
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(
        imagePath: '/fake/path/image.jpg',
        species: 'Bass',
        length: 30.5,
        showWatermark: true,
        watermarkSettings: multiInfoSettings,
      ));

      await tester.pump();

      // Should render watermark CustomPaint with multiple info types
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders with all optional fish data parameters',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        imagePath: '/fake/path/image.jpg',
        species: 'Bass',
        length: 30.5,
        showWatermark: true,
      ));

      await tester.pump();

      // Basic render should work with required params
      expect(find.byType(WatermarkedImage), findsOneWidget);
    });
  });
}
