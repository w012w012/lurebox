import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/widgets/common/premium_card.dart';

void main() {
  group('PremiumCard', () {
    testWidgets('renders child content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumCard(
              child: Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped',
        (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumCard(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PremiumCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not crash without onTap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumCard(
              child: Text('No Tap'),
            ),
          ),
        ),
      );

      expect(find.text('No Tap'), findsOneWidget);
    });

    testWidgets('applies touch feedback animation on press',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumCard(
              onTap: () {},
              child: const Text('Touch Feedback'),
            ),
          ),
        ),
      );

      // Start gesture to trigger press state
      final gesture = await tester.press(find.byType(InkWell));
      await tester.pump();

      // Verify AnimatedContainer exists for scale animation
      expect(find.byType(AnimatedContainer), findsOneWidget);

      // Release
      await gesture.up();
      await tester.pump();
    });

    testWidgets('has InkWell for tappable cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumCard(
              onTap: () {},
              child: const Text('Tappable'),
            ),
          ),
        ),
      );

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('applies accent color splash effect',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumCard(
              onTap: () {},
              child: const Text('Accent Splash'),
            ),
          ),
        ),
      );

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));

      expect(inkWell.splashColor, isNotNull);
      expect(inkWell.highlightColor, isNotNull);
    });

    group('PremiumCardVariant', () {
      testWidgets('flat variant renders', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumCard(
                variant: PremiumCardVariant.flat,
                child: Text('Flat Card'),
              ),
            ),
          ),
        );

        expect(find.text('Flat Card'), findsOneWidget);
      });

      testWidgets('standard variant renders', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumCard(
                child: Text('Standard Card'),
              ),
            ),
          ),
        );

        expect(find.text('Standard Card'), findsOneWidget);
      });

      testWidgets('elevated variant renders', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumCard(
                variant: PremiumCardVariant.elevated,
                child: Text('Elevated Card'),
              ),
            ),
          ),
        );

        expect(find.text('Elevated Card'), findsOneWidget);
      });

      testWidgets('floating variant renders', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumCard(
                variant: PremiumCardVariant.floating,
                child: Text('Floating Card'),
              ),
            ),
          ),
        );

        expect(find.text('Floating Card'), findsOneWidget);
      });
    });

    group('PremiumCardWithTitle', () {
      testWidgets('renders title and subtitle', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumCardWithTitle(
                title: 'Test Title',
                subtitle: 'Test Subtitle',
                child: Text('Content'),
              ),
            ),
          ),
        );

        expect(find.text('Test Title'), findsOneWidget);
        expect(find.text('Test Subtitle'), findsOneWidget);
        expect(find.text('Content'), findsOneWidget);
      });

      testWidgets('renders trailing widget when provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumCardWithTitle(
                title: 'Title',
                trailing: Icon(Icons.arrow_forward),
                child: Text('Content'),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      });

      testWidgets('calls onTap when tapped', (WidgetTester tester) async {
        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PremiumCardWithTitle(
                title: 'Title',
                child: const Text('Content'),
                onTap: () => tapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(PremiumCardWithTitle));
        await tester.pump();

        expect(tapped, isTrue);
      });
    });

    group('PremiumStatCard', () {
      testWidgets('renders title and value', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumStatCard(
                title: 'Total Catches',
                value: '42',
              ),
            ),
          ),
        );

        expect(find.text('Total Catches'), findsOneWidget);
        expect(find.text('42'), findsOneWidget);
      });

      testWidgets('renders unit when provided', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumStatCard(
                title: 'Weight',
                value: '2.5',
                unit: 'kg',
              ),
            ),
          ),
        );

        expect(find.text('kg'), findsOneWidget);
      });

      testWidgets('renders icon when provided', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumStatCard(
                title: 'Catches',
                value: '10',
                icon: Icons.catching_pokemon,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.catching_pokemon), findsOneWidget);
      });

      testWidgets('calls onTap when tapped', (WidgetTester tester) async {
        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PremiumStatCard(
                title: 'Catches',
                value: '10',
                onTap: () => tapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(PremiumStatCard));
        await tester.pump();

        expect(tapped, isTrue);
      });
    });

    group('PremiumListCard', () {
      testWidgets('renders leading, title, and subtitle',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumListCard(
                leading: Icon(Icons.catching_pokemon),
                title: 'Bass',
                subtitle: '30cm',
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.catching_pokemon), findsOneWidget);
        expect(find.text('Bass'), findsOneWidget);
        expect(find.text('30cm'), findsOneWidget);
      });

      testWidgets('renders trailing when provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumListCard(
                leading: Icon(Icons.catching_pokemon),
                title: 'Bass',
                trailing: Icon(Icons.chevron_right),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      });

      testWidgets('calls onTap when tapped', (WidgetTester tester) async {
        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PremiumListCard(
                leading: const Icon(Icons.catching_pokemon),
                title: 'Bass',
                onTap: () => tapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(PremiumListCard));
        await tester.pump();

        expect(tapped, isTrue);
      });
    });

    group('PremiumImageCard', () {
      testWidgets('renders title and subtitle when provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumImageCard(
                imageUrl: 'https://example.com/image.jpg',
                title: 'Big Catch',
                subtitle: '50cm Bass',
              ),
            ),
          ),
        );

        expect(find.text('Big Catch'), findsOneWidget);
        expect(find.text('50cm Bass'), findsOneWidget);
      });

      testWidgets('calls onTap when tapped', (WidgetTester tester) async {
        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PremiumImageCard(
                imageUrl: 'https://example.com/image.jpg',
                onTap: () => tapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(PremiumImageCard));
        await tester.pump();

        expect(tapped, isTrue);
      });

      testWidgets('shows error widget for invalid image',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumImageCard(
                imageUrl: 'invalid-url',
                title: 'Test',
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
      });
    });
  });
}
