import 'package:lurebox/core/repositories/backup_config_repository.dart';
import 'package:lurebox/core/services/app_logger.dart';
import 'package:lurebox/core/services/settings_service.dart';

/// 启动期一次性数据迁移
///
/// 历史上以下迁移逻辑已实现但从未被调用，导致旧版明文凭据长期残留：
/// - [BackupConfigRepository.migrateExistingPasswords]：
///   旧版把 WebDAV 密码明文存在 cloud_configs.password；不迁移的话，
///   每次 ZIP 备份（原样复制整个 DB 文件）都会把明文密码带出去。
/// - [SettingsService.getAiRecognitionSettings]：内含 AI apiKey →
///   安全存储的惰性迁移，但旧版用户若从不打开 AI 设置页则永不触发，
///   明文 apiKey 会跟随 settings 表被 JSON/WebDAV 导出。
///
/// 在 App 启动时调用 [run] 一次。所有失败只记日志，绝不阻断启动。
class StartupMigrationService {
  StartupMigrationService({
    required BackupConfigRepository backupConfigRepository,
    required SettingsService settingsService,
  })  : _backupConfigRepository = backupConfigRepository,
        _settingsService = settingsService;

  final BackupConfigRepository _backupConfigRepository;
  final SettingsService _settingsService;

  static const _tag = 'StartupMigrationService';

  Future<void> run() async {
    try {
      await _backupConfigRepository.migrateExistingPasswords();
    } on Exception catch (e, st) {
      AppLogger.e(_tag, 'WebDAV password migration failed', e, st);
    }

    try {
      // getAiRecognitionSettings 内部完成 apiKey → 安全存储的迁移
      await _settingsService.getAiRecognitionSettings();
    } on Exception catch (e, st) {
      AppLogger.e(_tag, 'AI api-key migration failed', e, st);
    }
  }
}
