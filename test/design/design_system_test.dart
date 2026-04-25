import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/animation_constants.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/design/theme/app_theme.dart';
import 'package:lurebox/widgets/common/premium_card.dart';
import 'package:lurebox/widgets/common/premium_button.dart';

Widget _wrapInTheme(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
    home: Scaffold(body: child),
  );
}

void main() {
  group('AnimationConstants', () {
    test('touch feedback duration is 150ms', () {
      expect(
        AnimationConstants.touchFeedbackDuration,
        equals(const Duration(milliseconds: 150)),
      );
    });

    test('touch scale factor is 0.98', () {
      expect(AnimationConstants.touchScale, equals(0.98));
    });

    test('default curve is easeOut', () {
      expect(AnimationConstants.defaultCurve, equals(Curves.easeOut));
    });
  });

  group('AppColors - Theme Integration', () {
    testWidgets('light theme wires AppColors to colorScheme', (tester) async {
      await tester.pumpWidget(
        _wrapInTheme(const Text('Test'), brightness: Brightness.light),
      );
      final context = tester.element(find.byType(Text));
      final scheme = Theme.of(context).colorScheme;

      expect(scheme.primary, equals(AppColors.primaryLight));
      expect(scheme.tertiary, equals(AppColors.accentLight));
      expect(
        Theme.of(context).scaffoldBackgroundColor,
        equals(AppColors.backgroundLight),
      );
    });

    testWidgets('dark theme wires AppColors to colorScheme', (tester) async {
      await tester.pumpWidget(
        _wrapInTheme(const Text('Test'), brightness: Brightness.dark),
      );
      final context = tester.element(find.byType(Text));
      final scheme = Theme.of(context).colorScheme;

      expect(scheme.primary, equals(AppColors.primaryDark));
      expect(scheme.tertiary, equals(AppColors.accentDark));
      expect(
        Theme.of(context).scaffoldBackgroundColor,
        equals(AppColors.backgroundDark),
      );
      expect(scheme.surface, equals(AppColors.surfaceDark));
    });

    testWidgets('light theme primary differs from dark mode primary constant',
        (tester) async {
      await tester.pumpWidget(
        _wrapInTheme(const Text('Test'), brightness: Brightness.light),
      );
      final context = tester.element(find.byType(Text));
      final lightPrimary = Theme.of(context).colorScheme.primary;

      // Verify the resolved primary is the light constant, not the dark one
      expect(lightPrimary, equals(AppColors.primaryLight));
      expect(lightPrimary, isNot(equals(AppColors.primaryDark)));
    });
  });

  group('PremiumCard Styling', () {
    testWidgets('renders with InkWell and AnimatedContainer', (tester) async {
      await tester.pumpWidget(
        _wrapInTheme(
          PremiumCard(onTap: () {}, child: const Text('Card')),
        ),
      );

      expect(find.byType(PremiumCard), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.byType(AnimatedContainer), findsOneWidget);
    });

    testWidgets('flat variant renders', (tester) async {
      await tester.pumpWidget(
        _wrapInTheme(
          PremiumCard(
            variant: PremiumCardVariant.flat,
            onTap: () {},
            child: const Text('Flat'),
          ),
        ),
      );
      expect(find.byType(PremiumCard), findsOneWidget);
    });

    testWidgets('flat variant with border renders', (tester) async {
      await tester.pumpWidget(
        _wrapInTheme(
          PremiumCard(
            variant: PremiumCardVariant.flat,
            showBorder: true,
            onTap: () {},
            child: const Text('Bordered'),
          ),
        ),
      );
      expect(find.byType(PremiumCard), findsOneWidget);
    });

    testWidgets('accepts custom padding', (tester) async {
      await tester.pumpWidget(
        _wrapInTheme(
          PremiumCard(
            onTap: () {},
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: const Text('Padded'),
          ),
        ),
      );
      expect(find.byType(PremiumCard), findsOneWidget);
    });

    testWidgets('AnimatedContainer uses TeslaTheme transition duration',
        (tester) async {
      await tester.pumpWidget(
        _wrapInTheme(
          PremiumCard(onTap: () {}, child: const Text('Card')),
        ),
      );
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(container.duration, equals(TeslaTheme.transitionDuration));
    });

    testWidgets('multiple flat cards render in a list', (tester) async {
      await tester.pumpWidget(
        _wrapInTheme(
          Column(
            children: [
              PremiumCard(
                variant: PremiumCardVariant.flat,
                showBorder: true,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                  vertical: AppTheme.spacingXs,
                ),
                onTap: () {},
                child: const Text('Item 1'),
              ),
              PremiumCard(
                variant: PremiumCardVariant.flat,
                showBorder: true,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                  vertical: AppTheme.spacingXs,
                ),
                onTap: () {},
                child: const Text('Item 2'),
              ),
            ],
          ),
        ),
      );
      expect(find.byType(PremiumCard), findsNWidgets(2));
    });

    testWidgets('respects margin property', (tester) async {
      await tester.pumpWidget(
        _wrapInTheme(
          PremiumCard(
            margin: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg,
              vertical: AppTheme.spacingSm,
            ),
            onTap: () {},
            child: const Text('Item'),
          ),
        ),
      );
      final card = tester.widget<PremiumCard>(find.byType(PremiumCard));
      expect(
        card.margin,
        equals(const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLg,
          vertical: AppTheme.spacingSm,
        )),
      );
    });
  });

  group('PremiumButton', () {
    testWidgets('primary variant renders as ElevatedButton', (tester) async {
      await tester.pumpWidget(
        _wrapInTheme(
          PremiumButton(
            text: 'Primary',
            onPressed: () {},
            variant: PremiumButtonVariant.primary,
          ),
        ),
      );
      expect(find.byType(PremiumButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('outline variant renders as OutlinedButton', (tester) async {
      await tester.pumpWidget(
        _wrapInTheme(
          PremiumButton(
            text: 'Outline',
            onPressed: () {},
            variant: PremiumButtonVariant.outline,
          ),
        ),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('has AnimatedScale for touch feedback', (tester) async {
      await tester.pumpWidget(
        _wrapInTheme(
          PremiumButton(text: 'Button', onPressed: () {}),
        ),
      );
      expect(find.byType(AnimatedScale), findsWidgets);
    });

    testWidgets('responds to tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrapInTheme(
          PremiumButton(
            text: 'Tap Me',
            onPressed: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.byType(PremiumButton));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('Dark Mode True Black Display', () {
    testWidgets('scaffold uses AppColors.backgroundDark', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: Text('Test')),
        ),
      );
      final context = tester.element(find.byType(Scaffold));
      expect(
        Theme.of(context).scaffoldBackgroundColor,
        equals(AppColors.backgroundDark),
      );
    });

    testWidgets('PremiumCard inherits dark surface color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: PremiumCard(onTap: () {}, child: const Text('Card')),
          ),
        ),
      );
      final context = tester.element(find.byType(PremiumCard));
      expect(
        Theme.of(context).colorScheme.surface,
        equals(AppColors.surfaceDark),
      );
    });

    testWidgets('text color is light enough for dark background',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: Text('Dark Text')),
        ),
      );
      final context = tester.element(find.byType(Text));
      final textColor = Theme.of(context).textTheme.bodyLarge?.color;
      expect(textColor, isNotNull);
      // Text must be lighter than mid-grey for readability on true black
      expect(textColor!.computeLuminance(), greaterThan(0.5));
    });
  });

  group('AppTheme Spacing System', () {
    test('follows 4px base unit', () {
      expect(AppTheme.spacingXs, equals(4.0));
      expect(AppTheme.spacingSm, equals(8.0));
      expect(AppTheme.spacingMd, equals(12.0));
      expect(AppTheme.spacingLg, equals(16.0));
      expect(AppTheme.spacingXl, equals(24.0));
      expect(AppTheme.spacingXxl, equals(32.0));
    });

    test('radius follows iOS design guidelines', () {
      expect(AppTheme.radiusSm, equals(6.0));
      expect(AppTheme.radiusMd, equals(12.0));
      expect(AppTheme.radiusLg, equals(16.0));
      expect(AppTheme.radiusXl, equals(24.0));
    });
  });
}
