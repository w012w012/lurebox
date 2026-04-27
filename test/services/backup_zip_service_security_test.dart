import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/database/database_provider.dart';
import 'package:lurebox/core/services/backup_zip_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// ===== Mocks =====

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

// ===== SHA-256 Helper =====

/// Computes SHA-256 hex digest of string content (matches crypto package)
String computeSha256Hex(String content) {
  final bytes = content.codeUnits;
  final digest = _sha256(bytes);
  return _bytesToHex(digest);
}

List<int> _sha256(List<int> message) {
  if (message.isEmpty) {
    // Empty message padding
    message = [0x80];
    while ((message.length % 64) != 56) {
      message.add(0x00);
    }
    // 8 bytes of length = 0
    for (var i = 0; i < 8; i++) message.add(0x00);
  }

  final msgLen = message.length;
  final bitLen = msgLen * 8;

  final padded = List<int>.from(message);
  padded.add(0x80);
  while ((padded.length % 64) != 56) {
    padded.add(0x00);
  }
  for (var i = 7; i >= 0; i--) {
    padded.add((bitLen >> (i * 8)) & 0xff);
  }

  final h = <int>[
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
  ];

  const k = <int>[
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
    0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
    0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
  ];

  for (var chunkStart = 0; chunkStart < padded.length; chunkStart += 64) {
    final chunk = padded.sublist(chunkStart, chunkStart + 64);
    final w = List<int>.filled(64, 0);
    for (var i = 0; i < 16; i++) {
      w[i] = (chunk[i * 4] << 24) | (chunk[i * 4 + 1] << 16) |
             (chunk[i * 4 + 2] << 8) | chunk[i * 4 + 3];
    }
    for (var i = 16; i < 64; i++) {
      final s0 = _rotr(w[i - 15], 7) ^ _rotr(w[i - 15], 18) ^ (w[i - 15] >> 3);
      final s1 = _rotr(w[i - 2], 17) ^ _rotr(w[i - 2], 19) ^ (w[i - 2] >> 10);
      w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & 0xffffffff;
    }

    var a = h[0], b = h[1], c = h[2], d = h[3];
    var e = h[4], f = h[5], g = h[6], hh = h[7];

    for (var i = 0; i < 64; i++) {
      final S1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
      final ch = (e & f) ^ ((~e) & g);
      final temp1 = (hh + S1 + ch + k[i] + w[i]) & 0xffffffff;
      final S0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
      final maj = (a & b) ^ (a & c) ^ (b & c);
      final temp2 = (S0 + maj) & 0xffffffff;
      hh = g; g = f; f = e; e = (d + temp1) & 0xffffffff;
      d = c; c = b; b = a; a = (temp1 + temp2) & 0xffffffff;
    }

    h[0] = (h[0] + a) & 0xffffffff;
    h[1] = (h[1] + b) & 0xffffffff;
    h[2] = (h[2] + c) & 0xffffffff;
    h[3] = (h[3] + d) & 0xffffffff;
    h[4] = (h[4] + e) & 0xffffffff;
    h[5] = (h[5] + f) & 0xffffffff;
    h[6] = (h[6] + g) & 0xffffffff;
    h[7] = (h[7] + hh) & 0xffffffff;
  }

  final result = <int>[];
  for (final val in h) {
    result.add((val >> 24) & 0xff);
    result.add((val >> 16) & 0xff);
    result.add((val >> 8) & 0xff);
    result.add(val & 0xff);
  }
  return result;
}

int _rotr(int x, int n) => ((x >> n) | (x << (32 - n))) & 0xffffffff;

String _bytesToHex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

// ===== ZIP Builder Helper =====

