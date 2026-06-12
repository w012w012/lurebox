import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/database/database_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// =============================================================================
// Schema 等价性与完整性测试
// =============================================================================
// 与 database_provider_test.dart 不同，本文件通过 @visibleForTesting 测试缝
// 调用 DatabaseProvider 中【真实的】_createSchema / _migrateDatabase，
// 而非复制 SQL 镜像 —— 镜像会随源码漂移而失去防护作用（已发生过）。
//
// 三类保障：
// 1. 完整性：全新安装的 schema 必须包含所有仓储层引用的表/列/索引
// 2. 完整性：从最早公开版本（v12，initial commit cd773fc）升级到当前版本的
//    schema 同样必须完整
// 3. 等价性：全新安装与升级路径产出的 schema 必须完全一致（防未来漂移）
// =============================================================================

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  final provider = DatabaseProvider.instance;
  final currentVersion = DatabaseProvider.databaseVersionForTesting;

  /// 仓储层实际引用的全部表（来源：lib/core/repositories/ 各 impl）
  const requiredTables = {
    'fish_catches',
    'equipments',
    'settings',
    'species_history',
    'cloud_configs', // SqliteBackupConfigRepository
    'backup_history', // SqliteBackupConfigRepository
    'fish_species', // FishGuideData / SpeciesManagementService
    'user_species_alias', // SqliteUserSpeciesAliasRepository
  };

  /// FishCatch.toMap() 写入的全部列（来源：lib/core/models/fish_catch.dart）
  /// update() 不剥 null，任何缺列都会让编辑渔获直接失败。
  const requiredFishCatchColumns = {
    'id',
    'image_path',
    'watermarked_image_path',
    'species',
    'length',
    'length_unit',
    'weight',
    'weight_unit',
    'fate',
    'catch_time',
    'location_name',
    'latitude',
    'longitude',
    'notes',
    'equipment_id',
    'rod_id',
    'reel_id',
    'lure_id',
    'air_temperature',
    'pressure',
    'weather_code',
    'pending_recognition',
    'created_at',
    'updated_at',
    // v16 钓组字段
    'rig_type',
    'sinker_weight',
    'sinker_position',
    'hook_type',
    'hook_size',
    'hook_weight',
  };

  group('schema 完整性（全新安装）', () {
    late Database db;
    late String dbPath;

    setUp(() async {
      dbPath = _tempDbPath('fresh_completeness');
      db = await _openFresh(dbPath, provider, currentVersion);
    });

    tearDown(() async {
      await db.close();
      await _deleteDb(dbPath);
    });

    test('包含仓储层引用的全部表', () async {
      final tables = await _tableNames(db);
      for (final table in requiredTables) {
        expect(tables, contains(table), reason: '全新安装缺表: $table');
      }
    });

    test('fish_catches 包含 FishCatch.toMap() 的全部列', () async {
      final columns = await _columnNames(db, 'fish_catches');
      for (final column in requiredFishCatchColumns) {
        expect(columns, contains(column), reason: '全新安装 fish_catches 缺列: $column');
      }
    });

    test('支持含钓组字段的完整 UPDATE（模拟仓储层 update 行为）', () async {
      final now = DateTime.now().toIso8601String();
      final id = await db.insert('fish_catches', {
        'species': '鲈鱼',
        'length': 45.0,
        'catch_time': now,
        'created_at': now,
        'updated_at': now,
      });

      // SqliteFishCatchRepository.update() 传完整 toMap()，含 null 的钓组字段
      final updated = await db.update(
        'fish_catches',
        {
          'species': '翘嘴',
          'length': 50.0,
          'rig_type': null,
          'sinker_weight': null,
          'sinker_position': null,
          'hook_type': null,
          'hook_size': null,
          'hook_weight': null,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      expect(updated, equals(1));
    });
  });

  group('schema 完整性（v12 升级路径 — 最早公开版本）', () {
    late Database db;
    late String dbPath;

    setUp(() async {
      dbPath = _tempDbPath('upgrade_completeness');
      db = await _openUpgradedFromV12(dbPath, provider, currentVersion);
    });

    tearDown(() async {
      await db.close();
      await _deleteDb(dbPath);
    });

    test('升级后包含仓储层引用的全部表', () async {
      final tables = await _tableNames(db);
      for (final table in requiredTables) {
        expect(tables, contains(table), reason: 'v12 升级后缺表: $table');
      }
    });

    test('升级后 fish_catches 包含全部必需列', () async {
      final columns = await _columnNames(db, 'fish_catches');
      for (final column in requiredFishCatchColumns) {
        expect(columns, contains(column), reason: 'v12 升级后 fish_catches 缺列: $column');
      }
    });
  });

  group('schema 等价性（全新安装 == v12 升级）', () {
    test('两条路径产出的表/列/索引完全一致', () async {
      final freshPath = _tempDbPath('equiv_fresh');
      final upgradedPath = _tempDbPath('equiv_upgraded');

      final fresh = await _openFresh(freshPath, provider, currentVersion);
      final upgraded =
          await _openUpgradedFromV12(upgradedPath, provider, currentVersion);

      try {
        final freshSchema = await _normalizedSchema(fresh);
        final upgradedSchema = await _normalizedSchema(upgraded);

        // 逐表对比，给出可读的差异信息
        expect(
          upgradedSchema.keys.toSet(),
          equals(freshSchema.keys.toSet()),
          reason: '表集合不一致\n全新安装: ${freshSchema.keys.toList()..sort()}\n'
              'v12 升级: ${upgradedSchema.keys.toList()..sort()}',
        );
        for (final table in freshSchema.keys) {
          expect(
            upgradedSchema[table],
            equals(freshSchema[table]),
            reason: '表 [$table] 的结构在两条路径下不一致\n'
                '全新安装: ${freshSchema[table]}\n'
                'v12 升级: ${upgradedSchema[table]}',
          );
        }
      } finally {
        await fresh.close();
        await upgraded.close();
        await _deleteDb(freshPath);
        await _deleteDb(upgradedPath);
      }
    });
  });
}

// =============================================================================
// 辅助函数
// =============================================================================

String _tempDbPath(String suffix) {
  final dir = Directory.systemTemp.createTempSync('lurebox_schema_test');
  return '${dir.path}/lurebox_$suffix.db';
}

Future<void> _deleteDb(String path) async {
  try {
    final dir = File(path).parent;
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  } on FileSystemException {
    // 清理是尽力而为
  }
}

/// 用【真实的】_createSchema 建一个全新安装的库
Future<Database> _openFresh(
  String path,
  DatabaseProvider provider,
  int version,
) {
  return openDatabase(
    path,
    version: version,
    onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    onCreate: (db, v) => provider.createSchemaForTesting(db),
  );
}

/// 建一个 v12 基线库（最早公开版本 cd773fc 的 _createSchema，冻结的历史事实，
/// 不会随源码演进 —— 这是合法的镜像），再用【真实的】_migrateDatabase 升级。
Future<Database> _openUpgradedFromV12(
  String path,
  DatabaseProvider provider,
  int version,
) async {
  final v12 = await openDatabase(
    path,
    version: 12,
    onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    onCreate: (db, v) => _createSchemaV12Baseline(db),
  );
  await v12.close();

  return openDatabase(
    path,
    version: version,
    onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    onUpgrade: (db, oldV, newV) =>
        provider.migrateDatabaseForTesting(db, oldV, newV),
  );
}

Future<Set<String>> _tableNames(Database db) async {
  final rows = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table' "
    "AND name NOT LIKE 'sqlite_%' AND name != 'android_metadata'",
  );
  return rows.map((r) => r['name']! as String).toSet();
}

