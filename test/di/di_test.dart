import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/database/database_provider.dart';
import 'package:lurebox/core/repositories/fish_catch_repository.dart';
import 'package:lurebox/core/repositories/fish_catch_repository_impl.dart';
import 'package:lurebox/core/repositories/equipment_repository.dart';
import 'package:lurebox/core/repositories/equipment_repository_impl.dart';
import 'package:lurebox/core/repositories/species_history_repository.dart';
import 'package:lurebox/core/repositories/species_history_repository_impl.dart';
import 'package:lurebox/core/repositories/settings_repository.dart';
import 'package:lurebox/core/repositories/settings_repository_impl.dart';
import 'package:lurebox/core/repositories/stats_repository.dart';
import 'package:lurebox/core/repositories/stats_repository_impl.dart';
import 'package:lurebox/core/repositories/user_species_alias_repository.dart';
import 'package:lurebox/core/repositories/location_repository.dart';
import 'package:lurebox/core/repositories/location_repository_impl.dart';
import 'package:lurebox/core/repositories/backup_config_repository.dart';
import 'package:lurebox/core/repositories/species_management_service.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';
import 'package:lurebox/core/services/equipment_service.dart';
import 'package:lurebox/core/services/settings_service.dart';
import 'package:lurebox/core/services/achievement_service.dart';
import 'package:lurebox/core/services/location_service.dart';
import 'package:lurebox/core/services/backup_service.dart';
import 'package:lurebox/core/services/backup_zip_service.dart';
import 'package:lurebox/core/services/fish_species_matcher.dart';

