import 'package:flutter/material.dart';
import '../../core/design/theme/app_colors.dart';

/// Global SnackBar utilities — replaces all ad-hoc ScaffoldMessenger calls.
class AppSnackBar {
  AppSnackBar._();

  /// Bottom padding offset so the SnackBar sits above the NavigationBar.
  static double _bottomPadding(BuildContext context) {
    return MediaQuery.of(context).padding.bottom + 80;
  }

  /// Show a success message.
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: TeslaColors.success, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: TeslaColors.carbonDark,
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: _bottomPadding(context),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show an error message. Debug info is printed to console, not shown in UI.
  static void showError(
    BuildContext context,
    String userMessage, {
    Object? debugError,
  }) {
    if (debugError != null) {
      debugPrint('[AppSnackBar] Error: $debugError');
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(userMessage)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        backgroundColor: TeslaColors.danger,
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: _bottomPadding(context),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show an informational message.
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: TeslaColors.electricBlue, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: TeslaColors.carbonDark,
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: _bottomPadding(context),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show a success message with an Undo action.
  static void showSuccessWithUndo(
    BuildContext context,
    String message,
    String undoLabel,
    VoidCallback onUndo,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        backgroundColor: TeslaColors.carbonDark,
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: _bottomPadding(context),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: undoLabel,
          textColor: TeslaColors.electricBlue,
          onPressed: onUndo,
        ),
      ),
    );
  }
}
