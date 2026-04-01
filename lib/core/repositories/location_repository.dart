import '../models/location_models.dart';

export '../models/location_models.dart';

/// 钓点位置仓储层
///
/// 管理钓鱼位置的数据访问，包括：
/// - 获取所有位置及其渔获统计
/// - 按坐标查询渔获数量
/// - 获取指定半径内的邻近位置
/// - 位置合并功能
/// - 获取位置的详细统计数据（总捕获数、放生数、保留数、物种分布、平均长度/重量）

abstract class LocationRepository {
  Future<List<LocationWithStats>> getAllWithStats();

  Future<int> getFishCountByCoordinates({
    required double latitude,
    required double longitude,
    double tolerance = 0.001,
  });

  Future<List<LocationWithStats>> getNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
  });

  Future<void> mergeLocations({
    required LocationWithStats source,
    required LocationWithStats target,
  });

  Future<LocationStats?> getStats(String locationName);

  Future<int> getLocationCount();
}
