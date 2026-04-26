import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/watermark_settings.dart';
import 'package:lurebox/core/providers/watermark_provider.dart';
import 'package:lurebox/core/services/settings_service.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsService extends Mock implements SettingsService {}

class FakeWatermarkSettings extends Fake implements WatermarkSettings {}

void main() {
  late MockSettingsService mockService;
  late WatermarkSettingsNotifier notifier;

  setUpAll(() {
    registerFallbackValue(FakeWatermarkSettings());
  });

  setUp(() {
    mockService = MockSettingsService();
    when(() => mockService.getWatermarkSettings())
        .thenAnswer((_) async => const WatermarkSettings());
    notifier = WatermarkSettingsNotifier(mockService);
  });

  group('WatermarkSettingsNotifier', () {
    group('initial state', () {
      test('default WatermarkSettings values are correct', () {
        const settings = WatermarkSettings();
        expect(settings.enabled, true);
        expect(settings.style, WatermarkStyle.minimal);
        expect(settings.blurRadius, 10.0);
        expect(settings.backgroundOpacity, 0.5);
        expect(settings.backgroundColor, 0xFF000000);
        expect(settings.fontSize, 14.0);
        expect(settings.textColor, 0xFFFFFFFF);
        expect(settings.position, WatermarkPosition.bottomLeft);
        expect(settings.customText, isNull);
        expect(
          settings.infoTypes,
          containsAll([
            WatermarkInfoType.species,
            WatermarkInfoType.length,
            WatermarkInfoType.location,
            WatermarkInfoType.airTemperature,
            WatermarkInfoType.pressure,
            WatermarkInfoType.weather,
            WatermarkInfoType.appName,
          ]),
        );
      });

      test('constructor loads settings from service', () async {
        // Wait for _loadSettings to complete
        await Future.delayed(Duration.zero);
        verify(() => mockService.getWatermarkSettings()).called(1);
      });
    });

    group('_loadSettings', () {
      test('loads settings from service and updates state', () async {
        const loadedSettings = WatermarkSettings(
          enabled: false,
          style: WatermarkStyle.bold,
          blurRadius: 20.0,
        );
        when(() => mockService.getWatermarkSettings())
            .thenAnswer((_) async => loadedSettings);

        final notifier = WatermarkSettingsNotifier(mockService);
        await Future.delayed(Duration.zero);

        expect(notifier.state.enabled, false);
        expect(notifier.state.style, WatermarkStyle.bold);
        expect(notifier.state.blurRadius, 20.0);
      });

      test('_loadSettings does not throw after dispose', () async {
        // Create a notifier where _loadSettings will complete after dispose
        final completer = Completer<WatermarkSettings>();
        when(() => mockService.getWatermarkSettings())
            .thenAnswer((_) => completer.future);

        final notifier = WatermarkSettingsNotifier(mockService);

        // Dispose immediately
        notifier.dispose();

        // Complete the future after dispose
        completer.complete(const WatermarkSettings());

        // Should not throw - the mounted check prevents state update after dispose
        await Future.delayed(Duration.zero);
      });
    });

    group('updateSettings', () {
      test('saves to service and updates state', () async {
        when(() => mockService.saveWatermarkSettings(any()))
            .thenAnswer((_) async {});

        await Future.delayed(Duration.zero);

        const newSettings = WatermarkSettings(
          enabled: false,
          style: WatermarkStyle.elegant,
          blurRadius: 25.0,
        );

        await notifier.updateSettings(newSettings);

        expect(notifier.state.enabled, false);
        expect(notifier.state.style, WatermarkStyle.elegant);
        expect(notifier.state.blurRadius, 25.0);
        verify(() => mockService.saveWatermarkSettings(newSettings)).called(1);
      });

      test('updateSettings calls service with correct settings', () async {
        when(() => mockService.saveWatermarkSettings(any()))
            .thenAnswer((_) async {});

        await Future.delayed(Duration.zero);

        const newSettings = WatermarkSettings(
          fontSize: 18.0,
          textColor: 0xFF000000,
        );

        await notifier.updateSettings(newSettings);

        verify(() => mockService.saveWatermarkSettings(newSettings)).called(1);
      });
    });

    group('updateEnabled', () {
      test('toggles enabled to false', () async {
        when(() => mockService.saveWatermarkSettings(any()))
            .thenAnswer((_) async {});

        await Future.delayed(Duration.zero);

        await notifier.updateEnabled(false);

        expect(notifier.state.enabled, false);
        verify(() => mockService.saveWatermarkSettings(any())).called(1);
      });

      test('toggles enabled to true', () async {
        when(() => mockService.saveWatermarkSettings(any()))
            .thenAnswer((_) async {});

        await Future.delayed(Duration.zero);

        // First set to false
        await notifier.updateEnabled(false);
        // Then set back to true
        await notifier.updateEnabled(true);

        expect(notifier.state.enabled, true);
        // Called twice: once for false, once for true
        verify(() => mockService.saveWatermarkSettings(any())).called(2);
      });
    });

    group('updateStyle', () {
      test('updates style with elegant preset values', () async {
        when(() => mockService.saveWatermarkSettings(any()))
            .thenAnswer((_) async {});

        await Future.delayed(Duration.zero);

        await notifier.updateStyle(WatermarkStyle.elegant);

        expect(notifier.state.style, WatermarkStyle.elegant);
        expect(notifier.state.blurRadius, 16); // from elegant preset
        expect(notifier.state.backgroundOpacity, 0.35); // from elegant preset
        expect(
            notifier.state.backgroundColor, 0xFF1A1A2E); // from elegant preset
        expect(notifier.state.fontSize, 12); // from elegant preset
        expect(notifier.state.textColor, 0xFFE0E0E0); // from elegant preset
        expect(notifier.state.position,
            WatermarkPosition.bottomRight); // from elegant preset
        verify(() => mockService.saveWatermarkSettings(any())).called(1);
      });

      test('updates style with bold preset values', () async {
        when(() => mockService.saveWatermarkSettings(any()))
            .thenAnswer((_) async {});

        await Future.delayed(Duration.zero);

        await notifier.updateStyle(WatermarkStyle.bold);

        expect(notifier.state.style, WatermarkStyle.bold);
        expect(notifier.state.blurRadius, 6); // from bold preset
        expect(notifier.state.backgroundOpacity, 0.7); // from bold preset
        expect(
            notifier.state.backgroundColor, 0xFF000000); // from bold preset
        expect(notifier.state.fontSize, 20); // from bold preset
        expect(notifier.state.textColor, 0xFFFFFFFF); // from bold preset
        expect(
            notifier.state.position, WatermarkPosition.center); // from bold preset
        verify(() => mockService.saveWatermarkSettings(any())).called(1);
      });
    });

    group('toggleInfoType', () {
      test('adds info type when not present', () async {
        when(() => mockService.saveWatermarkSettings(any()))
            .thenAnswer((_) async {});

        await Future.delayed(Duration.zero);

        // weight is not in default infoTypes
        await notifier.toggleInfoType(WatermarkInfoType.weight);

        expect(notifier.state.infoTypes, contains(WatermarkInfoType.weight));
        verify(() => mockService.saveWatermarkSettings(any())).called(1);
      });

      test('removes info type when present', () async {
        when(() => mockService.saveWatermarkSettings(any()))
            .thenAnswer((_) async {});

        await Future.delayed(Duration.zero);

        // species is in default infoTypes
        await notifier.toggleInfoType(WatermarkInfoType.species);

        expect(notifier.state.infoTypes, isNot(contains(WatermarkInfoType.species)));
        verify(() => mockService.saveWatermarkSettings(any())).called(1);
      });
    });

    group('reorderInfoTypes', () {
      test('reorders list correctly when moving item forward', () async {
        when(() => mockService.saveWatermarkSettings(any()))
            .thenAnswer((_) async {});

        await Future.delayed(Duration.zero);

        // Default order: species, length, location, airTemperature, pressure, weather, appName
        // Move species (index 0) to position 2
        await notifier.reorderInfoTypes(0, 2);

        expect(notifier.state.infoTypes[0], WatermarkInfoType.length);
        expect(notifier.state.infoTypes[1], WatermarkInfoType.species);
        verify(() => mockService.saveWatermarkSettings(any())).called(1);
      });

      test('reorders list correctly when moving item backward', () async {
        when(() => mockService.saveWatermarkSettings(any()))
            .thenAnswer((_) async {});

        await Future.delayed(Duration.zero);

        // Move appName (last index) to position 0
        await notifier.reorderInfoTypes(6, 0);

        expect(notifier.state.infoTypes[0], WatermarkInfoType.appName);
        expect(notifier.state.infoTypes[6], WatermarkInfoType.weather);
        verify(() => mockService.saveWatermarkSettings(any())).called(1);
      });
    });

    group('updateBlurRadius', () {
      test('updates blurRadius correctly', () async {
        when(() => mockService.saveWatermarkSettings(any()))
            .thenAnswer((_) async {});

        await Future.delayed(Duration.zero);

        await notifier.updateBlurRadius(15.0);

        expect(notifier.state.blurRadius, 15.0);
        verify(() => mockService.saveWatermarkSettings(any())).called(1);
      });
    });

    group('updateBackgroundColor', () {
      test('updates backgroundColor correctly', () async {
        when(() => mockService.saveWatermarkSettings(any()))
            .thenAnswer((_) async {});

        await Future.delayed(Duration.zero);

        await notifier.updateBackgroundColor(0xFFCCCCCC);

        expect(notifier.state.backgroundColor, 0xFFCCCCCC);
        verify(() => mockService.saveWatermarkSettings(any())).called(1);
      });
    });

    group('updateBackgroundOpacity', () {
      test('updates backgroundOpacity correctly', () async {
        when(() => mockService.saveWatermarkSettings(any()))
            .thenAnswer((_) async {});

        await Future.delayed(Duration.zero);

        await notifier.updateBackgroundOpacity(0.8);

        expect(notifier.state.backgroundOpacity, 0.8);
        verify(() => mockService.saveWatermarkSettings(any())).called(1);
      });
    });

    group('updateFontSize', () {
      test('updates fontSize correctly', () async {
        when(() => mockService.saveWatermarkSettings(any()))
            .thenAnswer((_) async {});

        await Future.delayed(Duration.zero);

        await notifier.updateFontSize(16.0);

        expect(notifier.state.fontSize, 16.0);
        verify(() => mockService.saveWatermarkSettings(any())).called(1);
      });
    });

    group('updateTextColor', () {
      test('updates textColor correctly', () async {
        when(() => mockService.saveWatermarkSettings(any()))
            .thenAnswer((_) async {});

        await Future.delayed(Duration.zero);

        await notifier.updateTextColor(0xFF123456);

        expect(notifier.state.textColor, 0xFF123456);
        verify(() => mockService.saveWatermarkSettings(any())).called(1);
      });
    });

    group('updatePosition', () {
      test('updates position correctly', () async {
        when(() => mockService.saveWatermarkSettings(any()))
            .thenAnswer((_) async {});

        await Future.delayed(Duration.zero);

        await notifier.updatePosition(WatermarkPosition.topRight);

        expect(notifier.state.position, WatermarkPosition.topRight);
        verify(() => mockService.saveWatermarkSettings(any())).called(1);
      });
    });

    group('updateCustomText', () {
      test('updates customText correctly', () async {
        when(() => mockService.saveWatermarkSettings(any()))
            .thenAnswer((_) async {});

        await Future.delayed(Duration.zero);

        await notifier.updateCustomText('My Custom Watermark');

        expect(notifier.state.customText, 'My Custom Watermark');
        verify(() => mockService.saveWatermarkSettings(any())).called(1);
      });

      test('updateCustomText calls save with updated settings', () async {
        when(() => mockService.saveWatermarkSettings(any()))
            .thenAnswer((_) async {});

        await Future.delayed(Duration.zero);

        await notifier.updateCustomText('Another Text');

        expect(notifier.state.customText, 'Another Text');
        verify(() => mockService.saveWatermarkSettings(any())).called(1);
      });
    });
  });
}
