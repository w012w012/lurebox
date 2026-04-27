import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lurebox/widgets/common/premium_navigation_bar.dart';

void main() {
  final testDestinations = [
    const PremiumNavigationDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    const PremiumNavigationDestination(
      icon: Icons.location_on_outlined,
      selectedIcon: Icons.location_on,
      label: 'Spots',
    ),
    const PremiumNavigationDestination(
      icon: Icons.camera_alt_outlined,
      selectedIcon: Icons.camera_alt,
      label: 'Camera',
    ),
    const PremiumNavigationDestination(
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      label: 'Stats',
    ),
    const PremiumNavigationDestination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  final fabDestinations = [
    const PremiumNavigationDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    const PremiumNavigationDestination(
      icon: Icons.location_on_outlined,
      selectedIcon: Icons.location_on,
      label: 'Spots',
    ),
    const PremiumNavigationDestination(
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      label: 'Stats',
    ),
    const PremiumNavigationDestination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  Widget buildNav({
    required int selectedIndex,
    required ValueChanged<int> onDestinationSelected,
    required List<PremiumNavigationDestination> destinations,
    bool showCenterFab = false,
    VoidCallback? onCenterFabPressed,
    Brightness brightness = Brightness.light,
  }) {
    return MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(
        bottomNavigationBar: PremiumNavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations,
          showCenterFab: showCenterFab,
          onCenterFabPressed: onCenterFabPressed,
        ),
      ),
    );
  }

  group('PremiumNavigationBar — Standard Mode', () {
    testWidgets('renders all destination labels', (tester) async {
      await tester.pumpWidget(
        buildNav(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          destinations: testDestinations,
        ),
      );

      for (final dest in testDestinations) {
        expect(find.text(dest.label), findsOneWidget);
      }
    });

    testWidgets('renders destination icons', (tester) async {
      await tester.pumpWidget(
        buildNav(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          destinations: testDestinations,
        ),
      );

      // Index 0 is selected, so its selectedIcon is shown
      expect(find.byIcon(testDestinations[0].selectedIcon), findsOneWidget);
      // Indices 1–4 are unselected, so their default icon is shown
      for (var i = 1; i < testDestinations.length; i++) {
        expect(find.byIcon(testDestinations[i].icon), findsOneWidget);
      }
    });

    testWidgets('defaults to selectedIndex 0 highlighting first tab',
        (tester) async {
      await tester.pumpWidget(
        buildNav(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          destinations: testDestinations,
        ),
      );

      // The first destination's selectedIcon should be used
      expect(find.byIcon(testDestinations[0].selectedIcon), findsOneWidget);
      // The first destination's unselected icon should NOT be used
      expect(find.byIcon(testDestinations[0].icon), findsNothing);
    });

    testWidgets('tapping a destination triggers onDestinationSelected',
        (tester) async {
      final tapped = <int>[];
      await tester.pumpWidget(
        buildNav(
          selectedIndex: 0,
          onDestinationSelected: tapped.add,
          destinations: testDestinations,
        ),
      );

      // Tap the "Spots" destination (index 1)
      await tester.tap(find.text('Spots'));
      await tester.pumpAndSettle();

      expect(tapped, contains(1));
    });

    testWidgets('tapping each destination passes correct index',
        (tester) async {
      final tapped = <int>[];
      await tester.pumpWidget(
        buildNav(
          selectedIndex: 0,
          onDestinationSelected: tapped.add,
          destinations: testDestinations,
        ),
      );

      for (var i = 0; i < testDestinations.length; i++) {
        await tester.tap(find.text(testDestinations[i].label));
        await tester.pumpAndSettle();
      }

      expect(tapped, orderedEquals([0, 1, 2, 3, 4]));
    });

    testWidgets('does not render center FAB when showCenterFab is false',
        (tester) async {
      await tester.pumpWidget(
        buildNav(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          destinations: testDestinations,
        ),
      );

      expect(find.byIcon(Icons.camera_alt), findsNothing);
    });
  });

  group('PremiumNavigationBar — FAB Mode', () {
    testWidgets('renders all 4 destination labels', (tester) async {
      await tester.pumpWidget(
        buildNav(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          destinations: fabDestinations,
          showCenterFab: true,
        ),
      );

      for (final dest in fabDestinations) {
        expect(find.text(dest.label), findsOneWidget);
      }
    });

    testWidgets('renders center FAB with camera icon', (tester) async {
      await tester.pumpWidget(
        buildNav(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          destinations: fabDestinations,
          showCenterFab: true,
          onCenterFabPressed: () {},
        ),
      );

      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('FAB has semantic label "Take photo"', (tester) async {
      await tester.pumpWidget(
        buildNav(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          destinations: fabDestinations,
          showCenterFab: true,
          onCenterFabPressed: () {},
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Take photo',
        ),
        findsOneWidget,
      );
    });

    testWidgets('pressing FAB triggers onCenterFabPressed', (tester) async {
      var fabPressed = false;
      await tester.pumpWidget(
        buildNav(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          destinations: fabDestinations,
          showCenterFab: true,
          onCenterFabPressed: () => fabPressed = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      expect(fabPressed, isTrue);
    });

    testWidgets('selected tab uses selectedIcon while others use default icon',
        (tester) async {
      await tester.pumpWidget(
        buildNav(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          destinations: fabDestinations,
          showCenterFab: true,
        ),
      );

      // Index 0 is selected → selectedIcon shown
      expect(find.byIcon(fabDestinations[0].selectedIcon), findsOneWidget);
      expect(find.byIcon(fabDestinations[0].icon), findsNothing);

      // Indices 1–3 are unselected → default icon shown
      for (var i = 1; i < fabDestinations.length; i++) {
        expect(find.byIcon(fabDestinations[i].icon), findsOneWidget);
        expect(find.byIcon(fabDestinations[i].selectedIcon), findsNothing);
      }
    });

    testWidgets('tapping _NavTab triggers onDestinationSelected with index',
        (tester) async {
      final tapped = <int>[];
      await tester.pumpWidget(
        buildNav(
          selectedIndex: 0,
          onDestinationSelected: tapped.add,
          destinations: fabDestinations,
          showCenterFab: true,
        ),
      );

      // Tap via the InkWell ancestor — the text overflows its constraints
      // so tapping the Text directly doesn't register in the hit-test area.
      await tester.tap(
        find.ancestor(
          of: find.text('Spots'),
          matching: find.byType(InkWell),
        ),
      );
      await tester.pumpAndSettle();

      expect(tapped, contains(1));
    });

    testWidgets('tapping all _NavTabs passes correct indices', (tester) async {
      final tapped = <int>[];
      await tester.pumpWidget(
        buildNav(
          selectedIndex: 0,
          onDestinationSelected: tapped.add,
          destinations: fabDestinations,
          showCenterFab: true,
        ),
      );

      for (final dest in fabDestinations) {
        await tester.tap(
          find.ancestor(
            of: find.text(dest.label),
            matching: find.byType(InkWell),
          ),
        );
        await tester.pumpAndSettle();
      }

      expect(tapped, orderedEquals([0, 1, 2, 3]));
    });

    testWidgets('selecting a different tab updates icon state', (tester) async {
      // Start with index 2 selected
      await tester.pumpWidget(
        buildNav(
          selectedIndex: 2,
          onDestinationSelected: (_) {},
          destinations: fabDestinations,
          showCenterFab: true,
        ),
      );

      // Index 2 is selected → its selectedIcon is shown
      expect(find.byIcon(fabDestinations[2].selectedIcon), findsOneWidget);
      expect(find.byIcon(fabDestinations[2].icon), findsNothing);

      // Index 0 is unselected → its default icon is shown
      expect(find.byIcon(fabDestinations[0].icon), findsOneWidget);
      expect(find.byIcon(fabDestinations[0].selectedIcon), findsNothing);
    });

    testWidgets('uses custom _NavTab widgets, not NavigationBar',
        (tester) async {
      await tester.pumpWidget(
        buildNav(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          destinations: fabDestinations,
          showCenterFab: true,
        ),
      );

      // FAB mode uses custom _NavTab via InkWell, not Material NavigationBar
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('container height is 80px in FAB mode', (tester) async {
      await tester.pumpWidget(
        buildNav(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          destinations: fabDestinations,
          showCenterFab: true,
        ),
      );

      // The SizedBox(height: 80) holds the Stack layout
      final sizedBoxFinder = find.byWidgetPredicate(
        (w) => w is SizedBox && w.height == 80,
      );
      expect(sizedBoxFinder, findsOneWidget);
    });
  });
}
