import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/design/theme/app_colors.dart';
import '../../core/constants/strings.dart';
import '../../core/constants/price_ranges.dart';
import '../../core/models/equipment.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/equipment_view_model.dart';
import '../../core/utils/file_utils.dart';
import '../../widgets/common/distribution_chart.dart';
import '../../widgets/common/premium_button.dart';
import '../../widgets/common/premium_card.dart';

class EquipmentOverviewPage extends ConsumerStatefulWidget {
  const EquipmentOverviewPage({super.key});

  @override
  ConsumerState<EquipmentOverviewPage> createState() =>
      _EquipmentOverviewPageState();
}

class _EquipmentOverviewPageState extends ConsumerState<EquipmentOverviewPage> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isSharing = false;
  final int _selectedCatchTab = 0;

  Future<void> _shareStats() async {
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
        '${tempDir.path}/${FileUtils.generateUniqueFileName('equipment_overview', 'png')}',
      );
      await file.writeAsBytes(pngBytes);

      final strings = ref.read(currentStringsProvider);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: '${strings.myEquipment} - ${strings.fromLureBox}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('分享失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(equipmentListViewModelProvider);
    final strings = ref.watch(currentStringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.equipmentOverview),
        centerTitle: true,
        actions: [
          if (state.rodList.isNotEmpty ||
              state.reelList.isNotEmpty ||
              state.lureList.isNotEmpty)
            PremiumIconButton(
              icon: Icons.share,
              onPressed: _isSharing ? null : _shareStats,
              tooltip: strings.share,
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: RepaintBoundary(
                key: _repaintBoundaryKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuantityChart(state, strings),
                    const SizedBox(height: 16),
                    _buildCatchRanking(state, strings),
                    const SizedBox(height: 16),
                    if (state.rodList.isNotEmpty) ...[
                      _buildRodCharts(state.rodList, strings),
                      const SizedBox(height: 16),
                    ],
                    if (state.reelList.isNotEmpty) ...[
                      _buildReelCharts(state.reelList, strings),
                      const SizedBox(height: 16),
                    ],
                    if (state.lureList.isNotEmpty) ...[
                      _buildLureCharts(state.lureList, strings),
                      const SizedBox(height: 16),
                    ],
                    _buildSoftWormAnalytics(state, strings),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuantityChart(EquipmentListState state, AppStrings strings) {
    final rodCount = state.rodList.length;
    final reelCount = state.reelList.length;
    final lureCount = state.lureList.length;
    final maxCount = [
      rodCount,
      reelCount,
      lureCount,
    ].reduce((a, b) => a > b ? a : b);

    return PremiumCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.quantityStats,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (maxCount + 2).toDouble(),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: rodCount.toDouble(),
                          color: AppColors.chartColors[0],
                          width: 32,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: reelCount.toDouble(),
                          color: AppColors.chartColors[3],
                          width: 32,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: lureCount.toDouble(),
                          color: AppColors.chartColors[2],
                          width: 32,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ],
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String label;
                        String unit;
                        switch (group.x.toInt()) {
                          case 0:
                            label = strings.rod;
                            unit = '支';
                            break;
                          case 1:
                            label = strings.reel;
                            unit = '只';
                            break;
                          case 2:
                            label = strings.lure;
                            unit = '种';
                            break;
                          default:
                            return null;
                        }
                        return BarTooltipItem(
                          '$label\n${rod.toY.toInt()}$unit',
                          const TextStyle(
                            color: AppColors.surfaceLight,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return Text(
                                '$rodCount支',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            case 1:
                              return Text(
                                '$reelCount只',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            case 2:
                              return Text(
                                '$lureCount种',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return Text(
                                strings.rod,
                                style: const TextStyle(fontSize: 11),
                              );
                            case 1:
                              return Text(
                                strings.reel,
                                style: const TextStyle(fontSize: 11),
                              );
                            case 2:
                              return Text(
                                strings.lure,
                                style: const TextStyle(fontSize: 11),
                              );
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatchRanking(EquipmentListState state, AppStrings strings) {
    final rodStats = _getTop5Equipment(state.equipmentStats, state.rodList);
    final reelStats = _getTop5Equipment(state.equipmentStats, state.reelList);
    final lureStats = _getTop5Equipment(state.equipmentStats, state.lureList);

    final currentStats = _selectedCatchTab == 0
        ? rodStats
        : _selectedCatchTab == 1
            ? reelStats
            : lureStats;

    return PremiumCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events,
                    color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Text(
                  strings.equipmentCatchRanking,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (currentStats.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    strings.noCatchData,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...currentStats.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final stat = entry.value;
                final equipmentName = _getEquipmentName(
                  stat.key,
                  state,
                  strings,
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: rank == 1
                              ? AppColors.gold
                              : rank == 2
                                  ? AppColors.silver
                                  : rank == 3
                                      ? AppColors.bronze
                                      : AppColors.secondaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$rank',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.surfaceLight,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          equipmentName,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${stat.value}${strings.fishCountUnit}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  List<MapEntry<int, int>> _getTop5Equipment(
    Map<int, Map<String, int>> stats,
    List<Equipment> equipmentList,
  ) {
    final equipmentIds = equipmentList.map((e) => e.id).toSet();
    final filtered = <MapEntry<int, int>>[];

    for (final entry in stats.entries) {
      if (equipmentIds.contains(entry.key)) {
        final total = entry.value['_total'] ?? 0;
        if (total > 0) {
          filtered.add(MapEntry(entry.key, total));
        }
      }
    }

    filtered.sort((a, b) => b.value.compareTo(a.value));
    return filtered.take(5).toList();
  }

  String _getEquipmentName(
    int equipmentId,
    EquipmentListState state,
    AppStrings strings,
  ) {
    for (final rod in state.rodList) {
      if (rod.id == equipmentId) {
        return rod.displayName;
      }
    }
    for (final reel in state.reelList) {
      if (reel.id == equipmentId) {
        return reel.displayName;
      }
    }
    for (final lure in state.lureList) {
      if (lure.id == equipmentId) {
        final parts = <String>[];
        if (lure.brand?.isNotEmpty == true) parts.add(lure.brand!);
        if (lure.model?.isNotEmpty == true) parts.add(lure.model!);
        if (lure.lureSize?.isNotEmpty == true) parts.add(lure.lureSize!);
        if (lure.lureColor?.isNotEmpty == true) parts.add(lure.lureColor!);
        return parts.isNotEmpty ? parts.join(' ') : strings.unnamed;
      }
    }
    return '${strings.equipmentId} $equipmentId';
  }

  Widget _buildRodCharts(List<Equipment> rods, AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('${strings.rod}分布', AppColors.chartColors[0]),
        const SizedBox(height: 12),
        _buildBarChart(
          _getDistribution(
            rods,
            (e) => e.brand?.isNotEmpty == true ? e.brand! : strings.unnamed,
          ),
          '${strings.brand}分布',
          AppColors.chartColors[0],
        ),
        const SizedBox(height: 12),
        _buildBarChart(
          _getDistribution(
            rods,
            (e) => e.length?.isNotEmpty == true ? e.length! : strings.notFilled,
          ),
          '${strings.length}分布',
          AppColors.chartColors[1],
        ),
        const SizedBox(height: 12),
        _buildBarChart(
          _getDistribution(
            rods,
            (e) => e.material?.isNotEmpty == true
                ? e.material!
                : strings.notFilled,
          ),
          '${strings.material}分布',
          AppColors.chartColors[2],
        ),
        const SizedBox(height: 12),
        _buildPieChart(
          _getDistribution(
            rods,
            (e) => e.hardness?.isNotEmpty == true
                ? e.hardness!
                : strings.notFilled,
          ),
          '${strings.hardness}分布',
          AppColors.chartColors[0],
        ),
        const SizedBox(height: 12),
        _buildPieChart(
          _getDistribution(
            rods,
            (e) => e.rodAction?.isNotEmpty == true
                ? e.rodAction!
                : strings.notFilled,
          ),
          '${strings.rodAction}分布',
          AppColors.chartColors[2],
        ),
        const SizedBox(height: 12),
        _buildPieChart(
          _getHandleTypeDistribution(rods, strings),
          '${strings.handleType}分布',
          AppColors.accentLight,
        ),
        const SizedBox(height: 12),
        _buildPriceChart(rods, '鱼竿${strings.price}分布', AppColors.primaryLight),
      ],
    );
  }

  Widget _buildReelCharts(List<Equipment> reels, AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('${strings.reel}分布', AppColors.chartColors[3]),
        const SizedBox(height: 12),
        _buildBarChart(
          _getDistribution(
            reels,
            (e) => e.brand?.isNotEmpty == true ? e.brand! : strings.unnamed,
          ),
          '${strings.brand}分布',
          AppColors.chartColors[3],
        ),
        const SizedBox(height: 12),
        _buildPieChart(
          _getReelTypeDistribution(reels, strings),
          '${strings.reelType}分布',
          AppColors.chartColors[3],
        ),
        const SizedBox(height: 12),
        _buildPieChart(
          _getReelUsageDistribution(reels, strings),
          '${strings.usageType}分布',
          AppColors.chartColors[7],
        ),
        const SizedBox(height: 12),
        _buildBarChart(
          _getDistribution(
            reels,
            (e) => e.reelRatio?.isNotEmpty == true
                ? e.reelRatio!
                : strings.notFilled,
          ),
          '${strings.reelRatio}分布',
          AppColors.warning,
        ),
        const SizedBox(height: 12),
        _buildPieChart(
          _getDistribution(
            reels,
            (e) => e.reelBrakeType?.isNotEmpty == true
                ? e.reelBrakeType!
                : strings.notFilled,
          ),
          '${strings.reelBrakeType}分布',
          AppColors.error,
        ),
        const SizedBox(height: 12),
        _buildPriceChart(
          reels,
          '渔轮${strings.price}分布',
          AppColors.secondaryLight,
        ),
      ],
    );
  }

  Widget _buildLureCharts(List<Equipment> lures, AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('${strings.lure}分布', AppColors.chartColors[2]),
        const SizedBox(height: 12),
        _buildBarChart(
          _getDistribution(
            lures,
            (e) => e.brand?.isNotEmpty == true ? e.brand! : strings.unnamed,
          ),
          '${strings.brand}分布',
          AppColors.chartColors[2],
        ),
        const SizedBox(height: 12),
        _buildPieChart(
          _getDistribution(
            lures,
            (e) => e.lureType?.isNotEmpty == true
                ? e.lureType!
                : strings.notFilled,
          ),
          '${strings.lureType}分布',
          AppColors.chartColors[2],
        ),
      ],
    );
  }

  Widget _buildSoftWormAnalytics(EquipmentListState state, AppStrings strings) {
    final analytics = state.softWormAnalytics;
    final hasData = analytics.isNotEmpty &&
        (analytics['rigType']?.isNotEmpty == true ||
            analytics['hookType']?.isNotEmpty == true ||
            analytics['hookSize']?.isNotEmpty == true ||
            analytics['hookWeight']?.isNotEmpty == true);

    if (!hasData) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('软虫数据分析', AppColors.chartColors[6]),
        const SizedBox(height: 12),
        if (analytics['rigType']?.isNotEmpty == true)
          _buildBarChart(
            analytics['rigType']!,
            '钓组分布',
            AppColors.chartColors[0],
          ),
        if (analytics['rigType']?.isNotEmpty == true)
          const SizedBox(height: 12),
        if (analytics['hookType']?.isNotEmpty == true)
          _buildBarChart(
            analytics['hookType']!,
            '鱼钩分布',
            AppColors.chartColors[1],
          ),
        if (analytics['hookType']?.isNotEmpty == true)
          const SizedBox(height: 12),
        if (analytics['hookSize']?.isNotEmpty == true)
          _buildBarChart(
            analytics['hookSize']!,
            '钩号分布',
            AppColors.chartColors[2],
          ),
        if (analytics['hookSize']?.isNotEmpty == true)
          const SizedBox(height: 12),
        if (analytics['hookWeight']?.isNotEmpty == true)
          _buildBarChart(
            analytics['hookWeight']!,
            '鱼钩重量分布',
            AppColors.chartColors[3],
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.bar_chart, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> data, String title, Color color) {
    return DistributionChart(
      data: data,
      title: title,
      color: color,
      chartType: ChartType.bar,
    );
  }

  Widget _buildPieChart(Map<String, int> data, String title, Color baseColor) {
    return DistributionChart(
      data: data,
      title: title,
      color: baseColor,
      chartType: ChartType.pie,
    );
  }

  Widget _buildPriceChart(
    List<Equipment> equipment,
    String title,
    Color color,
  ) {
    final ranges = <String, int>{};
    for (final range in PriceRanges.ranges) {
      ranges[range.label] = 0;
    }

    for (final e in equipment) {
      if (e.price != null) {
        final label = PriceRanges.getLabel(e.price!);
        ranges[label] = (ranges[label] ?? 0) + 1;
      }
    }

    final total = ranges.values.fold(0, (sum, v) => sum + v);
    if (total == 0) return const SizedBox();

    return PremiumCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: ranges.values
                          .fold(0, (max, v) => v > max ? v : max)
                          .toDouble() +
                      1,
                  barGroups: ranges.entries.map((entry) {
                    final index = ranges.keys.toList().indexOf(entry.key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: color,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < ranges.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                ranges.keys.toList()[index],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _getDistribution(
    List<Equipment> equipment,
    String Function(Equipment) getKey,
  ) {
    final distribution = <String, int>{};
    for (final e in equipment) {
      final key = getKey(e);
      distribution[key] = (distribution[key] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, int> _getHandleTypeDistribution(
    List<Equipment> rods,
    AppStrings strings,
  ) {
    final distribution = <String, int>{};
    for (final rod in rods) {
      if (rod.category != null && rod.category!.contains('|')) {
        final handleType = rod.category!.split('|')[0];
        distribution[handleType] = (distribution[handleType] ?? 0) + 1;
      } else {
        distribution[strings.notFilled] =
            (distribution[strings.notFilled] ?? 0) + 1;
      }
    }
    return distribution;
  }

  Map<String, int> _getReelTypeDistribution(
    List<Equipment> reels,
    AppStrings strings,
  ) {
    final distribution = <String, int>{};
    for (final reel in reels) {
      if (reel.category != null && reel.category!.contains('|')) {
        final reelType = reel.category!.split('|')[0];
        distribution[reelType] = (distribution[reelType] ?? 0) + 1;
      } else {
        distribution[strings.notFilled] =
            (distribution[strings.notFilled] ?? 0) + 1;
      }
    }
    return distribution;
  }

  Map<String, int> _getReelUsageDistribution(
    List<Equipment> reels,
    AppStrings strings,
  ) {
    final distribution = <String, int>{};
    for (final reel in reels) {
      if (reel.category != null && reel.category!.contains('|')) {
        final usage = reel.category!.split('|')[1];
        distribution[usage] = (distribution[usage] ?? 0) + 1;
      } else {
        distribution[strings.notFilled] =
            (distribution[strings.notFilled] ?? 0) + 1;
      }
    }
    return distribution;
  }
}
