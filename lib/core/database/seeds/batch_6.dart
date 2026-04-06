import 'dart:convert';

/// Species Profile Seed Data - Batch 6 (Species 16-18)
///
/// Data sourced from FishBase
/// Generated: 2026-04-05

/// Current timestamp for created_at/updated_at fields
final _now = DateTime.now().toIso8601String();

/// Batch 6 species profile data
/// Contains: Japanese Yellowfin (f016), Bluegill (f017), Black Crappie (f018)
final List<Map<String, dynamic>> batch6SpeciesProfiles = [
  // Species 16: 马口 (Japanese Yellowfin) - f016
  {
    'species_id': 'f016',
    'aliases': 'Japanese Yamabe, 马口, 溪哥',
    'identification':
        'Slender, compressed body, silvery with dark green back, males have red/orange fin tips during breeding.',
    'habitat':
        'Clear mountain streams and rivers with moderate current. Often found near surface.',
    'feeding_behavior':
        'Surface-oriented omnivore - aquatic insects, zooplankton, algae. Schooling fish.',
    'fishing_techniques':
        'Tiny spinners, wet flies, small dry flies. Light tackle. Stream fishing.',
    'size_records': 'Max length 25cm, common 10-15cm, max weight 80g',
    'conservation_status': 'IUCN: Least Concern (LC). Common in native range.',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=12074&GenusName=Opsariichthys&SpeciesName=bilentii',
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

  // Species 17: 蓝鳃太阳鱼 (Bluegill) - f017
  {
    'species_id': 'f017',
    'aliases': 'Bluegill, 蓝鳃太阳鱼, 太阳鱼',
    'identification':
        'Deep, flattened body, olive green with blue/violet sheen on cheek, black ear flap, rounded opercular flap.',
    'habitat':
        'Warm, vegetated lakes and slow streams. Shore-line vegetation important for spawning.',
    'feeding_behavior':
        'Diurnal feeder - insects, zooplankton, small crustaceans. Panfish feeding in schools.',
    'fishing_techniques':
        'Light tackle (1/32-1/8 oz), small jigs, worms under bobber. Weed bed edges.',
    'size_records':
        'Max length 41cm, common 15-20cm, max weight 2.2kg, max age 11 years',
    'conservation_status':
        'IUCN: Least Concern (LC). Excellent starter fish for beginners.',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=365&GenusName=Lepomis&SpeciesName=macrochirus',
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

  // Species 18: 黑Crappie (Black Crappie) - f018
  {
    'species_id': 'f018',
    'aliases': 'Black Crappie, 黑Crappie, 睡鳜',
    'identification':
        'Deep, laterally compressed body, silvery-olive with irregular black blotches, large mouth, highly mottled pattern.',
    'habitat':
        'Clear, vegetated lakes, reservoirs, slow rivers. Structure-oriented (brush, weed edges, docks).',
    'feeding_behavior':
        'Crepuscular/dawn feeding on small fish and insects. Schooling, especially in deeper water.',
    'fishing_techniques':
        'Small jigs (1/32-1/16 oz), live minnows under bobber. Ice fishing popular. Structure-based.',
    'size_records':
        'Max length 49cm, common 20-30cm, max weight 2.7kg, max age 17 years',
    'conservation_status': 'IUCN: Not Evaluated. Popular panfish.',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=361&GenusName=Pomoxis&SpeciesName=nigromaculatus',
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
