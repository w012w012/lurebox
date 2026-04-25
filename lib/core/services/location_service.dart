import 'package:lurebox/core/database/database_provider.dart';

/// 位置服务 - 钓点管理的业务逻辑层
///
/// 提供钓点位置的数据管理和智能识别功能：
/// - 位置查询：获取所有钓点及其渔获统计
/// - 位置合并：将多个相似或重复的地点名称合并为一个
/// - 相似识别：基于 Levenshtein 编辑距离算法（相似度 > 0.7）自动发现相似地点
///
/// 注意：[findSimilarLocations] 是同步方法，其他为异步方法。

class LocationService {

  LocationService(this._dbProvider);
  final DatabaseProvider _dbProvider;

  Future<List<Map<String, dynamic>>> getAllLocations() async {
    final db = await _dbProvider.database;
    final results = await db.rawQuery('''
      SELECT DISTINCT location_name, COUNT(*) as fish_count,
      MIN(catch_time) as first_time, MAX(catch_time) as last_time
      FROM fish_catches
      WHERE location_name IS NOT NULL AND location_name != ''
      GROUP BY location_name
      ORDER BY fish_count DESC
    ''');
    return results;
  }

  Future<int> getFishCountByLocation(String location) async {
    final db = await _dbProvider.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM fish_catches WHERE location_name = ?',
      [location],
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<void> mergeLocations(
    List<String> oldLocations,
    String newLocation,
  ) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      for (final oldLocation in oldLocations) {
        await txn.update(
          'fish_catches',
          {'location_name': newLocation},
          where: 'location_name = ?',
          whereArgs: [oldLocation],
        );
      }
    });
  }

  Future<void> renameLocation(String oldName, String newName) async {
    final db = await _dbProvider.database;
    await db.update(
      'fish_catches',
      {'location_name': newName},
      where: 'location_name = ?',
      whereArgs: [oldName],
    );
  }

  List<List<String>> findSimilarLocations(List<String> locations) {
    final groups = <List<String>>[];
    final processed = <String>{};

    for (final location in locations) {
      if (processed.contains(location)) continue;

      final similar = <String>[location];
      processed.add(location);

      for (final other in locations) {
        if (processed.contains(other)) continue;
        if (_isSimilarLocation(location, other)) {
          similar.add(other);
          processed.add(other);
        }
      }

      if (similar.length > 1) {
        groups.add(similar);
      }
    }

    return groups;
  }

  bool _isSimilarLocation(String loc1, String loc2) {
    if (loc1 == loc2) return false;

    final clean1 = _removeNumbers(loc1);
    final clean2 = _removeNumbers(loc2);

    if (clean1 == clean2) return true;

    final similarity = _calculateSimilarity(clean1, clean2);
    return similarity > 0.7;
  }

  String _removeNumbers(String str) {
    return str.replaceAll(RegExp(r'\d+'), '');
  }

  double _calculateSimilarity(String s1, String s2) {
    if (s1.isEmpty || s2.isEmpty) return 0;

    final longer = s1.length > s2.length ? s1 : s2;
    final shorter = s1.length > s2.length ? s2 : s1;

    final editDistance = _levenshteinDistance(longer, shorter);
    return (longer.length - editDistance) / longer.length;
  }

  int _levenshteinDistance(String s1, String s2) {
    final matrix = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (var i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= s1.length; i++) {
      for (var j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s1.length][s2.length];
  }

  String getBestLocationName(List<String> locations) {
    if (locations.isEmpty) return '';
    return locations.reduce((a, b) => a.length > b.length ? a : b);
  }
}
