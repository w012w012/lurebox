import 'dart:convert';

/// Species Profile Seed Data - Batch 4 (Species 10-12)
///
/// Data sourced from FishBase, USGS NAS, Animal Diversity Web
/// Generated: 2026-04-05

/// Current timestamp for created_at/updated_at fields
final _now = DateTime.now().toIso8601String();

/// Batch 4 species profile data
/// Contains: Brook Trout (f010), Lake Trout (f011), Chinook Salmon (f012)
/// Note: These IDs may need to be updated when fish_species table is fully populated
final List<Map<String, dynamic>> batch4SpeciesProfiles = [
  // Species 10: 溪鳟 (Brook Trout) - f010
  {
    'species_id': 'f010',
    'aliases': 'Brook Trout, 溪鳟, 山溪鳟',
    'identification':
        'Dark green/back with light spots (vermilion on adipose fin), bright colors, smaller than lake trout. Body covered with small scales.',
    'habitat':
        'Cold, clear mountain streams and headwater ponds with high oxygen. Native to Eastern North America.',
    'feeding_behavior':
        'Carnivorous - insects, zooplankton, small fish. Most active at dawn/dusk and during hatches.',
    'fishing_techniques':
        'Fly fishing (wet flies, nymphs), ultralight spinning. Small imitative lures work best.',
    'size_records':
        'Max length 59cm, common 25-35cm, max weight 3.2kg, max age 7 years',
    'conservation_status':
        'IUCN: Least Concern (LC). Invasive in some regions outside native range.',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=459&GenusName=Salvelinus&SpeciesName=fontinalis',
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
      },
      {
        'name': 'USGS NAS',
        'url': 'https://nas.er.usgs.gov/queries/factsheet.aspx?SpeciesID=932',
        'accessed_fields': ['SpeciesDescription', 'Habitat', 'Impacts'],
        'access_date': '2026-04-05'
      }
    ]),
    'confidence_score': 'high',
    'version': 1,
    'created_at': _now,
    'updated_at': _now,
  },

  // Species 11: 湖鳟 (Lake Trout) - f011
  {
    'species_id': 'f011',
    'aliases': 'Lake Trout, 湖鳟, 秋鳟',
    'identification':
        'Large, slender char with deeply forked tail, light gray/green body with cream spots. Bony shield between pelvic fins.',
    'habitat':
        'Deep, cold oligotrophic lakes (below 20°C). Native to North America. Found at depths 20-60m.',
    'feeding_behavior':
        'Piscivorous - ciscos, whitefish, sculpins. Deep-water predator, less active in summer.',
    'fishing_techniques':
        'Downriggers, lead-core line, large spoons. Summer: deep water. Spring/fall: shallower.',
    'size_records':
        'Max length 150cm, common 45-90cm, max weight 32kg, max age 70 years',
    'conservation_status':
        'IUCN: Least Concern (LC). Some populations declining due to invasive species.',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=485&GenusName=Salvelinus&SpeciesName=namaycush',
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
      },
      {
        'name': 'Animal Diversity Web',
        'url': 'https://animaldiversity.org/accounts/Salvelinus_namaycush/',
        'accessed_fields': [
          'Description',
          'Habitat',
          'FoodHabits',
          'Predation'
        ],
        'access_date': '2026-04-05'
      }
    ]),
    'confidence_score': 'high',
    'version': 1,
    'created_at': _now,
    'updated_at': _now,
  },

  // Species 12: 王鲑 (Chinook Salmon) - f012
  {
    'species_id': 'f012',
    'aliases': 'King Salmon, 大鳞大马哈鱼, 王鲑',
    'identification':
        'Largest Pacific salmon, blue/green back with silver sides, black spots on upper lobe of tail. Heavy spotting on tail.',
    'habitat':
        'Anadromous - Pacific coastal waters, spawning rivers. Enters freshwater in summer/fall.',
    'feeding_behavior':
        'Piscivorous at sea - herring, sandfish, crustaceans. Stops feeding in freshwater.',
    'fishing_techniques':
        'Drift fishing with spawn sacs, Kwikfish lures, fly fishing (skeg flies). Tidal rivers.',
    'size_records':
        'Max length 150cm, common 60-90cm, max weight 57kg, max age 9 years',
    'conservation_status':
        'IUCN: Not Evaluated. Some populations endangered due to damming and habitat loss.',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=240&GenusName=Oncorhynchus&SpeciesName=tshawytscha',
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
