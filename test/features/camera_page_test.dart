import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/camera/camera_state.dart';
import 'package:lurebox/core/camera/camera_view_model.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/services/equipment_service.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';
import 'package:lurebox/features/camera/widgets/camera_view_widget.dart';
import 'package:lurebox/widgets/common/premium_button.dart';

import '../helpers/test_helpers.dart';

/// Mock CameraViewModel that avoids real camera hardware.
///
/// CameraViewWidget takes (state, vm, strings) as constructor params.
/// vm.cameraHelper is only accessed in the camera preview path
/// (isCameraInitialized && no error), which we skip because it
/// requires real camera hardware.
class _MockCameraViewModel extends CameraViewModel {
  _MockCameraViewModel()
      : super(
          FishCatchService(
            MockFishCatchRepository(),
            MockSpeciesHistoryRepository(),
            MockStatsRepository(),
          ),
          EquipmentService(MockEquipmentRepository()),
          AppStrings.chinese,
        );

  @override
  Future<void> initializeCamera() async {}

  @override
  Future<void> switchCamera() async {}
}

void main() {
  setUpAll(registerFallbackValues);

  Widget buildWidget({
    required CameraState state,
    CameraViewModel? vm,
    VoidCallback? onPickFromGallery,
    VoidCallback? onTakePicture,
  }) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: Scaffold(
        body: CameraViewWidget(
          state: state,
          vm: vm ?? _MockCameraViewModel(),
          strings: AppStrings.chinese,
          onPickFromGallery: onPickFromGallery,
          onTakePicture: onTakePicture,
        ),
      ),
    );
  }

  group('CameraViewWidget', () {
    group('Loading state', () {
      testWidgets('shows CircularProgressIndicator when isLoading',
          (tester) async {
        const loadingState = CameraState(
          isLoading: true,
        );
        await tester.pumpWidget(buildWidget(state: loadingState));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(
          find.text(AppStrings.chinese.initializingCamera),
          findsOneWidget,
        );
      });

      testWidgets('shows loading when not initialized and not loading',
          (tester) async {
        const initial = CameraState(
          
        );
        await tester.pumpWidget(buildWidget(state: initial));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Error state', () {
      testWidgets('shows error icon and message', (tester) async {
        const errorState = CameraState(
          errorMessage: 'Camera permission denied',
        );
        await tester.pumpWidget(buildWidget(state: errorState));
        await tester.pump();

        expect(find.byIcon(Icons.camera_alt), findsOneWidget);
        expect(find.text('Camera permission denied'), findsOneWidget);
      });

      testWidgets('shows retry button with correct label', (tester) async {
        const errorState = CameraState(
          errorMessage: 'No camera found',
        );
        await tester.pumpWidget(buildWidget(state: errorState));
        await tester.pump();

        expect(
          find.widgetWithText(PremiumButton, AppStrings.chinese.retry),
          findsOneWidget,
        );
      });

      testWidgets('retry button has primary variant', (tester) async {
        const errorState = CameraState(
          errorMessage: 'Error',
        );
        await tester.pumpWidget(buildWidget(state: errorState));
        await tester.pump();

        final retryButton = tester.widget<PremiumButton>(
          find.widgetWithText(PremiumButton, AppStrings.chinese.retry),
        );
        expect(retryButton.variant, PremiumButtonVariant.primary);
      });
    });

    group('Capture button states', () {
      testWidgets('switch camera button disabled when canSwitchCamera false',
          (tester) async {
        const noSwitch = CameraState(
          isLoading: true,
        );
        await tester.pumpWidget(buildWidget(state: noSwitch));
        await tester.pump();

        final switchBtn = tester.widget<PremiumIconButton>(
          find.widgetWithIcon(PremiumIconButton, Icons.cameraswitch),
        );
        expect(switchBtn.onPressed, isNull);
      });

      testWidgets('switch camera button enabled when canSwitchCamera true',
          (tester) async {
        const withSwitch = CameraState(
          isLoading: true,
          canSwitchCamera: true,
        );
        await tester.pumpWidget(buildWidget(state: withSwitch));
        await tester.pump();

        final switchBtn = tester.widget<PremiumIconButton>(
          find.widgetWithIcon(PremiumIconButton, Icons.cameraswitch),
        );
        expect(switchBtn.onPressed, isNotNull);
      });
    });

    group('Controls rendering', () {
      testWidgets('renders gallery and switch camera buttons', (tester) async {
        const state = CameraState(
          isLoading: true,
        );
        await tester.pumpWidget(buildWidget(state: state));
        await tester.pump();

        expect(
          find.widgetWithIcon(PremiumIconButton, Icons.photo_library),
          findsOneWidget,
        );
        expect(
          find.widgetWithIcon(PremiumIconButton, Icons.cameraswitch),
          findsOneWidget,
        );
      });

      testWidgets('gallery button uses secondary variant', (tester) async {
        const state = CameraState(
          isLoading: true,
        );
        await tester.pumpWidget(buildWidget(state: state));
        await tester.pump();

        final galleryBtn = tester.widget<PremiumIconButton>(
          find.widgetWithIcon(PremiumIconButton, Icons.photo_library),
        );
        expect(galleryBtn.variant, PremiumButtonVariant.secondary);
      });

      testWidgets('capture button has circular shape', (tester) async {
        const state = CameraState(
          isLoading: true,
        );
        await tester.pumpWidget(buildWidget(state: state));
        await tester.pump();

        final circleFinder = find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).shape == BoxShape.circle &&
              (w.decoration! as BoxDecoration).border != null,
        );
        expect(circleFinder, findsOneWidget);
      });

      testWidgets('has SafeArea at bottom', (tester) async {
        const state = CameraState(
          isLoading: true,
        );
        await tester.pumpWidget(buildWidget(state: state));
        await tester.pump();

        expect(find.byType(SafeArea), findsWidgets);
      });
    });

    group('AppBar', () {
      testWidgets('shows recordCatch title', (tester) async {
        const state = CameraState(isLoading: true);
        await tester.pumpWidget(buildWidget(state: state));
        await tester.pump();

        expect(find.text(AppStrings.chinese.recordCatch), findsOneWidget);
      });
    });
  });
}
