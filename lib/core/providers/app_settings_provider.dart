import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';
import '../di/di.dart';

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsService _service;

  AppSettingsNotifier(this._service) : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _service.getAppSettings();
    state = settings;
  }

  Future<void> updateSettings(AppSettings settings) async {
    state = settings;
    await _service.saveAppSettings(settings);
  }

  Future<void> updateUnits(UnitSettings units) async {
    final newSettings = state.copyWith(units: units);
    await updateSettings(newSettings);
  }

  Future<void> updateDarkMode(DarkMode mode) async {
    final newSettings = state.copyWith(darkMode: mode);
    await updateSettings(newSettings);
  }

  Future<void> updateLanguage(AppLanguage language) async {
    final newSettings = state.copyWith(language: language);
    await updateSettings(newSettings);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier(ref.read(settingsServiceProvider)),
);

final flutterThemeModeProvider = Provider<ThemeMode>((ref) {
  final darkMode = ref.watch(appSettingsProvider).darkMode;
  switch (darkMode) {
    case DarkMode.light:
      return ThemeMode.light;
    case DarkMode.dark:
      return ThemeMode.dark;
    case DarkMode.system:
      return ThemeMode.system;
  }
});
