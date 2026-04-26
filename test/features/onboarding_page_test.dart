import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lurebox/core/constants/strings/app_strings.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/providers/onboarding_provider.dart';
import 'package:lurebox/features/onboarding/onboarding_page.dart';

import '../helpers/test_helpers.dart';

/// Creates a test app shell with ProviderScope + GoRouter wrapping OnboardingPage
Widget createOnboardingTestApp({
  required List<Override> overrides,
}) {
  final router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Home'))),
      ),
    ],
  );
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  setUpAll(() {
    setUpDatabaseForTesting();
    registerFallbackValues();
  });

  group('OnboardingPage', () {
    testWidgets('renders onboarding page with first page content',
        (tester) async {
      await tester.pumpWidget(
        createOnboardingTestApp(
          overrides: [
            onboardingNotifierProvider
                .overrideWith((ref) => MockOnboardingNotifier()),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // First page should show welcome content
      expect(find.text('欢迎使用路亚鱼护'), findsOneWidget);
      expect(find.text('记录每一次出钓的渔获'), findsOneWidget);
    });

    testWidgets('shows page indicators (dots) for 5 pages', (tester) async {
      await tester.pumpWidget(
        createOnboardingTestApp(
          overrides: [
            onboardingNotifierProvider
                .overrideWith((ref) => MockOnboardingNotifier()),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // PageView should have page indicators
      final indicators = find.byWidgetPredicate((widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).borderRadius != null);
      expect(indicators, findsWidgets);
    });

    testWidgets('shows skip button', (tester) async {
      await tester.pumpWidget(
        createOnboardingTestApp(
          overrides: [
            onboardingNotifierProvider
                .overrideWith((ref) => MockOnboardingNotifier()),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Skip button should be visible
      expect(find.text('跳过'), findsOneWidget);
    });

    testWidgets('shows next button on first page', (tester) async {
      await tester.pumpWidget(
        createOnboardingTestApp(
          overrides: [
            onboardingNotifierProvider
                .overrideWith((ref) => MockOnboardingNotifier()),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Next button should be visible on first page
      expect(find.text('下一步'), findsOneWidget);
    });

    testWidgets('navigates to next page when next button is tapped',
        (tester) async {
      await tester.pumpWidget(
        createOnboardingTestApp(
          overrides: [
            onboardingNotifierProvider
                .overrideWith((ref) => MockOnboardingNotifier()),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Tap next button
      await tester.tap(find.text('下一步'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should now show features page title
      expect(find.text('功能介绍'), findsOneWidget);
    });

    testWidgets('completes onboarding when skip button is tapped',
        (tester) async {
      final mockNotifier = MockOnboardingNotifier();

      await tester.pumpWidget(
        createOnboardingTestApp(
          overrides: [
            onboardingNotifierProvider.overrideWith((ref) => mockNotifier),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Tap skip button
      await tester.tap(find.text('跳过'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // completeOnboarding should have been called
      expect(mockNotifier.completeOnboardingCalled, isTrue);
    });

    testWidgets('shows get started button on last page', (tester) async {
      await tester.pumpWidget(
        createOnboardingTestApp(
          overrides: [
            onboardingNotifierProvider
                .overrideWith((ref) => MockOnboardingNotifier()),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Navigate through all 5 pages by tapping next repeatedly
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text('下一步'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      }

      // On last page, button should say "开始使用" (Get Started)
      expect(find.text('开始使用'), findsOneWidget);
    });

    testWidgets('completes onboarding when get started button is tapped',
        (tester) async {
      final mockNotifier = MockOnboardingNotifier();

      await tester.pumpWidget(
        createOnboardingTestApp(
          overrides: [
            onboardingNotifierProvider.overrideWith((ref) => mockNotifier),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Navigate to last page
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text('下一步'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Tap get started button
      await tester.tap(find.text('开始使用'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // completeOnboarding should have been called
      expect(mockNotifier.completeOnboardingCalled, isTrue);
    });

    testWidgets('swipes to next page', (tester) async {
      await tester.pumpWidget(
        createOnboardingTestApp(
          overrides: [
            onboardingNotifierProvider
                .overrideWith((ref) => MockOnboardingNotifier()),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Swipe left to go to next page
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should now show features page
      expect(find.text('功能介绍'), findsOneWidget);
    });
  });
}

/// Mock OnboardingNotifier for testing
class MockOnboardingNotifier extends StateNotifier<bool>
    implements OnboardingNotifier {
  MockOnboardingNotifier() : super(false);

  bool completeOnboardingCalled = false;
  bool resetOnboardingCalled = false;

  @override
  Future<void> completeOnboarding() async {
    completeOnboardingCalled = true;
    state = true;
  }

  @override
  Future<void> resetOnboarding() async {
    resetOnboardingCalled = true;
    state = false;
  }
}
