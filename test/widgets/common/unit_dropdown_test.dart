import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/widgets/common/unit_dropdown.dart';

void main() {
  group('UnitDropdown', () {
    testWidgets('displays label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnitDropdown(
              label: 'Length Unit',
              value: 'cm',
              options: const ['cm', 'inch'],
              onUnitChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Length Unit'), findsOneWidget);
    });

    testWidgets('displays current value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnitDropdown(
              label: 'Length Unit',
              value: 'cm',
              options: const ['cm', 'inch'],
              onUnitChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('cm'), findsOneWidget);
    });

    testWidgets('displays all options when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnitDropdown(
              label: 'Length Unit',
              value: 'cm',
              options: const ['cm', 'inch'],
              onUnitChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(find.text('cm'), findsWidgets);
      expect(find.text('inch'), findsWidgets);
    });

    testWidgets('calls onChanged when selection changes',
        (WidgetTester tester) async {
      String? selectedUnit;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnitDropdown(
              label: 'Length Unit',
              value: 'cm',
              options: const ['cm', 'inch'],
              onUnitChanged: (unit) => selectedUnit = unit,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('inch').last);
      await tester.pumpAndSettle();

      expect(selectedUnit, 'inch');
    });

    testWidgets('uses first option when value not in options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnitDropdown(
              label: 'Length Unit',
              value: 'invalid',
              options: const ['cm', 'inch'],
              onUnitChanged: (_) {},
            ),
          ),
        ),
      );

      // Should default to first option
      expect(find.text('cm'), findsOneWidget);
    });
  });
}
