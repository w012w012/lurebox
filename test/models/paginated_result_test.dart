import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/paginated_result.dart';

void main() {
  group('PaginatedResult', () {
    test('creates instance with required fields', () {
      const result = PaginatedResult<String>(
        items: ['a', 'b', 'c'],
        totalCount: 100,
        page: 1,
        pageSize: 10,
        hasMore: true,
      );

      expect(result.items, equals(['a', 'b', 'c']));
      expect(result.totalCount, equals(100));
      expect(result.page, equals(1));
      expect(result.pageSize, equals(10));
      expect(result.hasMore, isTrue);
    });

    test('hasMore is false when on last page', () {
      const result = PaginatedResult<String>(
        items: ['a', 'b'],
        totalCount: 12,
        page: 2,
        pageSize: 10,
        hasMore: false,
      );

      expect(result.hasMore, isFalse);
    });

    test('handles empty items', () {
      const result = PaginatedResult<String>(
        items: [],
        totalCount: 0,
        page: 1,
        pageSize: 10,
        hasMore: false,
      );

      expect(result.items, isEmpty);
      expect(result.totalCount, equals(0));
    });

    test('works with different types', () {
      final result = PaginatedResult<int>(
        items: [1, 2, 3, 4, 5],
        totalCount: 50,
        page: 1,
        pageSize: 5,
        hasMore: true,
      );

      expect(result.items, equals([1, 2, 3, 4, 5]));
    });

    test('works with complex objects', () {
      final items = [
        {'id': 1, 'name': 'Test'},
        {'id': 2, 'name': 'Test2'},
      ];

      final result = PaginatedResult<Map<String, dynamic>>(
        items: items,
        totalCount: 100,
        page: 1,
        pageSize: 10,
        hasMore: true,
      );

      expect(result.items.length, equals(2));
      expect(result.items[0]['id'], equals(1));
    });

    test('page numbering starts from 1', () {
      const result = PaginatedResult<String>(
        items: ['x'],
        totalCount: 50,
        page: 5,
        pageSize: 10,
        hasMore: false,
      );

      expect(result.page, equals(5));
    });

    test('handles single item page', () {
      const result = PaginatedResult<String>(
        items: ['only'],
        totalCount: 1,
        page: 1,
        pageSize: 1,
        hasMore: false,
      );

      expect(result.items.length, equals(1));
      expect(result.hasMore, isFalse);
    });

    test('handles large pageSize', () {
      final items = List.generate(1000, (i) => 'item_$i');

      final result = PaginatedResult<String>(
        items: items,
        totalCount: 5000,
        page: 1,
        pageSize: 1000,
        hasMore: true,
      );

      expect(result.items.length, equals(1000));
      expect(result.hasMore, isTrue);
    });
  });
}
