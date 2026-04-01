import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

export '../constants/constants.dart';

/// 数据库服务 - Lurebox 应用的核心数据持久化层
///
/// 提供 SQLite 数据库的初始化、迁移和统计查询功能。
/// 支持从旧数据库（luayhu.db）自动迁移到新数据库（lurebox.db）。
/// 通过版本号管理 schema 升级（当前版本 10），包含以下数据表：
/// - fish_catches: 渔获记录
/// - species_history: 物种历史
/// - equipments: 钓具装备
/// - settings: 应用设置
///
/// 使用单例模式，通过 [database] 访问器获取数据库实例。

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lurebox.db');
    final oldPath = join(dbPath, 'luayhu.db');

    final oldDbExists = await File(oldPath).exists();
    final newDbExists = await File(path).exists();

    // 迁移旧数据库到新名称
    if (oldDbExists && !newDbExists) {
      await File(oldPath).copy(path);
    }

    final db = await openDatabase(
      path,
      version: 12,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    // 确保所有必需的列都存在
    await _ensureRequiredColumns(db);

    return db;
  }

  // 确保所有必需的列都存在
  static Future<void> _ensureRequiredColumns(Database db) async {
    try {
      // 检查 equipment 表的 lure_size_unit 列
      final result = await db.rawQuery('PRAGMA table_info(equipments)');
      final columnExists = result.any((row) => row['name'] == 'lure_size_unit');
      if (!columnExists) {
        await db.execute(
          'ALTER TABLE equipments ADD COLUMN lure_size_unit TEXT DEFAULT "cm"',
        );
      }
    } catch (e) {
      // 忽略错误
    }

    // 确保 fish_catches 表有所有必需的列
    try {
      final fishColumns = await db.rawQuery('PRAGMA table_info(fish_catches)');
      final fishColumnNames =
          fishColumns.map((row) => row['name'] as String).toSet();

      final requiredColumns = <String, String>{
        'air_temperature': 'REAL',
        'pressure': 'REAL',
        'weather_code': 'INTEGER',
        'length_unit': "TEXT DEFAULT 'cm'",
        'weight_unit': "TEXT DEFAULT 'kg'",
        'pending_recognition': 'INTEGER DEFAULT 0',
      };

      for (final entry in requiredColumns.entries) {
        if (!fishColumnNames.contains(entry.key)) {
          await db.execute(
            'ALTER TABLE fish_catches ADD COLUMN ${entry.key} ${entry.value}',
          );
          debugPrint('Added missing column: ${entry.key}');

          // 迁移修复：如果新增的是 pending_recognition 列，
          // 将所有 species='待识别' 的记录标记为待识别
          if (entry.key == 'pending_recognition') {
            await db.execute(
              "UPDATE fish_catches SET pending_recognition = 1 WHERE species = '待识别'",
            );
            debugPrint('Migrated existing "待识别" fish to pending_recognition=1');
          }
        }
      }
    } catch (e) {
      debugPrint('Error ensuring fish_catches columns: $e');
    }
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS equipments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type TEXT NOT NULL,
          brand TEXT,
          model TEXT,
          length TEXT,
          sections INTEGER,
          material TEXT,
          hardness TEXT,
          weight_range TEXT,
          reel_bearings INTEGER,
          reel_ratio TEXT,
          reel_capacity TEXT,
          reel_brake_type TEXT,
          lure_type TEXT,
          lure_weight TEXT,
          lure_color TEXT,
          price REAL,
          purchase_date TEXT,
          is_default INTEGER DEFAULT 0,
          is_deleted INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute(
        'ALTER TABLE fish_catches ADD COLUMN equipment_id INTEGER',
      );
    }

    if (oldVersion < 3) {
      await db.execute('ALTER TABLE fish_catches ADD COLUMN rod_id INTEGER');
      await db.execute('ALTER TABLE fish_catches ADD COLUMN reel_id INTEGER');
      await db.execute('ALTER TABLE fish_catches ADD COLUMN lure_id INTEGER');

      await db.execute('ALTER TABLE equipments ADD COLUMN category TEXT');
      await db.execute('ALTER TABLE equipments ADD COLUMN lure_size TEXT');
    }

    if (oldVersion < 4) {
      await db.execute('ALTER TABLE equipments ADD COLUMN reel_line TEXT');
      await db.execute('ALTER TABLE equipments ADD COLUMN reel_line_date TEXT');
    }

    if (oldVersion < 5) {
      await db.execute(
        'ALTER TABLE equipments ADD COLUMN reel_line_number TEXT',
      );
      await db.execute(
        'ALTER TABLE equipments ADD COLUMN reel_line_length TEXT',
      );
    }

    if (oldVersion < 6) {
      await db.execute('ALTER TABLE equipments ADD COLUMN rod_action TEXT');
    }

    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 8) {
      await _ensureIndexes(db);
    }

    if (oldVersion < 9) {
      await db.execute(
        'ALTER TABLE fish_catches ADD COLUMN length_unit TEXT DEFAULT "cm"',
      );
      await db.execute(
        'ALTER TABLE fish_catches ADD COLUMN weight_unit TEXT DEFAULT "kg"',
      );

      await db.execute(
        'ALTER TABLE equipments ADD COLUMN length_unit TEXT DEFAULT "m"',
      );
      await db.execute(
        'ALTER TABLE equipments ADD COLUMN lure_weight_unit TEXT DEFAULT "g"',
      );
      await db.execute(
        'ALTER TABLE equipments ADD COLUMN line_length_unit TEXT DEFAULT "m"',
      );
      await db.execute(
        'ALTER TABLE equipments ADD COLUMN line_weight_unit TEXT DEFAULT "kg"',
      );
    }

    if (oldVersion < 10) {
      await db.execute(
        'ALTER TABLE equipments ADD COLUMN lure_quantity INTEGER',
      );
      await db.execute(
        'ALTER TABLE equipments ADD COLUMN lure_quantity_unit TEXT',
      );
    }

    if (oldVersion < 11) {
      await db.execute(
        'ALTER TABLE fish_catches ADD COLUMN air_temperature REAL',
      );
      await db.execute('ALTER TABLE fish_catches ADD COLUMN pressure REAL');
      await db.execute(
        'ALTER TABLE fish_catches ADD COLUMN weather_code INTEGER',
      );
    }

    if (oldVersion < 12) {
      await db.execute(
        'ALTER TABLE equipments ADD COLUMN lure_size_unit TEXT DEFAULT "cm"',
      );
      await _ensureColumnExists(
        db,
        'fish_catches',
        'pending_recognition',
        'INTEGER DEFAULT 0',
      );
      // 迁移修复：将已有的"待识别"记录标记为待识别
      await db.execute(
        "UPDATE fish_catches SET pending_recognition = 1 WHERE species = '待识别'",
      );
    }

    // 检查并添加缺失的列（防止版本跳跃）
    await _ensureColumnExists(
      db,
      'equipments',
      'lure_size_unit',
      'TEXT DEFAULT "cm"',
    );
  }

  // 检查列是否存在，不存在则添加
  static Future<void> _ensureColumnExists(
    Database db,
    String table,
    String column,
    String type,
  ) async {
    try {
      final result = await db.rawQuery('PRAGMA table_info($table)');
      final columnExists = result.any((row) => row['name'] == column);
      if (!columnExists) {
        await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
      }
    } catch (e) {
      // 忽略错误，可能是权限问题
    }
  }

  static Future<void> _ensureIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_fish_catches_time ON fish_catches(catch_time)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_fish_catches_fate ON fish_catches(fate)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_fish_catches_species ON fish_catches(species)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_equipments_type ON equipments(type)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_species_history_name ON species_history(name)',
    );
    // pending_recognition 索引 - 优化待识别查询
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_fish_catches_pending ON fish_catches(pending_recognition)',
    );
    // 复合索引优化常见筛选查询
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_fish_catches_time_fate ON fish_catches(catch_time, fate)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_fish_catches_time_species ON fish_catches(catch_time, species)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_fish_catches_fate_time ON fish_catches(fate, catch_time)',
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE fish_catches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_path TEXT NOT NULL,
        watermarked_image_path TEXT,
        species TEXT NOT NULL,
        length REAL NOT NULL,
        length_unit TEXT DEFAULT 'cm',
        weight REAL,
        weight_unit TEXT DEFAULT 'kg',
        fate INTEGER NOT NULL,
        catch_time TEXT NOT NULL,
        location_name TEXT,
        latitude REAL,
        longitude REAL,
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

    await db.execute('''
      CREATE TABLE species_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        use_count INTEGER NOT NULL DEFAULT 1,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
  CREATE TABLE equipments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT NOT NULL,
    brand TEXT,
    model TEXT,
    length TEXT,
    length_unit TEXT DEFAULT 'm',
    sections INTEGER,
    material TEXT,
    hardness TEXT,
    weight_range TEXT,
    reel_bearings INTEGER,
    reel_ratio TEXT,
    reel_capacity TEXT,
    reel_brake_type TEXT,
    lure_type TEXT,
    lure_weight TEXT,
    lure_weight_unit TEXT DEFAULT 'g',
    lure_size TEXT,
    lure_size_unit TEXT DEFAULT 'cm',
    lure_color TEXT,
    lure_quantity INTEGER,
    lure_quantity_unit TEXT,
    price REAL,
    purchase_date TEXT,
    is_default INTEGER DEFAULT 0,
    is_deleted INTEGER DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    category TEXT,
    reel_line TEXT,
    reel_line_date TEXT,
    reel_line_number TEXT,
    reel_line_length TEXT,
    rod_action TEXT,
    line_length_unit TEXT DEFAULT 'm',
    line_weight_unit TEXT DEFAULT 'kg'
  )
  ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await _ensureIndexes(db);
  }

  static Future<Map<String, int>> getStatsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT 
        COUNT(*) as total,
        COALESCE(SUM(CASE WHEN fate = 0 THEN 1 ELSE 0 END), 0) as release,
        COALESCE(SUM(CASE WHEN fate = 1 THEN 1 ELSE 0 END), 0) as keep
      FROM fish_catches 
      WHERE catch_time >= ? AND catch_time < ?
    ''',
      [start.toIso8601String(), end.toIso8601String()],
    );

    final row = result.first;
    return {
      'total': (row['total'] as int?) ?? 0,
      'release': (row['release'] as int?) ?? 0,
      'keep': (row['keep'] as int?) ?? 0,
    };
  }

  static Future<Map<String, int>> getSpeciesStatsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final results = await db.rawQuery(
      '''
      SELECT species, COUNT(*) as count 
      FROM fish_catches 
      WHERE catch_time >= ? AND catch_time < ?
      GROUP BY species 
      ORDER BY count DESC
      LIMIT 10
    ''',
      [start.toIso8601String(), end.toIso8601String()],
    );

    final stats = <String, int>{};
    for (final row in results) {
      stats[row['species'] as String] = (row['count'] as int?) ?? 0;
    }
    return stats;
  }
}
