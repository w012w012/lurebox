import 'app_logger.dart';
import '../constants/achievements.dart';
import '../models/achievement.dart';
import '../repositories/stats_repository.dart';

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

class AchievementService {
  final StatsRepository _statsRepo;

  AchievementService(this._statsRepo);

  Future<List<Achievement>> getAllAchievements() async {
    final results = <Achievement>[];
    final metrics = await _calculateMetrics();

    for (final def in AchievementConfig.definitions) {
      final current = _getCurrentValue(def.id, metrics);
      final progress = (current / def.target * 100.0).clamp(0.0, 100.0);

      results.add(
        Achievement(
          id: def.id,
          title: def.title,
          description: def.description,
          icon: def.icon,
          level: def.level,
          category: def.category,
          target: def.target,
          current: current,
          progress: progress,
        ),
      );
    }

    return results;
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
        return metrics.releaseRate >= 0.8 ? 1 : 0;

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
        _statsRepo.getTotalCatchCount(),       // 0
        _statsRepo.getMaxLength(),             // 1
        _statsRepo.getDistinctSpeciesCount(),  // 2
        _statsRepo.getLocationCount(),         // 3
        _statsRepo.getReleaseCount(),          // 4
        _statsRepo.getReleaseRate(),           // 5
        _statsRepo.getConsecutiveDays(),       // 6
        _statsRepo.getMonthlyMax(),            // 7
        _statsRepo.getDailyMax(),              // 8
        _statsRepo.getMorningCatchCount(),     // 9
        _statsRepo.getNightCatchCount(),       // 10
        _statsRepo.getPhotoCount(),            // 11
        _statsRepo.getTotalWeight(),           // 12
        _getEquipmentFullStatus(),             // 13
        _getEquipmentCount(),                  // 14
        _getEquipmentComboMax(),               // 15
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
    return await _statsRepo.getEquipmentCount();
  }

  Future<int> _getEquipmentComboMax() async {
    return 0;
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
