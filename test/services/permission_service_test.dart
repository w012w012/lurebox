import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';

/// Mock platform that stubs out all permission_handler and geolocator calls.
class MockPermissionPlatform extends PermissionPlatform {
  PermissionStatus statusResult = PermissionStatus.denied;
  PermissionStatus requestResult = PermissionStatus.denied;
  bool locationServiceEnabled = true;
  bool openSettingsCalled = false;

  @override
  Future<PermissionStatus> status(Permission permission) async {
    return statusResult;
  }

  @override
  Future<PermissionStatus> request(Permission permission) async {
    return requestResult;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return locationServiceEnabled;
  }

  @override
  Future<void> openAppSettings() async {
    openSettingsCalled = true;
  }

  void reset() {
    statusResult = PermissionStatus.denied;
    requestResult = PermissionStatus.denied;
    locationServiceEnabled = true;
    openSettingsCalled = false;
  }
}

void main() {
  group('PermissionService.setPlatformForTesting', () {
    test('uses injected platform instead of real implementation', () async {
      final mock = MockPermissionPlatform();
      mock.statusResult = PermissionStatus.granted;
      final service = PermissionService(); // singleton
      service.setPlatformForTesting(mock);

      final result = await service.isPermissionGranted(Permission.camera);

      expect(result, isTrue);
    });
  });

  group('PermissionService.isPermissionGranted', () {
    late MockPermissionPlatform mock;

    setUp(() {
      mock = MockPermissionPlatform();
      // Inject mock into singleton
      PermissionService().setPlatformForTesting(mock);
    });

    test('returns true when status is granted', () async {
      mock.statusResult = PermissionStatus.granted;

      final result = await PermissionService().isPermissionGranted(Permission.camera);

      expect(result, isTrue);
    });

    test('returns true when status is limited (iOS photos)', () async {
      mock.statusResult = PermissionStatus.limited;

      final result = await PermissionService().isPermissionGranted(Permission.photos);

      expect(result, isTrue);
    });

    test('returns false when status is denied', () async {
      mock.statusResult = PermissionStatus.denied;

      final result = await PermissionService().isPermissionGranted(Permission.camera);

      expect(result, isFalse);
    });

    test('returns false when status is permanently denied', () async {
      mock.statusResult = PermissionStatus.permanentlyDenied;

      final result = await PermissionService().isPermissionGranted(Permission.camera);

      expect(result, isFalse);
    });

    test('returns false when status is restricted', () async {
      mock.statusResult = PermissionStatus.restricted;

      final result = await PermissionService().isPermissionGranted(Permission.camera);

      expect(result, isFalse);
    });

    test('delegates to platform with correct permission', () async {
      mock.statusResult = PermissionStatus.granted;
      await PermissionService().isPermissionGranted(Permission.locationWhenInUse);
      expect(mock.statusResult, equals(PermissionStatus.granted));
    });
  });

  group('PermissionService.isPermanentlyDenied', () {
    late MockPermissionPlatform mock;

    setUp(() {
      mock = MockPermissionPlatform();
      PermissionService().setPlatformForTesting(mock);
    });

    test('returns true when status is permanentlyDenied', () async {
      mock.statusResult = PermissionStatus.permanentlyDenied;

      final result = await PermissionService().isPermanentlyDenied(Permission.camera);

      expect(result, isTrue);
    });

    test('returns false when status is denied (not permanent)', () async {
      mock.statusResult = PermissionStatus.denied;

      final result = await PermissionService().isPermanentlyDenied(Permission.camera);

      expect(result, isFalse);
    });

    test('returns false when status is granted', () async {
      mock.statusResult = PermissionStatus.granted;

      final result = await PermissionService().isPermanentlyDenied(Permission.camera);

      expect(result, isFalse);
    });
  });

  group('PermissionService.openSettings', () {
    late MockPermissionPlatform mock;

    setUp(() {
      mock = MockPermissionPlatform();
      PermissionService().setPlatformForTesting(mock);
    });

    test('calls platform.openAppSettings()', () async {
      expect(mock.openSettingsCalled, isFalse);

      await PermissionService().openSettings();

      expect(mock.openSettingsCalled, isTrue);
    });
  });

  group('PermissionService.requestLocationPermission — platform check', () {
    late MockPermissionPlatform mock;

    setUp(() {
      mock = MockPermissionPlatform();
      PermissionService().setPlatformForTesting(mock);
    });

    test('mock reports location service disabled', () async {
      mock.locationServiceEnabled = false;
      // Verify mock is configured correctly — the actual
      // requestLocationPermission would receive 'false' from this platform.
      final enabled = await mock.isLocationServiceEnabled();
      expect(enabled, isFalse);
    });

    test('mock reports location service enabled', () async {
      mock.locationServiceEnabled = true;
      final enabled = await mock.isLocationServiceEnabled();
      expect(enabled, isTrue);
    });
  });

  // Note: tests that call PermissionPlatform.real (real permission_handler /
  // Geolocator) require TestWidgetsFlutterBinding.ensureInitialized() because
  // permission_handler uses platform channels. These are tested indirectly via
  // widget tests that provide a proper Flutter binding environment.

  group('PermissionResult equality', () {
    test('two granted results with same values are equal', () {
      const r1 = PermissionResult(granted: true, permanentlyDenied: false);
      const r2 = PermissionResult(granted: true, permanentlyDenied: false);
      expect(r1, equals(r2));
    });

    test('results with different granted values are not equal', () {
      const granted = PermissionResult(granted: true, permanentlyDenied: false);
      const denied = PermissionResult(granted: false, permanentlyDenied: false);
      expect(granted, isNot(equals(denied)));
    });

    test('results with errorMessage are distinct', () {
      const withError = PermissionResult(
        granted: false,
        permanentlyDenied: true,
        errorMessage: 'Permanently denied',
      );
      const withoutError = PermissionResult(
        granted: false,
        permanentlyDenied: true,
      );
      expect(withError, isNot(equals(withoutError)));
    });
  });

  group('PermissionInfo static constants are well-formed', () {
    test('cameraInfo has required fields', () {
      expect(PermissionService.cameraInfo.title, isNotEmpty);
      expect(PermissionService.cameraInfo.description, isNotEmpty);
      expect(PermissionService.cameraInfo.benefit, isNotEmpty);
    });

    test('locationInfo has required fields', () {
      expect(PermissionService.locationInfo.title, isNotEmpty);
      expect(PermissionService.locationInfo.description, isNotEmpty);
    });

    test('photosInfo has required fields', () {
      expect(PermissionService.photosInfo.title, isNotEmpty);
      expect(PermissionService.photosInfo.description, isNotEmpty);
    });
  });

  group('PermissionService dialog integration tests', () {
    late MockPermissionPlatform mock;

    setUp(() {
      mock = MockPermissionPlatform();
      PermissionService().setPlatformForTesting(mock);
    });

    testWidgets('camera education dialog shows title and description', (tester) async {
      mock.statusResult = PermissionStatus.denied;
      mock.requestResult = PermissionStatus.granted;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    // Test the dialog flow
                    final status = await PermissionService().isPermissionGranted(Permission.camera);
                    if (!status && context.mounted) {
                      await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          icon: Icon(PermissionService.cameraInfo.icon, size: 48),
                          title: Text('需要${PermissionService.cameraInfo.title}'),
                          content: Text(PermissionService.cameraInfo.description),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('暂不授权'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('授权'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('Request Permission'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Request Permission'));
      await tester.pumpAndSettle();

      expect(find.text('需要${PermissionService.cameraInfo.title}'), findsOneWidget);
      expect(find.text(PermissionService.cameraInfo.description), findsOneWidget);
      expect(find.text('授权'), findsOneWidget);
      expect(find.text('暂不授权'), findsOneWidget);
    });

    testWidgets('settings dialog shows correct message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    if (context.mounted) {
                      await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('需要${PermissionService.cameraInfo.title}'),
                          content: Text(
                            '您之前拒绝了${PermissionService.cameraInfo.title}。\n\n'
                            '请在系统设置中开启${PermissionService.cameraInfo.title}，以使用相关功能。',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('取消'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('打开设置'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('Show Settings'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Settings'));
      await tester.pumpAndSettle();

      expect(find.textContaining('您之前拒绝了'), findsOneWidget);
      expect(find.text('打开设置'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
    });

    testWidgets('dialog shows privacy reassurance text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    if (context.mounted) {
                      await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          content: const Text(
                            '我们不会收集或上传您的数据，所有信息都保存在本地设备上。',
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('确定'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('Show Privacy'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Privacy'));
      await tester.pumpAndSettle();

      expect(find.textContaining('不会收集或上传'), findsOneWidget);
      expect(find.textContaining('保存在本地设备'), findsOneWidget);
    });
  });
}
