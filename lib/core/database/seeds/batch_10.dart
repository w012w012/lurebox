import 'dart:convert';

/// Species Profile Seed Data - Batch 10 (Species 28-30)
///
/// Data sourced from FishBase, Frontiers in Ecology, Israeli Journal of Aquaculture
/// Generated: 2026-04-05

/// Current timestamp for created_at/updated_at fields
final _now = DateTime.now().toIso8601String();

/// Batch 10 species profile data
/// Contains: Chinese Barb (f028), Cutthroat Trout (f029), Mandarin Fish (f030)
final List<Map<String, dynamic>> batch10SpeciesProfiles = [
  // Species 28: 翘嘴 (Chinese Barb) - f028
  {
    'species_id': 'f028',
    'aliases': 'Chinese Barb, 翘嘴, 蓝鳝鲦',
    'identification':
        'Slender, compressed body, silvery with dark lateral stripe. Sharpbelly - note the pointed belly ridge.',
    'habitat':
        'Freshwater rivers and lakes in China. Clear, flowing water with sandy or gravelly substrates.',
    'feeding_behavior':
        'Surface-oriented omnivore - insects, zooplankton, algae. Schooling, most active in daylight.',
    'fishing_techniques':
        'Small jigs, flies, or live bait in shallow waters. Best season: spring to early autumn.',
    'size_records': 'Max length 25cm, typical 15-20cm, max weight 150g',
    'conservation_status':
        'IUCN: Least Concern (LC). Common throughout Chinese waters.',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=4624&GenusName=Hemiculter&SpeciesName=leucisculus',
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

  // Species 29: 切喉鳟 (Cutthroat Trout) - f029
  {
    'species_id': 'f029',
    'aliases': 'Cutthroat Trout, 切喉鳟, 西点鳟',
    'identification':
        'Red/yellow slash mark under jaw (cutthroat sign), dark spots on back and tail, olive-green to brown body color.',
    'habitat':
        'Cold, clear freshwater streams and rivers in western US and Canada. Some subspecies are lake-resident.',
    'feeding_behavior':
        'Carnivorous - insects, crustaceans, small fish. More active during dawn/dusk and hatches.',
    'fishing_techniques':
        'Fly fishing with streamers or dry flies. Popular in urban streams near populated areas. Season: year-round.',
    'size_records': 'Max length 99cm, typical 30-50cm, max weight 18kg+',
    'conservation_status':
        'IUCN: Vulnerable (VU) due to hybridization with rainbow trout and habitat loss.',
    'source_references': jsonEncode([
      {
        'name': 'FishBase',
        'url':
            'https://www.fishbase.de/Summary/SpeciesSummary.php?ID=250&GenusName=Oncorhynchus&SpeciesName=clarkii',
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
        'name': 'Frontiers in Ecology',
        'url':
            'https://www.frontiersin.org/articles/10.3389/fevo.2019.00001/full',
        'accessed_fields': [
          'SpeciesName',
          'ConservationStatus',
          'Hybridization'
        ],
        'access_date': '2026-04-05'
      }
    ]),
    'confidence_score': 'high',
    'version': 1,
    'created_at': _now,
    'updated_at': _now,
  },

  // Species 30: 淡水鳜 (Mandarin Fish) - f030
  {
    'species_id': 'f030',
    'aliases': 'Mandarin Fish, 淡水鳜, 鳜鱼',
    'identification':
        'Oval body with sharp dorsal spines, olive-green coloration with vertical bars, large mouth with dense teeth.',
    'habitat':
        'Freshwater rivers and reservoirs in China. Prefers still or slow-moving water with vegetation and structure.',
    'feeding_behavior':
        'Ambush predator feeding on smaller fish and invertebrates. Exhibits social learning in feeding habits. Active at night.',
    'fishing_techniques':
        'Artificial lures or live bait in structured environments. Best season: late spring to autumn.',
    'size_records': 'Max length 70cm, typical 20-40cm, max weight 8kg',
    'conservation_status':
        'IUCN: Least Concern (LC). Important aquaculture species with domestication studies.',
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
      },
      {
        'name': 'Israeli Journal of Aquaculture',
        'url': 'https://www.researchgate.net/publication/235931421',
        'accessed_fields': ['SpeciesName', 'Aquaculture', 'Domestication'],
        'access_date': '2026-04-05'
      }
    ]),
    'confidence_score': 'high',
    'version': 1,
    'created_at': _now,
    'updated_at': _now,
  },
];
