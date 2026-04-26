import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/database/database_provider.dart';
import 'package:lurebox/core/design/theme/app_theme.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/router/app_router.dart';
import 'package:lurebox/core/services/app_logger.dart';

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

  // 同步异常：打印日志和堆栈
  FlutterError.onError = (details) {
    AppLogger.e(
      'FlutterError',
      'Flutter Error: ${details.exceptionAsString()}',
      details.exception,
      details.stack,
    );
  };

  // 异步异常：捕获 Dart zone 中未处理的错误
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    AppLogger.e('ZoneError', 'Uncaught async error', error, stackTrace);
    return true;
  };

  // 启动时清理残留的临时水印文件（不阻塞启动）
  _cleanupLegacyTempFiles();

  try {
    await DatabaseProvider.instance.database;
  } catch (e, stackTrace) {
    AppLogger.e('Main', 'Database initialization failed', e, stackTrace);
    // 仍然启动 app，让各 feature 的 DB 操作自行处理错误，避免白屏
  }

  runApp(const ProviderScope(child: LuYuHuApp()));
}

/// 清理旧版遗留的系统临时文件（防御性清理）
Future<void> _cleanupLegacyTempFiles() async {
  try {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    final tempDir = Directory.systemTemp;
    if (!await tempDir.exists()) return;

    await for (final entity in tempDir.list()) {
      if (entity is Directory) {
        final name = entity.path.split('/').last;
        if (name.contains('watermark_')) {
          final timestampMatch = RegExp(r'watermark_(\d+)').firstMatch(name);
          if (timestampMatch != null) {
            final timestamp = int.tryParse(timestampMatch.group(1)!);
            if (timestamp != null) {
              final fileTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
              if (DateTime.now().difference(fileTime).inDays > 7) {
                await entity.delete(recursive: true);
                AppLogger.i(
                    'Main', 'Cleaned up stale watermark temp: ${entity.path}');
              }
            }
          }
        }
      }
    }
  } on Exception catch (_) {
    // 静默失败，不影响启动
  }
}

class LuYuHuApp extends ConsumerStatefulWidget {
  const LuYuHuApp({super.key});

  @override
  ConsumerState<LuYuHuApp> createState() => _LuYuHuAppState();
}

class _LuYuHuAppState extends ConsumerState<LuYuHuApp> {
  @override
  Widget build(BuildContext context) {
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
