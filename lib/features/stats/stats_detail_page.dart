import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/services/app_logger.dart';
import 'package:lurebox/core/utils/file_utils.dart';
import 'package:lurebox/core/utils/unit_converter.dart';
import 'package:lurebox/features/stats/widgets/catch_trend_chart.dart';
import 'package:lurebox/features/stats/widgets/location_stats_card.dart';
import 'package:lurebox/features/stats/widgets/monthly_stats_card.dart';
import 'package:lurebox/features/stats/widgets/species_distribution_chart.dart';
import 'package:lurebox/features/stats/widgets/stats_summary_card.dart';
import 'package:lurebox/widgets/common/premium_card.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class StatsDetailPage extends ConsumerStatefulWidget {
  const StatsDetailPage({
    required this.title,
    required this.startDate,
    required this.endDate,
    super.key,
    this.speciesStats,
  });
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, int>? speciesStats;

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

  /// Safe accessors for Map values — avoid `as` crash on null/wrong type
  static String _s(Map<String, dynamic> m, String k) => m[k]?.toString() ?? '';
  static double? _d(Map<String, dynamic> m, String k) {
    final v = m[k];
    if (v is num) return v.toDouble();
    return null;
  }

  static int _i(Map<String, dynamic> m, String k) {
    final v = m[k];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  static DateTime? _dt(Map<String, dynamic> m, String k) {
    final v = m[k]?.toString();
    if (v == null || v.isEmpty) return null;
    return DateTime.tryParse(v);
  }

  Map<String, int> _rodDistribution = {};
  Map<String, int> _reelDistribution = {};
  Map<String, int> _lureDistribution = {};
  Map<String, Map<String, int>> _locationAnalysis = {};
  Map<String, int> _trendData = {};
  String _trendTitle = '';
  String _trendType = 'day';
  bool _isLoading = true;
  String? _errorMessage;
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
      duration: TeslaTheme.transitionDuration,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _contentAnimationController,
      curve: TeslaTheme.transitionCurve,
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
      if (!mounted) return;
      final catches = fishList.map((f) => f.toMap()).toList();

      final speciesMap = <String, int>{};
      for (final fish in catches) {
        final species = _s(fish, 'species');
        speciesMap[species] = (speciesMap[species] ?? 0) + 1;
      }

      final speciesData = <String, Map<String, dynamic>>{};
      for (final fish in catches) {
        final species = _s(fish, 'species');
        if (!speciesData.containsKey(species)) {
          speciesData[species] = {
            'species': species,
            'count': 0,
            'totalWeight': 0.0,
          };
        }
        speciesData[species]!['count'] = _i(speciesData[species]!, 'count') + 1;
        final weight = _d(fish, 'weight');
        final weightUnit =
            _s(fish, 'weight_unit').isEmpty ? 'kg' : _s(fish, 'weight_unit');
        if (weight != null) {
          // Convert to display unit before summing
          final displayWeight = UnitConverter.convertWeight(
            weight,
            weightUnit,
            displayUnits.fishWeightUnit,
          );
          speciesData[species]!['totalWeight'] =
              (_d(speciesData[species]!, 'totalWeight') ?? 0.0) + displayWeight;
        }
      }
      final speciesSummary = speciesData.values.toList()
        ..sort((a, b) => _i(b, 'count').compareTo(_i(a, 'count')));

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
      AppLogger.e('StatsDetailPage', 'Failed to load detail data', e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _calculateLocationAnalysis(List<Map<String, dynamic>> catches) {
    final locationMap = <String, Map<String, int>>{};
    for (final fish in catches) {
      final location =
          _s(fish, 'location_name').isEmpty ? null : _s(fish, 'location_name');
      if (location == null || location.isEmpty) continue;
      final species = _s(fish, 'species');
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
      final s = _s(species, 'species');
      final weight = _d(species, 'totalWeight') ?? 0.0;
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
      for (var h = 0; h < 24; h++) {
        trendMap['$h${strings.hour}'] = 0;
      }
      for (final fish in catches) {
        final t = _dt(fish, 'catch_time') ?? DateTime.now();
        final key = '${t.hour}${strings.hour}';
        trendMap[key] = (trendMap[key] ?? 0) + 1;
      }
    } else if (widget.title.contains(strings.month)) {
      _trendTitle = strings.dailyTrend;
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      for (var d = 1; d <= daysInMonth; d++) {
        trendMap['$d${strings.day}'] = 0;
      }
      for (final fish in catches) {
        final t = _dt(fish, 'catch_time') ?? DateTime.now();
        if (t.month == now.month && t.year == now.year) {
          final key = '${t.day}${strings.day}';
          trendMap[key] = (trendMap[key] ?? 0) + 1;
        }
      }
    } else if (widget.title.contains(strings.year)) {
      _trendTitle = strings.monthlyTrend;
      for (var m = 1; m <= 12; m++) {
        trendMap['$m${strings.monthUnit}'] = 0;
      }
      for (final fish in catches) {
        final t = _dt(fish, 'catch_time') ?? DateTime.now();
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
      for (var i = 29; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        trendMap['${d.month}/${d.day}'] = 0;
      }
      for (final fish in catches) {
        final t = _dt(fish, 'catch_time') ?? DateTime.now();
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
      for (var i = 11; i >= 0; i--) {
        final nowSub = DateTime(
          now.year,
          now.month,
        ).subtract(Duration(days: i * 30));
        final d = DateTime(nowSub.year, nowSub.month);
        trendMap['${d.month}${strings.monthUnit}'] = 0;
      }
      for (final fish in catches) {
        final t = _dt(fish, 'catch_time') ?? DateTime.now();
        final catchDate = DateTime(t.year, t.month);
        final nowDate = DateTime(now.year, now.month);
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
          ? (_dt(catches.last, 'catch_time') ?? DateTime.now()).year
          : now.year;
      for (var y = startYear; y <= now.year; y++) {
        trendMap['$y${strings.yearUnit}'] = 0;
      }
      for (final fish in catches) {
        final t = _dt(fish, 'catch_time') ?? DateTime.now();
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

      await Future<void>.delayed(const Duration(milliseconds: 100));
      final image = await boundary.toImage(pixelRatio: 2);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();

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
      AppLogger.e('StatsDetailPage', 'Failed to share stats', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.shareFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(currentStringsProvider);
    final displayUnits = ref.watch(appSettingsProvider).units;
    final isChinese = ref.watch(
      appSettingsProvider.select((s) => s.language == AppLanguage.chinese),
    );
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
                        color: TeslaColors.electricBlue,
                      ),
                    )
                  : const Icon(
                      Icons.share,
                      color: TeslaColors.electricBlue,
                    ),
              onPressed: _shareStats,
              tooltip: 'Share',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: TeslaColors.electricBlue,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(strings.error,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loadDetail,
                        child: Text(strings.retry),
                      ),
                    ],
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(TeslaTheme.spacingMd),
                        child: _buildContent(
                          totalCount,
                          releaseCount,
                          keepCount,
                          releaseRate,
                          strings,
                          displayUnits.fishWeightUnit,
                          isChinese,
                        ),
                      ),
                      Positioned(
                        left: -9999,
                        top: 0,
                        child: RepaintBoundary(
                          key: _repaintBoundaryKey,
                          child: Material(
                            color: TeslaColors.white,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(TeslaTheme.spacingMd),
                                child: _buildContent(
                                  totalCount,
                                  releaseCount,
                                  keepCount,
                                  releaseRate,
                                  strings,
                                  displayUnits.fishWeightUnit,
                                  isChinese,
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
    bool isChinese,
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
        const SizedBox(height: TeslaTheme.spacingMd),
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
            isChinese: isChinese,
          ),
          const SizedBox(height: TeslaTheme.spacingMd),
        ],
        if (_trendData.isNotEmpty) ...[
          CatchTrendChart(
            trendData: _trendData,
            trendTitle: _trendTitle,
            showDropdown: widget.title.contains(strings.all),
            trendType: _trendType,
            onTrendTypeChanged: _onTrendTypeChanged,
          ),
          const SizedBox(height: TeslaTheme.spacingMd),
        ],
        if (_locationAnalysis.isNotEmpty) ...[
          LocationStatsCard(
            locationAnalysis: _locationAnalysis,
            strings: strings,
            showDetails: _showLocationDetails,
            onToggleDetails: () {
              setState(() {
                _showLocationDetails = !_showLocationDetails;
              });
            },
          ),
          const SizedBox(height: TeslaTheme.spacingMd),
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
          const SizedBox(height: TeslaTheme.spacingMicro),
        ],
        if (_rodDistribution.isNotEmpty)
          EquipmentChart(
            title: strings.rodDistribution,
            data: _rodDistribution,
            color: TeslaColors.electricBlue,
            strings: strings,
          ),
        if (_reelDistribution.isNotEmpty)
          EquipmentChart(
            title: strings.reelDistribution,
            data: _reelDistribution,
            color: TeslaColors.electricBlue,
            strings: strings,
          ),
        if (_lureDistribution.isNotEmpty)
          EquipmentChart(
            title: strings.lureDistribution,
            data: _lureDistribution,
            color: TeslaColors.electricBlue,
            strings: strings,
          ),
        if (_catches.isEmpty)
          PremiumCard(
            variant: PremiumCardVariant.flat,
            child: Padding(
              padding: const EdgeInsets.all(TeslaTheme.spacingXl),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 60,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: TeslaTheme.spacingMd),
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
        const SizedBox(height: TeslaTheme.spacingLg),
      ],
    );
  }
}
