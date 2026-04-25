import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';

/// 语言 provider
final appLanguageProvider = Provider<AppLanguage>((ref) {
  return ref.watch(appSettingsProvider).language;
});

/// 当前语言字符串 provider
final currentStringsProvider = Provider<AppStrings>((ref) {
  final language = ref.watch(appLanguageProvider);
  switch (language) {
    case AppLanguage.chinese:
      return AppStrings.chinese;
    case AppLanguage.english:
      return AppStrings.english;
  }
});
