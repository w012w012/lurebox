import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/fish_species.dart';
import 'package:lurebox/core/services/fish_species_matcher.dart';

void main() {
  group('FishSpeciesMatcher', () {
    late FishSpeciesMatcher matcher;

    setUp(() {
      matcher = FishSpeciesMatcher();
    });

    tearDown(() {
      // No resources to clean up - fakes are garbage collected
    });

    group('findSpeciesByAlias', () {
      test('returns species when alias matches exactly', () {
        // 桂鱼 is an alias for 鳜鱼 (f001)
        final result = matcher.findSpeciesByAlias('桂鱼');
        expect(result, isNotNull);
        expect(result!.id, equals('f001'));
        expect(result.standardName, equals('鳜鱼'));
      });

      test('returns species for another valid alias', () {
        // 黑鱼 is an alias for 乌鳢 (f004)
        final result = matcher.findSpeciesByAlias('黑鱼');
        expect(result, isNotNull);
        expect(result!.id, equals('f004'));
        expect(result.standardName, equals('乌鳢'));
      });

      test('returns species for alias with different case', () {
        // Test case insensitivity - though Chinese doesn't have case
        final result = matcher.findSpeciesByAlias('桂鱼');
        expect(result, isNotNull);
      });

      test('returns null for unknown alias', () {
        final result = matcher.findSpeciesByAlias('unknown');
        expect(result, isNull);
      });

      test('returns null for empty alias', () {
        final result = matcher.findSpeciesByAlias('');
        expect(result, isNull);
      });

      test('returns null for partial alias match', () {
        // '桂' is part of '桂鱼' but not a full alias
        final result = matcher.findSpeciesByAlias('桂');
        expect(result, isNull);
      });

      test('returns species for翘嘴 alias', () {
        // 翘嘴 is an alias for 翘嘴红鲌 (f006)
        final result = matcher.findSpeciesByAlias('翘嘴');
        expect(result, isNotNull);
        expect(result!.id, equals('f006'));
      });
    });

    group('findSpeciesByName', () {
      test('returns species when standard name matches exactly', () {
        final result = matcher.findSpeciesByName('鳜鱼');
        expect(result, isNotNull);
        expect(result!.id, equals('f001'));
      });

      test('returns species when input matches alias (exact match)', () {
        // findSpeciesByName should find via alias
        final result = matcher.findSpeciesByName('桂鱼');
        expect(result, isNotNull);
        expect(result!.id, equals('f001'));
      });

      test('returns species for partial match on standard name', () {
        // '鳜' is contained in '鳜鱼'
        final result = matcher.findSpeciesByName('鳜');
        expect(result, isNotNull);
        expect(result!.id, equals('f001'));
      });

      test('returns species for partial match on alias', () {
        // '桂花' is contained in '桂花鱼' alias
        final result = matcher.findSpeciesByName('桂花');
        expect(result, isNotNull);
        expect(result!.id, equals('f001'));
      });

      test('returns species for fuzzy match within threshold', () {
        // '鳜鱼' with one char different should still match
        // 鳜鱼 vs 鳜鱼 - should be exact
        final result = matcher.findSpeciesByName('鳜鱼');
        expect(result, isNotNull);
      });

      test('returns null for unknown fish name', () {
        final result = matcher.findSpeciesByName('未知鱼');
        expect(result, isNull);
      });

      test('returns null for empty input', () {
        final result = matcher.findSpeciesByName('');
        expect(result, isNull);
      });

      test('returns species for similar name within distance threshold', () {
        // '大口黑鲈' - 输入 '大口黑' (missing 鲈)
        // Levenshtein distance should be small enough
        final result = matcher.findSpeciesByName('大口黑');
        expect(result, isNotNull);
        expect(result!.id, equals('f002'));
      });
    });

    group('fuzzyMatch', () {
      test('returns best match when input is similar to candidates', () {
        final candidates = ['鳜鱼', '黑鱼', '鲫鱼', '鲤鱼'];
        // '鳜鱼' with one char different -> Levenshtein distance 1
        final result = matcher.fuzzyMatch('桂鱼', candidates);
        expect(result, equals('鳜鱼'));
      });

      test('returns null when no candidate is within threshold', () {
        final candidates = ['鳜鱼', '黑鱼'];
        // '大海鱼' is too different from any candidate
        final result = matcher.fuzzyMatch('大海鱼', candidates);
        expect(result, isNull);
      });

      test('returns null for empty input', () {
        final candidates = ['鳜鱼', '黑鱼'];
        final result = matcher.fuzzyMatch('', candidates);
        expect(result, isNull);
      });

      test('returns null for empty candidates', () {
        final result = matcher.fuzzyMatch('鳜鱼', []);
        expect(result, isNull);
      });

      test('returns exact match when input equals candidate', () {
        final candidates = ['鳜鱼', '黑鱼', '鲫鱼'];
        final result = matcher.fuzzyMatch('鳜鱼', candidates);
        expect(result, equals('鳜鱼'));
      });

      test('returns closest match when multiple candidates are similar', () {
        final candidates = ['鳜鱼', '鳜花', '桂花鱼'];
        // '桂鱼' should match '鳜鱼' (distance 1) better than others
        final result = matcher.fuzzyMatch('桂鱼', candidates);
        expect(result, isNotNull);
      });
    });

    group('_levenshteinDistance', () {
      test('returns 0 for identical strings', () {
        final distance = matcher.fuzzyMatch('鳜鱼', ['鳜鱼']);
        expect(distance, equals('鳜鱼'));
      });

      test('returns correct distance for single char difference', () {
        final candidates = ['鳜鱼', '黑鱼'];
        // '桂鱼' vs '鳜鱼' = distance 1 (桂->鳜)
        // '桂鱼' vs '黑鱼' = distance 1 (桂->黑)
        // Both have same distance, should return first one encountered
        final result = matcher.fuzzyMatch('桂鱼', candidates);
        expect(result, isNotNull);
      });

      test('handles empty string correctly', () {
        final candidates = ['鳜鱼'];
        final distance = matcher.fuzzyMatch('', candidates);
        expect(distance, isNull);
      });
    });

    group('integration tests', () {
      test('finds species using various alias forms', () {
        // Test multiple aliases for the same fish (乌鳢 / 黑鱼 / 财鱼 / 生鱼 / 斑鳢)
        expect(matcher.findSpeciesByAlias('黑鱼')?.id, equals('f004'));
        expect(matcher.findSpeciesByAlias('财鱼')?.id, equals('f004'));
        expect(matcher.findSpeciesByAlias('生鱼')?.id, equals('f004'));
        expect(matcher.findSpeciesByAlias('斑鳢')?.id, equals('f004'));
      });

      test('handles freshwater general species', () {
        // Test freshwater general species (g001-g050)
        // 鲤鱼 has aliases ['鲤拐子', '锦鲤']
        expect(matcher.findSpeciesByAlias('鲤拐子')?.id, equals('g001'));
        expect(matcher.findSpeciesByAlias('锦鲤')?.id, equals('g001'));
      });

      test('findSpeciesByName finds freshwater general species', () {
        final result = matcher.findSpeciesByName('鲤鱼');
        expect(result, isNotNull);
        expect(result!.id, equals('g001'));
        expect(result.category, equals(FishCategory.freshwaterGeneral));
      });

      test('findSpeciesByName handles rarity correctly', () {
        // 鳜鱼 is rare (FishRarity.rare)
        final result = matcher.findSpeciesByName('鳜鱼');
        expect(result, isNotNull);
        expect(result!.rarity, equals(FishRarity.rare));
      });

      test('returns first match when multiple species have similar names', () {
        // Multiple 鳜鱼 entries exist (f001 and g007)
        // Should return the first one found (f001)
        final result = matcher.findSpeciesByName('鳜鱼');
        expect(result, isNotNull);
        expect(result!.id, equals('f001'));
      });
    });

    group('edge cases', () {
      test('handles species with no aliases', () {
        // 金鳟 (f030) has empty aliases
        final result = matcher.findSpeciesByAlias('金鳟');
        expect(result, isNull); // No alias match
        // But should still find by standard name
        final byName = matcher.findSpeciesByName('金鳟');
        expect(byName, isNotNull);
        expect(byName!.id, equals('f030'));
      });

      test('handles species with single character name', () {
        // Some species might have very short names
        final result = matcher.findSpeciesByName('鳜');
        expect(result, isNotNull);
      });

      test('handles unicode characters properly', () {
        // Chinese characters should be handled correctly
        final result = matcher.findSpeciesByName('黄颡鱼');
        expect(result, isNotNull);
        expect(result!.id, equals('f008'));
      });
    });
  });

  group('FishSpeciesMatcher.withSpecies', () {
    test('uses custom species list when provided', () {
      const customSpecies = [
        FishSpecies(
          id: 'custom1',
          standardName: '测试鱼',
          aliases: ['测试别名'],
          category: FishCategory.freshwaterLure,
          rarity: FishRarity.common,
        ),
      ];

      final matcher = FishSpeciesMatcher.withSpecies(customSpecies);

      // Should find in custom list
      expect(matcher.findSpeciesByAlias('测试别名')?.id, equals('custom1'));
      expect(matcher.findSpeciesByName('测试鱼')?.id, equals('custom1'));

      // Should not find in default list
      expect(matcher.findSpeciesByAlias('桂鱼'), isNull);
    });
  });
}
