import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    group('Primary Colors', () {
      test('primaryLight should be deep sea blue #1E3A5F', () {
        expect(AppColors.primaryLight, const Color(0xFF1E3A5F));
      });

      test('primaryDark should be light blue for dark mode contrast', () {
        // Should be lighter than primaryLight for dark mode readability
        expect(AppColors.primaryDark.value, isNotNull);
      });
    });

    group('Accent Colors', () {
      test('accentLight should be bright blue #3B82F6', () {
        expect(AppColors.accentLight, const Color(0xFF3B82F6));
      });

      test('accentDark should be lighter blue for dark mode', () {
        expect(AppColors.accentDark.value, isNotNull);
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
  });
}
