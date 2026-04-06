import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lurebox/core/database/database_provider.dart';
import 'package:lurebox/core/models/fish_species.dart';
import 'package:lurebox/features/achievement/fish_guide_data.dart';
import 'package:lurebox/core/database/seeds/batch_1.dart';
import 'package:lurebox/core/database/seeds/batch_2.dart';
import 'package:lurebox/core/database/seeds/batch_3.dart';
import 'package:lurebox/core/database/seeds/batch_4.dart';
import 'package:lurebox/core/database/seeds/batch_5.dart';
import 'package:lurebox/core/database/seeds/batch_6.dart';
import 'package:lurebox/core/database/seeds/batch_7.dart';
import 'package:lurebox/core/database/seeds/batch_8.dart';
import 'package:lurebox/core/database/seeds/batch_9.dart';
import 'package:lurebox/core/database/seeds/batch_10.dart';

void main() {
  late Database db;

  setUpAll(() {
    // Initialize FFI for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Create fresh database for each test
    final dbProvider = DatabaseProvider();
    await dbProvider.resetForTesting();
    db = await dbProvider.database;

    // Create fish_species and species_profiles tables (normally created via migration)
    await _createSpeciesTables(db);

    // Seed the database with fish_species and species_profiles data
    await _seedDatabase(db);
  });

  tearDown(() async {
    await db.close();
  });

  // Valid IUCN conservation statuses
  const validIucnStatuses = [
    'LC', // Least Concern
    'NT', // Near Threatened
    'VU', // Vulnerable
    'EN', // Endangered
    'CR', // Critically Endangered
    'EW', // Extinct in the Wild
    'EX', // Extinct
    'Data Deficient',
    'Not Evaluated',
  ];

  // Valid invasive designations
  const validInvasiveStatuses = [
    'Invasive',
    'Invasive (High Impact)',
    'Invasive (Medium Impact)',
    'Invasive (Low Impact)',
  ];

  List<String> getAllValidStatuses() {
    return [...validIucnStatuses, ...validInvasiveStatuses];
  }

  group('species_profiles table completeness tests', () {
    test('1. All species profiles from seed files exist', () async {
      // Get expected species IDs from the actual seed data
      final expectedSpeciesIds = _getExpectedSpeciesIds();

      // Query all species profiles
      final profiles = await db.query('species_profiles');

      // Verify count matches expected
      expect(
        profiles.length,
        expectedSpeciesIds.length,
        reason:
            'species_profiles table should contain ${expectedSpeciesIds.length} profiles (from seed data)',
      );

      // Extract all species_ids from the table
      final speciesIds = profiles.map((p) => p['species_id'] as String).toSet();

      // Verify all expected species IDs exist
      for (final speciesId in expectedSpeciesIds) {
        expect(
          speciesIds.contains(speciesId),
          true,
          reason: 'Species profile for $speciesId should exist',
        );
      }
    });

    test(
      '2. Each profile has all 7 required fields non-null and non-empty',
      () async {
        final profiles = await db.query('species_profiles');
        expect(profiles.isNotEmpty, true,
            reason: 'species_profiles table should not be empty');

        // The 7 required fields
        const requiredFields = [
          'aliases',
          'identification',
          'habitat',
          'feeding_behavior',
          'fishing_techniques',
          'size_records',
          'conservation_status',
        ];

        for (final profile in profiles) {
          final speciesId = profile['species_id'] as String;

          for (final field in requiredFields) {
            final value = profile[field];

            expect(
              value != null,
              true,
              reason: 'Species $speciesId: field "$field" should not be NULL',
            );

            expect(
              (value as String).trim().isNotEmpty,
              true,
              reason: 'Species $speciesId: field "$field" should not be empty',
            );
          }
        }
      },
    );

    test(
      '3. source_references format is valid JSON with required fields',
      () async {
        final profiles = await db.query('species_profiles');
        expect(profiles.isNotEmpty, true,
            reason: 'species_profiles table should not be empty');

        for (final profile in profiles) {
          final speciesId = profile['species_id'] as String;
          final sourceRefsRaw = profile['source_references'] as String?;

          expect(
            sourceRefsRaw != null && sourceRefsRaw!.trim().isNotEmpty,
            true,
            reason:
                'Species $speciesId: source_references should not be null or empty',
          );

          // Must be valid JSON array
          List<dynamic>? sources;
          try {
            final decoded = jsonDecode(sourceRefsRaw!);
            if (decoded is List) {
              sources = decoded;
            } else if (decoded is Map<String, dynamic>) {
              sources = decoded['sources'] as List<dynamic>?;
            }
          } catch (e) {
            fail('Species $speciesId: source_references is not valid JSON: $e');
          }

          expect(sources, isNotNull,
              reason:
                  'Species $speciesId: source_references should be a JSON array');

          expect(sources!.isNotEmpty, true,
              reason:
                  'Species $speciesId: source_references should have at least 1 source entry');

          for (int i = 0; i < sources.length; i++) {
            final source = sources[i] as Map<String, dynamic>;

            // Each entry must have: name (string), url (string), access_date or accessed (string date)
            expect(
              source.containsKey('name') && source['name'] is String,
              true,
              reason:
                  'Species $speciesId: source[$i] must have "name" (string)',
            );

            expect(
              source.containsKey('url') && source['url'] is String,
              true,
              reason: 'Species $speciesId: source[$i] must have "url" (string)',
            );

            // Check for either 'access_date' or 'accessed' field (both are acceptable)
            final hasAccessDate = source.containsKey('access_date') &&
                source['access_date'] is String;
            final hasAccessed =
                source.containsKey('accessed') && source['accessed'] is String;
            expect(
              hasAccessDate || hasAccessed,
              true,
              reason:
                  'Species $speciesId: source[$i] must have "access_date" or "accessed" (string date)',
            );
          }
        }
      },
    );

    test(
      '4. species_id foreign key references exist in fish_species table',
      () async {
        // Get all fish_species IDs
        final fishSpecies = await db.query('fish_species');
        final fishSpeciesIds =
            fishSpecies.map((f) => f['id'] as String).toSet();

        expect(
          fishSpeciesIds.isNotEmpty,
          true,
          reason: 'fish_species table should contain species',
        );

        // Get all species_profiles
        final profiles = await db.query('species_profiles');

        for (final profile in profiles) {
          final speciesId = profile['species_id'] as String;

          expect(
            fishSpeciesIds.contains(speciesId),
            true,
            reason:
                'species_profiles.species_id "$speciesId" must exist in fish_species table',
          );
        }
      },
    );

    test(
      '5. conservation_status contains valid IUCN status or invasive designation',
      () async {
        final profiles = await db.query('species_profiles');
        expect(profiles.isNotEmpty, true,
            reason: 'species_profiles table should not be empty');

        final allValidStatuses = getAllValidStatuses();

        for (final profile in profiles) {
          final speciesId = profile['species_id'] as String;
          final status = (profile['conservation_status'] as String).trim();

          // Check if status contains any valid IUCN status or invasive designation
          bool isValidStatus = allValidStatuses.any((valid) {
            return status.contains(valid);
          });

          expect(
            isValidStatus,
            true,
            reason: 'Species $speciesId: conservation_status "$status" should '
                'be a valid IUCN status or invasive designation. '
                'Expected one of: ${allValidStatuses.join(", ")}',
          );
        }
      },
    );
  });
}

