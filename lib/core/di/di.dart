import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/database/database_provider.dart';
import 'package:lurebox/core/repositories/backup_config_repository.dart';
import 'package:lurebox/core/repositories/equipment_repository.dart';
import 'package:lurebox/core/repositories/equipment_repository_impl.dart';
import 'package:lurebox/core/repositories/fish_catch_repository.dart';
import 'package:lurebox/core/repositories/fish_catch_repository_impl.dart';
import 'package:lurebox/core/repositories/location_repository.dart';
import 'package:lurebox/core/repositories/location_repository_impl.dart';
import 'package:lurebox/core/repositories/settings_repository.dart';
import 'package:lurebox/core/repositories/settings_repository_impl.dart';
import 'package:lurebox/core/repositories/species_history_repository.dart';
import 'package:lurebox/core/repositories/species_history_repository_impl.dart';
import 'package:lurebox/core/repositories/species_management_service.dart';
import 'package:lurebox/core/repositories/stats_repository.dart';
import 'package:lurebox/core/repositories/stats_repository_impl.dart';
import 'package:lurebox/core/repositories/user_species_alias_repository.dart';
import 'package:lurebox/core/services/achievement_service.dart';
import 'package:lurebox/core/services/backup_service.dart';
import 'package:lurebox/core/services/backup_zip_service.dart';
import 'package:lurebox/core/services/equipment_service.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';
import 'package:lurebox/core/services/fish_recognition_service.dart';
import 'package:lurebox/core/services/fish_species_matcher.dart';
import 'package:lurebox/core/services/location_service.dart';
import 'package:lurebox/core/services/secure_storage_service.dart';
import 'package:lurebox/core/services/settings_service.dart';

// ===== 核心依赖 =====

final databaseProvider = Provider<DatabaseProvider>((ref) {
  return DatabaseProvider.instance;
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

final userSpeciesAliasRepositoryProvider =
    Provider<UserSpeciesAliasRepository>((ref) {
  return SqliteUserSpeciesAliasRepository();
});

final fishSpeciesMatcherProvider = Provider<FishSpeciesMatcher>((ref) {
  return FishSpeciesMatcher();
});

final speciesManagementServiceProvider =
    Provider<SpeciesManagementService>((ref) {
  return SpeciesManagementService(
    aliasRepo: ref.watch(userSpeciesAliasRepositoryProvider),
    matcher: ref.watch(fishSpeciesMatcherProvider),
  );
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

final cloudPasswordStorageProvider = Provider<CloudPasswordStorage>((ref) {
  return SecureCloudPasswordStorage();
});

final backupConfigRepositoryProvider = Provider<BackupConfigRepository>((ref) {
  return SqliteBackupConfigRepository(
    ref.watch(databaseProvider).database,
    ref.watch(cloudPasswordStorageProvider),
  );
});

// ===== Fish Recognition Service =====

final fishRecognitionServiceProvider = Provider<FishRecognitionService>((ref) {
  return FishRecognitionService();
});
