import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/design/theme/app_theme.dart';
import 'core/models/app_settings.dart';
import 'core/providers/app_settings_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/database/database_provider.dart';
import 'core/router/app_router.dart';

/// LureBox (路亚鱼护) 应用入口
///
/// 这是一个 Flutter 移动应用，用于记录钓鱼爱好者的渔获数据。
/// 应用采用 Riverpod 进行状态管理，支持：
/// - 渔获记录（拍照、尺寸、位置、装备）
/// - 装备管理（鱼竿、鱼轮、鱼饵）
/// - 统计分析（物种分布、趋势、装备使用）
/// - 成就系统
/// - 数据导出与分享
///
/// 主要功能入口：
/// - 首页：展示统计概览和个人最佳渔获
/// - 渔获列表：管理所有渔获记录
/// - 装备管理：管理钓具装备
/// - 成就：展示成就进度
/// - 设置：应用配置

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    debugPrint('Flutter Error: ${details.exceptionAsString()}');
  };

  await DatabaseProvider.instance.database;

  runApp(const ProviderScope(child: LuYuHuApp()));
}

class LuYuHuApp extends ConsumerWidget {
  const LuYuHuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(flutterThemeModeProvider);
    final strings = ref.watch(currentStringsProvider);
    final language = ref.watch(appLanguageProvider);

    // 根据当前语言设置 locale
    final Locale locale;
    switch (language) {
      case AppLanguage.chinese:
        locale = const Locale('zh', 'CN');
      case AppLanguage.english:
        locale = const Locale('en', 'US');
    }

    return MaterialApp.router(
      title: strings.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: locale,
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(routerProvider),
    );
  }
}
