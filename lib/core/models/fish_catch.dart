/// 渔获记录数据模型
///
/// 定义了 LureBox 应用中渔获记录的核心数据结构。
///
/// 主要包含：
/// - [FishFateType]: 渔获处理方式枚举（放流/保留）
/// - [FishCatch]: 单次渔获的完整记录，包括鱼种、尺寸、位置、使用的钓具等信息
/// - [FishCatchListExtension]: 为渔获列表提供便捷的过滤、排序和搜索功能
///
/// 数据流向：
/// 1. 用户通过拍照记录渔获
/// 2. 系统保存原始图片并可生成水印图片
/// 3. 记录渔获的物种、尺寸、重量等信息
/// 4. 可关联使用的钓具（鱼竿、鱼轮、鱼饵）
/// 5. 支持放流或保留的标记
library;

import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/utils/unit_converter.dart';

enum FishFateType {
  release(0, '放流'),
  keep(1, '保留');

  const FishFateType(this.value, this.label);
  final int value;
  final String label;

  static FishFateType fromValue(int value) {
    return FishFateType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FishFateType.release,
    );
  }
}

class FishCatch {

  const FishCatch({
    required this.id,
    required this.imagePath,
    required this.species, required this.length, required this.fate, required this.catchTime, required this.createdAt, required this.updatedAt, this.watermarkedImagePath,
    this.lengthUnit = 'cm',
    this.weight,
    this.weightUnit = 'kg',
    this.locationName,
    this.latitude,
    this.longitude,
    this.equipmentId,
    this.rodId,
    this.reelId,
    this.lureId,
    this.airTemperature,
    this.pressure,
    this.weatherCode,
    this.pendingRecognition = false,
    this.notes,
    this.rigType,
    this.sinkerWeight,
    this.sinkerPosition,
    this.hookType,
    this.hookSize,
    this.hookWeight,
  });

