import '../models/fish_species.dart';
import '../../features/achievement/fish_guide_data.dart';

/// 鱼类物种匹配服务
///
/// 提供多种匹配策略来查找鱼类物种：
/// 1. 精确匹配别名
/// 2. 精确匹配标准名称
/// 3. 部分匹配（输入包含在名称或别名中）
/// 4. 相似度匹配（Levenshtein距离）
class FishSpeciesMatcher {
  final List<FishSpecies> _allSpecies;

  /// 创建鱼类物种匹配服务
  ///
  /// 默认使用 FishGuideData 中的全部物种
  FishSpeciesMatcher() : _allSpecies = FishGuideData.allSpecies;

  /// 使用指定物种列表创建匹配器
  FishSpeciesMatcher.withSpecies(List<FishSpecies> species)
      : _allSpecies = species;

  /// 根据别名查找物种
  ///
  /// 执行精确匹配，不区分大小写
  ///
  /// [alias] 别名
  /// 返回匹配的物种，如果没有匹配则返回 null
  FishSpecies? findSpeciesByAlias(String alias) {
    if (alias.isEmpty) return null;

    final lowerAlias = alias.toLowerCase();
    try {
      return _allSpecies.firstWhere(
        (s) => s.aliases.any((a) => a.toLowerCase() == lowerAlias),
      );
    } catch (_) {
      return null;
    }
  }

  /// 根据名称查找物种（模糊匹配）
  ///
  /// 按优先级依次尝试：
  /// 1. 精确匹配别名
  /// 2. 精确匹配标准名称
  /// 3. 部分匹配（输入包含在名称或别名中）
  /// 4. 相似度匹配（Levenshtein距离 ≤ 3）
  ///
  /// [name] 名称输入
  /// 返回匹配的物种，如果没有匹配则返回 null
  FishSpecies? findSpeciesByName(String name) {
    if (name.isEmpty) return null;

    // 1. 精确匹配别名
    final byAlias = findSpeciesByAlias(name);
    if (byAlias != null) return byAlias;

    // 2. 精确匹配标准名称
    final lowerName = name.toLowerCase();
    try {
      final exactMatch = _allSpecies.firstWhere(
        (s) => s.standardName.toLowerCase() == lowerName,
      );
      return exactMatch;
    } catch (_) {
      // continue to partial match
    }

    // 3. 部分匹配（输入包含在名称或别名中）
    try {
      final partialMatch = _allSpecies.firstWhere(
        (s) =>
            s.standardName.contains(name) ||
            s.aliases.any((a) => a.contains(name)),
      );
      return partialMatch;
    } catch (_) {
      // continue to similarity match
    }

    // 4. 相似度匹配（Levenshtein距离）
    return _findSimilar(name);
  }

  /// 模糊匹配输入与候选列表
  ///
  /// 使用Levenshtein距离计算相似度，返回最相似的候选
  ///
  /// [input] 输入字符串
  /// [candidates] 候选字符串列表
  /// 返回最相似的候选字符串，如果没有匹配则返回 null
  String? fuzzyMatch(String input, List<String> candidates) {
    if (input.isEmpty || candidates.isEmpty) return null;

    String? bestMatch;
    int bestDistance = 2; // 阈值（Levenshtein距离 <= 2视为相似）

    for (final candidate in candidates) {
      final distance = _levenshteinDistance(input, candidate);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestMatch = candidate;
      }
    }

    return bestMatch;
  }

  /// 查找最相似的物种
  ///
  /// 使用Levenshtein距离计算相似度
  ///
  /// [input] 输入字符串
  /// 返回最相似的物种，如果没有匹配则返回 null
  FishSpecies? _findSimilar(String input) {
    FishSpecies? best;
    int bestDistance = 2; // 阈值（Levenshtein距离 <= 2视为相似）

    for (final species in _allSpecies) {
      // 计算与标准名称的距离
      final distance = _levenshteinDistance(input, species.standardName);
      if (distance < bestDistance) {
        bestDistance = distance;
        best = species;
        continue;
      }

      // 计算与别名的最小距离
      for (final alias in species.aliases) {
        final aliasDistance = _levenshteinDistance(input, alias);
        if (aliasDistance < bestDistance) {
          bestDistance = aliasDistance;
          best = species;
        }
      }
    }

    return best;
  }

  /// 计算Levenshtein编辑距离
  ///
  /// 计算两个字符串之间的最小编辑距离（插入、删除、替换）
  ///
  /// [s1] 第一个字符串
  /// [s2] 第二个字符串
  /// 返回编辑距离
  int _levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final m = s1.length;
    final n = s2.length;

    // 使用一维数组优化空间复杂度
    var previousRow = List<int>.generate(n + 1, (i) => i);
    var currentRow = List<int>.filled(n + 1, 0);

    for (var i = 1; i <= m; i++) {
      currentRow[0] = i;

      for (var j = 1; j <= n; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        currentRow[j] = [
          currentRow[j - 1] + 1, // 插入
          previousRow[j] + 1, // 删除
          previousRow[j - 1] + cost, // 替换
        ].reduce((a, b) => a < b ? a : b);
      }

      // 交换行
      final temp = previousRow;
      previousRow = currentRow;
      currentRow = temp;
    }

    return previousRow[n];
  }
}
