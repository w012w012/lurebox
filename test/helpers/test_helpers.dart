import 'package:lurebox/core/database/database.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/fish_filter.dart';
import 'package:lurebox/core/models/fishing_location.dart';
import 'package:lurebox/core/repositories/equipment_repository.dart';
import 'package:lurebox/core/repositories/fish_catch_repository.dart';
import 'package:lurebox/core/repositories/location_repository.dart';
import 'package:lurebox/core/repositories/settings_repository.dart';
import 'package:lurebox/core/repositories/species_history_repository.dart';
import 'package:lurebox/core/repositories/stats_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Database;

void setUpDatabaseForTesting() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

void tearDownDatabase() {}

/// Mock Database implementing the Database interface for unit testing
class MockDatabase extends Mock implements Database {
  // Store query results for verification
  final Map<String, List<Map<String, dynamic>>> _queryResults = {};
  final List<Map<String, dynamic>> _insertedRecords = [];

  void addQueryResult(String sql, List<Map<String, dynamic>> results) {
    _queryResults[sql] = results;
  }

  List<Map<String, dynamic>> getInsertedRecords() =>
      List.from(_insertedRecords);

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    // Return stored result or empty list
    return _queryResults[table] ?? [];
  }

  @override
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    // Store the inserted record
    final record = Map<String, dynamic>.from(values);
    record['id'] = _insertedRecords.length + 1;
    _insertedRecords.add(record);
    return record['id'] as int;
  }

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return 1; // Mock: updated 1 row
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    return 1; // Mock: deleted 1 row
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    // Match exact SQL or return stored result
    return _queryResults[sql] ?? [];
  }

  @override
  Future<int> rawUpdate(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    return 1; // Mock: updated 1 row
  }

  @override
  Future<int> rawInsert(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    return 1; // Mock: inserted 1 row
  }

  @override
  Future<int> rawDelete(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    return 1; // Mock: deleted 1 row
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) async {
    return action(_MockTransaction());
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {}

  /// Clear all stored data
  void reset() {
    _queryResults.clear();
    _insertedRecords.clear();
  }
}

/// Mock Transaction for testing
class _MockTransaction implements Transaction {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return Future.value([]);
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

  static FishFilter createFishFilter({
    String timeFilter = 'all',
    FishFateType? fateFilter,
    String? speciesFilter,
    String sortBy = 'time',
    bool sortAsc = false,
    DateTime? customStartDate,
    DateTime? customEndDate,
    String? searchQuery,
  }) {
    return FishFilter(
      timeFilter: timeFilter,
      fateFilter: fateFilter,
      speciesFilter: speciesFilter,
      sortBy: sortBy,
      sortAsc: sortAsc,
      customStartDate: customStartDate,
      customEndDate: customEndDate,
      searchQuery: searchQuery,
    );
  }

  static FishingLocation createFishingLocation({
    int id = 1,
    String name = 'Test Location',
    double? latitude = 35.0,
    double? longitude = 139.0,
    DateTime? lastVisit,
    int fishCount = 5,
    DateTime? createdAt,
  }) {
    return FishingLocation(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      lastVisit: lastVisit,
      fishCount: fishCount,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  static AppSettings createAppSettings({
    UnitSettings? units,
    DarkMode darkMode = DarkMode.system,
    AppLanguage language = AppLanguage.chinese,
    bool hasCompletedOnboarding = false,
  }) {
    return AppSettings(
      units: units ?? const UnitSettings(),
      darkMode: darkMode,
      language: language,
      hasCompletedOnboarding: hasCompletedOnboarding,
    );
  }
}
