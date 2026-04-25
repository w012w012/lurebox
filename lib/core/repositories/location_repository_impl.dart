import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/repositories/base_repository.dart';
import 'package:lurebox/core/repositories/location_repository.dart';

/// SQLite 实现 - 钓点位置仓储层
///
/// 使用 SQLite 数据库实现钓点位置的数据访问。

class SqliteLocationRepository extends BaseSqliteRepository
    implements LocationRepository {

  /// 无参构造函数（使用默认 DatabaseService）
  SqliteLocationRepository();

  /// 带数据库的构造函数（用于测试）
  SqliteLocationRepository.withDatabase(super.testDb)
      : super.withDatabase();
  /// Approximate km per degree of latitude (varies ~110.57 at equator to ~111.70 at poles)
  static const double _kmPerDegreeLatitude = 111;

  @override
  String get tableName => 'fish_catches';

  @override
  Future<List<LocationWithStats>> getAllWithStats() async {
    try {
      final db = await database;
      final results = await db.rawQuery('''
        SELECT
          location_name,
          latitude,
          longitude,
          COUNT(*) as fish_count,
          MAX(catch_time) as last_catch_time
        FROM $tableName
        WHERE location_name IS NOT NULL
          AND location_name != ''
          AND latitude IS NOT NULL
          AND longitude IS NOT NULL
        GROUP BY location_name, latitude, longitude
        ORDER BY fish_count DESC
      ''');
      return List<LocationWithStats>.from(results.map(
          (map) => LocationWithStats.fromMap(map as Map<String, dynamic>),),);
    } catch (e) {
      throwDbError('get all locations with stats', e);
    }
  }

  @override
  Future<int> getFishCountByCoordinates({
    required double latitude,
    required double longitude,
    double tolerance = 0.001,
  }) async {
    try {
      final db = await database;
      final results = await db.rawQuery(
        '''
        SELECT COUNT(*) as count FROM $tableName
        WHERE latitude >= ? AND latitude <= ?
          AND longitude >= ? AND longitude <= ?
        ''',
        [
          latitude - tolerance,
          latitude + tolerance,
          longitude - tolerance,
          longitude + tolerance,
        ],
      );
      return results.first['count'] as int? ?? 0;
    } catch (e) {
      throwDbError('get fish count by coordinates', e);
    }
  }

  @override
  Future<List<LocationWithStats>> getNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      final db = await database;
      final radiusDeg = radiusKm / _kmPerDegreeLatitude;
      final results = await db.rawQuery(
        '''
        SELECT
          location_name,
          latitude,
          longitude,
          COUNT(*) as fish_count,
          MAX(catch_time) as last_catch_time
        FROM $tableName
        WHERE location_name IS NOT NULL
          AND location_name != ''
          AND latitude IS NOT NULL
          AND longitude IS NOT NULL
          AND latitude >= ? AND latitude <= ?
          AND longitude >= ? AND longitude <= ?
        GROUP BY location_name, latitude, longitude
        ORDER BY fish_count DESC
        ''',
        [
          latitude - radiusDeg,
          latitude + radiusDeg,
          longitude - radiusDeg,
          longitude + radiusDeg,
        ],
      );
      return List<LocationWithStats>.from(results.map(
          (map) => LocationWithStats.fromMap(map as Map<String, dynamic>),),);
    } catch (e) {
      throwDbError('get nearby locations', e);
    }
  }

  @override
  Future<void> mergeLocations({
    required LocationWithStats source,
    required LocationWithStats target,
  }) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        await txn.update(
          tableName,
          {
            'location_name': target.name,
            'latitude': target.latitude,
            'longitude': target.longitude,
          },
          where: 'location_name = ? AND latitude = ? AND longitude = ?',
          whereArgs: [source.name, source.latitude, source.longitude],
        );
      });
    } catch (e) {
      throwDbError('merge locations', e);
    }
  }

  @override
  Future<LocationStats?> getStats(String locationName) async {
    try {
      final db = await database;

      final basicStats = await db.rawQuery(
        '''
        SELECT
          COUNT(*) as total_catches,
          SUM(CASE WHEN fate = ? THEN 1 ELSE 0 END) as release_count,
          SUM(CASE WHEN fate = ? THEN 1 ELSE 0 END) as keep_count,
          AVG(length) as avg_length,
          AVG(weight) as avg_weight
        FROM $tableName
        WHERE location_name = ?
        ''',
        [FishFateType.release.value, FishFateType.keep.value, locationName],
      );

      if (basicStats.isEmpty ||
          (basicStats.first['total_catches'] as int?) == 0) {
        return null;
      }

      final speciesResults = await db.rawQuery(
        '''
        SELECT species, COUNT(*) as count
        FROM $tableName
        WHERE location_name = ?
        GROUP BY species
        ORDER BY count DESC
        ''',
        [locationName],
      );

      final speciesDistribution = <String, int>{};
      for (final row in speciesResults) {
        final species = row['species'] as String?;
        final count = row['count'] as int?;
        if (species != null && count != null) {
          speciesDistribution[species] = count;
        }
      }

      final stat = basicStats.first;
      return LocationStats(
        totalCatches: stat['total_catches'] as int? ?? 0,
        releaseCount: stat['release_count'] as int? ?? 0,
        keepCount: stat['keep_count'] as int? ?? 0,
        speciesDistribution: speciesDistribution,
        avgLength: stat['avg_length'] as double?,
        avgWeight: stat['avg_weight'] as double?,
      );
    } catch (e) {
      throwDbError('get location stats', e);
    }
  }

  @override
  Future<int> getLocationCount() async {
    try {
      final db = await database;
      final results = await db.rawQuery('''
        SELECT COUNT(DISTINCT location_name) as count
        FROM $tableName
        WHERE location_name IS NOT NULL AND location_name != ''
      ''');
      return results.first['count'] as int? ?? 0;
    } catch (e) {
      throwDbError('get location count', e);
    }
  }
}
