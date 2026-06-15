import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/database/database_provider.dart';
import 'package:lurebox/core/design/theme/app_theme.dart';
import 'package:lurebox/core/di/di.dart';
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

  // 在首帧前加载应用设置：onboardingCompletedProvider 派生自 appSettings，
  // 若不等待，路由会先按默认值（未完成 onboarding）落到 /onboarding 再重定向，
  // 造成返回用户看到 onboarding 闪屏。用同一 container 接到 UncontrolledProviderScope。
  final container = ProviderContainer();
  try {
    await container.read(appSettingsProvider.notifier).loaded;
  } catch (e, stackTrace) {
    // loaded 内部已吞异常回退默认值；此处再保险，避免阻断启动
    AppLogger.e('Main', 'App settings load failed', e, stackTrace);
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const LuYuHuApp(),
    ),
  );
}

/// 清理旧版遗留的系统临时文件（防御性清理）
///
/// 水印导出经由 Directory.systemTemp.createTemp('watermark') 创建临时目录，
/// 实际目录名形如 'watermarkAbc123'（无下划线、无时间戳）。此前用
/// 'watermark_' 前缀 + 时间戳正则匹配，永远命中不了真实目录，导致全分辨率
/// PNG 持续堆积。改为匹配 'watermark' 前缀，并按目录文件系统修改时间
/// （超过 N 天）判定是否删除，因为目录名中并无时间戳可解析。
Future<void> _cleanupLegacyTempFiles() async {
  const staleThresholdDays = 7;
  try {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    final tempDir = Directory.systemTemp;
    if (!await tempDir.exists()) return;

    final now = DateTime.now();
    await for (final entity in tempDir.list()) {
      if (entity is! Directory) continue;
      final name = entity.path.split('/').last;
      if (!name.startsWith('watermark')) continue;
      try {
        final stat = await entity.stat();
        if (now.difference(stat.modified).inDays > staleThresholdDays) {
          await entity.delete(recursive: true);
          AppLogger.i(
            'Main',
            'Cleaned up stale watermark temp: ${entity.path}',
          );
        }
      } on Exception catch (_) {
        // 单个目录处理失败不影响其余清理。
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
  void initState() {
    super.initState();
    // 启动期一次性迁移：明文 WebDAV 密码 / AI apiKey → 安全存储。
    // run() 内部吞掉所有异常，只记日志，不会阻断启动。
    unawaited(ref.read(startupMigrationServiceProvider).run());
  }

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
