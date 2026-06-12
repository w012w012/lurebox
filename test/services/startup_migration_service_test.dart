import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/repositories/backup_config_repository.dart';
import 'package:lurebox/core/services/error_service.dart';
import 'package:lurebox/core/services/settings_service.dart';
import 'package:lurebox/core/services/startup_migration_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockBackupConfigRepository extends Mock
    implements BackupConfigRepository {}

class _MockSettingsService extends Mock implements SettingsService {}

void main() {
  late _MockBackupConfigRepository backupConfigRepository;
  late _MockSettingsService settingsService;
  late StartupMigrationService service;

  setUp(() {
    backupConfigRepository = _MockBackupConfigRepository();
    settingsService = _MockSettingsService();
    service = StartupMigrationService(
      backupConfigRepository: backupConfigRepository,
      settingsService: settingsService,
    );

    when(() => backupConfigRepository.migrateExistingPasswords())
        .thenAnswer((_) async {});
    when(() => settingsService.getAiRecognitionSettings())
        .thenAnswer((_) async => const AiRecognitionSettings());
  });

  group('StartupMigrationService.run', () {
    test('触发明文 WebDAV 密码迁移', () async {
      await service.run();

      verify(() => backupConfigRepository.migrateExistingPasswords()).called(1);
    });

    test('触发 AI apiKey 迁移（getAiRecognitionSettings 内含迁移逻辑）', () async {
      await service.run();

      verify(() => settingsService.getAiRecognitionSettings()).called(1);
    });

    test('密码迁移失败不阻断 AI key 迁移', () async {
      when(() => backupConfigRepository.migrateExistingPasswords())
          .thenThrow(Exception('db locked'));

      await service.run();

      verify(() => settingsService.getAiRecognitionSettings()).called(1);
    });

    test('两个迁移都失败时 run() 不抛异常（启动不能被迁移失败打断）', () async {
      when(() => backupConfigRepository.migrateExistingPasswords())
          .thenThrow(Exception('db locked'));
      when(() => settingsService.getAiRecognitionSettings())
          .thenThrow(const SettingsCorruptedException('corrupted'));

      await expectLater(service.run(), completes);
    });
  });
}
