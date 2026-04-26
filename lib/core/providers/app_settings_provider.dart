import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/services/app_logger.dart';
import 'package:lurebox/core/services/error_service.dart';
import 'package:lurebox/core/services/settings_service.dart';

class AppSettingsNotifier extends StateNotifier<AppSettings> {

  AppSettingsNotifier(this._service) : super(const AppSettings()) {
    _loadSettings();
  }
  final SettingsService _service;

  Future<void> _loadSettings() async {
    try {
      final settings = await _service.getAppSettings();
      if (!mounted) return;
      state = settings;
    } on SettingsCorruptedException catch (e) {
      // 记录损坏状态但不崩溃：让应用以默认值启动
      AppLogger.w('AppSettingsNotifier', 'Settings corrupted, using defaults: $e');
    } on Exception catch (e) {
      AppLogger.e('AppSettingsNotifier', 'Unexpected error loading settings: $e');
    }
  }

  Future<void> updateSettings(AppSettings settings) async {
    try {
      await _service.saveAppSettings(settings);
      state = settings;
    } catch (e) {
      rethrow;
    }
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
