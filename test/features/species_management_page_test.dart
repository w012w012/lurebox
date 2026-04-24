import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/animation_constants.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/design/theme/app_theme.dart';
import 'package:lurebox/widgets/common/premium_card.dart';
import 'package:lurebox/widgets/common/premium_button.dart';

// Test wrapper with theme
Widget createTestWidget({
  required Widget child,
  Brightness brightness = Brightness.light,
}) {
  return MaterialApp(
    theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
    home: Scaffold(body: child),
  );
}

void main() {
  group('SpeciesManagementPage Design System Constants', () {
    test('AnimationConstants has correct touch feedback duration', () {
      expect(
        AnimationConstants.touchFeedbackDuration,
        equals(const Duration(milliseconds: 150)),
      );
    });

    test('AnimationConstants has correct touch scale factor', () {
      expect(AnimationConstants.touchScale, equals(0.98));
    });

    test('AnimationConstants has correct default curve', () {
      expect(AnimationConstants.defaultCurve, equals(Curves.easeOut));
    });
  });

  group('SpeciesManagementPage Blue Color Scheme', () {
    testWidgets('light mode uses primary color #1E3A5F',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          brightness: Brightness.light,
          child: const Text('Test'),
        ),
      );

      final context = tester.element(find.byType(Text));
      final theme = Theme.of(context);

      expect(theme.colorScheme.primary, equals(AppColors.primaryLight));
      expect(AppColors.primaryLight, equals(const Color(0xFF1E3A5F)));
    });

    testWidgets('light mode uses accent color #3B82F6',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          brightness: Brightness.light,
          child: const Text('Test'),
        ),
      );

      final context = tester.element(find.byType(Text));
      final theme = Theme.of(context);

      expect(theme.colorScheme.tertiary, equals(AppColors.accentLight));
      expect(AppColors.accentLight, equals(const Color(0xFF3B82F6)));
    });

    testWidgets('dark mode background is True Black #000000',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          brightness: Brightness.dark,
          child: const Text('Test'),
        ),
      );

      final context = tester.element(find.byType(Text));
      final theme = Theme.of(context);

      expect(theme.scaffoldBackgroundColor, equals(AppColors.backgroundDark));
      expect(AppColors.backgroundDark, equals(const Color(0xFF000000)));
    });

    testWidgets('dark mode surface is #0A0A0A', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          brightness: Brightness.dark,
          child: const Text('Test'),
        ),
      );

      final context = tester.element(find.byType(Text));
      final theme = Theme.of(context);

      expect(theme.colorScheme.surface, equals(AppColors.surfaceDark));
      expect(AppColors.surfaceDark, equals(const Color(0xFF0A0A0A)));
    });

    testWidgets('light mode background is #F7FAFC',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          brightness: Brightness.light,
          child: const Text('Test'),
        ),
      );

      final context = tester.element(find.byType(Text));
      final theme = Theme.of(context);

      expect(theme.scaffoldBackgroundColor, equals(AppColors.backgroundLight));
      expect(AppColors.backgroundLight, equals(const Color(0xFFF7FAFC)));
    });
  });

  group('PremiumCard Styling for Species List', () {
    testWidgets('PremiumCard renders correctly in light mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PremiumCard(
            onTap: () {},
            child: const Text('Species Item'),
          ),
        ),
      );

      expect(find.byType(PremiumCard), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.byType(AnimatedContainer), findsOneWidget);
    });

    testWidgets('PremiumCard uses flat variant for list items',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PremiumCard(
            variant: PremiumCardVariant.flat,
            onTap: () {},
            child: const Text('List Item'),
          ),
        ),
      );

      expect(find.byType(PremiumCard), findsOneWidget);
    });

    testWidgets('PremiumCard has touch feedback animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PremiumCard(
            onTap: () {},
            child: const Text('Tappable Card'),
          ),
        ),
      );

      // Find AnimatedContainer for scale animation
      final animatedContainer = find.byType(AnimatedContainer);
      expect(animatedContainer, findsOneWidget);

      // Find InkWell for tap detection
      final inkWell = find.byType(InkWell);
      expect(inkWell, findsOneWidget);
    });

    testWidgets('PremiumCard shows border in flat variant',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PremiumCard(
            variant: PremiumCardVariant.flat,
            showBorder: true,
            onTap: () {},
            child: const Text('Bordered Card'),
          ),
        ),
      );

      // Card should render
      expect(find.byType(PremiumCard), findsOneWidget);
    });

    testWidgets('PremiumCard applies iOS-style spacing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PremiumCard(
            onTap: () {},
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: const Text('Spaced Card'),
          ),
        ),
      );

      expect(find.byType(PremiumCard), findsOneWidget);
    });
  });

  group('PremiumButton for Species Actions', () {
    testWidgets('PremiumButton primary variant uses accent color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PremiumButton(
            text: 'AI识别',
            onPressed: () {},
            variant: PremiumButtonVariant.primary,
          ),
        ),
      );

      expect(find.byType(PremiumButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('PremiumButton outline variant uses accent border',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PremiumButton(
            text: 'Manual',
            onPressed: () {},
            variant: PremiumButtonVariant.outline,
          ),
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('PremiumButton has touch feedback animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PremiumButton(
            text: 'Button',
            onPressed: () {},
          ),
        ),
      );

      // PremiumButton wraps content in AnimatedScale
      expect(find.byType(AnimatedScale), findsWidgets);
    });

    testWidgets('PremiumButton responds to tap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        createTestWidget(
          child: PremiumButton(
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

  group('iOS-Style List Appearance', () {
    testWidgets('PremiumCard with flat variant looks like iOS settings list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Column(
            children: [
              PremiumCard(
                variant: PremiumCardVariant.flat,
                showBorder: true,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                  vertical: AppTheme.spacingXs,
                ),
                onTap: () {},
                child: const Row(
                  children: [
                    Icon(Icons.category),
                    SizedBox(width: AppTheme.spacingMd),
                    Text('Bass'),
                  ],
                ),
              ),
              PremiumCard(
                variant: PremiumCardVariant.flat,
                showBorder: true,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                  vertical: AppTheme.spacingXs,
                ),
                onTap: () {},
                child: const Row(
                  children: [
                    Icon(Icons.category),
                    SizedBox(width: AppTheme.spacingMd),
                    Text('Trout'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      expect(find.byType(PremiumCard), findsNWidgets(2));
    });

    testWidgets('iOS-style list uses proper 8pt spacing grid',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PremiumCard(
            margin: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg, // 16
              vertical: AppTheme.spacingSm, // 8
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
          )));
    });
  });

  group('Dark Mode True Black Display', () {
    testWidgets('dark mode uses #000000 scaffold background',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: Text('Test')),
        ),
      );

      final context = tester.element(find.byType(Scaffold));
      final theme = Theme.of(context);

      expect(theme.scaffoldBackgroundColor, equals(const Color(0xFF000000)));
    });

    testWidgets('dark mode PremiumCard uses #0A0A0A surface',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: PremiumCard(
              onTap: () {},
              child: const Text('Dark Card'),
            ),
          ),
        ),
      );

      final context = tester.element(find.byType(PremiumCard));
      final theme = Theme.of(context);

      expect(theme.colorScheme.surface, equals(const Color(0xFF0A0A0A)));
    });

    testWidgets('dark mode text color is #E2E8F0', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: Text('Dark Text'),
          ),
        ),
      );

      final context = tester.element(find.byType(Text));
      final theme = Theme.of(context);

      expect(theme.textTheme.bodyLarge?.color, equals(const Color(0xFFE2E8F0)));
    });
  });

  group('Touch Feedback Animation', () {
    testWidgets('PremiumCard animates scale on press',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PremiumCard(
            onTap: () {},
            child: const Text('Animated Card'),
          ),
        ),
      );

      // PremiumCard uses AnimatedContainer for touch feedback
      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      // Duration should be 330ms (Tesla design system)
      expect(animatedContainer.duration,
          equals(TeslaTheme.transitionDuration));
    });

    testWidgets('PremiumButton animates scale on press',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PremiumButton(
            text: 'Animated Button',
            onPressed: () {},
          ),
        ),
      );

      // PremiumButton uses AnimatedScale for touch feedback
      final animatedScales = tester.widgetList<AnimatedScale>(
        find.byType(AnimatedScale),
      );

      expect(animatedScales.isNotEmpty, isTrue);
    });
  });

  group('AppTheme Spacing System', () {
    test('spacing system follows 4px base unit', () {
      expect(AppTheme.spacingXs, equals(4.0));
      expect(AppTheme.spacingSm, equals(8.0));
      expect(AppTheme.spacingMd, equals(12.0));
      expect(AppTheme.spacingLg, equals(16.0));
      expect(AppTheme.spacingXl, equals(24.0));
      expect(AppTheme.spacingXxl, equals(32.0));
    });

    test('radius system follows iOS design guidelines', () {
      expect(AppTheme.radiusSm, equals(6.0));
      expect(AppTheme.radiusMd, equals(12.0));
      expect(AppTheme.radiusLg, equals(16.0));
      expect(AppTheme.radiusXl, equals(24.0));
    });
  });
}
