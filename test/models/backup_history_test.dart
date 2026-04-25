import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/backup_history.dart';

void main() {
  group('BackupType', () {
    test('fromString returns json for "json"', () {
      expect(BackupType.fromString('json'), equals(BackupType.json));
    });

    test('fromString returns zipFull for "zip_full"', () {
      expect(BackupType.fromString('zip_full'), equals(BackupType.zipFull));
    });

    test('fromString returns zipDbOnly for "zip_db"', () {
      expect(BackupType.fromString('zip_db'), equals(BackupType.zipDbOnly));
    });

    test('fromString returns json as default for unknown value', () {
      expect(BackupType.fromString('unknown_type'), equals(BackupType.json));
      expect(BackupType.fromString(''), equals(BackupType.json));
      expect(BackupType.fromString('INVALID'), equals(BackupType.json));
    });

    test('value property returns correct string for each type', () {
      expect(BackupType.json.value, equals('json'));
      expect(BackupType.zipFull.value, equals('zip_full'));
      expect(BackupType.zipDbOnly.value, equals('zip_db'));
    });

    test('label property returns human-readable string', () {
      expect(BackupType.json.label, equals('JSON 备份'));
      expect(BackupType.zipFull.label, equals('完整备份'));
      expect(BackupType.zipDbOnly.label, equals('仅数据库'));
    });
  });

  group('BackupHistory.fromMap', () {
    test('creates instance with all fields from map', () {
      final map = {
        'id': 1,
        'file_path': '/data/backup/backup_2024.json',
        'file_name': 'backup_2024.json',
        'backup_type': 'json',
        'file_size': 2048576,
        'fish_count': 50,
        'equipment_count': 10,
        'photo_count': 25,
        'created_at': '2024-06-15T10:30:00.000',
      };

      final backup = BackupHistory.fromMap(map);

      expect(backup.id, equals(1));
      expect(backup.filePath, equals('/data/backup/backup_2024.json'));
      expect(backup.fileName, equals('backup_2024.json'));
      expect(backup.backupType, equals(BackupType.json));
      expect(backup.fileSize, equals(2048576));
      expect(backup.fishCount, equals(50));
      expect(backup.equipmentCount, equals(10));
      expect(backup.photoCount, equals(25));
      expect(backup.createdAt, equals(DateTime.parse('2024-06-15T10:30:00.000')));
    });

    test('uses default counts (0) when fishCount is null', () {
      final map = {
        'file_path': '/data/backup/backup.json',
        'file_name': 'backup.json',
        'backup_type': 'json',
        'file_size': 1024,
        'created_at': '2024-06-15T10:30:00.000',
      };

      final backup = BackupHistory.fromMap(map);

      expect(backup.fishCount, equals(0));
      expect(backup.equipmentCount, equals(0));
      expect(backup.photoCount, equals(0));
    });

    test('uses default counts (0) when counts are explicitly null in map', () {
      final map = {
        'id': null,
        'file_path': '/data/backup/backup.json',
        'file_name': 'backup.json',
        'backup_type': 'zip_full',
        'file_size': 1024,
        'fish_count': null,
        'equipment_count': null,
        'photo_count': null,
        'created_at': '2024-06-15T10:30:00.000',
      };

      final backup = BackupHistory.fromMap(map);

      expect(backup.fishCount, equals(0));
      expect(backup.equipmentCount, equals(0));
      expect(backup.photoCount, equals(0));
    });

    test('parses zip_full backup type correctly', () {
      final map = {
        'file_path': '/data/backup/full.zip',
        'file_name': 'full.zip',
        'backup_type': 'zip_full',
        'file_size': 10485760,
        'created_at': '2024-07-01T12:00:00.000',
      };

      final backup = BackupHistory.fromMap(map);
      expect(backup.backupType, equals(BackupType.zipFull));
    });

    test('parses zip_db backup type correctly', () {
      final map = {
        'file_path': '/data/backup/db.zip',
        'file_name': 'db.zip',
        'backup_type': 'zip_db',
        'file_size': 512000,
        'created_at': '2024-07-01T12:00:00.000',
      };

      final backup = BackupHistory.fromMap(map);
      expect(backup.backupType, equals(BackupType.zipDbOnly));
    });
  });

  group('BackupHistory.toMap', () {
    test('outputs correct map with all fields', () {
      final createdAt = DateTime.parse('2024-06-15T10:30:00.000');
      final backup = BackupHistory(
        id: 5,
        filePath: '/data/backup/backup.zip',
        fileName: 'backup.zip',
        backupType: BackupType.zipFull,
        fileSize: 5242880,
        fishCount: 100,
        equipmentCount: 20,
        photoCount: 50,
        createdAt: createdAt,
      );

      final result = backup.toMap();

      expect(result['id'], equals(5));
      expect(result['file_path'], equals('/data/backup/backup.zip'));
      expect(result['file_name'], equals('backup.zip'));
      expect(result['backup_type'], equals('zip_full'));
      expect(result['file_size'], equals(5242880));
      expect(result['fish_count'], equals(100));
      expect(result['equipment_count'], equals(20));
      expect(result['photo_count'], equals(50));
      expect(result['created_at'], equals('2024-06-15T10:30:00.000'));
    });

    test('includes null id when id is null', () {
      final backup = BackupHistory(
        filePath: '/data/backup/backup.zip',
        fileName: 'backup.zip',
        backupType: BackupType.json,
        fileSize: 1024,
        createdAt: DateTime.parse('2024-06-15T10:30:00.000'),
      );

      final result = backup.toMap();
      expect(result.containsKey('id'), isTrue);
      expect(result['id'], isNull);
    });
  });

  group('BackupHistory.copyWith', () {
    test('preserves unmodified fields when id is changed', () {
      final original = BackupHistory(
        id: 1,
        filePath: '/data/backup/backup.zip',
        fileName: 'backup.zip',
        backupType: BackupType.zipFull,
        fileSize: 5242880,
        fishCount: 100,
        equipmentCount: 20,
        photoCount: 50,
        createdAt: DateTime.parse('2024-06-15T10:30:00.000'),
      );

      final copy = original.copyWith(id: 2);

      expect(copy.id, equals(2));
      expect(copy.filePath, equals('/data/backup/backup.zip'));
      expect(copy.fileName, equals('backup.zip'));
      expect(copy.backupType, equals(BackupType.zipFull));
      expect(copy.fileSize, equals(5242880));
      expect(copy.fishCount, equals(100));
      expect(copy.equipmentCount, equals(20));
      expect(copy.photoCount, equals(50));
      expect(copy.createdAt, equals(DateTime.parse('2024-06-15T10:30:00.000')));
    });

    test('preserves unmodified fields when fileSize is changed', () {
      final original = BackupHistory(
        id: 1,
        filePath: '/data/backup/backup.zip',
        fileName: 'backup.zip',
        backupType: BackupType.zipFull,
        fileSize: 5242880,
        fishCount: 100,
        equipmentCount: 20,
        photoCount: 50,
        createdAt: DateTime.parse('2024-06-15T10:30:00.000'),
      );

      final copy = original.copyWith(fileSize: 10485760);

      expect(copy.id, equals(1));
      expect(copy.filePath, equals('/data/backup/backup.zip'));
      expect(copy.fileSize, equals(10485760));
      expect(copy.fishCount, equals(100));
    });

    test('can change multiple fields at once', () {
      final original = BackupHistory(
        id: 1,
        filePath: '/data/backup/backup.zip',
        fileName: 'backup.zip',
        backupType: BackupType.zipFull,
        fileSize: 5242880,
        fishCount: 100,
        equipmentCount: 20,
        photoCount: 50,
        createdAt: DateTime.parse('2024-06-15T10:30:00.000'),
      );

      final copy = original.copyWith(
        id: 99,
        fishCount: 500,
        backupType: BackupType.zipDbOnly,
      );

      expect(copy.id, equals(99));
      expect(copy.fishCount, equals(500));
      expect(copy.backupType, equals(BackupType.zipDbOnly));
      expect(copy.filePath, equals('/data/backup/backup.zip'));
      expect(copy.equipmentCount, equals(20));
    });
  });

  group('BackupHistory.formattedFileSize', () {
    test('returns bytes when size < 1024', () {
      final backup = BackupHistory(
        filePath: '/data/backup/backup.zip',
        fileName: 'backup.zip',
        backupType: BackupType.json,
        fileSize: 512,
        createdAt: DateTime.now(),
      );

      expect(backup.formattedFileSize, equals('512 B'));
    });

    test('returns KB when size < 1 MB', () {
      final backup = BackupHistory(
        filePath: '/data/backup/backup.zip',
        fileName: 'backup.zip',
        backupType: BackupType.json,
        fileSize: 2048,
        createdAt: DateTime.now(),
      );

      expect(backup.formattedFileSize, equals('2.0 KB'));
    });

    test('returns MB when size < 1 GB', () {
      final backup = BackupHistory(
        filePath: '/data/backup/backup.zip',
        fileName: 'backup.zip',
        backupType: BackupType.json,
        fileSize: 5242880,
        createdAt: DateTime.now(),
      );

      expect(backup.formattedFileSize, equals('5.0 MB'));
    });

    test('returns GB when size >= 1 GB', () {
      final backup = BackupHistory(
        filePath: '/data/backup/backup.zip',
        fileName: 'backup.zip',
        backupType: BackupType.json,
        fileSize: 2147483648,
        createdAt: DateTime.now(),
      );

      expect(backup.formattedFileSize, equals('2.0 GB'));
    });

    test('uses one decimal place for KB', () {
      final backup = BackupHistory(
        filePath: '/data/backup/backup.zip',
        fileName: 'backup.zip',
        backupType: BackupType.json,
        fileSize: 1536,
        createdAt: DateTime.now(),
      );

      expect(backup.formattedFileSize, equals('1.5 KB'));
    });

    test('uses one decimal place for MB', () {
      final backup = BackupHistory(
        filePath: '/data/backup/backup.zip',
        fileName: 'backup.zip',
        backupType: BackupType.json,
        fileSize: 1572864,
        createdAt: DateTime.now(),
      );

      expect(backup.formattedFileSize, equals('1.5 MB'));
    });

    test('uses one decimal place for GB', () {
      final backup = BackupHistory(
        filePath: '/data/backup/backup.zip',
        fileName: 'backup.zip',
        backupType: BackupType.json,
        fileSize: 3221225472,
        createdAt: DateTime.now(),
      );

      expect(backup.formattedFileSize, equals('3.0 GB'));
    });
  });

  group('BackupHistory equality', () {
    test('two instances with same id are equal', () {
      final backup1 = BackupHistory(
        id: 1,
        filePath: '/path1',
        fileName: 'backup1.zip',
        backupType: BackupType.json,
        fileSize: 1000,
        createdAt: DateTime.now(),
      );
      final backup2 = BackupHistory(
        id: 1,
        filePath: '/path2',
        fileName: 'backup2.zip',
        backupType: BackupType.zipFull,
        fileSize: 2000,
        createdAt: DateTime.now(),
      );

      expect(backup1, equals(backup2));
    });

    test('two instances with different id are not equal', () {
      final backup1 = BackupHistory(
        id: 1,
        filePath: '/path',
        fileName: 'backup.zip',
        backupType: BackupType.json,
        fileSize: 1000,
        createdAt: DateTime.now(),
      );
      final backup2 = BackupHistory(
        id: 2,
        filePath: '/path',
        fileName: 'backup.zip',
        backupType: BackupType.json,
        fileSize: 1000,
        createdAt: DateTime.now(),
      );

      expect(backup1, isNot(equals(backup2)));
    });

    test('hashCode is based on id', () {
      final backup1 = BackupHistory(
        id: 42,
        filePath: '/path',
        fileName: 'backup.zip',
        backupType: BackupType.json,
        fileSize: 1000,
        createdAt: DateTime.now(),
      );
      final backup2 = BackupHistory(
        id: 42,
        filePath: '/different/path',
        fileName: 'different.zip',
        backupType: BackupType.zipFull,
        fileSize: 9999,
        createdAt: DateTime.now(),
      );

      expect(backup1.hashCode, equals(backup2.hashCode));
    });
  });
}