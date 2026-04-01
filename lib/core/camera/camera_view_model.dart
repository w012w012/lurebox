import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fish_catch.dart';
import '../models/equipment.dart';
import '../models/app_settings.dart';
import '../utils/unit_converter.dart';
import '../di/di.dart';
import '../services/fish_catch_service.dart';
import '../services/equipment_service.dart';
import '../services/error_service.dart' as error_service;
import 'camera_helper.dart';
import 'camera_state.dart';

class CameraViewModel extends StateNotifier<CameraState> {
  final CameraHelper _cameraHelper = CameraHelper();
  final FishCatchService _fishCatchService;
  final EquipmentService _equipmentService;

  CameraViewModel(this._fishCatchService, this._equipmentService)
      : super(const CameraState());

  CameraHelper get cameraHelper => _cameraHelper;

  Future<void> initializeCamera() async {
    state = state.copyWith(isLoading: true);
    try {
      await error_service.ErrorService().wrap(() async {
        await _cameraHelper.initCamera();
      }, context: '初始化相机');

      state = state.copyWith(
        isCameraInitialized: _cameraHelper.isInitialized,
        canSwitchCamera: _cameraHelper.canSwitchCamera,
        errorMessage: () => _cameraHelper.errorMessage,
        captureState: _cameraHelper.isInitialized
            ? CameraCaptureState.cameraReady
            : CameraCaptureState.initial,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => e.toString(),
      );
    }
  }

  Future<void> switchCamera() async {
    try {
      await error_service.ErrorService().wrap(() async {
        final success = await _cameraHelper.switchCamera();
        if (success) {
          state = state.copyWith(
            canSwitchCamera: _cameraHelper.canSwitchCamera,
            errorMessage: () => _cameraHelper.errorMessage,
          );
        }
      }, context: '切换相机');
    } catch (e) {
      state = state.copyWith(errorMessage: () => e.toString());
    }
  }

  Future<String?> takePicture() async {
    if (state.isTakingPicture) return null;

    state = state.copyWith(isTakingPicture: true);
    try {
      return await error_service.ErrorService().wrap(() async {
        final path = await _cameraHelper.takePicture();
        if (path != null) {
          setImagePath(path);
        }
        return path;
      }, context: '拍照');
    } finally {
      state = state.copyWith(isTakingPicture: false);
    }
  }

  Future<void> getLocation() async {
    try {
      await error_service.ErrorService().wrap(() async {
        await _cameraHelper.getLocation();
        setLocation(
          _cameraHelper.locationName,
          _cameraHelper.position?.latitude,
          _cameraHelper.position?.longitude,
          _cameraHelper.weatherData?.airTemperature,
          _cameraHelper.weatherData?.pressure,
          _cameraHelper.weatherData?.weatherCode,
        );
      }, context: '获取位置');
    } catch (e) {
      state = state.copyWith(errorMessage: () => e.toString());
    }
  }

  Future<void> loadSpeciesHistory() async {
    try {
      await error_service.ErrorService().wrap(() async {
        final history = await _fishCatchService.getSpeciesHistory();
        state = state.copyWith(speciesHistory: history);
      }, context: '加载历史品种');
    } catch (e) {
      state = state.copyWith(errorMessage: () => e.toString());
    }
  }

  Future<void> loadEquipments() async {
    try {
      await error_service.ErrorService().wrap(() async {
        final rods = await _equipmentService.getAll(type: 'rod');
        final reels = await _equipmentService.getAll(type: 'reel');
        final lures = await _equipmentService.getAll(type: 'lure');

        Equipment? defaultRod;
        Equipment? defaultReel;
        Equipment? defaultLure;
        for (final rod in rods) {
          if (rod.isDefault) {
            defaultRod = rod;
            break;
          }
        }
        for (final reel in reels) {
          if (reel.isDefault) {
            defaultReel = reel;
            break;
          }
        }
        for (final lure in lures) {
          if (lure.isDefault) {
            defaultLure = lure;
            break;
          }
        }

        state = state.copyWith(
          rods: rods,
          reels: reels,
          lures: lures,
          selectedRod: () => defaultRod,
          selectedReel: () => defaultReel,
          selectedLure: () => defaultLure,
        );
      }, context: '加载装备');
    } catch (e) {
      state = state.copyWith(errorMessage: () => e.toString());
    }
  }

  void setImagePath(String path) {
    state = state.copyWith(
      imagePath: () => path,
      captureState: CameraCaptureState.pictureTaken,
    );
  }

  void setSpecies(String species) {
    final bool keepPending =
        species.isNotEmpty ? false : state.pendingRecognition;
    state = state.copyWith(species: species, pendingRecognition: keepPending);
  }

  void setPendingRecognition(bool value) {
    state = state.copyWith(pendingRecognition: value);
  }

  void setCatchTime(DateTime time) {
    state = state.copyWith(catchTime: () => time);
  }

  void setAirTemperature(double temp) {
    state = state.copyWith(airTemperature: () => temp);
  }

  void setPressure(double pressure) {
    state = state.copyWith(pressure: () => pressure);
  }

  void setWeatherCode(int? code) {
    state = state.copyWith(weatherCode: () => code);
  }

  void setLocationName(String name) {
    state = state.copyWith(locationName: () => name);
  }

