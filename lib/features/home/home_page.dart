import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/providers/home_view_model.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/pending_recognition_providers.dart';
import '../../core/widgets/error_view.dart';
import '../../widgets/common/premium_button.dart';
import '../../widgets/common/premium_card.dart';
import '../camera/camera_page.dart';
import '../location/location_map_page.dart';
import '../settings/species_management_page.dart';
import '../stats/stats_detail_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);
    final homeState = ref.watch(homeViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: strings.mapLocation,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationMapPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: _HomePageBody(state: homeState, strings: strings),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PremiumButton(
            text: strings.recordCatch,
            icon: Icons.camera_alt,
            variant: PremiumButtonVariant.primary,
            isFullWidth: true,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CameraPage()),
              );
              ref.read(homeViewModelProvider.notifier).refresh();
            },
          ),
        ),
      ),
    );
  }
}

class _HomePageBody extends ConsumerWidget {
  final HomeState state;
  final AppStrings strings;

  const _HomePageBody({required this.state, required this.strings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return ErrorView(
        message: state.errorMessage!,
        onRetry: () => ref.read(homeViewModelProvider.notifier).refresh(),
        strings: strings,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(pendingRecognitionCountProvider);
        ref.invalidate(pendingRecognitionCatchesProvider);
        await ref.read(homeViewModelProvider.notifier).refresh();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _buildPendingRecognitionCard(context, ref, strings),
          _buildPodium(context),
          const SizedBox(height: 20),
          _buildStatCard(
            context,
            strings,
            strings.todayCatch,
            state.todayCount,
            state.todayRelease,
            state.todayKeep,
            state.todaySpecies,
            () {
              final now = DateTime.now();
              _navigateToDetail(
                context,
                strings.todayCatch,
                DateTime(now.year, now.month, now.day),
                DateTime(
                  now.year,
                  now.month,
                  now.day,
                ).add(const Duration(days: 1)),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            context,
            strings,
            strings.monthCatch,
            state.monthCount,
            state.monthRelease,
            state.monthKeep,
            state.monthSpecies,
            () {
              final now = DateTime.now();
              _navigateToDetail(
                context,
                strings.monthCatch,
                DateTime(now.year, now.month, 1),
                DateTime(now.year, now.month + 1, 1),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            context,
            strings,
            strings.yearCatch,
            state.yearCount,
            state.yearRelease,
            state.yearKeep,
            state.yearSpecies,
            () {
              final now = DateTime.now();
              _navigateToDetail(
                context,
                strings.yearCatch,
                DateTime(now.year, 1, 1),
                DateTime(now.year + 1, 1, 1),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            context,
            strings,
            strings.allCatch,
            state.allCount,
            state.allRelease,
            state.allKeep,
            state.allSpecies,
            () {
              final now = DateTime.now();
              _navigateToDetail(
                context,
                strings.allCatch,
                DateTime(2000, 1, 1),
                DateTime(now.year + 1, 1, 1),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _navigateToDetail(
    BuildContext context,
    String title,
    DateTime start,
    DateTime end,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            StatsDetailPage(title: title, startDate: start, endDate: end),
      ),
    );
  }

  Widget _buildPodium(BuildContext context) {
    if (state.top3Fishes.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                strings.noCatchYet,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                strings.goCatchFish,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final fishes = List<Map<String, dynamic>>.from(state.top3Fishes);
    fishes.sort(
      (a, b) => (b['length'] as double).compareTo(a['length'] as double),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                strings.personalRecord,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (fishes.length >= 2)
                _buildMedalCard(
                  context,
                  fishes[1],
                  2,
                  AppColors.silver,
                  AppColors.silver,
                )
              else
                _buildEmptyMedal(context),
              _buildMedalCard(
                context,
                fishes[0],
                1,
                AppColors.gold,
                AppColors.gold,
              ),
              if (fishes.length >= 3)
                _buildMedalCard(
                  context,
                  fishes[2],
                  3,
                  AppColors.bronze,
                  AppColors.bronze,
                )
              else
                _buildEmptyMedal(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMedal(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.help_outline,
          size: 28,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildMedalCard(
    BuildContext context,
    Map<String, dynamic> fish,
    int rank,
    Color mainColor,
    Color textColor,
  ) {
    final species = fish['species'] as String;
    final length = fish['length'] as double;

    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: rank == 1
                    ? [AppColors.gold, AppColors.gold]
                    : rank == 2
                        ? [AppColors.silver, AppColors.silver]
                        : [AppColors.bronze, AppColors.bronze],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: mainColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: rank == 1
                  ? const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 26,
                    )
                  : Text(
                      '$rank',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            species,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            '${length.toStringAsFixed(1)}cm',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    AppStrings strings,
    String title,
    int count,
    int release,
    int keep,
    Map<String, int> species,
    VoidCallback onTap,
  ) {
    return PremiumCard(
      variant: PremiumCardVariant.standard,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text(
                '$count ${strings.fishCountUnit}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatBadge(
                icon: Icons.water_drop,
                label: strings.release,
                count: release,
                color: AppColors.success,
              ),
              const SizedBox(width: 12),
              _StatBadge(
                icon: Icons.restaurant,
                label: strings.keep,
                count: keep,
                color: AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRecognitionCard(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) {
    final pendingCountAsync = ref.watch(pendingRecognitionCountProvider);

    return pendingCountAsync.when(
      data: (count) {
        if (count <= 0) return const SizedBox.shrink();
        return PremiumCard(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SpeciesManagementPage(),
              ),
            );
          },
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '你有 $count 条鱼获待识别品种',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      '点击前往品种管理',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: $count',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