Future<Set<String>> _columnNames(Database db, String table) async {
  final rows = await db.rawQuery('PRAGMA table_info($table)');
  return rows.map((r) => r['name']! as String).toSet();
}

/// 归一化 schema：表 -> { 列签名集合, 索引名集合 }
/// 列签名含名称/类型/非空/默认值/主键，忽略列顺序；索引忽略 sqlite 自动索引。
Future<Map<String, Map<String, Set<String>>>> _normalizedSchema(
  Database db,
) async {
  final result = <String, Map<String, Set<String>>>{};
  for (final table in await _tableNames(db)) {
    final columnRows = await db.rawQuery('PRAGMA table_info($table)');
    final columns = columnRows
        .map((r) => '${r['name']}|${(r['type'] as String?)?.toUpperCase()}'
            '|nn=${r['notnull']}|df=${r['dflt_value']}|pk=${r['pk']}')
        .toSet();
    final indexRows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name=? "
      "AND name NOT LIKE 'sqlite_autoindex%'",
      [table],
    );
    final indexes = indexRows.map((r) => r['name']! as String).toSet();
    result[table] = {'columns': columns, 'indexes': indexes};
  }
  return result;
}

/// 最早公开版本（initial commit cd773fc，v1.0.3，_databaseVersion = 12）的
/// _createSchema 原样拷贝。这是冻结的历史事实，用作升级路径的起点。
Future<void> _createSchemaV12Baseline(Database db) async {
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

  await db.execute('''
    CREATE TABLE settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      key TEXT UNIQUE NOT NULL,
      value TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE species_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT UNIQUE NOT NULL,
      use_count INTEGER DEFAULT 1,
      is_deleted INTEGER DEFAULT 0,
      created_at TEXT NOT NULL
    )
  ''');

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