  void setLength(double length) {
    final estimated = _calculateEstimatedWeight(length);
    state = state.copyWith(length: length, estimatedWeight: () => estimated);
  }

  void setWeight(double? weight) {
    state = state.copyWith(weight: weight);
  }

  void setLengthUnit(String unit) {
    state = state.copyWith(lengthUnit: unit);
  }

  void setWeightUnit(String unit) {
    state = state.copyWith(weightUnit: unit);
  }

  void initializeUnits(UnitSettings settings) {
    state = state.copyWith(
      lengthUnit: settings.fishLengthUnit,
      weightUnit: settings.fishWeightUnit,
    );
  }

  void setFate(FishFateType fate) {
    state = state.copyWith(fate: fate);
  }

  void setLocation(
    String? name,
    double? lat,
    double? lng,
    double? temperature,
    double? pressure,
    int? weatherCode,
  ) {
    state = state.copyWith(
      locationName: () => name,
      latitude: () => lat,
      longitude: () => lng,
      airTemperature: () => temperature,
      pressure: () => pressure,
      weatherCode: () => weatherCode,
    );
  }

  void setSelectedRod(Equipment? rod) {
    state = state.copyWith(selectedRod: () => rod);
  }

  void setSelectedReel(Equipment? reel) {
    state = state.copyWith(selectedReel: () => reel);
  }

  void setSelectedLure(Equipment? lure) {
    state = state.copyWith(selectedLure: () => lure);
  }

  double? _calculateEstimatedWeight(double length) {
    if (length <= 0) return null;
    // 公式基于厘米计算，转换输入长度到厘米
    final lengthInCm = UnitConverter.convertLength(
      length,
      state.lengthUnit,
      'cm',
    );
    final weightInGrams =
        lengthInCm * lengthInCm * lengthInCm * CameraState.weightCoefficient;
    // 转换到用户设置的重量单位
    final weightInKg = weightInGrams / 1000;
    return UnitConverter.convertWeight(weightInKg, 'kg', state.weightUnit);
  }

  Future<int?> saveFishCatch() async {
    if (!state.canSave) {
      debugPrint('=== SAVE FISH CATCH: canSave returned false ===');
      debugPrint(
          'imagePath=${state.imagePath}, species=${state.species}, length=${state.length}');
      return null;
    }

    state = state.copyWith(
      captureState: CameraCaptureState.saving,
      isLoading: true,
    );

    try {
      return await error_service.ErrorService().wrap(() async {
        final now = DateTime.now();
        final fish = FishCatch(
          id: 0,
          imagePath: state.imagePath ?? '',
          watermarkedImagePath: state.watermarkedImagePath,
          species: state.species.isNotEmpty ? state.species : '待识别',
          length: state.length,
          lengthUnit: state.lengthUnit,
          weight: state.weight ?? state.estimatedWeight,
          weightUnit: state.weightUnit,
          fate: state.fate,
          catchTime: state.catchTime ?? now,
          pendingRecognition: state.pendingRecognition,
          locationName: state.locationName,
          latitude: state.latitude,
          longitude: state.longitude,
          rodId: state.selectedRod?.id,
          reelId: state.selectedReel?.id,
          lureId: state.selectedLure?.id,
          airTemperature: state.airTemperature,
          pressure: state.pressure,
          weatherCode: state.weatherCode,
          createdAt: now,
          updatedAt: now,
        );

        debugPrint('=== CREATING FISH CATCH ===');
        debugPrint('Fish: ${fish.toMap()}');

        final fishId = await _fishCatchService.create(fish);
        debugPrint('Fish created with ID: $fishId');

        await _fishCatchService.updateSpeciesHistory(state.species);
        debugPrint('Species history updated');

        state = state.copyWith(
          captureState: CameraCaptureState.saved,
          isLoading: false,
        );
        return fishId;
      }, context: '保存鱼获');
    } catch (e, stackTrace) {
      debugPrint('=== SAVE FISH CATCH ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Stack trace: $stackTrace');

      state = state.copyWith(
        captureState: CameraCaptureState.error,
        errorMessage: () => '保存失败: $e',
        isLoading: false,
      );
      return null;
    }
  }

  void reset() {
    state = const CameraState();
  }

  void setWatermarkedPath(String path) {
    state = state.copyWith(watermarkedImagePath: () => path);
  }

  void clearImage() {
    state = state.copyWith(
      imagePath: () => null,
      watermarkedImagePath: () => null,
      captureState: CameraCaptureState.cameraReady,
    );
  }

  /// 重置 captureState 到 pictureTaken，让用户留在表单页面
  /// 用于保存失败后恢复表单显示
  void resetCaptureStateToForm() {
    if (state.imagePath != null) {
      state = state.copyWith(
        captureState: CameraCaptureState.pictureTaken,
        isLoading: false,
        errorMessage: () => null,
      );
    }
  }

  /// 释放相机资源但不销毁 ViewModel
  void disposeCamera() {
    _cameraHelper.dispose();
  }

  @override
  void dispose() {
    _cameraHelper.dispose();
    super.dispose();
  }
}

final cameraViewModelProvider =
    StateNotifierProvider<CameraViewModel, CameraState>((ref) {
  return CameraViewModel(
    ref.read(fishCatchServiceProvider),
    ref.read(equipmentServiceProvider),
  );
});
