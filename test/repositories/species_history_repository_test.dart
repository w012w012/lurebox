import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lurebox/core/models/species_history.dart';
import 'package:lurebox/core/repositories/species_history_repository.dart';
import 'package:lurebox/core/repositories/species_history_repository_impl.dart';

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
          await db.execute('''
CREATE TABLE species_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  use_count INTEGER DEFAULT 1,
  is_deleted INTEGER DEFAULT 0,
  created_at TEXT NOT NULL
)
''');
          await db.execute(
              'CREATE INDEX idx_species_name ON species_history(name)');
          await db.execute(
              'CREATE INDEX idx_species_use_count ON species_history(use_count)');
        },
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('SpeciesHistoryRepository', () {
    late SqliteSpeciesHistoryRepository repository;

    setUp(() {
      repository = SqliteSpeciesHistoryRepository.withDatabase(
        Future<Database>.value(db),
      );
    });

    test('upsert creates new species with useCount=1', () async {
      await repository.upsert('Bass');

      final result = await repository.getByName('Bass');
      expect(result, isNotNull);
      expect(result!.name, equals('Bass'));
      expect(result.useCount, equals(1));
      expect(result.isDeleted, isFalse);
    });

    test('upsert updates existing species and increments useCount', () async {
      await repository.upsert('Bass');
      await repository.upsert('Bass');
      await repository.upsert('Bass');

      final result = await repository.getByName('Bass');
      expect(result, isNotNull);
      expect(result!.useCount, equals(3));
    });

    test('upsert restores soft-deleted species', () async {
      await repository.upsert('Bass');
      await repository.softDelete('Bass');
      await repository.upsert('Bass');

      final result = await repository.getByName('Bass');
      expect(result, isNotNull);
      expect(result!.isDeleted, isFalse);
      expect(result.useCount, equals(2));
    });

    test('incrementUseCount increases useCount by 1', () async {
      await repository.upsert('Bass');
      final initialCount = (await repository.getByName('Bass'))!.useCount;

      await repository.incrementUseCount('Bass');
      await repository.incrementUseCount('Bass');

      final result = await repository.getByName('Bass');
      expect(result!.useCount, equals(initialCount + 2));
    });

    test('incrementUseCount creates new species if not exists', () async {
      await repository.incrementUseCount('Trout');

      final result = await repository.getByName('Trout');
      expect(result, isNotNull);
      expect(result!.name, equals('Trout'));
      expect(result.useCount, equals(1));
    });

    test('softDelete marks species as deleted', () async {
      await repository.upsert('Bass');
      await repository.softDelete('Bass');

      // getByName does not filter by is_deleted, so it still returns the record
      final result = await repository.getByName('Bass');
      expect(result, isNotNull);
      expect(result!.isDeleted, isTrue);
    });

    test('softDelete does not affect exists check', () async {
      await repository.upsert('Bass');
      await repository.softDelete('Bass');

      final exists = await repository.exists('Bass');
      expect(exists, isFalse);
    });

    test('restore marks species as not deleted', () async {
      await repository.upsert('Bass');
      await repository.softDelete('Bass');
      await repository.restore('Bass');

      final result = await repository.getByName('Bass');
      expect(result, isNotNull);
      expect(result!.isDeleted, isFalse);
    });

    test('exists returns true for non-deleted species', () async {
      await repository.upsert('Bass');

      final exists = await repository.exists('Bass');
      expect(exists, isTrue);
    });

    test('exists returns false for non-existent species', () async {
      final exists = await repository.exists('NonExistent');
      expect(exists, isFalse);
    });

    test('exists returns false for soft-deleted species', () async {
      await repository.upsert('Bass');
      await repository.softDelete('Bass');

      final exists = await repository.exists('Bass');
      expect(exists, isFalse);
    });

    test('getCount returns correct count of non-deleted species', () async {
      await repository.upsert('Bass');
      await repository.upsert('Trout');
      await repository.upsert('Pike');

      final count = await repository.getCount();
      expect(count, equals(3));
    });

    test('getCount excludes soft-deleted species', () async {
      await repository.upsert('Bass');
      await repository.upsert('Trout');
      await repository.softDelete('Bass');

      final count = await repository.getCount();
      expect(count, equals(1));
    });

    test('getAll returns all non-deleted species by default', () async {
      await repository.upsert('Bass');
      await repository.upsert('Trout');
      await repository.softDelete('Bass');

      final results = await repository.getAll();

      expect(results.length, equals(1));
      expect(results.first.name, equals('Trout'));
    });

    test('getAll with includeDeleted returns all species', () async {
      await repository.upsert('Bass');
      await repository.upsert('Trout');
      await repository.softDelete('Bass');

      final results = await repository.getAll(includeDeleted: true);

      expect(results.length, equals(2));
    });

    test('getAll returns species ordered by useCount descending', () async {
      await repository.upsert('Bass');
      await repository.upsert('Trout');
      await repository.incrementUseCount('Trout');
      await repository.incrementUseCount('Trout');
      // Pike has useCount = 1 (created via increment on non-existent)
      await repository.incrementUseCount('Pike');

      final results = await repository.getAll();

      expect(results.length, equals(3));
      expect(results[0].name, equals('Trout')); // useCount = 3
      // Bass and Pike both have useCount = 1, order by created_at ASC
      expect(results[1].useCount, equals(1));
      expect(results[2].useCount, equals(1));
    });

    test('getAll respects limit parameter', () async {
      await repository.upsert('Bass');
      await repository.upsert('Trout');
      await repository.upsert('Pike');
      await repository.upsert('Walleye');

      final results = await repository.getAll(limit: 2);

      expect(results.length, equals(2));
    });

    test('getByName returns null for non-existent species', () async {
      final result = await repository.getByName('NonExistent');
      expect(result, isNull);
    });
  });

  group('SpeciesHistory model', () {
    test('fromMap creates correct instance', () {
      final map = {
        'id': 1,
        'name': 'Bass',
        'use_count': 5,
        'is_deleted': 0,
        'created_at': '2024-01-01T12:00:00.000',
      };

      final species = SpeciesHistory.fromMap(map);

      expect(species.id, equals(1));
      expect(species.name, equals('Bass'));
      expect(species.useCount, equals(5));
      expect(species.isDeleted, isFalse);
      expect(species.createdAt, equals(DateTime(2024, 1, 1, 12, 0, 0)));
    });

    test('fromMap handles null use_count defaulting to 1', () {
      final map = {
        'id': 1,
        'name': 'Bass',
        'use_count': null,
        'is_deleted': 0,
        'created_at': '2024-01-01T12:00:00.000',
      };

      final species = SpeciesHistory.fromMap(map);

      expect(species.useCount, equals(1));
    });

    test('fromMap handles is_deleted as 1', () {
      final map = {
        'id': 1,
        'name': 'Bass',
        'use_count': 5,
        'is_deleted': 1,
        'created_at': '2024-01-01T12:00:00.000',
      };

      final species = SpeciesHistory.fromMap(map);

      expect(species.isDeleted, isTrue);
    });

    test('toMap creates correct map', () {
      final species = SpeciesHistory(
        id: 1,
        name: 'Bass',
        useCount: 5,
        isDeleted: true,
        createdAt: DateTime(2024, 1, 1, 12, 0, 0),
      );

      final map = species.toMap();

      expect(map['id'], equals(1));
      expect(map['name'], equals('Bass'));
      expect(map['use_count'], equals(5));
      expect(map['is_deleted'], equals(1));
      expect(map['created_at'], equals('2024-01-01T12:00:00.000'));
    });

    test('copyWith creates modified copy', () {
      final original = SpeciesHistory(
        id: 1,
        name: 'Bass',
        useCount: 5,
        isDeleted: false,
        createdAt: DateTime(2024, 1, 1),
      );

      final copy = original.copyWith(useCount: 10);

      expect(copy.id, equals(1));
      expect(copy.name, equals('Bass'));
      expect(copy.useCount, equals(10));
      expect(copy.isDeleted, isFalse);
    });

    test('equality based on id', () {
      final species1 = SpeciesHistory(
        id: 1,
        name: 'Bass',
        useCount: 5,
        isDeleted: false,
        createdAt: DateTime(2024, 1, 1),
      );

      final species2 = SpeciesHistory(
        id: 1,
        name: 'Different Name',
        useCount: 10,
        isDeleted: true,
        createdAt: DateTime(2024, 2, 2),
      );

      expect(species1, equals(species2));
    });

    test('hashCode based on id', () {
      final species1 = SpeciesHistory(
        id: 1,
        name: 'Bass',
        useCount: 5,
        isDeleted: false,
        createdAt: DateTime(2024, 1, 1),
      );

      final species2 = SpeciesHistory(
        id: 1,
        name: 'Different Name',
        useCount: 10,
        isDeleted: true,
        createdAt: DateTime(2024, 2, 2),
      );

      expect(species1.hashCode, equals(species2.hashCode));
    });
  });
}
