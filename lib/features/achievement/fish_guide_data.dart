import 'package:lurebox/core/models/fish_species.dart';
import 'package:lurebox/features/achievement/fish_guide_data/freshwater_general_species.dart';
import 'package:lurebox/features/achievement/fish_guide_data/freshwater_lure_species.dart';
import 'package:lurebox/features/achievement/fish_guide_data/saltwater_general_species.dart';
import 'package:lurebox/features/achievement/fish_guide_data/saltwater_lure_species.dart';

/// 鱼类图鉴数据
///
/// 包含100+种预定义的鱼类物种数据，按分类组织在子目录中
class FishGuideData {
  FishGuideData._();

  /// 淡水路亚鱼种 (f001-f034)
  static List<FishSpecies> get freshwaterLureSpecies =>
      FreshwaterLureSpecies.data;

  /// 海水路亚鱼种 (f035-f050)
  static List<FishSpecies> get saltwaterLureSpecies =>
      SaltwaterLureSpecies.data;

  /// 淡水综合鱼种 (g001-g033)
  static List<FishSpecies> get freshwaterGeneralSpecies =>
      FreshwaterGeneralSpecies.data;

  /// 海水综合鱼种 (g015-g050)
  static List<FishSpecies> get saltwaterGeneralSpecies =>
      SaltwaterGeneralSpecies.data;

  /// 全部鱼类物种列表
  static List<FishSpecies> get allSpecies => [
        ...freshwaterLureSpecies,
        ...saltwaterLureSpecies,
        ...freshwaterGeneralSpecies,
        ...saltwaterGeneralSpecies,
      ];

  /// 根据ID获取鱼类物种
  static FishSpecies? getById(String id) {
    try {
      return allSpecies.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 根据分类获取鱼类物种
  static List<FishSpecies> getByCategory(FishCategory category) {
    return allSpecies.where((s) => s.category == category).toList();
  }

  /// 根据稀有度获取鱼类物种
  static List<FishSpecies> getByRarity(FishRarity rarity) {
    return allSpecies.where((s) => s.rarity == rarity).toList();
  }

  /// 搜索鱼类物种
  static List<FishSpecies> search(String keyword) {
    if (keyword.isEmpty) return allSpecies;
    final lower = keyword.toLowerCase();
    return allSpecies.where((s) {
      return s.standardName.toLowerCase().contains(lower) ||
          s.aliases.any((a) => a.toLowerCase().contains(lower)) ||
          (s.scientificName?.toLowerCase().contains(lower) ?? false);
    }).toList();
  }
}