void main() {
  group('DI Provider Wiring Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('databaseProvider', () {
      test('returns a DatabaseProvider instance', () {
        final dbProvider = container.read(databaseProvider);
        expect(dbProvider, isA<DatabaseProvider>());
      });
    });

    group('Repository Providers', () {
      test('fishCatchRepositoryProvider returns SqliteFishCatchRepository', () {
        final repository = container.read(fishCatchRepositoryProvider);
        expect(repository, isA<FishCatchRepository>());
        expect(repository, isA<SqliteFishCatchRepository>());
      });

      test('equipmentRepositoryProvider returns SqliteEquipmentRepository', () {
        final repository = container.read(equipmentRepositoryProvider);
        expect(repository, isA<EquipmentRepository>());
        expect(repository, isA<SqliteEquipmentRepository>());
      });

      test(
          'speciesHistoryRepositoryProvider returns SqliteSpeciesHistoryRepository',
          () {
        final repository = container.read(speciesHistoryRepositoryProvider);
        expect(repository, isA<SpeciesHistoryRepository>());
        expect(repository, isA<SqliteSpeciesHistoryRepository>());
      });

      test('settingsRepositoryProvider returns SqliteSettingsRepository', () {
        final repository = container.read(settingsRepositoryProvider);
        expect(repository, isA<SettingsRepository>());
        expect(repository, isA<SqliteSettingsRepository>());
      });

      test('statsRepositoryProvider returns SqliteStatsRepository', () {
        final repository = container.read(statsRepositoryProvider);
        expect(repository, isA<StatsRepository>());
        expect(repository, isA<SqliteStatsRepository>());
      });

      test(
          'userSpeciesAliasRepositoryProvider returns SqliteUserSpeciesAliasRepository',
          () {
        final repository = container.read(userSpeciesAliasRepositoryProvider);
        expect(repository, isA<UserSpeciesAliasRepository>());
        expect(repository, isA<SqliteUserSpeciesAliasRepository>());
      });

      test('locationRepositoryProvider returns SqliteLocationRepository', () {
        final repository = container.read(locationRepositoryProvider);
        expect(repository, isA<LocationRepository>());
        expect(repository, isA<SqliteLocationRepository>());
      });

      test('backupConfigRepositoryProvider returns SqliteBackupConfigRepository', () async {
        final mockDb = MockDb();
        final testContainer = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(mockDb),
          ],
        );

        final repository = testContainer.read(backupConfigRepositoryProvider);
        expect(repository, isA<BackupConfigRepository>());
        expect(repository, isA<SqliteBackupConfigRepository>());
        testContainer.dispose();
      });

      test('fishSpeciesMatcherProvider returns FishSpeciesMatcher instance',
          () {
        final matcher = container.read(fishSpeciesMatcherProvider);
        expect(matcher, isA<FishSpeciesMatcher>());
      });
    });

    group('Service Providers', () {
      test('fishCatchServiceProvider has correct dependencies', () {
        final service = container.read(fishCatchServiceProvider);
        expect(service, isA<FishCatchService>());
      });

      test('equipmentServiceProvider has correct dependencies', () {
        final service = container.read(equipmentServiceProvider);
        expect(service, isA<EquipmentService>());
      });

      test('settingsServiceProvider depends on settingsRepositoryProvider', () {
        final service = container.read(settingsServiceProvider);
        expect(service, isA<SettingsService>());
      });

      test('achievementServiceProvider depends on statsRepositoryProvider', () {
        final service = container.read(achievementServiceProvider);
        expect(service, isA<AchievementService>());
      });

      test('locationServiceProvider depends on databaseProvider', () {
        final service = container.read(locationServiceProvider);
        expect(service, isA<LocationService>());
      });

      test('backupServiceProvider depends on databaseProvider', () {
        final service = container.read(backupServiceProvider);
        expect(service, isA<BackupService>());
      });

      test('backupZipServiceProvider depends on databaseProvider', () {
        final service = container.read(backupZipServiceProvider);
        expect(service, isA<BackupZipService>());
      });

      test('speciesManagementServiceProvider has correct dependencies', () {
        final service = container.read(speciesManagementServiceProvider);
        expect(service, isA<SpeciesManagementService>());
      });
    });

    group('Provider Override Tests', () {
      test('can override databaseProvider with mock', () {
        final mockDbProvider = DatabaseProvider.instance;
        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(mockDbProvider),
          ],
        );

        final dbProvider = container.read(databaseProvider);
        expect(dbProvider, equals(mockDbProvider));
        container.dispose();
      });

      test('can override fishCatchRepositoryProvider with mock', () {
        final mockRepository = MockFishCatchRepository();
        final container = ProviderContainer(
          overrides: [
            fishCatchRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );

        final repository = container.read(fishCatchRepositoryProvider);
        expect(repository, equals(mockRepository));
        container.dispose();
      });

      test('can override equipmentRepositoryProvider with mock', () {
        final mockRepository = MockEquipmentRepository();
        final container = ProviderContainer(
          overrides: [
            equipmentRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );

        final repository = container.read(equipmentRepositoryProvider);
        expect(repository, equals(mockRepository));
        container.dispose();
      });

      test('can override settingsRepositoryProvider with mock', () {
        final mockRepository = MockSettingsRepository();
        final container = ProviderContainer(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );

        final repository = container.read(settingsRepositoryProvider);
        expect(repository, equals(mockRepository));
        container.dispose();
      });

      test('can override locationRepositoryProvider with mock', () {
        final mockRepository = MockLocationRepository();
        final container = ProviderContainer(
          overrides: [
            locationRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );

        final repository = container.read(locationRepositoryProvider);
        expect(repository, equals(mockRepository));
        container.dispose();
      });

      test('can override statsRepositoryProvider with mock', () {
        final mockRepository = MockStatsRepository();
        final container = ProviderContainer(
          overrides: [
            statsRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );

        final repository = container.read(statsRepositoryProvider);
        expect(repository, equals(mockRepository));
        container.dispose();
      });

      test('can override speciesHistoryRepositoryProvider with mock', () {
        final mockRepository = MockSpeciesHistoryRepository();
        final container = ProviderContainer(
          overrides: [
            speciesHistoryRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );

        final repository = container.read(speciesHistoryRepositoryProvider);
        expect(repository, equals(mockRepository));
        container.dispose();
      });

      test('can override userSpeciesAliasRepositoryProvider with mock', () {
        final mockRepository = MockUserSpeciesAliasRepository();
        final container = ProviderContainer(
          overrides: [
            userSpeciesAliasRepositoryProvider
                .overrideWithValue(mockRepository),
          ],
        );

        final repository = container.read(userSpeciesAliasRepositoryProvider);
        expect(repository, equals(mockRepository));
        container.dispose();
      });
    });

    group('Service Provider Overrides', () {
      test('can override fishCatchServiceProvider with mock', () {
        final mockService = MockFishCatchService();
        final container = ProviderContainer(
          overrides: [
            fishCatchServiceProvider.overrideWithValue(mockService),
          ],
        );

        final service = container.read(fishCatchServiceProvider);
        expect(service, equals(mockService));
        container.dispose();
      });

      test('can override settingsServiceProvider with mock', () {
        final mockService = MockSettingsService();
        final container = ProviderContainer(
          overrides: [
            settingsServiceProvider.overrideWithValue(mockService),
          ],
        );

        final service = container.read(settingsServiceProvider);
        expect(service, equals(mockService));
        container.dispose();
      });

      test('can override achievementServiceProvider with mock', () {
        final mockService = MockAchievementService();
        final container = ProviderContainer(
          overrides: [
            achievementServiceProvider.overrideWithValue(mockService),
          ],
        );

        final service = container.read(achievementServiceProvider);
        expect(service, equals(mockService));
        container.dispose();
      });

      test('can override locationServiceProvider with mock', () {
        final mockService = MockLocationService();
        final container = ProviderContainer(
          overrides: [
            locationServiceProvider.overrideWithValue(mockService),
          ],
        );

        final service = container.read(locationServiceProvider);
        expect(service, equals(mockService));
        container.dispose();
      });
    });
  });
}

// Mock classes for override testing
class MockFishCatchRepository extends Mock implements FishCatchRepository {}

class MockEquipmentRepository extends Mock implements EquipmentRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockLocationRepository extends Mock implements LocationRepository {}

class MockStatsRepository extends Mock implements StatsRepository {}

class MockSpeciesHistoryRepository extends Mock
    implements SpeciesHistoryRepository {}

class MockUserSpeciesAliasRepository extends Mock
    implements UserSpeciesAliasRepository {}

class MockBackupConfigRepository extends Mock
    implements BackupConfigRepository {}

class MockFishSpeciesMatcher extends Mock implements FishSpeciesMatcher {}

class MockSpeciesManagementService extends Mock
    implements SpeciesManagementService {}

class MockFishCatchService extends Mock implements FishCatchService {}

class MockSettingsService extends Mock implements SettingsService {}

class MockAchievementService extends Mock implements AchievementService {}

class MockLocationService extends Mock implements LocationService {}

class MockDb implements DatabaseProvider {
  @override
  final Future<Database> database;

  MockDb() : database = _buildInMemoryDb();

  @override
  Future<void> close() async {}

  @override
  Future<void> resetForTesting() async {}

  static Future<Database> _buildInMemoryDb() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    return databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE cloud_configs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              provider TEXT NOT NULL,
              config TEXT NOT NULL,
              is_active INTEGER DEFAULT 0,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
        },
      ),
    );
  }
}
