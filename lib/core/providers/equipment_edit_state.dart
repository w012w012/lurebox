// No imports needed - pure Dart classes

/// Sealed class hierarchy for equipment edit states.
/// Each equipment type (rod/reel/lure) has its own subclass with type-specific fields.
sealed class EquipmentEditState {
  final String type;
  final Map<String, dynamic>? equipment;
  final bool isSaving;
  final String? errorMessage;
  final String brand;
  final String model;
  final String price;
  final String purchaseDate;
  final bool isDefault;
  final String categoryType1;
  final String categoryType2;

  const EquipmentEditState({
    required this.type,
    this.equipment,
    this.isSaving = false,
    this.errorMessage,
    this.brand = '',
    this.model = '',
    this.price = '',
    this.purchaseDate = '',
    this.isDefault = false,
    this.categoryType1 = '',
    this.categoryType2 = '',
  });

  /// Whether this is an edit (vs create) operation.
  bool get isEdit => equipment != null;

  /// Apply common field updates - each subclass provides its own copyWith
  EquipmentEditState withUpdates({
    String? type,
    Map<String, dynamic>? equipment,
    bool? isSaving,
    String? errorMessage,
    String? brand,
    String? model,
    String? price,
    String? purchaseDate,
    bool? isDefault,
    String? categoryType1,
    String? categoryType2,
  });
}

/// Rod-specific edit state
class RodEditState extends EquipmentEditState {
  final String length;
  final String lengthUnit;
  final String sections;
  final String jointType;
  final String material;
  final String hardness;
  final String rodAction;
  final String weightRange;

  const RodEditState({
    required super.type,
    super.equipment,
    super.isSaving,
    super.errorMessage,
    super.brand,
    super.model,
    super.price,
    super.purchaseDate,
    super.isDefault,
    super.categoryType1,
    super.categoryType2,
    this.length = '',
    this.lengthUnit = 'm',
    this.sections = '',
    this.jointType = '',
    this.material = '',
    this.hardness = '',
    this.rodAction = '',
    this.weightRange = '',
  });

  RodEditState copyWith({
    String? type,
    Map<String, dynamic>? equipment,
    bool? isSaving,
    String? errorMessage,
    String? brand,
    String? model,
    String? price,
    String? purchaseDate,
    bool? isDefault,
    String? categoryType1,
    String? categoryType2,
    String? length,
    String? lengthUnit,
    String? sections,
    String? jointType,
    String? material,
    String? hardness,
    String? rodAction,
    String? weightRange,
  }) {
    return RodEditState(
      type: type ?? this.type,
      equipment: equipment ?? this.equipment,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      price: price ?? this.price,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      isDefault: isDefault ?? this.isDefault,
      categoryType1: categoryType1 ?? this.categoryType1,
      categoryType2: categoryType2 ?? this.categoryType2,
      length: length ?? this.length,
      lengthUnit: lengthUnit ?? this.lengthUnit,
      sections: sections ?? this.sections,
      jointType: jointType ?? this.jointType,
      material: material ?? this.material,
      hardness: hardness ?? this.hardness,
      rodAction: rodAction ?? this.rodAction,
      weightRange: weightRange ?? this.weightRange,
    );
  }

  @override
  RodEditState withUpdates({
    String? type,
    Map<String, dynamic>? equipment,
    bool? isSaving,
    String? errorMessage,
    String? brand,
    String? model,
    String? price,
    String? purchaseDate,
    bool? isDefault,
    String? categoryType1,
    String? categoryType2,
    String? length,
    String? lengthUnit,
    String? sections,
    String? jointType,
    String? material,
    String? hardness,
    String? rodAction,
    String? weightRange,
  }) {
    return copyWith(
      type: type,
      equipment: equipment,
      isSaving: isSaving,
      errorMessage: errorMessage,
      brand: brand,
      model: model,
      price: price,
      purchaseDate: purchaseDate,
      isDefault: isDefault,
      categoryType1: categoryType1,
      categoryType2: categoryType2,
      length: length ?? this.length,
      lengthUnit: lengthUnit ?? this.lengthUnit,
      sections: sections ?? this.sections,
      jointType: jointType ?? this.jointType,
      material: material ?? this.material,
      hardness: hardness ?? this.hardness,
      rodAction: rodAction ?? this.rodAction,
      weightRange: weightRange ?? this.weightRange,
    );
  }
}

