import '../database/database_provider.dart';
import '../models/fish_catch.dart';
import '../services/error_service.dart';
import 'stats_repository.dart';

/// SQLite 实现 - 统计数据仓储层
///
/// 使用 SQLite 数据库实现各类统计查询。

class SqliteStatsRepository implements StatsRepository {
  static const String _tableName = 'fish_catches';

  @override
  Future<CatchStats> getCatchStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final db = await DatabaseProvider.instance.database;

      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (startDate != null && endDate != null) {
        whereClause = 'WHERE catch_time >= ? AND catch_time < ?';
        whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
      }

      final results = await db.rawQuery('''
        SELECT 
          COUNT(*) as total,
          SUM(CASE WHEN fate = 0 THEN 1 ELSE 0 END) as release,
          SUM(CASE WHEN fate = 1 THEN 1 ELSE 0 END) as keep
        FROM $_tableName
        $whereClause
        ''', whereArgs);

      if (results.isEmpty) {
        return const CatchStats(total: 0, release: 0, keep: 0);
      }

      return CatchStats.fromMap(results.first);
    } catch (e) {
      throw DatabaseException('Failed to get catch stats: $e');
    }
  }

  @override
  Future<Map<String, int>> getSpeciesStats({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 10,
  }) async {
    try {
      final db = await DatabaseProvider.instance.database;

      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (startDate != null && endDate != null) {
        whereClause = 'WHERE catch_time >= ? AND catch_time < ?';
        whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
      }

      final results = await db.rawQuery(
        '''
        SELECT species, COUNT(*) as count
        FROM $_tableName
        $whereClause
        GROUP BY species
        ORDER BY count DESC
        LIMIT ?
        ''',
        [...whereArgs, limit],
      );

      final stats = <String, int>{};
      for (final row in results) {
        final species = row['species'] as String?;
        final count = row['count'] as int?;
        if (species != null && count != null) {
          stats[species] = count;
        }
      }
      return stats;
    } catch (e) {
      throw DatabaseException('Failed to get species stats: $e');
    }
  }

  @override
  Future<int> getTotalCatchCount() async {
    try {
      final db = await DatabaseProvider.instance.database;
      final results = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName',
      );
      return results.first['count'] as int? ?? 0;
    } catch (e) {
      throw DatabaseException('Failed to get total catch count: $e');
    }
  }

  @override
  Future<int> getCatchesAboveLength(double minLength) async {
    try {
      final db = await DatabaseProvider.instance.database;
      final results = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE length >= ?',
        [minLength],
      );
      return results.first['count'] as int? ?? 0;
    } catch (e) {
      throw DatabaseException('Failed to get catches above length: $e');
    }
  }

  @override
  Future<int> getDistinctSpeciesCount() async {
    try {
      final db = await DatabaseProvider.instance.database;
      final results = await db.rawQuery(
        'SELECT COUNT(DISTINCT species) as count FROM $_tableName',
      );
      return results.first['count'] as int? ?? 0;
    } catch (e) {
      throw DatabaseException('Failed to get distinct species count: $e');
    }
  }

  @override
  Future<int> getEquipmentCount() async {
    try {
      final db = await DatabaseProvider.instance.database;
      final results = await db.rawQuery('''
        SELECT COUNT(DISTINCT eq_id) as count FROM (
          SELECT equipment_id as eq_id FROM $_tableName WHERE equipment_id IS NOT NULL
          UNION
          SELECT rod_id as eq_id FROM $_tableName WHERE rod_id IS NOT NULL
          UNION
          SELECT reel_id as eq_id FROM $_tableName WHERE reel_id IS NOT NULL
          UNION
          SELECT lure_id as eq_id FROM $_tableName WHERE lure_id IS NOT NULL
        )
        ''');
      return results.first['count'] as int? ?? 0;
    } catch (e) {
      throw DatabaseException('Failed to get equipment count: $e');
    }
  }

  @override
  Future<int> getLocationCount() async {
    try {
      final db = await DatabaseProvider.instance.database;
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

  @override
  Future<int> getReleaseCount() async {
    try {
      final db = await DatabaseProvider.instance.database;
      final results = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE fate = 0',
      );
      return results.first['count'] as int? ?? 0;
    } catch (e) {
      throw DatabaseException('Failed to get release count: $e');
    }
  }

  @override
  Future<double> getReleaseRate() async {
    try {
      final db = await DatabaseProvider.instance.database;
      // 优化：单次查询获取总数和放流数
      final results = await db.rawQuery('''
        SELECT
          COUNT(*) as total,
          SUM(CASE WHEN fate = 0 THEN 1 ELSE 0 END) as release
        FROM fish_catches
      ''');
      final total = results.first['total'] as int? ?? 0;
      if (total == 0) return 0.0;
      final release = results.first['release'] as int? ?? 0;
      return release / total;
    } catch (e) {
      throw DatabaseException('Failed to get release rate: $e');
    }
  }

  @override
  Future<int> getConsecutiveDays() async {
    try {
      final db = await DatabaseProvider.instance.database;
      final results = await db.rawQuery('''
        SELECT DATE(catch_time) as catch_date, COUNT(*) as count
        FROM $_tableName
        GROUP BY catch_date
        ORDER BY catch_date DESC
      ''');

      if (results.isEmpty) return 0;

      int consecutiveDays = 0;
      DateTime? lastDate;

      for (final row in results) {
        final dateStr = row['catch_date'] as String?;
        if (dateStr == null) continue;

        final date = DateTime.parse(dateStr);
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);

        if (lastDate == null) {
          final diff = todayDate.difference(date).inDays;
          if (diff > 1) return 0;
          consecutiveDays = 1;
          lastDate = date;
        } else {
          final diff = lastDate.difference(date).inDays;
          if (diff == 1) {
            consecutiveDays++;
            lastDate = date;
          } else {
            break;
          }
        }
      }

      return consecutiveDays;
    } catch (e) {
      throw DatabaseException('Failed to get consecutive days: $e');
    }
  }

  @override
  Future<int> getMonthlyMax() async {
    try {
      final db = await DatabaseProvider.instance.database;
      final results = await db.rawQuery('''
        SELECT strftime('%Y-%m', catch_time) as month, COUNT(*) as count
        FROM $_tableName
        GROUP BY month
        ORDER BY count DESC
        LIMIT 1
      ''');

      if (results.isEmpty) return 0;
      return results.first['count'] as int? ?? 0;
    } catch (e) {
      throw DatabaseException('Failed to get monthly max: $e');
    }
  }

  @override
  Future<int> getDailyMax() async {
    try {
      final db = await DatabaseProvider.instance.database;
      final results = await db.rawQuery('''
        SELECT DATE(catch_time) as day, COUNT(*) as count
        FROM $_tableName
        GROUP BY day
        ORDER BY count DESC
        LIMIT 1
      ''');

      if (results.isEmpty) return 0;
      return results.first['count'] as int? ?? 0;
    } catch (e) {
      throw DatabaseException('Failed to get daily max: $e');
    }
  }

  @override
  Future<int> getMorningCatchCount() async {
    try {
      final db = await DatabaseProvider.instance.database;
      final results = await db.rawQuery('''
        SELECT COUNT(*) as count FROM $_tableName
        WHERE strftime('%H', catch_time) >= '05' 
          AND strftime('%H', catch_time) < '09'
      ''');
      return results.first['count'] as int? ?? 0;
    } catch (e) {
      throw DatabaseException('Failed to get morning catch count: $e');
    }
  }

  @override
  Future<int> getNightCatchCount() async {
    try {
      final db = await DatabaseProvider.instance.database;
      final results = await db.rawQuery('''
        SELECT COUNT(*) as count FROM $_tableName
        WHERE strftime('%H', catch_time) >= '20' 
           OR strftime('%H', catch_time) < '05'
      ''');
      return results.first['count'] as int? ?? 0;
    } catch (e) {
      throw DatabaseException('Failed to get night catch count: $e');
    }
  }

  @override
  Future<int> getPhotoCount() async {
    try {
      final db = await DatabaseProvider.instance.database;
      final results = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE image_path IS NOT NULL AND image_path != ""',
      );
      return results.first['count'] as int? ?? 0;
    } catch (e) {
      throw DatabaseException('Failed to get photo count: $e');
    }
  }

  @override
  Future<double> getTotalWeight() async {
    try {
      final db = await DatabaseProvider.instance.database;
      final results = await db.rawQuery(
        'SELECT SUM(weight) as total FROM $_tableName WHERE weight IS NOT NULL',
      );
      return (results.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw DatabaseException('Failed to get total weight: $e');
    }
  }

  @override
  Future<double> getMaxLength() async {
    try {
      final db = await DatabaseProvider.instance.database;
      final results = await db.rawQuery(
        'SELECT MAX(length) as max_length FROM $_tableName WHERE length IS NOT NULL',
      );
      return (results.first['max_length'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw DatabaseException('Failed to get max length: $e');
    }
  }

  @override
  Future<DashboardData> getDashboardData() async {
    try {
      final now = DateTime.now();

      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 1);

      final yearStart = DateTime(now.year, 1, 1);
      final yearEnd = DateTime(now.year + 1, 1, 1);

      // 优化：将 9 个查询合并为 3 个
      final results = await Future.wait([
        _getAllPeriodCatchStats(
          todayStart: todayStart,
          todayEnd: todayEnd,
          monthStart: monthStart,
          monthEnd: monthEnd,
          yearStart: yearStart,
          yearEnd: yearEnd,
        ),
        _getAllPeriodSpeciesStats(
          todayStart: todayStart,
          todayEnd: todayEnd,
          monthStart: monthStart,
          monthEnd: monthEnd,
          yearStart: yearStart,
          yearEnd: yearEnd,
        ),
        getTop3LongestCatches(),
        getDailyCatchCount(startDate: monthStart, endDate: todayEnd),
      ]);

      final catchStats = results[0] as Map<String, CatchStats>;
      final speciesStats = results[1] as Map<String, Map<String, int>>;

      return DashboardData(
        todayStats: catchStats['today']!,
        todaySpecies: speciesStats['today'] ?? {},
        monthStats: catchStats['month']!,
        monthSpecies: speciesStats['month'] ?? {},
        yearStats: catchStats['year']!,
        yearSpecies: speciesStats['year'] ?? {},
        allStats: catchStats['all']!,
        allSpecies: speciesStats['all'] ?? {},
        top3Longest:
            (results[2] as List<FishCatch>).map((f) => f.toMap()).toList(),
        monthTrend: results[3] as List<Map<String, dynamic>>,
      );
    } catch (e) {
      throw DatabaseException('Failed to get dashboard data: $e');
    }
  }

  /// 优化：单次查询获取所有时间段的渔获统计
  Future<Map<String, CatchStats>> _getAllPeriodCatchStats({
    required DateTime todayStart,
    required DateTime todayEnd,
    required DateTime monthStart,
    required DateTime monthEnd,
    required DateTime yearStart,
    required DateTime yearEnd,
  }) async {
    final db = await DatabaseProvider.instance.database;
    final results = await db.rawQuery('''
      SELECT
        COUNT(*) as all_total,
        SUM(CASE WHEN fate = 0 THEN 1 ELSE 0 END) as all_release,
        SUM(CASE WHEN fate = 1 THEN 1 ELSE 0 END) as all_keep,
        SUM(CASE WHEN catch_time >= ? AND catch_time < ? THEN 1 ELSE 0 END) as today_total,
        SUM(CASE WHEN catch_time >= ? AND catch_time < ? AND fate = 0 THEN 1 ELSE 0 END) as today_release,
        SUM(CASE WHEN catch_time >= ? AND catch_time < ? AND fate = 1 THEN 1 ELSE 0 END) as today_keep,
        SUM(CASE WHEN catch_time >= ? AND catch_time < ? THEN 1 ELSE 0 END) as month_total,
        SUM(CASE WHEN catch_time >= ? AND catch_time < ? AND fate = 0 THEN 1 ELSE 0 END) as month_release,
        SUM(CASE WHEN catch_time >= ? AND catch_time < ? AND fate = 1 THEN 1 ELSE 0 END) as month_keep,
        SUM(CASE WHEN catch_time >= ? AND catch_time < ? THEN 1 ELSE 0 END) as year_total,
        SUM(CASE WHEN catch_time >= ? AND catch_time < ? AND fate = 0 THEN 1 ELSE 0 END) as year_release,
        SUM(CASE WHEN catch_time >= ? AND catch_time < ? AND fate = 1 THEN 1 ELSE 0 END) as year_keep
      FROM fish_catches
    ''', [
      todayStart.toIso8601String(),
      todayEnd.toIso8601String(),
      todayStart.toIso8601String(),
      todayEnd.toIso8601String(),
      todayStart.toIso8601String(),
      todayEnd.toIso8601String(),
      monthStart.toIso8601String(),
      monthEnd.toIso8601String(),
      monthStart.toIso8601String(),
      monthEnd.toIso8601String(),
      monthStart.toIso8601String(),
      monthEnd.toIso8601String(),
      yearStart.toIso8601String(),
      yearEnd.toIso8601String(),
      yearStart.toIso8601String(),
      yearEnd.toIso8601String(),
      yearStart.toIso8601String(),
      yearEnd.toIso8601String(),
    ]);

    final row = results.first;
    return {
      'today': CatchStats(
        total: row['today_total'] as int? ?? 0,
        release: row['today_release'] as int? ?? 0,
        keep: row['today_keep'] as int? ?? 0,
      ),
      'month': CatchStats(
        total: row['month_total'] as int? ?? 0,
        release: row['month_release'] as int? ?? 0,
        keep: row['month_keep'] as int? ?? 0,
      ),
      'year': CatchStats(
        total: row['year_total'] as int? ?? 0,
        release: row['year_release'] as int? ?? 0,
        keep: row['year_keep'] as int? ?? 0,
      ),
      'all': CatchStats(
        total: row['all_total'] as int? ?? 0,
        release: row['all_release'] as int? ?? 0,
        keep: row['all_keep'] as int? ?? 0,
      ),
    };
  }

  /// 优化：批量获取所有时间段的物种统计
  Future<Map<String, Map<String, int>>> _getAllPeriodSpeciesStats({
    required DateTime todayStart,
    required DateTime todayEnd,
    required DateTime monthStart,
    required DateTime monthEnd,
    required DateTime yearStart,
    required DateTime yearEnd,
  }) async {
    final db = await DatabaseProvider.instance.database;
    final results = await db.rawQuery('''
      SELECT
        species,
        SUM(CASE WHEN catch_time >= ? AND catch_time < ? THEN 1 ELSE 0 END) as today_count,
        SUM(CASE WHEN catch_time >= ? AND catch_time < ? THEN 1 ELSE 0 END) as month_count,
        SUM(CASE WHEN catch_time >= ? AND catch_time < ? THEN 1 ELSE 0 END) as year_count,
        COUNT(*) as all_count
      FROM fish_catches
      GROUP BY species
      ORDER BY all_count DESC
      LIMIT 10
    ''', [
      todayStart.toIso8601String(),
      todayEnd.toIso8601String(),
      monthStart.toIso8601String(),
      monthEnd.toIso8601String(),
      yearStart.toIso8601String(),
      yearEnd.toIso8601String(),
    ]);

    final todaySpecies = <String, int>{};
    final monthSpecies = <String, int>{};
    final yearSpecies = <String, int>{};
    final allSpecies = <String, int>{};

    for (final row in results) {
      final species = row['species'] as String?;
      if (species == null || species.isEmpty) continue;

      final todayCount = row['today_count'] as int? ?? 0;
      final monthCount = row['month_count'] as int? ?? 0;
      final yearCount = row['year_count'] as int? ?? 0;
      final allCount = row['all_count'] as int? ?? 0;

      if (todayCount > 0) todaySpecies[species] = todayCount;
      if (monthCount > 0) monthSpecies[species] = monthCount;
      if (yearCount > 0) yearSpecies[species] = yearCount;
      if (allCount > 0) allSpecies[species] = allCount;
    }

    return {
      'today': todaySpecies,
      'month': monthSpecies,
      'year': yearSpecies,
      'all': allSpecies,
    };
  }

  @override
  Future<Map<int, EquipmentCatchStats>> getEquipmentCatchStats() async {
    try {
      final db = await DatabaseProvider.instance.database;
      final results = await db.rawQuery('''
SELECT
  eq_id as equipment_id,
  COUNT(*) as catch_count,
  AVG(length) as avg_length,
  AVG(weight) as avg_weight,
  SUM(CASE WHEN fate = 0 THEN 1 ELSE 0 END) as release_count
FROM (
  SELECT equipment_id as eq_id, species, length, weight, fate FROM $_tableName WHERE equipment_id IS NOT NULL
  UNION ALL
  SELECT rod_id as eq_id, species, length, weight, fate FROM $_tableName WHERE rod_id IS NOT NULL
  UNION ALL
  SELECT reel_id as eq_id, species, length, weight, fate FROM $_tableName WHERE reel_id IS NOT NULL
  UNION ALL
  SELECT lure_id as eq_id, species, length, weight, fate FROM $_tableName WHERE lure_id IS NOT NULL
)
GROUP BY eq_id
''');

      final stats = <int, EquipmentCatchStats>{};
      for (final row in results) {
        final eqId = row['equipment_id'] as int?;
        if (eqId == null) continue;
        stats[eqId] = EquipmentCatchStats.fromMap(row);
      }
      return stats;
    } catch (e) {
      throw DatabaseException('Failed to get equipment catch stats: $e');
    }
  }

  @override
  Future<Map<int, Map<String, int>>> getAllEquipmentSpeciesStats() async {
    try {
      final db = await DatabaseProvider.instance.database;
      final results = await db.rawQuery('''
SELECT
  eq_id as equipment_id,
  species,
  COUNT(*) as species_count
FROM (
  SELECT equipment_id as eq_id, species FROM $_tableName WHERE equipment_id IS NOT NULL
  UNION ALL
  SELECT rod_id as eq_id, species FROM $_tableName WHERE rod_id IS NOT NULL
  UNION ALL
  SELECT reel_id as eq_id, species FROM $_tableName WHERE reel_id IS NOT NULL
  UNION ALL
  SELECT lure_id as eq_id, species FROM $_tableName WHERE lure_id IS NOT NULL
)
GROUP BY eq_id, species
''');

      final stats = <int, Map<String, int>>{};
      for (final row in results) {
        final eqId = row['equipment_id'] as int?;
        final species = row['species'] as String?;
        final count = row['species_count'] as int?;
        if (eqId == null || species == null || count == null) continue;

        if (!stats.containsKey(eqId)) {
          stats[eqId] = {};
        }
        stats[eqId]![species] = count;
      }
      return stats;
    } catch (e) {
      throw DatabaseException('Failed to get equipment species stats: $e');
    }
  }

  @override
  Future<Map<String, int>> getEquipmentDistribution(
    String type, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final db = await DatabaseProvider.instance.database;

      final typeToColumn = {
        'rod': 'rod_id',
        'reel': 'reel_id',
        'lure': 'lure_id',
      };
      final column = typeToColumn[type] ?? 'lure_id';

      String whereClause = 'f.$column IS NOT NULL';
      List<dynamic> whereArgs = [];

      if (startDate != null && endDate != null) {
        whereClause += ' AND f.catch_time >= ? AND f.catch_time < ?';
        whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
      }

      final results = await db.rawQuery('''
        SELECT e.brand, e.model, e.lure_type, COUNT(*) as count
        FROM $_tableName f
        LEFT JOIN equipments e ON f.$column = e.id
        WHERE $whereClause
        GROUP BY f.$column
        ORDER BY count DESC
        LIMIT 8
        ''', whereArgs);

      final distribution = <String, int>{};
      for (final row in results) {
        String name;
        if (type == 'lure') {
          name = row['lure_type'] as String? ?? 'Unknown';
        } else {
          final brand = row['brand'] as String? ?? '';
          final model = row['model'] as String? ?? '';
          name = '$brand $model'.trim();
          if (name.isEmpty) name = 'Unknown';
        }
        distribution[name] = row['count'] as int? ?? 0;
      }
      return distribution;
    } catch (e) {
      throw DatabaseException('Failed to get equipment distribution: $e');
    }
  }

  @override
  Future<List<FishCatch>> getTop3LongestCatches() async {
    try {
      final db = await DatabaseProvider.instance.database;
      final results = await db.query(
        _tableName,
        orderBy: 'length DESC',
        limit: 3,
      );
      return List<FishCatch>.from(
          results.map((map) => FishCatch.fromMap(map as Map<String, dynamic>)));
    } catch (e) {
      throw DatabaseException('Failed to get top 3 longest catches: $e');
    }
  }

  @override
  Future<int> getEquipmentFullStatus() async {
    try {
      final db = await DatabaseProvider.instance.database;
      final results = await db.rawQuery('''
        SELECT COUNT(*) as count FROM $_tableName
        WHERE equipment_id IS NOT NULL
           OR (rod_id IS NOT NULL AND reel_id IS NOT NULL AND lure_id IS NOT NULL)
      ''');
      return results.first['count'] as int? ?? 0;
    } catch (e) {
      throw DatabaseException('Failed to get equipment full status: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDailyCatchCount({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final db = await DatabaseProvider.instance.database;
      final results = await db.rawQuery('''
        SELECT
          DATE(catch_time) as date,
          COUNT(*) as count,
          SUM(CASE WHEN fate = 0 THEN 1 ELSE 0 END) as release,
          SUM(CASE WHEN fate = 1 THEN 1 ELSE 0 END) as keep
        FROM $_tableName
        WHERE catch_time >= ? AND catch_time < ?
        GROUP BY DATE(catch_time)
        ORDER BY date ASC
      ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

      return results.map((row) {
        return {
          'date': row['date'] as String,
          'count': row['count'] as int? ?? 0,
          'release': row['release'] as int? ?? 0,
          'keep': row['keep'] as int? ?? 0,
        };
      }).toList();
    } catch (e) {
      throw DatabaseException('Failed to get daily catch count: $e');
    }
  }
}