  factory FishCatch.fromMap(Map<String, dynamic> map) {
    return FishCatch(
      id: map['id'] as int,
      imagePath: map['image_path'] as String,
      watermarkedImagePath: map['watermarked_image_path'] as String?,
      species: map['species'] as String,
      length: (map['length'] as num).toDouble(),
      lengthUnit: map['length_unit'] as String? ?? 'cm',
      weight: (map['weight'] as num?)?.toDouble(),
      weightUnit: map['weight_unit'] as String? ?? 'kg',
      fate: FishFateType.fromValue(map['fate'] as int),
      catchTime: DateTime.parse(map['catch_time'] as String),
      locationName: map['location_name'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      equipmentId: map['equipment_id'] as int?,
      rodId: map['rod_id'] as int?,
      reelId: map['reel_id'] as int?,
      lureId: map['lure_id'] as int?,
      airTemperature: (map['air_temperature'] as num?)?.toDouble(),
      pressure: (map['pressure'] as num?)?.toDouble(),
      weatherCode: map['weather_code'] as int?,
      pendingRecognition: (map['pending_recognition'] as int? ?? 0) == 1,
      notes: map['notes'] as String?,
      rigType: map['rig_type'] as String?,
      sinkerWeight: map['sinker_weight'] as String?,
      sinkerPosition: map['sinker_position'] as String?,
      hookType: map['hook_type'] as String?,
      hookSize: map['hook_size'] as String?,
      hookWeight: map['hook_weight'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  final int id;
  final String imagePath;
  final String? watermarkedImagePath;
  final String species;
  final double length;
  final String lengthUnit; // 输入时的单位
  final double? weight;
  final String weightUnit; // 输入时的单位
  final FishFateType fate;
  final DateTime catchTime;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final int? equipmentId;
  final int? rodId;
  final int? reelId;
  final int? lureId;
  final double? airTemperature; // 气温（摄氏度）
  final double? pressure; // 气压（hPa）
  final int? weatherCode; // 天气代码（WMO）
  final bool pendingRecognition; // 待识别标记：true=待识别，false=已识别
  final String? notes;
  final String? rigType;
  final String? sinkerWeight;
  final String? sinkerPosition;
  final String? hookType;
  final String? hookSize;
  final String? hookWeight;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_path': imagePath,
      'watermarked_image_path': watermarkedImagePath,
      'species': species,
      'length': length,
      'length_unit': lengthUnit,
      'weight': weight,
      'weight_unit': weightUnit,
      'fate': fate.value,
      'catch_time': catchTime.toIso8601String(),
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'equipment_id': equipmentId,
      'rod_id': rodId,
      'reel_id': reelId,
      'lure_id': lureId,
      'air_temperature': airTemperature,
      'pressure': pressure,
      'weather_code': weatherCode,
      'pending_recognition': pendingRecognition ? 1 : 0,
      'notes': notes,
      'rig_type': rigType,
      'sinker_weight': sinkerWeight,
      'sinker_position': sinkerPosition,
      'hook_type': hookType,
      'hook_size': hookSize,
      'hook_weight': hookWeight,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  FishCatch copyWith({
    int? id,
    String? imagePath,
    String? watermarkedImagePath,
    String? species,
    double? length,
    String? lengthUnit,
    double? weight,
    String? weightUnit,
    FishFateType? fate,
    DateTime? catchTime,
    String? Function()? locationName,
    double? Function()? latitude,
    double? Function()? longitude,
    int? Function()? equipmentId,
    int? Function()? rodId,
    int? Function()? reelId,
    int? Function()? lureId,
    double? Function()? airTemperature,
    double? Function()? pressure,
    int? Function()? weatherCode,
    bool? pendingRecognition,
    String? Function()? notes,
    String? Function()? rigType,
    String? Function()? sinkerWeight,
    String? Function()? sinkerPosition,
    String? Function()? hookType,
    String? Function()? hookSize,
    String? Function()? hookWeight,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FishCatch(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      watermarkedImagePath: watermarkedImagePath ?? this.watermarkedImagePath,
      species: species ?? this.species,
      length: length ?? this.length,
      lengthUnit: lengthUnit ?? this.lengthUnit,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      fate: fate ?? this.fate,
      catchTime: catchTime ?? this.catchTime,
      locationName: locationName != null ? locationName() : this.locationName,
      latitude: latitude != null ? latitude() : this.latitude,
      longitude: longitude != null ? longitude() : this.longitude,
      equipmentId: equipmentId != null ? equipmentId() : this.equipmentId,
      rodId: rodId != null ? rodId() : this.rodId,
      reelId: reelId != null ? reelId() : this.reelId,
      lureId: lureId != null ? lureId() : this.lureId,
      airTemperature:
          airTemperature != null ? airTemperature() : this.airTemperature,
      pressure: pressure != null ? pressure() : this.pressure,
      weatherCode: weatherCode != null ? weatherCode() : this.weatherCode,
      pendingRecognition: pendingRecognition ?? this.pendingRecognition,
      notes: notes != null ? notes() : this.notes,
      rigType: rigType != null ? rigType() : this.rigType,
      sinkerWeight: sinkerWeight != null ? sinkerWeight() : this.sinkerWeight,
      sinkerPosition: sinkerPosition != null
          ? sinkerPosition()
          : this.sinkerPosition,
      hookType: hookType != null ? hookType() : this.hookType,
      hookSize: hookSize != null ? hookSize() : this.hookSize,
      hookWeight: hookWeight != null ? hookWeight() : this.hookWeight,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FishCatch && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FishCatch(id: $id, species: $species, length: ${length}cm, fate: ${fate.label})';
  }
}

extension FishCatchListExtension on List<FishCatch> {
  List<FishCatch> filterByTime(String timeFilter) {
    final now = DateTime.now();
    return where((fish) {
      switch (timeFilter) {
        case 'today':
          final start = DateTime(now.year, now.month, now.day);
          final end = start.add(const Duration(days: 1));
          return !fish.catchTime.isBefore(start) &&
              fish.catchTime.isBefore(end);
        case 'week':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final start = DateTime(
            startOfWeek.year,
            startOfWeek.month,
            startOfWeek.day,
          );
          final end = start.add(const Duration(days: 7));
          return !fish.catchTime.isBefore(start) &&
              fish.catchTime.isBefore(end);
        case 'month':
          final nextMonth = now.month == 12 ? 1 : now.month + 1;
          final nextYear = now.month == 12 ? now.year + 1 : now.year;
          final start = DateTime(now.year, now.month);
          final end = DateTime(nextYear, nextMonth);
          return !fish.catchTime.isBefore(start) &&
              fish.catchTime.isBefore(end);
        case 'year':
          final start = DateTime(now.year);
          final end = DateTime(now.year + 1);
          return !fish.catchTime.isBefore(start) &&
              fish.catchTime.isBefore(end);
        default:
          return true;
      }
    }).toList();
  }

  List<FishCatch> filterByFate(FishFateType? fateFilter) {
    if (fateFilter == null) return this;
    return where((fish) => fish.fate == fateFilter).toList();
  }

  List<FishCatch> filterBySpecies(String? speciesFilter) {
    if (speciesFilter == null) return this;
    return where((fish) => fish.species == speciesFilter).toList();
  }

  /// 过滤掉待识别记录（pending_recognition = true）
  List<FishCatch> filterPendingRecognition() {
    return where((fish) => fish.pendingRecognition != true).toList();
  }

  List<FishCatch> searchByKeyword(String keyword) {
    if (keyword.isEmpty) return this;
    final lower = keyword.toLowerCase();
    return where((fish) {
      return fish.species.toLowerCase().contains(lower) ||
          (fish.locationName?.toLowerCase().contains(lower) ?? false);
    }).toList();
  }

  List<FishCatch> sortBy(
    String sortBy,
    bool ascending,
    UnitSettings? displayUnits,
  ) {
    final sorted = List<FishCatch>.from(this);
    sorted.sort((a, b) {
      switch (sortBy) {
        case 'length':
          final aLength = displayUnits != null
              ? UnitConverter.convertLength(
                  a.length,
                  a.lengthUnit,
                  displayUnits.fishLengthUnit,
                )
              : a.length;
          final bLength = displayUnits != null
              ? UnitConverter.convertLength(
                  b.length,
                  b.lengthUnit,
                  displayUnits.fishLengthUnit,
                )
              : b.length;
          final lengthResult = aLength.compareTo(bLength);
          return ascending ? lengthResult : -lengthResult;
        case 'weight':
          final aWeight = displayUnits != null && a.weight != null
              ? UnitConverter.convertWeight(
                  a.weight!,
                  a.weightUnit,
                  displayUnits.fishWeightUnit,
                )
              : (a.weight ?? 0);
          final bWeight = displayUnits != null && b.weight != null
              ? UnitConverter.convertWeight(
                  b.weight!,
                  b.weightUnit,
                  displayUnits.fishWeightUnit,
                )
              : (b.weight ?? 0);
          final weightResult = aWeight.compareTo(bWeight);
          return ascending ? weightResult : -weightResult;
        case 'time':
        default:
          final timeResult = a.catchTime.compareTo(b.catchTime);
          return ascending ? timeResult : -timeResult;
      }
    });
    return sorted;
  }

  List<String> get uniqueSpecies =>
      map((f) => f.species).toSet().toList()..sort();

  int get releaseCount => where((f) => f.fate == FishFateType.release).length;
  int get keepCount => where((f) => f.fate == FishFateType.keep).length;
  double get releaseRate => isEmpty ? 0 : releaseCount / length;
}
