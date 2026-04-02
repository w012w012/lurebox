import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/fish_catch_repository.dart';
import '../repositories/fish_catch_repository_impl.dart';
import '../repositories/equipment_repository.dart';
import '../repositories/equipment_repository_impl.dart';
import '../repositories/species_history_repository.dart';
import '../repositories/species_history_repository_impl.dart';
import '../repositories/location_repository.dart';
import '../repositories/location_repository_impl.dart';
import '../repositories/settings_repository.dart';
import '../repositories/settings_repository_impl.dart';
import '../repositories/stats_repository.dart';
import '../repositories/stats_repository_impl.dart';
import '../services/fish_catch_service.dart';
import '../services/equipment_service.dart';
import '../services/settings_service.dart';
import '../services/achievement_service.dart';
import '../services/location_service.dart';
import '../services/backup_service.dart';
import '../services/backup_zip_service.dart';
import '../repositories/backup_config_repository.dart';
import '../database/database_provider.dart';
import '../models/ai_recognition_settings.dart';
import '../providers/ai_recognition_provider.dart';
import '../services/fish_recognition_service.dart';

// ===== 核心依赖 =====

final databaseProvider = Provider<DatabaseProvider>((ref) {
  return DatabaseProvider();
});

// ===== Repository 层 =====

final fishCatchRepositoryProvider = Provider<FishCatchRepository>((ref) {
  return SqliteFishCatchRepository();
});

final equipmentRepositoryProvider = Provider<EquipmentRepository>((ref) {
  return SqliteEquipmentRepository();
});

final speciesHistoryRepositoryProvider = Provider<SpeciesHistoryRepository>((
  ref,
) {
  return SqliteSpeciesHistoryRepository();
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return SqliteLocationRepository();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SqliteSettingsRepository();
});

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return SqliteStatsRepository();
});

// ===== Service 层 =====

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService(
    ref.watch(databaseProvider),
  );
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(databaseProvider));
});

final backupZipServiceProvider = Provider<BackupZipService>((ref) {
  return BackupZipService(ref.watch(databaseProvider));
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(ref.watch(settingsRepositoryProvider));
});

final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService(ref.watch(statsRepositoryProvider));
});

final fishCatchServiceProvider = Provider<FishCatchService>((ref) {
  final repository = ref.watch(fishCatchRepositoryProvider);
  final speciesHistoryRepo = ref.watch(speciesHistoryRepositoryProvider);
  final statsRepo = ref.watch(statsRepositoryProvider);
  return FishCatchService(repository, speciesHistoryRepo, statsRepo);
});

final equipmentServiceProvider = Provider<EquipmentService>((ref) {
  final repository = ref.watch(equipmentRepositoryProvider);
  return EquipmentService(repository);
});

// ===== Backup Config Repository =====

final backupConfigRepositoryProvider = Provider<BackupConfigRepository>((ref) {
  return SqliteBackupConfigRepository(
    ref.watch(databaseProvider).database,
  );
});

// ===== AI Recognition Provider =====

final aiRecognitionSettingsProvider =
    StateNotifierProvider<AiRecognitionSettingsNotifier, AiRecognitionSettings>(
  (ref) => AiRecognitionSettingsNotifier(ref.read(settingsServiceProvider)),
);

// ===== Fish Recognition Service =====

final fishRecognitionServiceProvider = Provider<FishRecognitionService>((ref) {
  return FishRecognitionService();
});
