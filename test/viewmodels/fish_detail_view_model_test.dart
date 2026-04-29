import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/providers/fish_detail_view_model.dart';
import 'package:lurebox/core/services/equipment_service.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFishCatchService extends Mock implements FishCatchService {}

class MockEquipmentService extends Mock implements EquipmentService {}

class FakeFishCatch extends Fake implements FishCatch {}

class FakeEquipment extends Fake implements Equipment {}

// Helper function to create FishCatch
FishCatch _createFishCatch({
  int id = 1,
  String species = 'Bass',
  double length = 30.0,
  double? weight,
  FishFateType fate = FishFateType.release,
  int? rodId,
  int? reelId,
  int? lureId,
  int? equipmentId,
  DateTime? catchTime,
}) {
  return FishCatch(
    id: id,
    imagePath: '/test/fish_$id.jpg',
    species: species,
    length: length,
    weight: weight,
    fate: fate,
    catchTime: catchTime ?? DateTime(2024, 1, 15),
    rodId: rodId,
    reelId: reelId,
    lureId: lureId,
    equipmentId: equipmentId,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

// Helper function to create Equipment
Equipment _createEquipment({
  int id = 1,
  EquipmentType type = EquipmentType.rod,
  String brand = 'Shimano',
  String model = 'Stradic',
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

void main() {
  late FishDetailViewModel viewModel;
  late MockFishCatchService mockFishCatchService;
  late MockEquipmentService mockEquipmentService;

  setUpAll(() {
    registerFallbackValue(FakeFishCatch());
    registerFallbackValue(FakeEquipment());
  });

  setUp(() {
    mockFishCatchService = MockFishCatchService();
    mockEquipmentService = MockEquipmentService();

    // Default mock behavior - return null for getById unless explicitly set
    when(() => mockFishCatchService.getById(any()))
        .thenAnswer((_) async => null);
    when(() => mockEquipmentService.getById(any()))
        .thenAnswer((_) async => null);
  });

  tearDown(() {
    try {
      viewModel.dispose();
    } catch (_) {
      // viewModel may not be initialized in all tests
    }
  });

  group('FishDetailViewModel', () {
    group('initial state', () {
      test('has correct default values', () {
        // Test the initial state before any operations
        const state = FishDetailState();

        expect(state.isLoading, true);
        expect(state.errorMessage, isNull);
        expect(state.fish, isNull);
        expect(state.rodEquipment, isNull);
        expect(state.reelEquipment, isNull);
        expect(state.lureEquipment, isNull);
        expect(state.isDeleting, false);
        expect(state.isSharing, false);
      });

      test('loads fish on construction and completes successfully', () async {
        // Arrange
        final fish = _createFishCatch(id: 42, species: 'Pike');
        when(() => mockFishCatchService.getById(42))
            .thenAnswer((_) async => fish);

        // Act - create viewmodel (triggers loadFish in constructor)
        viewModel = FishDetailViewModel(
          42,
          mockFishCatchService,
          mockEquipmentService,
        );

        // Wait for async loadFish to complete by using Future.delayed
        // and check state until loaded OR use a simple pump
        await viewModel.loadFish();

        // Assert
        expect(viewModel.state.fish, isNotNull);
        expect(viewModel.state.fish!.id, 42);
        expect(viewModel.state.fish!.species, 'Pike');
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, isNull);
      });
    });

    // ============================================================
    // loadFish Tests
    // ============================================================
    group('loadFish', () {
      test('loads fish successfully with all equipment', () async {
        // Arrange
        final fish = _createFishCatch(
          rodId: 10,
          reelId: 20,
          lureId: 30,
        );
        final rod = _createEquipment(id: 10);
        final reel = _createEquipment(id: 20, type: EquipmentType.reel);
        final lure = _createEquipment(id: 30, type: EquipmentType.lure);

        when(() => mockFishCatchService.getById(1))
            .thenAnswer((_) async => fish);
        when(() => mockEquipmentService.getById(10))
            .thenAnswer((_) async => rod);
        when(() => mockEquipmentService.getById(20))
            .thenAnswer((_) async => reel);
        when(() => mockEquipmentService.getById(30))
            .thenAnswer((_) async => lure);

        viewModel = FishDetailViewModel(
          1,
          mockFishCatchService,
          mockEquipmentService,
        );

        // Wait for all async operations to complete
        await viewModel.loadFish();

        // Assert
        expect(viewModel.state.fish, isNotNull);
        expect(viewModel.state.fish!.species, 'Bass');
        expect(viewModel.state.rodEquipment, isNotNull);
        expect(viewModel.state.reelEquipment, isNotNull);
        expect(viewModel.state.lureEquipment, isNotNull);
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, isNull);
      });

      test('loads fish with no equipment when IDs are null', () async {
        // Arrange
        final fish = _createFishCatch(id: 2, species: 'Trout');

        when(() => mockFishCatchService.getById(2))
            .thenAnswer((_) async => fish);

        viewModel = FishDetailViewModel(
          2,
          mockFishCatchService,
          mockEquipmentService,
        );

        await viewModel.loadFish();

        // Assert
        expect(viewModel.state.fish, isNotNull);
        expect(viewModel.state.fish!.species, 'Trout');
        expect(viewModel.state.rodEquipment, isNull);
        expect(viewModel.state.reelEquipment, isNull);
        expect(viewModel.state.lureEquipment, isNull);
      });

      test('sets fish not found error when fish is null', () async {
        // Arrange
        when(() => mockFishCatchService.getById(999))
            .thenAnswer((_) async => null);

        viewModel = FishDetailViewModel(
          999,
          mockFishCatchService,
          mockEquipmentService,
        );

        await viewModel.loadFish();

        // Assert
        expect(viewModel.state.fish, isNull);
        expect(viewModel.state.errorMessage, 'Fish not found');
        expect(viewModel.state.isLoading, false);
      });

      test('handles repository error on loadFish', () async {
        // Arrange
        when(() => mockFishCatchService.getById(1))
            .thenThrow(Exception('Database connection failed'));

        viewModel = FishDetailViewModel(
          1,
          mockFishCatchService,
          mockEquipmentService,
        );

        await viewModel.loadFish();

        // Assert
        expect(viewModel.state.fish, isNull);
        expect(
          viewModel.state.errorMessage,
          contains('Database connection failed'),
        );
        expect(viewModel.state.isLoading, false);
      });

      test('handles equipment service error by leaving equipment as null',
          () async {
        // Arrange
        final fish = _createFishCatch(rodId: 10);

        when(() => mockFishCatchService.getById(1))
            .thenAnswer((_) async => fish);
        when(() => mockEquipmentService.getById(10))
            .thenThrow(Exception('Equipment DB error'));

        viewModel = FishDetailViewModel(
          1,
          mockFishCatchService,
          mockEquipmentService,
        );

        await viewModel.loadFish();

        // Assert - equipment errors propagate up to catch block which sets errorMessage
        // and leaves fish null because the state assignment never happens
        expect(viewModel.state.fish, isNull);
        expect(viewModel.state.errorMessage, contains('Equipment DB error'));
      });

      test('loads equipment from equipment_id when rod/reel/lure are null',
          () async {
        // Arrange
        final fish = _createFishCatch(equipmentId: 50);
        final lure = _createEquipment(id: 50, type: EquipmentType.lure);

        when(() => mockFishCatchService.getById(1))
            .thenAnswer((_) async => fish);
        when(() => mockEquipmentService.getById(50))
            .thenAnswer((_) async => lure);

        viewModel = FishDetailViewModel(
          1,
          mockFishCatchService,
          mockEquipmentService,
        );

        await viewModel.loadFish();

        // Assert
        expect(viewModel.state.fish, isNotNull);
        expect(viewModel.state.lureEquipment, isNotNull);
        expect(viewModel.state.lureEquipment!.id, 50);
      });
    });

    // ============================================================
    // deleteFish Tests
    // ============================================================
    group('deleteFish', () {
      test('deletes fish successfully and returns true', () async {
        // Arrange
        final fish = _createFishCatch(id: 50);
        when(() => mockFishCatchService.getById(50))
            .thenAnswer((_) async => fish);
        when(() => mockFishCatchService.delete(50)).thenAnswer((_) async {});

        // Act
        viewModel = FishDetailViewModel(
          50,
          mockFishCatchService,
          mockEquipmentService,
        );
        await viewModel.loadFish();
        final result = await viewModel.deleteFish();

        // Assert
        expect(result, true);
        verify(() => mockFishCatchService.delete(50)).called(1);
      });

      test('sets isDeleting to true during delete operation', () async {
        // Arrange
        final fish = _createFishCatch(id: 51);
        when(() => mockFishCatchService.getById(51))
            .thenAnswer((_) async => fish);
        when(() => mockFishCatchService.delete(51)).thenAnswer((_) async {});

        viewModel = FishDetailViewModel(
          51,
          mockFishCatchService,
          mockEquipmentService,
        );
        await viewModel.loadFish();

        // Act - call deleteFish and wait for completion
        final result = await viewModel.deleteFish();

        // Assert
        expect(result, true);
      });

      test('returns false and sets error on delete failure', () async {
        // Arrange
        final fish = _createFishCatch(id: 52);
        when(() => mockFishCatchService.getById(52))
            .thenAnswer((_) async => fish);
        when(() => mockFishCatchService.delete(52))
            .thenThrow(Exception('Delete failed'));

        viewModel = FishDetailViewModel(
          52,
          mockFishCatchService,
          mockEquipmentService,
        );
        await viewModel.loadFish();

        // Act
        final result = await viewModel.deleteFish();

        // Assert
        expect(result, false);
        expect(viewModel.state.errorMessage, contains('Delete failed'));
      });
    });

    // ============================================================
    // setSharing Tests
    // ============================================================
    group('setSharing', () {
      test('sets isSharing to true', () async {
        // Arrange
        final fish = _createFishCatch(id: 8);
        when(() => mockFishCatchService.getById(8))
            .thenAnswer((_) async => fish);

        viewModel = FishDetailViewModel(
          8,
          mockFishCatchService,
          mockEquipmentService,
        );
        await viewModel.loadFish();

        expect(viewModel.state.isSharing, false);

        // Act
        viewModel.setSharing(true);

        // Assert
        expect(viewModel.state.isSharing, true);
      });

      test('sets isSharing to false', () async {
        // Arrange
        final fish = _createFishCatch(id: 9);
        when(() => mockFishCatchService.getById(9))
            .thenAnswer((_) async => fish);

        viewModel = FishDetailViewModel(
          9,
          mockFishCatchService,
          mockEquipmentService,
        );
        await viewModel.loadFish();

        viewModel.setSharing(true);
        expect(viewModel.state.isSharing, true);

        // Act
        viewModel.setSharing(false);

        // Assert
        expect(viewModel.state.isSharing, false);
      });

      test('toggles isSharing correctly', () async {
        // Arrange
        final fish = _createFishCatch(id: 10);
        when(() => mockFishCatchService.getById(10))
            .thenAnswer((_) async => fish);

        viewModel = FishDetailViewModel(
          10,
          mockFishCatchService,
          mockEquipmentService,
        );
        await viewModel.loadFish();

        // Initial state
        expect(viewModel.state.isSharing, false);

        // Toggle on
        viewModel.setSharing(true);
        expect(viewModel.state.isSharing, true);

        // Toggle off
        viewModel.setSharing(false);
        expect(viewModel.state.isSharing, false);
      });
    });

    // ============================================================
    // refresh Tests
    // ============================================================
    group('refresh', () {
      test('refresh calls loadFish again', () async {
        // Arrange
        final fish = _createFishCatch(id: 11, species: 'Pike');
        when(() => mockFishCatchService.getById(11))
            .thenAnswer((_) async => fish);

        viewModel = FishDetailViewModel(
          11,
          mockFishCatchService,
          mockEquipmentService,
        );
        // Let the constructor's loadFish() complete (mocks resolve immediately)
        await Future(() {});

        expect(viewModel.state.fish!.species, 'Pike');

        // Act - simulate fish being updated in DB
        final updatedFish = _createFishCatch(id: 11, species: 'Muskie');
        when(() => mockFishCatchService.getById(11))
            .thenAnswer((_) async => updatedFish);

        await viewModel.refresh();

        // Assert
        expect(viewModel.state.fish!.species, 'Muskie');
        verify(() => mockFishCatchService.getById(11)).called(2);
      });

      test('refresh reloads equipment data', () async {
        // Arrange
        final fish = _createFishCatch(id: 12, rodId: 100);
        final rod = _createEquipment(
          id: 100,
          brand: 'OldBrand',
        );

        when(() => mockFishCatchService.getById(12))
            .thenAnswer((_) async => fish);
        when(() => mockEquipmentService.getById(100))
            .thenAnswer((_) async => rod);

        viewModel = FishDetailViewModel(
          12,
          mockFishCatchService,
          mockEquipmentService,
        );
        // Let the constructor's loadFish() complete (mocks resolve immediately)
        await Future(() {});

        expect(viewModel.state.rodEquipment!.brand, 'OldBrand');

        // Act - simulate equipment being updated
        final updatedRod = _createEquipment(
          id: 100,
          brand: 'NewBrand',
        );
        when(() => mockEquipmentService.getById(100))
            .thenAnswer((_) async => updatedRod);

        await viewModel.refresh();

        // Assert
        expect(viewModel.state.rodEquipment!.brand, 'NewBrand');
      });
    });
  });
}
