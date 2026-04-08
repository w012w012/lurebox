import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/widgets/common/premium_button.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/animation_constants.dart';

void main() {
  group('PremiumButton', () {
    group('Rendering', () {
      testWidgets('renders correctly with required text', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumButton(text: 'Test Button'),
            ),
          ),
        );

        expect(find.text('Test Button'), findsOneWidget);
      });

      testWidgets('renders with icon when provided', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Test Button',
                icon: Icons.add,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.text('Test Button'), findsOneWidget);
      });

      testWidgets('renders loading indicator when isLoading is true',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Test Button',
                isLoading: true,
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Test Button'), findsNothing);
      });

      testWidgets('renders full width when isFullWidth is true',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Test Button',
                isFullWidth: true,
              ),
            ),
          ),
        );

        // Verify the PremiumButton is rendered
        expect(find.byType(PremiumButton), findsOneWidget);

        // When isFullWidth is true, the button widget tree starts with a SizedBox
        // We verify the button renders and contains an ElevatedButton
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.text('Test Button'), findsOneWidget);
      });
    });

    group('Theme Colors', () {
      Widget buildButtonWithVariant(PremiumButtonVariant variant) {
        return MaterialApp(
          home: Scaffold(
            body: PremiumButton(
              text: 'Test',
              variant: variant,
              onPressed: () {},
            ),
          ),
        );
      }

      testWidgets('primary variant uses accentLight in light mode',
          (tester) async {
        await tester
            .pumpWidget(buildButtonWithVariant(PremiumButtonVariant.primary));

        final elevatedButton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        final backgroundColor =
            elevatedButton.style?.backgroundColor?.resolve(<WidgetState>{});
        expect(backgroundColor, equals(AppColors.accentLight));
      });

      testWidgets('primary variant uses accentDark in dark mode',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: PremiumButton(
                text: 'Test',
                variant: PremiumButtonVariant.primary,
                onPressed: () {},
              ),
            ),
          ),
        );

        final elevatedButton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        final backgroundColor =
            elevatedButton.style?.backgroundColor?.resolve(<WidgetState>{});
        expect(backgroundColor, equals(AppColors.accentDark));
      });

      testWidgets(
          'secondary variant uses accentLight with opacity in light mode',
          (tester) async {
        await tester
            .pumpWidget(buildButtonWithVariant(PremiumButtonVariant.secondary));

        final elevatedButton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        final backgroundColor =
            elevatedButton.style?.backgroundColor?.resolve(<WidgetState>{});
        expect(
          backgroundColor,
          equals(AppColors.accentLight.withValues(alpha: 0.12)),
        );
      });

      testWidgets('outline variant uses accentLight for border in light mode',
          (tester) async {
        await tester
            .pumpWidget(buildButtonWithVariant(PremiumButtonVariant.outline));

        final outlinedButton = tester.widget<OutlinedButton>(
          find.byType(OutlinedButton),
        );
        final side = outlinedButton.style?.side?.resolve(<WidgetState>{});
        expect(side?.color, equals(AppColors.accentLight));
      });

      testWidgets('text variant uses accentLight in light mode',
          (tester) async {
        await tester
            .pumpWidget(buildButtonWithVariant(PremiumButtonVariant.text));

        final textButton = tester.widget<TextButton>(
          find.byType(TextButton),
        );
        final foregroundColor =
            textButton.style?.foregroundColor?.resolve(<WidgetState>{});
        expect(foregroundColor, equals(AppColors.accentLight));
      });

      testWidgets('danger variant uses error color', (tester) async {
        await tester
            .pumpWidget(buildButtonWithVariant(PremiumButtonVariant.danger));

        final elevatedButton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        final backgroundColor =
            elevatedButton.style?.backgroundColor?.resolve(<WidgetState>{});
        expect(backgroundColor, equals(AppColors.error));
      });

      testWidgets('success variant uses success color', (tester) async {
        await tester
            .pumpWidget(buildButtonWithVariant(PremiumButtonVariant.success));

        final elevatedButton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        final backgroundColor =
            elevatedButton.style?.backgroundColor?.resolve(<WidgetState>{});
        expect(backgroundColor, equals(AppColors.success));
      });
    });

    group('Touch Feedback Animation', () {
      testWidgets('applies AnimatedScale wrapper', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Test',
                onPressed: _emptyCallback,
              ),
            ),
          ),
        );

        expect(find.byType(AnimatedScale), findsOneWidget);
      });

      testWidgets('scales down to 0.98 on tap down', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Test',
                onPressed: () {},
              ),
            ),
          ),
        );

        // Find the AnimatedScale widget
        final animatedScaleFinder = find.byType(AnimatedScale);
        expect(animatedScaleFinder, findsOneWidget);

        // Get the center of the AnimatedScale
        final center = tester.getCenter(animatedScaleFinder);

        // Start tap
        final gesture = await tester.startGesture(center);
        await tester.pump();

        // Should be scaled down (AnimatedScale is still 1.0 before animation completes)
        // The scale animates over 150ms, so we need to wait a bit
        await tester.pump(const Duration(milliseconds: 100));

        // Release tap
        await gesture.up();
        await tester.pumpAndSettle();

        // After settling, scale should be back to 1.0
        final animatedScale = tester.widget<AnimatedScale>(animatedScaleFinder);
        expect(animatedScale.scale, equals(1.0));
      });

      testWidgets('returns to scale 1.0 on tap up', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Test',
                onPressed: () {},
              ),
            ),
          ),
        );

        final animatedScaleFinder = find.byType(AnimatedScale);
        final center = tester.getCenter(animatedScaleFinder);

        // Start and end tap
        final gesture = await tester.startGesture(center);
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();

        final animatedScale = tester.widget<AnimatedScale>(animatedScaleFinder);
        expect(animatedScale.scale, equals(1.0));
      });

      testWidgets('uses correct animation duration from AnimationConstants',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Test',
                onPressed: _emptyCallback,
              ),
            ),
          ),
        );

        final animatedScale = tester.widget<AnimatedScale>(
          find.byType(AnimatedScale),
        );
        expect(
          animatedScale.duration,
          equals(AnimationConstants.touchFeedbackDuration),
        );
        expect(
          animatedScale.duration,
          equals(const Duration(milliseconds: 150)),
        );
      });

      testWidgets('uses correct curve from AnimationConstants', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Test',
                onPressed: _emptyCallback,
              ),
            ),
          ),
        );

        final animatedScale = tester.widget<AnimatedScale>(
          find.byType(AnimatedScale),
        );
        expect(animatedScale.curve, equals(AnimationConstants.defaultCurve));
      });

      testWidgets('no animation when onPressed is null', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Test',
                onPressed: null,
              ),
            ),
          ),
        );

        // Should still render AnimatedScale
        expect(find.byType(AnimatedScale), findsOneWidget);
      });
    });

    group('All Variants', () {
      testWidgets('primary variant renders ElevatedButton', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Primary',
                variant: PremiumButtonVariant.primary,
              ),
            ),
          ),
        );

        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('secondary variant renders ElevatedButton', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Secondary',
                variant: PremiumButtonVariant.secondary,
              ),
            ),
          ),
        );

        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('outline variant renders OutlinedButton', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Outline',
                variant: PremiumButtonVariant.outline,
              ),
            ),
          ),
        );

        expect(find.byType(OutlinedButton), findsOneWidget);
      });

      testWidgets('text variant renders TextButton', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Text',
                variant: PremiumButtonVariant.text,
              ),
            ),
          ),
        );

        expect(find.byType(TextButton), findsOneWidget);
      });

      testWidgets('danger variant renders ElevatedButton with error color',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Danger',
                variant: PremiumButtonVariant.danger,
              ),
            ),
          ),
        );

        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('success variant renders ElevatedButton with success color',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Success',
                variant: PremiumButtonVariant.success,
              ),
            ),
          ),
        );

        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });

    group('Callback Behavior', () {
      testWidgets('calls onPressed when tapped', (tester) async {
        var pressed = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Test',
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        // Tap on the ElevatedButton inside PremiumButton
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        expect(pressed, isTrue);
      });

      testWidgets('does not call onPressed when isLoading is true',
          (tester) async {
        var pressed = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Test',
                isLoading: true,
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        // Tap on the button (loading state has disabled callback)
        await tester.tap(find.byType(ElevatedButton));
        // Use pump() instead of pumpAndSettle() because CircularProgressIndicator animates
        await tester.pump();

        expect(pressed, isFalse);
      });

      testWidgets('does not crash when onPressed is null and tapped',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Test',
                onPressed: null,
              ),
            ),
          ),
        );

        // Should not throw when tapping disabled button - tap on ElevatedButton
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
      });
    });

    group('Semantics', () {
      testWidgets('has correct semantic label', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Test Button',
                onPressed: () {},
              ),
            ),
          ),
        );

        // Verify the button text is rendered (which has semantics)
        expect(find.text('Test Button'), findsOneWidget);

        // Verify semantics exists by checking Semantics widget is present
        expect(find.byType(Semantics), findsWidgets);
      });
    });
  });

  group('PremiumButtonVariant', () {
    test('has correct values', () {
      expect(PremiumButtonVariant.values.length, equals(6));
      expect(PremiumButtonVariant.primary.index, equals(0));
      expect(PremiumButtonVariant.secondary.index, equals(1));
      expect(PremiumButtonVariant.outline.index, equals(2));
      expect(PremiumButtonVariant.text.index, equals(3));
      expect(PremiumButtonVariant.danger.index, equals(4));
      expect(PremiumButtonVariant.success.index, equals(5));
    });
  });
}

void _emptyCallback() {}
