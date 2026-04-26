import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/providers/ai_recognition_provider.dart';
import 'package:lurebox/core/services/settings_service.dart';

class MockSettingsService extends Mock implements SettingsService {}

class FakeAiRecognitionSettings extends Fake
    implements AiRecognitionSettings {}

void main() {
  late MockSettingsService mockService;

  setUpAll(() {
    registerFallbackValue(FakeAiRecognitionSettings());
  });

  setUp(() {
    mockService = MockSettingsService();
    when(() => mockService.getAiRecognitionSettings())
        .thenAnswer((_) async => const AiRecognitionSettings());
    when(() => mockService.saveAiRecognitionSettings(any()))
        .thenAnswer((_) async {});
  });

  group('AiRecognitionSettingsNotifier', () {
    test('initial state is default AiRecognitionSettings', () async {
      final notifier =
          AiRecognitionSettingsNotifier(mockService);

      // Allow async _loadSettings to complete
      await Future.delayed(Duration.zero);

      expect(notifier.state, const AiRecognitionSettings());
      expect(notifier.state.autoRecognize, isTrue);
      expect(notifier.state.currentProvider, AiRecognitionProvider.gemini);
      expect(notifier.state.providerConfigs, isEmpty);
    });

    test('loadSettings loads from SettingsService', () async {
      const customSettings = AiRecognitionSettings(
        currentProvider: AiRecognitionProvider.openai,
        autoRecognize: false,
      );
      when(() => mockService.getAiRecognitionSettings())
          .thenAnswer((_) async => customSettings);

      final notifier =
          AiRecognitionSettingsNotifier(mockService);

      await Future.delayed(Duration.zero);

      expect(notifier.state.currentProvider, AiRecognitionProvider.openai);
      expect(notifier.state.autoRecognize, isFalse);
    });

    test('loadSettings falls back to defaults on error', () async {
      when(() => mockService.getAiRecognitionSettings())
          .thenThrow(Exception('Settings load failed'));

      final notifier =
          AiRecognitionSettingsNotifier(mockService);

      await Future.delayed(Duration.zero);

      expect(notifier.state, const AiRecognitionSettings());
    });

    test('updateSettings saves and updates state', () async {
      final notifier =
          AiRecognitionSettingsNotifier(mockService);
      await Future.delayed(Duration.zero);

      const newSettings = AiRecognitionSettings(
        currentProvider: AiRecognitionProvider.claude,
        autoRecognize: true,
      );

      await notifier.updateSettings(newSettings);

      verify(() => mockService.saveAiRecognitionSettings(newSettings))
          .called(1);
      expect(notifier.state, newSettings);
    });

    test('updateProvider changes current provider', () async {
      final notifier =
          AiRecognitionSettingsNotifier(mockService);
      await Future.delayed(Duration.zero);

      await notifier.updateProvider(AiRecognitionProvider.deepseek);

      expect(notifier.state.currentProvider, AiRecognitionProvider.deepseek);
      verify(() => mockService.saveAiRecognitionSettings(any())).called(1);
    });

    test('updateApiKey updates api key for current provider', () async {
      final notifier =
          AiRecognitionSettingsNotifier(mockService);
      await Future.delayed(Duration.zero);

      await notifier.updateApiKey('sk-test-api-key-12345');

      expect(
        notifier.state.providerConfigs[AiRecognitionProvider.gemini]?.apiKey,
        'sk-test-api-key-12345',
      );
    });

    test('updateApiKey creates config for new provider', () async {
      final notifier =
          AiRecognitionSettingsNotifier(mockService);
      await Future.delayed(Duration.zero);

      // Change to a provider with no config first
      await notifier.updateProvider(AiRecognitionProvider.openai);
      await notifier.updateApiKey('sk-openai-key');

      expect(
        notifier.state.providerConfigs[AiRecognitionProvider.openai]?.apiKey,
        'sk-openai-key',
      );
    });

    test('toggleAutoRecognize toggles auto recognize flag', () async {
      final notifier =
          AiRecognitionSettingsNotifier(mockService);
      await Future.delayed(Duration.zero);

      expect(notifier.state.autoRecognize, isTrue);

      await notifier.toggleAutoRecognize();
      expect(notifier.state.autoRecognize, isFalse);

      await notifier.toggleAutoRecognize();
      expect(notifier.state.autoRecognize, isTrue);
    });
  });

  group('aiRecognitionSettingsProvider', () {
    test('provides AiRecognitionSettingsNotifier instance', () {
      final container = ProviderContainer(
        overrides: [
          settingsServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final provider = container.read(aiRecognitionSettingsProvider);

      expect(provider, isA<AiRecognitionSettings>());
    });

    test('state updates when notifier methods are called', () async {
      final container = ProviderContainer(
        overrides: [
          settingsServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      // Get the notifier via the provider's notifier
      final notifier = container
          .read(aiRecognitionSettingsProvider.notifier);

      await notifier.updateProvider(AiRecognitionProvider.minimax);

      final state = container.read(aiRecognitionSettingsProvider);
      expect(state.currentProvider, AiRecognitionProvider.minimax);
    });
  });
}
