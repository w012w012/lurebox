import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// 数据库提供者
/// 负责数据库的初始化和连接管理
class DatabaseProvider {
  static const String _databaseName = 'lurebox.db';
  static const int _databaseVersion = 14;

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
        notes TEXT,
        is_deleted INTEGER DEFAULT 0,
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
      'CREATE INDEX idx_fish_catches_species ON fish_catches(species)',
    );
    await db.execute(
      'CREATE INDEX idx_fish_catches_catch_time ON fish_catches(catch_time)',
    );
    await db.execute(
      'CREATE INDEX idx_fish_catches_location ON fish_catches(location_name)',
    );
    await db.execute('CREATE INDEX idx_equipment_type ON equipments(type)');
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
      await db.execute(
        'ALTER TABLE equipments ADD COLUMN reel_weight TEXT',
      );
      await db.execute(
        'ALTER TABLE equipments ADD COLUMN reel_weight_unit TEXT DEFAULT \'g\'',
      );
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
