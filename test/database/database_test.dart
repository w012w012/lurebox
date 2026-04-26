import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/database/database.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Database;

import '../helpers/test_helpers.dart';

void main() {
  late MockDatabase mockDatabase;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockDatabase = MockDatabase();
    mockDatabase.reset();
  });

  group('Database interface', () {
    group('query', () {
      test('returns stored results for a table', () async {
        final fishRecords = [
          {'id': 1, 'species': 'Bass', 'length': 30.0},
          {'id': 2, 'species': 'Trout', 'length': 25.0},
        ];
        mockDatabase.addQueryResult('fish_catches', fishRecords);

        final result = await mockDatabase.query('fish_catches');

        expect(result, equals(fishRecords));
      });

      test('returns empty list when no data stored', () async {
        final result = await mockDatabase.query('empty_table');

        expect(result, isEmpty);
      });

      test('query with where clause', () async {
        final records = [
          {'id': 1, 'species': 'Bass'},
        ];
        mockDatabase.addQueryResult('fish_catches', records);

        final result = await mockDatabase.query(
          'fish_catches',
          where: 'species = ?',
          whereArgs: ['Bass'],
        );

        expect(result, equals(records));
      });

      test('query with orderBy and limit', () async {
        final records = [
          {'id': 1, 'catch_time': '2024-01-01'},
          {'id': 2, 'catch_time': '2024-01-02'},
        ];
        mockDatabase.addQueryResult('fish_catches', records);

        final result = await mockDatabase.query(
          'fish_catches',
          orderBy: 'catch_time DESC',
          limit: 10,
        );

        expect(result, equals(records));
      });
    });

    group('insert', () {
      test('stores record and returns id', () async {
        final values = {'species': 'Bass', 'length': 30.0};

        final id = await mockDatabase.insert('fish_catches', values);

        expect(id, equals(1));
        final inserted = mockDatabase.getInsertedRecords();
        expect(inserted.length, equals(1));
        expect(inserted.first['species'], equals('Bass'));
      });

      test('increments id for multiple inserts', () async {
        await mockDatabase.insert('fish_catches', {'species': 'Bass'});
        final id2 = await mockDatabase.insert('fish_catches', {'species': 'Trout'});

        expect(id2, equals(2));
      });

      test('insert stores all fields', () async {
        final values = {
          'species': 'Pike',
          'length': 45.0,
          'weight': 2.5,
          'location_name': 'Lake Test',
        };

        await mockDatabase.insert('fish_catches', values);

        final inserted = mockDatabase.getInsertedRecords();
        expect(inserted.first['species'], equals('Pike'));
        expect(inserted.first['length'], equals(45.0));
        expect(inserted.first['weight'], equals(2.5));
        expect(inserted.first['location_name'], equals('Lake Test'));
      });
    });

    group('update', () {
      test('returns affected row count', () async {
        final result = await mockDatabase.update(
          'fish_catches',
          {'species': 'Updated'},
          where: 'id = ?',
          whereArgs: [1],
        );

        expect(result, equals(1));
      });

      test('update without where clause', () async {
        final result = await mockDatabase.update(
          'fish_catches',
          {'is_deleted': true},
        );

        expect(result, equals(1));
      });
    });

    group('delete', () {
      test('returns affected row count', () async {
        final result = await mockDatabase.delete(
          'fish_catches',
          where: 'id = ?',
          whereArgs: [1],
        );

        expect(result, equals(1));
      });

      test('delete without where clause', () async {
        final result = await mockDatabase.delete('fish_catches');

        expect(result, equals(1));
      });
    });

    group('rawQuery', () {
      test('returns stored results for SQL', () async {
        final records = [
          {'id': 1, 'name': 'Bass'},
          {'id': 2, 'name': 'Trout'},
        ];
        mockDatabase.addQueryResult('SELECT * FROM fish_catches', records);

        final result = await mockDatabase.rawQuery(
          'SELECT * FROM fish_catches',
        );

        expect(result, equals(records));
      });

      test('returns empty list for unknown SQL', () async {
        final result = await mockDatabase.rawQuery(
          'SELECT * FROM unknown_table',
        );

        expect(result, isEmpty);
      });

      test('rawQuery with arguments', () async {
        final records = [{'id': 1}];
        mockDatabase.addQueryResult('SELECT * FROM fish_catches WHERE id = ?', records);

        final result = await mockDatabase.rawQuery(
          'SELECT * FROM fish_catches WHERE id = ?',
          [1],
        );

        expect(result, equals(records));
      });
    });

    group('rawUpdate', () {
      test('returns affected row count', () async {
        final result = await mockDatabase.rawUpdate(
          'UPDATE fish_catches SET species = ? WHERE id = ?',
          ['Updated', 1],
        );

        expect(result, equals(1));
      });
    });

    group('rawInsert', () {
      test('returns affected row count', () async {
        final result = await mockDatabase.rawInsert(
          'INSERT INTO fish_catches (species) VALUES (?)',
          ['Bass'],
        );

        expect(result, equals(1));
      });
    });

    group('rawDelete', () {
      test('returns affected row count', () async {
        final result = await mockDatabase.rawDelete(
          'DELETE FROM fish_catches WHERE id = ?',
          [1],
        );

        expect(result, equals(1));
      });
    });

    group('transaction', () {
      test('executes action and returns result', () async {
        // Note: _MockTransaction.insert returns List<dynamic> instead of int,
        // so we test with a simple return value that doesn't use Transaction methods
        final result = await mockDatabase.transaction((txn) async {
          return 42;
        });

        expect(result, equals(42));
      });
    });

    group('close', () {
      test('completes without error', () async {
        await mockDatabase.close();
        // No exception means success
        expect(true, isTrue);
      });
    });

    group('execute', () {
      test('completes without error', () async {
        await mockDatabase.execute('CREATE TABLE IF NOT EXISTS test (id INTEGER)');
        // No exception means success
        expect(true, isTrue);
      });
    });
  });

  group('DatabaseWrapper', () {
    late DatabaseWrapper wrapper;

    setUp(() {
      wrapper = DatabaseWrapper(mockDatabase);
    });

    test('query delegates to wrapped database', () async {
      mockDatabase.addQueryResult('fish_catches', [
        {'id': 1, 'species': 'Bass'},
      ]);

      final result = await wrapper.query('fish_catches');

      expect(result, equals([
        {'id': 1, 'species': 'Bass'},
      ]));
    });

    test('insert delegates to wrapped database', () async {
      final id = await wrapper.insert('fish_catches', {'species': 'Trout'});

      expect(id, equals(1));
    });

    test('update delegates to wrapped database', () async {
      final count = await wrapper.update(
        'fish_catches',
        {'species': 'Updated'},
        where: 'id = ?',
        whereArgs: [1],
      );

      expect(count, equals(1));
    });

    test('delete delegates to wrapped database', () async {
      final count = await wrapper.delete(
        'fish_catches',
        where: 'id = ?',
        whereArgs: [1],
      );

      expect(count, equals(1));
    });

    test('rawQuery delegates to wrapped database', () async {
      mockDatabase.addQueryResult('SELECT * FROM fish_catches', [
        {'id': 1},
      ]);

      final result = await wrapper.rawQuery('SELECT * FROM fish_catches');

      expect(result, equals([{'id': 1}]));
    });

    test('rawUpdate delegates to wrapped database', () async {
      final result = await wrapper.rawUpdate('UPDATE fish_catches SET species = ?', ['Test']);

      expect(result, equals(1));
    });

    test('rawInsert delegates to wrapped database', () async {
      final result = await wrapper.rawInsert(
        'INSERT INTO fish_catches (species) VALUES (?)',
        ['Test'],
      );

      expect(result, equals(1));
    });

    test('rawDelete delegates to wrapped database', () async {
      final result = await wrapper.rawDelete('DELETE FROM fish_catches WHERE id = ?', [1]);

      expect(result, equals(1));
    });

    test('transaction delegates to wrapped database', () async {
      final result = await wrapper.transaction((txn) async => 'done');

      expect(result, equals('done'));
    });

    test('close delegates to wrapped database', () async {
      await wrapper.close();
      expect(true, isTrue);
    });

    test('execute delegates to wrapped database', () async {
      await wrapper.execute('CREATE TABLE test (id INTEGER)');
      expect(true, isTrue);
    });
  });

  group('DatabaseHelper', () {
    test('table constants are defined', () {
      expect(DatabaseHelper.tableFishCatches, equals('fish_catches'));
      expect(DatabaseHelper.tableEquipments, equals('equipments'));
      expect(DatabaseHelper.tableSettings, equals('settings'));
      expect(DatabaseHelper.tableSpeciesHistory, equals('species_history'));
      expect(DatabaseHelper.tableCloudConfigs, equals('cloud_configs'));
      expect(DatabaseHelper.tableBackupHistory, equals('backup_history'));
      expect(DatabaseHelper.tableFishSpecies, equals('fish_species'));
      expect(DatabaseHelper.tableUserSpeciesAlias, equals('user_species_alias'));
    });

    test('createFishCatchInsertSQL returns valid SQL', () {
      final sql = DatabaseHelper.createFishCatchInsertSQL();

      expect(sql, contains("INSERT INTO fish_catches"));
      expect(sql, contains("image_path"));
      expect(sql, contains("species"));
      expect(sql, contains("length"));
    });

    test('createFishCatchSelectSQL returns valid SQL', () {
      final sql = DatabaseHelper.createFishCatchSelectSQL();

      expect(sql, equals('SELECT * FROM fish_catches'));
    });

    test('createEquipmentInsertSQL returns valid SQL', () {
      final sql = DatabaseHelper.createEquipmentInsertSQL();

      expect(sql, contains('INSERT INTO equipments'));
    });

    test('createSettingInsertSQL returns valid SQL', () {
      final sql = DatabaseHelper.createSettingInsertSQL();

      expect(sql, contains("INSERT INTO settings"));
      expect(sql, contains("key"));
      expect(sql, contains("value"));
    });

    test('createSpeciesHistoryInsertSQL returns valid SQL', () {
      final sql = DatabaseHelper.createSpeciesHistoryInsertSQL();

      expect(sql, contains('INSERT INTO species_history'));
    });

    test('currentTimestamp returns ISO 8601 format', () {
      final timestamp = DatabaseHelper.currentTimestamp();

      expect(timestamp, matches(RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}')));
    });
  });
}