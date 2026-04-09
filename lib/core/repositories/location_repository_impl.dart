import '../models/fish_catch.dart';
import '../services/database_service.dart';
import '../services/error_service.dart';
import 'location_repository.dart';

/// SQLite 实现 - 钓点位置仓储层
///
/// 使用 SQLite 数据库实现钓点位置的数据访问。

class SqliteLocationRepository implements LocationRepository {
  static const String _tableName = 'fish_catches';

  @override
  Future<List<LocationWithStats>> getAllWithStats() async {
    try {
      final db = await DatabaseService.database;
      final results = await db.rawQuery('''
        SELECT 
          location_name,
          latitude,
          longitude,
          COUNT(*) as fish_count,
          MAX(catch_time) as last_catch_time
        FROM $_tableName
        WHERE location_name IS NOT NULL 
          AND location_name != '' 
          AND latitude IS NOT NULL 
          AND longitude IS NOT NULL
        GROUP BY location_name, latitude, longitude
        ORDER BY fish_count DESC
      ''');
      return List<LocationWithStats>.from(results.map(
          (map) => LocationWithStats.fromMap(map as Map<String, dynamic>)));
    } catch (e) {
      throw DatabaseException('Failed to get all locations with stats: $e');
    }
  }

  @override
  Future<int> getFishCountByCoordinates({
    required double latitude,
    required double longitude,
    double tolerance = 0.001,
  }) async {
    try {
      final db = await DatabaseService.database;
      final results = await db.rawQuery(
        '''
        SELECT COUNT(*) as count FROM $_tableName
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
      throw DatabaseException('Failed to get fish count by coordinates: $e');
    }
  }

  @override
  Future<List<LocationWithStats>> getNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      final db = await DatabaseService.database;
      final radiusDeg = radiusKm / 111.0;
      final results = await db.rawQuery(
        '''
        SELECT 
          location_name,
          latitude,
          longitude,
          COUNT(*) as fish_count,
          MAX(catch_time) as last_catch_time
        FROM $_tableName
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
          (map) => LocationWithStats.fromMap(map as Map<String, dynamic>)));
    } catch (e) {
      throw DatabaseException('Failed to get nearby locations: $e');
    }
  }

  @override
  Future<void> mergeLocations({
    required LocationWithStats source,
    required LocationWithStats target,
  }) async {
    try {
      final db = await DatabaseService.database;
      await db.transaction((txn) async {
        await txn.update(
          _tableName,
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
      throw DatabaseException('Failed to merge locations: $e');
    }
  }

  @override
  Future<LocationStats?> getStats(String locationName) async {
    try {
      final db = await DatabaseService.database;

      final basicStats = await db.rawQuery(
        '''
        SELECT 
          COUNT(*) as total_catches,
          SUM(CASE WHEN fate = ${FishFateType.release.value} THEN 1 ELSE 0 END) as release_count,
          SUM(CASE WHEN fate = ${FishFateType.keep.value} THEN 1 ELSE 0 END) as keep_count,
          AVG(length) as avg_length,
          AVG(weight) as avg_weight
        FROM $_tableName
        WHERE location_name = ?
        ''',
        [locationName],
      );

      if (basicStats.isEmpty ||
          (basicStats.first['total_catches'] as int?) == 0) {
        return null;
      }

      final speciesResults = await db.rawQuery(
        '''
        SELECT species, COUNT(*) as count
        FROM $_tableName
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
      throw DatabaseException('Failed to get location stats: $e');
    }
  }

  @override
  Future<int> getLocationCount() async {
    try {
      final db = await DatabaseService.database;
      final results = await db.rawQuery('''
        SELECT COUNT(DISTINCT location_name) as count
        FROM $_tableName
        WHERE location_name IS NOT NULL AND location_name != ''
      ''');
      return results.first['count'] as int? ?? 0;
    } catch (e) {
      throw DatabaseException('Failed to get location count: $e');
    }
  }
}
