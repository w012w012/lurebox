import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/animation_constants.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/providers/home_view_model.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/providers/pending_recognition_providers.dart';
import 'package:lurebox/core/widgets/error_view.dart';
import 'package:lurebox/widgets/common/premium_card.dart';
import 'package:lurebox/widgets/common/staggered_reveal.dart';

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
      ),
      body: _HomePageBody(state: homeState, strings: strings),
    );
  }
}

class _HomePageBody extends ConsumerStatefulWidget {

  const _HomePageBody({required this.state, required this.strings});
  final HomeState state;
  final AppStrings strings;

  @override
  ConsumerState<_HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends ConsumerState<_HomePageBody>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _fadeAnimations;
  static const int _itemCount = 7; // pending, podium, (index 2 reserved), 4 stat cards

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startStaggeredAnimation();
  }

  void _initAnimations() {
    _controllers = List.generate(
      _itemCount,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 330),
        vsync: this,
      ),
    );

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: TeslaTheme.transitionCurve),
      );
    }).toList();
  }

  void _startStaggeredAnimation() {
    for (var i = 0; i < _itemCount; i++) {
      Future.delayed(AnimationConstants.staggerDelay * i, () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final errorMessage = widget.state.errorMessage;
    if (errorMessage != null) {
      return ErrorView(
        message: errorMessage,
        onRetry: () => ref.read(homeViewModelProvider.notifier).refresh(),
        strings: widget.strings,
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
          // Item 0: Pending recognition card
          StaggeredReveal.withAnimation(animation: _fadeAnimations[0], child: _buildPendingRecognitionCard(context, ref)),
          const SizedBox(height: 12),
          // Item 1: Podium
          StaggeredReveal.withAnimation(animation: _fadeAnimations[1], child: _buildPodium(context)),
          const SizedBox(height: 12),
          // Item 3: Today stat card
          StaggeredReveal.withAnimation(
              animation: _fadeAnimations[3],
              child: _buildStatCard(
                context,
                widget.strings,
                widget.strings.todayCatch,
                widget.state.todayCount,
                widget.state.todayRelease,
                widget.state.todayKeep,
                widget.state.todaySpecies,
                () {
                  final now = DateTime.now();
                  _navigateToDetail(
                    context,
                    widget.strings.todayCatch,
                    DateTime(now.year, now.month, now.day),
                    DateTime(
                      now.year,
                      now.month,
                      now.day,
                    ).add(const Duration(days: 1)),
                  );
                },
              ),),
          const SizedBox(height: 12),
          // Item 4: Month stat card
          StaggeredReveal.withAnimation(
              animation: _fadeAnimations[4],
              child: _buildStatCard(
                context,
                widget.strings,
                widget.strings.monthCatch,
                widget.state.monthCount,
                widget.state.monthRelease,
                widget.state.monthKeep,
                widget.state.monthSpecies,
                () {
                  final now = DateTime.now();
                  _navigateToDetail(
                    context,
                    widget.strings.monthCatch,
                    DateTime(now.year, now.month),
                    DateTime(now.year, now.month + 1),
                  );
                },
              ),),
          const SizedBox(height: 12),
          // Item 5: Year stat card
          StaggeredReveal.withAnimation(
              animation: _fadeAnimations[5],
              child: _buildStatCard(
                context,
                widget.strings,
                widget.strings.yearCatch,
                widget.state.yearCount,
                widget.state.yearRelease,
                widget.state.yearKeep,
                widget.state.yearSpecies,
                () {
                  final now = DateTime.now();
                  _navigateToDetail(
                    context,
                    widget.strings.yearCatch,
                    DateTime(now.year),
                    DateTime(now.year + 1),
                  );
                },
              ),),
          const SizedBox(height: 12),
          // Item 6: All catch stat card
          StaggeredReveal.withAnimation(
              animation: _fadeAnimations[6],
              child: _buildStatCard(
                context,
                widget.strings,
                widget.strings.allCatch,
                widget.state.allCount,
                widget.state.allRelease,
                widget.state.allKeep,
                widget.state.allSpecies,
                () {
                  final now = DateTime.now();
                  _navigateToDetail(
                    context,
                    widget.strings.allCatch,
                    DateTime(2000),
                    DateTime(now.year + 1),
                  );
                },
              ),),
          const SizedBox(height: 24),
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
    context.push(
      '/stats?title=${Uri.encodeComponent(title)}&start=${start.toIso8601String()}&end=${end.toIso8601String()}',
    );
  }

  Widget _buildPodium(BuildContext context) {
    if (widget.state.top3Fishes.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: TeslaColors.lightAsh,
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          border: Border.all(
            color: TeslaColors.cloudGray,
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
                widget.strings.noCatchYet,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.strings.goCatchFish,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final fishes = List<FishCatch>.from(widget.state.top3Fishes)
      ..sort((a, b) => b.length.compareTo(a.length));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TeslaColors.white,
        borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
        border: Border.all(
          color: TeslaColors.cloudGray,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.strings.personalRecord,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
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
    FishCatch fish,
    int rank,
    Color mainColor,
    Color textColor,
  ) {
    final species = fish.species;
    final length = fish.length;

    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: mainColor,
              shape: BoxShape.circle,
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
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            species,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            '${length.toStringAsFixed(1)}cm',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
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
                color: TeslaColors.electricBlue,
              ),
              const SizedBox(width: 12),
              _StatBadge(
                icon: Icons.restaurant,
                label: strings.keep,
                count: keep,
                color: TeslaColors.electricBlue,
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
  ) {
    final strings = ref.watch(currentStringsProvider);
    final pendingCountAsync = ref.watch(pendingRecognitionCountProvider);

    return pendingCountAsync.when(
      data: (count) {
        if (count <= 0) return const SizedBox.shrink();
        return PremiumCard(
          onTap: () {
            context.push('/species');
          },
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: TeslaColors.electricBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.pendingFishCountPattern
                          .replaceAll('%d', '$count'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      strings.goToSpeciesManagement,
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

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });
  final IconData icon;
  final String label;
  final int count;
  final Color color;

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
