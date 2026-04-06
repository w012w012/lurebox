import 'dart:convert';

/// Species Profile Seed Data - Batch 1 (Species 1-3)
///
/// Data sourced from FishBase
/// Generated: 2026-04-05

/// Current timestamp for created_at/updated_at fields
final _now = DateTime.now().toIso8601String();

/// Batch 1 species profile data
/// Contains: Largemouth Bass (f002), Chinese Perch (f001), Rainbow Trout (f029)
final List<Map<String, dynamic>> batch1SpeciesProfiles = [
  // Species 1: 大口黑鲈 (Largemouth Bass) - f002
  {
    'species_id': 'f002',
    'aliases': 'Largemouth Bass, 加州鲈, 大口仔',
    'identification':
        'Big mouth with upper jaw extending past eye, fusiform body, variable coloration with greenish back and lighter sides, dark vertical bars',
    'habitat':
        'Freshwater lakes, ponds, rivers, and backwaters with rocky areas, prefers clear water and temperatures 10-32°C',
    'feeding_behavior':
        'Piscivorous; feeds on fish, crayfish, frogs, and insects. Cannibalistic. Feeding activity decreases below 5°C and above 37°C',
    'fishing_techniques':
        'Lure fishing (crankbaits, soft plastics), fly fishing, targeting rocky structures and weed edges. Most active during dawn/dusk',
    'size_records':
        'Max length 97cm, common length 40cm, max weight 10.1kg, max age 23 years',
    'conservation_status': 'IUCN: Least Concern (LC), CITES: Not Evaluated',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=463&GenusName=Micropterus&SpeciesName=salmoides',
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

  // Species 2: 鳜鱼 (Chinese Perch) - f001
  {
    'species_id': 'f001',
    'aliases': 'Mandarin fish, Chinese perch',
    'identification':
        'High body with flat sides, dark spots and 4-5 dark horizontal stripes near dorsal fin base, large mouth extending past eye',
    'habitat':
        'Freshwater rivers and lakes with macrophytes, prefers turbid water, pH 7.0-7.4, temperatures 4-22°C',
    'feeding_behavior':
        'Specialized piscivore; feeds exclusively on fish fry. Stalks prey visually, ambush predator active at night',
    'fishing_techniques':
        'Using live fish bait, deep water trolling, targeting vegetated areas. Seasonal winter fishing peak',
    'size_records': 'Max length 70cm, max weight 8kg, max age 9 years',
    'conservation_status': 'IUCN: Least Concern (LC), CITES: Not Evaluated',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=462&GenusName=Siniperca&SpeciesName=chuatsi',
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

  // Species 3: 虹鳟 (Rainbow Trout) - f029
  {
    'species_id': 'f029',
    'aliases': 'Rainbow trout, 虹鳟',
    'identification':
        'Elongate body, no nuptial tubercles, distinctive pink/red stripe along flanks, dark back with silvery sides',
    'habitat':
        'Anadromous; inhabits coastal streams, rivers, lakes, and marine environments. Temperature range 10-24°C',
    'feeding_behavior':
        'Feeds on aquatic invertebrates, small fish, and cephalopods. Marine phase consumes more fish and squid',
    'fishing_techniques':
        'Fly fishing (streamers, nymphs), spinning with lures, trolling in lakes. Seasonal spring-summer peak',
    'size_records':
        'Max length 122cm, common length 60cm, max weight 25.9kg, max age 11 years',
    'conservation_status': 'IUCN: Least Concern (LC), CITES: Not Evaluated',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=239&GenusName=Oncorhynchus&SpeciesName=mykiss',
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
