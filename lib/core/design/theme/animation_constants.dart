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

/// Tesla-inspired animation constants: 0.33s cubic-bezier transitions.
class TeslaAnimation {
  TeslaAnimation._();

  /// Universal transition duration for all interactive state changes.
  static const Duration transition = Duration(milliseconds: 330);

  /// Cubic-bezier curve: cubic-bezier(0.16, 1, 0.3, 1)
  static const Curve teslaCurve = Cubic(0.16, 1.0, 0.3, 1.0);

  /// Color-only transition duration.
  static const Duration colorTransition = Duration(milliseconds: 330);

  /// Border/shadow animation duration.
  static const Duration borderTransition = Duration(milliseconds: 250);

  /// Page transition duration (Tesla-style).
  static const Duration pageTransitionDuration = Duration(milliseconds: 330);
}