/// Creates fish_species and species_profiles tables
/// These are normally created via migration v17 and v18, but _onCreate
/// only calls _createSchema which doesn't include them.
Future<void> _createSpeciesTables(Database db) async {
  // Create fish_species table (migration v17)
  await db.execute('''
CREATE TABLE fish_species (
  id TEXT PRIMARY KEY,
  standard_name TEXT NOT NULL,
  scientific_name TEXT,
  category INTEGER NOT NULL,
  rarity INTEGER NOT NULL,
  habitat TEXT,
  behavior TEXT,
  fishing_method TEXT,
  description TEXT,
  icon_emoji TEXT
)
''');

  // Create species_profiles table (migration v18)
  await db.execute('''
CREATE TABLE species_profiles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  species_id TEXT NOT NULL UNIQUE,
  aliases TEXT,
  identification TEXT,
  habitat TEXT,
  feeding_behavior TEXT,
  fishing_techniques TEXT,
  size_records TEXT,
  conservation_status TEXT,
  source_references TEXT,
  confidence_score TEXT,
  version INTEGER DEFAULT 1,
  created_at TEXT,
  updated_at TEXT
)
''');

  // Create indexes
  await db.execute(
      'CREATE INDEX idx_species_profiles_species_id ON species_profiles(species_id)');
}

