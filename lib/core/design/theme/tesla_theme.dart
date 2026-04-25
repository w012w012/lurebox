import 'package:flutter/material.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_typography.dart';

/// Tesla-inspired ThemeData.
/// Reference: DESIGN.md Tesla Visual Theme & Component Styling.
///
/// Key principles:
/// - Zero shadows: depth via frosted glass and photography
/// - Electric Blue (#3E6AE1) for primary CTAs only
/// - 4px border-radius for buttons, 12px for cards
/// - 0.33s cubic-bezier(0.16,1,0.3,1) transitions
/// - Weight 400/500 only
/// - No borders, no gradients
class TeslaTheme {
  TeslaTheme._();

  /// Spacing: 8px base unit.
  static const double spacingMicro = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  /// Border radius: 4px buttons, 12px cards, 0px default.
  static const double radiusMicro = 4;
  static const double radiusCard = 12;

  /// 0.33s cubic-bezier(0.16, 1, 0.3, 1) — Tesla's universal transition.
  static const Duration transitionDuration = Duration(milliseconds: 330);
  static const Curve transitionCurve = Cubic(0.16, 1, 0.3, 1);

  // ─── Light Theme ──────────────────────────────────────────────────────────

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: TeslaColors.electricBlue,
        onSurface: TeslaColors.carbonDark,
        outline: TeslaColors.cloudGray,
      ),
      scaffoldBackgroundColor: TeslaColors.white,

      appBarTheme: AppBarTheme(
        backgroundColor: TeslaColors.white,
        foregroundColor: TeslaColors.carbonDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TeslaTypography.productName(
          color: TeslaColors.carbonDark,
        ),
        iconTheme: const IconThemeData(
          color: TeslaColors.carbonDark,
          size: 24,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: TeslaColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: TeslaColors.frostedGlassWhite,
        elevation: 0,
        height: 80,
        indicatorColor: TeslaColors.electricBlue.withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMicro),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: TeslaColors.electricBlue,
              size: 24,
            );
          }
          return const IconThemeData(
            color: TeslaColors.pewter,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TeslaTypography.navItem(color: TeslaColors.electricBlue);
          }
          return TeslaTypography.navItem(color: TeslaColors.pewter);
        }),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TeslaColors.electricBlue,
          foregroundColor: TeslaColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMd,
            vertical: spacingMicro,
          ),
          minimumSize: const Size(200, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMicro),
          ),
          textStyle: TeslaTypography.buttonLabel(),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TeslaColors.graphite,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMd,
            vertical: spacingMicro,
          ),
          minimumSize: const Size(160, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMicro),
          ),
          side: const BorderSide(color: TeslaColors.graphite),
          textStyle: TeslaTypography.buttonLabel(color: TeslaColors.graphite),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: TeslaColors.pewter,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingSm,
            vertical: spacingMicro,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMicro),
          ),
          textStyle: TeslaTypography.subLink(color: TeslaColors.pewter),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: TeslaColors.electricBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingSm,
          vertical: spacingMicro,
        ),
        hintStyle: TeslaTypography.placeholder(),
        labelStyle: TeslaTypography.body(color: TeslaColors.graphite),
      ),

      dividerTheme: const DividerThemeData(
        color: TeslaColors.cloudGray,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: TeslaColors.electricBlue,
        contentTextStyle: TeslaTypography.body(color: TeslaColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMicro),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: TeslaColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        titleTextStyle: TeslaTypography.productName(
          color: TeslaColors.carbonDark,
        ),
        contentTextStyle: TeslaTypography.body(color: TeslaColors.graphite),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: TeslaColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusCard),
          ),
        ),
      ),
    );
  }

  // ─── Dark Theme ───────────────────────────────────────────────────────────

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: TeslaColors.electricBlue,
        onPrimary: TeslaColors.white,
        surface: TeslaColors.carbonDark,
        outline: Color(0xFF2A2D30),
      ),
      scaffoldBackgroundColor: const Color(0xFF000000), // True Black

      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF000000),
        foregroundColor: TeslaColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TeslaTypography.productName(
          color: TeslaColors.white,
        ),
        iconTheme: const IconThemeData(
          color: TeslaColors.white,
          size: 24,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: TeslaColors.carbonDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: TeslaColors.frostedGlassDark,
        elevation: 0,
        height: 80,
        indicatorColor: TeslaColors.electricBlue.withValues(alpha: 0.2),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMicro),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: TeslaColors.electricBlue,
              size: 24,
            );
          }
          return const IconThemeData(
            color: Color(0xFF9A9A9A),
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TeslaTypography.navItem(color: TeslaColors.electricBlue);
          }
          return TeslaTypography.navItem(
            color: const Color(0xFF9A9A9A),
          );
        }),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TeslaColors.electricBlue,
          foregroundColor: TeslaColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMd,
            vertical: spacingMicro,
          ),
          minimumSize: const Size(200, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMicro),
          ),
          textStyle: TeslaTypography.buttonLabel(),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TeslaColors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMd,
            vertical: spacingMicro,
          ),
          minimumSize: const Size(160, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMicro),
          ),
          side: const BorderSide(color: Color(0xFF5A5A5A)),
          textStyle: TeslaTypography.buttonLabel(color: TeslaColors.white),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF9A9A9A),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingSm,
            vertical: spacingMicro,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMicro),
          ),
          textStyle: TeslaTypography.subLink(color: const Color(0xFF9A9A9A)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: TeslaColors.electricBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingSm,
          vertical: spacingMicro,
        ),
        hintStyle: TeslaTypography.placeholder(
          color: const Color(0xFF6A6A6A),
        ),
        labelStyle: TeslaTypography.body(color: const Color(0xFFB0B0B0)),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2D30),
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: TeslaColors.electricBlue,
        contentTextStyle: TeslaTypography.body(color: TeslaColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMicro),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: TeslaColors.carbonDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        titleTextStyle: TeslaTypography.productName(
          color: TeslaColors.white,
        ),
        contentTextStyle: TeslaTypography.body(color: const Color(0xFFB0B0B0)),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: TeslaColors.carbonDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusCard),
          ),
        ),
      ),
    );
  }
}
