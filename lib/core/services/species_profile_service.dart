import 'package:flutter/foundation.dart';
import '../database/database_provider.dart';
import '../models/species_profile.dart';
import 'fish_species_matcher.dart';

/// Species Profile Service
///
/// Provides access to species profile data from the species_profiles table.
/// This data includes detailed information about fish species such as
/// identification, habitat, feeding behavior, fishing techniques, and
/// conservation status.
class SpeciesProfileService {
  final DatabaseProvider _databaseProvider;
  final FishSpeciesMatcher _matcher = FishSpeciesMatcher();

  SpeciesProfileService(this._databaseProvider);

  /// Get species profile by species_id
  Future<SpeciesProfile?> getBySpeciesId(String speciesId) async {
    try {
      final db = await _databaseProvider.database;
      final results = await db.query(
        'species_profiles',
        where: 'species_id = ?',
        whereArgs: [speciesId],
        limit: 1,
      );

      if (results.isEmpty) {
        return null;
      }

      return SpeciesProfile.fromMap(results.first);
    } catch (e) {
      debugPrint('Error getting species profile: $e');
      return null;
    }
  }

  /// Get all species profiles
  Future<List<SpeciesProfile>> getAll() async {
    try {
      final db = await _databaseProvider.database;
      final results = await db.query('species_profiles');
      return results.map((map) => SpeciesProfile.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting all species profiles: $e');
      return [];
    }
  }

  /// Check if profile exists for species
  Future<bool> hasProfile(String speciesId) async {
    try {
      final db = await _databaseProvider.database;
      final results = await db.query(
        'species_profiles',
        columns: ['id'],
        where: 'species_id = ?',
        whereArgs: [speciesId],
        limit: 1,
      );
      return results.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking species profile: $e');
      return false;
    }
  }

  /// Get species profile by species name (e.g., "大口黑鲈")
  ///
  /// Uses FishSpeciesMatcher to find the species ID from FishGuideData,
  /// then queries species_profiles with that ID.
  Future<SpeciesProfile?> getBySpeciesName(String speciesName) async {
    debugPrint('=== getBySpeciesName called with: $speciesName ===');
    try {
      // Use FishSpeciesMatcher to find the FishSpecies from the name
      final species = _matcher.findSpeciesByName(speciesName);
      debugPrint(
          'findSpeciesByName result: ${species?.id} - ${species?.standardName}');
      if (species == null) {
        debugPrint('No species found for name: $speciesName');
        return null;
      }

      debugPrint('Found species: ${species.id} - ${species.standardName}');

      // Query species_profiles with the found ID
      final result = await getBySpeciesId(species.id);
      debugPrint('getBySpeciesId result: ${result?.speciesId}');
      return result;
    } catch (e) {
      debugPrint('Error getting species profile by name: $e');
      return null;
    }
  }

  /// Insert or update species profile
  Future<bool> upsert(SpeciesProfile profile) async {
    try {
      final db = await _databaseProvider.database;
      final existing = await getBySpeciesId(profile.speciesId);

      if (existing != null) {
        await db.update(
          'species_profiles',
          profile.toMap(),
          where: 'species_id = ?',
          whereArgs: [profile.speciesId],
        );
      } else {
        await db.insert('species_profiles', profile.toMap());
      }
      return true;
    } catch (e) {
      debugPrint('Error upserting species profile: $e');
      return false;
    }
  }

  /// Delete species profile
  Future<bool> delete(String speciesId) async {
    try {
      final db = await _databaseProvider.database;
      await db.delete(
        'species_profiles',
        where: 'species_id = ?',
        whereArgs: [speciesId],
      );
      return true;
    } catch (e) {
      debugPrint('Error deleting species profile: $e');
      return false;
    }
  }
}
