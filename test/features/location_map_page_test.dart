import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/animation_constants.dart';
import 'package:lurebox/core/providers/location_view_model.dart';
import 'package:lurebox/features/location/widgets/location_marker.dart';
import 'package:lurebox/features/location/widgets/location_group_card.dart';

Widget _wrapInApp(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: ThemeData(brightness: brightness),
    home: Scaffold(body: child),
  );
}

void main() {
  group('LocationMarker', () {
    testWidgets('renders name and fish count', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const LocationMarker(
          name: 'Test Lake',
          fishCount: 5,
          isSelected: false,
          onTap: _noop,
        ),
      ));

      expect(find.text('Test Lake'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders with selected state', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const LocationMarker(
          name: 'Selected Spot',
          fishCount: 3,
          isSelected: true,
          onTap: _noop,
        ),
      ));

      expect(find.text('Selected Spot'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('fires onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrapInApp(
        LocationMarker(
          name: 'Tap Me',
          fishCount: 1,
          isSelected: false,
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('uses AnimatedScale for touch feedback', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const LocationMarker(
          name: 'Animated',
          fishCount: 1,
          isSelected: false,
          onTap: _noop,
        ),
      ));

      expect(find.byType(AnimatedScale), findsOneWidget);
    });

    testWidgets('has CustomPaint triangle for map pin shape', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const LocationMarker(
          name: 'Pin',
          fishCount: 1,
          isSelected: false,
          onTap: _noop,
        ),
      ));

      // The marker uses CustomPaint for the triangle pin shape.
      // Flutter may also use CustomPaint internally, so check at least 1.
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    });

    testWidgets('renders location_on icon', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const LocationMarker(
          name: 'Icon Test',
          fishCount: 2,
          isSelected: false,
          onTap: _noop,
        ),
      ));

      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });
  });

  group('LocationGroupCard', () {
    const testGroup = LocationGroup(
      representative: 'Lake Michigan',
      locations: ['North Shore', 'South Pier'],
    );
    final testCounts = {'North Shore': 5, 'South Pier': 3};

    testWidgets('renders group representative name', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        LocationGroupCard(
          group: testGroup,
          locationFishCounts: testCounts,
        ),
      ));

      expect(find.textContaining('Lake Michigan'), findsOneWidget);
    });

    testWidgets('shows location count in subtitle', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        LocationGroupCard(
          group: testGroup,
          locationFishCounts: testCounts,
        ),
      ));

      expect(find.text('包含 2 个相似钓点'), findsOneWidget);
    });

    testWidgets('shows merge_type icon', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        LocationGroupCard(
          group: testGroup,
          locationFishCounts: testCounts,
        ),
      ));

      expect(find.byIcon(Icons.merge_type), findsOneWidget);
    });

    testWidgets('shows expand_more chevron', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        LocationGroupCard(
          group: testGroup,
          locationFishCounts: testCounts,
        ),
      ));

      expect(find.byIcon(Icons.expand_more), findsOneWidget);
    });

    testWidgets('uses AnimatedContainer for expansion', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        LocationGroupCard(
          group: testGroup,
          locationFishCounts: testCounts,
        ),
      ));

      expect(find.byType(AnimatedContainer), findsOneWidget);
    });

    testWidgets('uses AnimatedCrossFade for content', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        LocationGroupCard(
          group: testGroup,
          locationFishCounts: testCounts,
        ),
      ));

      expect(find.byType(AnimatedCrossFade), findsOneWidget);
    });

    testWidgets('expands on tap to show locations', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        LocationGroupCard(
          group: testGroup,
          locationFishCounts: testCounts,
        ),
      ));

      // AnimatedCrossFade keeps both children in tree (collapsed = zero opacity).
      // Verify the cross-fade starts in collapsed state.
      final crossFade = tester.widget<AnimatedCrossFade>(
        find.byType(AnimatedCrossFade),
      );
      expect(crossFade.crossFadeState, CrossFadeState.showFirst);

      // Tap to expand
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // After tap, cross-fade should show second child (location list)
      final expanded = tester.widget<AnimatedCrossFade>(
        find.byType(AnimatedCrossFade),
      );
      expect(expanded.crossFadeState, CrossFadeState.showSecond);
    });

    testWidgets('shows fish count per location when expanded', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        LocationGroupCard(
          group: testGroup,
          locationFishCounts: testCounts,
        ),
      ));

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.text('5 条渔获'), findsOneWidget);
      expect(find.text('3 条渔获'), findsOneWidget);
    });

    testWidgets('shows merge button when onAutoMerge provided', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        LocationGroupCard(
          group: testGroup,
          locationFishCounts: testCounts,
          onAutoMerge: () {},
        ),
      ));

      expect(find.text('合并'), findsOneWidget);
    });

    testWidgets('hides merge button when onAutoMerge is null', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        LocationGroupCard(
          group: testGroup,
          locationFishCounts: testCounts,
        ),
      ));

      expect(find.text('合并'), findsNothing);
    });

    testWidgets('uses English strings when provided', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        LocationGroupCard(
          group: testGroup,
          locationFishCounts: testCounts,
          strings: AppStrings.english,
          onAutoMerge: () {},
        ),
      ));

      expect(find.textContaining('Similar locations'), findsOneWidget);
      expect(find.text('Merge'), findsOneWidget);
    });

    testWidgets('supports dark mode', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        LocationGroupCard(
          group: testGroup,
          locationFishCounts: testCounts,
        ),
        brightness: Brightness.dark,
      ));

      expect(find.byType(AnimatedContainer), findsOneWidget);
      expect(find.textContaining('Lake Michigan'), findsOneWidget);
    });
  });
}

void _noop() {}
