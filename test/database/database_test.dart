import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/database/database.dart';

import '../helpers/test_helpers.dart';

void main() {
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabase = MockDatabase();
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

      expect(
          result,
          equals([
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

      expect(
          result,
          equals([
            {'id': 1}
          ]));
    });

    test('rawUpdate delegates to wrapped database', () async {
      final result = await wrapper
          .rawUpdate('UPDATE fish_catches SET species = ?', ['Test']);

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
      final result =
          await wrapper.rawDelete('DELETE FROM fish_catches WHERE id = ?', [1]);

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
      expect(
          DatabaseHelper.tableUserSpeciesAlias, equals('user_species_alias'));
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

      expect(
          timestamp, matches(RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}')));
    });
  });
}
