import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/widgets/common/image_cache_helper.dart';

void main() {
  group('LRUMap', () {
    group('basic operations', () {
      test('put and get', () {
        final cache = LRUMap<String, String>(maxSize: 3);
        cache.put('a', 'value_a');
        expect(cache.get('a'), 'value_a');
        expect(cache.length, 1);
      });

      test('get returns null for missing key', () {
        final cache = LRUMap<String, String>(maxSize: 3);
        expect(cache.get('missing'), isNull);
      });

      test('containsKey', () {
        final cache = LRUMap<String, String>(maxSize: 3);
        cache.put('a', 'value');
        expect(cache.containsKey('a'), isTrue);
        expect(cache.containsKey('b'), isFalse);
      });

      test('remove', () {
        final cache = LRUMap<String, String>(maxSize: 3);
        cache.put('a', 'value');
        cache.remove('a');
        expect(cache.containsKey('a'), isFalse);
        expect(cache.length, 0);
      });

      test('clear', () {
        final cache = LRUMap<String, String>(maxSize: 3);
        cache.put('a', '1');
        cache.put('b', '2');
        cache.clear();
        expect(cache.length, 0);
      });
    });

    group('eviction', () {
      test('evicts oldest entry when at capacity', () {
        final cache = LRUMap<String, String>(maxSize: 3);
        cache.put('a', '1');
        cache.put('b', '2');
        cache.put('c', '3');
        cache.put('d', '4');

        // 'a' should be evicted (oldest)
        expect(cache.containsKey('a'), isFalse);
        expect(cache.get('b'), '2');
        expect(cache.get('c'), '3');
        expect(cache.get('d'), '4');
        expect(cache.length, 3);
      });

      test('updating existing key does not evict', () {
        final cache = LRUMap<String, String>(maxSize: 2);
        cache.put('a', '1');
        cache.put('b', '2');
        cache.put('a', 'updated');

        expect(cache.length, 2);
        expect(cache.get('a'), 'updated');
        expect(cache.get('b'), '2');
      });
    });

    group('LRU access order', () {
      test('get promotes entry to most-recently-used', () {
        final cache = LRUMap<String, String>(maxSize: 3);
        cache.put('a', '1');
        cache.put('b', '2');
        cache.put('c', '3');

        // Access 'a' to promote it
        cache.get('a');

        // Now add 'd' — 'b' should be evicted (oldest after 'a' was promoted)
        cache.put('d', '4');

        expect(cache.containsKey('a'), isTrue);
        expect(cache.containsKey('b'), isFalse);
        expect(cache.containsKey('c'), isTrue);
        expect(cache.containsKey('d'), isTrue);
      });

      test('get returns null after eviction', () {
        final cache = LRUMap<String, String>(maxSize: 2);
        cache.put('a', '1');
        cache.put('b', '2');

        // 'a' is oldest, evict it
        cache.put('c', '3');

        expect(cache.get('a'), isNull);
        expect(cache.get('b'), '2');
        expect(cache.get('c'), '3');
      });
    });

    group('removeWhere', () {
      test('removes entries matching predicate', () {
        final cache = LRUMap<String, int>(maxSize: 5);
        cache.put('a', 1);
        cache.put('b', 2);
        cache.put('c', 3);
        cache.put('d', 4);

        cache.removeWhere((key, value) => value.isEven);

        expect(cache.length, 2);
        expect(cache.containsKey('a'), isTrue);
        expect(cache.containsKey('b'), isFalse);
        expect(cache.containsKey('c'), isTrue);
        expect(cache.containsKey('d'), isFalse);
      });

      test('removes nothing when predicate matches nothing', () {
        final cache = LRUMap<String, String>(maxSize: 3);
        cache.put('a', '1');
        cache.put('b', '2');

        cache.removeWhere((key, value) => false);

        expect(cache.length, 2);
      });
    });

    group('maxSize setter', () {
      test('shrinking maxSize evicts oldest entries', () {
        final cache = LRUMap<String, String>(maxSize: 5);
        cache.put('a', '1');
        cache.put('b', '2');
        cache.put('c', '3');
        cache.put('d', '4');
        cache.put('e', '5');

        cache.maxSize = 3;

        expect(cache.length, 3);
        expect(cache.containsKey('a'), isFalse);
        expect(cache.containsKey('b'), isFalse);
        expect(cache.containsKey('c'), isTrue);
        expect(cache.containsKey('d'), isTrue);
        expect(cache.containsKey('e'), isTrue);
      });
    });

    group('edge cases', () {
      test('works with maxSize of 1', () {
        final cache = LRUMap<String, String>(maxSize: 1);
        cache.put('a', '1');
        expect(cache.length, 1);

        cache.put('b', '2');
        expect(cache.length, 1);
        expect(cache.containsKey('a'), isFalse);
        expect(cache.get('b'), '2');
      });

      test('put same key repeatedly stays at length 1', () {
        final cache = LRUMap<String, String>(maxSize: 5);
        for (var i = 0; i < 10; i++) {
          cache.put('key', '$i');
        }
        expect(cache.length, 1);
        expect(cache.get('key'), '9');
      });

      test('supports int keys', () {
        final cache = LRUMap<int, String>(maxSize: 3);
        cache.put(1, 'one');
        cache.put(2, 'two');
        expect(cache.get(1), 'one');
        expect(cache.get(2), 'two');
      });
    });
  });
}
