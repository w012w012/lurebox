import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/widgets/common/image_cache_helper.dart';

void main() {
  group('LRUMap', () {
    test('put and get basic entry', () {
      final cache = LRUMap<String, int>(maxSize: 3);

      cache.put('a', 1);

      expect(cache.get('a'), 1);
      expect(cache.length, 1);
    });

    test('evicts least recently used when full', () {
      final cache = LRUMap<String, int>(maxSize: 3);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);
      // Cache is full: [a, b, c] (insertion order)
      cache.put('d', 4);
      // Should evict 'a' (least recently used): [b, c, d]

      expect(cache.get('a'), isNull);
      expect(cache.get('b'), 2);
      expect(cache.get('c'), 3);
      expect(cache.get('d'), 4);
      expect(cache.length, 3);
    });

    test('get promotes entry so it is not evicted next', () {
      final cache = LRUMap<String, int>(maxSize: 3);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);
      // Cache: [a, b, c]
      cache.get('a');
      // Cache after promotion: [b, c, a]
      cache.put('d', 4);
      // Should evict 'b' (now least recently used): [c, a, d]

      expect(cache.get('b'), isNull);
      expect(cache.get('a'), 1);
      expect(cache.get('c'), 3);
      expect(cache.get('d'), 4);
    });

    test('put overwrites existing key without eviction', () {
      final cache = LRUMap<String, int>(maxSize: 2);

      cache.put('a', 1);
      cache.put('b', 2);
      // Cache is full: [a, b]
      cache.put('a', 10);
      // Overwrite 'a' — no eviction since key already existed

      expect(cache.get('a'), 10);
      expect(cache.get('b'), 2);
      expect(cache.length, 2);
    });

    test('removeWhere removes matching entries', () {
      final cache = LRUMap<String, int>(maxSize: 5);

      cache.put('a1', 1);
      cache.put('b2', 2);
      cache.put('a3', 3);
      cache.put('b4', 4);

      cache.removeWhere((key, value) => key.startsWith('a'));

      expect(cache.length, 2);
      expect(cache.containsKey('a1'), false);
      expect(cache.containsKey('a3'), false);
      expect(cache.get('b2'), 2);
      expect(cache.get('b4'), 4);
    });

    test('removeWhere removes no entries when predicate matches nothing', () {
      final cache = LRUMap<String, int>(maxSize: 3);

      cache.put('a', 1);
      cache.put('b', 2);

      cache.removeWhere((key, value) => key == 'z');

      expect(cache.length, 2);
    });

    test('setting maxSize evicts excess entries from least recently used end', () {
      final cache = LRUMap<String, int>(maxSize: 5);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);
      cache.put('d', 4);
      cache.put('e', 5);
      // Cache: [a, b, c, d, e]

      cache.maxSize = 3;
      // Should evict 'a' and 'b': [c, d, e]

      expect(cache.length, 3);
      expect(cache.containsKey('a'), false);
      expect(cache.containsKey('b'), false);
      expect(cache.get('c'), 3);
      expect(cache.get('d'), 4);
      expect(cache.get('e'), 5);
    });

    test('maxSize setter changes eviction threshold for subsequent puts', () {
      final cache = LRUMap<String, int>(maxSize: 5);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);
      // Cache: [a, b, c], maxSize=5

      cache.maxSize = 2;
      // Evicts down to 2: [b, c]

      cache.put('d', 4);
      // Should evict 'b' (LRU) because maxSize is now 2: [c, d]

      expect(cache.containsKey('b'), isFalse);
      expect(cache.get('c'), 3);
      expect(cache.get('d'), 4);
      expect(cache.length, 2);
    });

    test('get returns null for missing key', () {
      final cache = LRUMap<String, int>(maxSize: 3);

      expect(cache.get('nonexistent'), isNull);
    });

    test('length reflects adds and removes', () {
      final cache = LRUMap<String, int>(maxSize: 5);

      expect(cache.length, 0);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);
      expect(cache.length, 3);

      cache.remove('b');
      expect(cache.length, 2);

      cache.remove('a');
      cache.remove('c');
      expect(cache.length, 0);
    });

    test('clear empties the cache', () {
      final cache = LRUMap<String, int>(maxSize: 3);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);
      expect(cache.length, 3);

      cache.clear();

      expect(cache.length, 0);
      expect(cache.get('a'), isNull);
      expect(cache.get('b'), isNull);
      expect(cache.get('c'), isNull);
    });

    test('maxSize=1 evicts previous entry on every put', () {
      final cache = LRUMap<String, int>(maxSize: 1);

      cache.put('a', 1);
      expect(cache.length, 1);
      expect(cache.get('a'), 1);

      cache.put('b', 2);
      expect(cache.length, 1);
      expect(cache.get('a'), isNull);
      expect(cache.get('b'), 2);

      cache.put('c', 3);
      expect(cache.length, 1);
      expect(cache.get('b'), isNull);
      expect(cache.get('c'), 3);
    });

    test('containsKey returns true for present keys', () {
      final cache = LRUMap<String, int>(maxSize: 3);

      cache.put('a', 1);

      expect(cache.containsKey('a'), true);
      expect(cache.containsKey('b'), false);
    });

    test('default maxSize is 50', () {
      final cache = LRUMap<String, int>();

      expect(cache.maxSize, 50);
    });
  });
}
