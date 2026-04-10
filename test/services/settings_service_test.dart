import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/services/settings_service.dart';
import 'package:lurebox/core/models/watermark_settings.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import '../helpers/test_helpers.dart';

void main() {
  late MockSettingsRepository mockRepository;
  late SettingsService settingsService;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockRepository = MockSettingsRepository();
    settingsService = SettingsService(mockRepository);
  });

  group('SettingsService', () {
    group('WatermarkSettings', () {
      test('saveWatermarkSettings calls repository.set with encoded JSON',
          () async {
        final settings = const WatermarkSettings(
          enabled: true,
          style: WatermarkStyle.minimal,
          blurRadius: 15.0,
          backgroundOpacity: 0.7,
          backgroundColor: 0xFF111111,
          fontSize: 16.0,
          textColor: 0xFF222222,
          position: WatermarkPosition.topRight,
        );

        when(() => mockRepository.set(any(), any())).thenAnswer((_) async {});

        await settingsService.saveWatermarkSettings(settings);

        verify(() =>
                mockRepository.set('watermark_settings', settings.encode()))
            .called(1);
      });

      test('getWatermarkSettings decodes JSON from repository', () async {
        final settings = const WatermarkSettings(
          enabled: false,
          style: WatermarkStyle.minimal,
          blurRadius: 20.0,
          backgroundOpacity: 0.8,
          backgroundColor: 0xFF333333,
          fontSize: 18.0,
          textColor: 0xFF444444,
          position: WatermarkPosition.center,
        );
        final encoded = settings.encode();

        when(() => mockRepository.get('watermark_settings'))
            .thenAnswer((_) async => encoded);

        final result = await settingsService.getWatermarkSettings();

        expect(result.enabled, equals(false));
        expect(result.blurRadius, equals(20.0));
        expect(result.backgroundOpacity, equals(0.8));
        expect(result.backgroundColor, equals(0xFF333333));
        expect(result.fontSize, equals(18.0));
        expect(result.textColor, equals(0xFF444444));
        expect(result.position, equals(WatermarkPosition.center));
      });

      test('getWatermarkSettings returns default when repository returns null',
          () async {
        when(() => mockRepository.get('watermark_settings'))
            .thenAnswer((_) async => null);

        final result = await settingsService.getWatermarkSettings();

        expect(result.enabled, equals(true)); // default
        expect(result.style, equals(WatermarkStyle.minimal)); // default
        expect(result.blurRadius, equals(10.0)); // default
        expect(result.backgroundOpacity, equals(0.5)); // default
      });

      test('getWatermarkSettings returns default when JSON parsing fails',
          () async {
        when(() => mockRepository.get('watermark_settings'))
            .thenAnswer((_) async => 'invalid json {');

        final result = await settingsService.getWatermarkSettings();

        expect(result.enabled, equals(true)); // default
        expect(result.blurRadius, equals(10.0)); // default
      });
    });

    group('AppSettings', () {
      test('saveAppSettings calls repository.set with encoded JSON', () async {
        final settings = const AppSettings(
          units: UnitSettings(
            fishLengthUnit: 'inch',
            fishWeightUnit: 'lb',
          ),
          darkMode: DarkMode.dark,
          language: AppLanguage.english,
        );

        when(() => mockRepository.set(any(), any())).thenAnswer((_) async {});

        await settingsService.saveAppSettings(settings);

        verify(() => mockRepository.set('app_settings', settings.encode()))
            .called(1);
      });

      test('getAppSettings decodes JSON from repository', () async {
        final settings = const AppSettings(
          units: UnitSettings(
            fishLengthUnit: 'm',
            fishWeightUnit: 'kg',
          ),
          darkMode: DarkMode.light,
          language: AppLanguage.chinese,
        );
        final encoded = settings.encode();

        when(() => mockRepository.get('app_settings'))
            .thenAnswer((_) async => encoded);

        final result = await settingsService.getAppSettings();

        expect(result.units.fishLengthUnit, equals('m'));
        expect(result.units.fishWeightUnit, equals('kg'));
        expect(result.darkMode, equals(DarkMode.light));
        expect(result.language, equals(AppLanguage.chinese));
      });

      test('getAppSettings returns default when repository returns null',
          () async {
        when(() => mockRepository.get('app_settings'))
            .thenAnswer((_) async => null);

        final result = await settingsService.getAppSettings();

        expect(result.units.fishLengthUnit, equals('cm')); // default
        expect(result.units.fishWeightUnit, equals('kg')); // default
        expect(result.darkMode, equals(DarkMode.system)); // default
        expect(result.language, equals(AppLanguage.chinese)); // default
      });

      test('getAppSettings returns default when JSON parsing fails', () async {
        when(() => mockRepository.get('app_settings'))
            .thenAnswer((_) async => 'not valid json');

        final result = await settingsService.getAppSettings();

        expect(result.units.fishLengthUnit, equals('cm')); // default
        expect(result.darkMode, equals(DarkMode.system)); // default
      });
    });

    group('AiRecognitionSettings', () {
      test('saveAiRecognitionSettings calls repository.set with encoded JSON',
          () async {
        final settings = const AiRecognitionSettings(
          currentProvider: AiRecognitionProvider.openai,
          autoRecognize: false,
          timeout: Duration(seconds: 30),
        );

        when(() => mockRepository.set(any(), any())).thenAnswer((_) async {});

        await settingsService.saveAiRecognitionSettings(settings);

        verify(() => mockRepository.set(
            'ai_recognition_settings', settings.encode())).called(1);
      });

      test('getAiRecognitionSettings decodes JSON from repository', () async {
        final settings = const AiRecognitionSettings(
          currentProvider: AiRecognitionProvider.minimax,
          autoRecognize: true,
          timeout: Duration(seconds: 15),
        );
        final encoded = settings.encode();

        when(() => mockRepository.get('ai_recognition_settings'))
            .thenAnswer((_) async => encoded);

        final result = await settingsService.getAiRecognitionSettings();

        expect(result.currentProvider, equals(AiRecognitionProvider.minimax));
        expect(result.autoRecognize, equals(true));
        expect(result.timeout, equals(const Duration(seconds: 15)));
      });

      test(
          'getAiRecognitionSettings returns default when repository returns null',
          () async {
        when(() => mockRepository.get('ai_recognition_settings'))
            .thenAnswer((_) async => null);

        final result = await settingsService.getAiRecognitionSettings();

        expect(result.currentProvider,
            equals(AiRecognitionProvider.gemini)); // default
        expect(result.autoRecognize, equals(true)); // default
        expect(result.timeout, equals(const Duration(seconds: 10))); // default
      });

      test('getAiRecognitionSettings returns default when JSON parsing fails',
          () async {
        when(() => mockRepository.get('ai_recognition_settings'))
            .thenAnswer((_) async => 'corrupted json }}');

        final result = await settingsService.getAiRecognitionSettings();

        expect(result.currentProvider,
            equals(AiRecognitionProvider.gemini)); // default
        expect(result.autoRecognize, equals(true)); // default
      });
    });
  });
}
