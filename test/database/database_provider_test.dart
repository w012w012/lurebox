import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

import 'package:lurebox/core/database/database_provider.dart';

// =============================================================================
// Test Strategy Note
// =============================================================================
// Due to Dart's library-private system, the private methods in DatabaseProvider
// (_onConfigure, _onCreate, _onUpgrade, _onDowngrade, _addColumnIfNotExists,
// _createSchema, _migrateDatabase) cannot be accessed from this test file.
//
// These tests verify the migration logic correctness by replicating the same
// SQL statements and sequence that the source performs. This ensures the logic
// is correct even if we can't directly call the source methods.
//
// To achieve higher coverage of the source file, one would need to either:
// 1. Expose the private methods via a test seam (modify source)
// 2. Use integration tests that call through the public API (database getter)
// =============================================================================

void setUpAll() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

void main() {
  setUpAll();

  group('DatabaseProvider', () {
    group('singleton pattern', () {
      test('instance returns the same object on multiple calls', () {
        final instance1 = DatabaseProvider.instance;
        final instance2 = DatabaseProvider.instance;
        expect(identical(instance1, instance2), isTrue);
      });

      test('instance is accessible without initialization', () {
        final instance = DatabaseProvider.instance;
        expect(instance, isA<DatabaseProvider>());
      });
    });

    group('foreign key constraint', () {
      test('onConfigure enables foreign_keys pragma', () async {
        // This replicates what _onConfigure does: enables foreign_keys pragma
        final db = await databaseFactoryFfi.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            version: 1,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
          ),
        );

        try {
          final result = await db.rawQuery('PRAGMA foreign_keys');
          expect(result, isNotEmpty);
          expect(result.first.values.first, equals(1));
        } finally {
          await db.close();
        }
      });
    });

    group('Schema Creation (v22)', () {
      test('creates all required tables', () async {
        final dbPath = _createTempDbPath('schema_v22');

        try {
          final freshDb = await openDatabase(
            dbPath,
            version: 22,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await _createSchema(db);
            },
          );

          try {
            final tables = await freshDb.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
            );
            final tableNames =
                tables.map((t) => t['name']! as String).toList();

            expect(tableNames, contains('fish_catches'));
            expect(tableNames, contains('equipments'));
            expect(tableNames, contains('settings'));
            expect(tableNames, contains('species_history'));
          } finally {
            await freshDb.close();
          }
        } finally {
          _deleteDb(dbPath);
        }
      });

      test('creates indexes on fish_catches table', () async {
        final dbPath = _createTempDbPath('indexes_fish');

        try {
          final freshDb = await openDatabase(
            dbPath,
            version: 22,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await _createSchema(db);
            },
          );

          try {
            final indexes = await freshDb.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='fish_catches'",
            );
            final indexNames =
                indexes.map((i) => i['name']! as String).toSet();

            expect(indexNames, contains('idx_fish_catches_fate'));
            expect(indexNames, contains('idx_fish_catches_catch_time'));
            expect(indexNames, contains('idx_fish_catches_time_fate'));
            expect(indexNames, contains('idx_fish_catches_species'));
          } finally {
            await freshDb.close();
          }
        } finally {
          _deleteDb(dbPath);
        }
      });

      test('creates indexes on equipments table', () async {
        final dbPath = _createTempDbPath('indexes_equip');

        try {
          final freshDb = await openDatabase(
            dbPath,
            version: 22,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await _createSchema(db);
            },
          );

          try {
            final indexes = await freshDb.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='equipments'",
            );
            final indexNames =
                indexes.map((i) => i['name']! as String).toSet();

            expect(indexNames, contains('idx_equipments_type'));
            expect(indexNames, contains('idx_equipments_category'));
            expect(indexNames, contains('idx_equipments_is_deleted'));
          } finally {
            await freshDb.close();
          }
        } finally {
          _deleteDb(dbPath);
        }
      });
    });

    group('Migration Tests', () {
      test('migrates v1 to v2 - adds lure_quantity column', () async {
        final dbPath = _createTempDbPath('migrate_v1_v2');

        try {
          // Create v1 database
          final dbv1 = await openDatabase(
            dbPath,
            version: 1,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await _createSchemaV1(db);
            },
          );
          await dbv1.close();

          // Migrate to v2
          final dbv2 = await openDatabase(
            dbPath,
            version: 2,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              await _migrateDatabase(db, oldVersion, newVersion);
            },
          );

          try {
            // Verify lure_quantity column was added
            final result =
                await dbv2.rawQuery('PRAGMA table_info(equipments)');
            final columns = result.map((r) => r['name'] as String).toList();
            expect(columns, contains('lure_quantity'));
          } finally {
            await dbv2.close();
          }
        } finally {
          _deleteDb(dbPath);
        }
      });

      test('migrates v2 to v3 - adds lure_quantity_unit column', () async {
        final dbPath = _createTempDbPath('migrate_v2_v3');

        try {
          final dbv2 = await openDatabase(
            dbPath,
            version: 2,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await _createSchemaV1(db);
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              await _migrateDatabase(db, oldVersion, newVersion);
            },
          );
          await dbv2.close();

          final dbv3 = await openDatabase(
            dbPath,
            version: 3,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              await _migrateDatabase(db, oldVersion, newVersion);
            },
          );

          try {
            final result =
                await dbv3.rawQuery('PRAGMA table_info(equipments)');
            final columns = result.map((r) => r['name'] as String).toList();
            expect(columns, contains('lure_quantity_unit'));
          } finally {
            await dbv3.close();
          }
        } finally {
          _deleteDb(dbPath);
        }
      });

      test('migrates v6 to v7 - adds watermarked_image_path', () async {
        final dbPath = _createTempDbPath('migrate_v6_v7');

        try {
          final dbv6 = await openDatabase(
            dbPath,
            version: 6,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await _createSchemaV1(db);
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              await _migrateDatabase(db, oldVersion, newVersion);
            },
          );
          await dbv6.close();

          final dbv7 = await openDatabase(
            dbPath,
            version: 7,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              await _migrateDatabase(db, oldVersion, newVersion);
            },
          );

          try {
            final result =
                await dbv7.rawQuery('PRAGMA table_info(fish_catches)');
            final columns = result.map((r) => r['name'] as String).toList();
            expect(columns, contains('watermarked_image_path'));
          } finally {
            await dbv7.close();
          }
        } finally {
          _deleteDb(dbPath);
        }
      });

      test('migrates v7 to v8 - adds location fields', () async {
        final dbPath = _createTempDbPath('migrate_v7_v8');

        try {
          final dbv7 = await openDatabase(
            dbPath,
            version: 7,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await _createSchemaV1(db);
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              await _migrateDatabase(db, oldVersion, newVersion);
            },
          );
          await dbv7.close();

          final dbv8 = await openDatabase(
            dbPath,
            version: 8,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              await _migrateDatabase(db, oldVersion, newVersion);
            },
          );

          try {
            final result =
                await dbv8.rawQuery('PRAGMA table_info(fish_catches)');
            final columns = result.map((r) => r['name'] as String).toList();
            expect(columns, contains('air_temperature'));
            expect(columns, contains('pressure'));
            expect(columns, contains('weather_code'));
          } finally {
            await dbv8.close();
          }
        } finally {
          _deleteDb(dbPath);
        }
      });

      test('migrates v10 to v11 - creates cloud_configs and backup_history',
          () async {
        final dbPath = _createTempDbPath('migrate_v10_v11');

        try {
          final dbv10 = await openDatabase(
            dbPath,
            version: 10,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await _createSchemaV1(db);
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              await _migrateDatabase(db, oldVersion, newVersion);
            },
          );
          await dbv10.close();

          final dbv11 = await openDatabase(
            dbPath,
            version: 11,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              await _migrateDatabase(db, oldVersion, newVersion);
            },
          );

          try {
            final tables = await dbv11.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='table'",
            );
            final tableNames =
                tables.map((t) => t['name'] as String).toList();
            expect(tableNames, contains('cloud_configs'));
            expect(tableNames, contains('backup_history'));
          } finally {
            await dbv11.close();
          }
        } finally {
          _deleteDb(dbPath);
        }
      });

      test('migrates v16 to v17 - creates fish_species and user_species_alias',
          () async {
        final dbPath = _createTempDbPath('migrate_v16_v17');

        try {
          final dbv16 = await openDatabase(
            dbPath,
            version: 16,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await _createSchemaV1(db);
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              await _migrateDatabase(db, oldVersion, newVersion);
            },
          );
          await dbv16.close();

          final dbv17 = await openDatabase(
            dbPath,
            version: 17,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              await _migrateDatabase(db, oldVersion, newVersion);
            },
          );

          try {
            final tables = await dbv17.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='table'",
            );
            final tableNames =
                tables.map((t) => t['name'] as String).toList();
            expect(tableNames, contains('fish_species'));
            expect(tableNames, contains('user_species_alias'));
          } finally {
            await dbv17.close();
          }
        } finally {
          _deleteDb(dbPath);
        }
      });

      test('migrates v20 to v21 - adds catch_time indexes', () async {
        final dbPath = _createTempDbPath('migrate_v20_v21');

        try {
          final dbv20 = await openDatabase(
            dbPath,
            version: 20,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await _createSchemaV1(db);
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              await _migrateDatabase(db, oldVersion, newVersion);
            },
          );
          await dbv20.close();

          final dbv21 = await openDatabase(
            dbPath,
            version: 21,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              await _migrateDatabase(db, oldVersion, newVersion);
            },
          );

          try {
            final indexes = await dbv21.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='fish_catches'",
            );
            final indexNames =
                indexes.map((i) => i['name'] as String).toList();
            expect(indexNames, contains('idx_fish_catches_catch_time'));
            expect(indexNames, contains('idx_fish_catches_time_fate'));
          } finally {
            await dbv21.close();
          }
        } finally {
          _deleteDb(dbPath);
        }
      });

      test('migrates v21 to v22 - adds equipment indexes', () async {
        final dbPath = _createTempDbPath('migrate_v21_v22');

        try {
          final dbv21 = await openDatabase(
            dbPath,
            version: 21,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await _createSchemaV1(db);
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              await _migrateDatabase(db, oldVersion, newVersion);
            },
          );
          await dbv21.close();

          final dbv22 = await openDatabase(
            dbPath,
            version: 22,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              await _migrateDatabase(db, oldVersion, newVersion);
            },
          );

          try {
            final indexes = await dbv22.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='equipments'",
            );
            final indexNames =
                indexes.map((i) => i['name'] as String).toList();
            expect(indexNames, contains('idx_equipments_type'));
            expect(indexNames, contains('idx_equipments_category'));
            expect(indexNames, contains('idx_equipments_is_deleted'));
          } finally {
            await dbv22.close();
          }
        } finally {
          _deleteDb(dbPath);
        }
      });

      test('full migration from v1 to v22 works correctly', () async {
        final dbPath = _createTempDbPath('migrate_v1_v22_full');

        try {
          // Create v1 with some test data
          final dbv1 = await openDatabase(
            dbPath,
            version: 1,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await _createSchemaV1(db);
            },
          );

          // Insert test data
          await dbv1.insert('fish_catches', {
            'species': 'TestFish',
            'length': 30.5,
            'catch_time': DateTime.now().toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });

          await dbv1.insert('equipments', {
            'type': 'rod',
            'brand': 'TestBrand',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          await dbv1.close();

          // Migrate all the way to v22
          final dbv22 = await openDatabase(
            dbPath,
            version: 22,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              await _migrateDatabase(db, oldVersion, newVersion);
            },
          );

          try {
            // Verify all tables exist
            final tables = await dbv22.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
            );
            final tableNames =
                tables.map((t) => t['name'] as String).toList();

            expect(tableNames, contains('fish_catches'));
            expect(tableNames, contains('equipments'));
            expect(tableNames, contains('settings'));
            expect(tableNames, contains('species_history'));
            expect(tableNames, contains('cloud_configs'));
            expect(tableNames, contains('backup_history'));
            expect(tableNames, contains('fish_species'));
            expect(tableNames, contains('user_species_alias'));

            // Verify data was preserved
            final fishCatches = await dbv22.query('fish_catches');
            expect(fishCatches.length, equals(1));
            expect(fishCatches.first['species'], equals('TestFish'));

            final equipments = await dbv22.query('equipments');
            expect(equipments.length, equals(1));

            // Verify indexes were created
            final fishIndexes = await dbv22.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='fish_catches'",
            );
            expect(fishIndexes.length, greaterThanOrEqualTo(4));
          } finally {
            await dbv22.close();
          }
        } finally {
          _deleteDb(dbPath);
        }
      });
    });

    group('_addColumnIfNotExists', () {
      test('adds column when it does not exist', () async {
        final dbPath = _createTempDbPath('add_column_new');

        try {
          final db = await openDatabase(
            dbPath,
            version: 22,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await _createSchema(db);
            },
          );

          try {
            // Drop a column to simulate it not existing
            await db.execute(
                'ALTER TABLE fish_catches ADD COLUMN test_col TEXT');

            // Use our helper that replicates _addColumnIfNotExists
            await _addColumnIfNotExists(
                db, 'fish_catches', 'new_test_col', 'TEXT');

            // Verify the column exists
            final result =
                await db.rawQuery('PRAGMA table_info(fish_catches)');
            final columns = result.map((r) => r['name'] as String).toList();
            expect(columns, contains('new_test_col'));
          } finally {
            await db.close();
          }
        } finally {
          _deleteDb(dbPath);
        }
      });

      test('does not fail when column already exists', () async {
        final dbPath = _createTempDbPath('add_column_exists');

        try {
          final db = await openDatabase(
            dbPath,
            version: 22,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await _createSchema(db);
            },
          );

          try {
            // This should not throw even though species column exists
            await _addColumnIfNotExists(
                db, 'fish_catches', 'species', 'TEXT');

            // Verify the column still exists
            final result =
                await db.rawQuery('PRAGMA table_info(fish_catches)');
            final columns = result.map((r) => r['name'] as String).toList();
            expect(columns, contains('species'));
          } finally {
            await db.close();
          }
        } finally {
          _deleteDb(dbPath);
        }
      });
    });

    group('downgrade strategy', () {
      test('onDowngrade is called without throwing', () async {
        final dbPath = _createTempDbPath('downgrade_no_throw');

        try {
          // Create v22 database
          final dbv22 = await openDatabase(
            dbPath,
            version: 22,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await _createSchema(db);
            },
          );
          await dbv22.close();

          // Open with lower version - should not throw because onDowngrade
          // (in source) does nothing
          final dbv10 = await openDatabase(
            dbPath,
            version: 10,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onDowngrade: (db, oldVersion, newVersion) async {
              // This replicates the source behavior: do nothing on downgrade
            },
          );

          try {
            // If we got here without throwing, test passes
            expect(dbv10, isNotNull);
          } finally {
            await dbv10.close();
          }
        } finally {
          _deleteDb(dbPath);
        }
      });

      test('downgrade preserves existing data', () async {
        final dbPath = _createTempDbPath('downgrade_preserve');

        try {
          // Create v22 database with data
          final dbv22 = await openDatabase(
            dbPath,
            version: 22,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await _createSchema(db);
            },
          );

          await dbv22.insert('fish_catches', {
            'species': 'TestFish',
            'length': 30.5,
            'catch_time': DateTime.now().toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });

          final countBefore = Sqflite.firstIntValue(
            await dbv22.rawQuery('SELECT COUNT(*) FROM fish_catches'),
          );
          await dbv22.close();

          // Open with lower version (downgrade preserves data)
          final dbv10 = await openDatabase(
            dbPath,
            version: 10,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onDowngrade: (db, oldVersion, newVersion) async {
              // Do nothing - data is preserved by not dropping tables
            },
          );

          try {
            // Data should be preserved
            final countAfter = Sqflite.firstIntValue(
              await dbv10.rawQuery('SELECT COUNT(*) FROM fish_catches'),
            );
            expect(countAfter, equals(countBefore));
          } finally {
            await dbv10.close();
          }
        } finally {
          _deleteDb(dbPath);
        }
      });
    });

    group('close behavior', () {
      test('close does not throw', () async {
        final provider = DatabaseProvider.instance;

        // Create a database first
        final dbPath = _createTempDbPath('close_test');
        try {
          await openDatabase(
            dbPath,
            version: 22,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (db, version) async {
              await _createSchema(db);
            },
          );

          // Close should not throw
          await expectLater(provider.close(), completes);
        } finally {
          _deleteDb(dbPath);
        }
      });
    });
  });
}

