import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_recognition_settings.dart';
import '../services/settings_service.dart';
import '../di/di.dart';

class AiRecognitionSettingsNotifier
    extends StateNotifier<AiRecognitionSettings> {
  final SettingsService _service;

  AiRecognitionSettingsNotifier(this._service)
      : super(const AiRecognitionSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _service.getAiRecognitionSettings();
      state = settings;
    } catch (_) {
      // 安全降级：使用默认设置，不阻塞应用启动
      state = const AiRecognitionSettings();
    }
  }

  Future<void> updateSettings(AiRecognitionSettings settings) async {
    await _service.saveAiRecognitionSettings(settings);
    state = settings;
  }

  Future<void> updateProvider(AiRecognitionProvider provider) async {
    final newSettings = state.copyWith(currentProvider: provider);
    await updateSettings(newSettings);
  }

  Future<void> updateApiKey(String apiKey) async {
    final currentConfig = state.providerConfigs[state.currentProvider];
    final newConfig = currentConfig?.copyWith(apiKey: apiKey) ??
        AiProviderConfig(
          provider: state.currentProvider,
          apiKey: apiKey,
        );

    final newConfigs = Map<AiRecognitionProvider, AiProviderConfig>.from(
      state.providerConfigs,
    );
    newConfigs[state.currentProvider] = newConfig;

    final newSettings = state.copyWith(providerConfigs: newConfigs);
    await updateSettings(newSettings);
  }

  Future<void> toggleAutoRecognize() async {
    final newSettings = state.copyWith(autoRecognize: !state.autoRecognize);
    await updateSettings(newSettings);
  }
}

final aiRecognitionSettingsProvider =
    StateNotifierProvider<AiRecognitionSettingsNotifier, AiRecognitionSettings>(
  (ref) => AiRecognitionSettingsNotifier(ref.read(settingsServiceProvider)),
);
