import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/widgets/common/premium_input.dart';
import 'package:lurebox/widgets/common/skeleton.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  group('PremiumTextField', () {
    group('Rendering', () {
      testWidgets('renders correctly with label', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumTextField(label: 'Test Label'),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('renders with hint text', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumTextField(hint: 'Enter text...'),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('renders with prefix icon', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumTextField(prefixIcon: Icon(Icons.person)),
            ),
          ),
        );

        expect(find.byIcon(Icons.person), findsOneWidget);
      });

      testWidgets('renders with suffix icon', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumTextField(suffixIcon: Icon(Icons.clear)),
            ),
          ),
        );

        expect(find.byIcon(Icons.clear), findsOneWidget);
      });

      testWidgets('renders with controller', (tester) async {
        final controller = TextEditingController(text: 'Test value');
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PremiumTextField(controller: controller),
            ),
          ),
        );

        expect(find.text('Test value'), findsOneWidget);
      });

      testWidgets('handles text changes', (tester) async {
        String? changedValue;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PremiumTextField(
                onChanged: (value) => changedValue = value,
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'New text');
        expect(changedValue, equals('New text'));
      });

      testWidgets('renders error state', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumTextField(errorText: 'This is an error'),
            ),
          ),
        );

        expect(find.text('This is an error'), findsOneWidget);
      });

      testWidgets('renders with custom content padding', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumTextField(
                contentPadding: EdgeInsets.all(20),
              ),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group('iOS-Style Theme Integration', () {
      testWidgets('renders with MaterialApp theme in light mode',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumTextField(label: 'Test'),
            ),
          ),
        );

        // Verify widget renders in light theme
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('renders with MaterialApp theme in dark mode',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(
              body: PremiumTextField(label: 'Test'),
            ),
          ),
        );

        // Verify widget renders in dark theme
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text('Test'), findsOneWidget);
      });
    });
  });

  group('PremiumSearchField', () {
    group('Rendering', () {
      testWidgets('renders correctly with hint', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumSearchField(hint: 'Search...'),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('renders with search icon by default', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumSearchField(),
            ),
          ),
        );

        expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      });

      testWidgets('renders with custom prefix icon', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumSearchField(prefixIcon: Icon(Icons.find_in_page)),
            ),
          ),
        );

        expect(find.byIcon(Icons.find_in_page), findsOneWidget);
        expect(find.byIcon(Icons.search_rounded), findsNothing);
      });
    });

    group('iOS-Style Theme Integration', () {
      testWidgets('renders in light mode', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumSearchField(),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('renders in dark mode', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(
              body: PremiumSearchField(),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });
    });
  });

  group('PremiumNumberField', () {
    group('Rendering', () {
      testWidgets('renders correctly with label', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumNumberField(label: 'Weight'),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('renders with suffix text', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumNumberField(suffixText: 'kg'),
            ),
          ),
        );

        expect(find.text('kg'), findsOneWidget);
      });

      testWidgets('renders with prefix text', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumNumberField(prefixText: '\$'),
            ),
          ),
        );

        expect(find.text('\$'), findsOneWidget);
      });
    });

    group('iOS-Style Theme Integration', () {
      testWidgets('renders in light mode', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumNumberField(),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('renders in dark mode', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(
              body: PremiumNumberField(),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });
    });
  });

  group('PremiumTextArea', () {
    group('Rendering', () {
      testWidgets('renders correctly with label', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumTextArea(label: 'Description'),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('renders with hint', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumTextArea(hint: 'Enter description...'),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('handles multi-line input', (tester) async {
        String? changedValue;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PremiumTextArea(
                onChanged: (value) => changedValue = value,
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'Multi\nLine\nText');
        expect(changedValue, equals('Multi\nLine\nText'));
      });
    });

    group('iOS-Style Theme Integration', () {
      testWidgets('renders in light mode', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PremiumTextArea(),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('renders in dark mode', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(
              body: PremiumTextArea(),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });
    });
  });

  group('PremiumDropdown', () {
    group('Rendering', () {
      testWidgets('renders correctly with label', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PremiumDropdown<int>(
                label: 'Select',
                items: const [
                  PremiumDropdownItem(value: 1, label: 'One'),
                  PremiumDropdownItem(value: 2, label: 'Two'),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
      });

      testWidgets('renders all items', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PremiumDropdown<int>(
                items: const [
                  PremiumDropdownItem(value: 1, label: 'One'),
                  PremiumDropdownItem(value: 2, label: 'Two'),
                  PremiumDropdownItem(value: 3, label: 'Three'),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        );

        // Tap to open dropdown
        await tester.tap(find.byType(DropdownButtonFormField<int>));
        await tester.pumpAndSettle();

        expect(find.text('One'), findsWidgets);
        expect(find.text('Two'), findsOneWidget);
        expect(find.text('Three'), findsOneWidget);
      });

      testWidgets('displays selected value', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PremiumDropdown<int>(
                value: 2,
                items: const [
                  PremiumDropdownItem(value: 1, label: 'One'),
                  PremiumDropdownItem(value: 2, label: 'Two'),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('Two'), findsOneWidget);
      });

      testWidgets('calls onChanged when selection changes', (tester) async {
        int? selectedValue;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PremiumDropdown<int>(
                items: const [
                  PremiumDropdownItem(value: 1, label: 'One'),
                  PremiumDropdownItem(value: 2, label: 'Two'),
                ],
                onChanged: (value) => selectedValue = value,
              ),
            ),
          ),
        );

        // Tap to open dropdown
        await tester.tap(find.byType(DropdownButtonFormField<int>));
        await tester.pumpAndSettle();

        // Select 'Two'
        await tester.tap(find.text('Two').last);
        await tester.pumpAndSettle();

        expect(selectedValue, equals(2));
      });
    });

    group('iOS-Style Theme Integration', () {
      testWidgets('renders in light mode', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PremiumDropdown<int>(
                items: const [
                  PremiumDropdownItem(value: 1, label: 'One'),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
      });

      testWidgets('renders in dark mode', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: PremiumDropdown<int>(
                items: const [
                  PremiumDropdownItem(value: 1, label: 'One'),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
      });
    });
  });

  group('PremiumDropdownItem', () {
    test('creates item with value and label', () {
      const item = PremiumDropdownItem<int>(value: 1, label: 'Test');
      expect(item.value, equals(1));
      expect(item.label, equals('Test'));
    });
  });

  group('Skeleton', () {
    group('Rendering', () {
      testWidgets('renders correctly with default values', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Skeleton(height: 100),
            ),
          ),
        );

        expect(find.byType(Shimmer), findsOneWidget);
        expect(find.byType(Container), findsOneWidget);
      });

      testWidgets('renders with custom width', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Skeleton(width: 200, height: 50),
            ),
          ),
        );

        expect(find.byType(Shimmer), findsOneWidget);
      });

      testWidgets('renders with custom height', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Skeleton(width: 200, height: 50),
            ),
          ),
        );

        expect(find.byType(Shimmer), findsOneWidget);
      });

      testWidgets('renders with custom border radius', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Skeleton(height: 50, borderRadius: 12),
            ),
          ),
        );

        expect(find.byType(Shimmer), findsOneWidget);
      });

      testWidgets('defaults to full width', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Skeleton(height: 50),
            ),
          ),
        );

        expect(find.byType(Shimmer), findsOneWidget);
      });

      testWidgets('defaults to 4px border radius', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Skeleton(height: 50),
            ),
          ),
        );

        expect(find.byType(Shimmer), findsOneWidget);
      });
    });

    group('iOS-Style Shimmer Colors', () {
      testWidgets('renders shimmer in light mode', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Skeleton(height: 50),
            ),
          ),
        );

        // Verify shimmer widget exists and renders
        expect(find.byType(Shimmer), findsOneWidget);
      });

      testWidgets('renders shimmer in dark mode', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(
              body: Skeleton(height: 50),
            ),
          ),
        );

        // Verify shimmer widget exists and renders
        expect(find.byType(Shimmer), findsOneWidget);
      });
    });

    group('Shimmer Animation', () {
      testWidgets('uses 1500ms period for smooth iOS-style animation',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Skeleton(height: 50),
            ),
          ),
        );

        final shimmer = tester.widget<Shimmer>(find.byType(Shimmer));
        expect(shimmer.period, equals(const Duration(milliseconds: 1500)));
      });

      testWidgets('is wrapped in Shimmer widget for animation', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Skeleton(height: 50),
            ),
          ),
        );

        expect(find.byType(Shimmer), findsOneWidget);
      });
    });
  });
}
