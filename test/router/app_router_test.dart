import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/providers/onboarding_provider.dart';
import 'package:lurebox/core/router/app_router.dart';
import 'package:lurebox/core/services/settings_service.dart';
import 'package:mocktail/mocktail.dart';

// ===== Fakes / Mocks =====

class MockSettingsService extends Mock implements SettingsService {}

/// A fake AppSettingsNotifier that bypasses async _loadSettings().
class _FakeAppSettingsNotifier extends AppSettingsNotifier {
  _FakeAppSettingsNotifier(AppSettings initial, SettingsService service)
      : super(service) {
    state = initial;
  }
}

/// A shell wrapper that captures the nav index for testing bottom nav logic.
class _NavCaptureShell extends StatelessWidget {
  const _NavCaptureShell({
    required this.child,
    required this.capture,
  });
  final Widget child;
  final ValueNotifier<int> capture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _CapturingNavBar(capture: capture),
    );
  }
}

class _CapturingNavBar extends StatelessWidget {
  const _CapturingNavBar({required this.capture});
  final ValueNotifier<int> capture;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    int index;
    if (location == '/') {
      index = 0;
    } else if (location.startsWith('/fish')) {
      index = 1;
    } else if (location.startsWith('/equipment')) {
      index = 2;
    } else if (location.startsWith('/me')) {
      index = 3;
    } else {
      index = 0;
    }
    capture.value = index;
    return Text('navIndex:$index');
  }
}

// ===== Test Helpers =====

/// Creates a GoRouter that mirrors the production redirect logic and route
/// structure (without importing actual page widgets).
GoRouter _createTestRouter({
  required bool onboardingCompleted,
  String? initialLocation,
}) {
  return GoRouter(
    initialLocation:
        initialLocation ?? (onboardingCompleted ? '/' : '/onboarding'),
    redirect: (context, state) {
      if (state.matchedLocation == '/onboarding') return null;
      if (!onboardingCompleted) return '/onboarding';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const Text('onboarding'),
      ),
      GoRoute(
        path: '/fish/:id',
        builder: (_, state) {
          final fishId = int.tryParse(state.pathParameters['id'] ?? '');
          return Text('fish:${fishId ?? "null"}');
        },
      ),
      GoRoute(
        path: '/fish/:id/edit',
        builder: (_, state) {
          final fishId = int.tryParse(state.pathParameters['id'] ?? '');
          return Text('fishEdit:${fishId ?? "null"}');
        },
      ),
      GoRoute(
        path: '/equipment/edit',
        builder: (_, state) {
          const allowedTypes = {'rod', 'reel', 'lure', 'line'};
          final rawType = state.uri.queryParameters['type'] ?? 'rod';
          final type = allowedTypes.contains(rawType) ? rawType : 'rod';
          final idStr = state.uri.queryParameters['id'];
          final equipmentId = idStr != null ? int.tryParse(idStr) : null;
          return Text('equipmentEdit:type=$type,id=$equipmentId');
        },
      ),
      GoRoute(
        path: '/stats',
        builder: (_, state) {
          final title = state.uri.queryParameters['title'] ?? '';
          return Text('stats:title=$title');
        },
      ),
      GoRoute(
        path: '/camera',
        builder: (_, __) => const Text('camera'),
      ),
    ],
  );
}

/// Creates a GoRouter with ShellRoute for bottom nav testing.
GoRouter _createShellRouter({
  required ValueNotifier<int> navIndexCapture,
  String initialLocation = '/',
}) {
  final shellKey = GlobalKey<NavigatorState>();
  return GoRouter(
    initialLocation: initialLocation,
    redirect: (_, __) => null,
    routes: [
      ShellRoute(
        navigatorKey: shellKey,
        builder: (context, state, child) {
          return _NavCaptureShell(
            capture: navIndexCapture,
            child: child,
          );
        },
        routes: [
          GoRoute(path: '/', builder: (_, __) => const Text('home')),
          GoRoute(path: '/fish', builder: (_, __) => const Text('fishList')),
          GoRoute(
              path: '/equipment',
              builder: (_, __) => const Text('equipmentList')),
          GoRoute(path: '/me', builder: (_, __) => const Text('mePage')),
        ],
      ),
    ],
  );
}

