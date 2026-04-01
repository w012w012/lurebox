import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/repositories/fish_catch_repository.dart';
import 'package:lurebox/core/repositories/equipment_repository.dart';
import 'package:lurebox/core/repositories/species_history_repository.dart';
import 'package:lurebox/core/repositories/location_repository.dart';
import 'package:lurebox/core/repositories/settings_repository.dart';
import 'package:lurebox/core/repositories/stats_repository.dart';

void setUpDatabaseForTesting() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

void tearDownDatabase() {}

// ===== Mock Database =====

class MockDatabase extends Mock implements Database {}

// Mock database service (for legacy tests)
class MockDatabaseService extends Mock {
  static Database? _mockDatabase;

  static Future<Database> get database async {
    return _mockDatabase ?? MockDatabase();
  }

  static void setMockDatabase(Database database) {
    _mockDatabase = database;
  }

  static void clearMocks() {
    _mockDatabase = null;
  }
}

// ===== Mock Repositories =====

class MockFishCatchRepository extends Mock implements FishCatchRepository {}

class MockEquipmentRepository extends Mock implements EquipmentRepository {}

class MockSpeciesHistoryRepository extends Mock
    implements SpeciesHistoryRepository {}

class MockLocationRepository extends Mock implements LocationRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockStatsRepository extends Mock implements StatsRepository {}

// ===== Fake Classes for Parameter Matching =====

class FakeFishCatch extends Fake implements FishCatch {}

class FakeEquipment extends Fake implements Equipment {}

class FakeSpeciesHistory extends Fake implements SpeciesHistory {}

class FakeLocationWithStats extends Fake implements LocationWithStats {}

class FakeCatchStats extends Fake implements CatchStats {}

// ===== Register Fallback Values =====

void registerFallbackValues() {
  registerFallbackValue(FakeFishCatch());
  registerFallbackValue(FakeEquipment());
  registerFallbackValue(FakeSpeciesHistory());
  registerFallbackValue(FakeLocationWithStats());
  registerFallbackValue(FakeCatchStats());
}

// ===== Test Data Factory =====

class TestDataFactory {
  static FishCatch createFishCatch({
    int id = 1,
    String species = 'Bass',
    double length = 30.0,
    double? weight,
    FishFateType fate = FishFateType.release,
    DateTime? catchTime,
    String? locationName,
    double? latitude,
    double? longitude,
  }) {
    return FishCatch(
      id: id,
      imagePath: '/test/fish_$id.jpg',
      species: species,
      length: length,
      weight: weight,
      fate: fate,
      catchTime: catchTime ?? DateTime.now(),
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static List<FishCatch> createFishCatches(
    int count, {
    String species = 'Bass',
  }) {
    return List.generate(
      count,
      (i) => createFishCatch(
        id: i + 1,
        species: i % 2 == 0 ? species : 'Trout',
        length: 20.0 + i * 2,
      ),
    );
  }

  static Equipment createEquipment({
    int id = 1,
    EquipmentType type = EquipmentType.rod,
    String brand = 'TestBrand',
    String model = 'TestModel',
  }) {
    return Equipment(
      id: id,
      type: type,
      brand: brand,
      model: model,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static SpeciesHistory createSpeciesHistory({
    int id = 1,
    String name = 'Bass',
    int useCount = 1,
    bool isDeleted = false,
  }) {
    return SpeciesHistory(
      id: id,
      name: name,
      useCount: useCount,
      isDeleted: isDeleted,
      createdAt: DateTime.now(),
    );
  }

  static LocationWithStats createLocationWithStats({
    String name = 'Test Location',
    double latitude = 35.0,
    double longitude = 139.0,
    int fishCount = 5,
  }) {
    return LocationWithStats(
      name: name,
      latitude: latitude,
      longitude: longitude,
      fishCount: fishCount,
      lastCatchTime: DateTime.now(),
    );
  }

  static CatchStats createCatchStats({
    int total = 10,
    int release = 7,
    int keep = 3,
  }) {
    return CatchStats(total: total, release: release, keep: keep);
  }
}
