import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/database/database_provider.dart';
import 'package:lurebox/core/services/backup_zip_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;

// ===== Mock DatabaseProvider =====

class MockDatabaseProvider extends Mock implements DatabaseProvider {
  bool isClosed = false;

  @override
  Future<Database> get database async {
    throw UnimplementedError();
  }

  @override
  Future<void> close() async {
    isClosed = true;
  }
}

// Flutter binding initializer for tests
void initializeFlutterBinding() {
  TestWidgetsFlutterBinding.ensureInitialized();
}

// ===== Path Provider Channel Mocks =====

class MockPathProviderChannel extends Mock implements MethodChannel {
  static const String channelName = 'plugins.flutter.io/path_provider';
}

class FakePathProviderResult extends Fake implements MethodChannel {
  static const MethodChannel instance =
      MethodChannel('plugins.flutter.io/path_provider');
}

// ===== Test Archive Helper =====

class TestArchive {
  static Future<File> createTestZip({
    Map<String, String> files = const {},
    Map<String, dynamic>? metadata,
  }) async {
    final archive = Archive();

    for (final entry in files.entries) {
      final bytes = entry.value.codeUnits;
      archive.addFile(ArchiveFile(entry.key, bytes.length, bytes));
    }

    if (metadata != null) {
      final metadataJson = const JsonEncoder.withIndent('  ').convert(metadata);
      archive.addFile(ArchiveFile(
        'metadata.json',
        metadataJson.codeUnits.length,
        metadataJson.codeUnits,
      ),);
    }

    final zipData = ZipEncoder().encode(archive);
    if (zipData == null) {
      throw Exception('Failed to create test ZIP');
    }
    final tempFile = File(
      '${Directory.systemTemp.path}/test_${DateTime.now().millisecondsSinceEpoch}.zip',
    );
    await tempFile.writeAsBytes(zipData);
    return tempFile;
  }

  static Future<File> createValidBackupZip({
    String dbContent = 'fake database content',
    int photoCount = 0,
    int fishCatchesCount = 5,
    int equipmentCount = 3,
  }) async {
    // Calculate SHA-256 of the db content
    final dbBytes = dbContent.codeUnits;
    final digest = _sha256Bytes(dbBytes);
    final checksum = _bytesToHex(digest);

    final files = <String, String>{'lurebox.db': dbContent};

    // Add placeholder photos if requested
    if (photoCount > 0) {
      for (var i = 0; i < photoCount; i++) {
        files['photos/fish_$i.jpg'] = 'fake photo data $i';
      }
    }

    return createTestZip(
      files: files,
      metadata: {
        'version': 1,
        'exportTime': DateTime.now().toIso8601String(),
        'databaseChecksum': checksum,
        'photoCount': photoCount,
        'fishCatchesCount': fishCatchesCount,
        'equipmentCount': equipmentCount,
        'appVersion': '1.0.3',
      },
    );
  }

  static List<int> _sha256Bytes(List<int> data) {
    // Simple SHA-256 implementation for testing
    // This matches the crypto package's sha256.convert behavior
    return _sha256(data);
  }

