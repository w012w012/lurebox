import 'dart:convert';

/// Species Profile Seed Data - Batch 2 (Species 4-6)
///
/// Data sourced from FishBase
/// Generated: 2026-04-05
///
/// NOTE: Species 4 (Brown Trout) and 5 (Northern Pike) do not have exact
/// matches in fish_species table. Using placeholder IDs f003 and f006
/// which are in the same category (freshwaterLure).
/// Species 6 (Northern Snakehead / 乌鳢) IS an exact match to f004.

/// Current timestamp for created_at/updated_at fields
final _now = DateTime.now().toIso8601String();

/// Batch 2 species profile data
/// Contains: Brown Trout (f003*), Northern Pike (f006*), Northern Snakehead (f004)
final List<Map<String, dynamic>> batch2SpeciesProfiles = [
  // Species 4: 棕鳟 (Brown Trout) - f003 (placeholder - not in fish_species)
  {
    'species_id': 'f003',
    'aliases': 'Brown Trout, 褐鳟',
    'identification':
        'Brownish body with black spots and red/orange spots surrounded by pale halos. Typical trout shape.',
    'habitat':
        'Cold, clear streams and lakes. Temperature range 4-20°C. Native to Europe, introduced worldwide.',
    'feeding_behavior':
        'Carnivorous - insects, small fish, crustaceans. More active at dawn/dusk.',
    'fishing_techniques':
        'Fly fishing (dry flies, nymphs), spinning with small lures. Best in cooler months.',
    'size_records': 'Max length 100cm+, common 30-50cm, max weight 20kg+',
    'conservation_status':
        'IUCN: Least Concern (LC). Invasive in many regions.',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=223&GenusName=Salmo&SpeciesName=trutta',
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

  // Species 5: Northern Pike (狗鱼) - f006 (placeholder - not in fish_species)
  {
    'species_id': 'f006',
    'aliases': 'Pike, Northern Pike, 狗鱼',
    'identification':
        'Elongated body, duckbill-shaped jaw, sharp teeth, greenish-brown with lighter spots.',
    'habitat':
        'Freshwater lakes, rivers, marshes. Prefers slow-moving warm water with vegetation.',
    'feeding_behavior':
        'Aggressive predator - fish, frogs, small mammals. Ambush hunter.',
    'fishing_techniques':
        'Large lures (spoons, jerkbaits), live bait. Targeting weed edges and drop-offs.',
    'size_records': 'Max length 130cm+, common 50-80cm, max weight 25kg+',
    'conservation_status': 'IUCN: Least Concern (LC)',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=1983&GenusName=Esox&SpeciesName=lucius',
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

  // Species 6: 黑鱼 (Northern Snakehead) - f004 (exact match: 乌鳢, Channa argus)
  {
    'species_id': 'f004',
    'aliases': 'Snakehead, 黑鱼, 乌鳢',
    'identification':
        'Snake-like body, long dorsal fin, cylindrical shape, dark brown with vertical bars.',
    'habitat':
        'Freshwater ponds, lakes, rivers. Can breathe air, survives in low oxygen water.',
    'feeding_behavior':
        'Carnivorous - fish, frogs, insects. Aggressive predator, strikes lures readily.',
    'fishing_techniques':
        'Topwater lures, spinnerbaits, rubber worms. Vegetation-rich areas.',
    'size_records': 'Max length 85cm, common 30-50cm, max weight 5kg+',
    'conservation_status':
        'Invasive in North America. Prohibited in many states.',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=204&GenusName=Channa&SpeciesName=argus',
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
