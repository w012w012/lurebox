import 'dart:convert';

/// Species Profile Seed Data - Batch 5 (Species 13-15)
///
/// Data sourced from FishBase, NOAA
/// Generated: 2026-04-05

/// Current timestamp for created_at/updated_at fields
final _now = DateTime.now().toIso8601String();

/// Batch 5 species profile data
/// Contains: Coho Salmon (f013), White Bass (f014), Channel Catfish (f015)
final List<Map<String, dynamic>> batch5SpeciesProfiles = [
  // Species 13: 银鲑 (Coho Salmon) - f013
  {
    'species_id': 'f013',
    'aliases': 'Coho Salmon, Silver Salmon, 银鲑',
    'identification':
        'Silver body with blue back, small black spots on back and upper tail lobe. Reddish hue on sides during spawning.',
    'habitat':
        'Anadromous - coastal streams and marine waters. Spawns in small coastal streams with gravel substrate.',
    'feeding_behavior':
        'At sea: herring, sandfish, crustaceans. Becomes aggressive feeder prior to spawning.',
    'fishing_techniques':
        'Spinning/casting spoons, fly fishing (egg patterns, streamers). In-river: lures mimicking baitfish.',
    'size_records':
        'Max length 78cm, common 50-70cm, max weight 15kg, max age 5 years',
    'conservation_status':
        'IUCN: Least Concern (LC). Sustainable populations overall.',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=243&GenusName=Oncorhynchus&SpeciesName=kisutch',
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
        'name': 'NOAA Fisheries',
        'url': 'https://www.fisheries.noaa.gov/species/coho-salmon',
        'accessed_fields': ['SpeciesDescription', 'Habitat', 'Diet', 'Fishing'],
        'access_date': '2026-04-05'
      }
    ]),
    'confidence_score': 'high',
    'version': 1,
    'created_at': _now,
    'updated_at': _now,
  },

  // Species 14: 玻璃梭鲈 (White Bass) - f014
  {
    'species_id': 'f014',
    'aliases': 'White Bass, 玻璃梭鲈',
    'identification':
        'Silver-white body with dark horizontal stripes, relatively small mouth, moderately forked tail.',
    'habitat':
        'Large rivers, reservoirs, estuaries. Prefers clean, flowing water with some salinity tolerance.',
    'feeding_behavior':
        'Schooling pelagic feeder - zooplankton, insects, small fish. Often seen chasing shad at surface.',
    'fishing_techniques':
        'Inline spinners, small cranks, live shad. Surface schooling in spring. Drifting/trolling.',
    'size_records':
        'Max length 45cm, common 25-35cm, max weight 2.3kg, max age 7 years',
    'conservation_status': 'IUCN: Not Evaluated. Abundant in many waters.',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=305&GenusName=Morone&SpeciesName=chrysops',
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

  // Species 15: 斑点叉尾鮰 (Channel Catfish) - f015
  {
    'species_id': 'f015',
    'aliases': 'Channel Catfish, 斑点叉尾鮰',
    'identification':
        'Slate gray body with dark spots (younger fish), forked tail, smooth skin, 8 barbels around mouth.',
    'habitat':
        'Rivers, lakes, reservoirs with varied bottom (sand, gravel, mud). Slightly saline water OK.',
    'feeding_behavior':
        'Nocturnal omnivore - fish, insects, crustaceans, detritus. Highly adaptive feeder.',
    'fishing_techniques':
        'Stink baits, cut bait, live bait (crayfish/shad). Bottom fishing. Brackish estuaries.',
    'size_records':
        'Max length 132cm, common 40-60cm, max weight 26kg, max age 24 years',
    'conservation_status': 'IUCN: Least Concern (LC). Excellent sport fish.',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=259&GenusName=Ictalurus&SpeciesName=punctatus',
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
