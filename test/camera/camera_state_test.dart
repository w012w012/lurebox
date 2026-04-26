import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/camera/camera_state.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/models/fish_catch.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

final _now = DateTime(2025, 6, 15, 10, 30);

Equipment _rod({int id = 1}) => Equipment(
      id: id,
      type: EquipmentType.rod,
      brand: 'Shimano',
      model: 'Expride',
      createdAt: _now,
      updatedAt: _now,
    );

Equipment _reel({int id = 2}) => Equipment(
      id: id,
      type: EquipmentType.reel,
      brand: 'Daiwa',
      model: 'Exist',
      createdAt: _now,
      updatedAt: _now,
    );

Equipment _lure({int id = 3}) => Equipment(
      id: id,
      type: EquipmentType.lure,
      brand: 'Megabass',
      model: 'Vision 110',
      createdAt: _now,
      updatedAt: _now,
    );

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // ===========================================================================
  // 1. Default constructor
  // ===========================================================================
  group('CameraState default constructor', () {
    test('creates state with expected defaults', () {
      const state = CameraState();

      expect(state.captureState, CameraCaptureState.initial);
      expect(state.imagePath, isNull);
      expect(state.watermarkedImagePath, isNull);
      expect(state.species, '');
      expect(state.length, 0);
      expect(state.lengthUnit, 'cm');
      expect(state.weight, isNull);
      expect(state.weightUnit, 'kg');
      expect(state.fate, FishFateType.release);
      expect(state.locationName, isNull);
      expect(state.latitude, isNull);
      expect(state.longitude, isNull);
      expect(state.catchTime, isNull);
      expect(state.airTemperature, isNull);
      expect(state.pressure, isNull);
      expect(state.weatherCode, isNull);
      expect(state.speciesHistory, isEmpty);
      expect(state.rods, isEmpty);
      expect(state.reels, isEmpty);
      expect(state.lures, isEmpty);
      expect(state.selectedRod, isNull);
      expect(state.selectedReel, isNull);
      expect(state.selectedLure, isNull);
      expect(state.estimatedWeight, isNull);
      expect(state.isCameraInitialized, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.isLoading, isFalse);
      expect(state.isTakingPicture, isFalse);
      expect(state.canSwitchCamera, isFalse);
      expect(state.isRecognizing, isFalse);
      expect(state.recognizedSpecies, isNull);
      expect(state.recognitionConfidence, isNull);
      expect(state.pendingRecognition, isFalse);
    });

    test('is a const constructor', () {
      // Verify the constructor can be used in const context at compile time.
      const state = CameraState();
      expect(state, isA<CameraState>());
    });
  });

  // ===========================================================================
  // 2. copyWith basic — update non-nullable fields
  // ===========================================================================
  group('copyWith updates non-nullable fields', () {
    test('updates captureState', () {
      const state = CameraState();
      final updated = state.copyWith(captureState: CameraCaptureState.cameraReady);

      expect(updated.captureState, CameraCaptureState.cameraReady);
    });

    test('updates species', () {
      const state = CameraState();
      final updated = state.copyWith(species: '鲈鱼');

      expect(updated.species, '鲈鱼');
    });

    test('updates length', () {
      const state = CameraState();
      final updated = state.copyWith(length: 35.5);

      expect(updated.length, 35.5);
    });

    test('updates fate', () {
      const state = CameraState();
      final updated = state.copyWith(fate: FishFateType.keep);

      expect(updated.fate, FishFateType.keep);
    });

    test('updates boolean flags', () {
      const state = CameraState();
      final updated = state.copyWith(
        isCameraInitialized: true,
        isLoading: true,
        isTakingPicture: true,
        canSwitchCamera: true,
        isRecognizing: true,
        pendingRecognition: true,
      );

      expect(updated.isCameraInitialized, isTrue);
      expect(updated.isLoading, isTrue);
      expect(updated.isTakingPicture, isTrue);
      expect(updated.canSwitchCamera, isTrue);
      expect(updated.isRecognizing, isTrue);
      expect(updated.pendingRecognition, isTrue);
    });

    test('updates lists', () {
      final rod = _rod();
      const state = CameraState();
      final updated = state.copyWith(
        speciesHistory: ['鲈鱼', '翘嘴'],
        rods: [rod],
        reels: [_reel()],
        lures: [_lure()],
      );

      expect(updated.speciesHistory, ['鲈鱼', '翘嘴']);
      expect(updated.rods, [rod]);
      expect(updated.reels, hasLength(1));
      expect(updated.lures, hasLength(1));
    });

    test('updates equipment selections via closure', () {
      final rod = _rod();
      final reel = _reel();
      final lure = _lure();

      const state = CameraState();
      final updated = state.copyWith(
        selectedRod: () => rod,
        selectedReel: () => reel,
        selectedLure: () => lure,
      );

      expect(updated.selectedRod, rod);
      expect(updated.selectedReel, reel);
      expect(updated.selectedLure, lure);
    });
  });

  // ===========================================================================
  // 3. copyWith preserves unmodified fields
  // ===========================================================================
  group('copyWith preserves unmodified fields', () {
    test('preserves all other fields when updating one', () {
      final rod = _rod();
      final catchTime = DateTime(2025, 6, 10, 8, 0);
      final state = CameraState(
        captureState: CameraCaptureState.pictureTaken,
        imagePath: '/path/to/image.jpg',
        species: '鲈鱼',
        length: 35.5,
        lengthUnit: 'in',
        weight: 2.5,
        weightUnit: 'lb',
        fate: FishFateType.keep,
        locationName: '千岛湖',
        latitude: 29.6,
        longitude: 119.0,
        catchTime: catchTime,
        airTemperature: 28.5,
        pressure: 1013.0,
        weatherCode: 1,
        speciesHistory: ['鲈鱼'],
        rods: [rod],
        reels: [_reel()],
        lures: [_lure()],
        selectedRod: rod,
        estimatedWeight: 1.8,
        isCameraInitialized: true,
        isLoading: false,
        isTakingPicture: false,
        canSwitchCamera: true,
        isRecognizing: false,
        recognizedSpecies: '鲈鱼',
        recognitionConfidence: 92,
        pendingRecognition: false,
      );

      // Only update species
      final updated = state.copyWith(species: '翘嘴');

      // species changes
      expect(updated.species, '翘嘴');

      // Everything else preserved
      expect(updated.captureState, CameraCaptureState.pictureTaken);
      expect(updated.imagePath, '/path/to/image.jpg');
      expect(updated.length, 35.5);
      expect(updated.lengthUnit, 'in');
      expect(updated.weight, 2.5);
      expect(updated.weightUnit, 'lb');
      expect(updated.fate, FishFateType.keep);
      expect(updated.locationName, '千岛湖');
      expect(updated.latitude, 29.6);
      expect(updated.longitude, 119.0);
      expect(updated.catchTime, catchTime);
      expect(updated.airTemperature, 28.5);
      expect(updated.pressure, 1013.0);
      expect(updated.weatherCode, 1);
      expect(updated.speciesHistory, ['鲈鱼']);
      expect(updated.rods, [rod]);
      expect(updated.reels, hasLength(1));
      expect(updated.lures, hasLength(1));
      expect(updated.selectedRod, rod);
      expect(updated.estimatedWeight, 1.8);
      expect(updated.isCameraInitialized, isTrue);
      expect(updated.canSwitchCamera, isTrue);
      expect(updated.recognizedSpecies, '鲈鱼');
      expect(updated.recognitionConfidence, 92);
    });
  });

  // ===========================================================================
  // 4. copyWith nullable closure — clears nullable fields with () => null
  // ===========================================================================
  group('copyWith nullable closure clears fields', () {
    test('clears imagePath with () => null', () {
      const state = CameraState(imagePath: '/old/path.jpg');
      final updated = state.copyWith(imagePath: () => null);

      expect(updated.imagePath, isNull);
    });

    test('clears watermarkedImagePath with () => null', () {
      const state = CameraState(watermarkedImagePath: '/wm/path.jpg');
      final updated = state.copyWith(watermarkedImagePath: () => null);

      expect(updated.watermarkedImagePath, isNull);
    });

    test('clears errorMessage with () => null', () {
      const state = CameraState(errorMessage: 'camera failed');
      final updated = state.copyWith(errorMessage: () => null);

      expect(updated.errorMessage, isNull);
    });

    test('clears locationName with () => null', () {
      const state = CameraState(locationName: '千岛湖');
      final updated = state.copyWith(locationName: () => null);

      expect(updated.locationName, isNull);
    });

    test('clears latitude and longitude with () => null', () {
      const state = CameraState(latitude: 29.6, longitude: 119.0);
      final updated = state.copyWith(
        latitude: () => null,
        longitude: () => null,
      );

      expect(updated.latitude, isNull);
      expect(updated.longitude, isNull);
    });

    test('clears catchTime with () => null', () {
      final state = CameraState(catchTime: DateTime(2025, 6, 1));
      final updated = state.copyWith(catchTime: () => null);

      expect(updated.catchTime, isNull);
    });

    test('clears weather fields with () => null', () {
      const state = CameraState(
        airTemperature: 28.5,
        pressure: 1013.0,
        weatherCode: 1,
      );
      final updated = state.copyWith(
        airTemperature: () => null,
        pressure: () => null,
        weatherCode: () => null,
      );

      expect(updated.airTemperature, isNull);
      expect(updated.pressure, isNull);
      expect(updated.weatherCode, isNull);
    });

    test('clears equipment selections with () => null', () {
      final state = CameraState(
        selectedRod: _rod(),
        selectedReel: _reel(),
        selectedLure: _lure(),
      );
      final updated = state.copyWith(
        selectedRod: () => null,
        selectedReel: () => null,
        selectedLure: () => null,
      );

      expect(updated.selectedRod, isNull);
      expect(updated.selectedReel, isNull);
      expect(updated.selectedLure, isNull);
    });

    test('clears estimatedWeight with () => null', () {
      const state = CameraState(estimatedWeight: 2.5);
      final updated = state.copyWith(estimatedWeight: () => null);

      expect(updated.estimatedWeight, isNull);
    });

    test('clears AI recognition fields with () => null', () {
      const state = CameraState(
        recognizedSpecies: '鲈鱼',
        recognitionConfidence: 92,
      );
      final updated = state.copyWith(
        recognizedSpecies: () => null,
        recognitionConfidence: () => null,
      );

      expect(updated.recognizedSpecies, isNull);
      expect(updated.recognitionConfidence, isNull);
    });
  });

  // ===========================================================================
  // 5. copyWith returns a new instance (identity check)
  // ===========================================================================
  group('copyWith returns new instance', () {
    test('returns a different object reference', () {
      const state = CameraState();
      final updated = state.copyWith(species: '鲈鱼');

      expect(identical(state, updated), isFalse);
    });

    test('returns different object even with same values', () {
      const state = CameraState();
      final updated = state.copyWith();

      expect(identical(state, updated), isFalse);
    });

    test('returns different object when clearing nullable field', () {
      const state = CameraState(imagePath: '/path.jpg');
      final updated = state.copyWith(imagePath: () => null);

      expect(identical(state, updated), isFalse);
    });
  });

  // ===========================================================================
  // 6. canSave — happy path
  // ===========================================================================
  group('canSave returns true', () {
    test('when imagePath, length > 0, and species non-empty', () {
      const state = CameraState(
        imagePath: '/path/to/image.jpg',
        species: '鲈鱼',
        length: 35,
      );

      expect(state.canSave, isTrue);
    });

    test('when imagePath, length > 0, and pendingRecognition is true (empty species)', () {
      const state = CameraState(
        imagePath: '/path/to/image.jpg',
        length: 25,
        species: '',
        pendingRecognition: true,
      );

      expect(state.canSave, isTrue);
    });

    test('when all three conditions met (species + pendingRecognition)', () {
      const state = CameraState(
        imagePath: '/path/to/image.jpg',
        species: '鲈鱼',
        length: 30,
        pendingRecognition: true,
      );

      expect(state.canSave, isTrue);
    });
  });

  // ===========================================================================
  // 7. canSave — failure cases
  // ===========================================================================
  group('canSave returns false', () {
    test('when imagePath is null', () {
      const state = CameraState(
        species: '鲈鱼',
        length: 35,
      );

      expect(state.canSave, isFalse);
    });

    test('when length is zero', () {
      const state = CameraState(
        imagePath: '/path/to/image.jpg',
        species: '鲈鱼',
        length: 0,
      );

      expect(state.canSave, isFalse);
    });

    test('when length is negative', () {
      const state = CameraState(
        imagePath: '/path/to/image.jpg',
        species: '鲈鱼',
        length: -5,
      );

      expect(state.canSave, isFalse);
    });

    test('when species is empty and pendingRecognition is false', () {
      const state = CameraState(
        imagePath: '/path/to/image.jpg',
        length: 35,
        species: '',
        pendingRecognition: false,
      );

      expect(state.canSave, isFalse);
    });

    test('when all required fields are missing (default state)', () {
      const state = CameraState();

      expect(state.canSave, isFalse);
    });

    test('when only imagePath is provided', () {
      const state = CameraState(imagePath: '/path/to/image.jpg');

      expect(state.canSave, isFalse);
    });

    test('when only species is provided', () {
      const state = CameraState(species: '鲈鱼', length: 35);

      expect(state.canSave, isFalse);
    });
  });

  // ===========================================================================
  // 8. weightCoefficient constant
  // ===========================================================================
  group('weightCoefficient', () {
    test('has expected value', () {
      expect(CameraState.weightCoefficient, 0.012);
    });
  });

  // ===========================================================================
  // 9. State transitions via copyWith
  // ===========================================================================
  group('state transitions', () {
    test('initial -> cameraReady', () {
      const state = CameraState();
      expect(state.captureState, CameraCaptureState.initial);

      final ready = state.copyWith(
        captureState: CameraCaptureState.cameraReady,
        isCameraInitialized: true,
      );
      expect(ready.captureState, CameraCaptureState.cameraReady);
      expect(ready.isCameraInitialized, isTrue);
    });

    test('cameraReady -> pictureTaken', () {
      final state = const CameraState().copyWith(
        captureState: CameraCaptureState.cameraReady,
        isCameraInitialized: true,
      );

      final taken = state.copyWith(
        captureState: CameraCaptureState.pictureTaken,
        imagePath: () => '/captured/photo.jpg',
        isTakingPicture: false,
      );

      expect(taken.captureState, CameraCaptureState.pictureTaken);
      expect(taken.imagePath, '/captured/photo.jpg');
      expect(taken.isTakingPicture, isFalse);
    });

    test('pictureTaken -> saving -> saved', () {
      final taken = const CameraState().copyWith(
        captureState: CameraCaptureState.pictureTaken,
        imagePath: () => '/captured/photo.jpg',
      );

      final saving = taken.copyWith(
        captureState: CameraCaptureState.saving,
        isLoading: true,
      );
      expect(saving.captureState, CameraCaptureState.saving);
      expect(saving.isLoading, isTrue);

      final saved = saving.copyWith(
        captureState: CameraCaptureState.saved,
        isLoading: false,
      );
      expect(saved.captureState, CameraCaptureState.saved);
      expect(saved.isLoading, isFalse);
    });

    test('any state -> error', () {
      const state = CameraState();
      final errored = state.copyWith(
        captureState: CameraCaptureState.error,
        errorMessage: () => '相机初始化失败',
      );

      expect(errored.captureState, CameraCaptureState.error);
      expect(errored.errorMessage, '相机初始化失败');
    });

    test('full recording flow preserves accumulated data', () {
      final rod = _rod();
      final lure = _lure();

      // Start: initial state
      const initial = CameraState();
      expect(initial.canSave, isFalse);

      // Camera ready
      final ready = initial.copyWith(
        captureState: CameraCaptureState.cameraReady,
        isCameraInitialized: true,
        canSwitchCamera: true,
      );

      // Take picture
      final taken = ready.copyWith(
        captureState: CameraCaptureState.pictureTaken,
        imagePath: () => '/captured/fish.jpg',
        isTakingPicture: false,
      );

      // Fill form data
      final withForm = taken.copyWith(
        species: '鲈鱼',
        length: 42,
        weight: 3.2,
        fate: FishFateType.release,
        locationName: () => '太湖',
        latitude: () => 31.2,
        longitude: () => 120.3,
        catchTime: () => _now,
        selectedRod: () => rod,
        selectedLure: () => lure,
      );

      expect(withForm.captureState, CameraCaptureState.pictureTaken);
      expect(withForm.imagePath, '/captured/fish.jpg');
      expect(withForm.species, '鲈鱼');
      expect(withForm.length, 42);
      expect(withForm.weight, 3.2);
      expect(withForm.fate, FishFateType.release);
      expect(withForm.locationName, '太湖');
      expect(withForm.latitude, 31.2);
      expect(withForm.longitude, 120.3);
      expect(withForm.catchTime, _now);
      expect(withForm.selectedRod, rod);
      expect(withForm.selectedLure, lure);
      expect(withForm.canSave, isTrue);
      expect(withForm.isCameraInitialized, isTrue);
      expect(withForm.canSwitchCamera, isTrue);
    });
  });

  // ===========================================================================
  // 10. CameraCaptureState enum values
  // ===========================================================================
  group('CameraCaptureState enum', () {
    test('has all expected values', () {
      expect(CameraCaptureState.values, hasLength(6));
      expect(CameraCaptureState.values, contains(CameraCaptureState.initial));
      expect(
        CameraCaptureState.values,
        contains(CameraCaptureState.cameraReady),
      );
      expect(
        CameraCaptureState.values,
        contains(CameraCaptureState.pictureTaken),
      );
      expect(CameraCaptureState.values, contains(CameraCaptureState.saving));
      expect(CameraCaptureState.values, contains(CameraCaptureState.saved));
      expect(CameraCaptureState.values, contains(CameraCaptureState.error));
    });
  });

  // ===========================================================================
  // 11. copyWith with nullable closure sets new values
  // ===========================================================================
  group('copyWith nullable closure sets new values', () {
    test('sets imagePath from null to a value', () {
      const state = CameraState();
      final updated = state.copyWith(imagePath: () => '/new/image.jpg');

      expect(updated.imagePath, '/new/image.jpg');
    });

    test('sets catchTime from null to a value', () {
      const state = CameraState();
      final time = DateTime(2025, 7, 1);
      final updated = state.copyWith(catchTime: () => time);

      expect(updated.catchTime, time);
    });

    test('sets weather fields from null to values', () {
      const state = CameraState();
      final updated = state.copyWith(
        airTemperature: () => 30.0,
        pressure: () => 1015.0,
        weatherCode: () => 3,
      );

      expect(updated.airTemperature, 30.0);
      expect(updated.pressure, 1015.0);
      expect(updated.weatherCode, 3);
    });
  });

  // ===========================================================================
  // 12. copyWith with non-nullable closure overwrites existing values
  // ===========================================================================
  group('copyWith nullable closure overwrites existing values', () {
    test('overwrites existing imagePath', () {
      const state = CameraState(imagePath: '/old/image.jpg');
      final updated = state.copyWith(imagePath: () => '/new/image.jpg');

      expect(updated.imagePath, '/new/image.jpg');
    });

    test('overwrites existing catchTime', () {
      final oldTime = DateTime(2025, 1, 1);
      final newTime = DateTime(2025, 12, 31);
      final state = CameraState(catchTime: oldTime);
      final updated = state.copyWith(catchTime: () => newTime);

      expect(updated.catchTime, newTime);
    });
  });

  // ===========================================================================
  // 13. AI recognition flow
  // ===========================================================================
  group('AI recognition flow', () {
    test('pendingRecognition allows canSave without species', () {
      const state = CameraState(
        imagePath: '/fish.jpg',
        length: 30,
        pendingRecognition: true,
        species: '',
      );

      expect(state.canSave, isTrue);
    });

    test('after recognition completes, species is populated', () {
      const state = CameraState(
        imagePath: '/fish.jpg',
        length: 30,
        pendingRecognition: true,
      );

      final recognized = state.copyWith(
        recognizedSpecies: () => '鲈鱼',
        recognitionConfidence: () => 95,
        isRecognizing: false,
        species: '鲈鱼',
        pendingRecognition: false,
      );

      expect(recognized.species, '鲈鱼');
      expect(recognized.recognizedSpecies, '鲈鱼');
      expect(recognized.recognitionConfidence, 95);
      expect(recognized.isRecognizing, isFalse);
      expect(recognized.pendingRecognition, isFalse);
      expect(recognized.canSave, isTrue);
    });

    test('isRecognizing flag tracks recognition in progress', () {
      const state = CameraState();
      final recognizing = state.copyWith(isRecognizing: true);

      expect(recognizing.isRecognizing, isTrue);
    });
  });
}