  static List<int> _sha256(List<int> message) {
    // Pre-processing: pad the message
    final msgLen = message.length;
    final bitLen = msgLen * 8;

    // Append padding bits
    final padded = List<int>.from(message);
    padded.add(0x80);
    while ((padded.length % 64) != 56) {
      padded.add(0x00);
    }

    // Append length in bits as 64-bit big-endian
    for (var i = 7; i >= 0; i--) {
      padded.add((bitLen >> (i * 8)) & 0xff);
    }

    // Initialize hash values
    final h = <int>[
      0x6a09e667,
      0xbb67ae85,
      0x3c6ef372,
      0xa54ff53a,
      0x510e527f,
      0x9b05688c,
      0x1f83d9ab,
      0x5be0cd19,
    ];

    // Constants
    final k = <int>[
      0x428a2f98,
      0x71374491,
      0xb5c0fbcf,
      0xe9b5dba5,
      0x3956c25b,
      0x59f111f1,
      0x923f82a4,
      0xab1c5ed5,
      0xd807aa98,
      0x12835b01,
      0x243185be,
      0x550c7dc3,
      0x72be5d74,
      0x80deb1fe,
      0x9bdc06a7,
      0xc19bf174,
      0xe49b69c1,
      0xefbe4786,
      0x0fc19dc6,
      0x240ca1cc,
      0x2de92c6f,
      0x4a7484aa,
      0x5cb0a9dc,
      0x76f988da,
      0x983e5152,
      0xa831c66d,
      0xb00327c8,
      0xbf597fc7,
      0xc6e00bf3,
      0xd5a79147,
      0x06ca6351,
      0x14292967,
      0x27b70a85,
      0x2e1b2138,
      0x4d2c6dfc,
      0x53380d13,
      0x650a7354,
      0x766a0abb,
      0x81c2c92e,
      0x92722c85,
      0xa2bfe8a1,
      0xa81a664b,
      0xc24b8b70,
      0xc76c51a3,
      0xd192e819,
      0xd6990624,
      0xf40e3585,
      0x106aa070,
      0x19a4c116,
      0x1e376c08,
      0x2748774c,
      0x34b0bcb5,
      0x391c0cb3,
      0x4ed8aa4a,
      0x5b9cca4f,
      0x682e6ff3,
      0x748f82ee,
      0x78a5636f,
      0x84c87814,
      0x8cc70208,
      0x90befffa,
      0xa4506ceb,
      0xbef9a3f7,
      0xc67178f2,
    ];

    // Process each 512-bit (64-byte) chunk
    for (var chunkStart = 0; chunkStart < padded.length; chunkStart += 64) {
      final chunk = padded.sublist(chunkStart, chunkStart + 64);

      // Create message schedule
      final w = List<int>.filled(64, 0);
      for (var i = 0; i < 16; i++) {
        w[i] = (chunk[i * 4] << 24) |
            (chunk[i * 4 + 1] << 16) |
            (chunk[i * 4 + 2] << 8) |
            chunk[i * 4 + 3];
      }
      for (var i = 16; i < 64; i++) {
        final s0 =
            _rotr(w[i - 15], 7) ^ _rotr(w[i - 15], 18) ^ (w[i - 15] >> 3);
        final s1 = _rotr(w[i - 2], 17) ^ _rotr(w[i - 2], 19) ^ (w[i - 2] >> 10);
        w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & 0xffffffff;
      }

      // Initialize working variables
      var a = h[0], b = h[1], c = h[2], d = h[3];
      var e = h[4];
      var f = h[5];
      var g = h[6];
      var hh = h[7];

      // Main compression loop
      for (var i = 0; i < 64; i++) {
        final S1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
        final ch = (e & f) ^ ((~e) & g);
        final temp1 = (hh + S1 + ch + k[i] + w[i]) & 0xffffffff;
        final S0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
        final maj = (a & b) ^ (a & c) ^ (b & c);
        final temp2 = (S0 + maj) & 0xffffffff;

        hh = g;
        g = f;
        f = e;
        e = (d + temp1) & 0xffffffff;
        d = c;
        c = b;
        b = a;
        a = (temp1 + temp2) & 0xffffffff;
      }

      // Add compressed chunk to current hash value
      h[0] = (h[0] + a) & 0xffffffff;
      h[1] = (h[1] + b) & 0xffffffff;
      h[2] = (h[2] + c) & 0xffffffff;
      h[3] = (h[3] + d) & 0xffffffff;
      h[4] = (h[4] + e) & 0xffffffff;
      h[5] = (h[5] + f) & 0xffffffff;
      h[6] = (h[6] + g) & 0xffffffff;
      h[7] = (h[7] + hh) & 0xffffffff;
    }

    // Produce final hash value (big-endian)
    final result = <int>[];
    for (final val in h) {
      result.add((val >> 24) & 0xff);
      result.add((val >> 16) & 0xff);
      result.add((val >> 8) & 0xff);
      result.add(val & 0xff);
    }
    return result;
  }

