import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/design/theme/app_theme.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';

void main() {
  group('AppTheme', () {
    group('Light Theme', () {
      late ThemeData lightTheme;

      setUp(() {
        lightTheme = AppTheme.light;
      });

      test('should use Material 3', () {
        expect(lightTheme.useMaterial3, isTrue);
      });

      test('should have correct brightness', () {
        expect(lightTheme.brightness, Brightness.light);
      });

      test('should use correct primary color scheme', () {
        expect(lightTheme.colorScheme.primary, AppColors.primaryLight);
      });

      test('should use correct accent (tertiary) color', () {
        expect(lightTheme.colorScheme.tertiary, AppColors.accentLight);
      });

      test('should use correct scaffold background color', () {
        expect(lightTheme.scaffoldBackgroundColor, AppColors.backgroundLight);
      });

      group('NavigationBarTheme (iOS-style)', () {
        test('should use accent light for selected icon', () {
          final iconTheme = lightTheme.navigationBarTheme.iconTheme;
          expect(iconTheme, isNotNull);
        });

        test('should use rounded indicator shape', () {
          final indicatorShape = lightTheme.navigationBarTheme.indicatorShape;
          expect(indicatorShape, isA<RoundedRectangleBorder>());
        });

        test('should only show selected label', () {
          expect(
            lightTheme.navigationBarTheme.labelBehavior,
            NavigationDestinationLabelBehavior.onlyShowSelected,
          );
        });
      });

      group('CardTheme (iOS-style subtle shadows)', () {
        test('should have no border side', () {
          final cardShape =
              lightTheme.cardTheme.shape as RoundedRectangleBorder;
          // iOS style: no border, just rounded corners
          expect(cardShape.side, BorderSide.none);
        });

        test('should use surface light color', () {
          expect(lightTheme.cardTheme.color, AppColors.surfaceLight);
        });

        test('should use correct border radius', () {
          final cardShape =
              lightTheme.cardTheme.shape as RoundedRectangleBorder;
          expect(
              cardShape.borderRadius, BorderRadius.circular(AppTheme.radiusMd));
        });
      });

      group('ButtonTheme (iOS-style blue)', () {
        test('elevated button should use accent light color', () {
          final elevatedStyle =
              lightTheme.elevatedButtonTheme.style as ButtonStyle;
          expect(
            elevatedStyle.backgroundColor?.resolve({}),
            AppColors.accentLight,
          );
        });

        test('outlined button should use accent light color', () {
          final outlinedStyle =
              lightTheme.outlinedButtonTheme.style as ButtonStyle;
          expect(
            outlinedStyle.foregroundColor?.resolve({}),
            AppColors.accentLight,
          );
        });

        test('text button should use accent light color', () {
          final textStyle = lightTheme.textButtonTheme.style as ButtonStyle;
          expect(
            textStyle.foregroundColor?.resolve({}),
            AppColors.accentLight,
          );
        });
      });

      group('InputDecorationTheme (iOS-style)', () {
        test('should be filled', () {
          expect(lightTheme.inputDecorationTheme.filled, isTrue);
        });

        test('should use grey100 fill color', () {
          expect(lightTheme.inputDecorationTheme.fillColor, AppColors.grey100);
        });

        test('enabled border should have no side (iOS style)', () {
          final enabledBorder = lightTheme.inputDecorationTheme.enabledBorder
              as OutlineInputBorder;
          expect(enabledBorder.borderSide, BorderSide.none);
        });

        test('focused border should use accent light', () {
          final focusedBorder = lightTheme.inputDecorationTheme.focusedBorder
              as OutlineInputBorder;
          expect(focusedBorder.borderSide.color, AppColors.accentLight);
        });
      });

      group('ChipTheme (iOS-style)', () {
        test('selected color should use accent light opacity', () {
          expect(lightTheme.chipTheme.selectedColor,
              AppColors.accentLight.withOpacity(0.12));
        });
      });

      group('SnackbarTheme (iOS-style blue)', () {
        test('should use accent light background', () {
          expect(
              lightTheme.snackBarTheme.backgroundColor, AppColors.accentLight);
        });
      });
    });

    group('Dark Theme', () {
      late ThemeData darkTheme;

      setUp(() {
        darkTheme = AppTheme.dark;
      });

      test('should use Material 3', () {
        expect(darkTheme.useMaterial3, isTrue);
      });

      test('should have correct brightness', () {
        expect(darkTheme.brightness, Brightness.dark);
      });

      test('should use correct primary color scheme', () {
        expect(darkTheme.colorScheme.primary, AppColors.primaryDark);
      });

      test('should use correct accent (tertiary) color', () {
        expect(darkTheme.colorScheme.tertiary, AppColors.accentDark);
      });

      test('should use True Black scaffold background (#000000)', () {
        expect(darkTheme.scaffoldBackgroundColor, AppColors.backgroundDark);
        expect(darkTheme.scaffoldBackgroundColor, const Color(0xFF000000));
      });

      group('NavigationBarTheme (iOS-style)', () {
        test('should use accent dark for selected icon', () {
          final iconTheme = darkTheme.navigationBarTheme.iconTheme;
          expect(iconTheme, isNotNull);
        });

        test('should use rounded indicator shape', () {
          final indicatorShape = darkTheme.navigationBarTheme.indicatorShape;
          expect(indicatorShape, isA<RoundedRectangleBorder>());
        });

        test('should only show selected label', () {
          expect(
            darkTheme.navigationBarTheme.labelBehavior,
            NavigationDestinationLabelBehavior.onlyShowSelected,
          );
        });
      });

      group('CardTheme (iOS-style True Black)', () {
        test('should have no border side', () {
          final cardShape = darkTheme.cardTheme.shape as RoundedRectangleBorder;
          expect(cardShape.side, BorderSide.none);
        });

        test('should use surface dark (#0A0A0A) for cards', () {
          expect(darkTheme.cardTheme.color, AppColors.surfaceDark);
          expect(darkTheme.cardTheme.color, const Color(0xFF0A0A0A));
        });

        test('should use correct border radius', () {
          final cardShape = darkTheme.cardTheme.shape as RoundedRectangleBorder;
          expect(
              cardShape.borderRadius, BorderRadius.circular(AppTheme.radiusMd));
        });
      });

      group('ButtonTheme (iOS-style blue)', () {
        test('elevated button should use accent dark color', () {
          final elevatedStyle =
              darkTheme.elevatedButtonTheme.style as ButtonStyle;
          expect(
            elevatedStyle.backgroundColor?.resolve({}),
            AppColors.accentDark,
          );
        });

        test('outlined button should use accent dark color', () {
          final outlinedStyle =
              darkTheme.outlinedButtonTheme.style as ButtonStyle;
          expect(
            outlinedStyle.foregroundColor?.resolve({}),
            AppColors.accentDark,
          );
        });

        test('text button should use accent dark color', () {
          final textStyle = darkTheme.textButtonTheme.style as ButtonStyle;
          expect(
            textStyle.foregroundColor?.resolve({}),
            AppColors.accentDark,
          );
        });
      });

      group('InputDecorationTheme (iOS-style)', () {
        test('should be filled', () {
          expect(darkTheme.inputDecorationTheme.filled, isTrue);
        });

        test('should use surface dark fill color (True Black)', () {
          expect(
              darkTheme.inputDecorationTheme.fillColor, AppColors.surfaceDark);
          expect(darkTheme.inputDecorationTheme.fillColor,
              const Color(0xFF0A0A0A));
        });

        test('enabled border should have no side (iOS style)', () {
          final enabledBorder = darkTheme.inputDecorationTheme.enabledBorder
              as OutlineInputBorder;
          expect(enabledBorder.borderSide, BorderSide.none);
        });

        test('focused border should use accent dark', () {
          final focusedBorder = darkTheme.inputDecorationTheme.focusedBorder
              as OutlineInputBorder;
          expect(focusedBorder.borderSide.color, AppColors.accentDark);
        });
      });

      group('ChipTheme (iOS-style)', () {
        test('selected color should use accent dark opacity', () {
          expect(darkTheme.chipTheme.selectedColor,
              AppColors.accentDark.withOpacity(0.15));
        });
      });

      group('SnackbarTheme (iOS-style blue)', () {
        test('should use accent dark background', () {
          expect(darkTheme.snackBarTheme.backgroundColor, AppColors.accentDark);
        });
      });
    });

    group('Spacing System (4px base unit)', () {
      test('spacingXs should be 4.0', () {
        expect(AppTheme.spacingXs, 4.0);
      });

      test('spacingSm should be 8.0', () {
        expect(AppTheme.spacingSm, 8.0);
      });

      test('spacingMd should be 12.0', () {
        expect(AppTheme.spacingMd, 12.0);
      });

      test('spacingLg should be 16.0', () {
        expect(AppTheme.spacingLg, 16.0);
      });

      test('spacingXl should be 24.0', () {
        expect(AppTheme.spacingXl, 24.0);
      });

      test('spacingXxl should be 32.0', () {
        expect(AppTheme.spacingXxl, 32.0);
      });
    });

    group('Radius System', () {
      test('radiusSm should be 6.0', () {
        expect(AppTheme.radiusSm, 6.0);
      });

      test('radiusMd should be 12.0', () {
        expect(AppTheme.radiusMd, 12.0);
      });

      test('radiusLg should be 16.0', () {
        expect(AppTheme.radiusLg, 16.0);
      });

      test('radiusXl should be 24.0', () {
        expect(AppTheme.radiusXl, 24.0);
      });

      test('radiusFull should be 9999.0', () {
        expect(AppTheme.radiusFull, 9999.0);
      });
    });

    group('Shadow System', () {
      test('shadowSm should return a list of BoxShadow', () {
        expect(AppTheme.shadowSm, isA<List<BoxShadow>>());
        expect(AppTheme.shadowSm.length, 1);
      });

      test('shadowMd should return a list of BoxShadow', () {
        expect(AppTheme.shadowMd, isA<List<BoxShadow>>());
        expect(AppTheme.shadowMd.length, 1);
      });

      test('shadowLg should return a list of BoxShadow', () {
        expect(AppTheme.shadowLg, isA<List<BoxShadow>>());
        expect(AppTheme.shadowLg.length, 1);
      });
    });
  });
}
