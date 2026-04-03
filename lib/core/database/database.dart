import 'package:sqflite/sqflite.dart';

/// 数据库抽象接口
///
/// 定义所有数据库操作的抽象接口，用于：
/// - 生产环境：DatabaseWrapper 实现了该接口
/// - 测试环境：MockDatabase 实现了该接口，用于单元测试
///
/// 接口方法签名与 sqflite 的 Database 类一致，
/// 确保可以无缝替换实现。
abstract class Database {
  /// 查询数据表
  ///
  /// [table] 表名
  /// [where] WHERE 条件语句 (可选)
  /// [whereArgs] WHERE 条件参数 (可选)
  /// [orderBy] ORDER BY 排序语句 (可选)
  /// [limit] 返回记录数限制 (可选)
  /// [offset] 偏移量 (可选)
  /// [distinct] 是否去重 (可选)
  /// [columns] 返回的列名列表 (可选)
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  });

  /// 插入记录
  ///
  /// [table] 表名
  /// [values] 要插入的数据 Map
  /// [nullColumnHack] 当 values 为空时使用的列名 (可选)
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  });

  /// 更新记录
  ///
  /// [table] 表名
  /// [values] 要更新的数据 Map
  /// [where] WHERE 条件语句 (可选)
  /// [whereArgs] WHERE 条件参数 (可选)
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  });

  /// 删除记录
  ///
  /// [table] 表名
  /// [where] WHERE 条件语句 (可选)
  /// [whereArgs] WHERE 条件参数 (可选)
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  });

  /// 执行原始 SQL 查询
  ///
  /// [sql] SQL 语句
  /// [arguments] 参数列表 (可选)
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]);

  /// 执行原始 SQL 更新/删除
  ///
  /// [sql] SQL 语句
  /// [arguments] 参数列表 (可选)
  Future<int> rawUpdate(
    String sql, [
    List<dynamic>? arguments,
  ]);

  /// 执行原始 SQL 插入
  ///
  /// [sql] SQL 语句
  /// [arguments] 参数列表 (可选)
  Future<int> rawInsert(
    String sql, [
    List<dynamic>? arguments,
  ]);

  /// 执行原始 SQL 删除
  ///
  /// [sql] SQL 语句
  /// [arguments] 参数列表 (可选)
  Future<int> rawDelete(
    String sql, [
    List<dynamic>? arguments,
  ]);

  /// 执行事务
  ///
  /// [action] 事务回调，包含所有数据库操作
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action,
  );

  /// 关闭数据库连接
  Future<void> close();

  /// 执行原始 SQL 语句 (不返回结果)
  ///
  /// [sql] SQL 语句
  Future<void> execute(String sql);
}

/// Database 接口的 sqflite 实现包装类
///
/// 包装 sqflite 的 Database 实例，转换为 Database 接口
/// 供生产环境使用。
class DatabaseWrapper implements Database {
  final Database _db;

  DatabaseWrapper(this._db);

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) {
    return _db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    return _db.insert(
      table,
      values,
      nullColumnHack: nullColumnHack,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    return _db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) {
    return _db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) {
    return _db.rawQuery(sql, arguments);
  }

  @override
  Future<int> rawUpdate(
    String sql, [
    List<dynamic>? arguments,
  ]) {
    return _db.rawUpdate(sql, arguments);
  }

  @override
  Future<int> rawInsert(
    String sql, [
    List<dynamic>? arguments,
  ]) {
    return _db.rawInsert(sql, arguments);
  }

  @override
  Future<int> rawDelete(
    String sql, [
    List<dynamic>? arguments,
  ]) {
    return _db.rawDelete(sql, arguments);
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action,
  ) {
    return _db.transaction(action);
  }

  @override
  Future<void> close() {
    return _db.close();
  }

  @override
  Future<void> execute(String sql) {
    return _db.execute(sql);
  }
}
