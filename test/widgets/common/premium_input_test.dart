import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/widgets/common/premium_input.dart';

void main() {
  group('PremiumTextField', () {
    testWidgets('renders with label and hint', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: PremiumTextField(
                label: 'Species',
                hint: 'Enter fish species',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Species'), findsOneWidget);
      expect(find.text('Enter fish species'), findsOneWidget);
    });

    testWidgets('calls onChanged when text entered',
        (WidgetTester tester) async {
      String? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: PremiumTextField(
                onChanged: (value) => changedValue = value,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Bass');
      expect(changedValue, 'Bass');
    });

    testWidgets('calls onSubmitted when submitted',
        (WidgetTester tester) async {
      String? submittedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: PremiumTextField(
                onSubmitted: (value) => submittedValue = value,
                textInputAction: TextInputAction.done,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Trout');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submittedValue, 'Trout');
    });

    testWidgets('shows error text when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: PremiumTextField(
                errorText: 'This field is required',
              ),
            ),
          ),
        ),
      );

      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('is disabled when enabled is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: PremiumTextField(
                enabled: false,
              ),
            ),
          ),
        ),
      );

      final textField =
          tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, false);
    });

    testWidgets('renders with prefix icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: PremiumTextField(
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('renders with suffix icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: PremiumTextField(
                suffixIcon: Icon(Icons.clear),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });
  });

  group('PremiumSearchField', () {
    testWidgets('renders with hint', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: PremiumSearchField(
                hint: 'Search catches...',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Search catches...'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('calls onChanged when text entered',
        (WidgetTester tester) async {
      String? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: PremiumSearchField(
                onChanged: (value) => changedValue = value,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Bass');
      expect(changedValue, 'Bass');
    });
  });

  group('PremiumNumberField', () {
    testWidgets('renders with label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: PremiumNumberField(
                label: 'Length',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Length'), findsOneWidget);
    });

    testWidgets('shows error text when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: PremiumNumberField(
                errorText: 'Invalid number',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Invalid number'), findsOneWidget);
    });

    testWidgets('respects suffixText', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: PremiumNumberField(
                suffixText: 'cm',
              ),
            ),
          ),
        ),
      );

      expect(find.text('cm'), findsOneWidget);
    });
  });

  group('PremiumDropdown', () {
    testWidgets('renders with label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: PremiumDropdown<String>(
                label: 'Unit',
                items: const [
                  PremiumDropdownItem(value: 'cm', label: 'Centimeters'),
                  PremiumDropdownItem(value: 'inch', label: 'Inches'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Unit'), findsOneWidget);
    });

    testWidgets('opens dropdown on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: PremiumDropdown<String>(
                value: 'cm',
                items: const [
                  PremiumDropdownItem(value: 'cm', label: 'Centimeters'),
                  PremiumDropdownItem(value: 'inch', label: 'Inches'),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Dropdown should be open now
      expect(find.byType(DropdownMenuItem<String>), findsWidgets);
    });
  });
}