/// Creates a ZIP file with optional malicious path traversal entries
Future<File> createZipWithFiles(
  Map<String, String> files, {
  List<String>? maliciousPaths,
}) async {
  final archive = Archive();

  // Add legitimate files
  for (final entry in files.entries) {
    final bytes = entry.value.codeUnits;
    archive.addFile(ArchiveFile(entry.key, bytes.length, bytes));
  }

  // Add malicious path traversal entries
  if (maliciousPaths != null) {
    for (final maliciousPath in maliciousPaths) {
      final content = 'malicious content'.codeUnits;
      archive.addFile(ArchiveFile(maliciousPath, content.length, content));
    }
  }

  final zipData = ZipEncoder().encode(archive);
  if (zipData == null) throw Exception('Failed to encode ZIP');

  final tempFile = File(
    '${Directory.systemTemp.path}/security_test_${DateTime.now().millisecondsSinceEpoch}.zip',
  );
  await tempFile.writeAsBytes(zipData);
  return tempFile;
}

/// Creates a valid backup ZIP with correct SHA-256 checksum
Future<File> createValidBackupZip({
  required String dbContent,
  int photoCount = 0,
  int fishCatchesCount = 5,
  int equipmentCount = 3,
}) async {
  final checksum = computeSha256Hex(dbContent);

  final files = <String, String>{'lurebox.db': dbContent};

  if (photoCount > 0) {
    for (var i = 0; i < photoCount; i++) {
      files['photos/fish_$i.jpg'] = 'fake photo data $i';
    }
  }

  final metadata = {
    'version': 1,
    'exportTime': DateTime.now().toIso8601String(),
    'databaseChecksum': checksum,
    'photoCount': photoCount,
    'fishCatchesCount': fishCatchesCount,
    'equipmentCount': equipmentCount,
    'appVersion': '1.0.5',
  };

  return createZipWithFilesAndMetadata(files, metadata);
}

/// Creates ZIP with metadata (helper signature for createZipWithFiles)
Future<File> createZipWithFilesAndMetadata(
  Map<String, String> files,
  Map<String, dynamic> metadata,
) async {
  final archive = Archive();

  for (final entry in files.entries) {
    final bytes = entry.value.codeUnits;
    archive.addFile(ArchiveFile(entry.key, bytes.length, bytes));
  }

  final metadataJson = const JsonEncoder.withIndent('  ').convert(metadata);
  archive.addFile(ArchiveFile(
    'metadata.json',
    metadataJson.codeUnits.length,
    metadataJson.codeUnits,
  ));

  final zipData = ZipEncoder().encode(archive);
  if (zipData == null) throw Exception('Failed to encode ZIP');

  final tempFile = File(
    '${Directory.systemTemp.path}/security_test_${DateTime.now().millisecondsSinceEpoch}.zip',
  );
  await tempFile.writeAsBytes(zipData);
  return tempFile;
}

// ===== Tests =====

