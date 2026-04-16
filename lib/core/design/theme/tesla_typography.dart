import 'package:flutter/material.dart';

/// Tesla typography system.
/// Reference: DESIGN.md Typography Rules.
///
/// Uses weight 400 (regular) and 500 (medium) only.
/// No bold (700), no light (300).
/// Universal Sans Display for hero, Universal Sans Text for UI.
class TeslaTypography {
  TeslaTypography._();

  // ─── Hero Scale ─────────────────────────────────────────────────────────────

  /// Hero Title: 40px, weight 500, height 48px (1.20).
  /// Universal Sans Display, white on dark hero imagery.
  static TextStyle heroTitle({Color? color}) => TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w500,
        height: 48 / 40, // 1.20
        letterSpacing: 0,
        color: color ?? const Color(0xFF171A20),
      );

  /// Promo Text: 22px, weight 400, height 20px (0.91).
  /// White promotional text on hero ("0% APR Available").
  static TextStyle promoText({Color? color}) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        height: 20 / 22, // ~0.91
        letterSpacing: 0,
        color: color ?? const Color(0xFFFFFFFF),
      );

  // ─── Product / Card Names ──────────────────────────────────────────────────

  /// Product Name: 17px, weight 500, height 20px (1.18).
  /// Model names in nav panel and cards.
  static TextStyle productName({Color? color}) => TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        height: 20 / 17, // ~1.18
        letterSpacing: 0,
        color: color ?? const Color(0xFF171A20),
      );

  /// Category Label: 16px, weight 500.
  /// White text labels on category cards ("Sport Sedan").
  static TextStyle categoryLabel({Color? color}) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 0,
        color: color ?? const Color(0xFFFFFFFF),
      );

  // ─── Navigation & UI ───────────────────────────────────────────────────────

  /// Nav Item: 14px, weight 500, height 16.8px (1.20).
  /// Primary navigation labels.
  static TextStyle navItem({Color? color}) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 16.8 / 14, // 1.20
        letterSpacing: 0,
        color: color ?? const Color(0xFF171A20),
      );

  /// Button Label: 14px, weight 500, height 16.8px (1.20).
  /// CTA button text.
  static TextStyle buttonLabel({Color? color}) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 16.8 / 14, // 1.20
        letterSpacing: 0,
        color: color ?? const Color(0xFFFFFFFF),
      );

  // ─── Body & Sub-text ────────────────────────────────────────────────────────

  /// Body Text: 14px, weight 400, height 20px (1.43).
  /// Paragraph and descriptive content.
  static TextStyle body({Color? color}) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14, // ~1.43
        letterSpacing: 0,
        color: color ?? const Color(0xFF393C41),
      );

  /// Sub-link: 14px, weight 400, height 20px (1.43).
  /// Tertiary links ("Learn", "Order", "Experience").
  static TextStyle subLink({Color? color}) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14, // ~1.43
        letterSpacing: 0,
        color: color ?? const Color(0xFF5C5E62),
      );

  // ─── Input Placeholder ──────────────────────────────────────────────────────

  /// Placeholder: 14px, weight 400, Silver Fog color.
  /// Input field placeholder text.
  static TextStyle placeholder({Color? color}) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: 0,
        color: color ?? const Color(0xFF8E8E8E),
      );
}
