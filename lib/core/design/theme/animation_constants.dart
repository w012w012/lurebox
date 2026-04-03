import 'package:flutter/material.dart';

/// iOS-style animation constants for LureBox UI/UX redesign.
class AnimationConstants {
  AnimationConstants._();

  /// Page transition duration (iOS-style).
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);

  /// Stagger delay between list items.
  static const Duration staggerDelay = Duration(milliseconds: 50);

  /// Touch feedback animation duration.
  static const Duration touchFeedbackDuration = Duration(milliseconds: 150);

  /// Scale factor for touch feedback (pressed state).
  static const double touchScale = 0.98;

  /// Default curve for animations.
  static const Curve defaultCurve = Curves.easeOut;
}
