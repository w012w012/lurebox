import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/widgets/common/settings_tile.dart';

void main() {
  group('SettingsTile', () {
    testWidgets('displays title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTile(
              icon: Icons.info,
              title: 'About',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('displays subtitle when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTile(
              icon: Icons.info,
              title: 'About',
              subtitle: 'Version 1.0.0',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('About'), findsOneWidget);
      expect(find.text('Version 1.0.0'), findsOneWidget);
    });

    testWidgets('displays leading icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTile(
              icon: Icons.camera,
              title: 'Camera',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.camera), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      var tapCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTile(
              icon: Icons.info,
              title: 'About',
              onTap: () => tapCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SettingsTile));
      expect(tapCount, 1);
    });

    testWidgets('shows chevron when showChevron is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTile(
              icon: Icons.info,
              title: 'About',
              showChevron: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('shows chevron when trailing is null and onTap is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTile(
              icon: Icons.info,
              title: 'About',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('does not show chevron when trailing is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTile(
              icon: Icons.info,
              title: 'About',
              trailing: Switch(value: false, onChanged: (_) {}),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('displays trailing widget when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTile(
              icon: Icons.info,
              title: 'About',
              trailing: const Text('value'),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('value'), findsOneWidget);
    });
  });

  group('SettingsSectionHeader', () {
    testWidgets('displays title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsSectionHeader(
              title: 'General',
            ),
          ),
        ),
      );

      expect(find.text('General'), findsOneWidget);
    });

    testWidgets('displays action widget when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsSectionHeader(
              title: 'General',
              action: TextButton(
                onPressed: () {},
                child: const Text('Add'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Add'), findsOneWidget);
    });
  });

  group('SettingsDivider', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsDivider(),
          ),
        ),
      );

      expect(find.byType(Divider), findsOneWidget);
    });
  });
}
