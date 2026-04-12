import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/services/error_service.dart';
import 'package:lurebox/core/constants/strings.dart';

void main() {
  group('ErrorService', () {
    late ErrorService errorService;
    var originalOnError = FlutterError.onError;

    setUp(() {
      errorService = ErrorService();
      // 临时抑制 FlutterError.onError 以避免测试期间的 debugPrint 输出被报告为错误
      FlutterError.onError = (FlutterErrorDetails details) {
        // 抑制所有错误输出
      };
    });

    tearDown(() {
      // 恢复原始的 FlutterError.onError
      FlutterError.onError = originalOnError;
    });

    group('singleton', () {
      test('returns same instance', () {
        final instance1 = ErrorService();
        final instance2 = ErrorService();
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('handler management', () {
      test('registers and unregisters handlers via behavior', () {
        var handlerCallCount = 0;
        void handler(Object error, StackTrace stack) {
          handlerCallCount++;
        }

        errorService.registerHandler(handler);
        errorService.handleError(Exception('test'), StackTrace.current);
        expect(handlerCallCount, equals(1));

        errorService.unregisterHandler(handler);
        errorService.handleError(Exception('test2'), StackTrace.current);
        expect(
            handlerCallCount, equals(1)); // Still 1, handler was unregistered
      });

      test('handles error with no handlers gracefully', () {
        // Should not throw
        errorService.handleError(Exception('test'), StackTrace.current);
      });

      test('calls all registered handlers', () {
        var callCount1 = 0;
        var callCount2 = 0;

        void handler1(Object error, StackTrace stack) {
          callCount1++;
        }

        void handler2(Object error, StackTrace stack) {
          callCount2++;
        }

        errorService.registerHandler(handler1);
        errorService.registerHandler(handler2);

        errorService.handleError(Exception('test'), StackTrace.current);

        expect(callCount1, equals(1));
        expect(callCount2, equals(1));
      });

      test('handles handler exception gracefully', () {
        var safeHandlerCallCount = 0;

        void throwingHandler(Object error, StackTrace stack) {
          throw Exception('Handler error');
        }

        void safeHandler(Object error, StackTrace stack) {
          safeHandlerCallCount++;
        }

        errorService.registerHandler(throwingHandler);
        errorService.registerHandler(safeHandler);

        // Should not throw, should continue calling other handlers
        errorService.handleError(Exception('test'), StackTrace.current);

        expect(safeHandlerCallCount, equals(1));
      });
    });

    group('wrap', () {
      test('returns result from successful function', () async {
        final result = await errorService.wrap(() async => 42);
        expect(result, equals(42));
      });

      test('rethrows exception from failed function', () async {
        await runZonedGuarded(() async {
          expect(
            () => errorService.wrap(() async {
              throw Exception('Test error');
            }),
            throwsException,
          );
        }, (e, s) {
          // 抑制测试期间的预期错误输出
        });
      });

      test('includes context in exception message', () async {
        try {
          await errorService.wrap(
            () async => throw Exception('Original'),
            context: 'TestContext',
          );
        } catch (e) {
          expect(e.toString(), contains('TestContext'));
          expect(e.toString(), contains('Original'));
        }
      });

      test('wraps and handles async errors', () async {
        var handled = false;

        void handler(Object error, StackTrace stack) {
          handled = true;
        }

        errorService.registerHandler(handler);

        try {
          await errorService.wrap(() async {
            throw Exception('Async error');
          });
        } catch (_) {}

        expect(handled, isTrue);
      });
    });

    group('run (sync)', () {
      test('returns result from successful function', () {
        final result = errorService.run(() => 42);
        expect(result, equals(42));
      });

      test('rethrows exception from failed function', () {
        runZonedGuarded(() {
          expect(
            () => errorService.run(() {
              throw Exception('Sync error');
            }),
            throwsException,
          );
        }, (e, s) {
          // 抑制测试期间的预期错误输出
        });
      });

      test('includes context in exception message', () {
        try {
          errorService.run(
            () => throw Exception('Original'),
            context: 'SyncContext',
          );
        } catch (e) {
          expect(e.toString(), contains('SyncContext'));
        }
      });
    });

    group('classifyError', () {
      test('classifies camera permission errors', () {
        expect(
          ErrorService.classifyError(Exception('camera permission denied')),
          equals(AppErrorType.cameraPermission),
        );
        expect(
          ErrorService.classifyError(Exception('CAMERA permission error')),
          equals(AppErrorType.cameraPermission),
        );
      });

      test('classifies camera init errors', () {
        expect(
          ErrorService.classifyError(Exception('camera init failed')),
          equals(AppErrorType.cameraInit),
        );
      });

      test('classifies camera switch errors', () {
        expect(
          ErrorService.classifyError(Exception('camera switch error')),
          equals(AppErrorType.cameraSwitch),
        );
      });

      test('classifies location permission errors', () {
        expect(
          ErrorService.classifyError(Exception('location permission denied')),
          equals(AppErrorType.locationPermission),
        );
      });

      test('classifies location fetch errors', () {
        expect(
          ErrorService.classifyError(Exception('location fetch failed')),
          equals(AppErrorType.locationFetch),
        );
      });

      test('classifies database read errors', () {
        expect(
          ErrorService.classifyError(Exception('database read error')),
          equals(AppErrorType.databaseRead),
        );
      });

      test('classifies database write errors', () {
        expect(
          ErrorService.classifyError(Exception('database write error')),
          equals(AppErrorType.databaseWrite),
        );
      });

      test('classifies file delete errors', () {
        expect(
          ErrorService.classifyError(Exception('file delete failed')),
          equals(AppErrorType.fileDelete),
        );
      });

      test('classifies export errors', () {
        expect(
          ErrorService.classifyError(Exception('export failed')),
          equals(AppErrorType.fileExport),
        );
        expect(
          ErrorService.classifyError(Exception('cannot export')),
          equals(AppErrorType.fileExport),
        );
      });

      test('classifies import errors', () {
        expect(
          ErrorService.classifyError(Exception('import failed')),
          equals(AppErrorType.fileImport),
        );
        expect(
          ErrorService.classifyError(Exception('cannot import')),
          equals(AppErrorType.fileImport),
        );
      });

      test('classifies network errors', () {
        expect(
          ErrorService.classifyError(Exception('network error')),
          equals(AppErrorType.networkConnect),
        );
        expect(
          ErrorService.classifyError(Exception('connection timeout')),
          equals(AppErrorType.networkConnect),
        );
      });

      test('classifies webdav connect errors', () {
        expect(
          ErrorService.classifyError(Exception('webdav connect failed')),
          equals(AppErrorType.webDAVConnect),
        );
      });

      test('classifies webdav upload errors', () {
        expect(
          ErrorService.classifyError(Exception('webdav upload failed')),
          equals(AppErrorType.webDAVUpload),
        );
      });

      test('classifies webdav download errors', () {
        expect(
          ErrorService.classifyError(Exception('webdav download failed')),
          equals(AppErrorType.webDAVDownload),
        );
      });

      test('classifies share errors', () {
        expect(
          ErrorService.classifyError(Exception('share failed')),
          equals(AppErrorType.shareFailed),
        );
      });

      test('classifies save errors', () {
        expect(
          ErrorService.classifyError(Exception('save operation failed')),
          equals(AppErrorType.saveFailed),
        );
      });

      test('classifies load errors', () {
        expect(
          ErrorService.classifyError(Exception('load operation failed')),
          equals(AppErrorType.loadFailed),
        );
      });

      test('classifies delete errors', () {
        expect(
          ErrorService.classifyError(Exception('delete operation failed')),
          equals(AppErrorType.deleteFailed),
        );
      });

      test('returns unknown for unrecognized errors', () {
        expect(
          ErrorService.classifyError(Exception('some random error')),
          equals(AppErrorType.unknown),
        );
      });

      test('handles case insensitivity', () {
        expect(
          ErrorService.classifyError(Exception('NETWORK ERROR')),
          equals(AppErrorType.networkConnect),
        );
        expect(
          ErrorService.classifyError(Exception('Database Write Error')),
          equals(AppErrorType.databaseWrite),
        );
      });
    });

    group('getLocalizedMessage', () {
      final strings = AppStrings.chinese;

      test('returns correct message for each error type', () {
        expect(
          ErrorService.getLocalizedMessage(
              AppErrorType.cameraPermission, strings),
          equals(strings.errorCameraPermission),
        );
        expect(
          ErrorService.getLocalizedMessage(AppErrorType.cameraInit, strings),
          equals(strings.errorCameraInit),
        );
        expect(
          ErrorService.getLocalizedMessage(AppErrorType.cameraSwitch, strings),
          equals(strings.errorCameraSwitch),
        );
        expect(
          ErrorService.getLocalizedMessage(
              AppErrorType.locationPermission, strings),
          equals(strings.errorLocationPermission),
        );
        expect(
          ErrorService.getLocalizedMessage(AppErrorType.locationFetch, strings),
          equals(strings.errorLocationFetch),
        );
        expect(
          ErrorService.getLocalizedMessage(AppErrorType.databaseRead, strings),
          equals(strings.errorDatabaseRead),
        );
        expect(
          ErrorService.getLocalizedMessage(AppErrorType.databaseWrite, strings),
          equals(strings.errorDatabaseWrite),
        );
        expect(
          ErrorService.getLocalizedMessage(AppErrorType.fileDelete, strings),
          equals(strings.errorFileDelete),
        );
        expect(
          ErrorService.getLocalizedMessage(AppErrorType.fileExport, strings),
          equals(strings.errorFileExport),
        );
        expect(
          ErrorService.getLocalizedMessage(AppErrorType.fileImport, strings),
          equals(strings.errorFileImport),
        );
        expect(
          ErrorService.getLocalizedMessage(
              AppErrorType.networkConnect, strings),
          equals(strings.errorNetworkConnect),
        );
        expect(
          ErrorService.getLocalizedMessage(AppErrorType.webDAVConnect, strings),
          equals(strings.errorWebDAVConnect),
        );
        expect(
          ErrorService.getLocalizedMessage(AppErrorType.webDAVUpload, strings),
          equals(strings.errorWebDAVUpload),
        );
        expect(
          ErrorService.getLocalizedMessage(
              AppErrorType.webDAVDownload, strings),
          equals(strings.errorWebDAVDownload),
        );
        expect(
          ErrorService.getLocalizedMessage(AppErrorType.shareFailed, strings),
          equals(strings.errorShareFailed),
        );
        expect(
          ErrorService.getLocalizedMessage(AppErrorType.saveFailed, strings),
          equals(strings.errorSaveFailed),
        );
        expect(
          ErrorService.getLocalizedMessage(AppErrorType.loadFailed, strings),
          equals(strings.errorLoadFailed),
        );
        expect(
          ErrorService.getLocalizedMessage(AppErrorType.deleteFailed, strings),
          equals(strings.errorDeleteFailed),
        );
        expect(
          ErrorService.getLocalizedMessage(AppErrorType.unknown, strings),
          equals(strings.errorUnknown),
        );
      });
    });

    group('getUserMessage', () {
      final strings = AppStrings.chinese;

      test('classifies error and returns localized message', () {
        final message = ErrorService.getUserMessage(
          Exception('network error'),
          strings,
        );
        expect(message, equals(strings.errorNetworkConnect));
      });

      test('returns unknown message for unrecognized errors', () {
        final message = ErrorService.getUserMessage(
          Exception('totally unknown error'),
          strings,
        );
        expect(message, equals(strings.errorUnknown));
      });
    });
  });

  group('AppException', () {
    test('creates exception with message', () {
      const exception = AppException('Test error');
      expect(exception.message, equals('Test error'));
      expect(exception.code, isNull);
      expect(exception.originalError, isNull);
    });

    test('creates exception with code', () {
      const exception = AppException('Test error', code: 'ERR001');
      expect(exception.message, equals('Test error'));
      expect(exception.code, equals('ERR001'));
    });

    test('creates exception with original error', () {
      final original = Exception('Original');
      final exception = AppException('Wrapped', originalError: original);
      expect(exception.originalError, equals(original));
    });

    test('toString includes code when present', () {
      const exception = AppException('Test error', code: 'ERR001');
      expect(exception.toString(), equals('[ERR001] Test error'));
    });

    test('toString excludes code when absent', () {
      const exception = AppException('Test error');
      expect(exception.toString(), equals('Test error'));
    });
  });

  group('DatabaseException', () {
    test('creates with message and original error', () {
      final original = Exception('DB error');
      final exception =
          DatabaseException('Database failed', originalError: original);
      expect(exception.message, equals('Database failed'));
      expect(exception.originalError, equals(original));
    });
  });

  group('NetworkException', () {
    test('creates with message and status code', () {
      const exception = NetworkException('Network failed', statusCode: 404);
      expect(exception.message, equals('Network failed'));
      expect(exception.statusCode, equals(404));
    });

    test('creates with message, status code, and original error', () {
      final original = Exception('Original');
      final exception = NetworkException(
        'Network failed',
        statusCode: 500,
        originalError: original,
      );
      expect(exception.statusCode, equals(500));
      expect(exception.originalError, equals(original));
    });
  });

  group('ValidationException', () {
    test('creates with message', () {
      const exception = ValidationException('Invalid input');
      expect(exception.message, equals('Invalid input'));
    });
  });

  group('CameraException', () {
    test('creates with message', () {
      const exception = CameraException('Camera unavailable');
      expect(exception.message, equals('Camera unavailable'));
    });
  });

  group('LocationException', () {
    test('creates with message', () {
      const exception = LocationException('Location unavailable');
      expect(exception.message, equals('Location unavailable'));
    });
  });

  group('FileException', () {
    test('creates with message', () {
      const exception = FileException('File not found');
      expect(exception.message, equals('File not found'));
    });
  });
}
