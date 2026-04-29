import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/equipment.dart';
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
          // 鱼获表 - 完整schema (v22)
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

          // 装备表 (至少需要用于外键关联)
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

          // 索引
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

  group('FishCatchRepository - CRUD', () {
    late SqliteFishCatchRepository repository;

    setUp(() {
      repository = SqliteFishCatchRepository.withDatabase(
        Future<Database>.value(db),
      );
    });

    test('create inserts fish catch and returns id', () async {
      final fish = TestDataFactory.createFishCatch();
      final id = await repository.create(fish);

      expect(id, greaterThan(0));
    });

    test('create stores fish catch with all fields', () async {
      final now = DateTime.now();
      final fish = TestDataFactory.createFishCatch(
        species: 'Trout',
        length: 25.5,
        weight: 1.2,
        fate: FishFateType.keep,
        catchTime: now,
        locationName: 'Test Lake',
        latitude: 35.6762,
        longitude: 139.6503,
      );

      final id = await repository.create(fish);
      final retrieved = await repository.getById(id);

      expect(retrieved, isNotNull);
      expect(retrieved!.species, equals('Trout'));
      expect(retrieved.length, equals(25.5));
      expect(retrieved.weight, equals(1.2));
      expect(retrieved.fate, equals(FishFateType.keep));
      expect(retrieved.locationName, equals('Test Lake'));
      expect(retrieved.latitude, equals(35.6762));
      expect(retrieved.longitude, equals(139.6503));
    });

    test('getAll returns empty list when no records', () async {
      final results = await repository.getAll();

      expect(results, isEmpty);
    });

    test('getAll returns all fish catches ordered by catch_time DESC',
        () async {
      final fish1 = TestDataFactory.createFishCatch(
        catchTime: DateTime(2024),
      );
      final fish2 = TestDataFactory.createFishCatch(
        id: 2,
        species: 'Trout',
        catchTime: DateTime(2024, 1, 3),
      );
      final fish3 = TestDataFactory.createFishCatch(
        id: 3,
        species: 'Salmon',
        catchTime: DateTime(2024, 1, 2),
      );

      await repository.create(fish1);
      await repository.create(fish2);
      await repository.create(fish3);

      final results = await repository.getAll();

      expect(results.length, equals(3));
      // 最新钓获在最前面
      expect(results[0].species, equals('Trout'));
      expect(results[1].species, equals('Salmon'));
      expect(results[2].species, equals('Bass'));
    });

    test('getById returns fish catch when exists', () async {
      final fish = TestDataFactory.createFishCatch();
      final id = await repository.create(fish);

      final result = await repository.getById(id);

      expect(result, isNotNull);
      expect(result!.species, equals('Bass'));
    });

    test('getById returns null when not exists', () async {
      final result = await repository.getById(9999);

      expect(result, isNull);
    });

    test('update modifies existing fish catch', () async {
      final fish = TestDataFactory.createFishCatch(
        
      );
      final id = await repository.create(fish);

      final updated = fish.copyWith(species: 'Trout', length: 35);
      await repository.update(updated);

      final result = await repository.getById(id);
      expect(result!.species, equals('Trout'));
      expect(result.length, equals(35.0));
    });

    test('delete removes fish catch', () async {
      final fish = TestDataFactory.createFishCatch();
      final id = await repository.create(fish);

      await repository.delete(id);

      final result = await repository.getById(id);
      expect(result, isNull);
    });

    test('deleteMultiple removes multiple fish catches', () async {
      final fish1 = TestDataFactory.createFishCatch();
      final fish2 = TestDataFactory.createFishCatch(id: 2, species: 'Trout');
      final fish3 = TestDataFactory.createFishCatch(id: 3, species: 'Salmon');

      final id1 = await repository.create(fish1);
      final id2 = await repository.create(fish2);
      await repository.create(fish3);

      await repository.deleteMultiple([id1, id2]);

      final all = await repository.getAll();
      expect(all.length, equals(1));
      expect(all[0].species, equals('Salmon'));
    });

    test('deleteMultiple does nothing for empty list', () async {
      final fish = TestDataFactory.createFishCatch();
      await repository.create(fish);

      // Should not throw
      await repository.deleteMultiple([]);

      final all = await repository.getAll();
      expect(all.length, equals(1));
    });
  });

  group('FishCatchRepository - Query Methods', () {
    late SqliteFishCatchRepository repository;

    setUp(() {
      repository = SqliteFishCatchRepository.withDatabase(
        Future<Database>.value(db),
      );
    });

    test('getByDateRange returns fish catches within range', () async {
      final fish1 = TestDataFactory.createFishCatch(
        catchTime: DateTime(2024),
      );
      final fish2 = TestDataFactory.createFishCatch(
        id: 2,
        species: 'Trout',
        catchTime: DateTime(2024, 1, 15),
      );
      final fish3 = TestDataFactory.createFishCatch(
        id: 3,
        species: 'Salmon',
        catchTime: DateTime(2024, 2),
      );

      await repository.create(fish1);
      await repository.create(fish2);
      await repository.create(fish3);

      final results = await repository.getByDateRange(
        DateTime(2024),
        DateTime(2024, 1, 31),
      );

      expect(results.length, equals(2));
      expect(results.map((f) => f.species), containsAll(['Bass', 'Trout']));
    });

    test('getByDateRange returns empty when no matches', () async {
      final fish = TestDataFactory.createFishCatch(
        catchTime: DateTime(2024),
      );
      await repository.create(fish);

      final results = await repository.getByDateRange(
        DateTime(2024, 6),
        DateTime(2024, 6, 30),
      );

      expect(results, isEmpty);
    });

    test('getByFate returns fish catches with matching fate', () async {
      final fish1 = TestDataFactory.createFishCatch(
        
      );
      final fish2 = TestDataFactory.createFishCatch(
        id: 2,
        species: 'Trout',
        fate: FishFateType.keep,
      );
      final fish3 = TestDataFactory.createFishCatch(
        id: 3,
        species: 'Salmon',
      );

      await repository.create(fish1);
      await repository.create(fish2);
      await repository.create(fish3);

      final results = await repository.getByFate(FishFateType.release);

      expect(results.length, equals(2));
      expect(results.map((f) => f.species), containsAll(['Bass', 'Salmon']));
    });

    test('getByFate returns empty when no matches', () async {
      final fish = TestDataFactory.createFishCatch();
      await repository.create(fish);

      final results = await repository.getByFate(FishFateType.keep);

      expect(results, isEmpty);
    });
  });

  group('FishCatchRepository - Pagination', () {
    late SqliteFishCatchRepository repository;

    setUp(() {
      repository = SqliteFishCatchRepository.withDatabase(
        Future<Database>.value(db),
      );
    });

    test('getPage returns first page with default pageSize', () async {
      // Create 25 fish catches
      for (var i = 0; i < 25; i++) {
        await repository.create(TestDataFactory.createFishCatch(
          id: i + 1,
          species: 'Fish_$i',
          catchTime: DateTime(2024, 1, i + 1),
        ),);
      }

      final result = await repository.getPage(page: 1);

      expect(result.items.length, equals(20));
      expect(result.page, equals(1));
      expect(result.pageSize, equals(20));
      expect(result.totalCount, equals(25));
      expect(result.hasMore, isTrue);
    });

    test('getPage returns second page with correct items', () async {
      for (var i = 0; i < 25; i++) {
        await repository.create(TestDataFactory.createFishCatch(
          id: i + 1,
          species: 'Fish_$i',
          catchTime: DateTime(2024, 1, i + 1),
        ),);
      }

      final result = await repository.getPage(page: 2);

      expect(result.items.length, equals(5));
      expect(result.page, equals(2));
      expect(result.hasMore, isFalse);
    });

    test('getPage returns last page with partial items', () async {
      for (var i = 0; i < 45; i++) {
        await repository.create(TestDataFactory.createFishCatch(
          id: i + 1,
          species: 'Fish_$i',
          catchTime: DateTime(2024, 1, i + 1),
        ),);
      }

      final result = await repository.getPage(page: 3);

      expect(result.items.length, equals(5));
      expect(result.hasMore, isFalse);
    });

    test('getPage returns empty items for page beyond data', () async {
      await repository.create(TestDataFactory.createFishCatch());

      final result = await repository.getPage(page: 100);

      expect(result.items, isEmpty);
      expect(result.hasMore, isFalse);
    });

    test('getPage with custom pageSize', () async {
      for (var i = 0; i < 15; i++) {
        await repository.create(TestDataFactory.createFishCatch(
          id: i + 1,
          species: 'Fish_$i',
          catchTime: DateTime(2024, 1, i + 1),
        ),);
      }

      final result = await repository.getPage(page: 1, pageSize: 5);

      expect(result.items.length, equals(5));
      expect(result.totalCount, equals(15));
      expect(result.hasMore, isTrue);
    });

    test('getFilteredPage filters by date range', () async {
      final fish1 = TestDataFactory.createFishCatch(
        catchTime: DateTime(2024),
      );
      final fish2 = TestDataFactory.createFishCatch(
        id: 2,
        species: 'Trout',
        catchTime: DateTime(2024, 1, 15),
      );
      final fish3 = TestDataFactory.createFishCatch(
        id: 3,
        species: 'Salmon',
        catchTime: DateTime(2024, 2),
      );

      await repository.create(fish1);
      await repository.create(fish2);
      await repository.create(fish3);

      final result = await repository.getFilteredPage(
        page: 1,
        startDate: DateTime(2024),
        endDate: DateTime(2024, 1, 31),
      );

      expect(result.items.length, equals(2));
      expect(result.totalCount, equals(2));
    });

    test('getFilteredPage filters by fate', () async {
      final fish1 = TestDataFactory.createFishCatch(
        
      );
      final fish2 = TestDataFactory.createFishCatch(
        id: 2,
        species: 'Trout',
        fate: FishFateType.keep,
      );

      await repository.create(fish1);
      await repository.create(fish2);

      final result = await repository.getFilteredPage(
        page: 1,
        fate: FishFateType.keep,
      );

      expect(result.items.length, equals(1));
      expect(result.items[0].species, equals('Trout'));
    });

    test('getFilteredPage filters by species', () async {
      final fish1 = TestDataFactory.createFishCatch(
        
      );
      final fish2 = TestDataFactory.createFishCatch(
        id: 2,
        species: 'Trout',
      );
      final fish3 = TestDataFactory.createFishCatch(
        id: 3,
      );

      await repository.create(fish1);
      await repository.create(fish2);
      await repository.create(fish3);

      final result = await repository.getFilteredPage(
        page: 1,
        species: 'Bass',
      );

      expect(result.items.length, equals(2));
    });
  });

  group('FishCatchRepository - Pending Recognition', () {
    late SqliteFishCatchRepository repository;

    setUp(() {
      repository = SqliteFishCatchRepository.withDatabase(
        Future<Database>.value(db),
      );
    });

    test('getPendingRecognitionCatches returns only pending records', () async {
      final fish1 = TestDataFactory.createFishCatch(
        
      ).copyWith(pendingRecognition: true);
      final fish2 = TestDataFactory.createFishCatch(
        id: 2,
        species: 'Trout',
      ).copyWith(pendingRecognition: false);
      final fish3 = TestDataFactory.createFishCatch(
        id: 3,
        species: 'Salmon',
      ).copyWith(pendingRecognition: true);

      await repository.create(fish1);
      await repository.create(fish2);
      await repository.create(fish3);

      final results = await repository.getPendingRecognitionCatches();

      expect(results.length, equals(2));
      expect(results.map((f) => f.species), containsAll(['Bass', 'Salmon']));
    });

    test('getPendingRecognitionCatches returns empty when none pending',
        () async {
      final fish = TestDataFactory.createFishCatch(
        
      ).copyWith(pendingRecognition: false);
      await repository.create(fish);

      final results = await repository.getPendingRecognitionCatches();

      expect(results, isEmpty);
    });

    test('updateSpecies updates species and clears pending flag', () async {
      final fish = TestDataFactory.createFishCatch(
        species: 'Unknown',
      ).copyWith(pendingRecognition: true);
      final id = await repository.create(fish);

      await repository.updateSpecies(id, 'Bass');

      final result = await repository.getById(id);
      expect(result!.species, equals('Bass'));
      expect(result.pendingRecognition, isFalse);
    });

    test('batchUpdateSpecies updates multiple records', () async {
      final fish1 = TestDataFactory.createFishCatch(
        species: 'Unknown',
      ).copyWith(pendingRecognition: true);
      final fish2 = TestDataFactory.createFishCatch(
        id: 2,
        species: 'Unknown',
      ).copyWith(pendingRecognition: true);

      final id1 = await repository.create(fish1);
      final id2 = await repository.create(fish2);

      await repository.batchUpdateSpecies(
        [id1, id2],
        ['Bass', 'Trout'],
      );

      final result1 = await repository.getById(id1);
      final result2 = await repository.getById(id2);

      expect(result1!.species, equals('Bass'));
      expect(result1.pendingRecognition, isFalse);
      expect(result2!.species, equals('Trout'));
      expect(result2.pendingRecognition, isFalse);
    });

    test('batchUpdateSpecies does nothing for empty list', () async {
      // Should not throw
      await repository.batchUpdateSpecies([], []);
    });

    test('batchUpdateSpecies throws on mismatched lengths', () async {
      final fish = TestDataFactory.createFishCatch(species: 'Unknown');
      final id = await repository.create(fish);

      expect(
        () => repository.batchUpdateSpecies([id], ['Bass', 'Trout']),
        throwsArgumentError,
      );
    });
  });

  group('FishCatchRepository - Species Operations', () {
    late SqliteFishCatchRepository repository;

    setUp(() {
      repository = SqliteFishCatchRepository.withDatabase(
        Future<Database>.value(db),
      );
    });

    test('getSpeciesCounts returns correct counts', () async {
      final fish1 = TestDataFactory.createFishCatch();
      final fish2 = TestDataFactory.createFishCatch(id: 2, species: 'Trout');
      final fish3 = TestDataFactory.createFishCatch(id: 3);
      final fish4 = TestDataFactory.createFishCatch(id: 4);

      await repository.create(fish1);
      await repository.create(fish2);
      await repository.create(fish3);
      await repository.create(fish4);

      final counts = await repository.getSpeciesCounts();

      expect(counts['Bass'], equals(3));
      expect(counts['Trout'], equals(1));
    });

    test('getSpeciesCounts returns empty when no records', () async {
      final counts = await repository.getSpeciesCounts();

      expect(counts, isEmpty);
    });

    test('renameSpecies updates all matching records', () async {
      final fish1 = TestDataFactory.createFishCatch(species: 'OldName');
      final fish2 = TestDataFactory.createFishCatch(id: 2, species: 'OldName');
      final fish3 = TestDataFactory.createFishCatch(id: 3, species: 'Other');

      await repository.create(fish1);
      await repository.create(fish2);
      await repository.create(fish3);

      await repository.renameSpecies('OldName', 'NewName');

      final counts = await repository.getSpeciesCounts();
      expect(counts['NewName'], equals(2));
      expect(counts['OldName'], isNull);
      expect(counts['Other'], equals(1));
    });

    test('renameSpecies throws on empty names', () async {
      expect(
        () => repository.renameSpecies('', 'NewName'),
        throwsException,
      );
      expect(
        () => repository.renameSpecies('OldName', ''),
        throwsException,
      );
    });

    test('mergeSpecies is same as renameSpecies', () async {
      final fish1 = TestDataFactory.createFishCatch(species: 'From');
      final fish2 = TestDataFactory.createFishCatch(id: 2, species: 'To');
      final fish3 = TestDataFactory.createFishCatch(id: 3, species: 'From');

      await repository.create(fish1);
      await repository.create(fish2);
      await repository.create(fish3);

      await repository.mergeSpecies('From', 'To');

      final counts = await repository.getSpeciesCounts();
      expect(counts['To'], equals(3));
      expect(counts['From'], isNull);
    });

    test('deleteSpecies removes all records with matching species', () async {
      final fish1 = TestDataFactory.createFishCatch();
      final fish2 = TestDataFactory.createFishCatch(id: 2, species: 'Trout');
      final fish3 = TestDataFactory.createFishCatch(id: 3);

      await repository.create(fish1);
      await repository.create(fish2);
      await repository.create(fish3);

      await repository.deleteSpecies('Bass');

      final all = await repository.getAll();
      expect(all.length, equals(1));
      expect(all[0].species, equals('Trout'));
    });

    test('deleteSpecies throws on empty species name', () async {
      expect(
        () => repository.deleteSpecies(''),
        throwsException,
      );
    });
  });

  group('FishCatchRepository - Count', () {
    late SqliteFishCatchRepository repository;

    setUp(() {
      repository = SqliteFishCatchRepository.withDatabase(
        Future<Database>.value(db),
      );
    });

    test('getCount returns 0 when empty', () async {
      final count = await repository.getCount();

      expect(count, equals(0));
    });

    test('getCount returns correct total', () async {
      await repository
          .create(TestDataFactory.createFishCatch());
      await repository
          .create(TestDataFactory.createFishCatch(id: 2, species: 'Trout'));
      await repository
          .create(TestDataFactory.createFishCatch(id: 3, species: 'Salmon'));

      final count = await repository.getCount();

      expect(count, equals(3));
    });
  });

  group('FishCatchRepository - getFilteredPageByFilter', () {
    late SqliteFishCatchRepository repository;

    setUp(() {
      repository = SqliteFishCatchRepository.withDatabase(
        Future<Database>.value(db),
      );
    });

    test('getFilteredPageByFilter with FishFilter returns paginated results',
        () async {
      final fish1 = TestDataFactory.createFishCatch(
        catchTime: DateTime(2024),
      );
      final fish2 = TestDataFactory.createFishCatch(
        id: 2,
        species: 'Trout',
        fate: FishFateType.keep,
        catchTime: DateTime(2024, 1, 15),
      );

      await repository.create(fish1);
      await repository.create(fish2);

      const filter = FishFilter(
        fateFilter: FishFateType.release,
      );

      final result = await repository.getFilteredPageByFilter(
        page: 1,
        filter: filter,
      );

      expect(result.items.length, equals(1));
      expect(result.items[0].species, equals('Bass'));
    });

    test(
      'hasMore is correct when totalCount is exactly divisible by pageSize',
      () async {
        // 20 items, pageSize=10 → 2 exact pages
        for (var i = 0; i < 20; i++) {
          await repository.create(TestDataFactory.createFishCatch(
            id: i + 1,
            species: 'Fish_$i',
            catchTime: DateTime(2024, 1, i + 1),
          ),);
        }

        const filter = FishFilter();

        final page1 = await repository.getFilteredPageByFilter(
          page: 1,
          pageSize: 10,
          filter: filter,
        );
        expect(page1.items.length, equals(10));
        expect(page1.hasMore, isTrue);

        final page2 = await repository.getFilteredPageByFilter(
          page: 2,
          pageSize: 10,
          filter: filter,
        );
        expect(page2.items.length, equals(10));
        expect(page2.hasMore, isFalse);
      },
    );

    test('hasMore is false when totalCount < pageSize', () async {
      for (var i = 0; i < 5; i++) {
        await repository.create(TestDataFactory.createFishCatch(
          id: i + 1,
          species: 'Fish_$i',
          catchTime: DateTime(2024, 1, i + 1),
        ),);
      }

      const filter = FishFilter();

      final result = await repository.getFilteredPageByFilter(
        page: 1,
        pageSize: 10,
        filter: filter,
      );
      expect(result.items.length, equals(5));
      expect(result.hasMore, isFalse);
    });

    test('hasMore is false when totalCount equals pageSize', () async {
      for (var i = 0; i < 10; i++) {
        await repository.create(TestDataFactory.createFishCatch(
          id: i + 1,
          species: 'Fish_$i',
          catchTime: DateTime(2024, 1, i + 1),
        ),);
      }

      const filter = FishFilter();

      final result = await repository.getFilteredPageByFilter(
        page: 1,
        pageSize: 10,
        filter: filter,
      );
      expect(result.items.length, equals(10));
      expect(result.hasMore, isFalse);
    });
  });

  group('FishCatchRepository - getSoftWormRigAnalytics', () {
    late SqliteFishCatchRepository repository;

    setUp(() {
      repository = SqliteFishCatchRepository.withDatabase(
        Future<Database>.value(db),
      );
    });

    test('returns empty maps when no catches exist', () async {
      final result = await repository.getSoftWormRigAnalytics();

      expect(result['rigType'], isEmpty);
      expect(result['hookType'], isEmpty);
      expect(result['hookSize'], isEmpty);
      expect(result['hookWeight'], isEmpty);
    });

    test('returns empty maps when no soft worm lures exist', () async {
      final fish = TestDataFactory.createFishCatch(
        catchTime: DateTime(2024),
      );
      await repository.create(fish);

      final result = await repository.getSoftWormRigAnalytics();

      expect(result['rigType'], isEmpty);
      expect(result['hookType'], isEmpty);
    });

    test('returns correct analytics for catches with soft worm lures',
        () async {
      // Create equipment (soft worm lure)
      final softWormLure = Equipment.fromMap({
        ...TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.lure,
          brand: 'Brand',
          model: 'SoftWorm',
        ).toMap(),
        'lure_type': '软虫',
      });
      await db.insert('equipments', softWormLure.toMap()..remove('id'));

      // Create fish catch with rig details and link to lure
      final fish = TestDataFactory.createFishCatch(
        catchTime: DateTime(2024),
      ).copyWith(
        rigType: () => '卡罗莱纳',
        hookType: () => '曲柄钩',
        hookSize: () => '3/0',
        hookWeight: () => '5g',
      );
      final fishId = await repository.create(fish);

      // Update to link lure
      await db.update(
        'fish_catches',
        {'lure_id': 1},
        where: 'id = ?',
        whereArgs: [fishId],
      );

      final result = await repository.getSoftWormRigAnalytics();

      expect(result['rigType']!['卡罗莱纳'], equals(1));
      expect(result['hookType']!['曲柄钩'], equals(1));
      expect(result['hookSize']!['3/0'], equals(1));
      expect(result['hookWeight']!['5g'], equals(1));
    });

    test('aggregates multiple catches with same rig configuration', () async {
      // Create equipment (soft worm lure)
      final softWormLure = Equipment.fromMap({
        ...TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.lure,
          brand: 'Brand',
          model: 'SoftWorm',
        ).toMap(),
        'lure_type': '软虫',
      });
      await db.insert('equipments', softWormLure.toMap()..remove('id'));

      // Create multiple fish catches with same rig
      for (var i = 0; i < 3; i++) {
        final fish = TestDataFactory.createFishCatch(
          catchTime: DateTime(2024, 1, i + 1),
        ).copyWith(
          rigType: () => '卡罗莱纳',
          hookType: () => '曲柄钩',
        );
        final fishId = await repository.create(fish);
        await db.update(
          'fish_catches',
          {'lure_id': 1},
          where: 'id = ?',
          whereArgs: [fishId],
        );
      }

      final result = await repository.getSoftWormRigAnalytics();

      expect(result['rigType']!['卡罗莱纳'], equals(3));
      expect(result['hookType']!['曲柄钩'], equals(3));
    });

    test('ignores catches with null rig_type', () async {
      // Create equipment (soft worm lure)
      final softWormLure = Equipment.fromMap({
        ...TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.lure,
          brand: 'Brand',
          model: 'SoftWorm',
        ).toMap(),
        'lure_type': '软虫',
      });
      await db.insert('equipments', softWormLure.toMap()..remove('id'));

      // Create fish catch without rig type but with lure linked
      final fish = TestDataFactory.createFishCatch(
        catchTime: DateTime(2024),
      ).copyWith(
        rigType: () => null,
      );
      final fishId = await repository.create(fish);
      await db.update(
        'fish_catches',
        {'lure_id': 1},
        where: 'id = ?',
        whereArgs: [fishId],
      );

      final result = await repository.getSoftWormRigAnalytics();

      expect(result['rigType'], isEmpty);
    });

    test('ignores non-soft-worm lures', () async {
      // Create equipment (not a soft worm lure)
      final otherLure = Equipment.fromMap({
        ...TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.lure,
          brand: 'Brand',
          model: 'Crankbait',
        ).toMap(),
        'lure_type': 'crankbait',
      });
      await db.insert('equipments', otherLure.toMap()..remove('id'));

      // Create fish catch with rig details but non-soft-worm lure
      final fish = TestDataFactory.createFishCatch(
        catchTime: DateTime(2024),
      ).copyWith(
        rigType: () => '卡罗莱纳',
      );
      final fishId = await repository.create(fish);
      await db.update(
        'fish_catches',
        {'lure_id': 1},
        where: 'id = ?',
        whereArgs: [fishId],
      );

      final result = await repository.getSoftWormRigAnalytics();

      expect(result['rigType'], isEmpty);
    });
  });
}
