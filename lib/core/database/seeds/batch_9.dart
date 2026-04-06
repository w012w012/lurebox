import 'dart:convert';

/// Species Profile Seed Data - Batch 9 (Species 25-27)
///
/// Data sourced from FishBase, NOAA
/// Generated: 2026-04-05

/// Current timestamp for created_at/updated_at fields
final _now = DateTime.now().toIso8601String();

/// Batch 9 species profile data
/// Contains: Atlantic Salmon (f025), Steelhead (f026), Chinese Mahseer (f027)
final List<Map<String, dynamic>> batch9SpeciesProfiles = [
  // Species 25: 大西洋鲑 (Atlantic Salmon) - f025
  {
    'species_id': 'f025',
    'aliases': 'Atlantic Salmon, 大西洋鲑, 三文鱼',
    'identification':
        'Silver body with dark blue back, black spots mainly on upper body. Red/yellow lateral line. Slender, streamlined shape.',
    'habitat':
        'Anadromous - North Atlantic. Spawns in clean, cold rivers with gravel substrate. Coastal marine waters.',
    'feeding_behavior':
        'At sea: cod, herring, sandeels, crustaceans. Becomes territorial in freshwater (stops feeding).',
    'fishing_techniques':
        'Fly fishing (dry flies, nymphs, streamers), spinning with small spoons. Prime: clear rivers.',
    'size_records':
        'Max length 150cm, typical 60-100cm, max weight 38kg, max age 13 years',
    'conservation_status':
        'IUCN: Least Concern (LC). Endangered in some specific populations (inner Bay of Fundy).',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=240&GenusName=Salmo&SpeciesName=salar',
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

  // Species 26: Steelhead (anadromous Rainbow Trout) - f026
  {
    'species_id': 'f026',
    'aliases': 'Steelhead, 降海型虹鳟, 海鳟',
    'identification':
        'Rainbow trout that migrates to sea. Silvery body with rainbow stripe, heavily spotted, larger size than resident rainbow.',
    'habitat':
        'Anadromous - Pacific coast. Spawns in coastal streams, rears in ocean. Clean, cold water required.',
    'feeding_behavior':
        'At sea: herring, anchovies, squid, crustaceans. Aggressive feeder, grows rapidly in salt water.',
    'fishing_techniques':
        'Fly fishing (egg patterns, streamers), spinning with Vibrax spinners. Drift fishing in steelhead rivers.',
    'size_records': 'Max length 120cm, typical 50-80cm, max weight 18kg+',
    'conservation_status':
        'IUCN: Not Evaluated. Some steelhead runs endangered (see NOAA).',
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
          'Size'
        ],
        'access_date': '2026-04-05'
      },
      {
        'name': 'NOAA Fisheries',
        'url': 'https://www.fisheries.noaa.gov/species/steelhead-trout',
        'accessed_fields': ['SpeciesName', 'Habitat', 'ConservationStatus'],
        'access_date': '2026-04-05'
      }
    ]),
    'confidence_score': 'high',
    'version': 1,
    'created_at': _now,
    'updated_at': _now,
  },

  // Species 27: 军鱼 (Chinese Mahseer) - f027
  {
    'species_id': 'f027',
    'aliases': 'Chinese Mahseer, 军鱼, 高原鳅',
    'identification':
        'Robust, elongated body, grayish-silver with darker back. Typical cyprinid shape with inferior mouth.',
    'habitat':
        'Highland rivers and streams in Sichuan/Tibet region. Cold, fast-flowing, well-oxygenated water.',
    'feeding_behavior':
        'Omnivorous bottom feeder - algae, aquatic plants, insects, detritus. Schooling behavior.',
    'fishing_techniques':
        'Small flies, nymphs, artificial insects. Light tackle. Mountain stream techniques.',
    'size_records': 'Max length 60cm+, typical 20-40cm, max weight 3kg+',
    'conservation_status':
        'IUCN: Vulnerable (VU) in some regions due to damming and habitat loss.',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=50408&GenusName=Schizothorax&SpeciesName=oconnori',
        'accessed_fields': [
          'SpeciesName',
          'CommonNames',
          'Morphology',
          'Habitat',
          'Diet',
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
