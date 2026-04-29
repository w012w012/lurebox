import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/widgets/common/premium_button.dart';
import 'package:lurebox/widgets/common/premium_navigation_bar.dart';

void main() {
  group('PremiumButton Semantics', () {
    testWidgets('primary button has correct semantic properties',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumButton(
              text: 'Save',
              onPressed: () {},
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(PremiumButton).first);
      expect(semantics.label, 'Save');
    });

    testWidgets('outline button has correct semantic properties',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumButton(
              text: 'Cancel',
              variant: PremiumButtonVariant.outline,
              onPressed: () {},
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(PremiumButton).first);
      expect(semantics.label, 'Cancel');
    });

    testWidgets('text button has correct semantic properties',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumButton(
              text: 'Skip',
              variant: PremiumButtonVariant.text,
              onPressed: () {},
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(PremiumButton).first);
      expect(semantics.label, 'Skip');
    });

    testWidgets('button with icon has correct semantic properties',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumButton(
              text: 'Add Item',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(PremiumButton).first);
      expect(semantics.label, 'Add Item');
    });

    testWidgets('danger button has correct semantic properties',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumButton(
              text: 'Delete',
              variant: PremiumButtonVariant.danger,
              onPressed: () {},
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(PremiumButton).first);
      expect(semantics.label, 'Delete');
    });

    testWidgets('success button has correct semantic properties',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumButton(
              text: 'Confirm',
              variant: PremiumButtonVariant.success,
              onPressed: () {},
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(PremiumButton).first);
      expect(semantics.label, 'Confirm');
    });

    testWidgets('loading button has correct semantic properties',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumButton(
              text: 'Loading',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(PremiumButton).first);
      expect(semantics.label, 'Loading');
    });
  });

  group('PremiumNavigationBar Semantics', () {
    testWidgets('standard nav bar renders destinations correctly',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumNavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              destinations: const [
                PremiumNavigationDestination(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: 'Home',
                ),
                PremiumNavigationDestination(
                  icon: Icons.search_outlined,
                  selectedIcon: Icons.search,
                  label: 'Search',
                ),
                PremiumNavigationDestination(
                  icon: Icons.add_outlined,
                  selectedIcon: Icons.add,
                  label: 'Add',
                ),
                PremiumNavigationDestination(
                  icon: Icons.person_outlined,
                  selectedIcon: Icons.person,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('fab nav bar has correct semantic properties',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumNavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              showCenterFab: true,
              onCenterFabPressed: () {},
              destinations: const [
                PremiumNavigationDestination(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: 'Home',
                ),
                PremiumNavigationDestination(
                  icon: Icons.search_outlined,
                  selectedIcon: Icons.search,
                  label: 'Search',
                ),
                PremiumNavigationDestination(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: 'Settings',
                ),
                PremiumNavigationDestination(
                  icon: Icons.person_outlined,
                  selectedIcon: Icons.person,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      );

      // The FAB has Semantics with label 'Take photo' and button: true
      final fabFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics &&
            widget.properties.label == 'Take photo' &&
            widget.properties.button == true,
      );
      expect(fabFinder, findsOneWidget);

      final semantics = tester.getSemantics(fabFinder.first);
      expect(semantics.label, 'Take photo');
    });

    testWidgets('nav bar tab has correct semantic properties',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumNavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              destinations: const [
                PremiumNavigationDestination(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: 'Home',
                ),
                PremiumNavigationDestination(
                  icon: Icons.search_outlined,
                  selectedIcon: Icons.search,
                  label: 'Search',
                ),
                PremiumNavigationDestination(
                  icon: Icons.add_outlined,
                  selectedIcon: Icons.add,
                  label: 'Add',
                ),
                PremiumNavigationDestination(
                  icon: Icons.person_outlined,
                  selectedIcon: Icons.person,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      );

      // Find the NavigationBar and check its destinations
      final navBar = find.byType(NavigationBar);
      expect(navBar, findsOneWidget);

      // Verify the navigation destinations exist
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });
  });

  group('PremiumFAB Semantics', () {
    testWidgets('FAB has correct semantic label with tooltip',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PremiumFAB(
                icon: Icons.add,
                tooltip: 'Add new catch',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // PremiumFAB wraps FloatingActionButton in a Semantics with label from tooltip
      final semantics = tester.getSemantics(find.byType(PremiumFAB).first);
      expect(semantics.label, 'Add new catch');
    });

    testWidgets('FAB has default semantic label without tooltip',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PremiumFAB(
                icon: Icons.add,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(PremiumFAB).first);
      expect(semantics.label, 'Floating action button');
    });
  });
}