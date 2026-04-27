import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/widgets/common/premium_button.dart';

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
          const MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Test Button',
                isFullWidth: true,
              ),
            ),
          ),
        );

        expect(find.byType(PremiumButton), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.text('Test Button'), findsOneWidget);
      });
    });

    group('All Variants', () {
      testWidgets('primary variant renders ElevatedButton', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumButton(
                text: 'Primary',
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

      testWidgets('danger variant renders ElevatedButton', (tester) async {
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

      testWidgets('success variant renders ElevatedButton', (tester) async {
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

        await tester.tap(find.byType(ElevatedButton));
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
              ),
            ),
          ),
        );

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

        expect(find.text('Test Button'), findsOneWidget);
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