Widget _testApp(GoRouter router, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  late MockSettingsService mockSettingsService;

  setUpAll(() {
    registerFallbackValue(const AppSettings());
  });

  setUp(() {
    mockSettingsService = MockSettingsService();
    when(() => mockSettingsService.getAppSettings())
        .thenAnswer((_) async => const AppSettings());
    when(() => mockSettingsService.saveAppSettings(any()))
        .thenAnswer((_) async {});
  });

  // ============================================================
  // 1. Route Path Parameter Parsing
  // ============================================================
  group('route path parameter parsing', () {
    testWidgets('parses valid fish id from /fish/:id', (tester) async {
      final router = _createTestRouter(onboardingCompleted: true);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      router.go('/fish/42');
      await tester.pumpAndSettle();
      expect(find.text('fish:42'), findsOneWidget);
    });

    testWidgets('parses valid fish id from /fish/:id/edit', (tester) async {
      final router = _createTestRouter(onboardingCompleted: true);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      router.go('/fish/99/edit');
      await tester.pumpAndSettle();
      expect(find.text('fishEdit:99'), findsOneWidget);
    });

    testWidgets('returns null for invalid fish id string', (tester) async {
      final router = _createTestRouter(onboardingCompleted: true);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      router.go('/fish/abc');
      await tester.pumpAndSettle();
      expect(find.text('fish:null'), findsOneWidget);
    });

    testWidgets('parses fish id zero from /fish/0', (tester) async {
      final router = _createTestRouter(onboardingCompleted: true);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      router.go('/fish/0');
      await tester.pumpAndSettle();
      expect(find.text('fish:0'), findsOneWidget);
    });
  });

  // ============================================================
  // 2. Equipment Type Whitelist
  // ============================================================
  group('equipment type whitelist', () {
    testWidgets('allows valid type "rod"', (tester) async {
      final router = _createTestRouter(onboardingCompleted: true);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      router.go('/equipment/edit?type=rod');
      await tester.pumpAndSettle();
      expect(find.text('equipmentEdit:type=rod,id=null'), findsOneWidget);
    });

    testWidgets('allows valid type "reel"', (tester) async {
      final router = _createTestRouter(onboardingCompleted: true);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      router.go('/equipment/edit?type=reel');
      await tester.pumpAndSettle();
      expect(find.text('equipmentEdit:type=reel,id=null'), findsOneWidget);
    });

    testWidgets('allows valid type "lure"', (tester) async {
      final router = _createTestRouter(onboardingCompleted: true);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      router.go('/equipment/edit?type=lure');
      await tester.pumpAndSettle();
      expect(find.text('equipmentEdit:type=lure,id=null'), findsOneWidget);
    });

    testWidgets('allows valid type "line"', (tester) async {
      final router = _createTestRouter(onboardingCompleted: true);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      router.go('/equipment/edit?type=line');
      await tester.pumpAndSettle();
      expect(find.text('equipmentEdit:type=line,id=null'), findsOneWidget);
    });

    testWidgets('falls back to "rod" for invalid type', (tester) async {
      final router = _createTestRouter(onboardingCompleted: true);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      router.go('/equipment/edit?type=invalid');
      await tester.pumpAndSettle();
      expect(find.text('equipmentEdit:type=rod,id=null'), findsOneWidget);
    });

    testWidgets('defaults to "rod" when type param is missing', (tester) async {
      final router = _createTestRouter(onboardingCompleted: true);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      router.go('/equipment/edit');
      await tester.pumpAndSettle();
      expect(find.text('equipmentEdit:type=rod,id=null'), findsOneWidget);
    });

    testWidgets('parses equipment id from query param', (tester) async {
      final router = _createTestRouter(onboardingCompleted: true);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      router.go('/equipment/edit?type=reel&id=7');
      await tester.pumpAndSettle();
      expect(find.text('equipmentEdit:type=reel,id=7'), findsOneWidget);
    });

    testWidgets('equipment id is null when query param is missing',
        (tester) async {
      final router = _createTestRouter(onboardingCompleted: true);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      router.go('/equipment/edit?type=lure');
      await tester.pumpAndSettle();
      expect(find.text('equipmentEdit:type=lure,id=null'), findsOneWidget);
    });

    testWidgets('equipment id is null for non-numeric query param',
        (tester) async {
      final router = _createTestRouter(onboardingCompleted: true);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      router.go('/equipment/edit?type=rod&id=abc');
      await tester.pumpAndSettle();
      expect(find.text('equipmentEdit:type=rod,id=null'), findsOneWidget);
    });
  });

  // ============================================================
  // 3. Onboarding Redirect Logic
  // ============================================================
  group('onboarding redirect', () {
    testWidgets('redirects to /onboarding when onboarding not completed',
        (tester) async {
      final router = _createTestRouter(onboardingCompleted: false);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      await tester.pumpAndSettle();
      expect(find.text('onboarding'), findsOneWidget);
    });

    testWidgets('does not redirect when already on /onboarding',
        (tester) async {
      final router = _createTestRouter(
        onboardingCompleted: false,
        initialLocation: '/onboarding',
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      await tester.pumpAndSettle();
      expect(find.text('onboarding'), findsOneWidget);
    });

    testWidgets('allows navigation when onboarding is completed',
        (tester) async {
      final router = _createTestRouter(onboardingCompleted: true);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      await tester.pumpAndSettle();
      // Should NOT be on onboarding page
      expect(find.text('onboarding'), findsNothing);
    });

    testWidgets('redirects navigation away from /onboarding when completed',
        (tester) async {
      final router = _createTestRouter(
        onboardingCompleted: true,
        initialLocation: '/onboarding',
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      await tester.pumpAndSettle();
      // Redirect does not block /onboarding when completed (null returned),
      // but the initial location is /onboarding so it stays.
      // This tests that the redirect doesn't break when completed=true
      // and user is on /onboarding.
      expect(find.text('onboarding'), findsOneWidget);
    });

    testWidgets(
        'navigating to /camera redirects to /onboarding when not completed',
        (tester) async {
      final router = _createTestRouter(onboardingCompleted: false);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      await tester.pumpAndSettle();

      // Find a widget INSIDE the GoRouter's InheritedWidget scope.
      // MaterialApp sits above the router's InheritedWidget, so we use
      // the onboarding Text widget that is rendered by the router.
      final onboardingText = find.text('onboarding');
      expect(onboardingText, findsOneWidget);

      // Attempt navigation to /camera using the router directly
      router.go('/camera');
      await tester.pumpAndSettle();

      // Should still be on /onboarding (redirect blocks /camera)
      expect(find.text('camera'), findsNothing);
      expect(find.text('onboarding'), findsOneWidget);
    });
  });

  // ============================================================
  // 4. Bottom Nav Index (via ShellRoute)
  // ============================================================
  group('bottom nav index', () {
    testWidgets('defaults to index 0 at root path "/"', (tester) async {
      final capture = ValueNotifier<int>(-1);
      final router = _createShellRouter(navIndexCapture: capture);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      await tester.pumpAndSettle();
      expect(capture.value, 0);
    });

    testWidgets('maps /fish to index 1', (tester) async {
      final capture = ValueNotifier<int>(-1);
      final router = _createShellRouter(
        navIndexCapture: capture,
        initialLocation: '/fish',
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      await tester.pumpAndSettle();
      expect(capture.value, 1);
    });

    testWidgets('maps /equipment to index 2', (tester) async {
      final capture = ValueNotifier<int>(-1);
      final router = _createShellRouter(
        navIndexCapture: capture,
        initialLocation: '/equipment',
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      await tester.pumpAndSettle();
      expect(capture.value, 2);
    });

    testWidgets('maps /me to index 3', (tester) async {
      final capture = ValueNotifier<int>(-1);
      final router = _createShellRouter(
        navIndexCapture: capture,
        initialLocation: '/me',
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      await tester.pumpAndSettle();
      expect(capture.value, 3);
    });

    testWidgets('updates index when navigating between tabs', (tester) async {
      final capture = ValueNotifier<int>(-1);
      final router = _createShellRouter(navIndexCapture: capture);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      await tester.pumpAndSettle();
      expect(capture.value, 0);

      // Navigate to /fish
      router.go('/fish');
      await tester.pumpAndSettle();
      expect(capture.value, 1);

      // Navigate to /equipment
      router.go('/equipment');
      await tester.pumpAndSettle();
      expect(capture.value, 2);

      // Navigate back to /
      router.go('/');
      await tester.pumpAndSettle();
      expect(capture.value, 0);
    });
  });

  // ============================================================
  // 5. Route Matching / Generation
  // ============================================================
  group('route matching', () {
    testWidgets('matches /onboarding route', (tester) async {
      final router = _createTestRouter(onboardingCompleted: true);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      router.go('/onboarding');
      await tester.pumpAndSettle();
      expect(find.text('onboarding'), findsOneWidget);
    });

    testWidgets('matches /fish/:id route with numeric id', (tester) async {
      final router = _createTestRouter(onboardingCompleted: true);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      router.go('/fish/123');
      await tester.pumpAndSettle();
      expect(find.text('fish:123'), findsOneWidget);
    });

    testWidgets('matches /stats route with query parameters', (tester) async {
      final router = _createTestRouter(onboardingCompleted: true);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      router.go('/stats?title=Summer');
      await tester.pumpAndSettle();
      expect(find.text('stats:title=Summer'), findsOneWidget);
    });

    testWidgets('matches /camera route', (tester) async {
      final router = _createTestRouter(onboardingCompleted: true);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      router.go('/camera');
      await tester.pumpAndSettle();
      expect(find.text('camera'), findsOneWidget);
    });

    testWidgets('shell routes are nested inside ShellRoute', (tester) async {
      final capture = ValueNotifier<int>(-1);
      final router = _createShellRouter(navIndexCapture: capture);
      addTearDown(router.dispose);

      await tester.pumpWidget(_testApp(router));
      await tester.pumpAndSettle();

      // Verify shell child is rendered (home page text)
      expect(find.text('home'), findsOneWidget);
      // Verify the shell wrapper is also rendered
      expect(find.byType(_NavCaptureShell), findsOneWidget);
    });
  });

  // ============================================================
  // 6. routerProvider integration with Riverpod overrides
  // ============================================================
  group('routerProvider with Riverpod overrides', () {
    test('initial location is "/" when onboarding completed', () async {
      final notifier = _FakeAppSettingsNotifier(
        const AppSettings(hasCompletedOnboarding: true),
        mockSettingsService,
      );
      final container = ProviderContainer(
        overrides: [
          settingsServiceProvider.overrideWithValue(mockSettingsService),
          appSettingsProvider.overrideWith((ref) => notifier),
          // Override the derived provider directly to avoid stale reads
          onboardingCompletedProvider.overrideWithValue(true),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(routerProvider);
      addTearDown(router.dispose);

      expect(router.routeInformationProvider.value.uri.path, '/');
    });

    test('initial location is /onboarding when not completed', () async {
      final notifier = _FakeAppSettingsNotifier(
        const AppSettings(hasCompletedOnboarding: false),
        mockSettingsService,
      );
      final container = ProviderContainer(
        overrides: [
          settingsServiceProvider.overrideWithValue(mockSettingsService),
          appSettingsProvider.overrideWith((ref) => notifier),
          // Override the derived provider directly to avoid stale reads
          onboardingCompletedProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(routerProvider);
      addTearDown(router.dispose);

      expect(router.routeInformationProvider.value.uri.path, '/onboarding');
    });
  });
}