/// Reel-specific edit state
class ReelEditState extends EquipmentEditState {
  final String reelBearings;
  final String reelRatio;
  final String reelCapacity;
  final String reelBrakeType;
  final String reelWeight;
  final String reelWeightUnit;
  final String reelLine;
  final String reelLineNumber;
  final String reelLineLength;
  final String reelLineLengthUnit;
  final String reelLineDate;

  const ReelEditState({
    required super.type,
    super.equipment,
    super.isSaving,
    super.errorMessage,
    super.brand,
    super.model,
    super.price,
    super.purchaseDate,
    super.isDefault,
    super.categoryType1,
    super.categoryType2,
    this.reelBearings = '',
    this.reelRatio = '',
    this.reelCapacity = '',
    this.reelBrakeType = '',
    this.reelWeight = '',
    this.reelWeightUnit = 'g',
    this.reelLine = '',
    this.reelLineNumber = '',
    this.reelLineLength = '',
    this.reelLineLengthUnit = 'm',
    this.reelLineDate = '',
  });

  ReelEditState copyWith({
    String? type,
    Map<String, dynamic>? equipment,
    bool? isSaving,
    String? errorMessage,
    String? brand,
    String? model,
    String? price,
    String? purchaseDate,
    bool? isDefault,
    String? categoryType1,
    String? categoryType2,
    String? reelBearings,
    String? reelRatio,
    String? reelCapacity,
    String? reelBrakeType,
    String? reelWeight,
    String? reelWeightUnit,
    String? reelLine,
    String? reelLineNumber,
    String? reelLineLength,
    String? reelLineLengthUnit,
    String? reelLineDate,
  }) {
    return ReelEditState(
      type: type ?? this.type,
      equipment: equipment ?? this.equipment,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      price: price ?? this.price,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      isDefault: isDefault ?? this.isDefault,
      categoryType1: categoryType1 ?? this.categoryType1,
      categoryType2: categoryType2 ?? this.categoryType2,
      reelBearings: reelBearings ?? this.reelBearings,
      reelRatio: reelRatio ?? this.reelRatio,
      reelCapacity: reelCapacity ?? this.reelCapacity,
      reelBrakeType: reelBrakeType ?? this.reelBrakeType,
      reelWeight: reelWeight ?? this.reelWeight,
      reelWeightUnit: reelWeightUnit ?? this.reelWeightUnit,
      reelLine: reelLine ?? this.reelLine,
      reelLineNumber: reelLineNumber ?? this.reelLineNumber,
      reelLineLength: reelLineLength ?? this.reelLineLength,
      reelLineLengthUnit: reelLineLengthUnit ?? this.reelLineLengthUnit,
      reelLineDate: reelLineDate ?? this.reelLineDate,
    );
  }

  @override
  ReelEditState withUpdates({
    String? type,
    Map<String, dynamic>? equipment,
    bool? isSaving,
    String? errorMessage,
    String? brand,
    String? model,
    String? price,
    String? purchaseDate,
    bool? isDefault,
    String? categoryType1,
    String? categoryType2,
    String? reelBearings,
    String? reelRatio,
    String? reelCapacity,
    String? reelBrakeType,
    String? reelWeight,
    String? reelWeightUnit,
    String? reelLine,
    String? reelLineNumber,
    String? reelLineLength,
    String? reelLineLengthUnit,
    String? reelLineDate,
  }) {
    return copyWith(
      type: type,
      equipment: equipment,
      isSaving: isSaving,
      errorMessage: errorMessage,
      brand: brand,
      model: model,
      price: price,
      purchaseDate: purchaseDate,
      isDefault: isDefault,
      categoryType1: categoryType1,
      categoryType2: categoryType2,
      reelBearings: reelBearings ?? this.reelBearings,
      reelRatio: reelRatio ?? this.reelRatio,
      reelCapacity: reelCapacity ?? this.reelCapacity,
      reelBrakeType: reelBrakeType ?? this.reelBrakeType,
      reelWeight: reelWeight ?? this.reelWeight,
      reelWeightUnit: reelWeightUnit ?? this.reelWeightUnit,
      reelLine: reelLine ?? this.reelLine,
      reelLineNumber: reelLineNumber ?? this.reelLineNumber,
      reelLineLength: reelLineLength ?? this.reelLineLength,
      reelLineLengthUnit: reelLineLengthUnit ?? this.reelLineLengthUnit,
      reelLineDate: reelLineDate ?? this.reelLineDate,
    );
  }
}