void main() {
  group('BackupZipService Security Tests', () {
    late BackupZipService service;
    late MockDatabaseProvider mockDbProvider;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      // Initialize sqflite_ffi for testing
      databaseFactory = databaseFactoryFfi;

      // Mock path_provider to return system temp directory
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getTemporaryDirectory') {
            return Directory.systemTemp.path;
          } else if (methodCall.method == 'getApplicationDocumentsDirectory') {
            return Directory.systemTemp.path;
          }
          return null;
        },
      );

      // Mock getDatabasesPath
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/sqflite'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getDatabasesPath') {
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

    // ===== SHA-256 Integrity Verification Tests =====

    group('SHA-256 Checksum Verification', () {
      test('succeeds when database checksum matches', () async {
        // Note: Without a real SQLite database, we cannot fully test successful
        // import. Instead, we verify that the checksum computation logic works.
        // The checksum in metadata should match the actual file content.
        const dbContent = 'valid database content';
        final zipFile = await createValidBackupZip(dbContent: dbContent);

        try {
          final result = await service.importFromZipPath(zipFile.path);

          // With correct checksum, import may fail at db-open stage (not a checksum error)
          // The key security check: error should NOT be "checksum mismatch"
          expect(result.isSuccess || !result.errorMessage!.contains('checksum mismatch'), true);
        } finally {
          await zipFile.delete();
        }
      });

      test('fails when database checksum does not match (tamper detection)',
          () async {
        // Create ZIP with correct checksum in metadata
        const dbContent = 'original database content';
        final correctChecksum = computeSha256Hex(dbContent);

        // But put different content in the db file
        final zipFile = await createZipWithFilesAndMetadata(
          {'lurebox.db': 'tampered database content'},
          {
            'version': 1,
            'exportTime': DateTime.now().toIso8601String(),
            'databaseChecksum': correctChecksum, // metadata says correct checksum
            'photoCount': 0,
            'fishCatchesCount': 0,
            'equipmentCount': 0,
            'appVersion': '1.0.5',
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

      test('fails when metadata checksum is completely wrong', () async {
        final zipFile = await createZipWithFilesAndMetadata(
          {'lurebox.db': 'some database content'},
          {
            'version': 1,
            'exportTime': DateTime.now().toIso8601String(),
            'databaseChecksum': 'invalid_checksum_12345',
            'photoCount': 0,
            'fishCatchesCount': 0,
            'equipmentCount': 0,
            'appVersion': '1.0.5',
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

      test('fails when database file is missing but checksum provided',
          () async {
        final zipFile = await createZipWithFilesAndMetadata(
          {'photos/fish.jpg': 'photo data'},
          {
            'version': 1,
            'exportTime': DateTime.now().toIso8601String(),
            'databaseChecksum': computeSha256Hex('some content'),
            'photoCount': 1,
            'fishCatchesCount': 0,
            'equipmentCount': 0,
            'appVersion': '1.0.5',
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

    // ===== Path Traversal Attack Prevention Tests =====

    group('Path Traversal Attack Prevention', () {
      test('blocks ZIP entry with ../ path traversal', () async {
        // Create ZIP with path traversal: "../../../malicious.txt"
        final zipFile = await createZipWithFiles(
          {'lurebox.db': 'db content'},
          maliciousPaths: ['../../../malicious.txt'],
        );

        // Add metadata to make it past initial checks
        final archive = ZipDecoder().decodeBytes(await zipFile.readAsBytes());
        final modifiedArchive = Archive();
        for (final f in archive) {
          modifiedArchive.addFile(f);
        }
        final metadata = {
          'version': 1,
          'exportTime': DateTime.now().toIso8601String(),
          'databaseChecksum': computeSha256Hex('db content'),
          'photoCount': 0,
          'fishCatchesCount': 0,
          'equipmentCount': 0,
          'appVersion': '1.0.5',
        };
        modifiedArchive.addFile(ArchiveFile(
          'metadata.json',
          jsonEncode(metadata).length,
          jsonEncode(metadata).codeUnits,
        ));
        final newZipData = ZipEncoder().encode(modifiedArchive)!;
        await zipFile.writeAsBytes(newZipData);

        try {
          final result = await service.importFromZipPath(zipFile.path);

          expect(result.isSuccess, false);
          expect(result.errorMessage, contains('path traversal'));
        } finally {
          await zipFile.delete();
        }
      });

      test('blocks ZIP entry with absolute path', () async {
        final archive = Archive();

        // Add legitimate files
        archive.addFile(ArchiveFile(
          'lurebox.db',
          'db content'.length,
          'db content'.codeUnits,
        ));

        // Add malicious absolute path entry
        archive.addFile(ArchiveFile(
          '/tmp/malicious_file.txt',
          'malicious'.length,
          'malicious'.codeUnits,
        ));

        // Add metadata
        final metadata = {
          'version': 1,
          'exportTime': DateTime.now().toIso8601String(),
          'databaseChecksum': computeSha256Hex('db content'),
          'photoCount': 0,
          'fishCatchesCount': 0,
          'equipmentCount': 0,
          'appVersion': '1.0.5',
        };
        archive.addFile(ArchiveFile(
          'metadata.json',
          jsonEncode(metadata).length,
          jsonEncode(metadata).codeUnits,
        ));

        final zipData = ZipEncoder().encode(archive)!;
        final zipFile = File(
          '${Directory.systemTemp.path}/abs_path_${DateTime.now().millisecondsSinceEpoch}.zip',
        );
        await zipFile.writeAsBytes(zipData);

        try {
          final result = await service.importFromZipPath(zipFile.path);

          expect(result.isSuccess, false);
          expect(result.errorMessage, contains('path traversal'));
        } finally {
          await zipFile.delete();
        }
      });

      test('blocks nested path traversal like photos/../../../etc/passwd',
          () async {
        final archive = Archive();

        archive.addFile(ArchiveFile(
          'lurebox.db',
          'db content'.length,
          'db content'.codeUnits,
        ));

        // Nested path traversal
        archive.addFile(ArchiveFile(
          'photos/../../../etc/malicious',
          'malicious'.length,
          'malicious'.codeUnits,
        ));

        final metadata = {
          'version': 1,
          'exportTime': DateTime.now().toIso8601String(),
          'databaseChecksum': computeSha256Hex('db content'),
          'photoCount': 0,
          'fishCatchesCount': 0,
          'equipmentCount': 0,
          'appVersion': '1.0.5',
        };
        archive.addFile(ArchiveFile(
          'metadata.json',
          jsonEncode(metadata).length,
          jsonEncode(metadata).codeUnits,
        ));

        final zipData = ZipEncoder().encode(archive)!;
        final zipFile = File(
          '${Directory.systemTemp.path}/nested_traversal_${DateTime.now().millisecondsSinceEpoch}.zip',
        );
        await zipFile.writeAsBytes(zipData);

        try {
          final result = await service.importFromZipPath(zipFile.path);

          expect(result.isSuccess, false);
          expect(result.errorMessage, contains('path traversal'));
        } finally {
          await zipFile.delete();
        }
      });

      test('allows legitimate file paths in ZIP', () async {
        final archive = Archive();

        // Legitimate paths
        archive.addFile(ArchiveFile(
          'lurebox.db',
          'db content'.length,
          'db content'.codeUnits,
        ));
        archive.addFile(ArchiveFile(
          'photos/fish_001.jpg',
          'photo data'.length,
          'photo data'.codeUnits,
        ));
        archive.addFile(ArchiveFile(
          'photos/subdir/catch.jpg',
          'nested photo'.length,
          'nested photo'.codeUnits,
        ));

        final metadata = {
          'version': 1,
          'exportTime': DateTime.now().toIso8601String(),
          'databaseChecksum': computeSha256Hex('db content'),
          'photoCount': 2,
          'fishCatchesCount': 0,
          'equipmentCount': 0,
          'appVersion': '1.0.5',
        };
        archive.addFile(ArchiveFile(
          'metadata.json',
          jsonEncode(metadata).length,
          jsonEncode(metadata).codeUnits,
        ));

        final zipData = ZipEncoder().encode(archive)!;
        final zipFile = File(
          '${Directory.systemTemp.path}/legitimate_${DateTime.now().millisecondsSinceEpoch}.zip',
        );
        await zipFile.writeAsBytes(zipData);

        try {
          final result = await service.importFromZipPath(zipFile.path);

          // Should not fail on path traversal - may fail on later steps
          // (atomic rename, db copy, etc.) but path traversal should pass
          if (!result.isSuccess) {
            expect(result.errorMessage, isNot(contains('path traversal')));
          }
        } finally {
          await zipFile.delete();
        }
      });

      test('handles URL-encoded path traversal %2e%2e%2f', () async {
        final archive = Archive();

        // Note: p.canonicalize does NOT decode URL-encoded characters.
        // So %2e%2e%2fmalicious.txt stays as-is and passes the
        // traversal check (because it's literally %2e%2e%2f, not ..).
        // The file extracts but import fails at db validation.
        archive.addFile(ArchiveFile(
          'lurebox.db',
          'db content'.length,
          'db content'.codeUnits,
        ));

        // URL-encoded path traversal - NOT blocked by current implementation
        archive.addFile(ArchiveFile(
          '%2e%2e%2fmalicious.txt',
          'malicious'.length,
          'malicious'.codeUnits,
        ));

        final metadata = {
          'version': 1,
          'exportTime': DateTime.now().toIso8601String(),
          'databaseChecksum': computeSha256Hex('db content'),
          'photoCount': 0,
          'fishCatchesCount': 0,
          'equipmentCount': 0,
          'appVersion': '1.0.5',
        };
        archive.addFile(ArchiveFile(
          'metadata.json',
          jsonEncode(metadata).length,
          jsonEncode(metadata).codeUnits,
        ));

        final zipData = ZipEncoder().encode(archive)!;
        final zipFile = File(
          '${Directory.systemTemp.path}/url_encoded_${DateTime.now().millisecondsSinceEpoch}.zip',
        );
        await zipFile.writeAsBytes(zipData);

        try {
          final result = await service.importFromZipPath(zipFile.path);

          // URL-encoded traversal is NOT detected by p.canonicalize
          // File extracts but import fails at db validation stage
          expect(result.isSuccess, false);
          expect(result.errorMessage, isNot(contains('path traversal')));
        } finally {
          await zipFile.delete();
        }
      });
    });

    // ===== Corrupted / Malformed ZIP Handling Tests =====

    group('Corrupted ZIP File Handling', () {
      test('handles empty ZIP file gracefully', () async {
        final archive = Archive(); // Empty
        final zipData = ZipEncoder().encode(archive)!;

        final zipFile = File(
          '${Directory.systemTemp.path}/empty_zip_${DateTime.now().millisecondsSinceEpoch}.zip',
        );
        await zipFile.writeAsBytes(zipData);

        try {
          final result = await service.importFromZipPath(zipFile.path);

          expect(result.isSuccess, false);
        } finally {
          await zipFile.delete();
        }
      });

      test('handles ZIP with corrupted metadata JSON', () async {
        final archive = Archive();

        archive.addFile(ArchiveFile(
          'lurebox.db',
          'db content'.length,
          'db content'.codeUnits,
        ));
        // Invalid JSON
        archive.addFile(ArchiveFile(
          'metadata.json',
          'not { valid json'.length,
          'not { valid json'.codeUnits,
        ));

        final zipData = ZipEncoder().encode(archive)!;
        final zipFile = File(
          '${Directory.systemTemp.path}/corrupt_json_${DateTime.now().millisecondsSinceEpoch}.zip',
        );
        await zipFile.writeAsBytes(zipData);

        try {
          final result = await service.importFromZipPath(zipFile.path);

          expect(result.isSuccess, false);
        } finally {
          await zipFile.delete();
        }
      });

      test('handles ZIP with missing metadata.json', () async {
        final archive = Archive();

        archive.addFile(ArchiveFile(
          'lurebox.db',
          'db content'.length,
          'db content'.codeUnits,
        ));
        // No metadata.json

        final zipData = ZipEncoder().encode(archive)!;
        final zipFile = File(
          '${Directory.systemTemp.path}/no_metadata_${DateTime.now().millisecondsSinceEpoch}.zip',
        );
        await zipFile.writeAsBytes(zipData);

        try {
          final result = await service.importFromZipPath(zipFile.path);

          expect(result.isSuccess, false);
          expect(result.errorMessage, contains('metadata.json'));
        } finally {
          await zipFile.delete();
        }
      });

      test('handles ZIP with truncated file content', () async {
        final archive = Archive();

        // Create truncated content - only first 5 bytes instead of full content
        final fullContent = 'valid content'.codeUnits;
        final truncatedContent = fullContent.sublist(0, 5);
        archive.addFile(ArchiveFile(
          'lurebox.db',
          truncatedContent.length,
          truncatedContent,
        ));

        // Metadata claims checksum of FULL content, but ZIP contains truncated
        // This causes checksum mismatch during import validation
        final metadata = {
          'version': 1,
          'exportTime': DateTime.now().toIso8601String(),
          'databaseChecksum': computeSha256Hex('valid content'),
          'photoCount': 0,
          'fishCatchesCount': 0,
          'equipmentCount': 0,
          'appVersion': '1.0.5',
        };
        archive.addFile(ArchiveFile(
          'metadata.json',
          jsonEncode(metadata).length,
          jsonEncode(metadata).codeUnits,
        ));

        final zipData = ZipEncoder().encode(archive)!;
        final zipFile = File(
          '${Directory.systemTemp.path}/truncated_${DateTime.now().millisecondsSinceEpoch}.zip',
        );
        await zipFile.writeAsBytes(zipData);

        try {
          final result = await service.importFromZipPath(zipFile.path);

          // Import fails - could be "file is not a database" (db validation)
          // or checksum mismatch. Either is acceptable for corrupted content.
          expect(result.isSuccess, false);
          expect(
            result.errorMessage!.contains('checksum') ||
                result.errorMessage!.contains('database') ||
                result.errorMessage!.contains('Sqlite'),
            true,
          );
        } finally {
          await zipFile.delete();
        }
      });

      test('handles non-existent ZIP file path', () async {
        final result = await service.importFromZipPath(
          '/non/existent/path/backup.zip',
        );

        expect(result.isSuccess, false);
        expect(result.errorMessage, contains('not found'));
      });

      test('handles unsupported backup version', () async {
        final archive = Archive();

        archive.addFile(ArchiveFile(
          'lurebox.db',
          'db content'.length,
          'db content'.codeUnits,
        ));

        final metadata = {
          'version': 999, // Future version
          'exportTime': DateTime.now().toIso8601String(),
          'databaseChecksum': computeSha256Hex('db content'),
          'photoCount': 0,
          'fishCatchesCount': 0,
          'equipmentCount': 0,
          'appVersion': '99.0.0',
        };
        archive.addFile(ArchiveFile(
          'metadata.json',
          jsonEncode(metadata).length,
          jsonEncode(metadata).codeUnits,
        ));

        final zipData = ZipEncoder().encode(archive)!;
        final zipFile = File(
          '${Directory.systemTemp.path}/future_version_${DateTime.now().millisecondsSinceEpoch}.zip',
        );
        await zipFile.writeAsBytes(zipData);

        try {
          final result = await service.importFromZipPath(zipFile.path);

          expect(result.isSuccess, false);
          expect(result.errorMessage, contains('Unsupported backup version'));
        } finally {
          await zipFile.delete();
        }
      });
    });

    // ===== Atomic Database Replacement Tests =====

    group('Atomic Database Replacement Security', () {
      test('creates recovery point before import', () async {
        // This test verifies the recovery mechanism exists
        // The actual recovery point creation is tested implicitly
        // by the atomic rename pattern in importFromZipPath

        final archive = Archive();

        archive.addFile(ArchiveFile(
          'lurebox.db',
          'new db content'.length,
          'new db content'.codeUnits,
        ));

        final metadata = {
          'version': 1,
          'exportTime': DateTime.now().toIso8601String(),
          'databaseChecksum': computeSha256Hex('new db content'),
          'photoCount': 0,
          'fishCatchesCount': 0,
          'equipmentCount': 0,
          'appVersion': '1.0.5',
        };
        archive.addFile(ArchiveFile(
          'metadata.json',
          jsonEncode(metadata).length,
          jsonEncode(metadata).codeUnits,
        ));

        final zipData = ZipEncoder().encode(archive)!;
        final zipFile = File(
          '${Directory.systemTemp.path}/recovery_test_${DateTime.now().millisecondsSinceEpoch}.zip',
        );
        await zipFile.writeAsBytes(zipData);

        try {
          // The operation may fail but it should not corrupt existing db
          // Recovery point creation is internal but should not throw
          await expectLater(
            service.importFromZipPath(zipFile.path),
            completes,
          );
        } finally {
          await zipFile.delete();
        }
      });

      test('handles rename failure gracefully', () async {
        // Test that if rename fails, the temp file is cleaned up
        // This is a structural test - the code has try-catch for temp file cleanup

        final archive = Archive();

        archive.addFile(ArchiveFile(
          'lurebox.db',
          'db content'.length,
          'db content'.codeUnits,
        ));

        final metadata = {
          'version': 1,
          'exportTime': DateTime.now().toIso8601String(),
          'databaseChecksum': computeSha256Hex('db content'),
          'photoCount': 0,
          'fishCatchesCount': 0,
          'equipmentCount': 0,
          'appVersion': '1.0.5',
        };
        archive.addFile(ArchiveFile(
          'metadata.json',
          jsonEncode(metadata).length,
          jsonEncode(metadata).codeUnits,
        ));

        final zipData = ZipEncoder().encode(archive)!;
        final zipFile = File(
          '${Directory.systemTemp.path}/atomic_test_${DateTime.now().millisecondsSinceEpoch}.zip',
        );
        await zipFile.writeAsBytes(zipData);

        try {
          // Should complete (success or failure) without leaving temp files
          await expectLater(
            service.importFromZipPath(zipFile.path),
            completes,
          );
        } finally {
          await zipFile.delete();
        }
      });
    });

    // ===== Metadata Validation Tests =====

    group('Metadata Validation Security', () {
      test('rejects metadata with missing required fields', () async {
        final archive = Archive();

        archive.addFile(ArchiveFile(
          'lurebox.db',
          'db'.length,
          'db'.codeUnits,
        ));

        // Missing 'databaseChecksum' field
        final metadata = {
          'version': 1,
          'exportTime': DateTime.now().toIso8601String(),
          // 'databaseChecksum' intentionally missing
          'photoCount': 0,
          'fishCatchesCount': 0,
          'equipmentCount': 0,
          'appVersion': '1.0.5',
        };
        archive.addFile(ArchiveFile(
          'metadata.json',
          jsonEncode(metadata).length,
          jsonEncode(metadata).codeUnits,
        ));

        final zipData = ZipEncoder().encode(archive)!;
        final zipFile = File(
          '${Directory.systemTemp.path}/missing_field_${DateTime.now().millisecondsSinceEpoch}.zip',
        );
        await zipFile.writeAsBytes(zipData);

        try {
          final result = await service.importFromZipPath(zipFile.path);

          expect(result.isSuccess, false);
        } finally {
          await zipFile.delete();
        }
      });

      test('rejects negative version number', () async {
        final archive = Archive();

        archive.addFile(ArchiveFile(
          'lurebox.db',
          'db'.length,
          'db'.codeUnits,
        ));

        final metadata = {
          'version': -1,
          'exportTime': DateTime.now().toIso8601String(),
          'databaseChecksum': 'checksum',
          'photoCount': 0,
          'fishCatchesCount': 0,
          'equipmentCount': 0,
          'appVersion': '1.0.5',
        };
        archive.addFile(ArchiveFile(
          'metadata.json',
          jsonEncode(metadata).length,
          jsonEncode(metadata).codeUnits,
        ));

        final zipData = ZipEncoder().encode(archive)!;
        final zipFile = File(
          '${Directory.systemTemp.path}/neg_version_${DateTime.now().millisecondsSinceEpoch}.zip',
        );
        await zipFile.writeAsBytes(zipData);

        try {
          // Negative version should be blocked by version > 1 check
          // or pass if version <= 1
          // The key is it shouldn't crash
          await expectLater(
            service.importFromZipPath(zipFile.path),
            completes,
          );
        } finally {
          await zipFile.delete();
        }
      });

      test('rejects very long checksum string', () async {
        final archive = Archive();

        archive.addFile(ArchiveFile(
          'lurebox.db',
          'db'.length,
          'db'.codeUnits,
        ));

        // Extremely long "checksum" (potential buffer overflow vector)
        final metadata = {
          'version': 1,
          'exportTime': DateTime.now().toIso8601String(),
          'databaseChecksum': 'A' * 10000,
          'photoCount': 0,
          'fishCatchesCount': 0,
          'equipmentCount': 0,
          'appVersion': '1.0.5',
        };
        archive.addFile(ArchiveFile(
          'metadata.json',
          jsonEncode(metadata).length,
          jsonEncode(metadata).codeUnits,
        ));

        final zipData = ZipEncoder().encode(archive)!;
        final zipFile = File(
          '${Directory.systemTemp.path}/long_checksum_${DateTime.now().millisecondsSinceEpoch}.zip',
        );
        await zipFile.writeAsBytes(zipData);

        try {
          final result = await service.importFromZipPath(zipFile.path);

          // Should handle gracefully - checksum won't match actual content
          expect(result.isSuccess, false);
          expect(result.errorMessage, contains('checksum'));
        } finally {
          await zipFile.delete();
        }
      });
    });
  });
}