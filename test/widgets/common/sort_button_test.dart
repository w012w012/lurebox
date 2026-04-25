import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/widgets/common/sort_button.dart';

void main() {
  group('AppSortButton', () {
    testWidgets('displays label correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSortButton(
              label: 'Date',
              isSelected: false,
              isAsc: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Date'), findsOneWidget);
    });

    testWidgets('shows ascending arrow when selected and isAsc',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSortButton(
              label: 'Date',
              isSelected: true,
              isAsc: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsNothing);
    });

    testWidgets('shows descending arrow when selected and not isAsc',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSortButton(
              label: 'Date',
              isSelected: true,
              isAsc: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsNothing);
    });

    testWidgets('does not show arrow when not selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSortButton(
              label: 'Date',
              isSelected: false,
              isAsc: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_upward), findsNothing);
      expect(find.byIcon(Icons.arrow_downward), findsNothing);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      var tapCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSortButton(
              label: 'Date',
              isSelected: false,
              isAsc: true,
              onTap: () => tapCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppSortButton));
      expect(tapCount, 1);

      await tester.tap(find.byType(AppSortButton));
      expect(tapCount, 2);
    });

    testWidgets('has semantic button role for accessibility',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSortButton(
              label: 'Date',
              isSelected: true,
              isAsc: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Semantics), findsWidgets);
    });
  });
}
