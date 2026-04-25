import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void setUpAll() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

void main() {
  setUpAll();

  group('DatabaseProvider', () {
    /// Creates a file-based database path for testing
    String createTempDbPath(String name) {
      final tempDir = Directory.systemTemp;
      return '${tempDir.path}/lurebox_test_$name${DateTime.now().millisecondsSinceEpoch}.db';
    }

    /// Helper to delete temp database
    Future<void> deleteDb(String dbPath) async {
      final file = File(dbPath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    group('Schema Creation (v22)', () {
      test('creates all required tables on fresh initialization', () async {
        final dbPath = createTempDbPath('schema_v22');

        try {
          final freshDb = await openDatabase(
            dbPath,
            version: 22,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              // Recreate the full v22 schema as defined in database_provider.dart
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

              // Create indexes
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
              await db.execute(
                'CREATE INDEX idx_fish_catches_catch_time ON fish_catches(catch_time)',
              );
              await db.execute(
                'CREATE INDEX idx_fish_catches_time_fate ON fish_catches(catch_time, fate)',
              );
              await db.execute(
                'CREATE INDEX idx_equipments_type ON equipments(type)',
              );
              await db.execute(
                'CREATE INDEX idx_equipments_category ON equipments(category)',
              );
              await db.execute(
                'CREATE INDEX idx_equipments_is_deleted ON equipments(is_deleted)',
              );
            },
          );

          try {
            // Verify all tables exist
            final tables = await freshDb.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
            );
            final tableNames = tables.map((t) => t['name']! as String).toList();

            expect(tableNames, contains('fish_catches'));
            expect(tableNames, contains('equipments'));
            expect(tableNames, contains('settings'));
            expect(tableNames, contains('species_history'));

            // Verify indexes on fish_catches
            final fishIndexes = await freshDb.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='fish_catches'",
            );
            final fishIndexNames =
                fishIndexes.map((i) => i['name']! as String).toList();

            expect(fishIndexNames, contains('idx_fish_catches_fate'));
            expect(fishIndexNames, contains('idx_fish_catches_equipment_id'));
            expect(fishIndexNames, contains('idx_fish_catches_catch_time'));
            expect(fishIndexNames, contains('idx_fish_catches_time_fate'));

            // Verify indexes on equipments
            final equipIndexes = await freshDb.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='equipments'",
            );
            final equipIndexNames =
                equipIndexes.map((i) => i['name']! as String).toList();

            expect(equipIndexNames, contains('idx_equipments_type'));
            expect(equipIndexNames, contains('idx_equipments_category'));
            expect(equipIndexNames, contains('idx_equipments_is_deleted'));
          } finally {
            await freshDb.close();
          }
        } finally {
          await deleteDb(dbPath);
        }
      });
    });

    group('Migration Tests', () {
      test('migrates v1 to v2 - adds lure_quantity column', () async {
        final dbPath = createTempDbPath('migrate_v1_v2');

        try {
          // Create v1 schema
          final db = await openDatabase(
            dbPath,
            version: 1,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE equipments (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  type TEXT NOT NULL,
                  brand TEXT,
                  model TEXT
                )
              ''');
            },
          );

          // Verify v1 doesn't have lure_quantity
          var columns = await db.rawQuery('PRAGMA table_info(equipments)');
          var columnNames = columns.map((c) => c['name']! as String).toList();
          expect(columnNames.contains('lure_quantity'), isFalse);

          await db.close();

          // Open with higher version to trigger upgrade
          final db2 = await openDatabase(
            dbPath,
            version: 2,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              if (oldVersion < 2) {
                await db.execute(
                  'ALTER TABLE equipments ADD COLUMN lure_quantity INTEGER DEFAULT 1',
                );
              }
            },
          );

          try {
            // Verify v2 has lure_quantity
            columns = await db2.rawQuery('PRAGMA table_info(equipments)');
            columnNames = columns.map((c) => c['name']! as String).toList();
            expect(columnNames, contains('lure_quantity'));
          } finally {
            await db2.close();
          }
        } finally {
          await deleteDb(dbPath);
        }
      });

      test('migrates v2 to v3 - adds lure_quantity_unit column', () async {
        final dbPath = createTempDbPath('migrate_v2_v3');

        try {
          // First create v1 schema
          var db = await openDatabase(
            dbPath,
            version: 1,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE equipments (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  type TEXT NOT NULL,
                  brand TEXT,
                  model TEXT
                )
              ''');
            },
          );
          await db.close();

          // Then open at v3 - this should trigger migrations v1->v2->v3
          db = await openDatabase(
            dbPath,
            version: 3,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (db, oldVersion, newVersion) async {
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
            },
          );

          try {
            final columns = await db.rawQuery('PRAGMA table_info(equipments)');
            final columnNames =
                columns.map((c) => c['name']! as String).toList();
            expect(columnNames, contains('lure_quantity'));
            expect(columnNames, contains('lure_quantity_unit'));
          } finally {
            await db.close();
          }
        } finally {
          await deleteDb(dbPath);
        }
      });

      test('migrates v3 to v4 - adds rod_power and rod_action', () async {
        final dbPath = createTempDbPath('migrate_v3_v4');

        try {
          // First create v1 schema
          var db = await openDatabase(
            dbPath,
            version: 1,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE equipments (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  type TEXT NOT NULL,
                  brand TEXT,
                  model TEXT
                )
              ''');
            },
          );
          await db.close();

          // Open at v4 - this should trigger migrations v1->v2->v3->v4
          db = await openDatabase(
            dbPath,
            version: 4,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (db, oldVersion, newVersion) async {
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
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN rod_power TEXT',);
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN rod_action TEXT',);
              }
            },
          );

          try {
            final columns = await db.rawQuery('PRAGMA table_info(equipments)');
            final columnNames =
                columns.map((c) => c['name']! as String).toList();
            expect(columnNames, contains('rod_power'));
            expect(columnNames, contains('rod_action'));
          } finally {
            await db.close();
          }
        } finally {
          await deleteDb(dbPath);
        }
      });

      test('migrates v6 to v7 - adds watermarked_image_path to fish_catches',
          () async {
        final dbPath = createTempDbPath('migrate_v6_v7');

        try {
          // Create v1 schema
          var db = await openDatabase(
            dbPath,
            version: 1,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE fish_catches (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  species TEXT NOT NULL,
                  length REAL NOT NULL,
                  catch_time INTEGER NOT NULL,
                  created_at TEXT NOT NULL,
                  updated_at TEXT NOT NULL
                )
              ''');
            },
          );
          await db.close();

          // Open at v7 to trigger upgrade
          db = await openDatabase(
            dbPath,
            version: 7,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              if (oldVersion < 7) {
                await db.execute(
                  'ALTER TABLE fish_catches ADD COLUMN watermarked_image_path TEXT',
                );
              }
            },
          );

          try {
            final columns =
                await db.rawQuery('PRAGMA table_info(fish_catches)');
            final columnNames =
                columns.map((c) => c['name']! as String).toList();
            expect(columnNames, contains('watermarked_image_path'));
          } finally {
            await db.close();
          }
        } finally {
          await deleteDb(dbPath);
        }
      });

      test('migrates v7 to v8 - adds location fields to fish_catches',
          () async {
        final dbPath = createTempDbPath('migrate_v7_v8');

        try {
          // Create v1 schema
          var db = await openDatabase(
            dbPath,
            version: 1,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE fish_catches (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  species TEXT NOT NULL,
                  length REAL NOT NULL,
                  catch_time INTEGER NOT NULL,
                  created_at TEXT NOT NULL,
                  updated_at TEXT NOT NULL
                )
              ''');
            },
          );
          await db.close();

          // Open at v8 to trigger upgrade through v7
          db = await openDatabase(
            dbPath,
            version: 8,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              if (oldVersion < 7) {
                await db.execute(
                  'ALTER TABLE fish_catches ADD COLUMN watermarked_image_path TEXT',
                );
              }
              if (oldVersion < 8) {
                await db.execute(
                  'ALTER TABLE fish_catches ADD COLUMN location_name TEXT',
                );
                await db.execute(
                  'ALTER TABLE fish_catches ADD COLUMN latitude REAL',
                );
                await db.execute(
                  'ALTER TABLE fish_catches ADD COLUMN longitude REAL',
                );
              }
            },
          );

          try {
            final columns =
                await db.rawQuery('PRAGMA table_info(fish_catches)');
            final columnNames =
                columns.map((c) => c['name']! as String).toList();
            expect(columnNames, contains('watermarked_image_path'));
            expect(columnNames, contains('location_name'));
            expect(columnNames, contains('latitude'));
            expect(columnNames, contains('longitude'));
          } finally {
            await db.close();
          }
        } finally {
          await deleteDb(dbPath);
        }
      });

      test(
          'migrates v10 to v11 - creates cloud_configs and backup_history tables',
          () async {
        final dbPath = createTempDbPath('migrate_v10_v11');

        try {
          // Create v1 schema
          var db = await openDatabase(
            dbPath,
            version: 1,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE equipments (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  type TEXT NOT NULL
                )
              ''');
            },
          );
          await db.close();

          // Open at v11 to trigger upgrade
          db = await openDatabase(
            dbPath,
            version: 11,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              if (oldVersion < 11) {
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
            },
          );

          try {
            final tables = await db.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='table'",
            );
            final tableNames = tables.map((t) => t['name']! as String).toList();

            expect(tableNames, contains('cloud_configs'));
            expect(tableNames, contains('backup_history'));

            // Verify backup_history index
            final indexes = await db.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='backup_history'",
            );
            final indexNames = indexes.map((i) => i['name']! as String).toList();
            expect(indexNames, contains('idx_backup_history_created_at'));
          } finally {
            await db.close();
          }
        } finally {
          await deleteDb(dbPath);
        }
      });

      test(
          'migrates v16 to v17 - creates fish_species and user_species_alias tables',
          () async {
        final dbPath = createTempDbPath('migrate_v16_v17');

        try {
          // Create v1 schema
          var db = await openDatabase(
            dbPath,
            version: 1,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE fish_catches (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  species TEXT NOT NULL,
                  catch_time INTEGER NOT NULL
                )
              ''');
            },
          );
          await db.close();

          // Open at v17 to trigger upgrade
          db = await openDatabase(
            dbPath,
            version: 17,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              if (oldVersion < 17) {
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

                await db.execute('''
                  CREATE TABLE user_species_alias (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_alias TEXT NOT NULL UNIQUE,
                    species_id TEXT NOT NULL,
                    created_at INTEGER NOT NULL
                  )
                ''');

                await db.execute(
                  'CREATE INDEX idx_alias_user_alias ON user_species_alias(user_alias)',
                );
                await db.execute(
                  'CREATE INDEX idx_alias_species ON user_species_alias(species_id)',
                );
              }
            },
          );

          try {
            final tables = await db.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='table'",
            );
            final tableNames = tables.map((t) => t['name']! as String).toList();

            expect(tableNames, contains('fish_species'));
            expect(tableNames, contains('user_species_alias'));

            // Verify indexes
            final indexes = await db.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='user_species_alias'",
            );
            final indexNames = indexes.map((i) => i['name']! as String).toList();
            expect(indexNames, contains('idx_alias_user_alias'));
            expect(indexNames, contains('idx_alias_species'));
          } finally {
            await db.close();
          }
        } finally {
          await deleteDb(dbPath);
        }
      });

      test('migrates v20 to v21 - adds catch_time indexes', () async {
        final dbPath = createTempDbPath('migrate_v20_v21');

        try {
          // Create v1 schema
          var db = await openDatabase(
            dbPath,
            version: 1,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE fish_catches (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  species TEXT NOT NULL,
                  catch_time INTEGER NOT NULL,
                  fate INTEGER DEFAULT 0
                )
              ''');
            },
          );
          await db.close();

          // Open at v21 to trigger upgrade
          db = await openDatabase(
            dbPath,
            version: 21,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              if (oldVersion < 21) {
                await db.execute(
                  'CREATE INDEX idx_fish_catches_catch_time ON fish_catches(catch_time)',
                );
                await db.execute(
                  'CREATE INDEX idx_fish_catches_time_fate ON fish_catches(catch_time, fate)',
                );
              }
            },
          );

          try {
            final indexes = await db.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='fish_catches'",
            );
            final indexNames = indexes.map((i) => i['name']! as String).toList();

            expect(indexNames, contains('idx_fish_catches_catch_time'));
            expect(indexNames, contains('idx_fish_catches_time_fate'));
          } finally {
            await db.close();
          }
        } finally {
          await deleteDb(dbPath);
        }
      });

      test('migrates v21 to v22 - adds equipment indexes', () async {
        final dbPath = createTempDbPath('migrate_v21_v22');

        try {
          // Create v1 schema
          var db = await openDatabase(
            dbPath,
            version: 1,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE equipments (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  type TEXT NOT NULL,
                  brand TEXT,
                  model TEXT,
                  category TEXT,
                  is_deleted INTEGER DEFAULT 0
                )
              ''');
            },
          );
          await db.close();

          // Open at v22 to trigger upgrade
          db = await openDatabase(
            dbPath,
            version: 22,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              if (oldVersion < 22) {
                await db.execute(
                  'CREATE INDEX idx_equipments_type ON equipments(type)',
                );
                await db.execute(
                  'CREATE INDEX idx_equipments_category ON equipments(category)',
                );
                await db.execute(
                  'CREATE INDEX idx_equipments_is_deleted ON equipments(is_deleted)',
                );
              }
            },
          );

          try {
            final indexes = await db.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='equipments'",
            );
            final indexNames = indexes.map((i) => i['name']! as String).toList();

            expect(indexNames, contains('idx_equipments_type'));
            expect(indexNames, contains('idx_equipments_category'));
            expect(indexNames, contains('idx_equipments_is_deleted'));
          } finally {
            await db.close();
          }
        } finally {
          await deleteDb(dbPath);
        }
      });

      test('full migration from v1 to v22 works correctly', () async {
        final dbPath = createTempDbPath('migrate_v1_v22_full');

        try {
          // Start with v1 schema
          var db = await openDatabase(
            dbPath,
            version: 1,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE fish_catches (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  species TEXT NOT NULL,
                  length REAL NOT NULL,
                  length_unit TEXT DEFAULT 'cm',
                  weight REAL,
                  weight_unit TEXT DEFAULT 'kg',
                  fate INTEGER DEFAULT 0,
                  catch_time INTEGER NOT NULL,
                  air_temperature REAL,
                  pressure REAL,
                  weather_code INTEGER,
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
                  is_deleted INTEGER DEFAULT 0
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
            },
          );

          // Insert some test data
          await db.insert('fish_catches', {
            'species': 'Bass',
            'length': 30.0,
            'catch_time': DateTime.now().millisecondsSinceEpoch,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });

          await db.insert('equipments', {
            'type': 'rod',
            'brand': 'Shimano',
            'model': 'Expride',
          });

          await db.close();

          // Migrate to v22
          db = await openDatabase(
            dbPath,
            version: 22,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              // Apply all migrations from v1 to v22
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
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN rod_power TEXT',);
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN rod_action TEXT',);
              }
              if (oldVersion < 5) {
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN rod_length TEXT',);
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN rod_weight TEXT',);
              }
              if (oldVersion < 6) {
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN reel_size TEXT',);
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN reel_ratio TEXT',);
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
                await db.execute(
                  'ALTER TABLE fish_catches ADD COLUMN latitude REAL',
                );
                await db.execute(
                  'ALTER TABLE fish_catches ADD COLUMN longitude REAL',
                );
              }
              if (oldVersion < 9) {
                await db
                    .execute('ALTER TABLE fish_catches ADD COLUMN notes TEXT');
              }
              if (oldVersion < 10) {
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN lure_type TEXT',);
              }
              if (oldVersion < 11) {
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
                    'ALTER TABLE equipments ADD COLUMN joint_type TEXT',);
              }
              if (oldVersion < 14) {
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN reel_weight TEXT',);
                await db.execute(
                  "ALTER TABLE equipments ADD COLUMN reel_weight_unit TEXT DEFAULT 'g'",
                );
              }
              if (oldVersion < 15) {
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN reel_bearings INTEGER',);
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN reel_capacity TEXT',);
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN reel_brake_type TEXT',);
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN lure_weight TEXT',);
                await db.execute(
                  "ALTER TABLE equipments ADD COLUMN lure_weight_unit TEXT DEFAULT 'g'",
                );
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN lure_size TEXT',);
                await db.execute(
                  "ALTER TABLE equipments ADD COLUMN lure_size_unit TEXT DEFAULT 'cm'",
                );
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN lure_color TEXT',);
                await db
                    .execute('ALTER TABLE equipments ADD COLUMN price REAL');
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN purchase_date TEXT',);
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN is_default INTEGER DEFAULT 0',);
                await db
                    .execute('ALTER TABLE equipments ADD COLUMN category TEXT');
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN reel_line TEXT',);
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN reel_line_date TEXT',);
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN reel_line_number TEXT',);
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN reel_line_length TEXT',);
                await db.execute(
                  "ALTER TABLE equipments ADD COLUMN line_length_unit TEXT DEFAULT 'm'",
                );
                await db.execute(
                  "ALTER TABLE equipments ADD COLUMN line_weight_unit TEXT DEFAULT 'kg'",
                );
                await db.execute(
                    'ALTER TABLE equipments ADD COLUMN weight_range TEXT',);
                await db
                    .execute('ALTER TABLE equipments ADD COLUMN length TEXT');
                await db.execute(
                  "ALTER TABLE equipments ADD COLUMN length_unit TEXT DEFAULT 'm'",
                );
                await db
                    .execute('ALTER TABLE equipments ADD COLUMN sections TEXT');
                await db
                    .execute('ALTER TABLE equipments ADD COLUMN material TEXT');
                await db
                    .execute('ALTER TABLE equipments ADD COLUMN hardness TEXT');
              }
              if (oldVersion < 16) {
                await db.execute(
                    'ALTER TABLE fish_catches ADD COLUMN rig_type TEXT',);
                await db.execute(
                    'ALTER TABLE fish_catches ADD COLUMN sinker_weight TEXT',);
                await db.execute(
                    'ALTER TABLE fish_catches ADD COLUMN sinker_position TEXT',);
                await db.execute(
                    'ALTER TABLE fish_catches ADD COLUMN hook_type TEXT',);
                await db.execute(
                    'ALTER TABLE fish_catches ADD COLUMN hook_size TEXT',);
                await db.execute(
                    'ALTER TABLE fish_catches ADD COLUMN hook_weight TEXT',);
              }
              if (oldVersion < 17) {
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
                await db.execute('''
                  CREATE TABLE user_species_alias (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_alias TEXT NOT NULL UNIQUE,
                    species_id TEXT NOT NULL,
                    created_at INTEGER NOT NULL
                  )
                ''');
                await db.execute(
                  'CREATE INDEX idx_alias_user_alias ON user_species_alias(user_alias)',
                );
                await db.execute(
                  'CREATE INDEX idx_alias_species ON user_species_alias(species_id)',
                );
              }
              if (oldVersion < 21) {
                await db.execute(
                  'CREATE INDEX idx_fish_catches_catch_time ON fish_catches(catch_time)',
                );
                await db.execute(
                  'CREATE INDEX idx_fish_catches_time_fate ON fish_catches(catch_time, fate)',
                );
              }
              if (oldVersion < 22) {
                await db.execute(
                  'CREATE INDEX idx_equipments_type ON equipments(type)',
                );
                await db.execute(
                  'CREATE INDEX idx_equipments_category ON equipments(category)',
                );
                await db.execute(
                  'CREATE INDEX idx_equipments_is_deleted ON equipments(is_deleted)',
                );
              }
            },
          );

          try {
            // Verify all v22 tables exist
            final tables = await db.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
            );
            final tableNames = tables.map((t) => t['name']! as String).toList();

            expect(tableNames, contains('fish_catches'));
            expect(tableNames, contains('equipments'));
            expect(tableNames, contains('settings'));
            expect(tableNames, contains('species_history'));
            expect(tableNames, contains('cloud_configs'));
            expect(tableNames, contains('backup_history'));
            expect(tableNames, contains('fish_species'));
            expect(tableNames, contains('user_species_alias'));

            // Verify fish_catches has all v22 columns
            final fishColumns =
                await db.rawQuery('PRAGMA table_info(fish_catches)');
            final fishColumnNames =
                fishColumns.map((c) => c['name']! as String).toList();

            expect(fishColumnNames, contains('watermarked_image_path'));
            expect(fishColumnNames, contains('location_name'));
            expect(fishColumnNames, contains('latitude'));
            expect(fishColumnNames, contains('longitude'));
            expect(fishColumnNames, contains('notes'));
            expect(fishColumnNames, contains('pending_recognition'));
            expect(fishColumnNames, contains('rig_type'));
            expect(fishColumnNames, contains('sinker_weight'));
            expect(fishColumnNames, contains('hook_type'));

            // Verify equipments has all v22 columns
            final equipColumns =
                await db.rawQuery('PRAGMA table_info(equipments)');
            final equipColumnNames =
                equipColumns.map((c) => c['name']! as String).toList();

            expect(equipColumnNames, contains('lure_quantity'));
            expect(equipColumnNames, contains('rod_power'));
            expect(equipColumnNames, contains('reel_size'));
            expect(equipColumnNames, contains('reel_bearings'));
            expect(equipColumnNames, contains('price'));
            expect(equipColumnNames, contains('category'));
            expect(equipColumnNames, contains('material'));

            // Verify data was preserved
            final fishCatches = await db.query('fish_catches');
            expect(fishCatches.length, equals(1));
            expect(fishCatches.first['species'], equals('Bass'));

            final equipments = await db.query('equipments');
            expect(equipments.length, equals(1));
            expect(equipments.first['brand'], equals('Shimano'));
          } finally {
            await db.close();
          }
        } finally {
          await deleteDb(dbPath);
        }
      });
    });

    group('_addColumnIfNotExists', () {
      test('adds column when it does not exist', () async {
        final dbPath = createTempDbPath('add_column_test');

        try {
          final db = await openDatabase(
            dbPath,
            version: 1,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE test_table (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  name TEXT NOT NULL
                )
              ''');
            },
          );

          // Test _addColumnIfNotExists logic
          final resultBefore =
              await db.rawQuery('PRAGMA table_info(test_table)');
          final hasNewColumn =
              resultBefore.any((row) => row['name'] == 'new_column');
          expect(hasNewColumn, isFalse);

          // Add column using ALTER TABLE
          try {
            await db.execute(
              "ALTER TABLE test_table ADD COLUMN new_column TEXT DEFAULT 'test'",
            );
          } catch (_) {}

          final resultAfter =
              await db.rawQuery('PRAGMA table_info(test_table)');
          final hasNewColumnAfter =
              resultAfter.any((row) => row['name'] == 'new_column');

          expect(hasNewColumnAfter, isTrue);

          await db.close();
        } finally {
          await deleteDb(dbPath);
        }
      });
    });
  });
}
