import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/widgets/error_view.dart';
import 'package:lurebox/widgets/common/premium_button.dart';

void main() {
  group('ErrorView', () {
    const testStrings = AppStrings.english;

    group('Rendering', () {
      testWidgets('renders correctly with required message', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ErrorView(
                message: 'Something went wrong',
                strings: testStrings,
              ),
            ),
          ),
        );

        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('displays default error title from strings', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ErrorView(
                message: 'Error message',
                strings: testStrings,
              ),
            ),
          ),
        );

        expect(find.text('Error'), findsOneWidget);
      });

      testWidgets('displays custom title when provided', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ErrorView(
                message: 'Error message',
                title: 'Custom Error Title',
                strings: testStrings,
              ),
            ),
          ),
        );

        expect(find.text('Custom Error Title'), findsOneWidget);
        expect(find.text('Error'), findsNothing);
      });

      testWidgets('displays custom icon when provided', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ErrorView(
                message: 'Error message',
                icon: Icons.warning_amber,
                strings: testStrings,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.warning_amber), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsNothing);
      });

      testWidgets('displays icon and title', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ErrorView(
                message: 'Error message',
                strings: testStrings,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Error'), findsOneWidget);
      });

      testWidgets('displays message text', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ErrorView(
                message: 'Error message',
                strings: testStrings,
              ),
            ),
          ),
        );

        expect(find.text('Error message'), findsOneWidget);
      });
    });

    group('Retry Button', () {
      testWidgets('displays retry button when onRetry is provided',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ErrorView(
                message: 'Error message',
                onRetry: () {},
                strings: testStrings,
              ),
            ),
          ),
        );

        // PremiumButton should be present
        expect(find.byType(PremiumButton), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('does not display retry button when onRetry is null',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ErrorView(
                message: 'Error message',
                strings: testStrings,
              ),
            ),
          ),
        );

        expect(find.byType(PremiumButton), findsNothing);
        expect(find.byIcon(Icons.refresh), findsNothing);
      });

      testWidgets('calls onRetry callback when retry button is tapped',
          (tester) async {
        var retryPressed = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ErrorView(
                message: 'Error message',
                onRetry: () => retryPressed = true,
                strings: testStrings,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(PremiumButton));
        await tester.pumpAndSettle();

        expect(retryPressed, isTrue);
      });

      testWidgets('retry button has correct text from strings', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ErrorView(
                message: 'Error message',
                onRetry: () {},
                strings: testStrings,
              ),
            ),
          ),
        );

        // English strings have 'Retry'
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('retry button has refresh icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ErrorView(
                message: 'Error message',
                onRetry: () {},
                strings: testStrings,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });

      testWidgets('retry callback is invoked only once per tap',
          (tester) async {
        var callbackCount = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ErrorView(
                message: 'Error message',
                onRetry: () => callbackCount++,
                strings: testStrings,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(PremiumButton));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(PremiumButton));
        await tester.pumpAndSettle();

        expect(callbackCount, equals(2));
      });
    });

    group('Icon Display', () {
      testWidgets('uses default error icon color', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ErrorView(
                message: 'Error message',
                strings: testStrings,
              ),
            ),
          ),
        );

        final iconFinder = find.byIcon(Icons.error_outline);
        expect(iconFinder, findsOneWidget);

        final iconWidget = tester.widget<Icon>(iconFinder);
        expect(iconWidget.color, equals(TeslaColors.electricBlue));
      });

      testWidgets('default icon has size 64', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ErrorView(
                message: 'Error message',
                strings: testStrings,
              ),
            ),
          ),
        );

        final iconFinder = find.byIcon(Icons.error_outline);
        final iconWidget = tester.widget<Icon>(iconFinder);
        expect(iconWidget.size, equals(64));
      });
    });

    group('With Chinese Strings', () {
      testWidgets('displays Chinese error text', (tester) async {
        const chineseStrings = AppStrings.chinese;
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ErrorView(
                message: '错误信息',
                strings: chineseStrings,
              ),
            ),
          ),
        );

        expect(find.text('加载失败'), findsOneWidget); // Chinese for "Error"
        expect(find.text('错误信息'), findsOneWidget);
      });

      testWidgets('displays Chinese retry text', (tester) async {
        const chineseStrings = AppStrings.chinese;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ErrorView(
                message: '错误信息',
                onRetry: () {},
                strings: chineseStrings,
              ),
            ),
          ),
        );

        expect(find.text('重试'), findsOneWidget); // Chinese for "Retry"
      });
    });
  });

  group('LoadingView', () {
    group('Rendering', () {
      testWidgets('renders circular progress indicator', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: LoadingView(),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('displays message when provided', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: LoadingView(message: 'Loading data...'),
            ),
          ),
        );

        expect(find.text('Loading data...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('message is displayed when provided', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: LoadingView(message: 'Loading...'),
            ),
          ),
        );

        expect(find.text('Loading...'), findsOneWidget);
      });
    });
  });

  group('EmptyView', () {
    group('Rendering', () {
      testWidgets('renders with default icon', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmptyView(message: 'No items'),
            ),
          ),
        );

        expect(find.text('No items'), findsOneWidget);
        expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      });

      testWidgets('renders with custom icon', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmptyView(
                message: 'No items',
                icon: Icons.search_off,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.search_off), findsOneWidget);
        expect(find.byIcon(Icons.inbox_outlined), findsNothing);
      });

      testWidgets('displays message text', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmptyView(message: 'No items'),
            ),
          ),
        );

        expect(find.text('No items'), findsOneWidget);
      });

      testWidgets('default icon has size 72', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmptyView(message: 'No items'),
            ),
          ),
        );

        final iconFinder = find.byIcon(Icons.inbox_outlined);
        final iconWidget = tester.widget<Icon>(iconFinder);
        expect(iconWidget.size, equals(72));
      });
    });

    group('Action Widget', () {
      testWidgets('displays action button when provided', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppEmptyState(
                message: 'No items',
                actionLabel: 'Add Item',
                onAction: () {},
              ),
            ),
          ),
        );

        expect(find.text('No items'), findsOneWidget);
        expect(find.text('Add Item'), findsOneWidget);
        expect(find.byType(PremiumButton), findsOneWidget);
      });

      testWidgets('calls action callback when tapped', (tester) async {
        var actionPressed = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppEmptyState(
                message: 'No items',
                actionLabel: 'Add Item',
                onAction: () => actionPressed = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(PremiumButton));
        await tester.pumpAndSettle();

        expect(actionPressed, isTrue);
      });
    });
  });
}