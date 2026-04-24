import 'app_logger.dart';
import '../constants/strings.dart';

typedef ErrorCallback = void Function(Object error, StackTrace stack);

/// 错误服务 - 全局错误处理与分类
///
/// 提供统一的错误处理机制：
/// - 错误分类：根据错误关键字自动识别 20+ 种错误类型
/// - 本地化消息：将错误转换为用户友好的本地化文本
/// - 错误包装：支持同步/异步操作的自动错误捕获
/// - 处理器管理：支持注册多个错误处理回调
///
/// 错误类型涵盖：相机、位置、数据库、文件、网络、WebDAV、分享、保存、加载、删除等。
///
/// 使用单例模式，通过 [ErrorService()] 获取实例。

enum AppErrorType {
  cameraPermission,
  cameraInit,
  cameraSwitch,
  locationPermission,
  locationFetch,
  databaseRead,
  databaseWrite,
  fileDelete,
  fileExport,
  fileImport,
  networkConnect,
  webDAVConnect,
  webDAVUpload,
  webDAVDownload,
  shareFailed,
  saveFailed,
  loadFailed,
  deleteFailed,
  unknown,
}

class ErrorService {
  static final ErrorService _instance = ErrorService._();
  factory ErrorService() => _instance;
  ErrorService._();

  final List<ErrorCallback> _handlers = [];

  void registerHandler(ErrorCallback handler) {
    _handlers.add(handler);
  }

  void unregisterHandler(ErrorCallback handler) {
    _handlers.remove(handler);
  }

  void handleError(Object error, [StackTrace? stack]) {
    final trace = stack ?? StackTrace.current;
    AppLogger.e('ErrorService', 'Unhandled error: $error', error);

    for (final handler in _handlers) {
      try {
        handler(error, trace);
      } catch (e) {
        AppLogger.e('ErrorService', 'Error in error handler', e);
      }
    }
  }

  Future<T> wrap<T>(Future<T> Function() fn, {String? context}) async {
    try {
      return await fn();
    } catch (e, stack) {
      handleError(e, stack);
      if (context != null) {
        throw Exception('$context: $e');
      }
      rethrow;
    }
  }

  R run<T, R>(R Function() fn, {String? context}) {
    try {
      return fn();
    } catch (e, stack) {
      handleError(e, stack);
      if (context != null) {
        throw Exception('$context: $e');
      }
      rethrow;
    }
  }

  static String getLocalizedMessage(AppErrorType type, AppStrings strings) {
    switch (type) {
      case AppErrorType.cameraPermission:
        return strings.errorCameraPermission;
      case AppErrorType.cameraInit:
        return strings.errorCameraInit;
      case AppErrorType.cameraSwitch:
        return strings.errorCameraSwitch;
      case AppErrorType.locationPermission:
        return strings.errorLocationPermission;
      case AppErrorType.locationFetch:
        return strings.errorLocationFetch;
      case AppErrorType.databaseRead:
        return strings.errorDatabaseRead;
      case AppErrorType.databaseWrite:
        return strings.errorDatabaseWrite;
      case AppErrorType.fileDelete:
        return strings.errorFileDelete;
      case AppErrorType.fileExport:
        return strings.errorFileExport;
      case AppErrorType.fileImport:
        return strings.errorFileImport;
      case AppErrorType.networkConnect:
        return strings.errorNetworkConnect;
      case AppErrorType.webDAVConnect:
        return strings.errorWebDAVConnect;
      case AppErrorType.webDAVUpload:
        return strings.errorWebDAVUpload;
      case AppErrorType.webDAVDownload:
        return strings.errorWebDAVDownload;
      case AppErrorType.shareFailed:
        return strings.errorShareFailed;
      case AppErrorType.saveFailed:
        return strings.errorSaveFailed;
      case AppErrorType.loadFailed:
        return strings.errorLoadFailed;
      case AppErrorType.deleteFailed:
        return strings.errorDeleteFailed;
      case AppErrorType.unknown:
        return strings.errorUnknown;
    }
  }

  static AppErrorType classifyError(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('camera') && errorString.contains('permission')) {
      return AppErrorType.cameraPermission;
    }
    if (errorString.contains('camera') && errorString.contains('init')) {
      return AppErrorType.cameraInit;
    }
    if (errorString.contains('camera') && errorString.contains('switch')) {
      return AppErrorType.cameraSwitch;
    }
    if (errorString.contains('location') &&
        errorString.contains('permission')) {
      return AppErrorType.locationPermission;
    }
    if (errorString.contains('location') && errorString.contains('fetch')) {
      return AppErrorType.locationFetch;
    }
    if (errorString.contains('database') && errorString.contains('read')) {
      return AppErrorType.databaseRead;
    }
    if (errorString.contains('database') && errorString.contains('write')) {
      return AppErrorType.databaseWrite;
    }
    if (errorString.contains('file') && errorString.contains('delete')) {
      return AppErrorType.fileDelete;
    }
    if (errorString.contains('export')) {
      return AppErrorType.fileExport;
    }
    if (errorString.contains('import')) {
      return AppErrorType.fileImport;
    }
    if (errorString.contains('network') || errorString.contains('connection')) {
      return AppErrorType.networkConnect;
    }
    if (errorString.contains('webdav') && errorString.contains('connect')) {
      return AppErrorType.webDAVConnect;
    }
    if (errorString.contains('webdav') && errorString.contains('upload')) {
      return AppErrorType.webDAVUpload;
    }
    if (errorString.contains('webdav') && errorString.contains('download')) {
      return AppErrorType.webDAVDownload;
    }
    if (errorString.contains('share')) {
      return AppErrorType.shareFailed;
    }
    if (errorString.contains('save')) {
      return AppErrorType.saveFailed;
    }
    if (errorString.contains('load')) {
      return AppErrorType.loadFailed;
    }
    if (errorString.contains('delete')) {
      return AppErrorType.deleteFailed;
    }

    return AppErrorType.unknown;
  }

  static String getUserMessage(Object error, AppStrings strings) {
    final type = classifyError(error);
    return getLocalizedMessage(type, strings);
  }
}

class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => code != null ? '[$code] $message' : message;
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.originalError});
}

class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException(super.message, {this.statusCode, super.originalError});
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.originalError});
}

class CameraException extends AppException {
  const CameraException(super.message, {super.originalError});
}

class LocationException extends AppException {
  const LocationException(super.message, {super.originalError});
}

class FileException extends AppException {
  const FileException(super.message, {super.originalError});
}

/// Settings 数据损坏异常
///
/// 当用户设置文件（WatermarkSettings / AppSettings / AiRecognitionSettings）
/// 无法解析时抛出，而非静默回退到默认值导致用户偏好丢失。
class SettingsCorruptedException extends AppException {
  /// 原始的损坏数据（可用于诊断或备份）
  final String? originalValue;

  const SettingsCorruptedException(
    super.message, {
    this.originalValue,
    super.originalError,
  });
}
