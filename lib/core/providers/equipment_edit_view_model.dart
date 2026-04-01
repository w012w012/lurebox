import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/strings.dart';
import '../constants/price_ranges.dart';
import '../di/di.dart';
import '../models/equipment.dart';
import '../services/equipment_service.dart';

class EquipmentEditState {
  final String type;
  final Map<String, dynamic>? equipment;
  final bool isSaving;
  final String? errorMessage;

  // Common fields
  final String brand;
  final String model;
  final String price;
  final String purchaseDate;
  final bool isDefault;

  // Category fields
  final String categoryType1;
  final String categoryType2;

  // Rod fields
  final String length;
  final String lengthUnit;
  final String sections;
  final String material;
  final String hardness;
  final String rodAction;
  final String weightRange;

  // Reel fields
  final String reelBearings;
  final String reelRatio;
  final String reelCapacity;
  final String reelBrakeType;

  // Reel line fields
  final String reelLine;
  final String reelLineNumber;
  final String reelLineLength;
  final String reelLineLengthUnit;
  final String reelLineDate;

  // Lure fields
  final String lureType;
  final String lureWeight;
  final String lureWeightUnit;
  final String lureSize;
  final String lureSizeUnit;
  final String lureColor;
  final String lureQuantity;
  final String lureQuantityUnit;

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
    this.length = '',
    this.lengthUnit = 'm',
    this.sections = '',
    this.material = '',
    this.hardness = '',
    this.rodAction = '',
    this.weightRange = '',
    this.reelBearings = '',
    this.reelRatio = '',
    this.reelCapacity = '',
    this.reelBrakeType = '',
    this.reelLine = '',
    this.reelLineNumber = '',
    this.reelLineLength = '',
    this.reelLineLengthUnit = 'm',
    this.reelLineDate = '',
    this.lureType = '',
    this.lureWeight = '',
    this.lureWeightUnit = 'g',
    this.lureSize = '',
    this.lureSizeUnit = 'cm',
    this.lureColor = '',
    this.lureQuantity = '',
    this.lureQuantityUnit = '',
  });

  bool get isEdit => equipment != null;

  EquipmentEditState copyWith({
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
    String? material,
    String? hardness,
    String? rodAction,
    String? weightRange,
    String? reelBearings,
    String? reelRatio,
    String? reelCapacity,
    String? reelBrakeType,
    String? reelLine,
    String? reelLineNumber,
    String? reelLineLength,
    String? reelLineLengthUnit,
    String? reelLineDate,
    String? lureType,
    String? lureWeight,
    String? lureWeightUnit,
    String? lureSize,
    String? lureSizeUnit,
    String? lureColor,
    String? lureQuantity,
    String? lureQuantityUnit,
  }) {
    return EquipmentEditState(
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
      material: material ?? this.material,
      hardness: hardness ?? this.hardness,
      rodAction: rodAction ?? this.rodAction,
      weightRange: weightRange ?? this.weightRange,
      reelBearings: reelBearings ?? this.reelBearings,
      reelRatio: reelRatio ?? this.reelRatio,
      reelCapacity: reelCapacity ?? this.reelCapacity,
      reelBrakeType: reelBrakeType ?? this.reelBrakeType,
      reelLine: reelLine ?? this.reelLine,
      reelLineNumber: reelLineNumber ?? this.reelLineNumber,
      reelLineLength: reelLineLength ?? this.reelLineLength,
      reelLineLengthUnit: reelLineLengthUnit ?? this.reelLineLengthUnit,
      reelLineDate: reelLineDate ?? this.reelLineDate,
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

class EquipmentEditViewModel extends StateNotifier<EquipmentEditState> {
  final EquipmentService _equipmentService;

  EquipmentEditViewModel(
    this._equipmentService,
    String type,
    Map<String, dynamic>? equipment,
  ) : super(EquipmentEditState(type: type, equipment: equipment)) {
    if (equipment != null) {
      _loadData();
    }
  }

  void loadDataFromMap(Map<String, dynamic> equipment) {
    state = state.copyWith(equipment: equipment);
    _loadData();
  }

  dynamic _getValue(Map<String, dynamic> map, String key) {
    if (map.containsKey(key)) return map[key];
    final altKey1 = key.replaceAll('_', ' ');
    if (map.containsKey(altKey1)) return map[altKey1];
    final altKey2 = key.replaceAll(' ', '_');
    if (map.containsKey(altKey2)) return map[altKey2];
    return null;
  }

  void _loadData() {
    final e = state.equipment!;
    String categoryType1 = '';
    String categoryType2 = '';

    final category = _getValue(e, 'category')?.toString();
    if (category != null && category.contains('|')) {
      final parts = category.split('|');
      categoryType1 = parts[0];
      categoryType2 = parts.length > 1 ? parts[1] : '';
    } else {
      categoryType1 = '';
      categoryType2 = category ?? '';
    }

    state = state.copyWith(
      brand: _getValue(e, 'brand')?.toString() ?? '',
      model: _getValue(e, 'model')?.toString() ?? '',
      price: _getValue(e, 'price')?.toString() ?? '',
      purchaseDate: _getValue(e, 'purchase_date')?.toString() ?? '',
      isDefault: _getValue(e, 'is_default') == 1,
      categoryType1: categoryType1,
      categoryType2: categoryType2,
      length: _getValue(e, 'length')?.toString() ?? '',
      lengthUnit: _getValue(e, 'length_unit')?.toString() ?? 'm',
      sections: _getValue(e, 'sections')?.toString() ?? '',
      material: _getValue(e, 'material')?.toString() ?? '',
      hardness: _getValue(e, 'hardness')?.toString() ?? '',
      rodAction: _getValue(e, 'rod_action')?.toString() ?? '',
      weightRange: _getValue(e, 'weight_range')?.toString() ?? '',
      reelBearings: _getValue(e, 'reel_bearings')?.toString() ?? '',
      reelRatio: _getValue(e, 'reel_ratio')?.toString() ?? '',
      reelCapacity: _getValue(e, 'reel_capacity')?.toString() ?? '',
      reelBrakeType: _getValue(e, 'reel_brake_type')?.toString() ?? '',
      reelLine: _getValue(e, 'reel_line')?.toString() ?? '',
      reelLineNumber: _getValue(e, 'reel_line_number')?.toString() ?? '',
      reelLineLength: _getValue(e, 'reel_line_length')?.toString() ?? '',
      reelLineLengthUnit:
          _getValue(e, 'reel_line_length_unit')?.toString() ?? 'm',
      reelLineDate: _getValue(e, 'reel_line_date')?.toString() ?? '',
      lureType: _getValue(e, 'lure_type')?.toString() ?? '',
      lureWeight: _getValue(e, 'lure_weight')?.toString() ?? '',
      lureWeightUnit: _getValue(e, 'lure_weight_unit')?.toString() ?? 'g',
      lureSize: _getValue(e, 'lure_size')?.toString() ?? '',
      lureSizeUnit: _getValue(e, 'lure_size_unit')?.toString() ?? 'cm',
      lureColor: _getValue(e, 'lure_color')?.toString() ?? '',
      lureQuantity: _getValue(e, 'lure_quantity')?.toString() ?? '',
      lureQuantityUnit: _getValue(e, 'lure_quantity_unit')?.toString() ?? '',
    );
  }

  void updateBrand(String value) => state = state.copyWith(brand: value);
  void updateModel(String value) => state = state.copyWith(model: value);
  void updatePrice(String value) => state = state.copyWith(price: value);
  void updatePurchaseDate(String value) =>
      state = state.copyWith(purchaseDate: value);
  void updateIsDefault(bool value) => state = state.copyWith(isDefault: value);
  void updateCategoryType1(String value) =>
      state = state.copyWith(categoryType1: value);
  void updateCategoryType2(String value) =>
      state = state.copyWith(categoryType2: value);

  void updateLength(String value) => state = state.copyWith(length: value);
  void updateLengthUnit(String value) =>
      state = state.copyWith(lengthUnit: value);
  void updateSections(String value) => state = state.copyWith(sections: value);
  void updateMaterial(String value) => state = state.copyWith(material: value);
  void updateHardness(String value) => state = state.copyWith(hardness: value);
  void updateRodAction(String value) =>
      state = state.copyWith(rodAction: value);
  void updateWeightRange(String value) =>
      state = state.copyWith(weightRange: value);

  void updateReelBearings(String value) =>
      state = state.copyWith(reelBearings: value);
  void updateReelRatio(String value) =>
      state = state.copyWith(reelRatio: value);
  void updateReelCapacity(String value) =>
      state = state.copyWith(reelCapacity: value);
  void updateReelBrakeType(String value) =>
      state = state.copyWith(reelBrakeType: value);

  void updateReelLine(String value) => state = state.copyWith(reelLine: value);
  void updateReelLineNumber(String value) =>
      state = state.copyWith(reelLineNumber: value);
  void updateReelLineLength(String value) =>
      state = state.copyWith(reelLineLength: value);
  void updateReelLineLengthUnit(String value) =>
      state = state.copyWith(reelLineLengthUnit: value);
  void updateReelLineDate(String value) =>
      state = state.copyWith(reelLineDate: value);

  void updateLureType(String value) => state = state.copyWith(lureType: value);
  void updateLureWeight(String value) =>
      state = state.copyWith(lureWeight: value);
  void updateLureWeightUnit(String value) =>
      state = state.copyWith(lureWeightUnit: value);
  void updateLureSize(String value) => state = state.copyWith(lureSize: value);
  void updateLureSizeUnit(String value) =>
      state = state.copyWith(lureSizeUnit: value);
  void updateLureColor(String value) =>
      state = state.copyWith(lureColor: value);
  void updateLureQuantity(String value) =>
      state = state.copyWith(lureQuantity: value);
  void updateLureQuantityUnit(String? value) =>
      state = state.copyWith(lureQuantityUnit: value ?? '');

  String? validatePrice(AppStrings strings) {
    if (state.price.isNotEmpty) {
      final price = double.tryParse(state.price);
      if (price == null || price < 0) return strings.invalidPrice;
      if (price > PriceRanges.maxPrice) return strings.priceTooHigh;
    }
    return null;
  }

  Future<bool> save() async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      String? category;
      final type1 = state.categoryType1.trim();
      final type2 = state.categoryType2.trim();
      if (type1.isNotEmpty && type2.isNotEmpty) {
        category = '$type1|$type2';
      } else if (type1.isNotEmpty) {
        category = type1;
      } else if (type2.isNotEmpty) {
        category = type2;
      }

      final data = <String, dynamic>{
        'type': state.type,
        'brand': state.brand.trim(),
        'model': state.model.trim(),
        'is_default': state.isDefault ? 1 : 0,
        'category': category,
      };

      if (state.price.isNotEmpty) {
        data['price'] = double.tryParse(state.price);
      }

      if (state.purchaseDate.isNotEmpty) {
        data['purchase_date'] = state.purchaseDate;
      }

      if (state.type == 'rod') {
        if (state.length.isNotEmpty) {
          data['length'] = state.length.trim();
          data['length_unit'] = state.lengthUnit;
        }
        if (state.sections.isNotEmpty) {
          data['sections'] = int.tryParse(state.sections);
        }
        if (state.material.isNotEmpty) {
          data['material'] = state.material.trim();
        }
        if (state.hardness.isNotEmpty) {
          data['hardness'] = state.hardness.trim();
        }
        if (state.rodAction.isNotEmpty) {
          data['rod_action'] = state.rodAction.trim();
        }
        if (state.weightRange.isNotEmpty) {
          data['weight_range'] = state.weightRange.trim();
        }
      }

      if (state.type == 'reel') {
        if (state.reelBearings.isNotEmpty) {
          data['reel_bearings'] = int.tryParse(state.reelBearings);
        }
        if (state.reelRatio.isNotEmpty) {
          data['reel_ratio'] = state.reelRatio.trim();
        }
        if (state.reelCapacity.isNotEmpty) {
          data['reel_capacity'] = state.reelCapacity.trim();
        }
        if (state.reelBrakeType.isNotEmpty) {
          data['reel_brake_type'] = state.reelBrakeType.trim();
        }
        if (state.reelLine.isNotEmpty) {
          data['reel_line'] = state.reelLine.trim();
        }
        if (state.reelLineNumber.isNotEmpty) {
          data['reel_line_number'] = state.reelLineNumber.trim();
        }
        if (state.reelLineLength.isNotEmpty) {
          data['reel_line_length'] = state.reelLineLength.trim();
          data['reel_line_length_unit'] = state.reelLineLengthUnit;
        }
        if (state.reelLineDate.isNotEmpty) {
          data['reel_line_date'] = state.reelLineDate.trim();
        }
      }

      if (state.type == 'lure') {
        if (state.lureType.isNotEmpty) {
          data['lure_type'] = state.lureType.trim();
        }
        if (state.lureWeight.isNotEmpty) {
          data['lure_weight'] = state.lureWeight.trim();
          data['lure_weight_unit'] = state.lureWeightUnit;
        }
        if (state.lureSize.isNotEmpty) {
          data['lure_size'] = state.lureSize.trim();
          data['lure_size_unit'] = state.lureSizeUnit;
        }
        if (state.lureColor.isNotEmpty) {
          data['lure_color'] = state.lureColor.trim();
        }
        if (state.lureQuantity.isNotEmpty) {
          data['lure_quantity'] = int.tryParse(state.lureQuantity);
        }
        if (state.lureQuantityUnit.isNotEmpty) {
          data['lure_quantity_unit'] = state.lureQuantityUnit.trim();
        }
      }

      int equipmentId;
      if (state.equipment != null) {
        equipmentId = state.equipment!['id'] as int;
        final equipment = Equipment.fromMap({
          ...data,
          'id': equipmentId,
          'created_at': state.equipment!['created_at'] ??
              DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        await _equipmentService.update(equipment);
      } else {
        final equipment = Equipment.fromMap({
          ...data,
          'id': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        equipmentId = await _equipmentService.create(equipment);
      }

      if (state.isDefault) {
        await _equipmentService.setDefaultEquipment(equipmentId, state.type);
      }

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      debugPrint('保存装备失败: $e');
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }
}

final equipmentEditViewModelProvider = StateNotifierProvider.autoDispose.family<
    EquipmentEditViewModel,
    EquipmentEditState,
    ({String type, Map<String, dynamic>? equipment})>(
  (ref, params) => EquipmentEditViewModel(
    ref.read(equipmentServiceProvider),
    params.type,
    params.equipment,
  ),
);
