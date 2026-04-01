import '../models/fish_catch.dart';
import '../models/stats_models.dart';

export '../models/stats_models.dart';

/// 统计数据仓储层
///
/// 提供全面的渔获、设备、位置等统计分析功能，是应用仪表板数据的主要来源，包括：
/// - 渔获统计（总数、放生数、保留数、放生率）
/// - 物种分布统计
/// - 时间段统计（早晨、夜间、单日最大、单月最大）
/// - 连续钓鱼天数
/// - 设备使用统计和分布
/// - 总重量、最大长度等汇总数据
/// - 仪表板一键获取所有关键数据

abstract class StatsRepository {
  Future<CatchStats> getCatchStats({DateTime? startDate, DateTime? endDate});

  Future<Map<String, int>> getSpeciesStats({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 10,
  });

  Future<int> getTotalCatchCount();

  Future<int> getCatchesAboveLength(double minLength);

  Future<int> getDistinctSpeciesCount();

  Future<int> getEquipmentCount();

  Future<int> getLocationCount();

  Future<int> getReleaseCount();

  Future<double> getReleaseRate();

  Future<int> getConsecutiveDays();

  Future<int> getMonthlyMax();

  Future<int> getDailyMax();

  Future<int> getMorningCatchCount();

  Future<int> getNightCatchCount();

  Future<int> getPhotoCount();

  Future<double> getTotalWeight();

  Future<DashboardData> getDashboardData();

  Future<Map<int, EquipmentCatchStats>> getEquipmentCatchStats();

  Future<Map<int, Map<String, int>>> getAllEquipmentSpeciesStats();

  Future<Map<String, int>> getEquipmentDistribution(
    String type, {
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<List<FishCatch>> getTop3LongestCatches();

  Future<int> getEquipmentFullStatus();

  Future<double> getMaxLength();
}
