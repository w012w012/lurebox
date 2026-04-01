import '../models/fish_catch.dart';
import '../models/equipment.dart';

enum CameraCaptureState {
  initial,
  cameraReady,
  pictureTaken,
  saving,
  saved,
  error,
}

class CameraState {
  final bool pendingRecognition;
  final CameraCaptureState captureState;
  final String? imagePath;
  final String? watermarkedImagePath;
  final String species;
  final double length;
  final String lengthUnit;
  final double? weight;
  final String weightUnit;
  final FishFateType fate;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final DateTime? catchTime;
  final double? airTemperature; // 气温（摄氏度）
  final double? pressure; // 气压（hPa）
  final int? weatherCode; // 天气代码（WMO）
  final List<String> speciesHistory;
  final List<Equipment> rods;
  final List<Equipment> reels;
  final List<Equipment> lures;
  final Equipment? selectedRod;
  final Equipment? selectedReel;
  final Equipment? selectedLure;
  final double? estimatedWeight;
  final bool isCameraInitialized;
  final String? errorMessage;
  final bool isLoading;
  final bool isTakingPicture;
  final bool canSwitchCamera;
  // AI 识别相关状态
  final bool isRecognizing;
  final String? recognizedSpecies;
  final int? recognitionConfidence;

  static const double weightCoefficient = 0.012;

  const CameraState({
    this.captureState = CameraCaptureState.initial,
    this.imagePath,
    this.watermarkedImagePath,
    this.species = '',
    this.length = 0,
    this.lengthUnit = 'cm',
    this.weight,
    this.weightUnit = 'kg',
    this.fate = FishFateType.release,
    this.locationName,
    this.latitude,
    this.longitude,
    this.catchTime,
    this.airTemperature,
    this.pressure,
    this.weatherCode,
    this.speciesHistory = const [],
    this.rods = const [],
    this.reels = const [],
    this.lures = const [],
    this.selectedRod,
    this.selectedReel,
    this.selectedLure,
    this.estimatedWeight,
    this.isCameraInitialized = false,
    this.errorMessage,
    this.isLoading = false,
    this.isTakingPicture = false,
    this.canSwitchCamera = false,
    this.isRecognizing = false,
    this.recognizedSpecies,
    this.recognitionConfidence,
    this.pendingRecognition = false,
  });

  CameraState copyWith({
    CameraCaptureState? captureState,
    String? Function()? imagePath,
    String? Function()? watermarkedImagePath,
    String? species,
    double? length,
    String? lengthUnit,
    double? weight,
    String? weightUnit,
    FishFateType? fate,
    String? Function()? locationName,
    double? Function()? latitude,
    double? Function()? longitude,
    DateTime? Function()? catchTime,
    double? Function()? airTemperature,
    double? Function()? pressure,
    int? Function()? weatherCode,
    List<String>? speciesHistory,
    List<Equipment>? rods,
    List<Equipment>? reels,
    List<Equipment>? lures,
    Equipment? Function()? selectedRod,
    Equipment? Function()? selectedReel,
    Equipment? Function()? selectedLure,
    double? Function()? estimatedWeight,
    bool? isCameraInitialized,
    String? Function()? errorMessage,
    bool? isLoading,
    bool? isTakingPicture,
    bool? canSwitchCamera,
    bool? isRecognizing,
    String? Function()? recognizedSpecies,
    int? Function()? recognitionConfidence,
    bool? pendingRecognition,
  }) {
    return CameraState(
      captureState: captureState ?? this.captureState,
      imagePath: imagePath != null ? imagePath() : this.imagePath,
      watermarkedImagePath: watermarkedImagePath != null
          ? watermarkedImagePath()
          : this.watermarkedImagePath,
      species: species ?? this.species,
      length: length ?? this.length,
      lengthUnit: lengthUnit ?? this.lengthUnit,
      weight: weight != null ? weight : this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      fate: fate ?? this.fate,
      locationName: locationName != null ? locationName() : this.locationName,
      latitude: latitude != null ? latitude() : this.latitude,
      longitude: longitude != null ? longitude() : this.longitude,
      catchTime: catchTime != null ? catchTime() : this.catchTime,
      airTemperature:
          airTemperature != null ? airTemperature() : this.airTemperature,
      pressure: pressure != null ? pressure() : this.pressure,
      weatherCode: weatherCode != null ? weatherCode() : this.weatherCode,
      speciesHistory: speciesHistory ?? this.speciesHistory,
      rods: rods ?? this.rods,
      reels: reels ?? this.reels,
      lures: lures ?? this.lures,
      selectedRod: selectedRod != null ? selectedRod() : this.selectedRod,
      selectedReel: selectedReel != null ? selectedReel() : this.selectedReel,
      selectedLure: selectedLure != null ? selectedLure() : this.selectedLure,
      estimatedWeight:
          estimatedWeight != null ? estimatedWeight() : this.estimatedWeight,
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isTakingPicture: isTakingPicture ?? this.isTakingPicture,
      canSwitchCamera: canSwitchCamera ?? this.canSwitchCamera,
      isRecognizing: isRecognizing ?? this.isRecognizing,
      recognizedSpecies: recognizedSpecies != null
          ? recognizedSpecies()
          : this.recognizedSpecies,
      recognitionConfidence: recognitionConfidence != null
          ? recognitionConfidence()
          : this.recognitionConfidence,
      pendingRecognition: pendingRecognition ?? this.pendingRecognition,
    );
  }

  bool get canSave =>
      imagePath != null &&
      length > 0 &&
      (species.isNotEmpty || pendingRecognition);
}