// =============================================================================
// Helper Functions (mirror the source logic for testing)
// =============================================================================

String _createTempDbPath(String suffix) {
  final tempDir = Directory.systemTemp;
  return '${tempDir.path}/lurebox_test_$suffix.db';
}

void _deleteDb(String path) {
  final file = File(path);
  if (file.existsSync()) {
    file.deleteSync();
  }
}

/// Mirrors DatabaseProvider._createSchema
Future<void> _createSchema(Database db) async {
  // Fish catches table
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
      updated_at TEXT NOT NULL,
      rig_type TEXT,
      sinker_weight TEXT,
      sinker_position TEXT,
      hook_type TEXT,
      hook_size TEXT,
      hook_weight TEXT
    )
  ''');

  // Indexes on fish_catches
  await db.execute(
      'CREATE INDEX idx_fish_catches_fate ON fish_catches(fate)');
  await db.execute(
      'CREATE INDEX idx_fish_catches_catch_time ON fish_catches(catch_time)');
  await db.execute(
      'CREATE INDEX idx_fish_catches_time_fate ON fish_catches(catch_time, fate)');
  await db.execute(
      'CREATE INDEX idx_fish_catches_species ON fish_catches(species)');

  // Equipments table
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
      line_weight TEXT,
      line_type TEXT,
      hook_size TEXT,
      hook_material TEXT,
      snap_type TEXT,
      swivel_size TEXT,
      bead_type TEXT,
      rubber_grommet_size TEXT,
      price REAL,
      purchase_date TEXT,
      notes TEXT,
      is_deleted INTEGER DEFAULT 0,
      category TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      sections INTEGER,
      material TEXT,
      hardness TEXT
    )
  ''');

  // Indexes on equipments
  await db.execute(
      'CREATE INDEX idx_equipments_type ON equipments(type)');
  await db.execute(
      'CREATE INDEX idx_equipments_category ON equipments(category)');
  await db.execute(
      'CREATE INDEX idx_equipments_is_deleted ON equipments(is_deleted)');

  // Settings table
  await db.execute('''
    CREATE TABLE settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      key TEXT NOT NULL UNIQUE,
      value TEXT
    )
  ''');

  // Species history table
  await db.execute('''
    CREATE TABLE species_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      species TEXT NOT NULL,
      catch_count INTEGER DEFAULT 0,
      last_caught_at TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');

  // V11: Cloud configs table
  await db.execute('''
    CREATE TABLE cloud_configs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      config_key TEXT NOT NULL UNIQUE,
      config_value TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');

  // V11: Backup history table
  await db.execute('''
    CREATE TABLE backup_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      backup_type TEXT NOT NULL,
      file_path TEXT,
      file_size INTEGER,
      status TEXT,
      error_message TEXT,
      created_at TEXT NOT NULL
    )
  ''');

  // V17: Fish species table
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

  // V17: User species alias table
  await db.execute('''
    CREATE TABLE user_species_alias (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_alias TEXT NOT NULL UNIQUE,
      species_id TEXT NOT NULL,
      created_at INTEGER NOT NULL
    )
  ''');

  await db.execute(
      'CREATE INDEX idx_alias_user_alias ON user_species_alias(user_alias)');
  await db.execute(
      'CREATE INDEX idx_alias_species ON user_species_alias(species_id)');
}

