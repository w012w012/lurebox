import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/design/theme/app_theme.dart';
import '../../core/design/theme/animation_constants.dart';
import '../../core/di/di.dart';
import '../../core/models/fish_catch.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/app_settings_provider.dart';
import '../../core/utils/file_utils.dart';
import '../../core/utils/unit_converter.dart';
import '../../widgets/common/premium_card.dart';
import '../../widgets/stats/catch_trend_chart.dart';
import '../../widgets/stats/species_distribution_chart.dart';
import '../../widgets/stats/monthly_stats_card.dart';
import '../../widgets/stats/location_stats_card.dart';
import '../../widgets/stats/stats_summary_card.dart';

class StatsDetailPage extends ConsumerStatefulWidget {
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, int>? speciesStats;

  const StatsDetailPage({
    super.key,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.speciesStats,
  });

  @override
  ConsumerState<StatsDetailPage> createState() => _StatsDetailPageState();
}

class _StatsDetailPageState extends ConsumerState<StatsDetailPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  List<Map<String, dynamic>> _catches = [];
  Map<String, int> _speciesStats = {};
  Map<String, double> _speciesWeightStats = {};
  List<Map<String, dynamic>> _speciesSummary = [];
  Map<String, int> _rodDistribution = {};
  Map<String, int> _reelDistribution = {};
  Map<String, int> _lureDistribution = {};
  Map<String, Map<String, int>> _locationAnalysis = {};
  Map<String, int> _trendData = {};
  String _trendTitle = '';
  String _trendType = 'day';
  bool _isLoading = true;
  bool _isSharing = false;
  bool _showByWeight = false;
  bool _showLocationDetails = true;
  double _totalWeight = 0;

  late final AnimationController _contentAnimationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _contentAnimationController = AnimationController(
      duration: AnimationConstants.pageTransitionDuration,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _contentAnimationController,
      curve: AnimationConstants.defaultCurve,
    );
    _loadDetail();
  }

  @override
  void dispose() {
    _contentAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    try {
      final displayUnits = ref.read(appSettingsProvider).units;
      final fishList = await ref
          .read(fishCatchServiceProvider)
          .getByDateRange(widget.startDate, widget.endDate);
      final catches = fishList.map((f) => f.toMap()).toList();

      final speciesMap = <String, int>{};
      for (final fish in catches) {
        final species = fish['species'] as String;
        speciesMap[species] = (speciesMap[species] ?? 0) + 1;
      }

      final speciesData = <String, Map<String, dynamic>>{};
      for (final fish in catches) {
        final species = fish['species'] as String;
        if (!speciesData.containsKey(species)) {
          speciesData[species] = {
            'species': species,
            'count': 0,
            'totalWeight': 0.0,
          };
        }
        speciesData[species]!['count'] =
            (speciesData[species]!['count'] as int) + 1;
        final weight = fish['weight'] as double?;
        final weightUnit = fish['weight_unit'] as String? ?? 'kg';
        if (weight != null) {
          // Convert to display unit before summing
          final displayWeight = UnitConverter.convertWeight(
            weight,
            weightUnit,
            displayUnits.fishWeightUnit,
          );
          speciesData[species]!['totalWeight'] =
              (speciesData[species]!['totalWeight'] as double) + displayWeight;
        }
      }
      final speciesSummary = speciesData.values.toList()
        ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      _rodDistribution =
          await ref.read(fishCatchServiceProvider).getEquipmentDistribution(
                'rod',
                startDate: widget.startDate,
                endDate: widget.endDate,
              );
      _reelDistribution =
          await ref.read(fishCatchServiceProvider).getEquipmentDistribution(
                'reel',
                startDate: widget.startDate,
                endDate: widget.endDate,
              );
      _lureDistribution =
          await ref.read(fishCatchServiceProvider).getEquipmentDistribution(
                'lure',
                startDate: widget.startDate,
                endDate: widget.endDate,
              );

      final strings = ref.read(currentStringsProvider);
      _calculateTrend(catches, strings);
      _calculateLocationAnalysis(catches);

      if (mounted) {
        setState(() {
          _catches = catches;
          _speciesStats = speciesMap;
          _speciesSummary = speciesSummary;
          _calculateWeightStats();
          _isLoading = false;
        });
        _contentAnimationController.forward();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _calculateLocationAnalysis(List<Map<String, dynamic>> catches) {
    final locationMap = <String, Map<String, int>>{};
    for (final fish in catches) {
      final location = fish['location_name'] as String?;
      if (location == null || location.isEmpty) continue;
      final species = fish['species'] as String;
      if (!locationMap.containsKey(location)) {
        locationMap[location] = {};
      }
      locationMap[location]![species] =
          (locationMap[location]![species] ?? 0) + 1;
    }
    _locationAnalysis = locationMap;
  }

  void _calculateWeightStats() {
    _speciesWeightStats = {};
    _totalWeight = 0;
    for (final species in _speciesSummary) {
      final s = species['species'] as String;
      final weight = (species['totalWeight'] as num?)?.toDouble() ?? 0.0;
      _speciesWeightStats[s] = weight;
      _totalWeight += weight;
    }
  }

  void _toggleShowByWeight() {
    setState(() {
      _showByWeight = !_showByWeight;
    });
  }

  void _calculateTrend(List<Map<String, dynamic>> catches, AppStrings strings) {
    final now = DateTime.now();
    final trendMap = <String, int>{};

    if (widget.title.contains(strings.today)) {
      _trendTitle = strings.hourlyTrend;
      for (int h = 0; h < 24; h++) {
        trendMap['$h${strings.hour}'] = 0;
      }
      for (final fish in catches) {
        final t = DateTime.parse(fish['catch_time'] as String);
        final key = '${t.hour}${strings.hour}';
        trendMap[key] = (trendMap[key] ?? 0) + 1;
      }
    } else if (widget.title.contains(strings.month)) {
      _trendTitle = strings.dailyTrend;
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      for (int d = 1; d <= daysInMonth; d++) {
        trendMap['$d${strings.day}'] = 0;
      }
      for (final fish in catches) {
        final t = DateTime.parse(fish['catch_time'] as String);
        if (t.month == now.month && t.year == now.year) {
          final key = '${t.day}${strings.day}';
          trendMap[key] = (trendMap[key] ?? 0) + 1;
        }
      }
    } else if (widget.title.contains(strings.year)) {
      _trendTitle = strings.monthlyTrend;
      for (int m = 1; m <= 12; m++) {
        trendMap['$m${strings.monthUnit}'] = 0;
      }
      for (final fish in catches) {
        final t = DateTime.parse(fish['catch_time'] as String);
        if (t.year == now.year) {
          final key = '${t.month}${strings.monthUnit}';
          trendMap[key] = (trendMap[key] ?? 0) + 1;
        }
      }
    } else {
      _calculateAllTrend(catches, strings);
      return;
    }
    _trendData = trendMap;
  }

  void _calculateAllTrend(
    List<Map<String, dynamic>> catches,
    AppStrings strings,
  ) {
    final now = DateTime.now();
    final trendMap = <String, int>{};

    if (_trendType == 'day') {
      _trendTitle = strings.last30Days;
      for (int i = 29; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        trendMap['${d.month}/${d.day}'] = 0;
      }
      for (final fish in catches) {
        final t = DateTime.parse(fish['catch_time'] as String);
        final diff = now.difference(t).inDays;
        if (diff >= 0 && diff < 30) {
          final key = '${t.month}/${t.day}';
          if (trendMap.containsKey(key)) {
            trendMap[key] = (trendMap[key] ?? 0) + 1;
          }
        }
      }
    } else if (_trendType == 'month') {
      _trendTitle = strings.last12Months;
      for (int i = 11; i >= 0; i--) {
        final nowSub = DateTime(
          now.year,
          now.month,
          1,
        ).subtract(Duration(days: i * 30));
        final d = DateTime(nowSub.year, nowSub.month, 1);
        trendMap['${d.month}${strings.monthUnit}'] = 0;
      }
      for (final fish in catches) {
        final t = DateTime.parse(fish['catch_time'] as String);
        final catchDate = DateTime(t.year, t.month, 1);
        final nowDate = DateTime(now.year, now.month, 1);
        final diffMonths = (nowDate.year - catchDate.year) * 12 +
            nowDate.month -
            catchDate.month;
        if (diffMonths >= 0 && diffMonths < 12) {
          final key = '${t.month}${strings.monthUnit}';
          if (trendMap.containsKey(key)) {
            trendMap[key] = (trendMap[key] ?? 0) + 1;
          }
        }
      }
    } else {
      _trendTitle = strings.yearlyTrend;
      final startYear = catches.isNotEmpty
          ? DateTime.parse(catches.last['catch_time'] as String).year
          : now.year;
      for (int y = startYear; y <= now.year; y++) {
        trendMap['$y${strings.yearUnit}'] = 0;
      }
      for (final fish in catches) {
        final t = DateTime.parse(fish['catch_time'] as String);
        final key = '${t.year}${strings.yearUnit}';
        if (trendMap.containsKey(key)) {
          trendMap[key] = (trendMap[key] ?? 0) + 1;
        }
      }
    }
    _trendData = trendMap;
  }

  void _onTrendTypeChanged(String type) {
    final strings = ref.read(currentStringsProvider);
    setState(() {
      _trendType = type;
      _calculateAllTrend(_catches, strings);
    });
  }

  Future<void> _shareStats() async {
    final strings = ref.read(currentStringsProvider);
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      await Future.delayed(const Duration(milliseconds: 100));
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/${FileUtils.generateUniqueFileName('stats', 'png')}',
      );
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            '${widget.title} - ${strings.catchStatistics}\n${strings.fromLureBox}',
      );
    } catch (e) {
      debugPrint('${strings.shareFailed}: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${strings.shareFailed}: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(currentStringsProvider);
    final displayUnits = ref.watch(appSettingsProvider).units;
    final releaseCount =
        _catches.where((f) => f['fate'] == FishFateType.release.value).length;
    final keepCount =
        _catches.where((f) => f['fate'] == FishFateType.keep.value).length;
    final totalCount = _catches.length;
    final releaseRate =
        totalCount > 0 ? (releaseCount / totalCount * 100) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          if (!_isLoading && totalCount > 0)
            IconButton(
              icon: _isSharing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accentLight,
                      ),
                    )
                  : Icon(
                      Icons.share,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.accentDark
                          : AppColors.accentLight,
                    ),
              onPressed: _shareStats,
              tooltip: strings.share,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.accentLight,
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    child: _buildContent(
                      totalCount,
                      releaseCount,
                      keepCount,
                      releaseRate,
                      strings,
                      displayUnits.fishWeightUnit,
                    ),
                  ),
                  Positioned(
                    left: -9999,
                    top: 0,
                    child: RepaintBoundary(
                      key: _repaintBoundaryKey,
                      child: Material(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.spacingLg),
                            child: _buildContent(
                              totalCount,
                              releaseCount,
                              keepCount,
                              releaseRate,
                              strings,
                              displayUnits.fishWeightUnit,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildContent(
    int totalCount,
    int releaseCount,
    int keepCount,
    double releaseRate,
    AppStrings strings,
    String weightUnit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonthlyStatsCard(
          title: widget.title,
          totalCount: totalCount,
          releaseCount: releaseCount,
          keepCount: keepCount,
          releaseRate: releaseRate,
        ),
        const SizedBox(height: AppTheme.spacingLg),
        if (_speciesStats.isNotEmpty) ...[
          SpeciesDistributionChart(
            speciesStats: _speciesStats,
            speciesWeightStats: _speciesWeightStats,
            totalCount: totalCount,
            totalWeight: _totalWeight,
            showByWeight: _showByWeight,
            onToggleShowByWeight: _toggleShowByWeight,
            strings: strings,
            weightUnit: weightUnit,
          ),
          const SizedBox(height: AppTheme.spacingLg),
        ],
        if (_trendData.isNotEmpty) ...[
          CatchTrendChart(
            trendData: _trendData,
            trendTitle: _trendTitle,
            showDropdown: widget.title.contains(strings.all),
            trendType: _trendType,
            onTrendTypeChanged: _onTrendTypeChanged,
          ),
          const SizedBox(height: AppTheme.spacingLg),
        ],
        if (_locationAnalysis.isNotEmpty) ...[
          LocationStatsCard(
            locationAnalysis: _locationAnalysis,
            showDetails: _showLocationDetails,
            onToggleDetails: () {
              setState(() {
                _showLocationDetails = !_showLocationDetails;
              });
            },
          ),
          const SizedBox(height: AppTheme.spacingLg),
        ],
        if (_rodDistribution.isNotEmpty ||
            _reelDistribution.isNotEmpty ||
            _lureDistribution.isNotEmpty) ...[
          Text(
            strings.equipmentDistribution,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],
        if (_rodDistribution.isNotEmpty)
          EquipmentChart(
            title: strings.rodDistribution,
            data: _rodDistribution,
            color: AppColors.accentLight,
          ),
        if (_reelDistribution.isNotEmpty)
          EquipmentChart(
            title: strings.reelDistribution,
            data: _reelDistribution,
            color: AppColors.keep,
          ),
        if (_lureDistribution.isNotEmpty)
          EquipmentChart(
            title: strings.lureDistribution,
            data: _lureDistribution,
            color: AppColors.purple,
          ),
        if (_catches.isEmpty)
          PremiumCard(
            variant: PremiumCardVariant.flat,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingXxl),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 60,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    Text(
                      strings.noData,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: AppTheme.spacingXl),
        _buildFooter(strings),
        const SizedBox(height: AppTheme.spacingLg),
      ],
    );
  }

  Widget _buildFooter(AppStrings strings) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacingMd,
        horizontal: AppTheme.spacingXl,
      ),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.set_meal, color: Colors.white, size: 20),
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            strings.appName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            strings.yourFishingAssistant,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
