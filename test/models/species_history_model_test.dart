import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/species_history.dart';

void main() {
  group('SpeciesHistory', () {
    late SpeciesHistory testInstance;

    setUp(() {
      testInstance = SpeciesHistory(
        id: 1,
        name: 'Bass',
        useCount: 5,
        createdAt: DateTime(2024),
      );
    });

    test('creates SpeciesHistory with required fields', () {
      expect(testInstance.id, equals(1));
      expect(testInstance.name, equals('Bass'));
      expect(testInstance.useCount, equals(5));
      expect(testInstance.isDeleted, equals(false));
      expect(testInstance.createdAt, equals(DateTime(2024)));
    });

    test('fromMap creates SpeciesHistory from map', () {
      final map = {
        'id': 2,
        'name': 'Trout',
        'use_count': 3,
        'is_deleted': 1,
        'created_at': '2024-02-01T00:00:00.000',
      };

      final result = SpeciesHistory.fromMap(map);

      expect(result.id, equals(2));
      expect(result.name, equals('Trout'));
      expect(result.useCount, equals(3));
      expect(result.isDeleted, equals(true));
      expect(result.createdAt, equals(DateTime(2024, 2)));
    });

    test('toMap converts SpeciesHistory to map', () {
      final map = testInstance.toMap();

      expect(map['id'], equals(1));
      expect(map['name'], equals('Bass'));
      expect(map['use_count'], equals(5));
      expect(map['is_deleted'], equals(0));
      expect(map['created_at'], equals('2024-01-01T00:00:00.000'));
    });

    test('copyWith creates modified copy', () {
      final copy = testInstance.copyWith(useCount: 10, isDeleted: true);

      expect(copy.id, equals(1));
      expect(copy.name, equals('Bass'));
      expect(copy.useCount, equals(10));
      expect(copy.isDeleted, equals(true));
    });

    test('copyWith preserves unmodified fields', () {
      final copy = testInstance.copyWith(useCount: 15);

      expect(copy.name, equals('Bass'));
      expect(copy.isDeleted, equals(false));
    });

    test('equality based on id', () {
      final other = SpeciesHistory(
        id: 1,
        name: 'Different',
        useCount: 99,
        isDeleted: true,
        createdAt: DateTime(2020),
      );

      expect(testInstance, equals(other));
    });

    test('hashCode based on id', () {
      final other = SpeciesHistory(
        id: 1,
        name: 'Different',
        useCount: 99,
        isDeleted: true,
        createdAt: DateTime(2020),
      );

      expect(testInstance.hashCode, equals(other.hashCode));
    });

    test('toString contains relevant information', () {
      final str = testInstance.toString();
      expect(str, contains('SpeciesHistory'));
      expect(str, contains('id: 1'));
      expect(str, contains('name: Bass'));
      expect(str, contains('useCount: 5'));
    });
  });
}
