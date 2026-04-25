import 'package:flutter/material.dart';

/// Responsive layout utility for adaptive layouts across devices
///
/// Breakpoints:
/// - mobile: < 600dp (default phone layout)
/// - tablet: >= 600dp (dual-column layouts)
/// - desktop: >= 1200dp (expanded layouts)
enum ResponsiveBreakpoint {
  mobile,
  tablet,
  desktop,
}

/// Extension on num for responsive breakpoint calculations
extension ResponsiveBreakpointExtension on num {
  /// Check if current width is in mobile range (< 600dp)
  bool get isMobile => this < 600;

  /// Check if current width is in tablet range (>= 600dp)
  bool get isTablet => this >= 600;

  /// Check if current width is in desktop range (>= 1200dp)
  bool get isDesktop => this >= 1200;

  /// Get the current breakpoint based on width
  ResponsiveBreakpoint get breakpoint {
    if (this < 600) return ResponsiveBreakpoint.mobile;
    if (this < 1200) return ResponsiveBreakpoint.tablet;
    return ResponsiveBreakpoint.desktop;
  }
}

/// Widget that provides responsive breakpoint information to its children
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
          BuildContext context, double width, ResponsiveBreakpoint breakpoint)
      builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final breakpoint = width.breakpoint;
        return builder(context, width, breakpoint);
      },
    );
  }
}

/// Mixin to add responsive breakpoint properties to any widget
mixin ResponsiveMixin<T extends StatefulWidget> on State<T> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600;
  bool get isDesktop => screenWidth >= 1200;

  ResponsiveBreakpoint get breakpoint => screenWidth.breakpoint;

  /// Get number of columns for grid based on screen width
  int get gridColumns {
    if (screenWidth < 600) return 1;
    if (screenWidth < 900) return 2;
    return 3;
  }

  /// Get responsive horizontal padding
  double get horizontalPadding {
    if (isMobile) return 16;
    if (isTablet) return 24;
    return 32;
  }

  /// Check if device is in landscape orientation
  bool get isLandscape => screenHeight < screenWidth;

  /// Get responsive content max width for centering on large screens
  double get contentMaxWidth {
    if (screenWidth <= 600) return screenWidth;
    if (screenWidth <= 900) return 600;
    return 800;
  }
}

/// Convenience widget for responsive column/row switching
class ResponsiveLayout extends StatelessWidget {
  /// Widget shown on mobile (single column)
  final Widget? mobile;

  /// Widget shown on tablet/desktop (multi-column)
  final Widget? tablet;

  /// Cross axis alignment for the layout
  final CrossAxisAlignment crossAxisAlignment;

  /// Main axis alignment
  final MainAxisAlignment mainAxisAlignment;

  /// Gap between children
  final double gap;

  const ResponsiveLayout({
    super.key,
    this.mobile,
    this.tablet,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.gap = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;

        final tabletWidget = tablet;
        final mobileWidget = mobile;

        if (isTablet && tabletWidget != null) {
          return tabletWidget;
        }

        if (mobileWidget != null) {
          return mobileWidget;
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Responsive container that constrains width on large screens
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final constrainedWidth =
            maxWidth != null && width > maxWidth! ? maxWidth! : width;

        return Center(
          child: Container(
            width: constrainedWidth,
            padding: padding,
            child: child,
          ),
        );
      },
    );
  }
}
