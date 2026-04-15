import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/watermark_settings.dart';
import '../services/settings_service.dart';
import '../di/di.dart';

class WatermarkSettingsNotifier extends StateNotifier<WatermarkSettings> {
  final SettingsService _service;

  WatermarkSettingsNotifier(this._service) : super(const WatermarkSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _service.getWatermarkSettings();
    state = settings;
  }

  Future<void> updateSettings(WatermarkSettings settings) async {
    state = settings;
    await _service.saveWatermarkSettings(settings);
  }

  Future<void> updateEnabled(bool enabled) async {
    final newSettings = state.copyWith(enabled: enabled);
    await updateSettings(newSettings);
  }

  Future<void> updateStyle(WatermarkStyle style) async {
    final preset = watermarkStylePresets[style]!;
    final newSettings = state.copyWith(
      style: style,
      blurRadius: preset.blurRadius,
      backgroundOpacity: preset.backgroundOpacity,
      backgroundColor: preset.backgroundColor,
      fontSize: preset.fontSize,
      textColor: preset.textColor,
      position: preset.position,
    );
    await updateSettings(newSettings);
  }

  Future<void> toggleInfoType(WatermarkInfoType type) async {
    final List<WatermarkInfoType> newTypes = List.from(state.infoTypes);
    if (newTypes.contains(type)) {
      if (type != WatermarkInfoType.appName) {
        newTypes.remove(type);
      }
    } else {
      newTypes.add(type);
    }
    final newSettings = state.copyWith(infoTypes: newTypes);
    await updateSettings(newSettings);
  }

  Future<void> reorderInfoTypes(int oldIndex, int newIndex) async {
    final List<WatermarkInfoType> newTypes = List.from(state.infoTypes);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = newTypes.removeAt(oldIndex);
    newTypes.insert(newIndex, item);
    final newSettings = state.copyWith(infoTypes: newTypes);
    await updateSettings(newSettings);
  }

  Future<void> updateBlurRadius(double blurRadius) async {
    final newSettings = state.copyWith(blurRadius: blurRadius);
    await updateSettings(newSettings);
  }

  Future<void> updateBackgroundColor(int backgroundColor) async {
    final newSettings = state.copyWith(backgroundColor: backgroundColor);
    await updateSettings(newSettings);
  }

  Future<void> updateBackgroundOpacity(double backgroundOpacity) async {
    final newSettings = state.copyWith(backgroundOpacity: backgroundOpacity);
    await updateSettings(newSettings);
  }

  Future<void> updateFontSize(double fontSize) async {
    final newSettings = state.copyWith(fontSize: fontSize);
    await updateSettings(newSettings);
  }

  Future<void> updateTextColor(int textColor) async {
    final newSettings = state.copyWith(textColor: textColor);
    await updateSettings(newSettings);
  }

  Future<void> updatePosition(WatermarkPosition position) async {
    final newSettings = state.copyWith(position: position);
    await updateSettings(newSettings);
  }

  Future<void> updateCustomText(String? customText) async {
    final newSettings = state.copyWith(customText: customText);
    await updateSettings(newSettings);
  }
}

final watermarkSettingsProvider =
    StateNotifierProvider<WatermarkSettingsNotifier, WatermarkSettings>(
  (ref) => WatermarkSettingsNotifier(ref.read(settingsServiceProvider)),
);
