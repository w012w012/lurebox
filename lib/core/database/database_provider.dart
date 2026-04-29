import 'dart:async';

import 'package:lurebox/core/services/app_logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// 数据库提供者
/// 负责数据库的初始化和连接管理
class DatabaseProvider {

  DatabaseProvider._();
  static DatabaseProvider? _instance;
  static DatabaseProvider get instance => _instance ??= DatabaseProvider._();

  static const String _databaseName = 'lurebox.db';
  static const int _databaseVersion = 23;

  Database? _database;
  Completer<Database>? _initCompleter;

  /// 获取数据库实例（单例模式）
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    // 首次调用时启动初始化
    _initCompleter ??= Completer<Database>();
    if (_initCompleter!.isCompleted) {
      // 初始化已完成但_database非空（正常情况）
      if (_database != null) return _database!;
      // 异常状态：Completer已完成但database为null，创建一个新的
      _initCompleter = Completer<Database>();
    }

    final completer = _initCompleter!;

    // 如果初始化还未开始
    if (_database == null && !completer.isCompleted) {
      _doInitialize(completer);
    }

    return completer.future;
  }

  Future<void> _doInitialize(Completer<Database> completer) async {
    try {
      _database = await _initDatabase();
      completer.complete(_database!);
    } catch (e) {
      completer.completeError(e);
      rethrow;
    }
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    AppLogger.i('DatabaseProvider', 'Opening database: $path');

    return openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
    );
  }

  /// 数据库配置回调
  Future<void> _onConfigure(Database db) async {
    // 启用外键约束
    await db.execute('PRAGMA foreign_keys = ON');
    // WAL 模式：提升并发读写性能
    // 必须用 rawQuery：Android 上 PRAGMA journal_mode 返回结果集
    await db.rawQuery('PRAGMA journal_mode = WAL');
  }

  /// 数据库创建回调
  Future<void> _onCreate(Database db, int version) async {
    AppLogger.i('DatabaseProvider', 'Creating database version $version');
    await _createSchema(db);
  }

  /// 数据库升级回调
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.i('DatabaseProvider', 'Upgrading database from $oldVersion to $newVersion');
    await _migrateDatabase(db, oldVersion, newVersion);
  }

  /// 数据库降级回调
  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.i('DatabaseProvider', 'Downgrading database from $oldVersion to $newVersion');
    // 降级时保留数据，不执行任何操作
  }

  /// 创建数据库表结构
  Future<void> _createSchema(Database db) async {
    // 鱼获表
    await db.execute('''
      CREATE TABLE fish_catches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_path TEXT,
        watermarked_image_path TEXT,
        species TEXT NOT NULL,
        length REAL NOT NULL,
        length_unit TEXT DEFAULT 'cm',
        weight REAL,
        weight_unit TEXT DEFAULT 'kg',
        fate INTEGER DEFAULT 0,
        catch_time INTEGER NOT NULL, -- HISTORICAL: stores ISO 8601 text (e.g. '2024-01-15T10:30:00.000') despite INTEGER affinity.
                                    -- ISO 8601 lexicographic order == chronological order, so range comparisons work.
                                    -- Do NOT migrate to real integers without updating all query code + backup import logic.
        location_name TEXT,
        latitude REAL,
        longitude REAL,
        notes TEXT,
        equipment_id INTEGER,
        rod_id INTEGER,
        reel_id INTEGER,
        lure_id INTEGER,
        air_temperature REAL,
        pressure REAL,
        weather_code INTEGER,
        pending_recognition INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 装备表
    await db.execute('''
      CREATE TABLE equipments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        brand TEXT,
        model TEXT,
        lure_type TEXT,
        lure_quantity INTEGER DEFAULT 1,
        lure_quantity_unit TEXT DEFAULT 'pcs',
        rod_power TEXT,
        rod_action TEXT,
        rod_length TEXT,
        rod_weight TEXT,
        reel_size TEXT,
        reel_ratio TEXT,
        reel_bearings INTEGER,
        reel_capacity TEXT,
        reel_brake_type TEXT,
        reel_drag TEXT,
        reel_drag_unit TEXT DEFAULT 'kg',
        reel_weight TEXT,
        reel_weight_unit TEXT DEFAULT 'g',
        joint_type TEXT,
        lure_weight TEXT,
        lure_weight_unit TEXT DEFAULT 'g',
        lure_size TEXT,
        lure_size_unit TEXT DEFAULT 'cm',
        lure_color TEXT,
        notes TEXT,
        price REAL,
        purchase_date TEXT,
        is_default INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0,
        category TEXT,
        reel_line TEXT,
        reel_line_date TEXT,
        reel_line_number TEXT,
        reel_line_length TEXT,
        line_length_unit TEXT DEFAULT 'm',
        line_weight_unit TEXT DEFAULT 'kg',
        weight_range TEXT,
        length TEXT,
        length_unit TEXT DEFAULT 'm',
        sections TEXT,
        material TEXT,
        hardness TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 设置表
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 物种历史表
    await db.execute('''
      CREATE TABLE species_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        use_count INTEGER DEFAULT 1,
        is_deleted INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

// 创建索引
    await db.execute(
      'CREATE INDEX idx_fish_catches_fate ON fish_catches(fate)',
    );
    await db.execute(
      'CREATE INDEX idx_fish_catches_equipment_id ON fish_catches(equipment_id)',
    );
    await db.execute(
      'CREATE INDEX idx_fish_catches_rod_id ON fish_catches(rod_id)',
    );
    await db.execute(
      'CREATE INDEX idx_fish_catches_reel_id ON fish_catches(reel_id)',
    );
    await db.execute(
      'CREATE INDEX idx_fish_catches_lure_id ON fish_catches(lure_id)',
    );
    // 关键索引：按时间排序查询（最常见的查询模式）
    await db.execute(
      'CREATE INDEX idx_fish_catches_catch_time ON fish_catches(catch_time)',
    );
    // 复合索引：时间 + 命运筛选（首页/列表常用）
    await db.execute(
      'CREATE INDEX idx_fish_catches_time_fate ON fish_catches(catch_time, fate)',
    );
    // 品种筛选索引
    await db.execute(
      'CREATE INDEX idx_fish_catches_species ON fish_catches(species)',
    );
    // 待识别筛选索引
    await db.execute(
      'CREATE INDEX idx_fish_catches_pending ON fish_catches(pending_recognition)',
    );

    // 装备表索引：按类型查询
    await db.execute(
      'CREATE INDEX idx_equipments_type ON equipments(type)',
    );
    // 装备表索引：按分类查询
    await db.execute(
      'CREATE INDEX idx_equipments_category ON equipments(category)',
    );
    // 装备表索引：按删除状态查询（软删除）
    await db.execute(
      'CREATE INDEX idx_equipments_is_deleted ON equipments(is_deleted)',
    );
    // 品种历史表索引：按名称查询
    await db.execute(
      'CREATE INDEX idx_species_history_name ON species_history(name)',
    );
  }

  /// 数据库迁移
  Future<void> _migrateDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE equipments ADD COLUMN lure_quantity INTEGER DEFAULT 1',
      );
    }
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE equipments ADD COLUMN lure_quantity_unit TEXT DEFAULT 'pcs'",
      );
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE equipments ADD COLUMN rod_power TEXT');
      await db.execute('ALTER TABLE equipments ADD COLUMN rod_action TEXT');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE equipments ADD COLUMN rod_length TEXT');
      await db.execute('ALTER TABLE equipments ADD COLUMN rod_weight TEXT');
    }
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE equipments ADD COLUMN reel_size TEXT');
      await db.execute('ALTER TABLE equipments ADD COLUMN reel_ratio TEXT');
    }
    if (oldVersion < 7) {
      await db.execute(
        'ALTER TABLE fish_catches ADD COLUMN watermarked_image_path TEXT',
      );
    }
    if (oldVersion < 8) {
      await db.execute(
        'ALTER TABLE fish_catches ADD COLUMN location_name TEXT',
      );
      await db.execute('ALTER TABLE fish_catches ADD COLUMN latitude REAL');
      await db.execute('ALTER TABLE fish_catches ADD COLUMN longitude REAL');
    }
    if (oldVersion < 9) {
      await db.execute('ALTER TABLE fish_catches ADD COLUMN notes TEXT');
    }
    if (oldVersion < 10) {
      await db.execute('ALTER TABLE equipments ADD COLUMN lure_type TEXT');
    }
    if (oldVersion < 11) {
      // 创建云备份配置表
      await db.execute('''
CREATE TABLE cloud_configs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  provider TEXT NOT NULL,
  server_url TEXT NOT NULL,
  username TEXT NOT NULL,
  password TEXT NOT NULL,
  is_active INTEGER DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''');
      // 创建本地备份历史表
      await db.execute('''
CREATE TABLE backup_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  file_path TEXT NOT NULL,
  file_name TEXT NOT NULL,
  backup_type TEXT NOT NULL,
  file_size INTEGER NOT NULL,
  fish_count INTEGER DEFAULT 0,
  equipment_count INTEGER DEFAULT 0,
  photo_count INTEGER DEFAULT 0,
  created_at TEXT NOT NULL
)
''');
      await db.execute(
        'CREATE INDEX idx_backup_history_created_at ON backup_history(created_at)',
      );
    }
    if (oldVersion < 12) {
      await db.execute(
        'ALTER TABLE fish_catches ADD COLUMN pending_recognition INTEGER DEFAULT 0',
      );
    }
    if (oldVersion < 13) {
      await db.execute(
        'ALTER TABLE equipments ADD COLUMN joint_type TEXT',
      );
    }
    if (oldVersion < 14) {
      await _addColumnIfNotExists(db, 'equipments', 'reel_weight', 'TEXT');
      await _addColumnIfNotExists(
        db,
        'equipments',
        'reel_weight_unit',
        "TEXT DEFAULT 'g'",
      );
    }
    if (oldVersion < 15) {
      // Ensure all columns exist for users who may have skipped migrations
      await _addColumnIfNotExists(db, 'equipments', 'reel_bearings', 'INTEGER');
      await _addColumnIfNotExists(db, 'equipments', 'reel_capacity', 'TEXT');
      await _addColumnIfNotExists(
        db,
        'equipments',
        'reel_brake_type',
        'TEXT',
      );
      await _addColumnIfNotExists(db, 'equipments', 'joint_type', 'TEXT');
      await _addColumnIfNotExists(db, 'equipments', 'lure_weight', 'TEXT');
      await _addColumnIfNotExists(
        db,
        'equipments',
        'lure_weight_unit',
        "TEXT DEFAULT 'g'",
      );
      await _addColumnIfNotExists(db, 'equipments', 'lure_size', 'TEXT');
      await _addColumnIfNotExists(
        db,
        'equipments',
        'lure_size_unit',
        "TEXT DEFAULT 'cm'",
      );
      await _addColumnIfNotExists(db, 'equipments', 'lure_color', 'TEXT');
      await _addColumnIfNotExists(db, 'equipments', 'price', 'REAL');
      await _addColumnIfNotExists(db, 'equipments', 'purchase_date', 'TEXT');
      await _addColumnIfNotExists(
        db,
        'equipments',
        'is_default',
        'INTEGER DEFAULT 0',
      );
      await _addColumnIfNotExists(db, 'equipments', 'category', 'TEXT');
      await _addColumnIfNotExists(db, 'equipments', 'reel_line', 'TEXT');
      await _addColumnIfNotExists(db, 'equipments', 'reel_line_date', 'TEXT');
      await _addColumnIfNotExists(
        db,
        'equipments',
        'reel_line_number',
        'TEXT',
      );
      await _addColumnIfNotExists(
        db,
        'equipments',
        'reel_line_length',
        'TEXT',
      );
      await _addColumnIfNotExists(
        db,
        'equipments',
        'line_length_unit',
        "TEXT DEFAULT 'm'",
      );
      await _addColumnIfNotExists(
        db,
        'equipments',
        'line_weight_unit',
        "TEXT DEFAULT 'kg'",
      );
      await _addColumnIfNotExists(db, 'equipments', 'weight_range', 'TEXT');
      await _addColumnIfNotExists(db, 'equipments', 'length', 'TEXT');
      await _addColumnIfNotExists(
        db,
        'equipments',
        'length_unit',
        "TEXT DEFAULT 'm'",
      );
      await _addColumnIfNotExists(db, 'equipments', 'sections', 'TEXT');
      await _addColumnIfNotExists(db, 'equipments', 'material', 'TEXT');
      await _addColumnIfNotExists(db, 'equipments', 'hardness', 'TEXT');
    }
    if (oldVersion < 16) {
      // 添加钓组配置字段到渔获表
      await _addColumnIfNotExists(db, 'fish_catches', 'rig_type', 'TEXT');
      await _addColumnIfNotExists(db, 'fish_catches', 'sinker_weight', 'TEXT');
      await _addColumnIfNotExists(
          db, 'fish_catches', 'sinker_position', 'TEXT',);
      await _addColumnIfNotExists(db, 'fish_catches', 'hook_type', 'TEXT');
      await _addColumnIfNotExists(db, 'fish_catches', 'hook_size', 'TEXT');
      await _addColumnIfNotExists(db, 'fish_catches', 'hook_weight', 'TEXT');
    }
    if (oldVersion < 17) {
      // 创建 fish_species 表 (预定义鱼种，只读，通过 FishGuideData 访问)
      await db.execute('''
CREATE TABLE fish_species (
  id TEXT PRIMARY KEY,
  standard_name TEXT NOT NULL,
  scientific_name TEXT,
  category INTEGER NOT NULL,
  rarity INTEGER NOT NULL,
  habitat TEXT,
  behavior TEXT,
  fishing_method TEXT,
  description TEXT,
  icon_emoji TEXT
)
''');

      // 创建 user_species_alias 表
      await db.execute('''
CREATE TABLE user_species_alias (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_alias TEXT NOT NULL UNIQUE,
  species_id TEXT NOT NULL,
  created_at INTEGER NOT NULL
)
''');

      // 创建索引
      await db.execute(
          'CREATE INDEX idx_alias_user_alias ON user_species_alias(user_alias)',);
      await db.execute(
          'CREATE INDEX idx_alias_species ON user_species_alias(species_id)',);
    }
    if (oldVersion < 21) {
      // 添加 catch_time 索引以优化按时间排序的查询
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_fish_catches_catch_time ON fish_catches(catch_time)',
      );
      // 复合索引：时间 + 命运筛选
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_fish_catches_time_fate ON fish_catches(catch_time, fate)',
      );
    }
    if (oldVersion < 22) {
      // 装备表索引：按类型、分类、删除状态查询
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_equipments_type ON equipments(type)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_equipments_category ON equipments(category)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_equipments_is_deleted ON equipments(is_deleted)',
      );
    }
    if (oldVersion < 23) {
      // 渔轮卸力值字段
      await _addColumnIfNotExists(db, 'equipments', 'reel_drag', 'TEXT');
      await _addColumnIfNotExists(
        db,
        'equipments',
        'reel_drag_unit',
        "TEXT DEFAULT 'kg'",
      );
    }
  }

  /// 安全添加列（如果不存在）
  ///
  /// [critical] 为 true 时，添加失败会抛出异常阻止迁移继续。
  /// 默认 false — 可选列添加失败时仅记录警告。
  Future<void> _addColumnIfNotExists(
    Database db,
    String table,
    String column,
    String type, {
    bool critical = false,
  }) async {
    try {
      final result = await db.rawQuery(
        'PRAGMA table_info($table)',
      );
      final columnExists = result.any((row) => row['name'] == column);
      if (!columnExists) {
        await db.execute(
          'ALTER TABLE $table ADD COLUMN $column $type',
        );
        AppLogger.i('DatabaseProvider', 'Added column $column to $table');
      }
    } catch (e) {
      if (critical) rethrow;
      AppLogger.w('DatabaseProvider', 'Failed to add column $column to $table', e);
    }
  }

  /// 关闭数据库连接
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// 重置数据库（用于测试）
  Future<void> resetForTesting() async {
    await close();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    await deleteDatabase(path);
    _database = null;
  }
}
