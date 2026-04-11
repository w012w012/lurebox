import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

/// Integration tests for database schema and queries.
///
/// Note: These tests verify SQL query logic by directly using sqflite
/// with an in-memory database. They do NOT use DatabaseService's static
/// singleton because that architecture prevents proper dependency injection.
///
/// DatabaseService uses a static singleton pattern which makes it difficult
/// to test without architectural changes. The actual getStatsByDateRange
/// and getSpeciesStatsByDateRange methods are tested indirectly through
/// integration tests of the full app.

void main() {
  // Initialize FFI for desktop testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Database Schema and Query Tests', () {
    late Database testDb;

    setUp(() async {
      // Create an in-memory database for testing
      testDb = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE fish_catches (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                image_path TEXT NOT NULL,
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
                air_temperature REAL,
                pressure REAL,
                weather_code INTEGER,
                pending_recognition INTEGER DEFAULT 0,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
              )
            ''');

            await db.execute('''
              CREATE TABLE species_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL UNIQUE,
                use_count INTEGER NOT NULL DEFAULT 1,
                is_deleted INTEGER NOT NULL DEFAULT 0,
                created_at TEXT NOT NULL
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
                reel_weight TEXT,
                reel_weight_unit TEXT DEFAULT 'g',
                lure_type TEXT,
                lure_weight TEXT,
                lure_weight_unit TEXT DEFAULT 'g',
                lure_size TEXT,
                lure_size_unit TEXT DEFAULT 'cm',
                lure_color TEXT,
                lure_quantity INTEGER,
                lure_quantity_unit TEXT,
                price REAL,
                purchase_date TEXT,
                is_default INTEGER DEFAULT 0,
                is_deleted INTEGER DEFAULT 0,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                category TEXT,
                reel_line TEXT,
                reel_line_date TEXT,
                reel_line_number TEXT,
                reel_line_length TEXT,
                rod_action TEXT,
                line_length_unit TEXT DEFAULT 'm',
                line_weight_unit TEXT DEFAULT 'kg',
                joint_type TEXT
              )
            ''');
          },
        ),
      );
    });

    tearDown(() async {
      await testDb.close();
    });

    group('getStatsByDateRange SQL logic', () {
      test('returns correct stats for date range with catches', () async {
        // Arrange - insert test data
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);

        await testDb.insert('fish_catches', {
          'image_path': '/test/image1.jpg',
          'species': 'Bass',
          'length': 30.0,
          'fate': 0, // release
          'catch_time': todayStart.toIso8601String(),
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });

        await testDb.insert('fish_catches', {
          'image_path': '/test/image2.jpg',
          'species': 'Trout',
          'length': 25.0,
          'fate': 1, // keep
          'catch_time': todayStart.toIso8601String(),
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });

        await testDb.insert('fish_catches', {
          'image_path': '/test/image3.jpg',
          'species': 'Carp',
          'length': 40.0,
          'fate': 0, // release
          'catch_time': todayStart.toIso8601String(),
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });

        // Act - use same SQL as DatabaseService
        final result = await testDb.rawQuery(
          '''
          SELECT
            COUNT(*) as total,
            COALESCE(SUM(CASE WHEN fate = 0 THEN 1 ELSE 0 END), 0) as release,
            COALESCE(SUM(CASE WHEN fate = 1 THEN 1 ELSE 0 END), 0) as keep
          FROM fish_catches
          WHERE catch_time >= ? AND catch_time < ?
          ''',
          [todayStart.toIso8601String(), todayStart.add(const Duration(days: 1)).toIso8601String()],
        );

        // Assert
        final row = result.first;
        expect(row['total'], equals(3));
        expect(row['release'], equals(2));
        expect(row['keep'], equals(1));
      });

      test('returns zero counts when no catches in range', () async {
        // Arrange
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final yesterdayStart = todayStart.subtract(const Duration(days: 1));

        // Act
        final result = await testDb.rawQuery(
          '''
          SELECT
            COUNT(*) as total,
            COALESCE(SUM(CASE WHEN fate = 0 THEN 1 ELSE 0 END), 0) as release,
            COALESCE(SUM(CASE WHEN fate = 1 THEN 1 ELSE 0 END), 0) as keep
          FROM fish_catches
          WHERE catch_time >= ? AND catch_time < ?
          ''',
          [yesterdayStart.toIso8601String(), todayStart.toIso8601String()],
        );

        // Assert
        final row = result.first;
        expect(row['total'], equals(0));
        expect(row['release'], equals(0));
        expect(row['keep'], equals(0));
      });

      test('excludes catches outside date range', () async {
        // Arrange
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final yesterdayStart = todayStart.subtract(const Duration(days: 1));

        // Insert a catch from yesterday
        await testDb.insert('fish_catches', {
          'image_path': '/test/image1.jpg',
          'species': 'Bass',
          'length': 30.0,
          'fate': 0,
          'catch_time': yesterdayStart.toIso8601String(),
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });

        // Insert a catch from today
        await testDb.insert('fish_catches', {
          'image_path': '/test/image2.jpg',
          'species': 'Trout',
          'length': 25.0,
          'fate': 1,
          'catch_time': todayStart.toIso8601String(),
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });

        // Act - query only today's range
        final result = await testDb.rawQuery(
          '''
          SELECT
            COUNT(*) as total,
            COALESCE(SUM(CASE WHEN fate = 0 THEN 1 ELSE 0 END), 0) as release,
            COALESCE(SUM(CASE WHEN fate = 1 THEN 1 ELSE 0 END), 0) as keep
          FROM fish_catches
          WHERE catch_time >= ? AND catch_time < ?
          ''',
          [todayStart.toIso8601String(), todayStart.add(const Duration(days: 1)).toIso8601String()],
        );

        // Assert - only today's catch
        final row = result.first;
        expect(row['total'], equals(1));
        expect(row['keep'], equals(1));
      });
    });

    group('getSpeciesStatsByDateRange SQL logic', () {
      test('returns correct species counts', () async {
        // Arrange
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);

        await testDb.insert('fish_catches', {
          'image_path': '/test/image1.jpg',
          'species': 'Bass',
          'length': 30.0,
          'fate': 0,
          'catch_time': todayStart.toIso8601String(),
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });

        await testDb.insert('fish_catches', {
          'image_path': '/test/image2.jpg',
          'species': 'Bass',
          'length': 32.0,
          'fate': 0,
          'catch_time': todayStart.toIso8601String(),
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });

        await testDb.insert('fish_catches', {
          'image_path': '/test/image3.jpg',
          'species': 'Trout',
          'length': 25.0,
          'fate': 1,
          'catch_time': todayStart.toIso8601String(),
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });

        // Act - use same SQL as DatabaseService
        final results = await testDb.rawQuery(
          '''
          SELECT species, COUNT(*) as count
          FROM fish_catches
          WHERE catch_time >= ? AND catch_time < ?
          GROUP BY species
          ORDER BY count DESC
          LIMIT 10
          ''',
          [todayStart.toIso8601String(), todayStart.add(const Duration(days: 1)).toIso8601String()],
        );

        // Assert
        final stats = <String, int>{};
        for (final row in results) {
          stats[row['species'] as String] = (row['count'] as int?) ?? 0;
        }

        expect(stats['Bass'], equals(2));
        expect(stats['Trout'], equals(1));
        expect(stats.length, equals(2));
      });

      test('returns empty map when no catches', () async {
        // Arrange
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);

        // Act
        final results = await testDb.rawQuery(
          '''
          SELECT species, COUNT(*) as count
          FROM fish_catches
          WHERE catch_time >= ? AND catch_time < ?
          GROUP BY species
          ORDER BY count DESC
          LIMIT 10
          ''',
          [todayStart.toIso8601String(), todayStart.add(const Duration(days: 1)).toIso8601String()],
        );

        // Assert
        expect(results, isEmpty);
      });

      test('returns species sorted by count descending', () async {
        // Arrange
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);

        // Insert multiple species with different counts
        for (int i = 0; i < 5; i++) {
          await testDb.insert('fish_catches', {
            'image_path': '/test/image$i.jpg',
            'species': 'Bass',
            'length': 30.0,
            'fate': 0,
            'catch_time': todayStart.toIso8601String(),
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          });
        }

        for (int i = 0; i < 3; i++) {
          await testDb.insert('fish_catches', {
            'image_path': '/test/image_trout$i.jpg',
            'species': 'Trout',
            'length': 25.0,
            'fate': 0,
            'catch_time': todayStart.toIso8601String(),
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          });
        }

        for (int i = 0; i < 1; i++) {
          await testDb.insert('fish_catches', {
            'image_path': '/test/image_carp$i.jpg',
            'species': 'Carp',
            'length': 40.0,
            'fate': 0,
            'catch_time': todayStart.toIso8601String(),
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          });
        }

        // Act
        final results = await testDb.rawQuery(
          '''
          SELECT species, COUNT(*) as count
          FROM fish_catches
          WHERE catch_time >= ? AND catch_time < ?
          GROUP BY species
          ORDER BY count DESC
          LIMIT 10
          ''',
          [todayStart.toIso8601String(), todayStart.add(const Duration(days: 1)).toIso8601String()],
        );

        // Assert - verify order (descending by count)
        expect(results[0]['species'], equals('Bass'));
        expect(results[0]['count'], equals(5));
        expect(results[1]['species'], equals('Trout'));
        expect(results[1]['count'], equals(3));
        expect(results[2]['species'], equals('Carp'));
        expect(results[2]['count'], equals(1));
      });

      test('limits results to top 10 species', () async {
        // Arrange
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);

        // Insert 15 different species (should only get top 10)
        for (int i = 0; i < 15; i++) {
          await testDb.insert('fish_catches', {
            'image_path': '/test/image$i.jpg',
            'species': 'Species$i',
            'length': 30.0,
            'fate': 0,
            'catch_time': todayStart.toIso8601String(),
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          });
        }

        // Act
        final results = await testDb.rawQuery(
          '''
          SELECT species, COUNT(*) as count
          FROM fish_catches
          WHERE catch_time >= ? AND catch_time < ?
          GROUP BY species
          ORDER BY count DESC
          LIMIT 10
          ''',
          [todayStart.toIso8601String(), todayStart.add(const Duration(days: 1)).toIso8601String()],
        );

        // Assert - should be limited to 10
        expect(results.length, equals(10));
      });
    });
  });
}
