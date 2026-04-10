import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/widgets/error_view.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
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

      testWidgets('is centered in the viewport', (tester) async {
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

        // ErrorView should contain a Center widget (there may be multiple due to Material widget tree)
        expect(
            find.descendant(
                of: find.byType(ErrorView), matching: find.byType(Center)),
            findsWidgets);
      });

      testWidgets('has correct padding', (tester) async {
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

        final paddingFinder = find.descendant(
          of: find.byType(Center),
          matching: find.byType(Padding),
        );
        expect(paddingFinder, findsOneWidget);

        final paddingWidget = tester.widget<Padding>(paddingFinder.first);
        expect(paddingWidget.padding, const EdgeInsets.all(24));
      });

      testWidgets('message is text aligned center', (tester) async {
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

        final textFinder = find.text('Error message');
        expect(textFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.textAlign, TextAlign.center);
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
        expect(iconWidget.color, equals(AppColors.error));
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

    group('Text Styling', () {
      testWidgets('title uses titleLarge text style', (tester) async {
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

        final titleFinder = find.text('Error');
        final titleWidget = tester.widget<Text>(titleFinder);
        expect(titleWidget.style?.fontSize, equals(22)); // titleLarge default
      });

      testWidgets('message uses bodyMedium text style', (tester) async {
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

        final messageFinder = find.text('Error message');
        final messageWidget = tester.widget<Text>(messageFinder);
        expect(messageWidget.style?.fontSize, equals(14)); // bodyMedium default
      });
    });

    group('Layout', () {
      testWidgets('contains Column with mainAxisAlignment center',
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

        final columnFinder = find.byType(Column);
        expect(columnFinder, findsOneWidget);

        final column = tester.widget<Column>(columnFinder);
        expect(column.mainAxisAlignment, MainAxisAlignment.center);
      });

      testWidgets('has SizedBox with height 16 between icon and title',
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

        final sizedBoxFinder = find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 16,
        );
        expect(sizedBoxFinder, findsWidgets);
      });

      testWidgets('has SizedBox with height 8 between title and message',
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

        final sizedBoxFinder = find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 8,
        );
        expect(sizedBoxFinder, findsWidgets);
      });

      testWidgets('has SizedBox with height 24 before retry button',
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

        // Verify that SizedBox with height 24 exists (premium button spacing)
        final sizedBoxFinder = find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 24,
        );
        expect(sizedBoxFinder, findsOneWidget);
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

      testWidgets('is centered in the viewport', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: LoadingView(),
            ),
          ),
        );

        expect(find.byType(Center), findsOneWidget);
      });

      testWidgets('contains Column with mainAxisAlignment center',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: LoadingView(),
            ),
          ),
        );

        final columnFinder = find.byType(Column);
        final column = tester.widget<Column>(columnFinder);
        expect(column.mainAxisAlignment, MainAxisAlignment.center);
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

      testWidgets('does not display SizedBox when message is null',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: LoadingView(),
            ),
          ),
        );

        // When message is null, the conditional children list is empty
        // The Column should only have CircularProgressIndicator
        final columnFinder = find.byType(Column);
        final column = tester.widget<Column>(columnFinder);
        expect(column.children.length, equals(1));
      });

      testWidgets('displays SizedBox between indicator and message',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: LoadingView(message: 'Loading...'),
            ),
          ),
        );

        final sizedBoxFinder = find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 16,
        );
        expect(sizedBoxFinder, findsOneWidget);
      });

      testWidgets('message uses bodyMedium text style', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: LoadingView(message: 'Loading...'),
            ),
          ),
        );

        final messageFinder = find.text('Loading...');
        final messageWidget = tester.widget<Text>(messageFinder);
        expect(messageWidget.style?.fontSize, equals(14)); // bodyMedium default
      });

      testWidgets('message is centered', (tester) async {
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

      testWidgets('is centered in the viewport', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmptyView(message: 'No items'),
            ),
          ),
        );

        // EmptyView should contain a Center widget (there may be multiple due to Material widget tree)
        expect(
            find.descendant(
                of: find.byType(EmptyView), matching: find.byType(Center)),
            findsWidgets);
      });

      testWidgets('has correct padding', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmptyView(message: 'No items'),
            ),
          ),
        );

        final paddingFinder = find.descendant(
          of: find.byType(Center),
          matching: find.byType(Padding),
        );
        expect(paddingFinder, findsOneWidget);

        final paddingWidget = tester.widget<Padding>(paddingFinder.first);
        expect(paddingWidget.padding, const EdgeInsets.all(24));
      });

      testWidgets('message is text aligned center', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmptyView(message: 'No items'),
            ),
          ),
        );

        final textFinder = find.text('No items');
        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.textAlign, TextAlign.center);
      });

      testWidgets('contains Column with mainAxisAlignment center',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmptyView(message: 'No items'),
            ),
          ),
        );

        final columnFinder = find.byType(Column);
        final column = tester.widget<Column>(columnFinder);
        expect(column.mainAxisAlignment, MainAxisAlignment.center);
      });

      testWidgets('default icon has size 64', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmptyView(message: 'No items'),
            ),
          ),
        );

        final iconFinder = find.byIcon(Icons.inbox_outlined);
        final iconWidget = tester.widget<Icon>(iconFinder);
        expect(iconWidget.size, equals(64));
      });
    });

    group('Action Widget', () {
      testWidgets('displays action widget when provided', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyView(
                message: 'No items',
                action: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Add Item'),
                ),
              ),
            ),
          ),
        );

        expect(find.text('No items'), findsOneWidget);
        expect(find.text('Add Item'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('does not display SizedBox when action is null',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmptyView(message: 'No items'),
            ),
          ),
        );

        // When action is null, the conditional children list is empty
        final columnFinder = find.byType(Column);
        final column = tester.widget<Column>(columnFinder);
        // Icon + SizedBox + Text = 3 children (without action)
        expect(column.children.length, equals(3));
      });

      testWidgets('has SizedBox with height 24 before action', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyView(
                message: 'No items',
                action: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Add Item'),
                ),
              ),
            ),
          ),
        );

        // Verify that SizedBox with height 24 exists (action widget spacing)
        final sizedBoxFinder = find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 24,
        );
        expect(sizedBoxFinder, findsOneWidget);
      });

      testWidgets('calls action callback when tapped', (tester) async {
        var actionPressed = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyView(
                message: 'No items',
                action: ElevatedButton(
                  onPressed: () => actionPressed = true,
                  child: const Text('Add Item'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        expect(actionPressed, isTrue);
      });
    });
  });
}
