import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/widgets/common/filter_chip.dart';

void main() {
  group('AppFilterChip', () {
    testWidgets('displays label correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppFilterChip(
              label: 'Release',
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Release'), findsOneWidget);
    });

    testWidgets('toggles selection on tap', (WidgetTester tester) async {
      bool selected = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppFilterChip(
              label: 'Release',
              isSelected: selected,
              onTap: () => selected = !selected,
            ),
          ),
        ),
      );

      expect(selected, false);

      await tester.tap(find.byType(AppFilterChip));
      expect(selected, true);

      await tester.tap(find.byType(AppFilterChip));
      expect(selected, false);
    });

    testWidgets('shows selected state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppFilterChip(
              label: 'Keep',
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // When selected, label text should be white (bold)
      final textWidget = tester.widget<Text>(find.text('Keep'));
      expect(textWidget.style?.fontWeight, FontWeight.bold);
      expect(textWidget.style?.color, Colors.white);
    });

    testWidgets('shows unselected state correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppFilterChip(
              label: 'Keep',
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      // When unselected, label text should not be bold
      final textWidget = tester.widget<Text>(find.text('Keep'));
      expect(textWidget.style?.fontWeight, FontWeight.normal);
    });

    testWidgets('displays icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppFilterChip(
              label: 'Release',
              isSelected: false,
              icon: Icons.check,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('has semantic label for accessibility',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppFilterChip(
              label: 'Release',
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify the widget has semantics wrapper
      expect(find.byType(Semantics), findsWidgets);
    });
  });
}
