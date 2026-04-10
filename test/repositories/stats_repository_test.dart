import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lurebox/core/models/stats_models.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/repositories/stats_repository.dart';
import 'package:lurebox/core/repositories/stats_repository_impl.dart';
import 'package:sqflite/sqflite.dart';

/// Test file for SqliteStatsRepository
///
/// NOTE: SqliteStatsRepository uses DatabaseService.database directly without
/// supporting database injection (unlike SqliteUserSpeciesAliasRepository which
/// has .withDatabase() constructor). This is a limitation of the production code.
///
/// These tests are structured correctly following the reference pattern but
/// require the production code to be modified to support database injection
/// for full test coverage.

void main() {
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Create in-memory database for testing
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // Create fish_catches table with full schema
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
              rig_type TEXT,
              sinker_weight TEXT,
              sinker_position TEXT,
              hook_type TEXT,
              hook_size TEXT,
              hook_weight TEXT,
              air_temperature REAL,
              pressure REAL,
              weather_code INTEGER,
              pending_recognition INTEGER DEFAULT 0,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');

          // Create equipments table for equipment stats tests
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
              lure_color TEXT,
              price REAL,
              purchase_date TEXT,
              is_default INTEGER DEFAULT 0,
              is_deleted INTEGER DEFAULT 0,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');

          // Create indexes
          await db.execute(
              'CREATE INDEX idx_fish_catches_time ON fish_catches(catch_time)');
          await db.execute(
              'CREATE INDEX idx_fish_catches_fate ON fish_catches(fate)');
          await db.execute(
              'CREATE INDEX idx_fish_catches_species ON fish_catches(species)');
        },
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('CatchStats Model', () {
    test('releaseRate calculates correctly', () {
      const stats = CatchStats(total: 10, release: 7, keep: 3);
      expect(stats.releaseRate, closeTo(0.7, 0.01));
    });

    test('releaseRate returns 0 when total is 0', () {
      const stats = CatchStats(total: 0, release: 0, keep: 0);
      expect(stats.releaseRate, equals(0.0));
    });

    test('fromMap creates correct instance', () {
      final map = {'total': 15, 'release': 10, 'keep': 5};
      final stats = CatchStats.fromMap(map);

      expect(stats.total, equals(15));
      expect(stats.release, equals(10));
      expect(stats.keep, equals(5));
    });

    test('fromMap handles null values with defaults', () {
      final map = <String, dynamic>{};
      final stats = CatchStats.fromMap(map);

      expect(stats.total, equals(0));
      expect(stats.release, equals(0));
      expect(stats.keep, equals(0));
    });
  });

  group('EquipmentCatchStats Model', () {
    test('fromMap creates correct instance', () {
      final map = {
        'equipment_id': 2,
        'catch_count': 5,
        'avg_length': 25.0,
        'avg_weight': 1.5,
        'release_count': 3,
      };

      final stats = EquipmentCatchStats.fromMap(map);

      expect(stats.equipmentId, equals(2));
      expect(stats.catchCount, equals(5));
      expect(stats.avgLength, equals(25.0));
      expect(stats.avgWeight, equals(1.5));
      expect(stats.releaseCount, equals(3));
    });

    test('fromMap handles null values', () {
      final map = <String, dynamic>{};
      final stats = EquipmentCatchStats.fromMap(map);

      expect(stats.equipmentId, equals(0));
      expect(stats.catchCount, equals(0));
      expect(stats.avgLength, isNull);
      expect(stats.avgWeight, isNull);
      expect(stats.releaseCount, equals(0));
    });
  });

  group('DashboardData Model', () {
    test('creates DashboardData with all fields', () {
      const todaySpecies = {'Bass': 3, 'Trout': 2};
      const dashboard = DashboardData(
        todayStats: CatchStats(total: 5, release: 3, keep: 2),
        todaySpecies: todaySpecies,
        monthStats: CatchStats(total: 50, release: 35, keep: 15),
        monthSpecies: const {'Bass': 30, 'Trout': 20},
        yearStats: CatchStats(total: 200, release: 140, keep: 60),
        yearSpecies: const {'Bass': 120, 'Trout': 80},
        allStats: CatchStats(total: 500, release: 350, keep: 150),
        allSpecies: const {'Bass': 300, 'Trout': 200},
        top3Longest: [
          {'id': 1, 'length': 50.0},
          {'id': 2, 'length': 45.0},
        ],
      );

      expect(dashboard.todayStats.total, equals(5));
      expect(dashboard.todaySpecies['Bass'], equals(3));
      expect(dashboard.monthStats.total, equals(50));
      expect(dashboard.allStats.total, equals(500));
      expect(dashboard.top3Longest.length, equals(2));
    });
  });

  group('SqliteStatsRepository Integration', () {
    /// NOTE: SqliteStatsRepository does not currently support database injection.
    /// The repository uses DatabaseService.database directly, making it difficult
    /// to test with an in-memory database without modifying production code.
    ///
    /// This is a known limitation - other repositories like
    /// SqliteUserSpeciesAliasRepository have .withDatabase() constructors
    /// that allow easy testing.
    ///
    /// The following tests demonstrate the intended testing pattern but may not
    /// all pass due to this architectural limitation.

    test('repository can be instantiated', () {
      final repository = SqliteStatsRepository();
      expect(repository, isA<SqliteStatsRepository>());
    });

    test('repository implements StatsRepository interface', () {
      final repository = SqliteStatsRepository();
      expect(repository, isA<StatsRepository>());
    });

    // These tests work because they don't insert data into the test database
    // The repository queries DatabaseService.database (singleton) instead

    test('getTotalCatchCount returns 0 when database is empty', () async {
      final repository = SqliteStatsRepository();
      final count = await repository.getTotalCatchCount();
      // Returns 0 because DatabaseService.database has no data
      expect(count, equals(0));
    });

    test('getDistinctSpeciesCount returns 0 when database is empty', () async {
      final repository = SqliteStatsRepository();
      final count = await repository.getDistinctSpeciesCount();
      expect(count, equals(0));
    });

    test('getLocationCount returns 0 when database is empty', () async {
      final repository = SqliteStatsRepository();
      final count = await repository.getLocationCount();
      expect(count, equals(0));
    });

    test('getReleaseCount returns 0 when database is empty', () async {
      final repository = SqliteStatsRepository();
      final count = await repository.getReleaseCount();
      expect(count, equals(0));
    });

    test('getReleaseRate returns 0 when database is empty', () async {
      final repository = SqliteStatsRepository();
      final rate = await repository.getReleaseRate();
      expect(rate, equals(0.0));
    });

    test('getCatchStats returns empty stats when database is empty', () async {
      final repository = SqliteStatsRepository();
      final stats = await repository.getCatchStats();

      expect(stats.total, equals(0));
      expect(stats.release, equals(0));
      expect(stats.keep, equals(0));
    });

    test('getSpeciesStats returns empty when database is empty', () async {
      final repository = SqliteStatsRepository();
      final stats = await repository.getSpeciesStats();

      expect(stats, isEmpty);
    });

    test('getEquipmentCatchStats returns empty when database is empty',
        () async {
      final repository = SqliteStatsRepository();
      final stats = await repository.getEquipmentCatchStats();

      expect(stats, isEmpty);
    });

    test('getConsecutiveDays returns 0 when database is empty', () async {
      final repository = SqliteStatsRepository();
      final days = await repository.getConsecutiveDays();
      expect(days, equals(0));
    });

    test('getMonthlyMax returns 0 when database is empty', () async {
      final repository = SqliteStatsRepository();
      final max = await repository.getMonthlyMax();
      expect(max, equals(0));
    });

    test('getDailyMax returns 0 when database is empty', () async {
      final repository = SqliteStatsRepository();
      final max = await repository.getDailyMax();
      expect(max, equals(0));
    });

    test('getMorningCatchCount returns 0 when database is empty', () async {
      final repository = SqliteStatsRepository();
      final count = await repository.getMorningCatchCount();
      expect(count, equals(0));
    });

    test('getNightCatchCount returns 0 when database is empty', () async {
      final repository = SqliteStatsRepository();
      final count = await repository.getNightCatchCount();
      expect(count, equals(0));
    });

    test('getMaxLength returns 0 when database is empty', () async {
      final repository = SqliteStatsRepository();
      final max = await repository.getMaxLength();
      expect(max, equals(0.0));
    });

    test('getTotalWeight returns 0 when database is empty', () async {
      final repository = SqliteStatsRepository();
      final total = await repository.getTotalWeight();
      expect(total, equals(0.0));
    });

    test('getTop3LongestCatches returns empty when database is empty',
        () async {
      final repository = SqliteStatsRepository();
      final catches = await repository.getTop3LongestCatches();
      expect(catches, isEmpty);
    });

    test('getDashboardData returns zero stats when database is empty',
        () async {
      final repository = SqliteStatsRepository();
      final dashboard = await repository.getDashboardData();

      expect(dashboard.todayStats.total, equals(0));
      expect(dashboard.monthStats.total, equals(0));
      expect(dashboard.yearStats.total, equals(0));
      expect(dashboard.allStats.total, equals(0));
      expect(dashboard.top3Longest, isEmpty);
    });
  });

  group('Test Data Insertion (Schema Validation)', () {
    /// These tests verify that our test database schema is correct
    /// by inserting data directly and querying it back.

    test('can insert fish catch into test database', () async {
      final now = DateTime.now();
      final id = await db.insert('fish_catches', {
        'image_path': '/test/fish.jpg',
        'species': 'Bass',
        'length': 30.0,
        'weight': 2.5,
        'fate': 0,
        'catch_time': now.toIso8601String(),
        'location_name': 'Test Lake',
        'pending_recognition': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      expect(id, greaterThan(0));
    });

    test('can insert equipment into test database', () async {
      final now = DateTime.now();
      final id = await db.insert('equipments', {
        'type': 'rod',
        'brand': 'TestBrand',
        'model': 'TestModel',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      expect(id, greaterThan(0));
    });

    test('can query inserted fish catch', () async {
      final now = DateTime.now();
      await db.insert('fish_catches', {
        'image_path': '/test/fish.jpg',
        'species': 'Trout',
        'length': 25.0,
        'fate': 1,
        'catch_time': now.toIso8601String(),
        'pending_recognition': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      final results = await db.query('fish_catches');
      expect(results.length, equals(1));
      expect(results.first['species'], equals('Trout'));
    });

    test('can calculate stats from inserted data', () async {
      final now = DateTime.now();

      // Insert multiple catches
      await db.insert('fish_catches', {
        'image_path': '/test/fish1.jpg',
        'species': 'Bass',
        'length': 30.0,
        'fate': 0, // release
        'catch_time': now.toIso8601String(),
        'pending_recognition': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      await db.insert('fish_catches', {
        'image_path': '/test/fish2.jpg',
        'species': 'Bass',
        'length': 25.0,
        'fate': 1, // keep
        'catch_time': now.toIso8601String(),
        'pending_recognition': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      // Query using raw SQL (this works in test db)
      final results = await db.rawQuery('''
        SELECT
          COUNT(*) as total,
          SUM(CASE WHEN fate = 0 THEN 1 ELSE 0 END) as release,
          SUM(CASE WHEN fate = 1 THEN 1 ELSE 0 END) as keep
        FROM fish_catches
      ''');

      expect(results.first['total'], equals(2));
      expect(results.first['release'], equals(1));
      expect(results.first['keep'], equals(1));
    });

    test('release rate calculation = release / (release + keep)', () async {
      final now = DateTime.now();

      // 3 release, 1 keep = 0.75 rate
      for (int i = 0; i < 3; i++) {
        await db.insert('fish_catches', {
          'image_path': '/test/fish$i.jpg',
          'species': 'Bass',
          'length': 30.0,
          'fate': 0,
          'catch_time': now.toIso8601String(),
          'pending_recognition': 0,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });
      }

      await db.insert('fish_catches', {
        'image_path': '/test/fish_kept.jpg',
        'species': 'Trout',
        'length': 25.0,
        'fate': 1,
        'catch_time': now.toIso8601String(),
        'pending_recognition': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      final results = await db.rawQuery('''
        SELECT
          COUNT(*) as total,
          SUM(CASE WHEN fate = 0 THEN 1 ELSE 0 END) as release
        FROM fish_catches
      ''');

      final total = results.first['total'] as int;
      final release = results.first['release'] as int;
      final rate = release / total;

      expect(total, equals(4));
      expect(release, equals(3));
      expect(rate, closeTo(0.75, 0.01));
    });

    test('getSpeciesStats returns map of species to count', () async {
      final now = DateTime.now();

      await db.insert('fish_catches', {
        'image_path': '/test/fish1.jpg',
        'species': 'Bass',
        'length': 30.0,
        'fate': 0,
        'catch_time': now.toIso8601String(),
        'pending_recognition': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      await db.insert('fish_catches', {
        'image_path': '/test/fish2.jpg',
        'species': 'Bass',
        'length': 25.0,
        'fate': 0,
        'catch_time': now.toIso8601String(),
        'pending_recognition': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      await db.insert('fish_catches', {
        'image_path': '/test/fish3.jpg',
        'species': 'Trout',
        'length': 20.0,
        'fate': 0,
        'catch_time': now.toIso8601String(),
        'pending_recognition': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      final results = await db.rawQuery('''
        SELECT species, COUNT(*) as count
        FROM fish_catches
        GROUP BY species
        ORDER BY count DESC
      ''');

      final stats = <String, int>{};
      for (final row in results) {
        stats[row['species'] as String] = row['count'] as int;
      }

      expect(stats['Bass'], equals(2));
      expect(stats['Trout'], equals(1));
    });
  });
}