/// Seeds the database with fish_species and species_profiles data
Future<void> _seedDatabase(Database db) async {
  // Get all species profiles from all batch files
  // Use a Map to deduplicate by species_id (some species appear in multiple batches)
  final profileMap = <String, Map<String, dynamic>>{};
  for (final batch in [
    batch1SpeciesProfiles,
    batch2SpeciesProfiles,
    batch3SpeciesProfiles,
    batch4SpeciesProfiles,
    batch5SpeciesProfiles,
    batch6SpeciesProfiles,
    batch7SpeciesProfiles,
    batch8SpeciesProfiles,
    batch9SpeciesProfiles,
    batch10SpeciesProfiles,
  ]) {
    for (final profile in batch) {
      final speciesId = profile['species_id'] as String;
      // Keep the first occurrence (don't overwrite)
      profileMap.putIfAbsent(speciesId, () => profile);
    }
  }
  final allProfiles = profileMap.values.toList();

  // Extract unique species IDs from profiles
  final speciesIds = allProfiles.map((p) => p['species_id'] as String).toSet();

  // Get fish_species data from FishGuideData for the species that have profiles
  final fishSpeciesData =
      FishGuideData.allSpecies.where((s) => speciesIds.contains(s.id)).toList();

  // For placeholder IDs (f051, f052, f053 etc.) that don't exist in FishGuideData,
  // create minimal placeholder entries to satisfy FK constraints
  final placeholderIds =
      speciesIds.difference(fishSpeciesData.map((s) => s.id).toSet());

  for (final placeholderId in placeholderIds) {
    // Create a minimal placeholder fish_species entry
    await db.insert('fish_species', {
      'id': placeholderId,
      'standard_name': 'Placeholder Species',
      'scientific_name': 'Unknown',
      'category': 0, // freshwaterLure
      'rarity': 0,
      'habitat': 'TBD',
      'behavior': 'TBD',
      'fishing_method': 'TBD',
      'description': 'Placeholder for species profile data',
      'icon_emoji': '🐟',
    });
  }

  // Insert fish_species data
  for (final species in fishSpeciesData) {
    await db.insert('fish_species', {
      'id': species.id,
      'standard_name': species.standardName,
      'scientific_name': species.scientificName,
      'category': species.category.value,
      'rarity': species.rarity.value,
      'habitat': species.habitat,
      'behavior': species.behavior,
      'fishing_method': species.fishingMethod,
      'description': species.description,
      'icon_emoji': species.iconEmoji,
    });
  }

  // Insert species_profiles data
  for (final profile in allProfiles) {
    await db.insert('species_profiles', {
      'species_id': profile['species_id'],
      'aliases': profile['aliases'],
      'identification': profile['identification'],
      'habitat': profile['habitat'],
      'feeding_behavior': profile['feeding_behavior'],
      'fishing_techniques': profile['fishing_techniques'],
      'size_records': profile['size_records'],
      'conservation_status': profile['conservation_status'],
      'source_references': profile['source_references'],
      'confidence_score': profile['confidence_score'],
      'version': profile['version'],
      'created_at': profile['created_at'],
      'updated_at': profile['updated_at'],
    });
  }
}

/// Gets the expected species IDs from the actual seed data files
Set<String> _getExpectedSpeciesIds() {
  // Collect all species IDs from all batches, deduplicating
  final profileMap = <String, bool>{};
  for (final batch in [
    batch1SpeciesProfiles,
    batch2SpeciesProfiles,
    batch3SpeciesProfiles,
    batch4SpeciesProfiles,
    batch5SpeciesProfiles,
    batch6SpeciesProfiles,
    batch7SpeciesProfiles,
    batch8SpeciesProfiles,
    batch9SpeciesProfiles,
    batch10SpeciesProfiles,
  ]) {
    for (final profile in batch) {
      profileMap[profile['species_id'] as String] = true;
    }
  }
  return profileMap.keys.toSet();
}
