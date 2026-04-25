import 'package:lurebox/core/repositories/user_species_alias_repository.dart';
import 'package:lurebox/core/services/fish_species_matcher.dart';

/// 品种管理服务
///
/// 负责品种重命名和合并的同步逻辑
class SpeciesManagementService {

  /// 创建品种管理服务
  ///
  /// [aliasRepo] 用户别名仓储层
  /// [matcher] 鱼种匹配器
  SpeciesManagementService({
    required UserSpeciesAliasRepository aliasRepo,
    required FishSpeciesMatcher matcher,
  })  : _aliasRepo = aliasRepo,
        _matcher = matcher;
  final UserSpeciesAliasRepository _aliasRepo;
  final FishSpeciesMatcher _matcher;

  /// 重命名品种
  ///
  /// 将 oldName 重命名为 newName
  /// 1. 如果 newName 已被其他鱼种使用 -> 合并
  /// 2. 否则创建新的别名映射
  ///
  /// 注意: 不再直接修改 FishCatch.species 字段
  Future<void> renameSpecies(String oldName, String newName) async {
    // 1. 检查新名称是否已存在映射
    final existingMapping = await _aliasRepo.findByAlias(newName);

    if (existingMapping != null) {
      // 新名称已被其他鱼种使用 -> 合并
      await _mergeSpecies(existingMapping.speciesId, oldName);
    } else {
      // 2. 创建新的别名映射
      final species = _matcher.findSpeciesByName(oldName);
      if (species != null) {
        await _aliasRepo.create(newName, species.id);
      }
    }
  }

  /// 合并品种
  ///
  /// 将 sourceAlias 合并到 targetSpeciesId
  /// 1. 为 sourceAlias 创建到 targetSpeciesId 的映射
  /// 2. 不删除 FishCatch 记录，保持数据完整性
  Future<void> _mergeSpecies(String targetSpeciesId, String sourceAlias) async {
    await _aliasRepo.create(sourceAlias, targetSpeciesId);
  }
}