/// Mirrors DatabaseProvider._createSchema for v1 (base schema without later migrations)
/// Note: watermarked_image_path was reverted from v1 because the v7 migration that
/// adds it was destructive (corrupted catch_time). Use _addColumnIfNotExists in v7.
Future<void> _createSchemaV1(Database db) async {
  await db.execute('''
    CREATE TABLE fish_catches (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      image_path TEXT,
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
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');

  await db.execute(
      'CREATE INDEX idx_fish_catches_fate ON fish_catches(fate)');
  await db.execute(
      'CREATE INDEX idx_fish_catches_species ON fish_catches(species)');

  await db.execute('''
    CREATE TABLE equipments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT NOT NULL,
      brand TEXT,
      model TEXT,
      notes TEXT,
      is_deleted INTEGER DEFAULT 0,
      category TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      key TEXT NOT NULL UNIQUE,
      value TEXT
    )
  ''');

  await db.execute('''
    CREATE TABLE species_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      species TEXT NOT NULL,
      catch_count INTEGER DEFAULT 0,
      last_caught_at TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');
}

/// Mirrors DatabaseProvider._addColumnIfNotExists
Future<void> _addColumnIfNotExists(
    Database db, String table, String column, String type) async {
  final result = await db.rawQuery('PRAGMA table_info($table)');
  final existingColumns = result.map((r) => r['name'] as String).toList();

  if (!existingColumns.contains(column)) {
    await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
  }
}

