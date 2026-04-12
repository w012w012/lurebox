import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/achievement/achievement_page.dart';
import '../../features/camera/camera_page.dart';
import '../../features/equipment/equipment_edit_page.dart';
import '../../features/equipment/equipment_list_page.dart';
import '../../features/equipment/equipment_overview_page.dart';
import '../../features/fish_detail/fish_detail_page.dart';
import '../../features/fish_list/fish_list_page.dart';
import '../../features/home/home_page.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/settings/ai_recognition_settings_page.dart';
import '../../features/settings/export_backup_management_page.dart';
import '../../features/settings/location_management_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/settings/species_management_page.dart';
import '../../features/settings/watermark_settings_page.dart';
import '../../features/stats/stats_detail_page.dart';
import '../../widgets/common/premium_navigation_bar.dart';
import '../../core/constants/strings.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/onboarding_provider.dart';
import '../../core/providers/fish_detail_view_model.dart';
import '../../features/fish_detail/widgets/fish_edit_page.dart';
import '../../features/settings/widgets/settings_units_section.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingCompleted = ref.watch(onboardingCompletedProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: onboardingCompleted ? '/' : '/onboarding',
    redirect: (context, state) {
      // Already on onboarding page - don't redirect
      if (state.matchedLocation == '/onboarding') {
        return null;
      }

      // If not completed, redirect to onboarding
      if (!onboardingCompleted) {
        return '/onboarding';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/fish/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final fishId = int.parse(state.pathParameters['id']!);
          return FishDetailPage(fishId: fishId);
        },
      ),
      GoRoute(
        path: '/fish/:id/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final fishId = int.parse(state.pathParameters['id']!);
          return _FishEditPageWrapper(fishId: fishId);
        },
      ),
      GoRoute(
        path: '/camera',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CameraPage(),
      ),
      GoRoute(
        path: '/species',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SpeciesManagementPage(),
      ),
      GoRoute(
        path: '/stats',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? '';
          final start = state.uri.queryParameters['start'];
          final end = state.uri.queryParameters['end'];
          return StatsDetailPage(
            title: title,
            startDate: start != null ? DateTime.parse(start) : DateTime.now(),
            endDate: end != null ? DateTime.parse(end) : DateTime.now(),
          );
        },
      ),
      GoRoute(
        path: '/equipment/overview',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EquipmentOverviewPage(),
      ),
      GoRoute(
        path: '/equipment/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final type = state.uri.queryParameters['type'] ?? 'rod';
          final idStr = state.uri.queryParameters['id'];
          final equipmentId = idStr != null ? int.tryParse(idStr) : null;
          return EquipmentEditPage(type: type, equipmentId: equipmentId);
        },
      ),
      GoRoute(
        path: '/settings/watermark',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WatermarkSettingsPage(),
      ),
      GoRoute(
        path: '/settings/ai',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AiRecognitionSettingsPage(),
      ),
      GoRoute(
        path: '/settings/locations',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LocationManagementPage(),
      ),
      GoRoute(
        path: '/settings/export-backup',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ExportBackupManagementPage(),
      ),
      GoRoute(
        path: '/settings/units',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const _UnitSettingsPageWrapper(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/achievements',
            builder: (context, state) => const AchievementPage(),
          ),
          GoRoute(
            path: '/fish',
            builder: (context, state) => const FishListPage(),
          ),
          GoRoute(
            path: '/',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/equipment',
            builder: (context, state) => const EquipmentListPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
});

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: PremiumNavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: [
          PremiumNavigationDestination(
            icon: Icons.emoji_events_outlined,
            selectedIcon: Icons.emoji_events,
            label: strings.achievement,
          ),
          PremiumNavigationDestination(
            icon: Icons.list_alt_outlined,
            selectedIcon: Icons.list_alt,
            label: strings.fishList,
          ),
          PremiumNavigationDestination(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: strings.home,
          ),
          PremiumNavigationDestination(
            icon: Icons.hardware_outlined,
            selectedIcon: Icons.hardware,
            label: strings.equipment,
          ),
          PremiumNavigationDestination(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: strings.settings,
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/achievements')) return 0;
    if (location.startsWith('/fish')) return 1;
    if (location == '/') return 2;
    if (location.startsWith('/equipment')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 2;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/achievements');
        break;
      case 1:
        context.go('/fish');
        break;
      case 2:
        context.go('/');
        break;
      case 3:
        context.go('/equipment');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }
}

class _FishEditPageWrapper extends ConsumerWidget {
  final int fishId;

  const _FishEditPageWrapper({required this.fishId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);
    final state = ref.watch(fishDetailViewModelProvider(fishId));

    if (state.fish == null) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.fishDetail)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final fish = state.fish!;
    return _FishEditPage(fish: fish, strings: strings);
  }
}

class _FishEditPage extends StatelessWidget {
  final Map<String, dynamic> fish;
  final AppStrings strings;

  const _FishEditPage({required this.fish, required this.strings});

  @override
  Widget build(BuildContext context) {
    return FishEditPage(fish: fish, strings: strings);
  }
}

class _UnitSettingsPageWrapper extends StatelessWidget {
  const _UnitSettingsPageWrapper();

  @override
  Widget build(BuildContext context) {
    return const UnitSettingsPage();
  }
}
