import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/repositories/stats_repository.dart';
import 'package:lurebox/core/repositories/stats_repository_impl.dart';

void main() {
  late Database db;
  late SqliteStatsRepository repository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
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

          await db.execute(
              'CREATE INDEX idx_fish_catches_time ON fish_catches(catch_time)');
          await db.execute(
              'CREATE INDEX idx_fish_catches_fate ON fish_catches(fate)');
          await db.execute(
              'CREATE INDEX idx_fish_catches_species ON fish_catches(species)');
        },
      ),
    );
    repository = SqliteStatsRepository.withDatabase(Future.value(db));
  });

  tearDown(() async {
    await db.close();
  });

  /// Helper to insert a fish catch into the test database.
  Future<int> insertCatch({
    required String species,
    required double length,
    double? weight,
    required FishFateType fate,
    required DateTime catchTime,
    String? locationName,
    int? equipmentId,
    int? rodId,
    int? reelId,
    int? lureId,
  }) {
    final now = DateTime.now().toIso8601String();
    return db.insert('fish_catches', {
      'image_path': '/test/fish_$species.jpg',
      'species': species,
      'length': length,
      'weight': weight,
      'fate': fate.value,
      'catch_time': catchTime.toIso8601String(),
      'location_name': locationName,
      'equipment_id': equipmentId,
      'rod_id': rodId,
      'reel_id': reelId,
      'lure_id': lureId,
      'pending_recognition': 0,
      'created_at': now,
      'updated_at': now,
    });
  }

  /// Helper to insert equipment into the test database.
  Future<int> insertEquipment({
    required String type,
    String? brand,
    String? model,
    String? lureType,
  }) {
    final now = DateTime.now().toIso8601String();
    return db.insert('equipments', {
      'type': type,
      'brand': brand,
      'model': model,
      'lure_type': lureType,
      'created_at': now,
      'updated_at': now,
    });
  }

  // ─── CatchStats Model ───

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
      final stats = CatchStats.fromMap(<String, dynamic>{});
      expect(stats.total, equals(0));
      expect(stats.release, equals(0));
      expect(stats.keep, equals(0));
    });
  });

  // ─── EquipmentCatchStats Model ───

  group('EquipmentCatchStats Model', () {
    test('fromMap creates correct instance', () {
      final stats = EquipmentCatchStats.fromMap({
        'equipment_id': 2,
        'catch_count': 5,
        'avg_length': 25.0,
        'avg_weight': 1.5,
        'release_count': 3,
      });
      expect(stats.equipmentId, equals(2));
      expect(stats.catchCount, equals(5));
      expect(stats.avgLength, equals(25.0));
      expect(stats.avgWeight, equals(1.5));
      expect(stats.releaseCount, equals(3));
    });

    test('fromMap handles null values', () {
      final stats = EquipmentCatchStats.fromMap(<String, dynamic>{});
      expect(stats.equipmentId, equals(0));
      expect(stats.catchCount, equals(0));
      expect(stats.avgLength, isNull);
      expect(stats.avgWeight, isNull);
      expect(stats.releaseCount, equals(0));
    });
  });

  // ─── DashboardData Model ───

  group('DashboardData Model', () {
    test('creates DashboardData with all fields', () {
      const dashboard = DashboardData(
        todayStats: CatchStats(total: 5, release: 3, keep: 2),
        todaySpecies: {'Bass': 3, 'Trout': 2},
        monthStats: CatchStats(total: 50, release: 35, keep: 15),
        monthSpecies: {'Bass': 30, 'Trout': 20},
        yearStats: CatchStats(total: 200, release: 140, keep: 60),
        yearSpecies: {'Bass': 120, 'Trout': 80},
        allStats: CatchStats(total: 500, release: 350, keep: 150),
        allSpecies: {'Bass': 300, 'Trout': 200},
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

  // ─── Repository Interface ───

  group('Repository Interface', () {
    test('implements StatsRepository', () {
      expect(repository, isA<StatsRepository>());
    });
  });

  // ─── Empty Database Defaults ───

  group('Empty Database Defaults', () {
    test('getTotalCatchCount returns 0', () async {
      expect(await repository.getTotalCatchCount(), equals(0));
    });

    test('getDistinctSpeciesCount returns 0', () async {
      expect(await repository.getDistinctSpeciesCount(), equals(0));
    });

    test('getLocationCount returns 0', () async {
      expect(await repository.getLocationCount(), equals(0));
    });

    test('getReleaseCount returns 0', () async {
      expect(await repository.getReleaseCount(), equals(0));
    });

    test('getReleaseRate returns 0.0', () async {
      expect(await repository.getReleaseRate(), equals(0.0));
    });

    test('getCatchStats returns zero stats', () async {
      final stats = await repository.getCatchStats();
      expect(stats.total, equals(0));
      expect(stats.release, equals(0));
      expect(stats.keep, equals(0));
    });

    test('getSpeciesStats returns empty map', () async {
      expect(await repository.getSpeciesStats(), isEmpty);
    });

    test('getEquipmentCatchStats returns empty map', () async {
      expect(await repository.getEquipmentCatchStats(), isEmpty);
    });

    test('getConsecutiveDays returns 0', () async {
      expect(await repository.getConsecutiveDays(), equals(0));
    });

    test('getMonthlyMax returns 0', () async {
      expect(await repository.getMonthlyMax(), equals(0));
    });

    test('getDailyMax returns 0', () async {
      expect(await repository.getDailyMax(), equals(0));
    });

    test('getMorningCatchCount returns 0', () async {
      expect(await repository.getMorningCatchCount(), equals(0));
    });

    test('getNightCatchCount returns 0', () async {
      expect(await repository.getNightCatchCount(), equals(0));
    });

    test('getMaxLength returns 0.0', () async {
      expect(await repository.getMaxLength(), equals(0.0));
    });

    test('getTotalWeight returns 0.0', () async {
      expect(await repository.getTotalWeight(), equals(0.0));
    });

    test('getTop3LongestCatches returns empty list', () async {
      expect(await repository.getTop3LongestCatches(), isEmpty);
    });

    test('getDashboardData returns zero stats', () async {
      final dashboard = await repository.getDashboardData();
      expect(dashboard.todayStats.total, equals(0));
      expect(dashboard.monthStats.total, equals(0));
      expect(dashboard.yearStats.total, equals(0));
      expect(dashboard.allStats.total, equals(0));
      expect(dashboard.top3Longest, isEmpty);
    });
  });

  // ─── CatchStats with Real Data ───

  group('CatchStats with Real Data', () {
    setUp(() async {
      final now = DateTime.now();
      // 3 released, 2 kept
      await insertCatch(
          species: 'Bass',
          length: 30,
          fate: FishFateType.release,
          catchTime: now);
      await insertCatch(
          species: 'Bass',
          length: 28,
          fate: FishFateType.release,
          catchTime: now);
      await insertCatch(
          species: 'Trout',
          length: 25,
          fate: FishFateType.release,
          catchTime: now);
      await insertCatch(
          species: 'Bass',
          length: 22,
          fate: FishFateType.keep,
          catchTime: now);
      await insertCatch(
          species: 'Trout',
          length: 20,
          fate: FishFateType.keep,
          catchTime: now);
    });

    test('getCatchStats returns correct counts', () async {
      final stats = await repository.getCatchStats();
      expect(stats.total, equals(5));
      expect(stats.release, equals(3));
      expect(stats.keep, equals(2));
      expect(stats.releaseRate, closeTo(0.6, 0.01));
    });

    test('getTotalCatchCount returns 5', () async {
      expect(await repository.getTotalCatchCount(), equals(5));
    });

    test('getDistinctSpeciesCount returns 2', () async {
      expect(await repository.getDistinctSpeciesCount(), equals(2));
    });

    test('getReleaseCount returns 3', () async {
      expect(await repository.getReleaseCount(), equals(3));
    });

    test('getReleaseRate returns 0.6', () async {
      expect(await repository.getReleaseRate(), closeTo(0.6, 0.01));
    });
  });

  // ─── Species Stats ───

  group('Species Stats', () {
    setUp(() async {
      final now = DateTime.now();
      // Bass: 3 catches, Trout: 2, Perch: 1
      for (var i = 0; i < 3; i++) {
        await insertCatch(
            species: 'Bass',
            length: 25 + i * 2,
            fate: FishFateType.release,
            catchTime: now);
      }
      for (var i = 0; i < 2; i++) {
        await insertCatch(
            species: 'Trout',
            length: 20 + i * 3,
            fate: FishFateType.keep,
            catchTime: now);
      }
      await insertCatch(
          species: 'Perch',
          length: 18,
          fate: FishFateType.release,
          catchTime: now);
    });

    test('getSpeciesStats returns species map ordered by count', () async {
      final stats = await repository.getSpeciesStats();
      expect(stats.length, equals(3));
      expect(stats['Bass'], equals(3));
      expect(stats['Trout'], equals(2));
      expect(stats['Perch'], equals(1));
    });

    test('getSpeciesStats respects limit parameter', () async {
      final stats = await repository.getSpeciesStats(limit: 2);
      expect(stats.length, equals(2));
      expect(stats.containsKey('Bass'), isTrue);
      expect(stats.containsKey('Trout'), isTrue);
      expect(stats.containsKey('Perch'), isFalse);
    });
  });

  // ─── Location Stats ───

  group('Location Stats', () {
    setUp(() async {
      final now = DateTime.now();
      await insertCatch(
          species: 'Bass',
          length: 30,
          fate: FishFateType.release,
          catchTime: now,
          locationName: 'Lake A');
      await insertCatch(
          species: 'Trout',
          length: 25,
          fate: FishFateType.release,
          catchTime: now,
          locationName: 'Lake A');
      await insertCatch(
          species: 'Bass',
          length: 28,
          fate: FishFateType.release,
          catchTime: now,
          locationName: 'River B');
      await insertCatch(
          species: 'Perch',
          length: 20,
          fate: FishFateType.keep,
          catchTime: now,
          locationName: null);
    });

    test('getLocationCount counts distinct non-null locations', () async {
      expect(await repository.getLocationCount(), equals(2));
    });
  });

  // ─── Length & Weight ───

  group('Length & Weight Stats', () {
    setUp(() async {
      final now = DateTime.now();
      await insertCatch(
          species: 'Bass',
          length: 35.5,
          weight: 3.2,
          fate: FishFateType.release,
          catchTime: now);
      await insertCatch(
          species: 'Trout',
          length: 28.0,
          weight: 2.1,
          fate: FishFateType.keep,
          catchTime: now);
      await insertCatch(
          species: 'Perch',
          length: 18.0,
          weight: null,
          fate: FishFateType.release,
          catchTime: now);
    });

    test('getMaxLength returns the maximum length', () async {
      expect(await repository.getMaxLength(), equals(35.5));
    });

    test('getTotalWeight sums non-null weights', () async {
      expect(await repository.getTotalWeight(), closeTo(5.3, 0.01));
    });

    test('getCatchesAboveLength counts catches above threshold', () async {
      expect(await repository.getCatchesAboveLength(30.0), equals(1));
      expect(await repository.getCatchesAboveLength(20.0), equals(2));
      expect(await repository.getCatchesAboveLength(10.0), equals(3));
    });
  });

  // ─── Time Period Stats ───

  group('Time Period Stats', () {
    test('getMorningCatchCount counts morning catches', () async {
      // Morning: hour 5-9 (based on TimeConstants)
      final now = DateTime.now();
      final morning = DateTime(now.year, now.month, now.day, 6);
      await insertCatch(
          species: 'Bass',
          length: 30,
          fate: FishFateType.release,
          catchTime: morning);
      await insertCatch(
          species: 'Trout',
          length: 25,
          fate: FishFateType.release,
          catchTime: DateTime(now.year, now.month, now.day, 7));

      final count = await repository.getMorningCatchCount();
      expect(count, equals(2));
    });

    test('getNightCatchCount counts night catches', () async {
      final now = DateTime.now();
      // Night: hour >= 21 or < 5
      final lateNight = DateTime(now.year, now.month, now.day, 22);
      await insertCatch(
          species: 'Bass',
          length: 30,
          fate: FishFateType.release,
          catchTime: lateNight);

      final count = await repository.getNightCatchCount();
      expect(count, equals(1));
    });

    test('getDailyMax returns max catches in a single day', () async {
      final now = DateTime.now();
      // Day 1: 3 catches
      for (var i = 0; i < 3; i++) {
        await insertCatch(
            species: 'Bass',
            length: 25,
            fate: FishFateType.release,
            catchTime: now);
      }
      // Day 2: 1 catch
      await insertCatch(
          species: 'Trout',
          length: 20,
          fate: FishFateType.keep,
          catchTime: now.subtract(const Duration(days: 1)));

      expect(await repository.getDailyMax(), equals(3));
    });

    test('getMonthlyMax returns max catches in a single month', () async {
      final now = DateTime.now();
      // All in current month
      for (var i = 0; i < 4; i++) {
        await insertCatch(
            species: 'Bass',
            length: 25,
            fate: FishFateType.release,
            catchTime: now);
      }

      expect(await repository.getMonthlyMax(), equals(4));
    });
  });

  // ─── Top 3 Longest Catches ───

  group('Top 3 Longest Catches', () {
    test('returns top 3 by length descending', () async {
      final now = DateTime.now();
      await insertCatch(
          species: 'Small Perch',
          length: 15.0,
          fate: FishFateType.release,
          catchTime: now);
      await insertCatch(
          species: 'Big Bass',
          length: 50.0,
          fate: FishFateType.release,
          catchTime: now);
      await insertCatch(
          species: 'Medium Trout',
          length: 35.0,
          fate: FishFateType.keep,
          catchTime: now);
      await insertCatch(
          species: 'Trophy Pike',
          length: 45.0,
          fate: FishFateType.release,
          catchTime: now);

      final top3 = await repository.getTop3LongestCatches();
      expect(top3.length, equals(3));
      expect(top3[0].species, equals('Big Bass'));
      expect(top3[0].length, equals(50.0));
      expect(top3[1].species, equals('Trophy Pike'));
      expect(top3[1].length, equals(45.0));
      expect(top3[2].species, equals('Medium Trout'));
      expect(top3[2].length, equals(35.0));
    });

    test('returns fewer than 3 when less data exists', () async {
      final now = DateTime.now();
      await insertCatch(
          species: 'Only Fish',
          length: 30.0,
          fate: FishFateType.release,
          catchTime: now);

      final top3 = await repository.getTop3LongestCatches();
      expect(top3.length, equals(1));
      expect(top3[0].species, equals('Only Fish'));
    });

    test('returns FishCatch objects with correct data', () async {
      final now = DateTime.now();
      await insertCatch(
          species: 'Bass',
          length: 40.0,
          weight: 2.5,
          fate: FishFateType.keep,
          catchTime: now,
          locationName: 'Lake Test');

      final top3 = await repository.getTop3LongestCatches();
      final fish = top3.first;
      expect(fish, isA<FishCatch>());
      expect(fish.species, equals('Bass'));
      expect(fish.length, equals(40.0));
      expect(fish.weight, equals(2.5));
      expect(fish.fate, equals(FishFateType.keep));
    });
  });

  // ─── Dashboard Data ───

  group('Dashboard Data', () {
    test('getDashboardData returns today/month/year/all stats', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10);
      final thisMonth = DateTime(now.year, now.month, 10, 10);
      final thisYear = DateTime(now.year, 3, 15, 10);
      final oldDate = DateTime(now.year - 2, 6, 15, 10);

      // Today: 2 catches
      await insertCatch(
          species: 'Bass',
          length: 30,
          fate: FishFateType.release,
          catchTime: today);
      await insertCatch(
          species: 'Trout',
          length: 25,
          fate: FishFateType.keep,
          catchTime: today);

      // This month (but not today): 1 catch
      await insertCatch(
          species: 'Perch',
          length: 20,
          fate: FishFateType.release,
          catchTime: thisMonth);

      // This year (different month): 1 catch
      await insertCatch(
          species: 'Bass',
          length: 28,
          fate: FishFateType.release,
          catchTime: thisYear);

      // Old date: 1 catch
      await insertCatch(
          species: 'Pike',
          length: 45,
          fate: FishFateType.release,
          catchTime: oldDate);

      final dashboard = await repository.getDashboardData();

      // All time: 5 catches, 4 released, 1 kept
      expect(dashboard.allStats.total, equals(5));
      expect(dashboard.allStats.release, equals(4));
      expect(dashboard.allStats.keep, equals(1));

      // Today: 2 catches
      expect(dashboard.todayStats.total, equals(2));
      expect(dashboard.todayStats.release, equals(1));
      expect(dashboard.todayStats.keep, equals(1));

      // Top 3 longest
      expect(dashboard.top3Longest.length, equals(3));
      expect(dashboard.top3Longest.first['species'], equals('Pike'));
      expect(dashboard.top3Longest.first['length'], equals(45.0));
    });
  });

  // ─── Equipment Stats ───

  group('Equipment Stats', () {
    test('getEquipmentCatchStats aggregates by equipment ID', () async {
      final now = DateTime.now();
      // Insert equipment
      await insertEquipment(type: 'rod', brand: 'Shimano', model: 'Expride');

      // Insert catches linked to equipment_id = 1
      await insertCatch(
          species: 'Bass',
          length: 30,
          weight: 2.0,
          fate: FishFateType.release,
          catchTime: now,
          equipmentId: 1);
      await insertCatch(
          species: 'Trout',
          length: 25,
          weight: 1.5,
          fate: FishFateType.keep,
          catchTime: now,
          equipmentId: 1);

      final stats = await repository.getEquipmentCatchStats();
      expect(stats.containsKey(1), isTrue);
      expect(stats[1]!.catchCount, equals(2));
      expect(stats[1]!.releaseCount, equals(1));
    });

    test(
        'getEquipmentCatchStats aggregates across rod/reel/lure ID columns',
        () async {
      final now = DateTime.now();
      await insertCatch(
          species: 'Bass',
          length: 30,
          fate: FishFateType.release,
          catchTime: now,
          rodId: 5);
      await insertCatch(
          species: 'Trout',
          length: 25,
          fate: FishFateType.keep,
          catchTime: now,
          reelId: 3);

      final stats = await repository.getEquipmentCatchStats();
      expect(stats.containsKey(5), isTrue);
      expect(stats.containsKey(3), isTrue);
    });
  });

  // ─── Equipment Distribution ───

  group('Equipment Distribution', () {
    test('getEquipmentDistribution groups by lure type', () async {
      final now = DateTime.now();
      await insertEquipment(type: 'lure', lureType: 'Soft Plastic');
      await insertEquipment(type: 'lure', lureType: 'Crankbait');

      await insertCatch(
          species: 'Bass',
          length: 30,
          fate: FishFateType.release,
          catchTime: now,
          lureId: 1);
      await insertCatch(
          species: 'Bass',
          length: 28,
          fate: FishFateType.release,
          catchTime: now,
          lureId: 1);
      await insertCatch(
          species: 'Trout',
          length: 25,
          fate: FishFateType.keep,
          catchTime: now,
          lureId: 2);

      final dist = await repository.getEquipmentDistribution('lure');
      expect(dist['Soft Plastic'], equals(2));
      expect(dist['Crankbait'], equals(1));
    });
  });

  // ─── Daily Catch Count ───

  group('Daily Catch Count', () {
    test('getDailyCatchCount returns daily aggregates', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10);
      final yesterday =
          DateTime(now.year, now.month, now.day, 10)
              .subtract(const Duration(days: 1));

      // Today: 2 catches
      await insertCatch(
          species: 'Bass',
          length: 30,
          fate: FishFateType.release,
          catchTime: today);
      await insertCatch(
          species: 'Trout',
          length: 25,
          fate: FishFateType.keep,
          catchTime: today);

      // Yesterday: 1 catch
      await insertCatch(
          species: 'Perch',
          length: 20,
          fate: FishFateType.release,
          catchTime: yesterday);

      final dailyCounts = await repository.getDailyCatchCount(
        startDate: yesterday.subtract(const Duration(hours: 1)),
        endDate: now.add(const Duration(days: 1)),
      );

      expect(dailyCounts.length, equals(2));
      // Check today has 2 catches
      final todayEntry = dailyCounts.lastWhere(
          (d) => d['date'] == '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}');
      expect(todayEntry['count'], equals(2));
      expect(todayEntry['release'], equals(1));
      expect(todayEntry['keep'], equals(1));
    });
  });

  // ─── Equipment Full Status ───

  group('Equipment Full Status', () {
    test('counts catches with equipment_id or full rig', () async {
      final now = DateTime.now();
      // Catches with equipment_id
      await insertCatch(
          species: 'Bass',
          length: 30,
          fate: FishFateType.release,
          catchTime: now,
          equipmentId: 1);
      // Catch with full rig (rod+reel+lure)
      await insertCatch(
          species: 'Trout',
          length: 25,
          fate: FishFateType.release,
          catchTime: now,
          rodId: 1,
          reelId: 1,
          lureId: 1);
      // Catch with partial equipment (should not count)
      await insertCatch(
          species: 'Perch',
          length: 20,
          fate: FishFateType.keep,
          catchTime: now,
          rodId: 1);

      final count = await repository.getEquipmentFullStatus();
      expect(count, equals(2));
    });
  });

  // ─── Date Range Filtering ───

  group('Date Range Filtering', () {
    setUp(() async {
      final now = DateTime.now();
      // 2 catches this week, 1 catch last month
      await insertCatch(
          species: 'Bass',
          length: 30,
          fate: FishFateType.release,
          catchTime: now);
      await insertCatch(
          species: 'Trout',
          length: 25,
          fate: FishFateType.keep,
          catchTime: now.subtract(const Duration(days: 2)));
      await insertCatch(
          species: 'Pike',
          length: 45,
          fate: FishFateType.release,
          catchTime: now.subtract(const Duration(days: 40)));
    });

    test('getCatchStats with date range filters correctly', () async {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      final recentStats =
          await repository.getCatchStats(startDate: weekAgo, endDate: now);
      expect(recentStats.total, equals(2));
      expect(recentStats.release, equals(1));
      expect(recentStats.keep, equals(1));

      final allStats = await repository.getCatchStats();
      expect(allStats.total, equals(3));
    });

    test('getSpeciesStats with date range filters correctly', () async {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      final recentSpecies =
          await repository.getSpeciesStats(startDate: weekAgo, endDate: now);
      expect(recentSpecies.length, equals(2));
      expect(recentSpecies.containsKey('Pike'), isFalse);

      final allSpecies = await repository.getSpeciesStats();
      expect(allSpecies.length, equals(3));
    });
  });

  // ─── Photo Count ───

  group('Photo Count', () {
    test('getPhotoCount counts catches with image paths', () async {
      final now = DateTime.now();
      await insertCatch(
          species: 'Bass',
          length: 30,
          fate: FishFateType.release,
          catchTime: now);
      await insertCatch(
          species: 'Trout',
          length: 25,
          fate: FishFateType.release,
          catchTime: now);

      final count = await repository.getPhotoCount();
      expect(count, equals(2));
    });
  });
}
