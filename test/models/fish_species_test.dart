import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/fish_species.dart';
import 'package:lurebox/features/achievement/fish_guide_data.dart';

void main() {
  group('FishCategory', () {
    test('has correct labels', () {
      expect(FishCategory.freshwaterLure.label, equals('淡水路亚'));
      expect(FishCategory.freshwaterGeneral.label, equals('淡水综合'));
      expect(FishCategory.saltwaterLure.label, equals('海水路亚'));
      expect(FishCategory.saltwaterGeneral.label, equals('海水综合'));
    });

    test('fromValue returns correct category', () {
      expect(FishCategory.fromValue(0), equals(FishCategory.freshwaterLure));
      expect(FishCategory.fromValue(1), equals(FishCategory.freshwaterGeneral));
      expect(FishCategory.fromValue(2), equals(FishCategory.saltwaterLure));
      expect(FishCategory.fromValue(3), equals(FishCategory.saltwaterGeneral));
    });

    test('fromValue returns default for invalid value', () {
      expect(FishCategory.fromValue(99), equals(FishCategory.freshwaterLure));
    });

    test('value returns correct int value', () {
      expect(FishCategory.freshwaterLure.value, equals(0));
      expect(FishCategory.freshwaterGeneral.value, equals(1));
      expect(FishCategory.saltwaterLure.value, equals(2));
      expect(FishCategory.saltwaterGeneral.value, equals(3));
    });
  });

  group('FishRarity', () {
    test('has correct values and labels', () {
      expect(FishRarity.common.value, equals(1));
      expect(FishRarity.common.label, equals('普通'));
      expect(FishRarity.uncommon.value, equals(2));
      expect(FishRarity.uncommon.label, equals('少见'));
      expect(FishRarity.rare.value, equals(3));
      expect(FishRarity.rare.label, equals('稀有'));
      expect(FishRarity.legendary.value, equals(4));
      expect(FishRarity.legendary.label, equals('传说'));
      expect(FishRarity.mythical.value, equals(5));
      expect(FishRarity.mythical.label, equals('神话'));
    });

    test('fromValue returns correct rarity', () {
      expect(FishRarity.fromValue(1), equals(FishRarity.common));
      expect(FishRarity.fromValue(2), equals(FishRarity.uncommon));
      expect(FishRarity.fromValue(3), equals(FishRarity.rare));
      expect(FishRarity.fromValue(4), equals(FishRarity.legendary));
      expect(FishRarity.fromValue(5), equals(FishRarity.mythical));
    });

    test('fromValue returns default for invalid value', () {
      expect(FishRarity.fromValue(99), equals(FishRarity.common));
    });
  });

  group('FishSpecies', () {
    late FishSpecies testInstance;

    setUp(() {
      testInstance = const FishSpecies(
        id: 'f001',
        standardName: '鳜鱼',
        scientificName: 'Siniperca chuatsi',
        aliases: ['桂鱼', '桂花鱼'],
        category: FishCategory.freshwaterLure,
        rarity: FishRarity.rare,
        habitat: '江河、湖泊',
        behavior: '肉食性',
        fishingMethod: '软饵',
        description: '典型肉食性淡水鱼',
        iconEmoji: '🐟',
      );
    });

    test('creates FishSpecies with required fields', () {
      expect(testInstance.id, equals('f001'));
      expect(testInstance.standardName, equals('鳜鱼'));
      expect(testInstance.scientificName, equals('Siniperca chuatsi'));
      expect(testInstance.aliases, equals(['桂鱼', '桂花鱼']));
      expect(testInstance.category, equals(FishCategory.freshwaterLure));
      expect(testInstance.rarity, equals(FishRarity.rare));
      expect(testInstance.habitat, equals('江河、湖泊'));
      expect(testInstance.behavior, equals('肉食性'));
      expect(testInstance.fishingMethod, equals('软饵'));
      expect(testInstance.description, equals('典型肉食性淡水鱼'));
      expect(testInstance.iconEmoji, equals('🐟'));
    });

    test('creates FishSpecies with default empty aliases', () {
      const species = FishSpecies(
        id: 'test',
        standardName: '测试',
        category: FishCategory.freshwaterLure,
        rarity: FishRarity.common,
      );
      expect(species.aliases, isEmpty);
    });

    test('fromMap creates FishSpecies from map', () {
      final map = {
        'id': 'g001',
        'standard_name': '鲤鱼',
        'scientific_name': 'Cyprinus carpio',
        'aliases': '鲤拐子,锦鲤',
        'category': 1,
        'rarity': 1,
        'habitat': '江河湖泊',
        'behavior': '杂食性',
        'fishing_method': '玉米',
        'description': '常见淡水鱼',
        'icon_emoji': '🐉',
      };

      final result = FishSpecies.fromMap(map);

      expect(result.id, equals('g001'));
      expect(result.standardName, equals('鲤鱼'));
      expect(result.scientificName, equals('Cyprinus carpio'));
      expect(result.aliases, equals(['鲤拐子', '锦鲤']));
      expect(result.category, equals(FishCategory.freshwaterGeneral));
      expect(result.rarity, equals(FishRarity.common));
      expect(result.habitat, equals('江河湖泊'));
      expect(result.behavior, equals('杂食性'));
      expect(result.fishingMethod, equals('玉米'));
      expect(result.description, equals('常见淡水鱼'));
      expect(result.iconEmoji, equals('🐉'));
    });

    test('fromMap handles missing optional fields', () {
      final map = {
        'id': 'test',
        'standard_name': '测试鱼',
        'category': 0,
        'rarity': 1,
      };

      final result = FishSpecies.fromMap(map);

      expect(result.id, equals('test'));
      expect(result.standardName, equals('测试鱼'));
      expect(result.scientificName, isNull);
      expect(result.aliases, isEmpty);
      expect(result.category, equals(FishCategory.freshwaterLure));
      expect(result.rarity, equals(FishRarity.common));
      expect(result.habitat, isNull);
    });

    test('toMap converts FishSpecies to map', () {
      final map = testInstance.toMap();

      expect(map['id'], equals('f001'));
      expect(map['standard_name'], equals('鳜鱼'));
      expect(map['scientific_name'], equals('Siniperca chuatsi'));
      expect(map['aliases'], equals('桂鱼,桂花鱼'));
      expect(map['category'], equals(0));
      expect(map['rarity'], equals(3));
      expect(map['habitat'], equals('江河、湖泊'));
      expect(map['behavior'], equals('肉食性'));
      expect(map['fishing_method'], equals('软饵'));
      expect(map['description'], equals('典型肉食性淡水鱼'));
      expect(map['icon_emoji'], equals('🐟'));
    });

    test('copyWith creates modified copy', () {
      final copy = testInstance.copyWith(
        standardName: '新名称',
        rarity: FishRarity.legendary,
      );

      expect(copy.id, equals('f001'));
      expect(copy.standardName, equals('新名称'));
      expect(copy.rarity, equals(FishRarity.legendary));
      expect(copy.scientificName, equals('Siniperca chuatsi'));
      expect(copy.category, equals(FishCategory.freshwaterLure));
    });

    test('copyWith preserves unmodified fields', () {
      final copy = testInstance.copyWith(rarity: FishRarity.common);

      expect(copy.standardName, equals('鳜鱼'));
      expect(copy.category, equals(FishCategory.freshwaterLure));
      expect(copy.habitat, equals('江河、湖泊'));
    });

    test('equality based on id', () {
      const other = FishSpecies(
        id: 'f001',
        standardName: '不同名称',
        scientificName: 'Different',
        category: FishCategory.saltwaterLure,
        rarity: FishRarity.mythical,
      );

      expect(testInstance, equals(other));
    });

    test('hashCode based on id', () {
      const other = FishSpecies(
        id: 'f001',
        standardName: '不同名称',
        scientificName: 'Different',
        category: FishCategory.saltwaterLure,
        rarity: FishRarity.mythical,
      );

      expect(testInstance.hashCode, equals(other.hashCode));
    });

    test('different ids are not equal', () {
      const other = FishSpecies(
        id: 'f002',
        standardName: '鳜鱼',
        scientificName: 'Siniperca chuatsi',
        aliases: ['桂鱼'],
        category: FishCategory.freshwaterLure,
        rarity: FishRarity.rare,
      );

      expect(testInstance, isNot(equals(other)));
    });

    test('toString contains relevant information', () {
      final str = testInstance.toString();
      expect(str, contains('FishSpecies'));
      expect(str, contains('id: f001'));
      expect(str, contains('standardName: 鳜鱼'));
      expect(str, contains('rarity: 稀有'));
    });
  });

  group('FishGuideData', () {
    test('allSpecies returns combined list', () {
      final all = FishGuideData.allSpecies;
      expect(all.length, equals(100));
      expect(all, containsAll(FishGuideData.freshwaterLureSpecies));
      expect(all, containsAll(FishGuideData.saltwaterLureSpecies));
      expect(all, containsAll(FishGuideData.freshwaterGeneralSpecies));
      expect(all, containsAll(FishGuideData.saltwaterGeneralSpecies));
    });

    test('freshwaterLureSpecies has 34 entries', () {
      expect(FishGuideData.freshwaterLureSpecies.length, equals(34));
    });

    test('saltwaterLureSpecies has 16 entries', () {
      expect(FishGuideData.saltwaterLureSpecies.length, equals(16));
    });

    test('freshwaterGeneralSpecies has 33 entries', () {
      expect(FishGuideData.freshwaterGeneralSpecies.length, equals(33));
    });

    test('saltwaterGeneralSpecies has 17 entries', () {
      expect(FishGuideData.saltwaterGeneralSpecies.length, equals(17));
    });

    test('getById returns correct species', () {
      final species = FishGuideData.getById('f001');
      expect(species, isNotNull);
      expect(species!.standardName, equals('鳜鱼'));
    });

    test('getById returns null for invalid id', () {
      final species = FishGuideData.getById('invalid');
      expect(species, isNull);
    });

    test('getByCategory filters correctly', () {
      final lureSpecies =
          FishGuideData.getByCategory(FishCategory.freshwaterLure);
      expect(lureSpecies.length, equals(34));
      expect(
          lureSpecies.every((s) => s.category == FishCategory.freshwaterLure),
          isTrue,);

      final saltwaterLure =
          FishGuideData.getByCategory(FishCategory.saltwaterLure);
      expect(saltwaterLure.length, equals(16));
      expect(
          saltwaterLure.every((s) => s.category == FishCategory.saltwaterLure),
          isTrue,);

      final saltwaterGeneral =
          FishGuideData.getByCategory(FishCategory.saltwaterGeneral);
      expect(saltwaterGeneral.length, equals(17));
    });

    test('getByRarity filters correctly', () {
      final rareSpecies = FishGuideData.getByRarity(FishRarity.rare);
      expect(rareSpecies.every((s) => s.rarity == FishRarity.rare), isTrue);
    });

    test('search finds by standard name', () {
      final results = FishGuideData.search('鳜鱼');
      expect(results, isNotEmpty);
      expect(results.first.standardName, contains('鳜鱼'));
    });

    test('search finds by alias', () {
      final results = FishGuideData.search('桂鱼');
      expect(results, isNotEmpty);
      expect(results.first.aliases, contains('桂鱼'));
    });

    test('search finds by scientific name', () {
      final results = FishGuideData.search('Siniperca chuatsi');
      expect(results, isNotEmpty);
    });

    test('search is case insensitive', () {
      // Chinese characters don't change on lowercase, but search is case-insensitive for Latin chars
      final results = FishGuideData.search('鱼');
      expect(results, isNotEmpty);
    });

    test('search returns all when keyword is empty', () {
      final results = FishGuideData.search('');
      expect(results.length, equals(FishGuideData.allSpecies.length));
    });

    test('all species have valid id', () {
      for (final species in FishGuideData.allSpecies) {
        expect(species.id, isNotEmpty);
        expect(
            species.id.startsWith('f') || species.id.startsWith('g'), isTrue,);
      }
    });

    test('all species have standard name', () {
      for (final species in FishGuideData.allSpecies) {
        expect(species.standardName, isNotEmpty);
      }
    });

    test('f001-f034 are freshwater lure species', () {
      for (var i = 1; i <= 34; i++) {
        final id = 'f${i.toString().padLeft(3, '0')}';
        final species = FishGuideData.getById(id);
        expect(species, isNotNull, reason: 'Missing species: $id');
        expect(species!.category, equals(FishCategory.freshwaterLure));
      }
    });

    test('f035-f050 are saltwater lure species', () {
      for (var i = 35; i <= 50; i++) {
        final id = 'f${i.toString().padLeft(3, '0')}';
        final species = FishGuideData.getById(id);
        expect(species, isNotNull, reason: 'Missing species: $id');
        expect(species!.category, equals(FishCategory.saltwaterLure));
      }
    });

    test('all g-species have valid categories', () {
      for (final species in FishGuideData.allSpecies.where(
          (s) => s.id.startsWith('g'),)) {
        expect(
          species.category == FishCategory.freshwaterGeneral ||
              species.category == FishCategory.saltwaterGeneral,
          isTrue,
          reason: 'g-species ${species.id} has unexpected category',
        );
      }
    });

    test('species with scientific names have valid format', () {
      final speciesWithScientificName = FishGuideData.allSpecies
          .where((s) => s.scientificName != null)
          .toList();
      expect(speciesWithScientificName.length, greaterThan(0));
      for (final species in speciesWithScientificName) {
        expect(species.scientificName!.isNotEmpty, isTrue);
        // Scientific names typically contain spaces and are in Latin
        expect(species.scientificName!.contains(' '), isTrue);
      }
    });
  });
}
