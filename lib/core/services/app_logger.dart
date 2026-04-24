import 'package:flutter/foundation.dart';

/// Log levels for structured logging
enum LogLevel { debug, info, warning, error }

/// Centralized logging utility.
///
/// Replaces scattered `debugPrint` calls with a single API that:
/// - prefixes every line with level + tag for easy filtering
/// - suppresses debug-level output in release builds
/// - forwards to `debugPrint` so output stays in the Flutter console
class AppLogger {
  AppLogger._();

  static void d(String tag, String message) =>
      _log(LogLevel.debug, tag, message);

  static void i(String tag, String message) =>
      _log(LogLevel.info, tag, message);

  static void w(String tag, String message, [Object? error]) =>
      _log(LogLevel.warning, tag, message, error);

  static void e(String tag, String message, [Object? error]) =>
      _log(LogLevel.error, tag, message, error);

  static void _log(
    LogLevel level,
    String tag,
    String message, [
    Object? error,
  ]) {
    if (kReleaseMode && level == LogLevel.debug) return;
    final suffix = error != null ? '\n$error' : '';
    debugPrint('[$level][$tag] $message$suffix');
  }
}
