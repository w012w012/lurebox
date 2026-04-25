import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/cloud_config.dart';

void main() {
  group('CloudProvider', () {
    test('fromString returns webdav for "webdav"', () {
      expect(CloudProvider.fromString('webdav'), equals(CloudProvider.webdav));
    });

    test('fromString returns nextcloud for "nextcloud"', () {
      expect(CloudProvider.fromString('nextcloud'), equals(CloudProvider.nextcloud));
    });

    test('fromString returns owncloud for "owncloud"', () {
      expect(CloudProvider.fromString('owncloud'), equals(CloudProvider.owncloud));
    });

    test('fromString returns webdav as default for unknown value', () {
      expect(CloudProvider.fromString('unknown'), equals(CloudProvider.webdav));
      expect(CloudProvider.fromString(''), equals(CloudProvider.webdav));
      expect(CloudProvider.fromString('S3'), equals(CloudProvider.webdav));
      expect(CloudProvider.fromString('DROPBOX'), equals(CloudProvider.webdav));
    });

    test('value property returns correct string for each provider', () {
      expect(CloudProvider.webdav.value, equals('webdav'));
      expect(CloudProvider.nextcloud.value, equals('nextcloud'));
      expect(CloudProvider.owncloud.value, equals('owncloud'));
    });

    test('label property returns human-readable string', () {
      expect(CloudProvider.webdav.label, equals('WebDAV'));
      expect(CloudProvider.nextcloud.label, equals('Nextcloud'));
      expect(CloudProvider.owncloud.label, equals('OwnCloud'));
    });
  });

  group('CloudConfig.fromMap', () {
    test('creates instance with all fields from map', () {
      final map = {
        'id': 1,
        'provider': 'nextcloud',
        'server_url': 'https://cloud.example.com/remote.php/dav',
        'username': 'testuser',
        'password': 'secret123',
        'is_active': 1,
        'created_at': '2024-06-15T10:30:00.000',
        'updated_at': '2024-06-15T12:00:00.000',
      };

      final config = CloudConfig.fromMap(map);

      expect(config.id, equals(1));
      expect(config.provider, equals(CloudProvider.nextcloud));
      expect(config.serverUrl, equals('https://cloud.example.com/remote.php/dav'));
      expect(config.username, equals('testuser'));
      expect(config.password, equals('secret123'));
      expect(config.isActive, isTrue);
      expect(config.createdAt, equals(DateTime.parse('2024-06-15T10:30:00.000')));
      expect(config.updatedAt, equals(DateTime.parse('2024-06-15T12:00:00.000')));
    });

    test('defaults password to empty string when null', () {
      final map = {
        'id': 2,
        'provider': 'webdav',
        'server_url': 'https://webdav.example.com',
        'username': 'user2',
        'password': null,
        'is_active': 0,
        'created_at': '2024-06-15T10:30:00.000',
        'updated_at': '2024-06-15T12:00:00.000',
      };

      final config = CloudConfig.fromMap(map);

      expect(config.password, equals(''));
    });

    test('defaults password to empty string when absent from map', () {
      final map = {
        'id': 3,
        'provider': 'owncloud',
        'server_url': 'https://owncloud.example.com',
        'username': 'user3',
        'is_active': 0,
        'created_at': '2024-06-15T10:30:00.000',
        'updated_at': '2024-06-15T12:00:00.000',
      };

      final config = CloudConfig.fromMap(map);

      expect(config.password, equals(''));
    });

    test('parses webdav provider correctly', () {
      final map = {
        'provider': 'webdav',
        'server_url': 'https://webdav.example.com',
        'username': 'user',
        'password': 'pass',
        'is_active': 1,
        'created_at': '2024-06-15T10:30:00.000',
        'updated_at': '2024-06-15T12:00:00.000',
      };

      final config = CloudConfig.fromMap(map);
      expect(config.provider, equals(CloudProvider.webdav));
    });

    test('parses owncloud provider correctly', () {
      final map = {
        'provider': 'owncloud',
        'server_url': 'https://owncloud.example.com',
        'username': 'user',
        'password': 'pass',
        'is_active': 0,
        'created_at': '2024-06-15T10:30:00.000',
        'updated_at': '2024-06-15T12:00:00.000',
      };

      final config = CloudConfig.fromMap(map);
      expect(config.provider, equals(CloudProvider.owncloud));
    });

    test('isActive converts 0 to false', () {
      final map = {
        'provider': 'webdav',
        'server_url': 'https://webdav.example.com',
        'username': 'user',
        'password': 'pass',
        'is_active': 0,
        'created_at': '2024-06-15T10:30:00.000',
        'updated_at': '2024-06-15T12:00:00.000',
      };

      final config = CloudConfig.fromMap(map);
      expect(config.isActive, isFalse);
    });

    test('isActive converts 1 to true', () {
      final map = {
        'provider': 'webdav',
        'server_url': 'https://webdav.example.com',
        'username': 'user',
        'password': 'pass',
        'is_active': 1,
        'created_at': '2024-06-15T10:30:00.000',
        'created_at': '2024-06-15T10:30:00.000',
        'updated_at': '2024-06-15T12:00:00.000',
      };

      final config = CloudConfig.fromMap(map);
      expect(config.isActive, isTrue);
    });
  });

  group('CloudConfig.toMap', () {
    test('outputs correct map including password', () {
      final createdAt = DateTime.parse('2024-06-15T10:30:00.000');
      final updatedAt = DateTime.parse('2024-06-15T12:00:00.000');
      final config = CloudConfig(
        id: 5,
        provider: CloudProvider.nextcloud,
        serverUrl: 'https://cloud.example.com/remote.php/dav',
        username: 'testuser',
        password: 'mysecretpassword',
        isActive: true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final result = config.toMap();

      expect(result['id'], equals(5));
      expect(result['provider'], equals('nextcloud'));
      expect(result['server_url'], equals('https://cloud.example.com/remote.php/dav'));
      expect(result['username'], equals('testuser'));
      expect(result['password'], equals('mysecretpassword'));
      expect(result['is_active'], equals(1));
      expect(result['created_at'], equals('2024-06-15T10:30:00.000'));
      expect(result['updated_at'], equals('2024-06-15T12:00:00.000'));
    });

    test('includes null id when id is null', () {
      final config = CloudConfig(
        provider: CloudProvider.webdav,
        serverUrl: 'https://webdav.example.com',
        username: 'user',
        password: 'pass',
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = config.toMap();
      expect(result.containsKey('id'), isTrue);
      expect(result['id'], isNull);
    });
  });

  group('CloudConfig.toDbMap', () {
    test('outputs correct map excluding password (password is empty string)', () {
      final createdAt = DateTime.parse('2024-06-15T10:30:00.000');
      final updatedAt = DateTime.parse('2024-06-15T12:00:00.000');
      final config = CloudConfig(
        id: 5,
        provider: CloudProvider.nextcloud,
        serverUrl: 'https://cloud.example.com/remote.php/dav',
        username: 'testuser',
        password: 'mysecretpassword',
        isActive: true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final result = config.toDbMap();

      expect(result['id'], equals(5));
      expect(result['provider'], equals('nextcloud'));
      expect(result['server_url'], equals('https://cloud.example.com/remote.php/dav'));
      expect(result['username'], equals('testuser'));
      expect(result['password'], equals('')); // password always empty in db map
      expect(result['is_active'], equals(1));
      expect(result['created_at'], equals('2024-06-15T10:30:00.000'));
      expect(result['updated_at'], equals('2024-06-15T12:00:00.000'));
    });

    test('toDbMap password is empty regardless of actual password value', () {
      final config = CloudConfig(
        id: 1,
        provider: CloudProvider.webdav,
        serverUrl: 'https://webdav.example.com',
        username: 'user',
        password: 'anything',
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = config.toDbMap();
      expect(result['password'], equals(''));
    });
  });

  group('CloudConfig.copyWith', () {
    test('preserves unmodified fields when id is changed', () {
      final original = CloudConfig(
        id: 1,
        provider: CloudProvider.webdav,
        serverUrl: 'https://webdav.example.com',
        username: 'user1',
        password: 'pass1',
        isActive: true,
        createdAt: DateTime.parse('2024-06-15T10:30:00.000'),
        updatedAt: DateTime.parse('2024-06-15T12:00:00.000'),
      );

      final copy = original.copyWith(id: 99);

      expect(copy.id, equals(99));
      expect(copy.provider, equals(CloudProvider.webdav));
      expect(copy.serverUrl, equals('https://webdav.example.com'));
      expect(copy.username, equals('user1'));
      expect(copy.password, equals('pass1'));
      expect(copy.isActive, isTrue);
    });

    test('preserves unmodified fields when isActive is changed', () {
      final original = CloudConfig(
        id: 1,
        provider: CloudProvider.nextcloud,
        serverUrl: 'https://cloud.example.com',
        username: 'user',
        password: 'pass',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final copy = original.copyWith(isActive: false);

      expect(copy.isActive, isFalse);
      expect(copy.id, equals(1));
      expect(copy.provider, equals(CloudProvider.nextcloud));
      expect(copy.serverUrl, equals('https://cloud.example.com'));
      expect(copy.username, equals('user'));
      expect(copy.password, equals('pass'));
    });

    test('can change multiple fields at once', () {
      final original = CloudConfig(
        id: 1,
        provider: CloudProvider.webdav,
        serverUrl: 'https://webdav.example.com',
        username: 'olduser',
        password: 'oldpass',
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final copy = original.copyWith(
        provider: CloudProvider.nextcloud,
        username: 'newuser',
        isActive: true,
      );

      expect(copy.provider, equals(CloudProvider.nextcloud));
      expect(copy.username, equals('newuser'));
      expect(copy.isActive, isTrue);
      expect(copy.serverUrl, equals('https://webdav.example.com'));
      expect(copy.password, equals('oldpass'));
    });
  });

  group('CloudConfig equality', () {
    test('two instances with same id, provider, serverUrl, username, isActive are equal', () {
      final config1 = CloudConfig(
        id: 1,
        provider: CloudProvider.webdav,
        serverUrl: 'https://example.com',
        username: 'user',
        password: 'pass1',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final config2 = CloudConfig(
        id: 1,
        provider: CloudProvider.webdav,
        serverUrl: 'https://example.com',
        username: 'user',
        password: 'pass2', // different password - not part of equality
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(config1, equals(config2));
    });

    test('two instances with different id are not equal', () {
      final config1 = CloudConfig(
        id: 1,
        provider: CloudProvider.webdav,
        serverUrl: 'https://example.com',
        username: 'user',
        password: 'pass',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final config2 = CloudConfig(
        id: 2,
        provider: CloudProvider.webdav,
        serverUrl: 'https://example.com',
        username: 'user',
        password: 'pass',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(config1, isNot(equals(config2)));
    });

    test('hashCode is based on id, provider, serverUrl, username, isActive', () {
      final config1 = CloudConfig(
        id: 1,
        provider: CloudProvider.webdav,
        serverUrl: 'https://example.com',
        username: 'user',
        password: 'pass1',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final config2 = CloudConfig(
        id: 1,
        provider: CloudProvider.webdav,
        serverUrl: 'https://example.com',
        username: 'user',
        password: 'pass2', // different - not in hash
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(config1.hashCode, equals(config2.hashCode));
    });
  });
}