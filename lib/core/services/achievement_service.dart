import 'dart:convert';

import 'package:lurebox/core/constants/achievements.dart';
import 'package:lurebox/core/models/achievement.dart';
import 'package:lurebox/core/repositories/settings_repository.dart';
import 'package:lurebox/core/repositories/stats_repository.dart';
import 'package:lurebox/core/services/app_logger.dart';

/// 成就服务 - 用户成就系统
///
/// 自动追踪和计算用户钓鱼成就，基于 [StatsRepository] 提供的统计数据。
/// 支持多种成就类别：
/// - 数量成就：首次、10尾、100尾、500尾、1000尾
/// - 尺寸成就：30cm、50cm、70cm、90cm、120cm
/// - 物种成就：3种、5种、10种、15种、20种
/// - 装备成就：全套、5件、10件、20件、50件
/// - 地点成就：3个、10个、20个、30个、50个
/// - 环保成就：放流10尾、50尾、100尾、200尾，放流率80%
/// - 特殊成就：连续7天、每月30尾、每日5尾、晨钓20尾、夜钓20尾等
///
/// 每个成就包含目标值、当前进度、完成百分比和锁定状态。
///
/// 永久解锁语义：成就一旦达成即写入 [SettingsRepository]（键
/// [_unlockedKey]，值为 `{成就ID: 解锁时间ISO8601}` 的 JSON）。即便用户随后
/// 删除鱼获导致实时指标回落到目标值以下，已解锁成就也不会被撤销；尚未解锁的
/// 成就仍按实时指标展示进度。

class AchievementService {
  AchievementService(this._statsRepo, this._settingsRepo);
  final StatsRepository _statsRepo;
  final SettingsRepository _settingsRepo;

  /// 已解锁成就的持久化键。值为 `{成就ID: 解锁时间ISO8601}` 的 JSON 对象。
  static const String _unlockedKey = 'unlocked_achievements';

  /// 鱼获分享次数计数器的持久化键。仅统计鱼获分享，不含备份/CSV/装备/统计卡分享。
  static const String shareCountKey = 'share_count';

  /// 在一次成功的鱼获分享后递增分享计数。
  ///
  /// 供分享成功站点调用（持有 [SettingsRepository] 引用即可）。失败仅告警，
  /// 不抛出，避免影响分享主流程。
  static Future<void> incrementShareCount(
      SettingsRepository settingsRepo,) async {
    try {
      final current = await settingsRepo.getInt(shareCountKey);
      await settingsRepo.setInt(shareCountKey, current + 1);
    } on Exception catch (e) {
      AppLogger.w('AchievementService', 'Failed to increment share count: $e');
    }
  }

  /// 获取全部成就（带永久解锁语义）。
  ///
  /// 注意：本方法在检测到新解锁成就时会**写入**设置表（持久化解锁时间）。
  /// 这是有意为之——成就页重新加载或写后失效会再次调用本方法以刷新展示。
  Future<List<Achievement>> getAllAchievements() async {
    final results = <Achievement>[];
    final metrics = await _calculateMetrics();
    final unlockedMap = await _loadUnlockedMap();
    var dirty = false;
    final now = DateTime.now();

    for (final def in AchievementConfig.definitions) {
      final current = _getCurrentValue(def.id, metrics);
      final liveUnlocked = current >= def.target;
      final wasUnlocked = unlockedMap.containsKey(def.id);

      if (liveUnlocked && !wasUnlocked) {
        unlockedMap[def.id] = now.toIso8601String();
        dirty = true;
      }

      final effectiveUnlocked = liveUnlocked || wasUnlocked;

      // 已解锁：抬升 current 至目标值以保证 isUnlocked 为真且进度满格；
      // 解锁时间取持久化值（新解锁则为 now）。
      final effectiveCurrent =
          effectiveUnlocked && current < def.target ? def.target : current;
      final progress =
          (effectiveCurrent / def.target * 100.0).clamp(0.0, 100.0);
      final unlockedAt =
          effectiveUnlocked ? _parseDateTime(unlockedMap[def.id]) ?? now : null;

      results.add(
        Achievement(
          id: def.id,
          title: def.title,
          description: def.description,
          icon: def.icon,
          level: def.level,
          category: def.category,
          target: def.target,
          current: effectiveCurrent,
          progress: progress,
          unlockedAt: unlockedAt,
        ),
      );
    }

    if (dirty) {
      await _persistUnlockedMap(unlockedMap);
    }

    return results;
  }

