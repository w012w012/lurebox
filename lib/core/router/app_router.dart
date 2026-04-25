import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/providers/fish_detail_view_model.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/providers/onboarding_provider.dart';
import 'package:lurebox/features/achievement/achievement_page.dart';
import 'package:lurebox/features/camera/camera_page.dart';
import 'package:lurebox/features/equipment/equipment_edit_page.dart';
import 'package:lurebox/features/equipment/equipment_list_page.dart';
import 'package:lurebox/features/equipment/equipment_overview_page.dart';
import 'package:lurebox/features/fish_detail/fish_detail_page.dart';
import 'package:lurebox/features/fish_detail/widgets/fish_edit_page.dart';
import 'package:lurebox/features/fish_list/fish_list_page.dart';
import 'package:lurebox/features/home/home_page.dart';
import 'package:lurebox/features/me/backup_export_page.dart';
import 'package:lurebox/features/me/me_page.dart';
import 'package:lurebox/features/me/me_settings_page.dart';
import 'package:lurebox/features/onboarding/onboarding_page.dart';
import 'package:lurebox/features/settings/ai_recognition_settings_page.dart';
import 'package:lurebox/features/settings/export_backup_management_page.dart';
import 'package:lurebox/features/settings/location_management_page.dart';
import 'package:lurebox/features/settings/settings_page.dart';
import 'package:lurebox/features/settings/species_management_page.dart';
import 'package:lurebox/features/settings/watermark_settings_page.dart';
import 'package:lurebox/features/settings/widgets/settings_units_section.dart';
import 'package:lurebox/features/stats/stats_detail_page.dart';
import 'package:lurebox/widgets/common/premium_navigation_bar.dart';

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
          final fishId = int.tryParse(state.pathParameters['id'] ?? '');
          if (fishId == null) {
            return Consumer(
              builder: (context, ref, _) {
                final strings = ref.watch(currentStringsProvider);
                return Scaffold(
                  body: Center(child: Text(strings.invalidFishId)),
                );
              },
            );
          }
          return FishDetailPage(fishId: fishId);
        },
      ),
      GoRoute(
        path: '/fish/:id/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final fishId = int.tryParse(state.pathParameters['id'] ?? '');
          if (fishId == null) {
            return Consumer(
              builder: (context, ref, _) {
                final strings = ref.watch(currentStringsProvider);
                return Scaffold(
                  body: Center(child: Text(strings.invalidFishId)),
                );
              },
            );
          }
          return _FishEditPageWrapper(fishId: fishId);
        },
      ),
      GoRoute(
        path: '/camera',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CameraPage(),
      ),
      GoRoute(
        path: '/achievements',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AchievementPage(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsPage(),
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
            startDate: start != null
                ? (DateTime.tryParse(start) ?? DateTime.now())
                : DateTime.now(),
            endDate: end != null
                ? (DateTime.tryParse(end) ?? DateTime.now())
                : DateTime.now(),
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
          const allowedTypes = {'rod', 'reel', 'lure', 'line'};
          final rawType = state.uri.queryParameters['type'] ?? 'rod';
          final type = allowedTypes.contains(rawType) ? rawType : 'rod';
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
  GoRoute(
      path: '/me/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MeSettingsPage(),
    ),
  GoRoute(
      path: '/me/backup-export',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BackupExportPage(),
    ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/fish',
            builder: (context, state) => const FishListPage(),
          ),
          GoRoute(
            path: '/equipment',
            builder: (context, state) => const EquipmentListPage(),
          ),
          GoRoute(
            path: '/me',
            builder: (context, state) => const MePage(),
          ),
        ],
      ),
    ],
  );
});

class MainShell extends ConsumerWidget {

  const MainShell({required this.child, super.key});
  final Widget child;

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
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: strings.home,
          ),
          PremiumNavigationDestination(
            icon: Icons.list_alt_outlined,
            selectedIcon: Icons.list_alt,
            label: strings.fishList,
          ),
          PremiumNavigationDestination(
            icon: Icons.hardware_outlined,
            selectedIcon: Icons.hardware,
            label: strings.equipment,
          ),
          PremiumNavigationDestination(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: strings.me,
          ),
        ],
        showCenterFab: true,
        onCenterFabPressed: () => context.push('/camera'),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    // tabs[0]=home→Row[0], tabs[1]=fish→Row[1], tabs[2]=equipment→Row[3], tabs[3]=me→Row[4]
    // selectedIndex 是 tabs 数组索引，不是 Row 物理位置
    if (location == '/') return 0;
    if (location.startsWith('/fish')) return 1;
    if (location.startsWith('/equipment')) return 2;
    if (location.startsWith('/me')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    // tabs[0]=home, tabs[1]=fish, tabs[2]=equipment, tabs[3]=me
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        context.go('/fish');
      case 2:
        context.go('/equipment');
      case 3:
        context.go('/me');
    }
  }
}

class _FishEditPageWrapper extends ConsumerWidget {

  const _FishEditPageWrapper({required this.fishId});
  final int fishId;

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

  const _FishEditPage({required this.fish, required this.strings});
  final Map<String, dynamic> fish;
  final AppStrings strings;

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
