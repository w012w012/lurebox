import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lurebox/core/services/backup_service.dart';
import 'package:lurebox/core/database/database_provider.dart';

void main() {
  late Database db;
  late BackupService backupService;
  late _TestDatabaseProvider testDbProvider;

  setUpAll(() {
    // Initialize Flutter binding for path_provider
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock path_provider to return system temp directory
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return Directory.systemTemp.path;
        }
        return null;
      },
    );

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 22,
        onCreate: (db, version) async {
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

          // Species history table
          await db.execute('''
            CREATE TABLE species_history (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT UNIQUE NOT NULL,
              use_count INTEGER DEFAULT 1,
              is_deleted INTEGER DEFAULT 0,
              created_at TEXT NOT NULL
            )
          ''');

          // Settings table
          await db.execute('''
            CREATE TABLE settings (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              key TEXT UNIQUE NOT NULL,
              value TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');

          // Indexes
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

    // Create test database provider
    testDbProvider = _TestDatabaseProvider(db);
    backupService = BackupService(testDbProvider);
  });

  tearDown(() async {
    await db.close();
  });

  group('BackupService Integration - Full Round-trip', () {
    test('full round-trip: export then import preserves all data', () async {
      // Arrange - Create test data
      final now = DateTime.now();
      final catchTime = DateTime(2024, 6, 15, 10, 30);

      // Insert fish catches directly
      await db.insert('fish_catches', {
        'image_path': '/test/fish_1.jpg',
        'watermarked_image_path': '/test/fish_1_wm.jpg',
        'species': 'Bass',
        'length': 35.5,
        'length_unit': 'cm',
        'weight': 2.3,
        'weight_unit': 'kg',
        'fate': 0, // release
        'catch_time': catchTime.toIso8601String(),
        'location_name': 'Test Lake',
        'latitude': 35.6762,
        'longitude': 139.6503,
        'notes': 'Great catch!',
        'air_temperature': 25.0,
        'pressure': 1013.25,
        'weather_code': 800,
        'pending_recognition': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      await db.insert('fish_catches', {
        'image_path': '/test/fish_2.jpg',
        'species': 'Trout',
        'length': 28.0,
        'length_unit': 'cm',
        'fate': 1, // keep
        'catch_time': DateTime(2024, 6, 16).toIso8601String(),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      // Insert equipment directly
      await db.insert('equipments', {
        'type': 'rod',
        'brand': 'Shimano',
        'model': 'Expride',
        'rod_action': 'Fast',
        'rod_power': 'Medium',
        'length': '2.13',
        'length_unit': 'm',
        'price': 299.99,
        'is_default': 1,
        'is_deleted': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      await db.insert('equipments', {
        'type': 'reel',
        'brand': 'Abu Garcia',
        'model': 'Revo SX',
        'reel_ratio': '6.4:1',
        'reel_bearings': 8,
        'price': 199.99,
        'is_default': 0,
        'is_deleted': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      await db.insert('equipments', {
        'type': 'lure',
        'brand': 'Rapala',
        'model': 'X-Rap',
        'lure_type': 'Crankbait',
        'lure_weight': '12',
        'lure_weight_unit': 'g',
        'lure_color': 'Blue Fox',
        'lure_quantity': 3,
        'price': 15.99,
        'is_default': 0,
        'is_deleted': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      // Insert species history
      await db.insert('species_history', {
        'name': 'Bass',
        'use_count': 15,
        'is_deleted': 0,
        'created_at': now.toIso8601String(),
      });

      await db.insert('species_history', {
        'name': 'Trout',
        'use_count': 8,
        'is_deleted': 0,
        'created_at': now.toIso8601String(),
      });

      // Insert settings
      await db.insert('settings', {
        'key': 'theme',
        'value': 'dark',
        'updated_at': now.toIso8601String(),
      });

      await db.insert('settings', {
        'key': 'units_length',
        'value': 'cm',
        'updated_at': now.toIso8601String(),
      });

      await db.insert('settings', {
        'key': 'units_weight',
        'value': 'kg',
        'updated_at': now.toIso8601String(),
      });

      // Verify initial data
      expect((await db.query('fish_catches')).length, equals(2));
      expect((await db.query('equipments')).length, equals(3));
      expect((await db.query('species_history')).length, equals(2));
      expect((await db.query('settings')).length, equals(3));

      // Act - Export to JSON
      final exportPath = await backupService.exportToJson();

      // Read exported file
      final exportFile = File(exportPath);
      final exportContent = await exportFile.readAsString();
      final exportedData = jsonDecode(exportContent) as Map<String, dynamic>;

      // Verify exported data structure
      expect(exportedData['version'], equals(1));
      expect(exportedData.containsKey('exportTime'), isTrue);
      expect((exportedData['fishCatches'] as List).length, equals(2));
      expect((exportedData['equipments'] as List).length, equals(3));
      expect((exportedData['speciesHistory'] as List).length, equals(2));
      expect((exportedData['settings'] as List).length, equals(3));

      // Clear database
      await db.delete('fish_catches');
      await db.delete('equipments');
      await db.delete('species_history');
      await db.delete('settings');

      // Verify database is empty
      expect((await db.query('fish_catches')).length, equals(0));
      expect((await db.query('equipments')).length, equals(0));
      expect((await db.query('species_history')).length, equals(0));
      expect((await db.query('settings')).length, equals(0));

      // Import from JSON
      await backupService.importFromJson(exportPath);

      // Assert - Verify all data restored
      final restoredFishCatches = await db.query('fish_catches');
      final restoredEquipments = await db.query('equipments');
      final restoredSpeciesHistory = await db.query('species_history');
      final restoredSettings = await db.query('settings');

      expect(restoredFishCatches.length, equals(2));
      expect(restoredEquipments.length, equals(3));
      expect(restoredSpeciesHistory.length, equals(2));
      expect(restoredSettings.length, equals(3));

      // Verify fish catch data integrity
      final bassCatch = restoredFishCatches.firstWhere(
        (f) => f['species'] == 'Bass',
      );
      expect(bassCatch['image_path'], equals('/test/fish_1.jpg'));
      expect(bassCatch['length'], equals(35.5));
      expect(bassCatch['weight'], equals(2.3));
      expect(bassCatch['fate'], equals(0));
      expect(bassCatch['location_name'], equals('Test Lake'));
      expect(bassCatch['latitude'], equals(35.6762));
      expect(bassCatch['longitude'], equals(139.6503));
      expect(bassCatch['notes'], equals('Great catch!'));
      expect(bassCatch['air_temperature'], equals(25.0));
      expect(bassCatch['weather_code'], equals(800));

      // Verify equipment data integrity
      final rodEquipment = restoredEquipments.firstWhere(
        (e) => e['type'] == 'rod',
      );
      expect(rodEquipment['brand'], equals('Shimano'));
      expect(rodEquipment['model'], equals('Expride'));
      expect(rodEquipment['rod_action'], equals('Fast'));
      expect(rodEquipment['rod_power'], equals('Medium'));
      expect(rodEquipment['price'], equals(299.99));
      expect(rodEquipment['is_default'], equals(1));

      final reelEquipment = restoredEquipments.firstWhere(
        (e) => e['type'] == 'reel',
      );
      expect(reelEquipment['brand'], equals('Abu Garcia'));
      expect(reelEquipment['reel_ratio'], equals('6.4:1'));
      expect(reelEquipment['reel_bearings'], equals(8));

      final lureEquipment = restoredEquipments.firstWhere(
        (e) => e['type'] == 'lure',
      );
      expect(lureEquipment['brand'], equals('Rapala'));
      expect(lureEquipment['lure_type'], equals('Crankbait'));
      expect(lureEquipment['lure_quantity'], equals(3));

      // Verify species history
      final bassSpecies = restoredSpeciesHistory.firstWhere(
        (s) => s['name'] == 'Bass',
      );
      expect(bassSpecies['use_count'], equals(15));

      // Verify settings
      final themeSetting = restoredSettings.firstWhere(
        (s) => s['key'] == 'theme',
      );
      expect(themeSetting['value'], equals('dark'));

      // Cleanup
      await exportFile.delete();
    });

    test('fish catches round-trip preserves all fields', () async {
      // Arrange
      final catchTime = DateTime(2024, 7, 20, 14, 30);
      final now = DateTime.now();

      await db.insert('fish_catches', {
        'species': 'Pike',
        'length': 65.0,
        'length_unit': 'cm',
        'weight': 4.5,
        'weight_unit': 'kg',
        'fate': 1,
        'catch_time': catchTime.toIso8601String(),
        'location_name': 'Northern Lake',
        'latitude': 61.9241,
        'longitude': 25.7482,
        'notes': 'Huge pike!',
        'equipment_id': null,
        'rod_id': null,
        'reel_id': null,
        'lure_id': null,
        'air_temperature': 18.5,
        'pressure': 1005.0,
        'weather_code': 501,
        'pending_recognition': 0,
        'rig_type': 'Texas Rig',
        'sinker_weight': '1/2 oz',
        'sinker_position': 'Bottom',
        'hook_type': 'Offset Hook',
        'hook_size': '4/0',
        'hook_weight': '5g',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      // Act - Export
      final exportPath = await backupService.exportToJson();

      // Clear
      await db.delete('fish_catches');

      // Import
      await backupService.importFromJson(exportPath);

      // Assert
      final restored = await db.query('fish_catches');
      expect(restored.length, equals(1));

      final pike = restored.first;
      expect(pike['species'], equals('Pike'));
      expect(pike['length'], equals(65.0));
      expect(pike['weight'], equals(4.5));
      expect(pike['fate'], equals(1));
      expect(pike['location_name'], equals('Northern Lake'));
      expect(pike['latitude'], equals(61.9241));
      expect(pike['longitude'], equals(25.7482));
      expect(pike['notes'], equals('Huge pike!'));
      expect(pike['air_temperature'], equals(18.5));
      expect(pike['pressure'], equals(1005.0));
      expect(pike['weather_code'], equals(501));
      expect(pike['rig_type'], equals('Texas Rig'));
      expect(pike['sinker_weight'], equals('1/2 oz'));
      expect(pike['sinker_position'], equals('Bottom'));
      expect(pike['hook_type'], equals('Offset Hook'));
      expect(pike['hook_size'], equals('4/0'));
      expect(pike['hook_weight'], equals('5g'));

      // Cleanup
      await File(exportPath).delete();
    });

    test('equipment round-trip preserves all types', () async {
      // Arrange
      final now = DateTime.now();

      // Rod
      await db.insert('equipments', {
        'type': 'rod',
        'brand': 'Major Marine',
        'model': 'Sea Pro',
        'rod_action': 'Moderate Fast',
        'rod_power': 'Heavy',
        'rod_length': '2.7',
        'length_unit': 'm',
        'sections': '2',
        'joint_type': 'Unsplit',
        'material': 'Graphite',
        'hardness': 'Extra Heavy',
        'price': 599.99,
        'purchase_date': '2024-01-15',
        'is_default': 1,
        'is_deleted': 0,
        'category': 'spinning',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      // Reel
      await db.insert('equipments', {
        'type': 'reel',
        'brand': 'Daiwa',
        'model': 'Exist',
        'reel_size': '3000',
        'reel_ratio': '5.8:1',
        'reel_bearings': 12,
        'reel_capacity': '150m/0.32mm',
        'reel_brake_type': 'Magnetic',
        'reel_weight': '195',
        'reel_weight_unit': 'g',
        'reel_line': 'Power Pro',
        'reel_line_date': '2024-03-01',
        'reel_line_number': '30',
        'reel_line_length': '150',
        'line_length_unit': 'm',
        'line_weight_unit': 'lb',
        'price': 449.99,
        'purchase_date': '2024-02-20',
        'is_default': 0,
        'is_deleted': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      // Lure
      await db.insert('equipments', {
        'type': 'lure',
        'brand': 'Keitech',
        'model': 'Easy ShinER',
        'lure_type': 'Soft Plastic',
        'lure_weight': '3.5',
        'lure_weight_unit': 'g',
        'lure_size': '4',
        'lure_size_unit': 'inch',
        'lure_color': 'Motor Oil',
        'lure_quantity': 10,
        'lure_quantity_unit': 'pcs',
        'hardness': 'Medium',
        'price': 8.99,
        'is_default': 0,
        'is_deleted': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      // Act - Export
      final exportPath = await backupService.exportToJson();

      // Clear
      await db.delete('equipments');

      // Import
      await backupService.importFromJson(exportPath);

      // Assert
      final restored = await db.query('equipments');
      expect(restored.length, equals(3));

      final rod = restored.firstWhere((e) => e['type'] == 'rod');
      expect(rod['brand'], equals('Major Marine'));
      expect(rod['rod_action'], equals('Moderate Fast'));
      expect(rod['rod_power'], equals('Heavy'));
      expect(rod['rod_length'], equals('2.7'));
      expect(rod['sections'], equals('2'));
      expect(rod['joint_type'], equals('Unsplit'));
      expect(rod['material'], equals('Graphite'));
      expect(rod['hardness'], equals('Extra Heavy'));
      expect(rod['category'], equals('spinning'));
      expect(rod['price'], equals(599.99));
      expect(rod['is_default'], equals(1));

      final reel = restored.firstWhere((e) => e['type'] == 'reel');
      expect(reel['brand'], equals('Daiwa'));
      expect(reel['model'], equals('Exist'));
      expect(reel['reel_size'], equals('3000'));
      expect(reel['reel_ratio'], equals('5.8:1'));
      expect(reel['reel_bearings'], equals(12));
      expect(reel['reel_capacity'], equals('150m/0.32mm'));
      expect(reel['reel_brake_type'], equals('Magnetic'));
      expect(reel['reel_line'], equals('Power Pro'));
      expect(reel['reel_line_number'], equals('30'));

      final lure = restored.firstWhere((e) => e['type'] == 'lure');
      expect(lure['brand'], equals('Keitech'));
      expect(lure['lure_type'], equals('Soft Plastic'));
      expect(lure['lure_weight'], equals('3.5'));
      expect(lure['lure_size'], equals('4'));
      expect(lure['lure_color'], equals('Motor Oil'));
      expect(lure['lure_quantity'], equals(10));

      // Cleanup
      await File(exportPath).delete();
    });

    test('settings round-trip preserves data', () async {
      // Arrange
      final now = DateTime.now();

      await db.insert('settings', {
        'key': 'theme',
        'value': 'light',
        'updated_at': now.toIso8601String(),
      });

      await db.insert('settings', {
        'key': 'language',
        'value': 'zh_CN',
        'updated_at': now.toIso8601String(),
      });

      await db.insert('settings', {
        'key': 'units_length',
        'value': 'inch',
        'updated_at': now.toIso8601String(),
      });

      await db.insert('settings', {
        'key': 'units_weight',
        'value': 'lb',
        'updated_at': now.toIso8601String(),
      });

      await db.insert('settings', {
        'key': 'water_temperature_unit',
        'value': 'fahrenheit',
        'updated_at': now.toIso8601String(),
      });

      // Act - Export
      final exportPath = await backupService.exportToJson();

      // Clear
      await db.delete('settings');

      // Import
      await backupService.importFromJson(exportPath);

      // Assert
      final restored = await db.query('settings');
      expect(restored.length, equals(5));

      final theme = restored.firstWhere((s) => s['key'] == 'theme');
      expect(theme['value'], equals('light'));

      final lang = restored.firstWhere((s) => s['key'] == 'language');
      expect(lang['value'], equals('zh_CN'));

      final lengthUnit = restored.firstWhere((s) => s['key'] == 'units_length');
      expect(lengthUnit['value'], equals('inch'));

      final weightUnit = restored.firstWhere((s) => s['key'] == 'units_weight');
      expect(weightUnit['value'], equals('lb'));

      final tempUnit = restored.firstWhere(
        (s) => s['key'] == 'water_temperature_unit',
      );
      expect(tempUnit['value'], equals('fahrenheit'));

      // Cleanup
      await File(exportPath).delete();
    });

    test('partial import: only fishCatches imports correctly', () async {
      // Arrange - Create only fish catches data
      final now = DateTime.now();

      await db.insert('fish_catches', {
        'species': 'Walleye',
        'length': 45.0,
        'length_unit': 'cm',
        'fate': 0,
        'catch_time': DateTime(2024, 8, 1).toIso8601String(),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      // Also add equipment to verify it's not affected
      await db.insert('equipments', {
        'type': 'rod',
        'brand': 'Old Brand',
        'model': 'Old Model',
        'is_deleted': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      // Export
      final exportPath = await backupService.exportToJson();

      // Read and modify export to only have fishCatches
      final exportContent = await File(exportPath).readAsString();
      final exportedData = jsonDecode(exportContent) as Map<String, dynamic>;
      final partialData = {
        'version': 1,
        'exportTime': DateTime.now().toIso8601String(),
        'fishCatches': exportedData['fishCatches'],
        // No equipments, speciesHistory, or settings
      };
      final modifiedPath = exportPath.replaceAll('.json', '_partial.json');
      await File(modifiedPath).writeAsString(jsonEncode(partialData));

      // Clear database
      await db.delete('fish_catches');
      await db.delete('equipments');

      // Import partial backup
      await backupService.importFromJson(modifiedPath);

      // Assert - Only fish catches should be restored
      final fishCatches = await db.query('fish_catches');
      final equipments = await db.query('equipments');

      expect(fishCatches.length, equals(1));
      expect(fishCatches.first['species'], equals('Walleye'));
      expect(
          equipments.length, equals(0)); // Equipment was not in partial backup

      // Cleanup
      await File(exportPath).delete();
      await File(modifiedPath).delete();
    });

    test('invalid JSON parsing throws FormatException', () async {
      // Arrange - invalid JSON content
      const invalidJson = 'not even json';

      // Act & Assert - jsonDecode should throw FormatException for invalid JSON
      expect(
        () => jsonDecode(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('non-existent file throws exception', () async {
      // Act & Assert
      expect(
        () => backupService.importFromJson('/non/existent/path/backup.json'),
        throwsA(isA<Exception>()),
      );
    });

    test('empty database export produces valid JSON with empty arrays',
        () async {
      // Act
      final exportPath = await backupService.exportToJson();

      // Read and parse
      final exportContent = await File(exportPath).readAsString();
      final data = jsonDecode(exportContent) as Map<String, dynamic>;

      // Assert structure
      expect(data['version'], equals(1));
      expect(data.containsKey('exportTime'), isTrue);
      expect(data['fishCatches'], isEmpty);
      expect(data['equipments'], isEmpty);
      expect(data['speciesHistory'], isEmpty);
      expect(data['settings'], isEmpty);

      // Cleanup
      await File(exportPath).delete();
    });

    test('multiple fish catches with different fates round-trip correctly',
        () async {
      // Arrange
      final now = DateTime.now();

      // Release catch
      await db.insert('fish_catches', {
        'species': 'Bass',
        'length': 30.0,
        'length_unit': 'cm',
        'fate': 0, // release
        'catch_time': DateTime(2024, 9, 1).toIso8601String(),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      // Keep catch
      await db.insert('fish_catches', {
        'species': 'Catfish',
        'length': 55.0,
        'length_unit': 'cm',
        'weight': 3.5,
        'weight_unit': 'kg',
        'fate': 1, // keep
        'catch_time': DateTime(2024, 9, 2).toIso8601String(),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      // Act - Export
      final exportPath = await backupService.exportToJson();

      // Clear
      await db.delete('fish_catches');

      // Import
      await backupService.importFromJson(exportPath);

      // Assert
      final restored = await db.query('fish_catches');
      expect(restored.length, equals(2));

      final releaseFish = restored.firstWhere((f) => f['fate'] == 0);
      expect(releaseFish['species'], equals('Bass'));
      expect(releaseFish['fate'], equals(0));

      final keepFish = restored.firstWhere((f) => f['fate'] == 1);
      expect(keepFish['species'], equals('Catfish'));
      expect(keepFish['fate'], equals(1));
      expect(keepFish['weight'], equals(3.5));

      // Cleanup
      await File(exportPath).delete();
    });

    test('equipment with null optional fields round-trips correctly', () async {
      // Arrange - Equipment with many null fields
      final now = DateTime.now();

      await db.insert('equipments', {
        'type': 'rod',
        'brand': null,
        'model': null,
        'length': null,
        'length_unit': 'm',
        'sections': null,
        'joint_type': null,
        'material': null,
        'hardness': null,
        'price': null,
        'purchase_date': null,
        'is_default': 0,
        'is_deleted': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      // Act - Export
      final exportPath = await backupService.exportToJson();

      // Clear
      await db.delete('equipments');

      // Import
      await backupService.importFromJson(exportPath);

      // Assert
      final restored = await db.query('equipments');
      expect(restored.length, equals(1));

      final rod = restored.first;
      expect(rod['type'], equals('rod'));
      expect(rod['brand'], isNull);
      expect(rod['model'], isNull);
      expect(rod['price'], isNull);

      // Cleanup
      await File(exportPath).delete();
    });
  });
}

/// Test DatabaseProvider that wraps a real Database instance
class _TestDatabaseProvider implements DatabaseProvider {
  final Database _database;

  _TestDatabaseProvider(this._database);

  @override
  Future<Database> get database async => _database;

  @override
  Future<void> close() async {
    await _database.close();
  }

  @override
  Future<void> resetForTesting() async {
    // No-op for integration tests
  }
}
