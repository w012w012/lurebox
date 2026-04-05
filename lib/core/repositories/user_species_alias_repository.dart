import 'package:sqflite/sqflite.dart';
import '../models/user_species_alias.dart';
import '../services/database_service.dart';

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
class SqliteUserSpeciesAliasRepository implements UserSpeciesAliasRepository {
  static const String _tableName = 'user_species_alias';

  /// 可选的数据库实例（用于测试注入）
  Future<Database>? _testDb;

  /// 内部获取数据库实例
  Future<Database> get _database async {
    final testDb = _testDb;
    if (testDb != null) return await testDb;
    return await DatabaseService.database;
  }

  /// 无参构造函数（使用默认 DatabaseService）
  SqliteUserSpeciesAliasRepository();

  /// 带数据库的构造函数（用于测试）
  SqliteUserSpeciesAliasRepository.withDatabase(Future<Database> testDb) {
    _testDb = testDb;
  }

  @override
  Future<int> create(String userAlias, String speciesId) async {
    try {
      final db = await _database;
      return await db.insert(_tableName, {
        'user_alias': userAlias,
        'species_id': speciesId,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to create species alias: $e');
    }
  }

  @override
  Future<UserSpeciesAlias?> findByAlias(String userAlias) async {
    try {
      final db = await _database;
      final results = await db.query(
        _tableName,
        where: 'user_alias = ?',
        whereArgs: [userAlias],
        limit: 1,
      );
      if (results.isEmpty) return null;
      return UserSpeciesAlias.fromMap(results.first);
    } catch (e) {
      throw Exception('Failed to find species alias by alias: $e');
    }
  }

  @override
  Future<List<UserSpeciesAlias>> findBySpeciesId(String speciesId) async {
    try {
      final db = await _database;
      final results = await db.query(
        _tableName,
        where: 'species_id = ?',
        whereArgs: [speciesId],
        orderBy: 'created_at DESC',
      );
      return results.map((map) => UserSpeciesAlias.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to find species aliases by speciesId: $e');
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      final db = await _database;
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete species alias: $e');
    }
  }

  @override
  Future<List<UserSpeciesAlias>> getAll() async {
    try {
      final db = await _database;
      final results = await db.query(
        _tableName,
        orderBy: 'created_at DESC',
      );
      return results.map((map) => UserSpeciesAlias.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get all species aliases: $e');
    }
  }
}