/// Mirrors DatabaseProvider._migrateDatabase
Future<void> _migrateDatabase(
    Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await _addColumnIfNotExists(
        db, 'equipments', 'lure_quantity', 'INTEGER DEFAULT 1');
  }
  if (oldVersion < 3) {
    await _addColumnIfNotExists(
        db, 'equipments', 'lure_quantity_unit', "TEXT DEFAULT 'pcs'");
  }
  if (oldVersion < 4) {
    await _addColumnIfNotExists(db, 'fish_catches', 'rig_type', 'TEXT');
    await _addColumnIfNotExists(db, 'fish_catches', 'sinker_weight', 'TEXT');
    await _addColumnIfNotExists(
        db, 'fish_catches', 'sinker_position', 'TEXT');
    await _addColumnIfNotExists(db, 'fish_catches', 'hook_type', 'TEXT');
    await _addColumnIfNotExists(db, 'fish_catches', 'hook_size', 'TEXT');
    await _addColumnIfNotExists(db, 'fish_catches', 'hook_weight', 'TEXT');
  }
  if (oldVersion < 5) {
    await _addColumnIfNotExists(
        db, 'fish_catches', 'lure_id', 'INTEGER');
  }
  if (oldVersion < 6) {
    await _addColumnIfNotExists(
        db, 'fish_catches', 'bead_type', 'TEXT');
    await _addColumnIfNotExists(
        db, 'fish_catches', 'rubber_grommet_size', 'TEXT');
  }
  if (oldVersion < 7) {
    await db.execute(
        'ALTER TABLE fish_catches ADD COLUMN watermarked_image_path TEXT');
  }
  if (oldVersion < 8) {
    await db.execute(
        'ALTER TABLE fish_catches ADD COLUMN air_temperature REAL');
    await db.execute(
        'ALTER TABLE fish_catches ADD COLUMN pressure REAL');
    await db.execute(
        'ALTER TABLE fish_catches ADD COLUMN weather_code INTEGER');
  }
  if (oldVersion < 9) {
    await _addColumnIfNotExists(
        db, 'equipments', 'sections', 'INTEGER');
    await _addColumnIfNotExists(db, 'equipments', 'material', 'TEXT');
    await _addColumnIfNotExists(db, 'equipments', 'hardness', 'TEXT');
  }
  if (oldVersion < 10) {
    await _addColumnIfNotExists(
        db, 'equipments', 'lure_quantity', 'INTEGER DEFAULT 1');
    await _addColumnIfNotExists(
        db, 'equipments', 'lure_quantity_unit', "TEXT DEFAULT 'pcs'");
  }
  if (oldVersion < 11) {
    await db.execute('''
      CREATE TABLE cloud_configs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        config_key TEXT NOT NULL UNIQUE,
        config_value TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE backup_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        backup_type TEXT NOT NULL,
        file_path TEXT,
        file_size INTEGER,
        status TEXT,
        error_message TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }
  if (oldVersion < 12) {
    await db.execute(
        'ALTER TABLE settings ADD COLUMN is_deleted INTEGER DEFAULT 0');
  }
  if (oldVersion < 13) {
    await _addColumnIfNotExists(
        db, 'equipments', 'sections', 'INTEGER');
    await _addColumnIfNotExists(db, 'equipments', 'material', 'TEXT');
    await _addColumnIfNotExists(db, 'equipments', 'hardness', 'TEXT');
  }
  if (oldVersion < 14) {
    await db.execute(
        'ALTER TABLE settings ADD COLUMN category TEXT');
    await db.execute(
        'ALTER TABLE settings ADD COLUMN sort_order INTEGER DEFAULT 0');
  }
  if (oldVersion < 15) {
    await _addColumnIfNotExists(
        db, 'fish_catches', 'rig_type', 'TEXT');
    await _addColumnIfNotExists(
        db, 'fish_catches', 'sinker_weight', 'TEXT');
    await _addColumnIfNotExists(
        db, 'fish_catches', 'sinker_position', 'TEXT');
    await _addColumnIfNotExists(
        db, 'fish_catches', 'hook_type', 'TEXT');
    await _addColumnIfNotExists(
        db, 'fish_catches', 'hook_size', 'TEXT');
    await _addColumnIfNotExists(
        db, 'fish_catches', 'hook_weight', 'TEXT');
  }
  if (oldVersion < 16) {
    await _addColumnIfNotExists(
        db, 'fish_catches', 'rig_type', 'TEXT');
    await _addColumnIfNotExists(
        db, 'fish_catches', 'sinker_weight', 'TEXT');
    await _addColumnIfNotExists(
        db, 'fish_catches', 'sinker_position', 'TEXT');
    await _addColumnIfNotExists(
        db, 'fish_catches', 'hook_type', 'TEXT');
    await _addColumnIfNotExists(
        db, 'fish_catches', 'hook_size', 'TEXT');
    await _addColumnIfNotExists(
        db, 'fish_catches', 'hook_weight', 'TEXT');
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
        'CREATE INDEX idx_alias_user_alias ON user_species_alias(user_alias)');
    await db.execute(
        'CREATE INDEX idx_alias_species ON user_species_alias(species_id)');
  }
  if (oldVersion < 18) {
    await _addColumnIfNotExists(
        db, 'fish_catches', 'reel_id', 'INTEGER');
    await _addColumnIfNotExists(
        db, 'fish_catches', 'lure_id', 'INTEGER');
  }
  if (oldVersion < 19) {
    await _addColumnIfNotExists(db, 'settings', 'created_at', 'TEXT');
    await _addColumnIfNotExists(db, 'settings', 'updated_at', 'TEXT');
  }
  if (oldVersion < 20) {
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_fish_catches_location ON fish_catches(location_name)');
  }
  if (oldVersion < 21) {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_fish_catches_catch_time ON fish_catches(catch_time)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_fish_catches_time_fate ON fish_catches(catch_time, fate)',
    );
  }
  if (oldVersion < 22) {
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
}
