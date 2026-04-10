import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lurebox/core/repositories/settings_repository.dart';
import 'package:lurebox/core/repositories/settings_repository_impl.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // 创建内存数据库用于测试
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''');
        },
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('SqliteSettingsRepository', () {
    late SqliteSettingsRepository repository;

    setUp(() {
      repository = SqliteSettingsRepository.withDatabase(
        Future<Database>.value(db),
      );
    });

    // Basic get/set tests
    test('set and get returns the stored value', () async {
      await repository.set('username', 'John');

      final result = await repository.get('username');

      expect(result, equals('John'));
    });

    test('get returns null for non-existent key', () async {
      final result = await repository.get('non_existent_key');

      expect(result, isNull);
    });

    test('set overwrites existing value', () async {
      await repository.set('key', 'value1');
      await repository.set('key', 'value2');

      final result = await repository.get('key');

      expect(result, equals('value2'));
    });

    // getOrDefault tests
    test('getOrDefault returns value when key exists', () async {
      await repository.set('key', 'value');

      final result = await repository.getOrDefault('key', 'default');

      expect(result, equals('value'));
    });

    test('getOrDefault returns default when key does not exist', () async {
      final result = await repository.getOrDefault('non_existent', 'default');

      expect(result, equals('default'));
    });

    // exists tests
    test('exists returns true for existing key', () async {
      await repository.set('key', 'value');

      final result = await repository.exists('key');

      expect(result, isTrue);
    });

    test('exists returns false for non-existent key', () async {
      final result = await repository.exists('non_existent_key');

      expect(result, isFalse);
    });

    // delete tests
    test('delete removes the key', () async {
      await repository.set('key', 'value');

      await repository.delete('key');

      final value = await repository.get('key');
      final exists = await repository.exists('key');
      expect(value, isNull);
      expect(exists, isFalse);
    });

    test('delete does nothing for non-existent key', () async {
      // Should not throw
      await repository.delete('non_existent_key');
    });

    // getAll tests
    test('getAll returns all key-value pairs', () async {
      await repository.set('key1', 'value1');
      await repository.set('key2', 'value2');
      await repository.set('key3', 'value3');

      final result = await repository.getAll();

      expect(result.length, equals(3));
      expect(result['key1'], equals('value1'));
      expect(result['key2'], equals('value2'));
      expect(result['key3'], equals('value3'));
    });

    test('getAll returns empty map when no settings exist', () async {
      final result = await repository.getAll();

      expect(result, isEmpty);
    });

    // setAll tests
    test('setAll inserts multiple key-value pairs', () async {
      await repository.setAll({
        'a': '1',
        'b': '2',
        'c': '3',
      });

      final result = await repository.getAll();

      expect(result.length, equals(3));
      expect(result['a'], equals('1'));
      expect(result['b'], equals('2'));
      expect(result['c'], equals('3'));
    });

    test('setAll overwrites existing keys', () async {
      await repository.set('existing', 'old');
      await repository.setAll({'existing': 'new', 'new_key': 'new_value'});

      final result = await repository.getAll();

      expect(result['existing'], equals('new'));
      expect(result['new_key'], equals('new_value'));
      expect(result.length, equals(2));
    });

    // Type conversion tests - getInt
    test('getInt parses integer string correctly', () async {
      await repository.set('int_key', '42');

      final result = await repository.getInt('int_key');

      expect(result, equals(42));
    });

    test('getInt returns default when key does not exist', () async {
      final result = await repository.getInt('non_existent', defaultValue: 999);

      expect(result, equals(999));
    });

    test('getInt returns default when value is not a valid integer', () async {
      await repository.set('invalid', 'not_a_number');

      final result = await repository.getInt('invalid');

      expect(result, equals(0));
    });

    // Type conversion tests - getDouble
    test('getDouble parses double string correctly', () async {
      await repository.set('double_key', '3.14');

      final result = await repository.getDouble('double_key');

      expect(result, equals(3.14));
    });

    test('getDouble returns default when key does not exist', () async {
      final result =
          await repository.getDouble('non_existent', defaultValue: 9.99);

      expect(result, equals(9.99));
    });

    test('getDouble returns default when value is not a valid double',
        () async {
      await repository.set('invalid', 'not_a_decimal');

      final result = await repository.getDouble('invalid');

      expect(result, equals(0.0));
    });

    // Type conversion tests - getBool
    test('getBool parses "true" string correctly', () async {
      await repository.set('bool_key', 'true');

      final result = await repository.getBool('bool_key');

      expect(result, isTrue);
    });

    test('getBool parses "1" string as true', () async {
      await repository.set('bool_key', '1');

      final result = await repository.getBool('bool_key');

      expect(result, isTrue);
    });

    test('getBool parses "false" string correctly', () async {
      await repository.set('bool_key', 'false');

      final result = await repository.getBool('bool_key');

      expect(result, isFalse);
    });

    test('getBool returns default when key does not exist', () async {
      final result =
          await repository.getBool('non_existent', defaultValue: true);

      expect(result, isTrue);
    });

    test('getBool returns default when value is not a valid boolean', () async {
      await repository.set('invalid', 'maybe');

      final result = await repository.getBool('invalid');

      expect(result, isFalse);
    });

    // Type conversion tests - setInt
    test('setInt stores integer as string', () async {
      await repository.setInt('int_key', 42);

      final result = await repository.get('int_key');

      expect(result, equals('42'));
    });

    // Type conversion tests - setDouble
    test('setDouble stores double as string', () async {
      await repository.setDouble('double_key', 3.14);

      final result = await repository.get('double_key');

      expect(result, equals('3.14'));
    });

    // Type conversion tests - setBool
    test('setBool stores false as string', () async {
      await repository.setBool('bool_key', false);

      final result = await repository.get('bool_key');

      expect(result, equals('false'));
    });

    test('setBool stores true as string', () async {
      await repository.setBool('bool_key', true);

      final result = await repository.get('bool_key');

      expect(result, equals('true'));
    });

    // Integration: set/get with type conversion
    test('setInt and getInt work together', () async {
      await repository.setInt('counter', 100);
      final retrieved = await repository.getInt('counter');

      expect(retrieved, equals(100));
    });

    test('setDouble and getDouble work together', () async {
      await repository.setDouble('price', 19.99);
      final retrieved = await repository.getDouble('price');

      expect(retrieved, equals(19.99));
    });

    test('setBool and getBool work together', () async {
      await repository.setBool('enabled', true);
      final retrieved = await repository.getBool('enabled');

      expect(retrieved, isTrue);
    });
  });
}
