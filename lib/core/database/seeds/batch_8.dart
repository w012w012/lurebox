import 'dart:convert';

/// Species Profile Seed Data - Batch 8 (Species 22-24)
///
/// Data sourced from FishBase, USGS
/// Generated: 2026-04-05

/// Current timestamp for created_at/updated_at fields
final _now = DateTime.now().toIso8601String();

/// Batch 8 species profile data
/// Contains: Tiger Muskie (f022), White Crappie (f023), White Perch (f024)
final List<Map<String, dynamic>> batch8SpeciesProfiles = [
  // Species 22: Tiger Muskie - f022
  {
    'species_id': 'f022',
    'aliases': 'Tiger Muskie, Tiger Muskellunge, 杂交梭鱼',
    'identification':
        'Hybrid between muskellunge and northern pike. Distinguished by markings: faint vertical bars mixed with spots, longer body than pure pike.',
    'habitat':
        'Clear, cool lakes and rivers with abundant prey fish. Stocked in many waters.',
    'feeding_behavior':
        'Apex predator like parent species - fish primarily. Extremely aggressive strike.',
    'fishing_techniques':
        'Large bucktail spinners, jerkbaits, large soft plastics. Trophy waters only.',
    'size_records':
        'Max length 130cm+, typical 20-40 inches, can exceed 50 inches',
    'conservation_status':
        'Not Evaluated by IUCN (hybrid). Stocked for sport fishing.',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=202438&GenusName=Esox&SpeciesName=masquinongy',
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
        'name': 'USGS',
        'url': 'https://nas.er.usgs.gov/@@SearchSpecies#',
        'accessed_fields': ['SpeciesName', 'HybridStatus'],
        'access_date': '2026-04-05'
      }
    ]),
    'confidence_score': 'high',
    'version': 1,
    'created_at': _now,
    'updated_at': _now,
  },

  // Species 23: White Crappie - f023
  {
    'species_id': 'f023',
    'aliases': 'White Crappie, 白Crappie',
    'identification':
        'Silver-white body with vertical bars (6-8), slightly forked tail, smaller mouth than black crappie.',
    'habitat':
        'Lakes, reservoirs, sluggish rivers. More tolerant of murky water than black crappie. Structure-based.',
    'feeding_behavior':
        'Schooling pelagic feeder - small fish, insects. Crepuscular feeding peaks.',
    'fishing_techniques':
        'Small jigs, minnows under slip bobber. Trolling. Bridge pilings, weed edges.',
    'size_records': 'Max length 53cm, common 20-30cm, max weight 2.4kg',
    'conservation_status': 'IUCN: Not Evaluated. Good panfish.',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=361&GenusName=Pomoxis&SpeciesName=annularis',
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

  // Species 24: 金鲈 (White Perch) - f024
  {
    'species_id': 'f024',
    'aliases': 'White Perch, 金鲈',
    'identification':
        'Silvery body without stripes (distinguishes from striped bass), slightly arched back, smaller than striped bass.',
    'habitat':
        'Coastal estuaries, tidal rivers, freshwater lakes. Brackish water preferred. Schooling fish.',
    'feeding_behavior':
        'Omnivorous - insects, small fish, crustaceans, zooplankton. Feeds throughout water column.',
    'fishing_techniques':
        'Light tackle (small spinners, worms), ice fishing. Chumming effective.',
    'size_records': 'Max length 48cm, common 15-25cm, max weight 2.2kg',
    'conservation_status':
        'IUCN: Least Concern (LC). Invasive in some northeastern US lakes.',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=302&GenusName=Morone&SpeciesName=americana',
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
