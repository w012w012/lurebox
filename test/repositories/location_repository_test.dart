import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/location_models.dart';
import 'package:lurebox/core/repositories/location_repository.dart';
import 'package:lurebox/core/repositories/location_repository_impl.dart';

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
          // Create fish_catches table
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
              catch_time INTEGER NOT NULL,
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
              updated_at TEXT NOT NULL
            )
          ''');
        },
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('SqliteLocationRepository', () {
    late SqliteLocationRepository repository;

    setUp(() {
      repository = SqliteLocationRepository.withDatabase(
        Future<Database>.value(db),
      );
    });

    group('getAllWithStats', () {
      test('returns empty list when no fish catches exist', () async {
        final results = await repository.getAllWithStats();

        expect(results, isEmpty);
      });

      test('returns locations with fish counts', () async {
        await _insertFishCatch(db,
            locationName: 'Location A',
            latitude: 35.0,
            longitude: 139.0,
            species: 'Bass');
        await _insertFishCatch(db,
            locationName: 'Location A',
            latitude: 35.0,
            longitude: 139.0,
            species: 'Trout');
        await _insertFishCatch(db,
            locationName: 'Location B',
            latitude: 36.0,
            longitude: 140.0,
            species: 'Bass');

        final results = await repository.getAllWithStats();

        expect(results.length, equals(2));
        // Ordered by fish_count DESC
        expect(results.first.name, equals('Location A'));
        expect(results.first.fishCount, equals(2));
        expect(results.last.name, equals('Location B'));
        expect(results.last.fishCount, equals(1));
      });

      test('ignores fish catches without location', () async {
        await _insertFishCatch(db,
            locationName: null, latitude: null, longitude: null);
        await _insertFishCatch(db,
            locationName: '', latitude: null, longitude: null);
        await _insertFishCatch(db,
            locationName: 'Valid Location', latitude: 35.0, longitude: 139.0);

        final results = await repository.getAllWithStats();

        expect(results.length, equals(1));
        expect(results.first.name, equals('Valid Location'));
      });

      test('includes last catch time', () async {
        final time1 = DateTime(2024, 1, 1);
        final time2 = DateTime(2024, 1, 2);

        await _insertFishCatch(db,
            locationName: 'Location A',
            latitude: 35.0,
            longitude: 139.0,
            catchTime: time1);
        await _insertFishCatch(db,
            locationName: 'Location A',
            latitude: 35.0,
            longitude: 139.0,
            catchTime: time2);

        final results = await repository.getAllWithStats();

        expect(results.first.lastCatchTime, equals(time2));
      });
    });

    group('getFishCountByCoordinates', () {
      test('returns 0 when no catches at coordinates', () async {
        final count = await repository.getFishCountByCoordinates(
          latitude: 35.0,
          longitude: 139.0,
        );

        expect(count, equals(0));
      });

      test('returns count of catches within tolerance', () async {
        // Insert catch at exactly 35.0, 139.0
        await _insertFishCatch(db, latitude: 35.0, longitude: 139.0);

        // These should be within default tolerance of 0.001
        await _insertFishCatch(db, latitude: 35.0005, longitude: 139.0005);
        await _insertFishCatch(db, latitude: 35.0005, longitude: 139.0005);

        // This should be outside tolerance
        await _insertFishCatch(db, latitude: 35.01, longitude: 139.0);

        final count = await repository.getFishCountByCoordinates(
          latitude: 35.0,
          longitude: 139.0,
        );

        expect(count, equals(3));
      });

      test('respects custom tolerance', () async {
        await _insertFishCatch(db, latitude: 35.0, longitude: 139.0);
        await _insertFishCatch(db, latitude: 35.002, longitude: 139.0);

        // With tolerance 0.001, second one should be outside
        var count = await repository.getFishCountByCoordinates(
          latitude: 35.0,
          longitude: 139.0,
          tolerance: 0.001,
        );
        expect(count, equals(1));

        // With tolerance 0.003, both should be inside
        count = await repository.getFishCountByCoordinates(
          latitude: 35.0,
          longitude: 139.0,
          tolerance: 0.003,
        );
        expect(count, equals(2));
      });
    });

    group('getNearby', () {
      test('returns empty list when no catches exist', () async {
        final results = await repository.getNearby(
          latitude: 35.0,
          longitude: 139.0,
          radiusKm: 10.0,
        );

        expect(results, isEmpty);
      });

      test('returns locations within radius', () async {
        // Location A: ~1km away (roughly 0.009 degrees)
        await _insertFishCatch(db,
            locationName: 'Location A', latitude: 35.009, longitude: 139.0);
        await _insertFishCatch(db,
            locationName: 'Location A', latitude: 35.009, longitude: 139.0);

        // Location B: ~50km away (roughly 0.45 degrees)
        await _insertFishCatch(db,
            locationName: 'Location B', latitude: 35.45, longitude: 139.0);

        // Location C: ~100km away (roughly 0.9 degrees)
        await _insertFishCatch(db,
            locationName: 'Location C', latitude: 35.9, longitude: 139.0);

        final results = await repository.getNearby(
          latitude: 35.0,
          longitude: 139.0,
          radiusKm: 10.0, // ~10km radius = ~0.09 degrees
        );

        expect(results.length, equals(1));
        expect(results.first.name, equals('Location A'));
        expect(results.first.fishCount, equals(2));
      });

      test('excludes locations outside radius', () async {
        // Insert catch at location that would be outside 5km radius
        await _insertFishCatch(db,
            locationName: 'Far Location', latitude: 35.1, longitude: 139.0);

        final results = await repository.getNearby(
          latitude: 35.0,
          longitude: 139.0,
          radiusKm: 5.0,
        );

        expect(results, isEmpty);
      });

      test('calculates distance correctly using 111km per degree', () async {
        // A location ~111km away (exactly 1 degree)
        await _insertFishCatch(db,
            locationName: 'Distant Location', latitude: 36.0, longitude: 139.0);

        // Should be outside 100km radius
        var results = await repository.getNearby(
          latitude: 35.0,
          longitude: 139.0,
          radiusKm: 100.0,
        );
        expect(results, isEmpty);

        // Should be inside 200km radius
        results = await repository.getNearby(
          latitude: 35.0,
          longitude: 139.0,
          radiusKm: 200.0,
        );
        expect(results.length, equals(1));
      });
    });

    group('mergeLocations', () {
      test('updates source location to target location', () async {
        await _insertFishCatch(db,
            locationName: 'Source Location', latitude: 35.0, longitude: 139.0);
        await _insertFishCatch(db,
            locationName: 'Source Location', latitude: 35.0, longitude: 139.0);

        const source = LocationWithStats(
          name: 'Source Location',
          latitude: 35.0,
          longitude: 139.0,
          fishCount: 2,
        );
        const target = LocationWithStats(
          name: 'Target Location',
          latitude: 36.0,
          longitude: 140.0,
          fishCount: 1,
        );

        await repository.mergeLocations(source: source, target: target);

        // Verify source catches now have target location
        final results = await db.query(
          'fish_catches',
          where: 'location_name = ?',
          whereArgs: ['Target Location'],
        );
        expect(results.length, equals(2));
      });

      test('only updates catches matching exact source location', () async {
        await _insertFishCatch(db,
            locationName: 'Source Location', latitude: 35.0, longitude: 139.0);
        await _insertFishCatch(db,
            locationName: 'Source Location', latitude: 35.0, longitude: 139.0);
        await _insertFishCatch(db,
            locationName: 'Other Location', latitude: 35.0, longitude: 139.0);

        const source = LocationWithStats(
          name: 'Source Location',
          latitude: 35.0,
          longitude: 139.0,
          fishCount: 2,
        );
        const target = LocationWithStats(
          name: 'Target Location',
          latitude: 36.0,
          longitude: 140.0,
          fishCount: 1,
        );

        await repository.mergeLocations(source: source, target: target);

        // Verify 'Source Location' records were merged (0 remain)
        final sourceResults = await db.query(
          'fish_catches',
          where: 'location_name = ?',
          whereArgs: ['Source Location'],
        );
        expect(sourceResults.length, equals(0));

        // Verify 'Other Location' remains unchanged (different location_name)
        final otherResults = await db.query(
          'fish_catches',
          where: 'location_name = ?',
          whereArgs: ['Other Location'],
        );
        expect(otherResults.length, equals(1));
        expect(otherResults.first['latitude'], equals(35.0));
        expect(otherResults.first['longitude'], equals(139.0));

        // Verify merged records at target location
        final targetResults = await db.query(
          'fish_catches',
          where: 'location_name = ?',
          whereArgs: ['Target Location'],
        );
        expect(targetResults.length, equals(2));
      });
    });

    group('getStats', () {
      test('returns null for non-existent location', () async {
        final stats = await repository.getStats('Non-existent Location');

        expect(stats, isNull);
      });

      test('returns correct total catches', () async {
        await _insertFishCatch(db,
            locationName: 'Test Location', latitude: 35.0, longitude: 139.0);
        await _insertFishCatch(db,
            locationName: 'Test Location', latitude: 35.0, longitude: 139.0);
        await _insertFishCatch(db,
            locationName: 'Test Location', latitude: 35.0, longitude: 139.0);

        final stats = await repository.getStats('Test Location');

        expect(stats, isNotNull);
        expect(stats!.totalCatches, equals(3));
      });

      test('returns correct release and keep counts', () async {
        await _insertFishCatch(db,
            locationName: 'Test Location',
            latitude: 35.0,
            longitude: 139.0,
            fate: FishFateType.release);
        await _insertFishCatch(db,
            locationName: 'Test Location',
            latitude: 35.0,
            longitude: 139.0,
            fate: FishFateType.release);
        await _insertFishCatch(db,
            locationName: 'Test Location',
            latitude: 35.0,
            longitude: 139.0,
            fate: FishFateType.keep);

        final stats = await repository.getStats('Test Location');

        expect(stats!.releaseCount, equals(2));
        expect(stats.keepCount, equals(1));
      });

      test('returns correct species distribution', () async {
        await _insertFishCatch(db,
            locationName: 'Test Location',
            latitude: 35.0,
            longitude: 139.0,
            species: 'Bass');
        await _insertFishCatch(db,
            locationName: 'Test Location',
            latitude: 35.0,
            longitude: 139.0,
            species: 'Bass');
        await _insertFishCatch(db,
            locationName: 'Test Location',
            latitude: 35.0,
            longitude: 139.0,
            species: 'Trout');

        final stats = await repository.getStats('Test Location');

        expect(stats!.speciesDistribution['Bass'], equals(2));
        expect(stats.speciesDistribution['Trout'], equals(1));
      });

      test('returns correct average length and weight', () async {
        await _insertFishCatch(db,
            locationName: 'Test Location',
            latitude: 35.0,
            longitude: 139.0,
            length: 30.0,
            weight: 2.0);
        await _insertFishCatch(db,
            locationName: 'Test Location',
            latitude: 35.0,
            longitude: 139.0,
            length: 40.0,
            weight: 3.0);
        await _insertFishCatch(db,
            locationName: 'Test Location',
            latitude: 35.0,
            longitude: 139.0,
            length: 50.0,
            weight: 4.0);

        final stats = await repository.getStats('Test Location');

        expect(stats!.avgLength, equals(40.0)); // (30+40+50)/3
        expect(stats.avgWeight, equals(3.0)); // (2+3+4)/3
      });

      test('calculates correct release rate', () async {
        await _insertFishCatch(db,
            locationName: 'Test Location',
            latitude: 35.0,
            longitude: 139.0,
            fate: FishFateType.release);
        await _insertFishCatch(db,
            locationName: 'Test Location',
            latitude: 35.0,
            longitude: 139.0,
            fate: FishFateType.release);
        await _insertFishCatch(db,
            locationName: 'Test Location',
            latitude: 35.0,
            longitude: 139.0,
            fate: FishFateType.release);
        await _insertFishCatch(db,
            locationName: 'Test Location',
            latitude: 35.0,
            longitude: 139.0,
            fate: FishFateType.keep);

        final stats = await repository.getStats('Test Location');

        expect(stats!.releaseRate, equals(0.75)); // 3/4 = 0.75
      });
    });

    group('getLocationCount', () {
      test('returns 0 when no locations exist', () async {
        final count = await repository.getLocationCount();

        expect(count, equals(0));
      });

      test('returns count of distinct locations', () async {
        await _insertFishCatch(db,
            locationName: 'Location A', latitude: 35.0, longitude: 139.0);
        await _insertFishCatch(db,
            locationName: 'Location A',
            latitude: 35.0,
            longitude: 139.0); // duplicate
        await _insertFishCatch(db,
            locationName: 'Location B', latitude: 36.0, longitude: 140.0);
        await _insertFishCatch(db,
            locationName: 'Location B', latitude: 36.0, longitude: 140.0);

        final count = await repository.getLocationCount();

        expect(count, equals(2));
      });

      test('ignores null and empty location names', () async {
        await _insertFishCatch(db,
            locationName: 'Valid Location', latitude: 35.0, longitude: 139.0);
        await _insertFishCatch(db,
            locationName: null, latitude: null, longitude: null);
        await _insertFishCatch(db,
            locationName: '', latitude: null, longitude: null);

        final count = await repository.getLocationCount();

        expect(count, equals(1));
      });
    });
  });
}

/// Helper function to insert a fish catch for testing
Future<void> _insertFishCatch(
  Database db, {
  String? locationName,
  double? latitude,
  double? longitude,
  String species = 'Bass',
  double length = 30.0,
  double? weight,
  FishFateType fate = FishFateType.release,
  DateTime? catchTime,
}) async {
  await db.insert('fish_catches', {
    'species': species,
    'length': length,
    'weight': weight,
    'fate': fate.value,
    'catch_time': (catchTime ?? DateTime.now()).toIso8601String(),
    'location_name': locationName,
    'latitude': latitude,
    'longitude': longitude,
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  });
}
