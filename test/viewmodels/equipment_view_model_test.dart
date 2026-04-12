import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/services/equipment_service.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';
import 'package:lurebox/core/providers/equipment_view_model.dart';

class MockEquipmentService extends Mock implements EquipmentService {}

class MockFishCatchService extends Mock implements FishCatchService {}

class FakeEquipment extends Fake implements Equipment {}

// Helper function to create Equipment
Equipment _createEquipment({
  int id = 1,
  EquipmentType type = EquipmentType.rod,
  String brand = 'TestBrand',
  String model = 'TestModel',
  bool isDefault = false,
}) {
  return Equipment(
    id: id,
    type: type,
    brand: brand,
    model: model,
    isDefault: isDefault,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );
}

void main() {
  late EquipmentListViewModel viewModel;
  late MockEquipmentService mockEquipmentService;
  late MockFishCatchService mockFishCatchService;

  setUpAll(() {
    registerFallbackValue(FakeEquipment());
    registerFallbackValue(<Equipment>[]);
    registerFallbackValue(<int, Map<String, int>>{});
  });

  setUp(() {
    mockEquipmentService = MockEquipmentService();
    mockFishCatchService = MockFishCatchService();

    // Default mock behavior - return empty lists and empty stats
    when(() => mockEquipmentService.getAll(type: any(named: 'type')))
        .thenAnswer((_) async => <Equipment>[]);
    when(() => mockFishCatchService.getAllEquipmentCatchStats())
        .thenAnswer((_) async => <int, Map<String, int>>{});

    viewModel = EquipmentListViewModel(
      mockEquipmentService,
      mockFishCatchService,
    );
  });

  group('EquipmentListViewModel', () {
    // ============================================================
    // Initial State Tests
    // ============================================================
    group('initial state', () {
      test('has correct default values after construction', () async {
        // Wait for initial loadData() to complete
        await Future.delayed(Duration.zero);

        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, isNull);
        expect(viewModel.state.rodList, isEmpty);
        expect(viewModel.state.reelList, isEmpty);
        expect(viewModel.state.lureList, isEmpty);
        expect(viewModel.state.equipmentStats, isEmpty);
        expect(viewModel.state.selectedType, 'rod');
        expect(viewModel.state.allExpanded, true);
        expect(viewModel.state.expandedId, isNull);
      });

      test('initial state has isLoading true before data loads', () {
        // Create a new viewModel and immediately check state before any await
        final newViewModel = EquipmentListViewModel(
          mockEquipmentService,
          mockFishCatchService,
        );

        // The constructor calls loadData() synchronously which sets isLoading = true
        // but since it's async, the initial state shows isLoading = true
        expect(newViewModel.state.isLoading, true);
      });
    });

    // ============================================================
    // loadData Tests
    // ============================================================
    group('loadData', () {
      test('loads data successfully with equipment lists', () async {
        // Arrange
        final rods = [
          _createEquipment(id: 1, type: EquipmentType.rod, brand: 'Shimano'),
          _createEquipment(id: 2, type: EquipmentType.rod, brand: 'Abu Garcia'),
        ];
        final reels = [
          _createEquipment(id: 3, type: EquipmentType.reel, brand: 'Shimano'),
        ];
        final lures = [
          _createEquipment(id: 4, type: EquipmentType.lure, brand: 'Rapala'),
          _createEquipment(id: 5, type: EquipmentType.lure, brand: 'Mepps'),
          _createEquipment(id: 6, type: EquipmentType.lure, brand: 'Booyah'),
        ];
        final stats = <int, Map<String, int>>{
          1: {'_total': 5, 'Bass': 3, 'Trout': 2},
          3: {'_total': 3, 'Bass': 3},
        };

        when(() => mockEquipmentService.getAll(type: 'rod'))
            .thenAnswer((_) async => rods);
        when(() => mockEquipmentService.getAll(type: 'reel'))
            .thenAnswer((_) async => reels);
        when(() => mockEquipmentService.getAll(type: 'lure'))
            .thenAnswer((_) async => lures);
        when(() => mockFishCatchService.getAllEquipmentCatchStats())
            .thenAnswer((_) async => stats);

        // Act
        await viewModel.loadData();

        // Assert
        expect(viewModel.state.rodList, equals(rods));
        expect(viewModel.state.reelList, equals(reels));
        expect(viewModel.state.lureList, equals(lures));
        expect(viewModel.state.equipmentStats, equals(stats));
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, isNull);
      });

      test('loads data successfully with empty lists', () async {
        // Arrange - all services return empty
        when(() => mockEquipmentService.getAll(type: 'rod'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'reel'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'lure'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockFishCatchService.getAllEquipmentCatchStats())
            .thenAnswer((_) async => <int, Map<String, int>>{});

        // Act
        await viewModel.loadData();

        // Assert
        expect(viewModel.state.rodList, isEmpty);
        expect(viewModel.state.reelList, isEmpty);
        expect(viewModel.state.lureList, isEmpty);
        expect(viewModel.state.equipmentStats, isEmpty);
        expect(viewModel.state.isLoading, false);
      });

      test('sets errorMessage when getAll for rod fails', () async {
        // Arrange
        when(() => mockEquipmentService.getAll(type: 'rod'))
            .thenThrow(Exception('Database error: rod table not found'));
        when(() => mockEquipmentService.getAll(type: 'reel'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'lure'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockFishCatchService.getAllEquipmentCatchStats())
            .thenAnswer((_) async => <int, Map<String, int>>{});

        // Act
        await viewModel.loadData();

        // Assert
        expect(viewModel.state.errorMessage,
            contains('Database error: rod table not found'));
        expect(viewModel.state.isLoading, false);
      });

      test('sets errorMessage when getAll for reel fails', () async {
        // Arrange
        when(() => mockEquipmentService.getAll(type: 'rod'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'reel'))
            .thenThrow(Exception('Reel query failed'));
        when(() => mockEquipmentService.getAll(type: 'lure'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockFishCatchService.getAllEquipmentCatchStats())
            .thenAnswer((_) async => <int, Map<String, int>>{});

        // Act
        await viewModel.loadData();

        // Assert
        expect(viewModel.state.errorMessage, contains('Reel query failed'));
        expect(viewModel.state.isLoading, false);
      });

      test('sets errorMessage when getAll for lure fails', () async {
        // Arrange
        when(() => mockEquipmentService.getAll(type: 'rod'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'reel'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'lure'))
            .thenThrow(Exception('Lure query failed'));
        when(() => mockFishCatchService.getAllEquipmentCatchStats())
            .thenAnswer((_) async => <int, Map<String, int>>{});

        // Act
        await viewModel.loadData();

        // Assert
        expect(viewModel.state.errorMessage, contains('Lure query failed'));
        expect(viewModel.state.isLoading, false);
      });

      test('sets errorMessage when getAllEquipmentCatchStats fails', () async {
        // Arrange
        when(() => mockEquipmentService.getAll(type: 'rod'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'reel'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'lure'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockFishCatchService.getAllEquipmentCatchStats())
            .thenThrow(Exception('Stats query failed'));

        // Act
        await viewModel.loadData();

        // Assert
        expect(viewModel.state.errorMessage, contains('Stats query failed'));
        expect(viewModel.state.isLoading, false);
      });
    });

    // ============================================================
    // setSelectedType Tests
    // ============================================================
    group('setSelectedType', () {
      test('sets selectedType to "rod"', () async {
        // Wait for initial load
        await Future.delayed(Duration.zero);

        viewModel.setSelectedType('rod');

        expect(viewModel.state.selectedType, 'rod');
      });

      test('sets selectedType to "reel"', () async {
        // Wait for initial load
        await Future.delayed(Duration.zero);

        viewModel.setSelectedType('reel');

        expect(viewModel.state.selectedType, 'reel');
      });

      test('sets selectedType to "lure"', () async {
        // Wait for initial load
        await Future.delayed(Duration.zero);

        viewModel.setSelectedType('lure');

        expect(viewModel.state.selectedType, 'lure');
      });

      test('does not change other state properties when setting selectedType',
          () async {
        // Arrange
        final rods = [_createEquipment(id: 1, brand: 'Shimano')];
        final stats = <int, Map<String, int>>{
          1: {'_total': 5}
        };

        when(() => mockEquipmentService.getAll(type: 'rod'))
            .thenAnswer((_) async => rods);
        when(() => mockEquipmentService.getAll(type: 'reel'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'lure'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockFishCatchService.getAllEquipmentCatchStats())
            .thenAnswer((_) async => stats);

        await viewModel.loadData();

        // Act
        viewModel.setSelectedType('reel');

        // Assert - other properties unchanged
        expect(viewModel.state.rodList, equals(rods));
        expect(viewModel.state.equipmentStats, equals(stats));
        expect(viewModel.state.allExpanded, true);
      });
    });

    // ============================================================
    // toggleExpanded Tests
    // ============================================================
    group('toggleExpanded', () {
      test('sets expandedId when different from current', () async {
        await Future.delayed(Duration.zero);

        viewModel.toggleExpanded(5);

        expect(viewModel.state.expandedId, 5);
      });

      test('clears expandedId when same id is toggled', () async {
        await Future.delayed(Duration.zero);

        // First toggle sets expandedId
        viewModel.toggleExpanded(5);
        expect(viewModel.state.expandedId, 5);

        // Second toggle clears it
        viewModel.toggleExpanded(5);
        expect(viewModel.state.expandedId, isNull);
      });

      test('changes expandedId to different id', () async {
        await Future.delayed(Duration.zero);

        // First toggle sets to 5
        viewModel.toggleExpanded(5);
        expect(viewModel.state.expandedId, 5);

        // Toggle different id replaces
        viewModel.toggleExpanded(10);
        expect(viewModel.state.expandedId, 10);
      });

      test('does not affect other state properties', () async {
        await Future.delayed(Duration.zero);

        final originalState = viewModel.state;

        viewModel.toggleExpanded(3);

        expect(viewModel.state.isLoading, originalState.isLoading);
        expect(viewModel.state.errorMessage, originalState.errorMessage);
        expect(viewModel.state.rodList, originalState.rodList);
        expect(viewModel.state.selectedType, originalState.selectedType);
        expect(viewModel.state.allExpanded, originalState.allExpanded);
      });
    });

    // ============================================================
    // setAllExpanded Tests
    // ============================================================
    group('setAllExpanded', () {
      test('sets allExpanded to false', () async {
        await Future.delayed(Duration.zero);

        expect(viewModel.state.allExpanded, true);

        viewModel.setAllExpanded(false);

        expect(viewModel.state.allExpanded, false);
      });

      test('sets allExpanded to true', () async {
        await Future.delayed(Duration.zero);

        viewModel.setAllExpanded(false);
        expect(viewModel.state.allExpanded, false);

        viewModel.setAllExpanded(true);

        expect(viewModel.state.allExpanded, true);
      });
    });

    // ============================================================
    // deleteEquipment Tests
    // ============================================================
    group('deleteEquipment', () {
      test('deletes equipment successfully and reloads data', () async {
        // Arrange
        // Clear interactions from setUp's loadData() call
        clearInteractions(mockEquipmentService);
        when(() => mockEquipmentService.delete(1)).thenAnswer((_) async {});
        when(() => mockEquipmentService.getAll(type: 'rod'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'reel'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'lure'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockFishCatchService.getAllEquipmentCatchStats())
            .thenAnswer((_) async => <int, Map<String, int>>{});

        // Act
        await viewModel.deleteEquipment(1);

        // Assert
        verify(() => mockEquipmentService.delete(1)).called(1);
        // Should have called loadData after delete
        verify(() => mockEquipmentService.getAll(type: 'rod')).called(1);
      });

      test('sets errorMessage when delete fails', () async {
        // Arrange
        when(() => mockEquipmentService.delete(1))
            .thenThrow(Exception('Delete failed: foreign key constraint'));
        when(() => mockEquipmentService.getAll(type: 'rod'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'reel'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'lure'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockFishCatchService.getAllEquipmentCatchStats())
            .thenAnswer((_) async => <int, Map<String, int>>{});

        // Act
        await viewModel.deleteEquipment(1);

        // Assert
        expect(
          viewModel.state.errorMessage,
          contains('Delete failed: foreign key constraint'),
        );
      });

      test('does not reload data when delete throws', () async {
        // Arrange
        when(() => mockEquipmentService.delete(999))
            .thenThrow(Exception('Not found'));
        // Clear interactions from setUp's loadData() call
        clearInteractions(mockEquipmentService);
        // These should NOT be called if delete fails
        when(() => mockEquipmentService.getAll(type: 'rod'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'reel'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'lure'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockFishCatchService.getAllEquipmentCatchStats())
            .thenAnswer((_) async => <int, Map<String, int>>{});

        // Act
        await viewModel.deleteEquipment(999);

        // Assert - the loadData call happens AFTER successful delete, so it should not be called
        // (But verify that the mocks were set up for potential reload in case delete had succeeded)
        verifyNever(() => mockEquipmentService.getAll(type: 'rod'));
      });
    });

    // ============================================================
    // setDefaultEquipment Tests
    // ============================================================
    group('setDefaultEquipment', () {
      test('sets default equipment successfully and reloads data', () async {
        // Arrange
        // Clear interactions from setUp's loadData() call
        clearInteractions(mockEquipmentService);
        when(() => mockEquipmentService.setDefaultEquipment(1, 'rod'))
            .thenAnswer((_) async {});
        when(() => mockEquipmentService.getAll(type: 'rod'))
            .thenAnswer((_) async => [
                  _createEquipment(id: 1, isDefault: true),
                ]);
        when(() => mockEquipmentService.getAll(type: 'reel'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'lure'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockFishCatchService.getAllEquipmentCatchStats())
            .thenAnswer((_) async => <int, Map<String, int>>{});

        // Act
        await viewModel.setDefaultEquipment(1, 'rod');

        // Assert
        verify(() => mockEquipmentService.setDefaultEquipment(1, 'rod'))
            .called(1);
        // Should have called loadData after setting default
        verify(() => mockEquipmentService.getAll(type: 'rod')).called(1);
      });

      test('sets errorMessage when setDefaultEquipment fails', () async {
        // Arrange
        when(() => mockEquipmentService.setDefaultEquipment(1, 'rod'))
            .thenThrow(Exception('Update failed: invalid equipment id'));
        when(() => mockEquipmentService.getAll(type: 'rod'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'reel'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'lure'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockFishCatchService.getAllEquipmentCatchStats())
            .thenAnswer((_) async => <int, Map<String, int>>{});

        // Act
        await viewModel.setDefaultEquipment(1, 'rod');

        // Assert
        expect(
          viewModel.state.errorMessage,
          contains('Update failed: invalid equipment id'),
        );
      });

      test('does not reload data when setDefaultEquipment throws', () async {
        // Arrange
        when(() => mockEquipmentService.setDefaultEquipment(999, 'rod'))
            .thenThrow(Exception('Equipment not found'));
        // Clear interactions from setUp's loadData() call
        clearInteractions(mockEquipmentService);
        // These should NOT be called if setDefaultEquipment fails
        when(() => mockEquipmentService.getAll(type: 'rod'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'reel'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'lure'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockFishCatchService.getAllEquipmentCatchStats())
            .thenAnswer((_) async => <int, Map<String, int>>{});

        // Act
        await viewModel.setDefaultEquipment(999, 'rod');

        // Assert - loadData should not be called after failed setDefaultEquipment
        verifyNever(() => mockEquipmentService.getAll(type: 'rod'));
      });

      test('setDefaultEquipment works for different equipment types', () async {
        // Arrange - reel
        when(() => mockEquipmentService.setDefaultEquipment(2, 'reel'))
            .thenAnswer((_) async {});
        when(() => mockEquipmentService.getAll(type: 'rod'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'reel'))
            .thenAnswer((_) async => [
                  _createEquipment(
                      id: 2, type: EquipmentType.reel, isDefault: true),
                ]);
        when(() => mockEquipmentService.getAll(type: 'lure'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockFishCatchService.getAllEquipmentCatchStats())
            .thenAnswer((_) async => <int, Map<String, int>>{});

        // Act
        await viewModel.setDefaultEquipment(2, 'reel');

        // Assert
        verify(() => mockEquipmentService.setDefaultEquipment(2, 'reel'))
            .called(1);
      });
    });

    // ============================================================
    // refresh Tests
    // ============================================================
    group('refresh', () {
      test('refresh calls loadData', () async {
        // Arrange
        // Clear interactions from setUp's loadData() call
        clearInteractions(mockEquipmentService);
        when(() => mockEquipmentService.getAll(type: 'rod'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'reel'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'lure'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockFishCatchService.getAllEquipmentCatchStats())
            .thenAnswer((_) async => <int, Map<String, int>>{});

        // Act
        await viewModel.refresh();

        // Assert
        verify(() => mockEquipmentService.getAll(type: 'rod')).called(1);
        verify(() => mockEquipmentService.getAll(type: 'reel')).called(1);
        verify(() => mockEquipmentService.getAll(type: 'lure')).called(1);
      });
    });

    // ============================================================
    // currentList getter Tests
    // ============================================================
    group('currentList getter', () {
      test('returns rodList when selectedType is rod', () async {
        // Arrange
        final rods = [
          _createEquipment(id: 1, type: EquipmentType.rod),
          _createEquipment(id: 2, type: EquipmentType.rod),
        ];
        when(() => mockEquipmentService.getAll(type: 'rod'))
            .thenAnswer((_) async => rods);
        when(() => mockEquipmentService.getAll(type: 'reel'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'lure'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockFishCatchService.getAllEquipmentCatchStats())
            .thenAnswer((_) async => <int, Map<String, int>>{});

        await viewModel.loadData();

        // Act & Assert
        expect(viewModel.state.currentList, equals(rods));
      });

      test('returns reelList when selectedType is reel', () async {
        // Arrange
        final reels = [
          _createEquipment(id: 1, type: EquipmentType.reel),
        ];
        when(() => mockEquipmentService.getAll(type: 'rod'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'reel'))
            .thenAnswer((_) async => reels);
        when(() => mockEquipmentService.getAll(type: 'lure'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockFishCatchService.getAllEquipmentCatchStats())
            .thenAnswer((_) async => <int, Map<String, int>>{});

        await viewModel.loadData();
        viewModel.setSelectedType('reel');

        // Act & Assert
        expect(viewModel.state.currentList, equals(reels));
      });

      test('returns lureList when selectedType is lure', () async {
        // Arrange
        final lures = [
          _createEquipment(id: 1, type: EquipmentType.lure),
          _createEquipment(id: 2, type: EquipmentType.lure),
          _createEquipment(id: 3, type: EquipmentType.lure),
        ];
        when(() => mockEquipmentService.getAll(type: 'rod'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'reel'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'lure'))
            .thenAnswer((_) async => lures);
        when(() => mockFishCatchService.getAllEquipmentCatchStats())
            .thenAnswer((_) async => <int, Map<String, int>>{});

        await viewModel.loadData();
        viewModel.setSelectedType('lure');

        // Act & Assert
        expect(viewModel.state.currentList, equals(lures));
      });

      test('returns empty list for unknown selectedType', () async {
        // Arrange
        when(() => mockEquipmentService.getAll(type: 'rod'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'reel'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockEquipmentService.getAll(type: 'lure'))
            .thenAnswer((_) async => <Equipment>[]);
        when(() => mockFishCatchService.getAllEquipmentCatchStats())
            .thenAnswer((_) async => <int, Map<String, int>>{});

        await viewModel.loadData();
        viewModel.setSelectedType('unknown');

        // Act & Assert
        expect(viewModel.state.currentList, isEmpty);
      });
    });
  });
}
