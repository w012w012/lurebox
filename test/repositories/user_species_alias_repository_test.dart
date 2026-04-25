import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/user_species_alias.dart';
import 'package:lurebox/core/repositories/user_species_alias_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
        version: 17,
        onCreate: (db, version) async {
          await db.execute('''
CREATE TABLE user_species_alias (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_alias TEXT NOT NULL UNIQUE,
  species_id TEXT NOT NULL,
  created_at INTEGER NOT NULL
)
''');
          await db.execute(
              'CREATE INDEX idx_alias_user_alias ON user_species_alias(user_alias)',);
          await db.execute(
              'CREATE INDEX idx_alias_species ON user_species_alias(species_id)',);
        },
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('UserSpeciesAliasRepository', () {
    late SqliteUserSpeciesAliasRepository repository;

    setUp(() {
      repository = SqliteUserSpeciesAliasRepository.withDatabase(
        Future<Database>.value(db),
      );
    });

    test('create inserts a new alias mapping', () async {
      final id = await repository.create('桂鱼', 'f001');

      expect(id, greaterThan(0));

      final result = await repository.findByAlias('桂鱼');
      expect(result, isNotNull);
      expect(result!.userAlias, equals('桂鱼'));
      expect(result.speciesId, equals('f001'));
    });

    test('create throws on duplicate alias', () async {
      await repository.create('桂鱼', 'f001');

      expect(
        () => repository.create('桂鱼', 'f002'),
        throwsException,
      );
    });

    test('findByAlias returns null for non-existent alias', () async {
      final result = await repository.findByAlias('非存在');

      expect(result, isNull);
    });

    test('findByAlias returns correct mapping', () async {
      await repository.create('桂鱼', 'f001');
      await repository.create('桂花鱼', 'f001');

      final result = await repository.findByAlias('桂花鱼');

      expect(result, isNotNull);
      expect(result!.speciesId, equals('f001'));
    });

    test('findBySpeciesId returns all aliases for a species', () async {
      await repository.create('桂鱼', 'f001');
      await repository.create('桂花鱼', 'f001');
      await repository.create('翘嘴', 'f002');

      final results = await repository.findBySpeciesId('f001');

      expect(results.length, equals(2));
      expect(
          results.map((a) => a.userAlias).toList(), containsAll(['桂鱼', '桂花鱼']),);
    });

    test('findBySpeciesId returns empty list for non-existent species',
        () async {
      final results = await repository.findBySpeciesId('non_existent');

      expect(results, isEmpty);
    });

    test('delete removes the mapping', () async {
      await repository.create('桂鱼', 'f001');

      final created = await repository.findByAlias('桂鱼');
      await repository.delete(created!.id!);

      final result = await repository.findByAlias('桂鱼');
      expect(result, isNull);
    });

    test('delete does nothing for non-existent id', () async {
      // Should not throw
      await repository.delete(9999);
    });

    test('getAll returns all mappings', () async {
      await repository.create('桂鱼', 'f001');
      await repository.create('翘嘴', 'f002');
      await repository.create('黑鱼', 'f003');

      final results = await repository.getAll();

      expect(results.length, equals(3));
    });

    test('getAll returns empty list when no mappings exist', () async {
      final results = await repository.getAll();

      expect(results, isEmpty);
    });

    test('getAll returns mappings ordered by createdAt descending', () async {
      await repository.create('桂鱼', 'f001');
      await Future.delayed(const Duration(milliseconds: 10));
      await repository.create('翘嘴', 'f002');
      await Future.delayed(const Duration(milliseconds: 10));
      await repository.create('黑鱼', 'f003');

      final results = await repository.getAll();

      expect(results.length, equals(3));
      // 最新创建的应该在最前面
      expect(results.first.userAlias, equals('黑鱼'));
    });
  });

  group('UserSpeciesAlias model', () {
    test('fromMap creates correct instance', () {
      final map = {
        'id': 1,
        'user_alias': '桂鱼',
        'species_id': 'f001',
        'created_at': DateTime(2024).millisecondsSinceEpoch,
      };

      final alias = UserSpeciesAlias.fromMap(map);

      expect(alias.id, equals(1));
      expect(alias.userAlias, equals('桂鱼'));
      expect(alias.speciesId, equals('f001'));
      expect(alias.createdAt, equals(DateTime(2024)));
    });

    test('fromMap handles null id', () {
      final map = {
        'user_alias': '桂鱼',
        'species_id': 'f001',
        'created_at': DateTime(2024).millisecondsSinceEpoch,
      };

      final alias = UserSpeciesAlias.fromMap(map);

      expect(alias.id, isNull);
      expect(alias.userAlias, equals('桂鱼'));
    });

    test('toMap creates correct map', () {
      final alias = UserSpeciesAlias(
        id: 1,
        userAlias: '桂鱼',
        speciesId: 'f001',
        createdAt: DateTime(2024),
      );

      final map = alias.toMap();

      expect(map['id'], equals(1));
      expect(map['user_alias'], equals('桂鱼'));
      expect(map['species_id'], equals('f001'));
      expect(map['created_at'],
          equals(DateTime(2024).millisecondsSinceEpoch),);
    });

    test('toMap excludes null id', () {
      final alias = UserSpeciesAlias(
        userAlias: '桂鱼',
        speciesId: 'f001',
        createdAt: DateTime(2024),
      );

      final map = alias.toMap();

      expect(map.containsKey('id'), isFalse);
    });

    test('copyWith creates modified copy', () {
      final original = UserSpeciesAlias(
        id: 1,
        userAlias: '桂鱼',
        speciesId: 'f001',
        createdAt: DateTime(2024),
      );

      final copy = original.copyWith(userAlias: '翘嘴');

      expect(copy.id, equals(1));
      expect(copy.userAlias, equals('翘嘴'));
      expect(copy.speciesId, equals('f001'));
    });

    test('equality based on id', () {
      final alias1 = UserSpeciesAlias(
        id: 1,
        userAlias: '桂鱼',
        speciesId: 'f001',
        createdAt: DateTime(2024),
      );

      final alias2 = UserSpeciesAlias(
        id: 1,
        userAlias: '不同的别名',
        speciesId: 'f002',
        createdAt: DateTime(2024, 2, 2),
      );

      expect(alias1, equals(alias2));
    });

    test('hashCode based on id', () {
      final alias1 = UserSpeciesAlias(
        id: 1,
        userAlias: '桂鱼',
        speciesId: 'f001',
        createdAt: DateTime(2024),
      );

      final alias2 = UserSpeciesAlias(
        id: 1,
        userAlias: '不同的别名',
        speciesId: 'f002',
        createdAt: DateTime(2024, 2, 2),
      );

      expect(alias1.hashCode, equals(alias2.hashCode));
    });
  });
}
