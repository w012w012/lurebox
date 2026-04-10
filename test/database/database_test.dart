import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/database/database.dart';

void main() {
  group('DatabaseHelper', () {
    group('table name constants', () {
      test('tableFishCatches returns "fish_catches"', () {
        expect(DatabaseHelper.tableFishCatches, 'fish_catches');
      });

      test('tableEquipments returns "equipments"', () {
        expect(DatabaseHelper.tableEquipments, 'equipments');
      });

      test('tableSettings returns "settings"', () {
        expect(DatabaseHelper.tableSettings, 'settings');
      });

      test('tableSpeciesHistory returns "species_history"', () {
        expect(DatabaseHelper.tableSpeciesHistory, 'species_history');
      });

      test('tableCloudConfigs returns "cloud_configs"', () {
        expect(DatabaseHelper.tableCloudConfigs, 'cloud_configs');
      });

      test('tableBackupHistory returns "backup_history"', () {
        expect(DatabaseHelper.tableBackupHistory, 'backup_history');
      });

      test('tableFishSpecies returns "fish_species"', () {
        expect(DatabaseHelper.tableFishSpecies, 'fish_species');
      });

      test('tableUserSpeciesAlias returns "user_species_alias"', () {
        expect(DatabaseHelper.tableUserSpeciesAlias, 'user_species_alias');
      });
    });

    group('SQL helper methods', () {
      test('createFishCatchInsertSQL contains correct table name', () {
        final sql = DatabaseHelper.createFishCatchInsertSQL();
        expect(sql, contains(DatabaseHelper.tableFishCatches));
      });

      test('createFishCatchInsertSQL is a valid INSERT statement', () {
        final sql = DatabaseHelper.createFishCatchInsertSQL();
        expect(sql.toUpperCase().trim(), startsWith('INSERT INTO'));
      });

      test('createFishCatchSelectSQL contains correct table name', () {
        final sql = DatabaseHelper.createFishCatchSelectSQL();
        expect(sql, contains(DatabaseHelper.tableFishCatches));
      });

      test('createFishCatchSelectSQL is a valid SELECT statement', () {
        final sql = DatabaseHelper.createFishCatchSelectSQL();
        expect(sql.toUpperCase(), startsWith('SELECT * FROM'));
      });

      test('createEquipmentInsertSQL contains correct table name', () {
        final sql = DatabaseHelper.createEquipmentInsertSQL();
        expect(sql, contains(DatabaseHelper.tableEquipments));
      });

      test('createEquipmentInsertSQL is a valid INSERT statement', () {
        final sql = DatabaseHelper.createEquipmentInsertSQL();
        expect(sql.toUpperCase().trim(), startsWith('INSERT INTO'));
      });

      test('createSettingInsertSQL contains correct table name', () {
        final sql = DatabaseHelper.createSettingInsertSQL();
        expect(sql, contains(DatabaseHelper.tableSettings));
      });

      test('createSettingInsertSQL is a valid INSERT statement', () {
        final sql = DatabaseHelper.createSettingInsertSQL();
        expect(sql.toUpperCase().trim(), startsWith('INSERT INTO'));
      });

      test('createSpeciesHistoryInsertSQL contains correct table name', () {
        final sql = DatabaseHelper.createSpeciesHistoryInsertSQL();
        expect(sql, contains(DatabaseHelper.tableSpeciesHistory));
      });

      test('createSpeciesHistoryInsertSQL is a valid INSERT statement', () {
        final sql = DatabaseHelper.createSpeciesHistoryInsertSQL();
        expect(sql.toUpperCase().trim(), startsWith('INSERT INTO'));
      });

      test('currentTimestamp returns ISO 8601 format', () {
        final timestamp = DatabaseHelper.currentTimestamp();
        expect(timestamp, isNotEmpty);
        // Verify it's parseable as ISO 8601
        expect(() => DateTime.parse(timestamp), returnsNormally);
      });
    });

    group('SQL statements contain expected columns', () {
      test('createFishCatchInsertSQL contains species column', () {
        final sql = DatabaseHelper.createFishCatchInsertSQL();
        expect(sql.toLowerCase(), contains('species'));
      });

      test('createFishCatchInsertSQL contains length column', () {
        final sql = DatabaseHelper.createFishCatchInsertSQL();
        expect(sql.toLowerCase(), contains('length'));
      });

      test('createFishCatchInsertSQL contains catch_time column', () {
        final sql = DatabaseHelper.createFishCatchInsertSQL();
        expect(sql.toLowerCase(), contains('catch_time'));
      });

      test('createEquipmentInsertSQL contains type column', () {
        final sql = DatabaseHelper.createEquipmentInsertSQL();
        expect(sql.toLowerCase(), contains('type'));
      });

      test('createEquipmentInsertSQL contains brand column', () {
        final sql = DatabaseHelper.createEquipmentInsertSQL();
        expect(sql.toLowerCase(), contains('brand'));
      });
    });
  });
}
