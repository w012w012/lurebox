import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// 数据库提供者
/// 负责数据库的初始化和连接管理
class DatabaseProvider {
  static const String _databaseName = 'lurebox.db';
  static const int _databaseVersion = 19;

  Database? _database;
  bool _initializing = false;

  /// 获取数据库实例（单例模式）
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    if (_initializing) {
      // 等待初始化完成
      while (_initializing && _database == null) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      return _database!;
    }

    _initializing = true;
    try {
      _database = await _initDatabase();
      return _database!;
    } finally {
      _initializing = false;
    }
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    debugPrint('Opening database: $path');

    return await openDatabase(
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
  }

  /// 数据库创建回调
  Future<void> _onCreate(Database db, int version) async {
    debugPrint('Creating database version $version');
    await _createSchema(db);
  }

  /// 数据库升级回调
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('Upgrading database from $oldVersion to $newVersion');
    await _migrateDatabase(db, oldVersion, newVersion);
  }

  /// 数据库降级回调
  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('Downgrading database from $oldVersion to $newVersion');
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
        catch_time INTEGER NOT NULL,
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

    // 创建 species_profiles 表 (鱼种详细信息) - v18
    await db.execute('''
CREATE TABLE species_profiles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  species_id TEXT NOT NULL UNIQUE,
  aliases TEXT,
  identification TEXT,
  habitat TEXT,
  feeding_behavior TEXT,
  fishing_techniques TEXT,
  size_records TEXT,
  conservation_status TEXT,
  source_references TEXT,
  confidence_score TEXT,
  version INTEGER DEFAULT 1,
  created_at TEXT,
  updated_at TEXT
)
''');

    // 创建索引
    await db.execute(
        'CREATE INDEX idx_species_profiles_species_id ON species_profiles(species_id)');
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
        'ALTER TABLE equipments ADD COLUMN lure_quantity_unit TEXT DEFAULT \'pcs\'',
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
          db, 'fish_catches', 'sinker_position', 'TEXT');
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
          'CREATE INDEX idx_alias_user_alias ON user_species_alias(user_alias)');
      await db.execute(
          'CREATE INDEX idx_alias_species ON user_species_alias(species_id)');
    }
    if (oldVersion < 19) {
      // 创建 species_profiles 表（如果不存在）
      await db.execute('''
CREATE TABLE IF NOT EXISTS species_profiles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  species_id TEXT NOT NULL UNIQUE,
  aliases TEXT,
  identification TEXT,
  habitat TEXT,
  feeding_behavior TEXT,
  fishing_techniques TEXT,
  size_records TEXT,
  conservation_status TEXT,
  source_references TEXT,
  confidence_score TEXT,
  version INTEGER DEFAULT 1,
  created_at TEXT,
  updated_at TEXT
)
''');

      // 创建索引
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_species_profiles_species_id ON species_profiles(species_id)');
    }
  }

  /// 安全添加列（如果不存在）
  Future<void> _addColumnIfNotExists(
    Database db,
    String table,
    String column,
    String type,
  ) async {
    try {
      final result = await db.rawQuery(
        "PRAGMA table_info($table)",
      );
      final columnExists = result.any((row) => row['name'] == column);
      if (!columnExists) {
        await db.execute(
          'ALTER TABLE $table ADD COLUMN $column $type',
        );
        debugPrint('Added column $column to $table');
      }
    } catch (e) {
      debugPrint('Warning: Failed to add column $column to $table: $e');
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
