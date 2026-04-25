import 'package:lurebox/core/exceptions/species_alias_exception.dart';
import 'package:lurebox/core/models/user_species_alias.dart';
import 'package:lurebox/core/repositories/base_repository.dart';

/// 用户鱼种别名仓储层
///
/// 管理用户鱼种别名与标准鱼种ID之间映射关系的数据访问。
abstract class UserSpeciesAliasRepository {
  /// 创建新的别名映射
  Future<int> create(String userAlias, String speciesId);

  /// 通过用户别名查找映射
  Future<UserSpeciesAlias?> findByAlias(String userAlias);

  /// 通过鱼种ID查找所有别名映射
  Future<List<UserSpeciesAlias>> findBySpeciesId(String speciesId);

  /// 删除指定ID的映射
  Future<void> delete(int id);

  /// 获取所有映射
  Future<List<UserSpeciesAlias>> getAll();
}

/// SQLite 实现 - 用户鱼种别名仓储层
class SqliteUserSpeciesAliasRepository extends BaseSqliteRepository
    implements UserSpeciesAliasRepository {

  /// 无参构造函数（使用默认 DatabaseService）
  SqliteUserSpeciesAliasRepository();

  /// 带数据库的构造函数（用于测试）
  SqliteUserSpeciesAliasRepository.withDatabase(super.testDb)
      : super.withDatabase();
  @override
  String get tableName => 'user_species_alias';

  @override
  Future<int> create(String userAlias, String speciesId) async {
    try {
      final db = await database;
      return await db.insert(tableName, {
        'user_alias': userAlias,
        'species_id': speciesId,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw SpeciesAliasException(
        message: 'Failed to create species alias',
        operation: 'create',
        cause: e,
      );
    }
  }

  @override
  Future<UserSpeciesAlias?> findByAlias(String userAlias) async {
    try {
      final db = await database;
      final results = await db.query(
        tableName,
        where: 'user_alias = ?',
        whereArgs: [userAlias],
        limit: 1,
      );
      if (results.isEmpty) return null;
      return UserSpeciesAlias.fromMap(results.first);
    } catch (e) {
      throw SpeciesAliasException(
        message: 'Failed to find species alias by alias',
        operation: 'findByAlias',
        cause: e,
      );
    }
  }

  @override
  Future<List<UserSpeciesAlias>> findBySpeciesId(String speciesId) async {
    try {
      final db = await database;
      final results = await db.query(
        tableName,
        where: 'species_id = ?',
        whereArgs: [speciesId],
        orderBy: 'created_at DESC',
      );
      return results.map(UserSpeciesAlias.fromMap).toList();
    } catch (e) {
      throw SpeciesAliasException(
        message: 'Failed to find species aliases by speciesId',
        operation: 'findBySpeciesId',
        cause: e,
      );
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      final db = await database;
      await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw SpeciesAliasException(
        message: 'Failed to delete species alias',
        operation: 'delete',
        cause: e,
      );
    }
  }

  @override
  Future<List<UserSpeciesAlias>> getAll() async {
    try {
      final db = await database;
      final results = await db.query(
        tableName,
        orderBy: 'created_at DESC',
      );
      return results.map(UserSpeciesAlias.fromMap).toList();
    } catch (e) {
      throw SpeciesAliasException(
        message: 'Failed to get all species aliases',
        operation: 'getAll',
        cause: e,
      );
    }
  }
}
