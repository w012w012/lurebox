import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    group('Primary Colors', () {
      test('primaryLight should be deep sea blue #1E3A5F', () {
        expect(AppColors.primaryLight, const Color(0xFF1E3A5F));
      });

      test('primaryDark should be light blue #8FADC5', () {
        expect(AppColors.primaryDark, const Color(0xFF8FADC5));
      });
    });

    group('Accent Colors', () {
      test('accentLight should be bright blue #3B82F6', () {
        expect(AppColors.accentLight, const Color(0xFF3B82F6));
      });

      test('accentDark should be lighter blue #93C5FD', () {
        expect(AppColors.accentDark, const Color(0xFF93C5FD));
      });
    });

    group('Semantic Colors (Unchanged)', () {
      test('release should be green #48BB78', () {
        expect(AppColors.release, const Color(0xFF48BB78));
      });

      test('keep should be orange #ED8936', () {
        expect(AppColors.keep, const Color(0xFFED8936));
      });
    });

    group('Dark Mode Surface Colors (True Black)', () {
      test('backgroundDark should be True Black #000000', () {
        expect(AppColors.backgroundDark, const Color(0xFF000000));
      });

      test('surfaceDark should be card color #0A0A0A', () {
        expect(AppColors.surfaceDark, const Color(0xFF0A0A0A));
      });

      test(
          'darkColorScheme surfaceContainerHighest should be #111111 for inputs',
          () {
        final scheme = AppColors.darkColorScheme();
        // surfaceContainerHighest is used for inputs in dark mode
        expect(scheme.surfaceContainerHighest, const Color(0xFF111111));
      });
    });

    group('ColorScheme', () {
      test('lightColorScheme should use correct primary color', () {
        final scheme = AppColors.lightColorScheme();
        expect(scheme.primary, AppColors.primaryLight);
      });

      test('lightColorScheme should use correct accent color', () {
        final scheme = AppColors.lightColorScheme();
        expect(scheme.tertiary, AppColors.accentLight);
      });

      test('darkColorScheme should use True Black background', () {
        final scheme = AppColors.darkColorScheme();
        // surface is used for cards/scaffolds
        expect(scheme.surface, AppColors.surfaceDark);
      });
    });

    group('Grey Palette (Unchanged)', () {
      test('grey100 should remain #F7FAFC', () {
        expect(AppColors.grey100, const Color(0xFFF7FAFC));
      });

      test('grey900 should remain #1A202C', () {
        expect(AppColors.grey900, const Color(0xFF1A202C));
      });
    });

    group('Chart Colors (Unchanged)', () {
      test('chartColors should contain teal for variety', () {
        expect(AppColors.chartColors, isNotEmpty);
        // Teal should be in the chart colors
        expect(AppColors.chartColors, contains(AppColors.teal));
      });
    });

    group('Color Distinctness', () {
      test('primary/accent semantic pairs should differ between modes', () {
        expect(AppColors.primaryLight, isNot(equals(AppColors.primaryDark)));
        expect(AppColors.accentLight, isNot(equals(AppColors.accentDark)));
      });

      test('chart colors should all be distinct', () {
        final uniqueColors = AppColors.chartColors.toSet();
        expect(uniqueColors.length, equals(AppColors.chartColors.length));
      });
    });

    group('Tesla Design System', () {
      test('teslaElectricBlue should be #3E6AE1', () {
        expect(AppColors.teslaElectricBlue, const Color(0xFF3E6AE1));
      });

      test('teslaCarbonDark should be #171A20', () {
        expect(AppColors.teslaCarbonDark, const Color(0xFF171A20));
      });

      test('teslaFrostedGlassWhite should have 0.75 alpha', () {
        final color = AppColors.teslaFrostedGlassWhite;
        expect(color.a, closeTo(0.75, 0.01));
      });

      test('teslaFrostedGlassDark should have 0.85 alpha', () {
        final color = AppColors.teslaFrostedGlassDark;
        expect(color.a, closeTo(0.85, 0.01));
      });
    });
  });
}
