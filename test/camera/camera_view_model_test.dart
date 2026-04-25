import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/camera/camera_state.dart';
import 'package:lurebox/core/camera/camera_view_model.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/services/equipment_service.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';

// ── Mocks ────────────────────────────────────────────────────────────────────

class MockFishCatchService extends Mock implements FishCatchService {}

class MockEquipmentService extends Mock implements EquipmentService {}

class FakeFishCatch extends Fake implements FishCatch {}

// ── Helpers ──────────────────────────────────────────────────────────────────

final _now = DateTime(2025, 6, 15, 10, 30);

Equipment _rod({int id = 1, bool isDefault = false}) => Equipment(
      id: id,
      type: EquipmentType.rod,
      brand: 'Shimano',
      model: 'Expride',
      isDefault: isDefault,
      createdAt: _now,
      updatedAt: _now,
    );

Equipment _reel({int id = 2, bool isDefault = false}) => Equipment(
      id: id,
      type: EquipmentType.reel,
      brand: 'Daiwa',
      model: 'Exist',
      isDefault: isDefault,
      createdAt: _now,
      updatedAt: _now,
    );

Equipment _lure({int id = 3, bool isDefault = false}) => Equipment(
      id: id,
      type: EquipmentType.lure,
      brand: 'Megabass',
      model: 'Vision 110',
      isDefault: isDefault,
      createdAt: _now,
      updatedAt: _now,
    );

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late CameraViewModel viewModel;
  late MockFishCatchService mockFishCatchService;
  late MockEquipmentService mockEquipmentService;
  const strings = AppStrings.chinese;

  setUpAll(() {
    registerFallbackValue(FakeFishCatch());
  });

  setUp(() {
    mockFishCatchService = MockFishCatchService();
    mockEquipmentService = MockEquipmentService();
    viewModel = CameraViewModel(
      mockFishCatchService,
      mockEquipmentService,
      strings,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  // ===========================================================================
  // 1. Initial state
  // ===========================================================================
  group('initial state', () {
    test('state starts as const CameraState() defaults', () {
      final s = viewModel.state;

      expect(s.isLoading, false);
      expect(s.isCameraInitialized, false);
      expect(s.captureState, CameraCaptureState.initial);
      expect(s.species, '');
      expect(s.length, 0);
      expect(s.weight, isNull);
      expect(s.fate, FishFateType.release);
      expect(s.locationName, isNull);
      expect(s.imagePath, isNull);
      expect(s.watermarkedImagePath, isNull);
      expect(s.selectedRod, isNull);
      expect(s.selectedReel, isNull);
      expect(s.selectedLure, isNull);
      expect(s.isTakingPicture, false);
      expect(s.canSwitchCamera, false);
      expect(s.errorMessage, isNull);
      expect(s.pendingRecognition, false);
    });
  });

  // ===========================================================================
  // 2. Species management
  // ===========================================================================
  group('species management', () {
    test('setSpecies updates state.species', () {
      viewModel.setSpecies('Bass');
      expect(viewModel.state.species, 'Bass');
    });

    test('setSpecies with empty string clears pendingRecognition', () {
      viewModel.setPendingRecognition(true);
      expect(viewModel.state.pendingRecognition, true);

      viewModel.setSpecies('');
      expect(viewModel.state.species, '');
      // When species is empty, pendingRecognition is kept
      expect(viewModel.state.pendingRecognition, true);
    });

    test('setSpecies with non-empty string clears pendingRecognition', () {
      viewModel.setPendingRecognition(true);
      expect(viewModel.state.pendingRecognition, true);

      viewModel.setSpecies('Trout');
      expect(viewModel.state.pendingRecognition, false);
    });

    test('setLength updates state.length', () {
      viewModel.setLength(42.5);
      expect(viewModel.state.length, 42.5);
    });

    test('setLength also computes estimatedWeight', () {
      viewModel.setLength(30);
      expect(viewModel.state.estimatedWeight, isNotNull);
      expect(viewModel.state.estimatedWeight!, greaterThan(0));
    });

    test('setLength with 0 does not set estimatedWeight', () {
      viewModel.setLength(0);
      expect(viewModel.state.estimatedWeight, isNull);
    });

    test('setWeight updates state.weight', () {
      viewModel.setWeight(2.5);
      expect(viewModel.state.weight, 2.5);
    });

    test('setWeight with null preserves existing weight (copyWith uses ??)', () {
      viewModel.setWeight(2.5);
      viewModel.setWeight(null);
      // copyWith uses `weight ?? this.weight`, so null keeps existing value
      expect(viewModel.state.weight, 2.5);
    });

    test('setFate updates state.fate', () {
      viewModel.setFate(FishFateType.keep);
      expect(viewModel.state.fate, FishFateType.keep);

      viewModel.setFate(FishFateType.release);
      expect(viewModel.state.fate, FishFateType.release);
    });

    test('setLocationName updates state.locationName', () {
      viewModel.setLocationName('Lake Tahoe');
      expect(viewModel.state.locationName, 'Lake Tahoe');
    });
  });

  // ===========================================================================
  // 3. Equipment selection
  // ===========================================================================
  group('equipment selection', () {
    test('setSelectedRod updates state.selectedRod', () {
      final rod = _rod();
      viewModel.setSelectedRod(rod);
      expect(viewModel.state.selectedRod, rod);
    });

    test('setSelectedRod with null clears selection', () {
      viewModel.setSelectedRod(_rod());
      viewModel.setSelectedRod(null);
      expect(viewModel.state.selectedRod, isNull);
    });

    test('setSelectedReel updates state.selectedReel', () {
      final reel = _reel();
      viewModel.setSelectedReel(reel);
      expect(viewModel.state.selectedReel, reel);
    });

    test('setSelectedReel with null clears selection', () {
      viewModel.setSelectedReel(_reel());
      viewModel.setSelectedReel(null);
      expect(viewModel.state.selectedReel, isNull);
    });

    test('setSelectedLure updates state.selectedLure', () {
      final lure = _lure();
      viewModel.setSelectedLure(lure);
      expect(viewModel.state.selectedLure, lure);
    });

    test('setSelectedLure with null clears selection', () {
      viewModel.setSelectedLure(_lure());
      viewModel.setSelectedLure(null);
      expect(viewModel.state.selectedLure, isNull);
    });
  });

  // ===========================================================================
  // 4. Form state
  // ===========================================================================
  group('form state', () {
    test('setImagePath updates state.imagePath and captureState', () {
      viewModel.setImagePath('/photos/test.jpg');

      expect(viewModel.state.imagePath, '/photos/test.jpg');
      expect(viewModel.state.captureState, CameraCaptureState.pictureTaken);
      expect(viewModel.state.catchTime, isNotNull);
    });

    test('setCatchTime updates state.catchTime', () {
      final time = DateTime(2025, 1, 1);
      viewModel.setCatchTime(time);
      expect(viewModel.state.catchTime, time);
    });

    test('setPendingRecognition updates state.pendingRecognition', () {
      viewModel.setPendingRecognition(true);
      expect(viewModel.state.pendingRecognition, true);

      viewModel.setPendingRecognition(false);
      expect(viewModel.state.pendingRecognition, false);
    });

    test('setLengthUnit updates state.lengthUnit', () {
      viewModel.setLengthUnit('inch');
      expect(viewModel.state.lengthUnit, 'inch');
    });

    test('setWeightUnit updates state.weightUnit', () {
      viewModel.setWeightUnit('lb');
      expect(viewModel.state.weightUnit, 'lb');
    });

    test('reset() resets all fields to CameraState defaults', () {
      // Mutate several fields
      viewModel.setSpecies('Bass');
      viewModel.setLength(30);
      viewModel.setWeight(5.0);
      viewModel.setFate(FishFateType.keep);
      viewModel.setLocationName('River');
      viewModel.setImagePath('/path/img.jpg');
      viewModel.setSelectedRod(_rod());
      viewModel.setSelectedReel(_reel());
      viewModel.setSelectedLure(_lure());

      // Verify fields were mutated
      expect(viewModel.state.species, 'Bass');
      expect(viewModel.state.length, 30);
      expect(viewModel.state.imagePath, '/path/img.jpg');

      // Reset
      viewModel.reset();

      final s = viewModel.state;
      expect(s, const CameraState());
      expect(s.species, '');
      expect(s.length, 0);
      expect(s.weight, isNull);
      expect(s.fate, FishFateType.release);
      expect(s.locationName, isNull);
      expect(s.imagePath, isNull);
      expect(s.selectedRod, isNull);
      expect(s.selectedReel, isNull);
      expect(s.selectedLure, isNull);
      expect(s.captureState, CameraCaptureState.initial);
    });

    test('setWatermarkedPath updates state.watermarkedImagePath', () {
      viewModel.setWatermarkedPath('/watermarked/img.jpg');
      expect(viewModel.state.watermarkedImagePath, '/watermarked/img.jpg');
    });

    test('clearImage resets imagePath, watermarkedImagePath, and captureState',
        () {
      viewModel.setImagePath('/img.jpg');
      viewModel.setWatermarkedPath('/wm.jpg');

      viewModel.clearImage();

      expect(viewModel.state.imagePath, isNull);
      expect(viewModel.state.watermarkedImagePath, isNull);
      expect(viewModel.state.captureState, CameraCaptureState.cameraReady);
    });
  });

  // ===========================================================================
  // 5. canSave logic
  // ===========================================================================
  group('canSave', () {
    test('returns false when no imagePath', () {
      viewModel.setSpecies('Bass');
      viewModel.setLength(30);
      expect(viewModel.state.canSave, false);
    });

    test('returns false when length is 0', () {
      viewModel.setImagePath('/img.jpg');
      viewModel.setSpecies('Bass');
      expect(viewModel.state.canSave, false);
    });

    test('returns false when species is empty and no pendingRecognition', () {
      viewModel.setImagePath('/img.jpg');
      viewModel.setLength(30);
      expect(viewModel.state.canSave, false);
    });

    test('returns true when imagePath, length > 0, and species set', () {
      viewModel.setImagePath('/img.jpg');
      viewModel.setLength(30);
      viewModel.setSpecies('Bass');
      expect(viewModel.state.canSave, true);
    });

    test('returns true with pendingRecognition even without species', () {
      viewModel.setImagePath('/img.jpg');
      viewModel.setLength(30);
      viewModel.setPendingRecognition(true);
      expect(viewModel.state.canSave, true);
    });
  });

  // ===========================================================================
  // 6. setLocation
  // ===========================================================================
  group('setLocation', () {
    test('updates locationName, latitude, longitude, and weather fields', () {
      viewModel.setLocation('Beach', 35.0, 139.0, 25.0, 1013.0, 1);

      final s = viewModel.state;
      expect(s.locationName, 'Beach');
      expect(s.latitude, 35.0);
      expect(s.longitude, 139.0);
      expect(s.airTemperature, 25.0);
      expect(s.pressure, 1013.0);
      expect(s.weatherCode, 1);
    });
  });

  // ===========================================================================
  // 7. Weather fields
  // ===========================================================================
  group('weather fields', () {
    test('setAirTemperature updates state.airTemperature', () {
      viewModel.setAirTemperature(22.5);
      expect(viewModel.state.airTemperature, 22.5);
    });

    test('setPressure updates state.pressure', () {
      viewModel.setPressure(1015.0);
      expect(viewModel.state.pressure, 1015.0);
    });

    test('setWeatherCode updates state.weatherCode', () {
      viewModel.setWeatherCode(3);
      expect(viewModel.state.weatherCode, 3);
    });

    test('setWeatherCode with null clears weatherCode', () {
      viewModel.setWeatherCode(3);
      viewModel.setWeatherCode(null);
      expect(viewModel.state.weatherCode, isNull);
    });
  });

  // ===========================================================================
  // 8. resetCaptureStateToForm
  // ===========================================================================
  group('resetCaptureStateToForm', () {
    test('resets to pictureTaken when imagePath is set', () {
      viewModel.setImagePath('/img.jpg');
      // Simulate error state
      viewModel.state = viewModel.state.copyWith(
        captureState: CameraCaptureState.error,
        isLoading: true,
        errorMessage: () => 'fail',
      );

      viewModel.resetCaptureStateToForm();

      expect(viewModel.state.captureState, CameraCaptureState.pictureTaken);
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.errorMessage, isNull);
    });

    test('does nothing when imagePath is null', () {
      // State without imagePath
      expect(viewModel.state.imagePath, isNull);

      viewModel.state = viewModel.state.copyWith(
        captureState: CameraCaptureState.error,
        isLoading: true,
        errorMessage: () => 'fail',
      );

      viewModel.resetCaptureStateToForm();

      // State unchanged
      expect(viewModel.state.captureState, CameraCaptureState.error);
      expect(viewModel.state.isLoading, true);
    });
  });

  // ===========================================================================
  // 9. Save flow (mocked services)
  // ===========================================================================
  group('saveFishCatch', () {
    test('returns null when canSave is false (missing imagePath)', () async {
      viewModel.setSpecies('Bass');
      viewModel.setLength(30);
      // No imagePath → canSave == false

      final result = await viewModel.saveFishCatch();

      expect(result, isNull);
      // State should remain unchanged (no saving started)
      expect(viewModel.state.captureState, CameraCaptureState.initial);
      verifyNever(() => mockFishCatchService.create(any()));
    });

    test('returns null when canSave is false (no length)', () async {
      viewModel.setImagePath('/img.jpg');
      viewModel.setSpecies('Bass');
      // length == 0 → canSave == false

      final result = await viewModel.saveFishCatch();
      expect(result, isNull);
      verifyNever(() => mockFishCatchService.create(any()));
    });

    test('returns null when canSave is false (no species or pending)', () async {
      viewModel.setImagePath('/img.jpg');
      viewModel.setLength(30);
      // species == '' and pendingRecognition == false → canSave == false

      final result = await viewModel.saveFishCatch();
      expect(result, isNull);
      verifyNever(() => mockFishCatchService.create(any()));
    });

    test('creates fish catch and returns id on success', () async {
      // Arrange: set up valid state
      viewModel.setImagePath('/photos/test.jpg');
      viewModel.setSpecies('Bass');
      viewModel.setLength(30);
      viewModel.setWeight(2.5);
      viewModel.setFate(FishFateType.release);
      viewModel.setLocationName('Lake');
      viewModel.setSelectedRod(_rod(id: 10));
      viewModel.setSelectedReel(_reel(id: 20));
      viewModel.setSelectedLure(_lure(id: 30));

      when(() => mockFishCatchService.create(any())).thenAnswer((_) async => 42);
      when(() => mockFishCatchService.updateSpeciesHistory(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await viewModel.saveFishCatch();

      // Assert
      expect(result, 42);
      expect(viewModel.state.captureState, CameraCaptureState.saved);
      expect(viewModel.state.isLoading, false);

      // Verify the service was called with correct data
      final captured = verify(
        () => mockFishCatchService.create(captureAny()),
      ).captured;
      expect(captured.length, 1);
      final fish = captured.first as FishCatch;
      expect(fish.species, 'Bass');
      expect(fish.length, 30);
      expect(fish.weight, 2.5);
      expect(fish.fate, FishFateType.release);
      expect(fish.imagePath, '/photos/test.jpg');
      expect(fish.locationName, 'Lake');
      expect(fish.rodId, 10);
      expect(fish.reelId, 20);
      expect(fish.lureId, 30);
      expect(fish.pendingRecognition, false);

      verify(() => mockFishCatchService.updateSpeciesHistory('Bass')).called(1);
    });

    test('uses pendingRecognition string when species is empty', () async {
      viewModel.setImagePath('/photos/test.jpg');
      viewModel.setLength(30);
      viewModel.setPendingRecognition(true);
      // species is '' but pendingRecognition is true → canSave == true

      when(() => mockFishCatchService.create(any())).thenAnswer((_) async => 1);
      when(() => mockFishCatchService.updateSpeciesHistory(any()))
          .thenAnswer((_) async {});

      await viewModel.saveFishCatch();

      final captured = verify(
        () => mockFishCatchService.create(captureAny()),
      ).captured;
      final fish = captured.first as FishCatch;
      expect(fish.pendingRecognition, true);
      expect(fish.species, strings.pendingRecognition);
    });

    test('sets captureState to saving during save', () async {
      viewModel.setImagePath('/photos/test.jpg');
      viewModel.setSpecies('Bass');
      viewModel.setLength(30);

      // Use a completer to inspect state mid-save
      late CameraCaptureState stateDuringSave;
      when(() => mockFishCatchService.create(any())).thenAnswer((_) async {
        stateDuringSave = viewModel.state.captureState;
        return 1;
      });
      when(() => mockFishCatchService.updateSpeciesHistory(any()))
          .thenAnswer((_) async {});

      await viewModel.saveFishCatch();

      expect(stateDuringSave, CameraCaptureState.saving);
    });

    test('handles service error gracefully', () async {
      viewModel.setImagePath('/photos/test.jpg');
      viewModel.setSpecies('Bass');
      viewModel.setLength(30);

      when(() => mockFishCatchService.create(any()))
          .thenThrow(Exception('DB write failed'));

      final result = await viewModel.saveFishCatch();

      expect(result, isNull);
      expect(viewModel.state.captureState, CameraCaptureState.error);
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.errorMessage, isNotNull);
      expect(viewModel.state.errorMessage, contains('DB write failed'));
    });

    test('handles species history update error gracefully', () async {
      viewModel.setImagePath('/photos/test.jpg');
      viewModel.setSpecies('Bass');
      viewModel.setLength(30);

      when(() => mockFishCatchService.create(any())).thenAnswer((_) async => 1);
      when(() => mockFishCatchService.updateSpeciesHistory(any()))
          .thenThrow(Exception('history update failed'));

      final result = await viewModel.saveFishCatch();

      // Error is caught by ErrorService.wrap and outer catch
      expect(result, isNull);
      expect(viewModel.state.captureState, CameraCaptureState.error);
    });

    test('sets estimatedWeight as fallback when weight is null', () async {
      viewModel.setImagePath('/photos/test.jpg');
      viewModel.setSpecies('Bass');
      viewModel.setLength(30);
      // weight is null, but estimatedWeight should be computed

      when(() => mockFishCatchService.create(any())).thenAnswer((_) async => 1);
      when(() => mockFishCatchService.updateSpeciesHistory(any()))
          .thenAnswer((_) async {});

      await viewModel.saveFishCatch();

      final captured = verify(
        () => mockFishCatchService.create(captureAny()),
      ).captured;
      final fish = captured.first as FishCatch;
      // When weight is null, saveFishCatch uses estimatedWeight
      expect(fish.weight, viewModel.state.estimatedWeight);
    });
  });

  // ===========================================================================
  // 10. loadSpeciesHistory
  // ===========================================================================
  group('loadSpeciesHistory', () {
    test('updates speciesHistory on success', () async {
      when(() => mockFishCatchService.getSpeciesHistory())
          .thenAnswer((_) async => ['Bass', 'Trout', 'Salmon']);

      await viewModel.loadSpeciesHistory();

      expect(viewModel.state.speciesHistory, ['Bass', 'Trout', 'Salmon']);
    });

    test('sets errorMessage on failure', () async {
      when(() => mockFishCatchService.getSpeciesHistory())
          .thenThrow(Exception('network error'));

      await viewModel.loadSpeciesHistory();

      expect(viewModel.state.errorMessage, isNotNull);
      expect(viewModel.state.errorMessage, contains('network error'));
    });
  });

  // ===========================================================================
  // 11. loadEquipments
  // ===========================================================================
  group('loadEquipments', () {
    test('loads rods, reels, lures and selects defaults', () async {
      final defaultRod = _rod(id: 1, isDefault: true);
      final defaultReel = _reel(id: 2, isDefault: true);
      final defaultLure = _lure(id: 3, isDefault: true);

      when(() => mockEquipmentService.getAll(type: 'rod'))
          .thenAnswer((_) async => [defaultRod, _rod(id: 11)]);
      when(() => mockEquipmentService.getAll(type: 'reel'))
          .thenAnswer((_) async => [defaultReel, _reel(id: 12)]);
      when(() => mockEquipmentService.getAll(type: 'lure'))
          .thenAnswer((_) async => [defaultLure, _lure(id: 13)]);

      await viewModel.loadEquipments();

      expect(viewModel.state.rods.length, 2);
      expect(viewModel.state.reels.length, 2);
      expect(viewModel.state.lures.length, 2);
      expect(viewModel.state.selectedRod, defaultRod);
      expect(viewModel.state.selectedReel, defaultReel);
      expect(viewModel.state.selectedLure, defaultLure);
    });

    test('selects null defaults when no default equipment exists', () async {
      when(() => mockEquipmentService.getAll(type: 'rod'))
          .thenAnswer((_) async => [_rod(id: 1)]);
      when(() => mockEquipmentService.getAll(type: 'reel'))
          .thenAnswer((_) async => [_reel(id: 2)]);
      when(() => mockEquipmentService.getAll(type: 'lure'))
          .thenAnswer((_) async => [_lure(id: 3)]);

      await viewModel.loadEquipments();

      expect(viewModel.state.selectedRod, isNull);
      expect(viewModel.state.selectedReel, isNull);
      expect(viewModel.state.selectedLure, isNull);
    });

    test('sets errorMessage on failure', () async {
      when(() => mockEquipmentService.getAll(type: 'rod'))
          .thenThrow(Exception('db read failed'));

      await viewModel.loadEquipments();

      expect(viewModel.state.errorMessage, isNotNull);
      expect(viewModel.state.errorMessage, contains('db read failed'));
    });
  });
}
