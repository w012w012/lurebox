import 'package:flutter/material.dart';

/// Tesla design tokens: spacing, radius, and shadow.
/// Zero shadows — depth via photography and frosted glass only.
class TeslaTokens {
  TeslaTokens._();

  // ─── Spacing (8px base unit) ───────────────────────────────────────────────

  /// 8px — micro spacing.
  static const double spacingMicro = 4;
  /// 8px — small spacing.
  static const double spacingSm = 8;
  /// 16px — medium spacing.
  static const double spacingMd = 16;
  /// 24px — large spacing.
  static const double spacingLg = 24;
  /// 32px — extra large spacing.
  static const double spacingXl = 32;
  /// 48px — section spacing.
  static const double spacingSection = 48;
  /// 64px — hero spacing.
  static const double spacingHero = 64;

  // ─── Border Radius ───────────────────────────────────────────────────────────

  /// 0px — sharp edges are the default.
  static const double radiusNone = 0;
  /// 4px — buttons (primary, secondary, nav items).
  static const double radiusMicro = 4;
  /// ~12px — category cards.
  static const double radiusCard = 12;
  /// 50% — carousel dot indicators.
  static const double radiusFull = 9999;

  // ─── Shadows ────────────────────────────────────────────────────────────────

  /// No shadows — depth achieved via frosted glass and photography.
  static const List<BoxShadow> shadowNone = <BoxShadow>[];

  /// Level 3 (Subtle): `rgba(0,0,0,0.05)` — used very sparingly on hover.
  static List<BoxShadow> get shadowSubtle => [
        const BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ];

  // ─── Z-Index / Elevation ────────────────────────────────────────────────────

  /// Level 0 (Flat): default state — no shadow, no border.
  static const double elevationFlat = 0;
  /// Level 1 (Frost): frosted glass nav on scroll.
  static const double elevationFrost = 1;
  /// Level 2 (Overlay): modal overlays.
  static const double elevationOverlay = 2;
}