/// Lure-specific edit state
class LureEditState extends EquipmentEditState {
  final String lureType;
  final String lureWeight;
  final String lureWeightUnit;
  final String lureSize;
  final String lureSizeUnit;
  final String lureColor;
  final String lureQuantity;
  final String lureQuantityUnit;

  const LureEditState({
    required super.type,
    super.equipment,
    super.isSaving,
    super.errorMessage,
    super.brand,
    super.model,
    super.price,
    super.purchaseDate,
    super.isDefault,
    super.categoryType1,
    super.categoryType2,
    this.lureType = '',
    this.lureWeight = '',
    this.lureWeightUnit = 'g',
    this.lureSize = '',
    this.lureSizeUnit = 'cm',
    this.lureColor = '',
    this.lureQuantity = '',
    this.lureQuantityUnit = 'pcs',
  });

  LureEditState copyWith({
    String? type,
    Map<String, dynamic>? equipment,
    bool? isSaving,
    String? errorMessage,
    String? brand,
    String? model,
    String? price,
    String? purchaseDate,
    bool? isDefault,
    String? categoryType1,
    String? categoryType2,
    String? lureType,
    String? lureWeight,
    String? lureWeightUnit,
    String? lureSize,
    String? lureSizeUnit,
    String? lureColor,
    String? lureQuantity,
    String? lureQuantityUnit,
  }) {
    return LureEditState(
      type: type ?? this.type,
      equipment: equipment ?? this.equipment,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      price: price ?? this.price,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      isDefault: isDefault ?? this.isDefault,
      categoryType1: categoryType1 ?? this.categoryType1,
      categoryType2: categoryType2 ?? this.categoryType2,
      lureType: lureType ?? this.lureType,
      lureWeight: lureWeight ?? this.lureWeight,
      lureWeightUnit: lureWeightUnit ?? this.lureWeightUnit,
      lureSize: lureSize ?? this.lureSize,
      lureSizeUnit: lureSizeUnit ?? this.lureSizeUnit,
      lureColor: lureColor ?? this.lureColor,
      lureQuantity: lureQuantity ?? this.lureQuantity,
      lureQuantityUnit: lureQuantityUnit ?? this.lureQuantityUnit,
    );
  }

  @override
  LureEditState withUpdates({
    String? type,
    Map<String, dynamic>? equipment,
    bool? isSaving,
    String? errorMessage,
    String? brand,
    String? model,
    String? price,
    String? purchaseDate,
    bool? isDefault,
    String? categoryType1,
    String? categoryType2,
    String? lureType,
    String? lureWeight,
    String? lureWeightUnit,
    String? lureSize,
    String? lureSizeUnit,
    String? lureColor,
    String? lureQuantity,
    String? lureQuantityUnit,
  }) {
    return copyWith(
      type: type,
      equipment: equipment,
      isSaving: isSaving,
      errorMessage: errorMessage,
      brand: brand,
      model: model,
      price: price,
      purchaseDate: purchaseDate,
      isDefault: isDefault,
      categoryType1: categoryType1,
      categoryType2: categoryType2,
      lureType: lureType ?? this.lureType,
      lureWeight: lureWeight ?? this.lureWeight,
      lureWeightUnit: lureWeightUnit ?? this.lureWeightUnit,
      lureSize: lureSize ?? this.lureSize,
      lureSizeUnit: lureSizeUnit ?? this.lureSizeUnit,
      lureColor: lureColor ?? this.lureColor,
      lureQuantity: lureQuantity ?? this.lureQuantity,
      lureQuantityUnit: lureQuantityUnit ?? this.lureQuantityUnit,
    );
  }
}
