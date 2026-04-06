import 'dart:convert';

/// Species Profile Seed Data - Batch 7 (Species 19-21)
///
/// Data sourced from FishBase, IUCN Red List
/// Generated: 2026-04-05

/// Current timestamp for created_at/updated_at fields
final _now = DateTime.now().toIso8601String();

/// Batch 7 species profile data
/// Contains: Flathead Catfish (f019), Lake Sturgeon (f020), Striped Bass (f021)
final List<Map<String, dynamic>> batch7SpeciesProfiles = [
  // Species 19: 平头叉尾鮰 (Flathead Catfish) - f019
  {
    'species_id': 'f019',
    'aliases': 'Flathead Catfish, 平头叉尾鮰',
    'identification':
        'Olive-green to brown color with flat head, 8 barbels around mouth, adipose dorsal fin. Adults reach large sizes.',
    'habitat':
        'Freshwater rivers and streams with sandy/rocky bottoms. Native to Mississippi River system in North America.',
    'feeding_behavior':
        'Nocturnal predator. Eats fish, crustaceans, and mollusks. Ambush hunter using concealment.',
    'fishing_techniques':
        'Heavy tackle (8-20kg), live bait (shad, carp), night fishing. Prime locations: deep holes, submerged structures.',
    'size_records': 'Max length 123cm, typical 30-50cm, max weight 60kg+',
    'conservation_status': 'IUCN: Data Deficient. Important sport fish.',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=4879&GenusName=Pylodictis&SpeciesName=olivaris',
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

  // Species 20: 河鲟 (Lake Sturgeon) - f020
  {
    'species_id': 'f020',
    'aliases': 'Lake Sturgeon, 河鲟, 湖鲟',
    'identification':
        'Prehistoric appearance with 5 rows of bony scutes, long snout, 4 fringe-like barbels. Pale yellow to brown color.',
    'habitat':
        'Cold, clear lakes and rivers with sandy bottoms. Native to Great Lakes basin in North America.',
    'feeding_behavior':
        'Bottom feeder. Eats benthic organisms (insects, mollusks, fish eggs). Active year-round.',
    'fishing_techniques':
        'Hook and line with heavy gear (10-20kg), night crawlers or minnows. Prime locations: river confluences, deep pools.',
    'size_records':
        'Max length 203cm, typical 100-150cm, max weight 108kg, max age 150+ years',
    'conservation_status':
        'IUCN: Near Threatened (NT). Ancient species needing protection.',
    'source_references': jsonEncode([
      {
        'name': 'IUCN Red List',
        'url': 'https://www.iucnredlist.org/species/199/124438034',
        'accessed_fields': [
          'ScientificName',
          'CommonNames',
          'Habitat',
          'ConservationStatus'
        ],
        'access_date': '2026-04-05'
      },
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=198&GenusName=Acipenser&SpeciesName=fulvescens',
        'accessed_fields': [
          'SpeciesName',
          'Morphology',
          'Habitat',
          'Diet',
          'Size',
          'Age'
        ],
        'access_date': '2026-04-05'
      }
    ]),
    'confidence_score': 'high',
    'version': 1,
    'created_at': _now,
    'updated_at': _now,
  },

  // Species 21: 条纹鲈 (Striped Bass) - f021
  {
    'species_id': 'f021',
    'aliases': 'Striped Bass, 条纹鲈, Striper',
    'identification':
        'Distinctive vertical stripes (5-7), silver body with bluish back. Dorsal fin with 2 spines (distinguishes from white perch).',
    'habitat':
        'Anadromous - migrates from saltwater to freshwater. Found in coastal areas, estuaries, and large rivers.',
    'feeding_behavior':
        'Predatory. Eats herring, shad, and crustaceans. Most active during dawn/dusk and tidal changes.',
    'fishing_techniques':
        'Trolling (spoons, plugs), surfcasting (baitfish), fly fishing. Prime locations: tidal rivers, bridge pilings.',
    'size_records':
        'Max length 183cm, typical 60-90cm, max weight 41kg, record 41.4 kg (1983 CA record)',
    'conservation_status': 'IUCN: Least Concern (LC). Major sport fish.',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=303&GenusName=Morone&SpeciesName=saxatilis',
        'accessed_fields': [
          'SpeciesName',
          'CommonNames',
          'Morphology',
          'Habitat',
          'Diet',
          'Fishing',
          'Size'
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
