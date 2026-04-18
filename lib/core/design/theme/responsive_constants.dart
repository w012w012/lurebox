/// Responsive breakpoints for adaptive layouts.
///
/// Usage:
/// ```dart
/// final isTablet = MediaQuery.of(context).size.width >= ResponsiveConstants.tabletMinWidth;
/// ```
class ResponsiveConstants {
  ResponsiveConstants._();

  /// Phone / mobile maximum width
  static const double mobileMaxWidth = 600;

  /// Tablet minimum width
  static const double tabletMinWidth = 600;

  /// Large tablet minimum width
  static const double largeTabletMinWidth = 900;

  /// Check if current screen width is tablet or larger
  static bool isTablet(double width) => width >= tabletMinWidth;

  /// Check if current screen width is large tablet or larger
  static bool isLargeTablet(double width) => width >= largeTabletMinWidth;

  /// Check if current screen width is phone
  static bool isPhone(double width) => width < tabletMinWidth;
}
