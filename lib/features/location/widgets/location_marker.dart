import 'package:flutter/material.dart';
import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/app_theme.dart';
import '../../../core/design/theme/animation_constants.dart';

/// Location marker widget with blue accent styling and iOS-style touch feedback.
class LocationMarker extends StatefulWidget {
  final String name;
  final int fishCount;
  final bool isSelected;
  final VoidCallback onTap;

  const LocationMarker({
    super.key,
    required this.name,
    required this.fishCount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<LocationMarker> createState() => _LocationMarkerState();
}

class _LocationMarkerState extends State<LocationMarker> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Blue accent color scheme - primary #1E3A5F, accent #3B82F6
    final backgroundColor = widget.isSelected
        ? (isDark ? AppColors.accentDark : AppColors.accentLight)
        : (isDark ? AppColors.primaryDark : AppColors.primaryLight);
    final borderColor = widget.isSelected
        ? Colors.white
        : (isDark ? AppColors.accentDark : AppColors.accentLight);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? AnimationConstants.touchScale : 1.0,
        duration: AnimationConstants.touchFeedbackDuration,
        curve: AnimationConstants.defaultCurve,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSm,
                vertical: AppTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 16),
                  const SizedBox(width: AppTheme.spacingXs),
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingXs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${widget.fishCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CustomPaint(
              size: const Size(12, 8),
              painter: _TrianglePainter(color: backgroundColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
