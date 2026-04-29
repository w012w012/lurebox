import 'package:flutter/material.dart';
import 'package:lurebox/core/design/theme/animation_constants.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';

/// Staggered reveal animation — fade in + slide up.
///
/// Two usage patterns:
///
/// 1. **Self-contained** (provide [index], omit [animation]):
///    Creates its own [AnimationController] and staggers start via
///    [Future.delayed].  Good for simple pages with a fixed item count.
///
/// 2. **Animation supplied** (provide [animation], omit [index]):
///    Uses an externally managed animation.  Good for pages with
///    complex lifecycle requirements (e.g., animation pool limits).
class StaggeredReveal extends StatefulWidget {
  /// Self-contained mode — widget owns the controller.
  const StaggeredReveal({
    required this.index,
    required this.child,
    super.key,
  })  : animation = null,
        assert(index >= 0, 'index must be non-negative');

  /// External-animation mode — caller owns the controller.
  const StaggeredReveal.withAnimation({
    required Animation<double> this.animation,
    required this.child,
    super.key,
  }) : index = 0;

  /// Item index — used to compute the stagger delay.
  final int index;

  /// Optional externally managed animation. When null the widget creates
  /// its own controller and uses [index] for stagger timing.
  final Animation<double>? animation;

  /// The widget to reveal.
  final Widget child;

  @override
  State<StaggeredReveal> createState() => _StaggeredRevealState();
}

class _StaggeredRevealState extends State<StaggeredReveal>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.animation == null) {
      _controller = AnimationController(
        duration: TeslaTheme.transitionDuration,
        vsync: this,
      );

      _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller!,
          curve: TeslaTheme.transitionCurve,
        ),
      );

      _slideAnimation =
          Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
              .animate(
        CurvedAnimation(
          parent: _controller!,
          curve: TeslaTheme.transitionCurve,
        ),
      );

      final delay = AnimationConstants.staggerDelay * widget.index;
      Future.delayed(delay, () {
        if (mounted) {
          _controller!.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animation != null) {
      // External-animation mode
      return FadeTransition(
        opacity: widget.animation!,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.15),
            end: Offset.zero,
          ).animate(widget.animation!),
          child: widget.child,
        ),
      );
    }

    // Self-contained mode
    return FadeTransition(
      opacity: _fadeAnimation!,
      child: SlideTransition(
        position: _slideAnimation!,
        child: widget.child,
      ),
    );
  }
}
