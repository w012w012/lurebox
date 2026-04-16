import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';

import '../../../core/constants/strings.dart';
import '../../../core/camera/camera_state.dart';
import '../../../core/camera/camera_view_model.dart';
import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/tesla_theme.dart';
import '../../../widgets/common/premium_button.dart';

/// Camera view widget - displays camera preview with capture controls.
class CameraViewWidget extends ConsumerWidget {
  final CameraState state;
  final CameraViewModel vm;
  final AppStrings strings;
  final VoidCallback? onPickFromGallery;
  final VoidCallback? onTakePicture;

  const CameraViewWidget({
    super.key,
    required this.state,
    required this.vm,
    required this.strings,
    this.onPickFromGallery,
    this.onTakePicture,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(strings.recordCatch)),
      body: Column(
        children: [
          Expanded(child: _buildCameraPreview(context)),
          _buildCameraControls(context),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(BuildContext context) {
    if (state.errorMessage != null && !state.isCameraInitialized) {
      return _buildErrorView(context);
    }

    if (!state.isCameraInitialized || state.isLoading) {
      return _buildLoadingView();
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
        child: CameraPreview(vm.cameraHelper.cameraController!),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'Camera error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            PremiumButton(
              text: strings.retry,
              onPressed: () => vm.initializeCamera(),
              variant: PremiumButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(strings.initializingCamera),
        ],
      ),
    );
  }

  Widget _buildCameraControls(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = TeslaColors.electricBlue;
    final surfaceColor = isDark ? TeslaColors.carbonDark : TeslaColors.white;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PremiumIconButton(
              icon: Icons.photo_library,
              onPressed: onPickFromGallery,
              tooltip: strings.selectFromGallery,
              size: 48,
              variant: PremiumButtonVariant.secondary,
            ),
            GestureDetector(
              onTap: state.isTakingPicture ? null : onTakePicture,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor,
                    ),
                    child: state.isTakingPicture
                        ? Padding(
                            padding: const EdgeInsets.all(15),
                            child: CircularProgressIndicator(
                              color: TeslaColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            PremiumIconButton(
              icon: Icons.cameraswitch,
              onPressed: state.canSwitchCamera ? () => vm.switchCamera() : null,
              tooltip: strings.switchCamera,
              size: 48,
              variant: PremiumButtonVariant.secondary,
              color: state.canSwitchCamera
                  ? accentColor
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
