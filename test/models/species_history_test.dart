import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/species_history.dart';

void main() {
  group('SpeciesHistory', () {
    group('fromMap', () {
      test('with all fields parses correctly', () {
        final map = {
          'id': 1,
          'name': 'Bass',
          'use_count': 5,
          'is_deleted': 1,
          'created_at': '2024-03-15T10:30:00.000',
        };

        final result = SpeciesHistory.fromMap(map);

        expect(result.id, equals(1));
        expect(result.name, equals('Bass'));
        expect(result.useCount, equals(5));
        expect(result.isDeleted, isTrue);
        expect(result.createdAt, equals(DateTime(2024, 3, 15, 10, 30)));
      });

      test('with default useCount uses 1 when use_count is null', () {
        final map = {
          'id': 2,
          'name': 'Trout',
          'use_count': null,
          'is_deleted': 0,
          'created_at': '2024-06-01T00:00:00.000',
        };

        final result = SpeciesHistory.fromMap(map);

        expect(result.useCount, equals(1));
      });

      test('with missing use_count key uses default 1', () {
        final map = {
          'id': 3,
          'name': 'Salmon',
          'is_deleted': 0,
          'created_at': '2024-07-20T00:00:00.000',
        };

        final result = SpeciesHistory.fromMap(map);

        expect(result.useCount, equals(1));
      });

      test('with is_deleted as 0 sets isDeleted to false', () {
        final map = {
          'id': 4,
          'name': 'Pike',
          'use_count': 3,
          'is_deleted': 0,
          'created_at': '2024-08-10T00:00:00.000',
        };

        final result = SpeciesHistory.fromMap(map);

        expect(result.isDeleted, isFalse);
      });
    });

    group('toMap', () {
      test('outputs correct map structure', () {
        final history = SpeciesHistory(
          id: 1,
          name: 'Bass',
          useCount: 5,
          isDeleted: true,
          createdAt: DateTime(2024, 3, 15, 10, 30),
        );

        final map = history.toMap();

        expect(map['id'], equals(1));
        expect(map['name'], equals('Bass'));
        expect(map['use_count'], equals(5));
        expect(map['is_deleted'], equals(1));
        expect(map['created_at'], equals('2024-03-15T10:30:00.000'));
      });

      test('toMap output can be round-tripped through fromMap', () {
        final original = SpeciesHistory(
          id: 10,
          name: 'Walleye',
          useCount: 7,
          isDeleted: false,
          createdAt: DateTime(2024, 12, 25),
        );

        final map = original.toMap();
        final restored = SpeciesHistory.fromMap(map);

        expect(restored.id, equals(original.id));
        expect(restored.name, equals(original.name));
        expect(restored.useCount, equals(original.useCount));
        expect(restored.isDeleted, equals(original.isDeleted));
        expect(restored.createdAt, equals(original.createdAt));
      });
    });

    group('copyWith', () {
      test('preserves unmodified fields', () {
        final original = SpeciesHistory(
          id: 1,
          name: 'Bass',
          useCount: 5,
          isDeleted: false,
          createdAt: DateTime(2024, 3, 15),
        );

        final copy = original.copyWith(useCount: 10);

        expect(copy.id, equals(original.id));
        expect(copy.name, equals(original.name));
        expect(copy.useCount, equals(10));
        expect(copy.isDeleted, equals(original.isDeleted));
        expect(copy.createdAt, equals(original.createdAt));
      });

      test('multiple modified fields preserve others', () {
        final original = SpeciesHistory(
          id: 2,
          name: 'Trout',
          useCount: 3,
          isDeleted: false,
          createdAt: DateTime(2024, 6, 1),
        );

        final copy = original.copyWith(
          name: 'Rainbow Trout',
          isDeleted: true,
        );

        expect(copy.id, equals(original.id));
        expect(copy.name, equals('Rainbow Trout'));
        expect(copy.useCount, equals(original.useCount));
        expect(copy.isDeleted, isTrue);
        expect(copy.createdAt, equals(original.createdAt));
      });

      test('copyWith returns new instance', () {
        final original = SpeciesHistory(
          id: 1,
          name: 'Bass',
          useCount: 5,
          createdAt: DateTime(2024),
        );

        final copy = original.copyWith(useCount: 10);

        expect(original.useCount, equals(5));
        expect(copy.useCount, equals(10));
        expect(identical(original, copy), isFalse);
      });
    });

    group('equality', () {
      test('based on id only', () {
        final history1 = SpeciesHistory(
          id: 1,
          name: 'Bass',
          useCount: 5,
          isDeleted: false,
          createdAt: DateTime(2024, 1, 1),
        );

        final history2 = SpeciesHistory(
          id: 1,
          name: 'Different Name',
          useCount: 99,
          isDeleted: true,
          createdAt: DateTime(2020, 1, 1),
        );

        expect(history1, equals(history2));
      });

      test('different id means not equal', () {
        final history1 = SpeciesHistory(
          id: 1,
          name: 'Bass',
          useCount: 5,
          createdAt: DateTime(2024),
        );

        final history2 = SpeciesHistory(
          id: 2,
          name: 'Bass',
          useCount: 5,
          createdAt: DateTime(2024),
        );

        expect(history1, isNot(equals(history2)));
      });

      test('hashCode based on id', () {
        final history1 = SpeciesHistory(
          id: 42,
          name: 'Bass',
          useCount: 5,
          createdAt: DateTime(2024),
        );

        final history2 = SpeciesHistory(
          id: 42,
          name: 'Totally Different',
          useCount: 100,
          createdAt: DateTime(2020),
        );

        expect(history1.hashCode, equals(history2.hashCode));
      });
    });

    group('toString', () {
      test('contains id name and useCount', () {
        final history = SpeciesHistory(
          id: 7,
          name: 'Catfish',
          useCount: 12,
          isDeleted: false,
          createdAt: DateTime(2024),
        );

        final str = history.toString();

        expect(str, contains('SpeciesHistory'));
        expect(str, contains('id: 7'));
        expect(str, contains('name: Catfish'));
        expect(str, contains('useCount: 12'));
        expect(str, contains('isDeleted: false'));
      });
    });
  });
}