  /// 读取已解锁成就映射。缺失或 JSON 损坏时按空映射处理（告警，不抛出）。
  Future<Map<String, String>> _loadUnlockedMap() async {
    try {
      final raw = await _settingsRepo.get(_unlockedKey);
      if (raw == null || raw.isEmpty) return {};
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        AppLogger.w(
          'AchievementService',
          'Unlocked achievements payload is not a JSON object',
        );
        return {};
      }
      return decoded.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } on FormatException catch (e) {
      AppLogger.w(
        'AchievementService',
        'Failed to parse unlocked achievements JSON: $e',
      );
      return {};
    } on Exception catch (e) {
      AppLogger.w(
        'AchievementService',
        'Failed to load unlocked achievements: $e',
      );
      return {};
    }
  }

  /// 持久化已解锁成就映射。写入失败时仅告警，不抛出。
  Future<void> _persistUnlockedMap(Map<String, String> map) async {
    try {
      await _settingsRepo.set(_unlockedKey, jsonEncode(map));
    } on Exception catch (e) {
      AppLogger.w(
        'AchievementService',
        'Failed to persist unlocked achievements: $e',
      );
    }
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  int _getCurrentValue(String id, AchievementMetrics metrics) {
    switch (id) {
      // 数量类
      case 'catch_first':
      case 'catch_10':
      case 'catch_100':
      case 'catch_500':
      case 'catch_1000':
        return metrics.totalCatches;

      // 尺寸类
      case 'length_30':
        return metrics.maxLength >= 30 ? 1 : 0;
      case 'length_50':
        return metrics.maxLength >= 50 ? 1 : 0;
      case 'length_70':
        return metrics.maxLength >= 70 ? 1 : 0;
      case 'length_90':
        return metrics.maxLength >= 90 ? 1 : 0;
      case 'length_120':
        return metrics.maxLength >= 120 ? 1 : 0;

      // 品种类
      case 'species_3':
      case 'species_5':
      case 'species_10':
      case 'species_15':
      case 'species_20':
        return metrics.speciesCount;

      // 装备类
      case 'equipment_full':
        return metrics.equipmentFull ? 1 : 0;
      case 'equipment_5':
      case 'equipment_10':
      case 'equipment_20':
      case 'equipment_50':
        return metrics.equipmentCount;

      // 地点类
      case 'location_3':
      case 'location_10':
      case 'location_20':
      case 'location_30':
      case 'location_50':
        return metrics.locationCount;

      // 环保类
      case 'release_10':
      case 'release_50':
      case 'release_100':
      case 'release_200':
        return metrics.releaseCount;
      case 'release_rate_80':
        // 要求最小样本量，避免单条放流即解锁。
        return (metrics.releaseRate >= 0.8 && metrics.totalCatches >= 5)
            ? 1
            : 0;

      // 特殊成就
      case 'consecutive_7':
        return metrics.consecutiveDays;
      case 'monthly_30':
        return metrics.monthlyMax;
      case 'share_5':
        return metrics.shareCount;
      case 'new_record':
        return metrics.newRecord ? 1 : 0;
      case 'daily_5':
        return metrics.dailyMax;
      case 'morning_20':
        return metrics.morningCatches;
      case 'night_20':
        return metrics.nightCatches;
      case 'photos_100':
        return metrics.photoCount;
      case 'total_weight_10':
        return metrics.totalWeight.toInt();
      case 'equipment_combo_20':
        return metrics.equipmentComboMax;

      default:
        return 0;
    }
  }

  Future<AchievementMetrics> _calculateMetrics() async {
    try {
      // 所有查询相互独立，并行执行以提升性能
      final results = await Future.wait([
        _statsRepo.getTotalCatchCount(), // 0
        _statsRepo.getMaxLength(), // 1
        _statsRepo.getDistinctSpeciesCount(), // 2
        _statsRepo.getLocationCount(), // 3
        _statsRepo.getReleaseCount(), // 4
        _statsRepo.getReleaseRate(), // 5
        _statsRepo.getConsecutiveDays(), // 6
        _statsRepo.getMonthlyMax(), // 7
        _statsRepo.getDailyMax(), // 8
        _statsRepo.getMorningCatchCount(), // 9
        _statsRepo.getNightCatchCount(), // 10
        _statsRepo.getPhotoCount(), // 11
        _statsRepo.getTotalWeight(), // 12
        _getEquipmentFullStatus(), // 13
        _getEquipmentCount(), // 14
        _getEquipmentComboMax(), // 15
        _settingsRepo.getInt(shareCountKey), // 16
      ]);

      final totalCatches = results[0] as int;
      return AchievementMetrics(
        totalCatches: totalCatches,
        maxLength: results[1] as double,
        speciesCount: results[2] as int,
        locationCount: results[3] as int,
        releaseCount: results[4] as int,
        releaseRate: results[5] as double,
        consecutiveDays: results[6] as int,
        monthlyMax: results[7] as int,
        dailyMax: results[8] as int,
        morningCatches: results[9] as int,
        nightCatches: results[10] as int,
        photoCount: results[11] as int,
        totalWeight: results[12] as double,
        equipmentFull: results[13] as bool,
        equipmentCount: results[14] as int,
        equipmentComboMax: results[15] as int,
        shareCount: results[16] as int,
        newRecord: totalCatches > 0,
      );
    } catch (e) {
      AppLogger.e('AchievementService', 'Failed to calculate metrics', e);
      return const AchievementMetrics();
    }
  }

  Future<bool> _getEquipmentFullStatus() async {
    final count = await _statsRepo.getEquipmentFullStatus();
    return count > 0;
  }

  Future<int> _getEquipmentCount() async {
    // 装备类成就口径为"拥有"装备数（未软删除），与描述"添加 N 件装备"一致。
    return _statsRepo.getOwnedEquipmentCount();
  }

  Future<int> _getEquipmentComboMax() async {
    // 单套装备最多钓获数 = 各装备 catchCount 的最大值（无装备记录时为 0）。
    final stats = await _statsRepo.getEquipmentCatchStats();
    if (stats.isEmpty) return 0;
    return stats.values
        .map((s) => s.catchCount)
        .reduce((a, b) => a > b ? a : b);
  }

  Future<Map<String, dynamic>> getAchievementStats() async {
    final achievements = await getAllAchievements();
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final totalCount = achievements.length;
    final progress =
        totalCount > 0 ? (unlockedCount / totalCount * 100).round() : 0;

    return {
      'unlockedCount': unlockedCount,
      'totalCount': totalCount,
      'progress': progress,
    };
  }
}
