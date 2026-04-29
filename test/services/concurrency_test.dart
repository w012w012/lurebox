import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/fish_filter.dart';
import 'package:lurebox/core/repositories/fish_catch_repository_impl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/test_helpers.dart';

void main() {
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 22,
        onCreate: (db, version) async {
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
              catch_time TEXT NOT NULL,
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
            'CREATE INDEX idx_fish_catches_fate ON fish_catches(fate)',
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
        },
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('FishCatchRepository - Concurrency', () {
    late SqliteFishCatchRepository repository;

    setUp(() {
      repository = SqliteFishCatchRepository.withDatabase(
        Future<Database>.value(db),
      );
    });

    test('rapid double-tap save - both inserts succeed with unique ids',
        () async {
      final fish = TestDataFactory.createFishCatch(
        species: 'Bass',
        length: 30.0,
      );

      // Simulate rapid double-tap: two create() calls in parallel
      final results = await Future.wait([
        repository.create(fish),
        repository.create(fish),
      ]);

      // Both should succeed and return unique ids
      expect(results.length, equals(2));
      expect(results[0], isNot(equals(results[1])));
      expect(results[0], greaterThan(0));
      expect(results[1], greaterThan(0));

      // Verify both records exist
      final all = await repository.getAll();
      expect(all.length, equals(2));
    });

    test('rapid double-tap save - data integrity preserved', () async {
      final fish = TestDataFactory.createFishCatch(
        species: 'Trout',
        length: 25.5,
        weight: 1.2,
        fate: FishFateType.keep,
      );

      // Rapid parallel inserts
      await Future.wait([
        repository.create(fish),
        repository.create(fish),
      ]);

      final all = await repository.getAll();
      expect(all.length, equals(2));

      // Both records should have identical data (no corruption)
      for (final record in all) {
        expect(record.species, equals('Trout'));
        expect(record.length, equals(25.5));
        expect(record.weight, equals(1.2));
        expect(record.fate, equals(FishFateType.keep));
      }
    });

    test('parallel read/write - read returns consistent data', () async {
      // Pre-populate with some data
      await repository.create(TestDataFactory.createFishCatch(
        species: 'Bass',
        catchTime: DateTime(2024),
      ));

      // Start read and write operations in parallel
      final readFuture = repository.getAll();
      final writeFuture = repository.create(TestDataFactory.createFishCatch(
        species: 'Trout',
        catchTime: DateTime(2024, 1, 2),
      ));

      final results = await Future.wait([readFuture, writeFuture]);
      final readData = results[0] as List<FishCatch>;

      // Read should see either 1 or 2 records (depends on scheduling)
      // but no errors should occur
      expect(readData.length, greaterThanOrEqualTo(1));
      expect(readData.length, lessThanOrEqualTo(2));

      // Final state should have 2 records
      final finalAll = await repository.getAll();
      expect(finalAll.length, equals(2));
    });

    test('parallel write/write - all records persisted', () async {
      final fish1 = TestDataFactory.createFishCatch(
        id: 1,
        species: 'Bass',
        catchTime: DateTime(2024),
      );
      final fish2 = TestDataFactory.createFishCatch(
        id: 2,
        species: 'Trout',
        catchTime: DateTime(2024, 1, 2),
      );
      final fish3 = TestDataFactory.createFishCatch(
        id: 3,
        species: 'Salmon',
        catchTime: DateTime(2024, 1, 3),
      );

      // Three parallel inserts
      await Future.wait([
        repository.create(fish1),
        repository.create(fish2),
        repository.create(fish3),
      ]);

      final all = await repository.getAll();
      expect(all.length, equals(3));

      // Verify all species are present
      final species = all.map((f) => f.species).toList();
      expect(species, containsAll(['Bass', 'Trout', 'Salmon']));
    });

    test('parallel mixed operations - no data loss or corruption', () async {
      // Create initial record
      await repository.create(TestDataFactory.createFishCatch(
        species: 'Initial',
      ));

      // Perform mixed operations in parallel
      await Future.wait([
        repository.create(TestDataFactory.createFishCatch(
          species: 'Second',
        )),
        repository.getAll(),
        repository.create(TestDataFactory.createFishCatch(
          species: 'Third',
        )),
        repository.getCount(),
      ]);

      // Verify final state
      final all = await repository.getAll();
      final count = await repository.getCount();

      expect(all.length, equals(3));
      expect(count, equals(3));
    });

    test('concurrent updates to different records - no interference', () async {
      final fish1 = TestDataFactory.createFishCatch(species: 'Bass');
      final fish2 = TestDataFactory.createFishCatch(
        id: 2,
        species: 'Trout',
      );

      final id1 = await repository.create(fish1);
      final id2 = await repository.create(fish2);

      // Update records in parallel
      await Future.wait([
        repository.update(fish1.copyWith(id: id1, species: 'UpdatedBass')),
        repository.update(fish2.copyWith(id: id2, species: 'UpdatedTrout')),
      ]);

      // Verify both updates persisted correctly
      final result1 = await repository.getById(id1);
      final result2 = await repository.getById(id2);

      expect(result1!.species, equals('UpdatedBass'));
      expect(result2!.species, equals('UpdatedTrout'));
    });

    test('concurrent delete and read - consistent state', () async {
      final fish1 = TestDataFactory.createFishCatch(species: 'Bass');
      final fish2 = TestDataFactory.createFishCatch(
        id: 2,
        species: 'Trout',
      );

      final id1 = await repository.create(fish1);
      await repository.create(fish2);

      // Delete and read in parallel
      final deleteFuture = repository.delete(id1);
      final readFuture = repository.getAll();

      await Future.wait([deleteFuture, readFuture]);

      // Verify delete completed
      final count = await repository.getCount();
      expect(count, equals(1));

      // Verify correct record was deleted
      final remaining = await repository.getAll();
      expect(remaining.length, equals(1));
      expect(remaining[0].species, equals('Trout'));
    });

    test('rapid sequential saves - no duplicates', () async {
      final fish = TestDataFactory.createFishCatch(species: 'RapidSave');

      // Rapid sequential saves (simulates quick button taps)
      await repository.create(fish);
      await repository.create(fish);
      await repository.create(fish);

      final all = await repository.getAll();
      expect(all.length, equals(3));

      // Verify all are unique records
      final ids = all.map((f) => f.id).toList();
      expect(ids.toSet().length, equals(3));
    });

    test('concurrent filtered queries - no corruption', () async {
      final fish1 = TestDataFactory.createFishCatch(
        species: 'Bass',
        fate: FishFateType.release,
      );
      final fish2 = TestDataFactory.createFishCatch(
        id: 2,
        species: 'Trout',
        fate: FishFateType.keep,
      );

      await repository.create(fish1);
      await repository.create(fish2);

      // Multiple filtered queries in parallel
      final results = await Future.wait([
        repository.getByFate(FishFateType.release),
        repository.getByFate(FishFateType.keep),
        repository.getAll(),
      ]);

      final releaseList = results[0] as List<FishCatch>;
      final keepList = results[1] as List<FishCatch>;
      final allList = results[2] as List<FishCatch>;

      expect(releaseList.length, equals(1));
      expect(releaseList[0].species, equals('Bass'));
      expect(keepList.length, equals(1));
      expect(keepList[0].species, equals('Trout'));
      expect(allList.length, equals(2));
    });
  });
}
