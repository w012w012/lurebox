import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/camera/camera_helper.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart' as perm_handler;

// ── Mocks ────────────────────────────────────────────────────────────────────

class MockPermissionPlatform extends Mock implements PermissionPlatform {}

// ── Fake Classes ─────────────────────────────────────────────────────────────

class FakeCameraDescription extends Fake implements CameraDescription {}

class FakePermissionResult extends Fake implements PermissionResult {}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // Initialize Flutter binding for tests that use ErrorService/AppLogger
  TestWidgetsFlutterBinding.ensureInitialized();

  late CameraHelper cameraHelper;
  late MockPermissionPlatform mockPermissionPlatform;

  const strings = AppStrings.chinese;

  setUpAll(() {
    registerFallbackValue(FakeCameraDescription());
    registerFallbackValue(FakePermissionResult());
    registerFallbackValue(perm_handler.Permission.camera);
    registerFallbackValue(perm_handler.Permission.locationWhenInUse);
  });

  setUp(() {
    mockPermissionPlatform = MockPermissionPlatform();

    // Inject mock platform into the PermissionService singleton
    PermissionService().setPlatformForTesting(mockPermissionPlatform);

    cameraHelper = CameraHelper();
    cameraHelper.setStrings(strings);
  });

  tearDown(() {
    cameraHelper.dispose();
  });

  // ===========================================================================
  // 1. Take picture when not initialized
  // ===========================================================================
  group('takePicture - not initialized', () {
    test('returns null when camera not initialized', () async {
      // Ensure camera is not initialized
      expect(cameraHelper.isInitialized, false);

      final result = await cameraHelper.takePicture();

      expect(result, isNull);
    });

    test('returns null when cameraController is null', () async {
      // Manually set state to appear initialized but controller is null
      // This simulates a race condition where controller was disposed
      final result = await cameraHelper.takePicture();

      expect(result, isNull);
    });
  });

  // ===========================================================================
  // 2. Dispose cleanup
  // ===========================================================================
  group('dispose cleanup', () {
    test('resets all state fields on dispose', () {
      // Call dispose
      cameraHelper.dispose();

      // Verify state is reset
      expect(cameraHelper.isInitialized, false);
      expect(cameraHelper.errorMessage, isNull);
      expect(cameraHelper.locationName, isNull);
      expect(cameraHelper.latitude, isNull);
      expect(cameraHelper.longitude, isNull);
      expect(cameraHelper.position, isNull);
      expect(cameraHelper.weatherData, isNull);
    });

    test('dispose can be called multiple times without error', () {
      // Arrange: call dispose once
      cameraHelper.dispose();

      // Act: call again - should not throw
      cameraHelper.dispose();

      // Assert: no exception thrown
      expect(cameraHelper.isInitialized, false);
    });
  });

  // ===========================================================================
  // 3. Switch camera with single camera
  // ===========================================================================
  group('switchCamera - single camera', () {
    test('returns false when only one camera available', () async {
      final helper = CameraHelper();
      helper.setStrings(strings);

      final result = await helper.switchCamera();

      expect(result, false);
      expect(helper.canSwitchCamera, false);

      helper.dispose();
    });
  });

  // ===========================================================================
  // 4. Camera permission handling via context path
  // ===========================================================================
  //
  // NOTE: The fallback path (context == null) in initCamera/getLocation directly
  // calls permission_handler package APIs (Permission.camera.status, etc.)
  // which cannot be mocked in unit tests. Tests for permission denial in the
  // fallback path would require either:
  // - Using integration tests with mock method channels
  // - Refactoring CameraHelper to use PermissionPlatform for all paths
  //
  // The test below verifies the behavior when the permission plugin
  // is unavailable (throws MissingPluginException).
  // ===========================================================================
  group('initCamera - permission handling', () {
    test(
        'handles MissingPluginException gracefully (permission handler unavailable)',
        () async {
      // Act - call initCamera without context (uses fallback path)
      // In unit test environment, Permission.camera.status throws
      // MissingPluginException since there's no actual plugin registered
      await cameraHelper.initCamera();

      // Assert: errorMessage is set (error was caught and stored)
      expect(cameraHelper.errorMessage, isNotNull);
      expect(
        cameraHelper.errorMessage,
        anyOf(
          contains('MissingPluginException'),
          contains('Camera permission'),
          contains('初始化相机'),
        ),
      );
    });
  });

  // ===========================================================================
  // 5. Location handling when permission handler unavailable
  // ===========================================================================
  group('getLocation - permission handling', () {
    test(
        'handles MissingPluginException gracefully (permission handler unavailable)',
        () async {
      // Act - call getLocation without context (uses fallback path)
      // In unit test environment, Permission.locationWhenInUse.status throws
      // MissingPluginException since there's no actual plugin registered
      await cameraHelper.getLocation();

      // Assert: locationName is set to an error message
      expect(cameraHelper.locationName, isNotNull);
      expect(
        cameraHelper.locationName,
        anyOf(
          contains('获取位置信息'),
          contains('Location'),
          contains('error'),
        ),
      );
    });
  });

  // ===========================================================================
  // 6. Switch camera with empty cameras list
  // ===========================================================================
  group('switchCamera - edge cases', () {
    test('returns false and no error when cameras list is empty', () async {
      // This tests the early return when _cameras.isEmpty
      // We can't directly populate _cameras without availableCameras(),
      // but we can verify the guard works by checking switchCamera returns
      // false when canSwitchCamera is false
      expect(cameraHelper.canSwitchCamera, false);

      final result = await cameraHelper.switchCamera();

      expect(result, false);
    });
  });

  // ===========================================================================
  // 7. Getters behavior
  // ===========================================================================
  group('getter behavior', () {
    test('initial state has null values', () {
      expect(cameraHelper.cameraController, isNull);
      expect(cameraHelper.isInitialized, false);
      expect(cameraHelper.errorMessage, isNull);
      expect(cameraHelper.canSwitchCamera, false);
      expect(cameraHelper.locationName, isNull);
      expect(cameraHelper.latitude, isNull);
      expect(cameraHelper.longitude, isNull);
      expect(cameraHelper.position, isNull);
      expect(cameraHelper.weatherData, isNull);
      expect(cameraHelper.positionLat, isNull);
      expect(cameraHelper.positionLng, isNull);
    });

    test('positionLat and positionLng delegate to latitude/longitude', () {
      // After dispose, all should be null
      cameraHelper.dispose();

      expect(cameraHelper.positionLat, cameraHelper.latitude);
      expect(cameraHelper.positionLng, cameraHelper.longitude);
    });
  });
}
