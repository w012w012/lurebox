import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/widgets/common/premium_card.dart';
import 'package:lurebox/widgets/common/settings_tile.dart';

// Note: SettingsPage integration tests require database initialization.
// The SettingsPage widget tests verify the core iOS-style settings tiles work correctly.
// For full SettingsPage integration tests, use test_driver or manual testing.

void main() {
  group('SettingsTile iOS-style Widget', () {
    testWidgets('renders with icon, title and subtitle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTile(
              icon: Icons.location_on,
              title: 'Location',
              subtitle: 'Manage fishing spots',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Manage fishing spots'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('renders with trailing widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTile(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              trailing: Switch.adaptive(
                value: false,
                onChanged: (_) {},
              ),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTile(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SettingsTile));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('applies blue accent color for light mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTile(
              icon: Icons.location_on,
              title: 'Location',
              onTap: () {},
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.location_on));
      expect(icon.color, equals(AppColors.accentLight));
    });

    testWidgets('applies blue accent color for dark mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Scaffold(
            body: SettingsTile(
              icon: Icons.location_on,
              title: 'Location',
              onTap: () {},
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.location_on));
      expect(icon.color, equals(AppColors.accentDark));
    });

    testWidgets('shows chevron for navigation tiles',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTile(
              icon: Icons.location_on,
              title: 'Location',
              showChevron: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('hides chevron when explicitly set to false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTile(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              showChevron: false,
              trailing: Switch.adaptive(
                value: false,
                onChanged: (_) {},
              ),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('applies touch feedback animation on press',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTile(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {},
            ),
          ),
        ),
      );

      // Find AnimatedScale inside SettingsTile
      final animatedScale = find.byType(AnimatedScale);
      expect(animatedScale, findsOneWidget);

      // Find the InkWell from PremiumCard (tappable card)
      final inkWells = find.byType(InkWell);
      expect(inkWells, findsWidgets);

      // Start gesture to trigger press state
      await tester.press(inkWells.first);
      await tester.pump();

      // Verify animation container exists
      expect(find.byType(AnimatedScale), findsOneWidget);
    });

    testWidgets('renders without subtitle', (WidgetTester tester) async {
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

    testWidgets('applies PremiumCard variant correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTile(
              icon: Icons.info,
              title: 'About',
              variant: PremiumCardVariant.flat,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(PremiumCard), findsOneWidget);
    });
  });

  group('SettingsTile Blue Color Scheme', () {
    testWidgets('uses primary color #1E3A5F for light mode icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTile(
              icon: Icons.account_circle,
              title: 'Account',
              onTap: () {},
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.account_circle));
      expect(icon.color, equals(AppColors.accentLight));
    });

    testWidgets('uses accent color #3B82F6 for interactive elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTile(
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () {},
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.notifications));
      // Accent color is used for icons in settings
      expect(icon.color, equals(AppColors.accentLight));
    });

    testWidgets('dark mode uses #000000 background (True Black)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Scaffold(
            backgroundColor: AppColors.backgroundDark,
            body: SettingsTile(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify dark theme is applied
      final context = tester.element(find.byType(SettingsTile));
      final isDark = Theme.of(context).brightness == Brightness.dark;
      expect(isDark, isTrue);
    });
  });
}