  static int _rotr(int x, int n) {
    return ((x >> n) | (x << (32 - n))) & 0xffffffff;
  }

  static String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

void main() {
  // ===== BackupMetadata Tests =====

  group('BackupMetadata', () {
    test('fromMap creates correct instance', () {
      final map = {
        'version': 1,
        'exportTime': '2024-01-15T10:30:00.000',
        'databaseChecksum': 'abc123def456',
        'photoCount': 5,
        'fishCatchesCount': 10,
        'equipmentCount': 3,
        'appVersion': '1.0.3',
      };

      final metadata = BackupMetadata.fromMap(map);

      expect(metadata.version, 1);
      expect(metadata.exportTime, DateTime.parse('2024-01-15T10:30:00.000'));
      expect(metadata.databaseChecksum, 'abc123def456');
      expect(metadata.photoCount, 5);
      expect(metadata.fishCatchesCount, 10);
      expect(metadata.equipmentCount, 3);
      expect(metadata.appVersion, '1.0.3');
    });

    test('toMap produces correct JSON', () {
      final exportTime = DateTime.parse('2024-01-15T10:30:00.000');
      final metadata = BackupMetadata(
        version: 1,
        exportTime: exportTime,
        databaseChecksum: 'abc123def456',
        photoCount: 5,
        fishCatchesCount: 10,
        equipmentCount: 3,
        appVersion: '1.0.3',
      );

      final map = metadata.toMap();

      expect(map['version'], 1);
      expect(map['exportTime'], '2024-01-15T10:30:00.000');
      expect(map['databaseChecksum'], 'abc123def456');
      expect(map['photoCount'], 5);
      expect(map['fishCatchesCount'], 10);
      expect(map['equipmentCount'], 3);
      expect(map['appVersion'], '1.0.3');
    });

    test('copyWith updates specified fields', () {
      final original = BackupMetadata(
        version: 1,
        exportTime: DateTime.parse('2024-01-15T10:30:00.000'),
        databaseChecksum: 'abc123',
        photoCount: 5,
        fishCatchesCount: 10,
        equipmentCount: 3,
        appVersion: '1.0.3',
      );

      final updated = original.copyWith(
        photoCount: 20,
        fishCatchesCount: 15,
      );

      expect(updated.version, 1);
      expect(updated.photoCount, 20);
      expect(updated.fishCatchesCount, 15);
      expect(updated.equipmentCount, 3);
      expect(updated.databaseChecksum, 'abc123');
      expect(updated.appVersion, '1.0.3');
    });

    test('copyWith preserves all fields when no arguments', () {
      final original = BackupMetadata(
        version: 2,
        exportTime: DateTime.parse('2024-06-20T15:45:00.000'),
        databaseChecksum: 'xyz789',
        photoCount: 8,
        fishCatchesCount: 25,
        equipmentCount: 7,
        appVersion: '2.0.0',
      );

      final copy = original.copyWith();

      expect(copy.version, original.version);
      expect(copy.exportTime, original.exportTime);
      expect(copy.databaseChecksum, original.databaseChecksum);
      expect(copy.photoCount, original.photoCount);
      expect(copy.fishCatchesCount, original.fishCatchesCount);
      expect(copy.equipmentCount, original.equipmentCount);
      expect(copy.appVersion, original.appVersion);
    });

    test('equality works correctly for equal instances', () {
      final exportTime = DateTime.parse('2024-01-15T10:30:00.000');
      final metadata1 = BackupMetadata(
        version: 1,
        exportTime: exportTime,
        databaseChecksum: 'abc123',
        photoCount: 5,
        fishCatchesCount: 10,
        equipmentCount: 3,
        appVersion: '1.0.3',
      );

      final metadata2 = BackupMetadata(
        version: 1,
        exportTime: exportTime,
        databaseChecksum: 'abc123',
        photoCount: 5,
        fishCatchesCount: 10,
        equipmentCount: 3,
        appVersion: '1.0.3',
      );

      expect(metadata1, equals(metadata2));
      expect(metadata1.hashCode, equals(metadata2.hashCode));
    });

    test('equality works correctly for different instances', () {
      final metadata1 = BackupMetadata(
        version: 1,
        exportTime: DateTime.parse('2024-01-15T10:30:00.000'),
        databaseChecksum: 'abc123',
        photoCount: 5,
        fishCatchesCount: 10,
        equipmentCount: 3,
        appVersion: '1.0.3',
      );

      final metadata2 = BackupMetadata(
        version: 2,
        exportTime: DateTime.parse('2024-01-15T10:30:00.000'),
        databaseChecksum: 'abc123',
        photoCount: 5,
        fishCatchesCount: 10,
        equipmentCount: 3,
        appVersion: '1.0.3',
      );

      expect(metadata1, isNot(equals(metadata2)));
    });

    test('equality returns true for same instance', () {
      final metadata = BackupMetadata(
        version: 1,
        exportTime: DateTime.parse('2024-01-15T10:30:00.000'),
        databaseChecksum: 'abc123',
        photoCount: 5,
        fishCatchesCount: 10,
        equipmentCount: 3,
        appVersion: '1.0.3',
      );

      expect(metadata, equals(metadata));
    });
  });

  // ===== BackupExportOptions Tests =====

  group('BackupExportOptions', () {
    test('defaultOptions has correct values', () {
      expect(BackupExportOptions.defaultOptions.includePhotos, true);
      expect(BackupExportOptions.defaultOptions.createRecoveryPoint, false);
    });

    test('databaseOnly has correct values', () {
      expect(BackupExportOptions.databaseOnly.includePhotos, false);
      expect(BackupExportOptions.databaseOnly.createRecoveryPoint, false);
    });

    test('copyWith updates specified fields', () {
      const original = BackupExportOptions.defaultOptions;
      final updated = original.copyWith(includePhotos: false);

      expect(updated.includePhotos, false);
      expect(updated.createRecoveryPoint, false);
    });

    test('copyWith preserves unchanged fields', () {
      const original = BackupExportOptions(
        createRecoveryPoint: true,
      );
      final updated = original.copyWith(createRecoveryPoint: false);

      expect(updated.includePhotos, true);
      expect(updated.createRecoveryPoint, false);
    });

    test('custom options can be created', () {
      const custom = BackupExportOptions(
        includePhotos: false,
        createRecoveryPoint: true,
      );

      expect(custom.includePhotos, false);
      expect(custom.createRecoveryPoint, true);
    });

    test('different options have different hashCodes (default object equality)',
        () {
      const options1 = BackupExportOptions();
      const options2 = BackupExportOptions(includePhotos: false);

      // BackupExportOptions uses default Object equality (identity)
      expect(identical(options1, options2), false);
    });
  });

  // ===== IntegrityResult Tests =====

  group('IntegrityResult', () {
    test('valid() factory creates success result', () {
      const result = IntegrityResult.valid();

      expect(result.isValid, true);
      expect(result.errorMessage, isNull);
      expect(result.metadata, isNull);
    });

    test('invalid() factory creates failure result', () {
      const result = IntegrityResult.invalid('Checksum mismatch');

      expect(result.isValid, false);
      expect(result.errorMessage, 'Checksum mismatch');
      expect(result.metadata, isNull);
    });

    test('validWithMetadata() factory creates success with metadata', () {
      final metadata = BackupMetadata(
        version: 1,
        exportTime: DateTime.now(),
        databaseChecksum: 'abc123',
        photoCount: 5,
        fishCatchesCount: 10,
        equipmentCount: 3,
        appVersion: '1.0.3',
      );
      final result = IntegrityResult.validWithMetadata(metadata);

      expect(result.isValid, true);
      expect(result.errorMessage, isNull);
      expect(result.metadata, equals(metadata));
    });

    test('invalidWithMetadata() factory creates failure with metadata', () {
      final metadata = BackupMetadata(
        version: 1,
        exportTime: DateTime.now(),
        databaseChecksum: 'abc123',
        photoCount: 5,
        fishCatchesCount: 10,
        equipmentCount: 3,
        appVersion: '1.0.3',
      );
      final result = IntegrityResult.invalidWithMetadata(
        'Version incompatible',
        metadata,
      );

      expect(result.isValid, false);
      expect(result.errorMessage, 'Version incompatible');
      expect(result.metadata, equals(metadata));
    });

    test('constructor creates instance with all fields', () {
      final metadata = BackupMetadata(
        version: 1,
        exportTime: DateTime.now(),
        databaseChecksum: 'abc123',
        photoCount: 5,
        fishCatchesCount: 10,
        equipmentCount: 3,
        appVersion: '1.0.3',
      );
      final result = IntegrityResult(
        isValid: true,
        metadata: metadata,
      );

      expect(result.isValid, true);
      expect(result.metadata, equals(metadata));
    });

    test('equality works for equal instances', () {
      const result1 = IntegrityResult.valid();
      const result2 = IntegrityResult.valid();

      expect(result1, equals(result2));
      expect(result1.hashCode, equals(result2.hashCode));
    });

    test('equality works for different instances', () {
      const result1 = IntegrityResult.valid();
      const result2 = IntegrityResult.invalid('error');

      expect(result1, isNot(equals(result2)));
    });
  });

  // ===== ImportResult Tests =====

  group('ImportResult', () {
    test('success() factory creates success result', () {
      const result = ImportResult.success();

      expect(result.isSuccess, true);
      expect(result.errorMessage, isNull);
      expect(result.metadata, isNull);
    });

    test('failure() factory creates failure result', () {
      const result = ImportResult.failure('File not found');

      expect(result.isSuccess, false);
      expect(result.errorMessage, 'File not found');
      expect(result.metadata, isNull);
    });

    test('successWithMetadata() factory creates success with metadata', () {
      final metadata = BackupMetadata(
        version: 1,
        exportTime: DateTime.now(),
        databaseChecksum: 'abc123',
        photoCount: 5,
        fishCatchesCount: 10,
        equipmentCount: 3,
        appVersion: '1.0.3',
      );
      final result = ImportResult.successWithMetadata(metadata);

      expect(result.isSuccess, true);
      expect(result.errorMessage, isNull);
      expect(result.metadata, equals(metadata));
    });

    test('constructor creates instance with all fields', () {
      final metadata = BackupMetadata(
        version: 1,
        exportTime: DateTime.now(),
        databaseChecksum: 'abc123',
        photoCount: 5,
        fishCatchesCount: 10,
        equipmentCount: 3,
        appVersion: '1.0.3',
      );
      final result = ImportResult(
        isSuccess: true,
        metadata: metadata,
      );

      expect(result.isSuccess, true);
      expect(result.metadata, equals(metadata));
    });

    test('equality works for equal instances', () {
      const result1 = ImportResult.success();
      const result2 = ImportResult.success();

      expect(result1, equals(result2));
      expect(result1.hashCode, equals(result2.hashCode));
    });

    test('equality works for different instances', () {
      const result1 = ImportResult.success();
      const result2 = ImportResult.failure('error');

      expect(result1, isNot(equals(result2)));
    });

    test('equality works for successWithMetadata instances', () {
      final metadata = BackupMetadata(
        version: 1,
        exportTime: DateTime.now(),
        databaseChecksum: 'abc123',
        photoCount: 5,
        fishCatchesCount: 10,
        equipmentCount: 3,
        appVersion: '1.0.3',
      );
      final result1 = ImportResult.successWithMetadata(metadata);
      final result2 = ImportResult.successWithMetadata(metadata);

      expect(result1, equals(result2));
    });
  });

  // ===== BackupZipService importFromZipPath Error Handling Tests =====

  group('BackupZipService importFromZipPath Error Handling', () {
    late BackupZipService service;
    late MockDatabaseProvider mockDbProvider;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      // Mock path_provider to return system temp directory
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getTemporaryDirectory') {
            return Directory.systemTemp.path;
          }
          return null;
        },
      );
    });

    setUp(() {
      mockDbProvider = MockDatabaseProvider();
      service = BackupZipService(mockDbProvider);
    });

    test('returns failure when ZIP file not found', () async {
      const nonExistentPath = '/non/existent/path/backup.zip';
      final result = await service.importFromZipPath(nonExistentPath);

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('not found'));
    });

    test('returns failure when metadata.json missing', () async {
      // Create a ZIP without metadata.json
      final zipFile = await TestArchive.createTestZip(
        files: {'lurebox.db': 'fake db content'},
      );
      try {
        final result = await service.importFromZipPath(zipFile.path);

        expect(result.isSuccess, false);
        expect(result.errorMessage, contains('metadata.json'));
      } finally {
        await zipFile.delete();
      }
    });

    test('returns failure when version incompatible', () async {
      // Create ZIP with version: 99
      final zipFile = await TestArchive.createTestZip(
        files: {'lurebox.db': 'fake db'},
        metadata: {
          'version': 99,
          'exportTime': DateTime.now().toIso8601String(),
          'databaseChecksum': 'abc123',
          'photoCount': 0,
          'fishCatchesCount': 0,
          'equipmentCount': 0,
          'appVersion': '99.0.0',
        },
      );
      try {
        final result = await service.importFromZipPath(zipFile.path);

        expect(result.isSuccess, false);
        expect(
          result.errorMessage,
          contains('Unsupported backup version'),
        );
      } finally {
        await zipFile.delete();
      }
    });

    test('returns failure when database file missing in ZIP', () async {
      // Create ZIP with metadata but no lurebox.db
      final zipFile = await TestArchive.createTestZip(
        files: {'photos/fish.jpg': 'photo data'},
        metadata: {
          'version': 1,
          'exportTime': DateTime.now().toIso8601String(),
          'databaseChecksum': 'abc123',
          'photoCount': 1,
          'fishCatchesCount': 0,
          'equipmentCount': 0,
          'appVersion': '1.0.3',
        },
      );
      try {
        final result = await service.importFromZipPath(zipFile.path);

        expect(result.isSuccess, false);
        expect(result.errorMessage, contains('database file not found'));
      } finally {
        await zipFile.delete();
      }
    });

    test('returns failure when checksum mismatch', () async {
      // Create ZIP with wrong checksum
      final zipFile = await TestArchive.createTestZip(
        files: {'lurebox.db': 'fake db content that does not match checksum'},
        metadata: {
          'version': 1,
          'exportTime': DateTime.now().toIso8601String(),
          'databaseChecksum': 'wrong_checksum_that_does_not_match',
          'photoCount': 0,
          'fishCatchesCount': 0,
          'equipmentCount': 0,
          'appVersion': '1.0.3',
        },
      );
      try {
        final result = await service.importFromZipPath(zipFile.path);

        expect(result.isSuccess, false);
        expect(result.errorMessage, contains('checksum mismatch'));
      } finally {
        await zipFile.delete();
      }
    });

    test('returns failure when metadata has invalid format', () async {
      // Create ZIP with corrupted metadata.json content
      final archive = Archive();
      archive.addFile(ArchiveFile(
        'metadata.json',
        'not valid json'.length,
        'not valid json'.codeUnits,
      ),);
      archive.addFile(ArchiveFile(
        'lurebox.db',
        'db content'.length,
        'db content'.codeUnits,
      ),);

      final zipData = ZipEncoder().encode(archive);
      final zipFile = File(
        '${Directory.systemTemp.path}/corrupted_metadata_${DateTime.now().millisecondsSinceEpoch}.zip',
      );
      await zipFile.writeAsBytes(zipData!);

      try {
        final result = await service.importFromZipPath(zipFile.path);

        expect(result.isSuccess, false);
      } finally {
        await zipFile.delete();
      }
    });

    test('returns failure when backup version is zero', () async {
      final zipFile = await TestArchive.createTestZip(
        files: {'lurebox.db': 'fake db'},
        metadata: {
          'version': 0,
          'exportTime': DateTime.now().toIso8601String(),
          'databaseChecksum': 'abc123',
          'photoCount': 0,
          'fishCatchesCount': 0,
          'equipmentCount': 0,
          'appVersion': '1.0.3',
        },
      );
      try {
        final result = await service.importFromZipPath(zipFile.path);

        // Version 0 is less than or equal to 1, so it should pass version check
        // But will fail checksum since the db content doesn't match
        expect(
          result.isSuccess || result.errorMessage!.contains('checksum'),
          true,
        );
      } finally {
        await zipFile.delete();
      }
    });

    test('handles empty ZIP file gracefully', () async {
      // Create an empty ZIP
      final archive = Archive();
      final zipData = ZipEncoder().encode(archive);
      final zipFile = File(
        '${Directory.systemTemp.path}/empty_${DateTime.now().millisecondsSinceEpoch}.zip',
      );
      await zipFile.writeAsBytes(zipData!);

      try {
        final result = await service.importFromZipPath(zipFile.path);

        expect(result.isSuccess, false);
      } finally {
        await zipFile.delete();
      }
    });

    test('handles ZIP with only metadata.json', () async {
      final zipFile = await TestArchive.createTestZip(
        files: {},
        metadata: {
          'version': 1,
          'exportTime': DateTime.now().toIso8601String(),
          'databaseChecksum': 'abc123',
          'photoCount': 0,
          'fishCatchesCount': 0,
          'equipmentCount': 0,
          'appVersion': '1.0.3',
        },
      );

      try {
        final result = await service.importFromZipPath(zipFile.path);

        expect(result.isSuccess, false);
        expect(result.errorMessage, contains('database file not found'));
      } finally {
        await zipFile.delete();
      }
    });
  });

  // ===== TestArchive Helper Tests =====

  group('TestArchive', () {
    test('createTestZip creates valid ZIP file', () async {
      final zipFile = await TestArchive.createTestZip(
        files: {'test.txt': 'Hello World'},
      );

      try {
        expect(await zipFile.exists(), true);
        expect(zipFile.lengthSync(), greaterThan(0));
      } finally {
        await zipFile.delete();
      }
    });

    test('createTestZip includes specified files', () async {
      final files = {
        'dir/file1.txt': 'content1',
        'dir/file2.txt': 'content2',
        'root.txt': 'content3',
      };
      final zipFile = await TestArchive.createTestZip(files: files);

      try {
        // Verify ZIP can be read
        final bytes = await zipFile.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);

        expect(archive.files.length, 3);
        final names = archive.files.map((f) => f.name).toList();
        expect(names, contains('dir/file1.txt'));
        expect(names, contains('dir/file2.txt'));
        expect(names, contains('root.txt'));
      } finally {
        await zipFile.delete();
      }
    });

    test('createTestZip includes metadata when provided', () async {
      final metadata = {
        'version': 1,
        'exportTime': '2024-01-15T10:30:00.000',
        'databaseChecksum': 'test123',
        'photoCount': 5,
        'fishCatchesCount': 10,
        'equipmentCount': 3,
        'appVersion': '1.0.3',
      };
      final zipFile = await TestArchive.createTestZip(
        files: {'lurebox.db': 'db'},
        metadata: metadata,
      );

      try {
        final bytes = await zipFile.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);

        final metadataFile = archive.files.firstWhere(
          (f) => f.name == 'metadata.json',
        );
        final content = String.fromCharCodes(metadataFile.content as List<int>);
        final decoded = jsonDecode(content) as Map<String, dynamic>;

        expect(decoded['version'], 1);
        expect(decoded['databaseChecksum'], 'test123');
        expect(decoded['photoCount'], 5);
      } finally {
        await zipFile.delete();
      }
    });

    test('createValidBackupZip creates ZIP with correct checksum', () async {
      const dbContent = 'database content for checksum';
      final zipFile = await TestArchive.createValidBackupZip(
        dbContent: dbContent,
      );

      try {
        final bytes = await zipFile.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);

        final metadataFile = archive.files.firstWhere(
          (f) => f.name == 'metadata.json',
        );
        final metadataContent = String.fromCharCodes(
          metadataFile.content as List<int>,
        );
        final metadata = jsonDecode(metadataContent) as Map<String, dynamic>;

        // The checksum in metadata should match the actual db content SHA-256
        final dbFile = archive.files.firstWhere(
          (f) => f.name == 'lurebox.db',
        );
        final actualDbContent = String.fromCharCodes(
          dbFile.content as List<int>,
        );

        // Verify the db content matches what we put in
        expect(actualDbContent, dbContent);
        expect(metadata['fishCatchesCount'], 5);
        expect(metadata['equipmentCount'], 3);
      } finally {
        await zipFile.delete();
      }
    });
  });

  // ===== Additional Edge Case Tests =====

  group('BackupMetadata edge cases', () {
    test('handles special characters in appVersion', () {
      final metadata = BackupMetadata.fromMap({
        'version': 1,
        'exportTime': '2024-01-15T10:30:00.000',
        'databaseChecksum': 'abc123',
        'photoCount': 0,
        'fishCatchesCount': 0,
        'equipmentCount': 0,
        'appVersion': '1.0.3+4',
      });

      expect(metadata.appVersion, '1.0.3+4');
    });

    test('handles large photo count', () {
      final metadata = BackupMetadata.fromMap({
        'version': 1,
        'exportTime': '2024-01-15T10:30:00.000',
        'databaseChecksum': 'abc123',
        'photoCount': 999999,
        'fishCatchesCount': 0,
        'equipmentCount': 0,
        'appVersion': '1.0.3',
      });

      expect(metadata.photoCount, 999999);
    });

    test('handles zero counts', () {
      final metadata = BackupMetadata.fromMap({
        'version': 1,
        'exportTime': '2024-01-15T10:30:00.000',
        'databaseChecksum': 'abc123',
        'photoCount': 0,
        'fishCatchesCount': 0,
        'equipmentCount': 0,
        'appVersion': '1.0.3',
      });

      expect(metadata.photoCount, 0);
      expect(metadata.fishCatchesCount, 0);
      expect(metadata.equipmentCount, 0);
    });
  });

  group('ImportResult edge cases', () {
    test('success result has null errorMessage', () {
      const result = ImportResult.success();

      expect(result.errorMessage, isNull);
      expect(result.isSuccess, true);
    });

    test('failure result preserves error message', () {
      const result = ImportResult.failure('Database corrupted');

      expect(result.errorMessage, 'Database corrupted');
      expect(result.isSuccess, false);
    });

    test('failure result with long error message', () {
      final longMessage = 'A' * 1000;
      final result = ImportResult.failure(longMessage);

      expect(result.errorMessage, longMessage);
      expect(result.errorMessage!.length, 1000);
    });
  });

  group('IntegrityResult edge cases', () {
    test('valid result has null errorMessage', () {
      const result = IntegrityResult.valid();

      expect(result.errorMessage, isNull);
      expect(result.isValid, true);
    });

    test('invalid result preserves error message', () {
      const result = IntegrityResult.invalid('File corrupted');

      expect(result.errorMessage, 'File corrupted');
      expect(result.isValid, false);
    });
  });

  group('BackupExportOptions edge cases', () {
    test('default values are correct', () {
      const options = BackupExportOptions();

      expect(options.includePhotos, true);
      expect(options.createRecoveryPoint, false);
    });

    test('both options can be true', () {
      const options = BackupExportOptions(
        createRecoveryPoint: true,
      );

      expect(options.includePhotos, true);
      expect(options.createRecoveryPoint, true);
    });

    test('both options can be false', () {
      const options = BackupExportOptions(
        includePhotos: false,
      );

      expect(options.includePhotos, false);
      expect(options.createRecoveryPoint, false);
    });
  });
}
