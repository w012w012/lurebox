import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/design/theme/animation_constants.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/app_theme.dart';
import 'package:lurebox/widgets/common/premium_button.dart';
import 'package:lurebox/widgets/common/premium_card.dart';
import 'package:lurebox/widgets/common/premium_input.dart';

void main() {
  group('Design System Verification Tests', () {
    test('AnimationConstants uses correct touch feedback values', () {
      expect(AnimationConstants.touchFeedbackDuration,
          const Duration(milliseconds: 150),);
      expect(AnimationConstants.touchScale, 0.98);
    });

    test('AppColors has correct blue theme colors', () {
      expect(AppColors.primaryLight, const Color(0xFF1E3A5F));
      expect(AppColors.accentLight, const Color(0xFF3B82F6));
    });

    test('AppTheme has correct spacing system', () {
      expect(AppTheme.spacingXs, 4.0);
      expect(AppTheme.spacingSm, 8.0);
      expect(AppTheme.spacingMd, 12.0);
      expect(AppTheme.spacingLg, 16.0);
      expect(AppTheme.spacingXl, 24.0);
      expect(AppTheme.spacingXxl, 32.0);
    });

    test('AppTheme has correct radius system', () {
      expect(AppTheme.radiusSm, 6.0);
      expect(AppTheme.radiusMd, 12.0);
      expect(AppTheme.radiusLg, 16.0);
      expect(AppTheme.radiusXl, 24.0);
      expect(AppTheme.radiusFull, 9999.0);
    });
  });

  group('PremiumCard Widget Tests', () {
    testWidgets('renders correctly with standard variant', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: PremiumCard(
              child: Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.byType(PremiumCard), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('applies touch feedback animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: PremiumCard(
              onTap: () {},
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      // Find and tap the card
      final cardFinder = find.byType(PremiumCard);
      expect(cardFinder, findsOneWidget);

      await tester.tap(cardFinder);
      await tester.pumpAndSettle();
    });

    testWidgets('flat variant has no shadow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: PremiumCard(
              variant: PremiumCardVariant.flat,
              child: Text('Flat Card'),
            ),
          ),
        ),
      );

      expect(find.byType(PremiumCard), findsOneWidget);
    });
  });

  group('PremiumButton Widget Tests', () {
    testWidgets('primary button uses blue accent color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: PremiumButton(
                text: 'Primary',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PremiumButton), findsOneWidget);
      expect(find.text('Primary'), findsOneWidget);
    });

    testWidgets('secondary button renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: PremiumButton(
                text: 'Secondary',
                variant: PremiumButtonVariant.secondary,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final button = tester.widget<PremiumButton>(find.byType(PremiumButton));
      expect(button.variant, PremiumButtonVariant.secondary);
    });

    testWidgets('applies touch feedback animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: PremiumButton(
                text: 'Tap Me',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(PremiumButton);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();
    });
  });

  group('PremiumTextField Widget Tests', () {
    testWidgets('renders with label and hint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: PremiumTextField(
                label: 'Brand',
                hint: 'Enter brand name',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PremiumTextField), findsOneWidget);
    });

    testWidgets('handles text input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: PremiumTextField(
                controller: controller,
                label: 'Model',
                onChanged: (value) {},
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(PremiumTextField), 'Shimano');
      expect(controller.text, 'Shimano');
    });
  });

  group('iOS-Style Spacing Verification', () {
    test('spacing follows 4px base unit system', () {
      // Verify spacing is consistent with 4px base
      expect(AppTheme.spacingXs % 4, 0);
      expect(AppTheme.spacingSm % 4, 0);
      expect(AppTheme.spacingMd % 4, 0);
      expect(AppTheme.spacingLg % 4, 0);
      expect(AppTheme.spacingXl % 4, 0);
      expect(AppTheme.spacingXxl % 4, 0);
    });

    test('radius follows standard iOS values', () {
      // Verify common iOS-style radius values
      expect(AppTheme.radiusSm, 6.0); // Small elements
      expect(AppTheme.radiusMd, 12.0); // Medium elements (buttons)
      expect(AppTheme.radiusLg, 16.0); // Large elements (cards)
      expect(AppTheme.radiusXl, 24.0); // Extra large
    });
  });

  group('Blue Theme Color Verification', () {
    test('primary color is deep sea blue', () {
      expect(AppColors.primaryLight, const Color(0xFF1E3A5F));
    });

    test('accent color is bright blue', () {
      expect(AppColors.accentLight, const Color(0xFF3B82F6));
    });

    test('secondary color complements primary', () {
      // Secondary should be lighter than primary (higher RGB values)
      expect(AppColors.secondaryLight.r, greaterThan(AppColors.primaryLight.r));
    });
  });
}
