import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/repositories/equipment_repository_impl.dart';
import '../helpers/test_helpers.dart';

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
        version: 22,
        onCreate: (db, version) async {
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
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('SqliteEquipmentRepository', () {
    late SqliteEquipmentRepository repository;

    setUp(() {
      repository = SqliteEquipmentRepository.withDatabase(
        Future<Database>.value(db),
      );
    });

    group('getAll', () {
      test('returns all non-deleted equipments', () async {
        final equipment1 = TestDataFactory.createEquipment(
          id: 1,
          type: EquipmentType.rod,
          brand: 'Brand1',
          model: 'Model1',
        );
        final equipment2 = TestDataFactory.createEquipment(
          id: 2,
          type: EquipmentType.reel,
          brand: 'Brand2',
          model: 'Model2',
        );

        await repository.create(equipment1);
        await repository.create(equipment2);

        final results = await repository.getAll();

        expect(results.length, equals(2));
      });

      test('excludes deleted equipments', () async {
        final equipment1 = TestDataFactory.createEquipment(
          id: 1,
          type: EquipmentType.rod,
          brand: 'Brand1',
          model: 'Model1',
        );
        final equipment2 = TestDataFactory.createEquipment(
          id: 2,
          type: EquipmentType.reel,
          brand: 'Brand2',
          model: 'Model2',
        );

        await repository.create(equipment1);
        await repository.create(equipment2);
        await repository.delete(1);

        final results = await repository.getAll();

        expect(results.length, equals(1));
        expect(results.first.id, equals(2));
      });

      test('filters by type when provided', () async {
        final rod = TestDataFactory.createEquipment(
          id: 1,
          type: EquipmentType.rod,
          brand: 'RodBrand',
          model: 'RodModel',
        );
        final reel = TestDataFactory.createEquipment(
          id: 2,
          type: EquipmentType.reel,
          brand: 'ReelBrand',
          model: 'ReelModel',
        );

        await repository.create(rod);
        await repository.create(reel);

        final results = await repository.getAll(type: 'rod');

        expect(results.length, equals(1));
        expect(results.first.type, equals(EquipmentType.rod));
      });

      test('returns empty list when no equipments exist', () async {
        final results = await repository.getAll();

        expect(results, isEmpty);
      });
    });

    group('getById', () {
      test('returns equipment when it exists', () async {
        final equipment = TestDataFactory.createEquipment(
          id: 1,
          type: EquipmentType.rod,
          brand: 'Brand1',
          model: 'Model1',
        );

        await repository.create(equipment);
        final result = await repository.getById(1);

        expect(result, isNotNull);
        expect(result!.id, equals(1));
        expect(result.brand, equals('Brand1'));
      });

      test('returns null when equipment does not exist', () async {
        final result = await repository.getById(9999);

        expect(result, isNull);
      });

      test('returns null for deleted equipment', () async {
        final equipment = TestDataFactory.createEquipment(
          id: 1,
          type: EquipmentType.rod,
          brand: 'Brand1',
          model: 'Model1',
        );

        await repository.create(equipment);
        await repository.delete(1);
        final result = await repository.getById(1);

        expect(result, isNull);
      });
    });

    group('create', () {
      test('inserts equipment and returns id', () async {
        final equipment = TestDataFactory.createEquipment(
          id: 0, // id will be auto-generated
          type: EquipmentType.rod,
          brand: 'Brand1',
          model: 'Model1',
        );

        final id = await repository.create(equipment);

        expect(id, greaterThan(0));
      });

      test('persists equipment to database', () async {
        final equipment = TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.reel,
          brand: 'Shimano',
          model: 'Stradic',
        );

        await repository.create(equipment);
        final result = await repository.getById(1);

        expect(result, isNotNull);
        expect(result!.brand, equals('Shimano'));
        expect(result.model, equals('Stradic'));
      });

      test('handles is_default flag correctly', () async {
        final defaultEquipment = Equipment.fromMap({
          ...TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            brand: 'Default',
            model: 'Rod',
          ).toMap(),
          'is_default': 1,
        });

        await repository.create(defaultEquipment);
        final result = await repository.getById(1);

        expect(result!.isDefault, isTrue);
      });
    });

    group('update', () {
      test('updates existing equipment', () async {
        final equipment = TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'OldBrand',
          model: 'OldModel',
        );

        await repository.create(equipment);
        final created = await repository.getById(1);

        final updated = Equipment.fromMap({
          ...created!.toMap(),
          'brand': 'NewBrand',
          'model': 'NewModel',
        });
        await repository.update(updated);

        final result = await repository.getById(1);
        expect(result!.brand, equals('NewBrand'));
        expect(result.model, equals('NewModel'));
      });

      test('preserves other fields when updating', () async {
        final equipment = TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Brand',
          model: 'Model',
        );

        await repository.create(equipment);
        final created = await repository.getById(1);

        final updated = Equipment.fromMap({
          ...created!.toMap(),
          'brand': 'NewBrand',
        });
        await repository.update(updated);

        final result = await repository.getById(1);
        expect(result!.brand, equals('NewBrand'));
        expect(result.model, equals('Model'));
      });
    });

    group('delete (soft delete)', () {
      test('sets is_deleted to 1', () async {
        final equipment = TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Brand1',
          model: 'Model1',
        );

        await repository.create(equipment);
        await repository.delete(1);

        // Verify soft delete by checking raw data
        final rawResults = await db.query(
          'equipments',
          where: 'id = ?',
          whereArgs: [1],
        );

        expect(rawResults.first['is_deleted'], equals(1));
      });

      test('excludes deleted equipment from getAll', () async {
        final equipment1 = TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Brand1',
          model: 'Model1',
        );
        final equipment2 = TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.reel,
          brand: 'Brand2',
          model: 'Model2',
        );

        await repository.create(equipment1);
        await repository.create(equipment2);
        await repository.delete(1);

        final results = await repository.getAll();
        expect(results.length, equals(1));
        expect(results.first.id, equals(2));
      });

      test('does not affect other equipments when deleting one', () async {
        final equipment1 = TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Brand1',
          model: 'Model1',
        );
        final equipment2 = TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.reel,
          brand: 'Brand2',
          model: 'Model2',
        );

        await repository.create(equipment1);
        await repository.create(equipment2);
        await repository.delete(1);

        final results = await repository.getAll();
        expect(results.length, equals(1));
        expect(results.first.id, equals(2));
      });
    });

    group('getDefaultEquipment', () {
      test('returns default equipment for type', () async {
        final rod = Equipment.fromMap({
          ...TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            brand: 'Rod',
            model: 'Model',
          ).toMap(),
          'is_default': 1,
        });

        await repository.create(rod);
        final result = await repository.getDefaultEquipment('rod');

        expect(result, isNotNull);
        expect(result!.type, equals(EquipmentType.rod));
        expect(result.isDefault, isTrue);
      });

      test('returns null when no default exists for type', () async {
        final result = await repository.getDefaultEquipment('rod');

        expect(result, isNull);
      });

      test('excludes deleted equipment from default search', () async {
        final rod = Equipment.fromMap({
          ...TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            brand: 'Rod',
            model: 'Model',
          ).toMap(),
          'is_default': 1,
        });

        await repository.create(rod);
        await repository.delete(1);

        final result = await repository.getDefaultEquipment('rod');
        expect(result, isNull);
      });
    });

    group('setDefaultEquipment', () {
      test('sets equipment as default for its type', () async {
        final rod1 = TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Rod1',
          model: 'Model1',
        );
        final rod2 = TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Rod2',
          model: 'Model2',
        );

        await repository.create(rod1);
        await repository.create(rod2);
        await repository.setDefaultEquipment(2, 'rod');

        final result = await repository.getDefaultEquipment('rod');
        expect(result!.id, equals(2));
      });

      test('only one default per type - clears other defaults', () async {
        final rod1 = Equipment.fromMap({
          ...TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            brand: 'Rod1',
            model: 'Model1',
          ).toMap(),
          'is_default': 1,
        });
        final rod2 = TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Rod2',
          model: 'Model2',
        );

        await repository.create(rod1);
        await repository.create(rod2);
        await repository.setDefaultEquipment(2, 'rod');

        // Rod1 should no longer be default
        final rod1Result = await repository.getById(1);
        expect(rod1Result!.isDefault, isFalse);
      });

      test('works independently for different types', () async {
        final rod = TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Rod',
          model: 'Model',
        );
        final reel = TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.reel,
          brand: 'Reel',
          model: 'Model',
        );

        await repository.create(rod);
        await repository.create(reel);
        await repository.setDefaultEquipment(1, 'rod');
        await repository.setDefaultEquipment(2, 'reel');

        final defaultRod = await repository.getDefaultEquipment('rod');
        final defaultReel = await repository.getDefaultEquipment('reel');

        expect(defaultRod!.id, equals(1));
        expect(defaultReel!.id, equals(2));
      });
    });

    group('getPage', () {
      test('returns paginated results', () async {
        for (int i = 0; i < 25; i++) {
          await repository.create(TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            brand: 'Brand$i',
            model: 'Model$i',
          ));
        }

        final result = await repository.getPage(page: 1, pageSize: 10);

        expect(result.items.length, equals(10));
        expect(result.totalCount, equals(25));
        expect(result.page, equals(1));
        expect(result.pageSize, equals(10));
        expect(result.hasMore, isTrue);
      });

      test('returns hasMore false when on last page', () async {
        for (int i = 0; i < 5; i++) {
          await repository.create(TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            brand: 'Brand$i',
            model: 'Model$i',
          ));
        }

        final result = await repository.getPage(page: 1, pageSize: 10);

        expect(result.items.length, equals(5));
        expect(result.hasMore, isFalse);
      });

      test('filters by type', () async {
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Rod',
          model: 'Model',
        ));
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.reel,
          brand: 'Reel',
          model: 'Model',
        ));

        final result = await repository.getPage(page: 1, type: 'rod');

        expect(result.items.length, equals(1));
        expect(result.items.first.type, equals(EquipmentType.rod));
      });

      test('respects custom orderBy', () async {
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'AAA',
          model: 'Model',
        ));
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'ZZZ',
          model: 'Model',
        ));

        final result = await repository.getPage(
          page: 1,
          orderBy: 'brand ASC',
        );

        expect(result.items.first.brand, equals('AAA'));
      });
    });

    group('getFilteredPage', () {
      test('filters by brand', () async {
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Shimano',
          model: 'Model1',
        ));
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Daiwa',
          model: 'Model2',
        ));

        final result = await repository.getFilteredPage(
          page: 1,
          brand: 'Shimano',
        );

        expect(result.items.length, equals(1));
        expect(result.items.first.brand, equals('Shimano'));
      });

      test('filters by model', () async {
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Brand',
          model: 'Tournament',
        ));
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Brand',
          model: 'Competitor',
        ));

        final result = await repository.getFilteredPage(
          page: 1,
          model: 'Tournament',
        );

        expect(result.items.length, equals(1));
        expect(result.items.first.model, equals('Tournament'));
      });

      test('filters by category', () async {
        await repository.create(Equipment.fromMap({
          ...TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            brand: 'Brand',
            model: 'Model',
          ).toMap(),
          'category': 'Spinning',
        }));
        await repository.create(Equipment.fromMap({
          ...TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            brand: 'Brand',
            model: 'Model',
          ).toMap(),
          'category': 'Casting',
        }));

        final result = await repository.getFilteredPage(
          page: 1,
          category: 'Spinning',
        );

        expect(result.items.length, equals(1));
        expect(result.items.first.category, equals('Spinning'));
      });

      test('combines multiple filters', () async {
        await repository.create(Equipment.fromMap({
          ...TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            brand: 'Shimano',
            model: 'Tournament',
          ).toMap(),
          'category': 'Spinning',
        }));
        await repository.create(Equipment.fromMap({
          ...TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            brand: 'Shimano',
            model: 'Competitor',
          ).toMap(),
          'category': 'Spinning',
        }));
        await repository.create(Equipment.fromMap({
          ...TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            brand: 'Daiwa',
            model: 'Tournament',
          ).toMap(),
          'category': 'Spinning',
        }));

        final result = await repository.getFilteredPage(
          page: 1,
          brand: 'Shimano',
          model: 'Tournament',
        );

        expect(result.items.length, equals(1));
        expect(result.items.first.brand, equals('Shimano'));
        expect(result.items.first.model, equals('Tournament'));
      });
    });

    group('getStats', () {
      test('returns count per type', () async {
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Brand',
          model: 'Model',
        ));
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Brand',
          model: 'Model',
        ));
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.reel,
          brand: 'Brand',
          model: 'Model',
        ));

        final stats = await repository.getStats();

        expect(stats['rod'], equals(2));
        expect(stats['reel'], equals(1));
      });

      test('excludes deleted equipment from stats', () async {
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Brand',
          model: 'Model',
        ));
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Brand',
          model: 'Model',
        ));
        await repository.delete(1);

        final stats = await repository.getStats();

        expect(stats['rod'], equals(1));
      });

      test('returns empty map when no equipments', () async {
        final stats = await repository.getStats();

        expect(stats, isEmpty);
      });
    });

    group('getBrands', () {
      test('returns distinct brands', () async {
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Shimano',
          model: 'Model1',
        ));
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.reel,
          brand: 'Shimano',
          model: 'Model2',
        ));
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Daiwa',
          model: 'Model3',
        ));

        final brands = await repository.getBrands();

        expect(brands.length, equals(2));
        expect(brands, containsAll(['Shimano', 'Daiwa']));
      });

      test('excludes deleted equipment', () async {
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Shimano',
          model: 'Model1',
        ));
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Daiwa',
          model: 'Model2',
        ));
        await repository.delete(2);

        final brands = await repository.getBrands();

        expect(brands, equals(['Shimano']));
      });

      test('excludes empty brands', () async {
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Shimano',
          model: 'Model1',
        ));
        await repository.create(Equipment.fromMap({
          ...TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            model: 'Model2',
          ).toMap(),
          'brand': null,
        }));

        final brands = await repository.getBrands();

        expect(brands, equals(['Shimano']));
      });

      test('returns sorted brands', () async {
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Zebra',
          model: 'Model',
        ));
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Alpha',
          model: 'Model',
        ));

        final brands = await repository.getBrands();

        expect(brands, equals(['Alpha', 'Zebra']));
      });
    });

    group('getModelsByBrand', () {
      test('returns models for specific brand', () async {
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Shimano',
          model: 'Stradic',
        ));
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Shimano',
          model: 'Sustainer',
        ));
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Daiwa',
          model: 'Certate',
        ));

        final models = await repository.getModelsByBrand('Shimano');

        expect(models.length, equals(2));
        expect(models, containsAll(['Stradic', 'Sustainer']));
      });

      test('excludes deleted equipment', () async {
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Shimano',
          model: 'Stradic',
        ));
        await repository.create(TestDataFactory.createEquipment(
          id: 0,
          type: EquipmentType.rod,
          brand: 'Shimano',
          model: 'Sustainer',
        ));
        await repository.delete(2);

        final models = await repository.getModelsByBrand('Shimano');

        expect(models, equals(['Stradic']));
      });

      test('returns empty list for non-existent brand', () async {
        final models = await repository.getModelsByBrand('NonExistent');

        expect(models, isEmpty);
      });
    });

    group('getCategoryDistribution', () {
      test('returns count per category for type', () async {
        await repository.create(Equipment.fromMap({
          ...TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            brand: 'Brand',
            model: 'Model',
          ).toMap(),
          'category': 'Spinning',
        }));
        await repository.create(Equipment.fromMap({
          ...TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            brand: 'Brand',
            model: 'Model',
          ).toMap(),
          'category': 'Spinning',
        }));
        await repository.create(Equipment.fromMap({
          ...TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            brand: 'Brand',
            model: 'Model',
          ).toMap(),
          'category': 'Casting',
        }));

        final distribution = await repository.getCategoryDistribution('rod');

        expect(distribution['Spinning'], equals(2));
        expect(distribution['Casting'], equals(1));
      });

      test('excludes deleted equipment', () async {
        await repository.create(Equipment.fromMap({
          ...TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            brand: 'Brand',
            model: 'Model',
          ).toMap(),
          'category': 'Spinning',
        }));
        await repository.create(Equipment.fromMap({
          ...TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            brand: 'Brand',
            model: 'Model',
          ).toMap(),
          'category': 'Spinning',
        }));
        await repository.delete(1);

        final distribution = await repository.getCategoryDistribution('rod');

        expect(distribution['Spinning'], equals(1));
      });

      test('returns empty map when no categories', () async {
        await repository.create(Equipment.fromMap({
          ...TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            brand: 'Brand',
            model: 'Model',
          ).toMap(),
          'category': null,
        }));

        final distribution = await repository.getCategoryDistribution('rod');

        expect(distribution, isEmpty);
      });

      test('returns sorted by count descending', () async {
        await repository.create(Equipment.fromMap({
          ...TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            brand: 'Brand',
            model: 'Model',
          ).toMap(),
          'category': 'Rare',
        }));
        await repository.create(Equipment.fromMap({
          ...TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            brand: 'Brand',
            model: 'Model',
          ).toMap(),
          'category': 'Common',
        }));
        await repository.create(Equipment.fromMap({
          ...TestDataFactory.createEquipment(
            id: 0,
            type: EquipmentType.rod,
            brand: 'Brand',
            model: 'Model',
          ).toMap(),
          'category': 'Common',
        }));

        final distribution = await repository.getCategoryDistribution('rod');

        final entries = distribution.entries.toList();
        expect(entries[0].key, equals('Common'));
        expect(entries[0].value, equals(2));
        expect(entries[1].key, equals('Rare'));
        expect(entries[1].value, equals(1));
      });
    });
  });

  group('Equipment model', () {
    test('fromMap creates correct instance', () {
      final now = DateTime.now();
      final map = {
        'id': 1,
        'type': 'rod',
        'brand': 'Shimano',
        'model': 'Stradic',
        'is_default': 1,
        'is_deleted': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final equipment = Equipment.fromMap(map);

      expect(equipment.id, equals(1));
      expect(equipment.type, equals(EquipmentType.rod));
      expect(equipment.brand, equals('Shimano'));
      expect(equipment.model, equals('Stradic'));
      expect(equipment.isDefault, isTrue);
      expect(equipment.isDeleted, isFalse);
    });

    test('toMap creates correct map', () {
      final now = DateTime.now();
      final equipment = Equipment(
        id: 1,
        type: EquipmentType.rod,
        brand: 'Shimano',
        model: 'Stradic',
        createdAt: now,
        updatedAt: now,
      );

      final map = equipment.toMap();

      expect(map['id'], equals(1));
      expect(map['type'], equals('rod'));
      expect(map['brand'], equals('Shimano'));
      expect(map['model'], equals('Stradic'));
      expect(map['is_default'], equals(0));
      expect(map['is_deleted'], equals(0));
    });

    test('copyWith creates modified copy', () {
      final now = DateTime.now();
      final original = Equipment(
        id: 1,
        type: EquipmentType.rod,
        brand: 'Shimano',
        model: 'Stradic',
        createdAt: now,
        updatedAt: now,
      );

      final copy = Equipment.fromMap({
        ...original.toMap(),
        'brand': 'Daiwa',
        'model': 'Certate',
      });

      expect(copy.id, equals(1));
      expect(copy.brand, equals('Daiwa'));
      expect(copy.model, equals('Certate'));
      expect(copy.type, equals(EquipmentType.rod));
    });

    test('equality based on id', () {
      final now = DateTime.now();
      final equipment1 = Equipment(
        id: 1,
        type: EquipmentType.rod,
        brand: 'Shimano',
        model: 'Stradic',
        createdAt: now,
        updatedAt: now,
      );

      final equipment2 = Equipment(
        id: 1,
        type: EquipmentType.reel,
        brand: 'Different',
        model: 'Model',
        createdAt: now,
        updatedAt: now,
      );

      expect(equipment1, equals(equipment2));
    });

    test('hashCode based on id', () {
      final now = DateTime.now();
      final equipment1 = Equipment(
        id: 1,
        type: EquipmentType.rod,
        brand: 'Shimano',
        model: 'Stradic',
        createdAt: now,
        updatedAt: now,
      );

      final equipment2 = Equipment(
        id: 1,
        type: EquipmentType.reel,
        brand: 'Different',
        model: 'Model',
        createdAt: now,
        updatedAt: now,
      );

      expect(equipment1.hashCode, equals(equipment2.hashCode));
    });

    test('displayName combines brand and model', () {
      final now = DateTime.now();
      final equipment = Equipment(
        id: 1,
        type: EquipmentType.rod,
        brand: 'Shimano',
        model: 'Stradic',
        createdAt: now,
        updatedAt: now,
      );

      expect(equipment.displayName, equals('Shimano Stradic'));
    });

    test('displayName returns type label when no brand/model', () {
      final now = DateTime.now();
      final equipment = Equipment(
        id: 1,
        type: EquipmentType.rod,
        createdAt: now,
        updatedAt: now,
      );

      expect(equipment.displayName, equals('鱼竿'));
    });
  });
}
