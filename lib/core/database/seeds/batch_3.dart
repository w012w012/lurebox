import 'dart:convert';

/// Species Profile Seed Data - Batch 3 (Species 7-9)
///
/// Data sourced from FishBase
/// Generated: 2026-04-05
///
/// NOTE: Species 7-9 (Smallmouth Bass, Spotted Bass, Muskie) are assigned
/// placeholder IDs f051, f052, f053 to avoid conflicts with other batches.

/// Current timestamp for created_at/updated_at fields
final _now = DateTime.now().toIso8601String();

/// Batch 3 species profile data
/// Contains: Smallmouth Bass (f051), Spotted Bass (f052), Muskie (f053)
final List<Map<String, dynamic>> batch3SpeciesProfiles = [
  // Species 7: 小口黑鲈 (Smallmouth Bass) - f051
  {
    'species_id': 'f051',
    'aliases': 'Smallmouth Bass, 小口黑鲈',
    'identification':
        'Smaller mouth than largemouth, vertical stripes rather than horizontal, bronze/copper coloration',
    'habitat':
        'Clear, cool streams and lakes with rocky bottoms. Prefers running water.',
    'feeding_behavior':
        'Piscivorous - crayfish, fish, insects. More active in cooler water than largemouth.',
    'fishing_techniques':
        'Smallmouth-specific lures (grubs, tubes), fly fishing (streamers). Best in current breaks.',
    'size_records': 'Max length 69cm, common 30-40cm, max weight 5.4kg',
    'conservation_status': 'IUCN: Least Concern (LC)',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=330&GenusName=Micropterus&SpeciesName=dolomieu',
        'accessed_fields': [
          'SpeciesName',
          'CommonNames',
          'Morphology',
          'Habitat',
          'Diet',
          'Fishing',
          'Size',
          'Conservation'
        ],
        'access_date': '2026-04-05'
      }
    ]),
    'confidence_score': 'high',
    'version': 1,
    'created_at': _now,
    'updated_at': _now,
  },

  // Species 8: 斑点黑鲈 (Spotted Bass) - f052
  {
    'species_id': 'f052',
    'aliases': 'Spotted Bass, 斑点黑鲈',
    'identification':
        'Small mouth, rows of teeth on tongue, spotted pattern near dorsal fin, greenish body',
    'habitat':
        'Streams and reservoirs with clear water, moderate current. Rock-based substrate.',
    'feeding_behavior':
        'Piscivorous - small fish, crayfish. Active throughout the water column.',
    'fishing_techniques':
        'Drop shot rigs, small cranks, tubes. Found in flowing water areas.',
    'size_records': 'Max length 56cm, common 25-35cm, max weight 2.2kg',
    'conservation_status': 'IUCN: Least Concern (LC)',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=331&GenusName=Micropterus&SpeciesName=punctulatus',
        'accessed_fields': [
          'SpeciesName',
          'CommonNames',
          'Morphology',
          'Habitat',
          'Diet',
          'Fishing',
          'Size',
          'Conservation'
        ],
        'access_date': '2026-04-05'
      }
    ]),
    'confidence_score': 'high',
    'version': 1,
    'created_at': _now,
    'updated_at': _now,
  },

  // Species 9: Muskellunge (Muskie) - f053
  {
    'species_id': 'f053',
    'aliases': 'Muskie, 巨型梭鱼',
    'identification':
        'Largest member of pike family, long slender body, large duckbill-shaped mouth with many teeth',
    'habitat':
        'Large clear lakes and rivers with abundant vegetation. Prefers 15-20°C water.',
    'feeding_behavior':
        'Apex predator - fish primarily, occasionally waterfowl. Extremely aggressive.',
    'fishing_techniques':
        'Large lures (bucktail spinners, jerkbaits), tacky soft plastics. Trophy hunting.',
    'size_records': 'Max length 150cm+, common 90-120cm, max weight 30kg+',
    'conservation_status': 'IUCN: Vulnerable (VU) in some range states',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=1986&GenusName=Esox&SpeciesName=masquinongy',
        'accessed_fields': [
          'SpeciesName',
          'CommonNames',
          'Morphology',
          'Habitat',
          'Diet',
          'Fishing',
          'Size',
          'Conservation'
        ],
        'access_date': '2026-04-05'
      }
    ]),
    'confidence_score': 'high',
    'version': 1,
    'created_at': _now,
    'updated_at': _now,
  },
];
