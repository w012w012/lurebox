import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/user_species_alias.dart';

void main() {
  group('UserSpeciesAlias.fromMap', () {
    test('creates instance with all fields from map', () {
      final timestamp = 1718444400000; // 2024-06-15 10:00:00 UTC
      final map = {
        'id': 42,
        'user_alias': '小黄鱼',
        'species_id': 'fish_001',
        'created_at': timestamp,
      };

      final alias = UserSpeciesAlias.fromMap(map);

      expect(alias.id, equals(42));
      expect(alias.userAlias, equals('小黄鱼'));
      expect(alias.speciesId, equals('fish_001'));
      expect(alias.createdAt.millisecondsSinceEpoch, equals(timestamp));
    });

    test('creates instance with null id when id is null', () {
      final timestamp = 1718444400000;
      final map = {
        'id': null,
        'user_alias': '翘嘴',
        'species_id': 'fish_002',
        'created_at': timestamp,
      };

      final alias = UserSpeciesAlias.fromMap(map);

      expect(alias.id, isNull);
      expect(alias.userAlias, equals('翘嘴'));
      expect(alias.speciesId, equals('fish_002'));
      expect(alias.createdAt.millisecondsSinceEpoch, equals(timestamp));
    });

    test('parses user_alias correctly', () {
      final map = {
        'user_alias': '黑鱼',
        'species_id': 'fish_003',
        'created_at': 1718444400000,
      };

      final alias = UserSpeciesAlias.fromMap(map);
      expect(alias.userAlias, equals('黑鱼'));
    });

    test('parses species_id correctly', () {
      final map = {
        'user_alias': '鲈鱼',
        'species_id': 'bass_001',
        'created_at': 1718444400000,
      };

      final alias = UserSpeciesAlias.fromMap(map);
      expect(alias.speciesId, equals('bass_001'));
    });

    test('handles numeric timestamp for created_at', () {
      final timestamp = 1718444400000;
      final map = {
        'user_alias': 'test_alias',
        'species_id': 'fish_test',
        'created_at': timestamp,
      };

      final alias = UserSpeciesAlias.fromMap(map);
      expect(alias.createdAt.millisecondsSinceEpoch, equals(timestamp));
    });
  });

  group('UserSpeciesAlias.toMap', () {
    test('outputs correct map including id when id is not null', () {
      final createdAt = DateTime.fromMillisecondsSinceEpoch(1718444400000);
      final alias = UserSpeciesAlias(
        id: 10,
        userAlias: '桂鱼',
        speciesId: 'fish_010',
        createdAt: createdAt,
      );

      final result = alias.toMap();

      expect(result.containsKey('id'), isTrue);
      expect(result['id'], equals(10));
      expect(result['user_alias'], equals('桂鱼'));
      expect(result['species_id'], equals('fish_010'));
      expect(result['created_at'], equals(1718444400000));
    });

    test('outputs correct map excluding id when id is null', () {
      final createdAt = DateTime.fromMillisecondsSinceEpoch(1718444400000);
      final alias = UserSpeciesAlias(
        id: null,
        userAlias: '鲢鱼',
        speciesId: 'fish_011',
        createdAt: createdAt,
      );

      final result = alias.toMap();

      expect(result.containsKey('id'), isFalse);
      expect(result['user_alias'], equals('鲢鱼'));
      expect(result['species_id'], equals('fish_011'));
      expect(result['created_at'], equals(1718444400000));
    });

    test('excludes id when id is null even if it was set during construction', () {
      final alias = UserSpeciesAlias(
        id: null,
        userAlias: '罗非',
        speciesId: 'fish_012',
        createdAt: DateTime.now(),
      );

      final result = alias.toMap();
      expect(result.containsKey('id'), isFalse);
    });

    test('includes id when id is 0 (non-null)', () {
      final alias = UserSpeciesAlias(
        id: 0, // 0 is a valid non-null id
        userAlias: 'test',
        speciesId: 'fish_013',
        createdAt: DateTime.now(),
      );

      final result = alias.toMap();
      expect(result.containsKey('id'), isTrue);
      expect(result['id'], equals(0));
    });
  });

  group('UserSpeciesAlias.copyWith', () {
    test('preserves unmodified fields when userAlias is changed', () {
      final original = UserSpeciesAlias(
        id: 1,
        userAlias: 'original_alias',
        speciesId: 'fish_001',
        createdAt: DateTime.parse('2024-06-15T10:00:00.000'),
      );

      final copy = original.copyWith(userAlias: 'new_alias');

      expect(copy.userAlias, equals('new_alias'));
      expect(copy.id, equals(1));
      expect(copy.speciesId, equals('fish_001'));
      expect(copy.createdAt, equals(DateTime.parse('2024-06-15T10:00:00.000')));
    });

    test('preserves unmodified fields when speciesId is changed', () {
      final original = UserSpeciesAlias(
        id: 2,
        userAlias: 'my_alias',
        speciesId: 'fish_old',
        createdAt: DateTime.now(),
      );

      final copy = original.copyWith(speciesId: 'fish_new');

      expect(copy.speciesId, equals('fish_new'));
      expect(copy.id, equals(2));
      expect(copy.userAlias, equals('my_alias'));
    });

    test('can change multiple fields at once', () {
      final original = UserSpeciesAlias(
        id: 1,
        userAlias: 'alias1',
        speciesId: 'fish_001',
        createdAt: DateTime.now(),
      );

      final copy = original.copyWith(
        userAlias: 'alias2',
        speciesId: 'fish_002',
      );

      expect(copy.userAlias, equals('alias2'));
      expect(copy.speciesId, equals('fish_002'));
      expect(copy.id, equals(1));
    });

    test('can set id to non-null value with copyWith', () {
      final original = UserSpeciesAlias(
        id: null,
        userAlias: 'alias',
        speciesId: 'fish',
        createdAt: DateTime.now(),
      );

      final copy = original.copyWith(id: 99);

      expect(copy.id, equals(99));
      expect(copy.userAlias, equals('alias'));
    });

    test('copyWith with id: null preserves original id (null coalescing behavior)', () {
      final original = UserSpeciesAlias(
        id: 5,
        userAlias: 'alias',
        speciesId: 'fish',
        createdAt: DateTime.now(),
      );

      final copy = original.copyWith(id: null);

      // copyWith uses `id ?? this.id`, so passing null preserves original value
      expect(copy.id, equals(5));
      expect(copy.userAlias, equals('alias'));
    });
  });

  group('UserSpeciesAlias equality - id based', () {
    test('two instances with same non-null id are equal', () {
      final alias1 = UserSpeciesAlias(
        id: 42,
        userAlias: 'alias_a',
        speciesId: 'fish_a',
        createdAt: DateTime.now(),
      );
      final alias2 = UserSpeciesAlias(
        id: 42,
        userAlias: 'alias_b',
        speciesId: 'fish_b', // different - not used when id is non-null
        createdAt: DateTime.now(),
      );

      expect(alias1, equals(alias2));
    });

    test('two instances with different non-null id are not equal', () {
      final alias1 = UserSpeciesAlias(
        id: 1,
        userAlias: 'same_alias',
        speciesId: 'same_species',
        createdAt: DateTime.now(),
      );
      final alias2 = UserSpeciesAlias(
        id: 2,
        userAlias: 'same_alias',
        speciesId: 'same_species',
        createdAt: DateTime.now(),
      );

      expect(alias1, isNot(equals(alias2)));
    });

    test('hashCode is based on id when id is non-null', () {
      final alias1 = UserSpeciesAlias(
        id: 99,
        userAlias: 'name1',
        speciesId: 'species1',
        createdAt: DateTime.now(),
      );
      final alias2 = UserSpeciesAlias(
        id: 99,
        userAlias: 'name2', // different - not used when id is non-null
        speciesId: 'species2', // different - not used when id is non-null
        createdAt: DateTime.now(),
      );

      expect(alias1.hashCode, equals(alias2.hashCode));
    });
  });

  group('UserSpeciesAlias equality - userAlias + speciesId based', () {
    test('two instances with null id and same userAlias + speciesId are equal', () {
      final alias1 = UserSpeciesAlias(
        id: null,
        userAlias: 'my_alias',
        speciesId: 'fish_123',
        createdAt: DateTime.now(),
      );
      final alias2 = UserSpeciesAlias(
        id: null,
        userAlias: 'my_alias',
        speciesId: 'fish_123',
        createdAt: DateTime.now(),
      );

      expect(alias1, equals(alias2));
    });

    test('two instances with null id but different userAlias are not equal', () {
      final alias1 = UserSpeciesAlias(
        id: null,
        userAlias: 'alias_one',
        speciesId: 'fish_same',
        createdAt: DateTime.now(),
      );
      final alias2 = UserSpeciesAlias(
        id: null,
        userAlias: 'alias_two',
        speciesId: 'fish_same',
        createdAt: DateTime.now(),
      );

      expect(alias1, isNot(equals(alias2)));
    });

    test('two instances with null id but different speciesId are not equal', () {
      final alias1 = UserSpeciesAlias(
        id: null,
        userAlias: 'same_alias',
        speciesId: 'fish_one',
        createdAt: DateTime.now(),
      );
      final alias2 = UserSpeciesAlias(
        id: null,
        userAlias: 'same_alias',
        speciesId: 'fish_two',
        createdAt: DateTime.now(),
      );

      expect(alias1, isNot(equals(alias2)));
    });

    test('hashCode is based on userAlias + speciesId when id is null', () {
      final alias1 = UserSpeciesAlias(
        id: null,
        userAlias: 'common_alias',
        speciesId: 'common_species',
        createdAt: DateTime.now(),
      );
      final alias2 = UserSpeciesAlias(
        id: null,
        userAlias: 'common_alias',
        speciesId: 'common_species',
        createdAt: DateTime.now(),
      );

      expect(alias1.hashCode, equals(alias2.hashCode));
    });

    test('null id instance and non-null id instance with same userAlias+speciesId are not equal', () {
      final aliasNullId = UserSpeciesAlias(
        id: null,
        userAlias: 'alias_x',
        speciesId: 'fish_x',
        createdAt: DateTime.now(),
      );
      final aliasNonNullId = UserSpeciesAlias(
        id: 100, // different id - equality checks id first
        userAlias: 'alias_x',
        speciesId: 'fish_x',
        createdAt: DateTime.now(),
      );

      // Non-null id takes precedence - 100 != null so they are not equal
      expect(aliasNullId, isNot(equals(aliasNonNullId)));
    });
  });

  group('UserSpeciesAlias toString', () {
    test('returns formatted string with id, userAlias, speciesId', () {
      final alias = UserSpeciesAlias(
        id: 5,
        userAlias: '黑鱼',
        speciesId: 'fish_001',
        createdAt: DateTime.now(),
      );

      final result = alias.toString();

      expect(result, contains('id: 5'));
      expect(result, contains('userAlias: 黑鱼'));
      expect(result, contains('speciesId: fish_001'));
    });

    test('handles null id in toString', () {
      final alias = UserSpeciesAlias(
        id: null,
        userAlias: '鲈鱼',
        speciesId: 'bass_001',
        createdAt: DateTime.now(),
      );

      final result = alias.toString();

      expect(result, contains('id: null'));
      expect(result, contains('userAlias: 鲈鱼'));
    });
  });
}