import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/strings.dart';
import '../constants/price_ranges.dart';
import '../di/di.dart';
import '../models/equipment.dart';
import '../services/equipment_service.dart';
import 'equipment_edit_state.dart';

// =============================================================================
// State Classes
// =============================================================================

/// Unified state for equipment editing - maintains backwards compatibility.
/// Contains all fields for all equipment types.
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

  // Category fields (used by rod and reel)
  final String categoryType1;
  final String categoryType2;

  // Rod fields
  final String length;
  final String lengthUnit;
  final String sections;
  final String jointType;
  final String material;
  final String hardness;
  final String rodAction;
  final String weightRange;

  // Reel fields
  final String reelBearings;
  final String reelRatio;
  final String reelCapacity;
  final String reelBrakeType;
  final String reelWeight;
  final String reelWeightUnit;

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
    this.jointType = '',
    this.material = '',
    this.hardness = '',
    this.rodAction = '',
    this.weightRange = '',
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
    String? jointType,
    String? material,
    String? hardness,
    String? rodAction,
    String? weightRange,
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
      jointType: jointType ?? this.jointType,
      material: material ?? this.material,
      hardness: hardness ?? this.hardness,
      rodAction: rodAction ?? this.rodAction,
      weightRange: weightRange ?? this.weightRange,
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

// =============================================================================
// Base Notifier (Handles Shared Fields)
// =============================================================================

class _BaseEquipmentEditNotifier {
  final EquipmentService _equipmentService;
  EquipmentEditStateBase _state;
  final String type;

  _BaseEquipmentEditNotifier(
    this._equipmentService,
    this.type, [
    Map<String, dynamic>? equipment,
  ]) : _state = _createInitialState(type, equipment);

  static EquipmentEditStateBase _createInitialState(
      String type, Map<String, dynamic>? equipment) {
    switch (type) {
      case 'rod':
        return RodEditState(type: type, equipment: equipment);
      case 'reel':
        return ReelEditState(type: type, equipment: equipment);
      case 'lure':
        return LureEditState(type: type, equipment: equipment);
      default:
        return RodEditState(type: type, equipment: equipment);
    }
  }

  EquipmentEditStateBase get state => _state;

  void _updateState(EquipmentEditStateBase newState) {
    _state = newState;
  }

  dynamic _getValue(Map<String, dynamic> map, String key) {
    if (map.containsKey(key)) return map[key];
    final altKey1 = key.replaceAll('_', ' ');
    if (map.containsKey(altKey1)) return map[altKey1];
    final altKey2 = key.replaceAll(' ', '_');
    if (map.containsKey(altKey2)) return map[altKey2];
    return null;
  }

  void loadDataFromMap(Map<String, dynamic> equipment) {
    // Guard against null - can happen on first build before data is loaded
    if (equipment == null) return;

    debugPrint(
        '[loadDataFromMap] START - equipment.length: ${equipment['length']}');

    // Load common fields from equipment map
    final brandValue = _getValue(equipment, 'brand')?.toString() ?? '';
    final modelValue = _getValue(equipment, 'model')?.toString() ?? '';
    final priceValue = _getValue(equipment, 'price')?.toString() ?? '';
    final purchaseDateValue =
        _getValue(equipment, 'purchase_date')?.toString() ?? '';
    final isDefaultValue = _getValue(equipment, 'is_default');

    // Load type-specific fields first
    _loadData(equipment);

    // Then overlay basic fields
    _state = _state.withUpdates(
      equipment: equipment,
      brand: brandValue,
      model: modelValue,
      price: priceValue,
      purchaseDate: purchaseDateValue,
      isDefault: isDefaultValue == 1,
    );
  }

  void _loadData(Map<String, dynamic> e) {
    // Implemented by subclasses
  }

  // Shared update methods
  void updateBrand(String value) =>
      _updateState(_state.withUpdates(brand: value));
  void updateModel(String value) =>
      _updateState(_state.withUpdates(model: value));
  void updatePrice(String value) =>
      _updateState(_state.withUpdates(price: value));
  void updatePurchaseDate(String value) =>
      _updateState(_state.withUpdates(purchaseDate: value));
  void updateIsDefault(bool value) =>
      _updateState(_state.withUpdates(isDefault: value));

  String? validatePrice(AppStrings strings) {
    if (_state.price.isNotEmpty) {
      final price = double.tryParse(_state.price);
      if (price == null || price < 0) return strings.invalidPrice;
      if (price > PriceRanges.maxPrice) return strings.priceTooHigh;
    }
    return null;
  }

  // Stub implementations for type-specific methods - overridden by subclasses
  void updateCategoryType1(String value) {}
  void updateCategoryType2(String value) {}
  void updateLength(String value) {}
  void updateLengthUnit(String value) {}
  void updateSections(String value) {}
  void updateJointType(String value) {}
  void updateMaterial(String value) {}
  void updateHardness(String value) {}
  void updateRodAction(String value) {}
  void updateWeightRange(String value) {}
  void updateReelBearings(String value) {}
  void updateReelRatio(String value) {}
  void updateReelCapacity(String value) {}
  void updateReelBrakeType(String value) {}
  void updateReelWeight(String value) {}
  void updateReelWeightUnit(String value) {}
  void updateReelLine(String value) {}
  void updateReelLineNumber(String value) {}
  void updateReelLineLength(String value) {}
  void updateReelLineLengthUnit(String value) {}
  void updateReelLineDate(String value) {}
  void updateLureType(String value) {}
  void updateLureWeight(String value) {}
  void updateLureWeightUnit(String value) {}
  void updateLureSize(String value) {}
  void updateLureSizeUnit(String value) {}
  void updateLureColor(String value) {}
  void updateLureQuantity(String value) {}
  void updateLureQuantityUnit(String? value) {}

  Future<bool> save() async {
    _updateState(_state.withUpdates(isSaving: true, errorMessage: null));

    try {
      String? category;
      final type1 = _state.categoryType1.trim();
      final type2 = _state.categoryType2.trim();
      if (type1.isNotEmpty && type2.isNotEmpty) {
        category = '$type1|$type2';
      } else if (type1.isNotEmpty) {
        category = type1;
      } else if (type2.isNotEmpty) {
        category = type2;
      }

      final data = <String, dynamic>{
        'type': _state.type,
        'brand': _state.brand.trim(),
        'model': _state.model.trim(),
        'is_default': _state.isDefault ? 1 : 0,
        'category': category,
      };

      if (_state.price.isNotEmpty) {
        data['price'] = double.tryParse(_state.price);
      }

      if (_state.purchaseDate.isNotEmpty) {
        data['purchase_date'] = _state.purchaseDate;
      }

      _buildTypeSpecificData(data);

      int equipmentId;
      if (_state.equipment != null) {
        equipmentId = _state.equipment!['id'] as int;
        final equipment = Equipment.fromMap({
          ...data,
          'id': equipmentId,
          'created_at': _state.equipment!['created_at'] ??
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

      if (_state.isDefault) {
        await _equipmentService.setDefaultEquipment(equipmentId, _state.type);
      }

      _updateState(_state.withUpdates(isSaving: false));
      return true;
    } catch (e) {
      debugPrint('保存装备失败: $e');
      _updateState(
          _state.withUpdates(isSaving: false, errorMessage: e.toString()));
      return false;
    }
  }

  void _buildTypeSpecificData(Map<String, dynamic> data) {
    // Implemented by subclasses
  }
}

// =============================================================================
// Rod Notifier
// =============================================================================

class RodEditNotifier extends _BaseEquipmentEditNotifier {
  RodEditNotifier(
    EquipmentService equipmentService,
    String type,
    Map<String, dynamic>? equipment,
  ) : super(equipmentService, type, equipment);

  RodEditState get rodState => _state as RodEditState;

  @override
  void _loadData(Map<String, dynamic> e) {
    String categoryType1 = '';
    String categoryType2 = '';

    debugPrint('[_loadData Rod] e.length: ${e['length']}');
    debugPrint('[_loadData Rod] _getValue length: ${_getValue(e, 'length')}');

    final category = _getValue(e, 'category')?.toString();
    if (category != null && category.contains('|')) {
      final parts = category.split('|');
      categoryType1 = parts[0];
      categoryType2 = parts.length > 1 ? parts[1] : '';
    } else {
      categoryType1 = '';
      categoryType2 = category ?? '';
    }

    final lengthValue = _getValue(e, 'length')?.toString() ?? '';
    debugPrint('[_loadData Rod] lengthValue to set: $lengthValue');

    _updateState(rodState.copyWith(
      categoryType1: categoryType1,
      categoryType2: categoryType2,
      length: lengthValue,
      lengthUnit: _getValue(e, 'length_unit')?.toString() ?? 'm',
      sections: _getValue(e, 'sections')?.toString() ?? '',
      jointType: _getValue(e, 'joint_type')?.toString() ?? '',
      material: _getValue(e, 'material')?.toString() ?? '',
      hardness: _getValue(e, 'hardness')?.toString() ?? '',
      rodAction: _getValue(e, 'rod_action')?.toString() ?? '',
      weightRange: _getValue(e, 'weight_range')?.toString() ?? '',
    ));

    debugPrint(
        '[_loadData Rod] after copyWith, rodState.length: ${rodState.length}');
  }

  @override
  void updateCategoryType1(String value) =>
      _updateState(rodState.copyWith(categoryType1: value));
  @override
  void updateCategoryType2(String value) =>
      _updateState(rodState.copyWith(categoryType2: value));
  @override
  void updateLength(String value) =>
      _updateState(rodState.copyWith(length: value));
  @override
  void updateLengthUnit(String value) =>
      _updateState(rodState.copyWith(lengthUnit: value));
  @override
  void updateSections(String value) =>
      _updateState(rodState.copyWith(sections: value));
  @override
  void updateJointType(String value) =>
      _updateState(rodState.copyWith(jointType: value));
  @override
  void updateMaterial(String value) =>
      _updateState(rodState.copyWith(material: value));
  @override
  void updateHardness(String value) =>
      _updateState(rodState.copyWith(hardness: value));
  @override
  void updateRodAction(String value) =>
      _updateState(rodState.copyWith(rodAction: value));
  @override
  void updateWeightRange(String value) =>
      _updateState(rodState.copyWith(weightRange: value));

  @override
  void _buildTypeSpecificData(Map<String, dynamic> data) {
    if (rodState.length.isNotEmpty) {
      data['length'] = rodState.length.trim();
      data['length_unit'] = rodState.lengthUnit;
    }
    if (rodState.sections.isNotEmpty) {
      data['sections'] = rodState.sections.trim();
    }
    if (rodState.jointType.isNotEmpty) {
      data['joint_type'] = rodState.jointType.trim();
    }
    if (rodState.material.isNotEmpty) {
      data['material'] = rodState.material.trim();
    }
    if (rodState.hardness.isNotEmpty) {
      data['hardness'] = rodState.hardness.trim();
    }
    if (rodState.rodAction.isNotEmpty) {
      data['rod_action'] = rodState.rodAction.trim();
    }
    if (rodState.weightRange.isNotEmpty) {
      data['weight_range'] = rodState.weightRange.trim();
    }
  }
}

// =============================================================================
// Reel Notifier
// =============================================================================

class ReelEditNotifier extends _BaseEquipmentEditNotifier {
  ReelEditNotifier(
    EquipmentService equipmentService,
    String type,
    Map<String, dynamic>? equipment,
  ) : super(equipmentService, type, equipment);

  ReelEditState get reelState => _state as ReelEditState;

  @override
  void _loadData(Map<String, dynamic> e) {
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

    _updateState(reelState.copyWith(
      categoryType1: categoryType1,
      categoryType2: categoryType2,
      reelBearings: _getValue(e, 'reel_bearings')?.toString() ?? '',
      reelRatio: _getValue(e, 'reel_ratio')?.toString() ?? '',
      reelCapacity: _getValue(e, 'reel_capacity')?.toString() ?? '',
      reelBrakeType: _getValue(e, 'reel_brake_type')?.toString() ?? '',
      reelWeight: _getValue(e, 'reel_weight')?.toString() ?? '',
      reelWeightUnit: _getValue(e, 'reel_weight_unit')?.toString() ?? 'g',
      reelLine: _getValue(e, 'reel_line')?.toString() ?? '',
      reelLineNumber: _getValue(e, 'reel_line_number')?.toString() ?? '',
      reelLineLength: _getValue(e, 'reel_line_length')?.toString() ?? '',
      reelLineLengthUnit:
          _getValue(e, 'reel_line_length_unit')?.toString() ?? 'm',
      reelLineDate: _getValue(e, 'reel_line_date')?.toString() ?? '',
    ));
  }

  @override
  void updateCategoryType1(String value) =>
      _updateState(reelState.copyWith(categoryType1: value));
  @override
  void updateCategoryType2(String value) =>
      _updateState(reelState.copyWith(categoryType2: value));
  @override
  void updateReelBearings(String value) =>
      _updateState(reelState.copyWith(reelBearings: value));
  @override
  void updateReelRatio(String value) =>
      _updateState(reelState.copyWith(reelRatio: value));
  @override
  void updateReelCapacity(String value) =>
      _updateState(reelState.copyWith(reelCapacity: value));
  @override
  void updateReelBrakeType(String value) =>
      _updateState(reelState.copyWith(reelBrakeType: value));
  @override
  void updateReelWeight(String value) =>
      _updateState(reelState.copyWith(reelWeight: value));
  @override
  void updateReelWeightUnit(String value) =>
      _updateState(reelState.copyWith(reelWeightUnit: value));
  @override
  void updateReelLine(String value) =>
      _updateState(reelState.copyWith(reelLine: value));
  @override
  void updateReelLineNumber(String value) =>
      _updateState(reelState.copyWith(reelLineNumber: value));
  @override
  void updateReelLineLength(String value) =>
      _updateState(reelState.copyWith(reelLineLength: value));
  @override
  void updateReelLineLengthUnit(String value) =>
      _updateState(reelState.copyWith(reelLineLengthUnit: value));
  @override
  void updateReelLineDate(String value) =>
      _updateState(reelState.copyWith(reelLineDate: value));

  @override
  void _buildTypeSpecificData(Map<String, dynamic> data) {
    if (reelState.reelBearings.isNotEmpty) {
      data['reel_bearings'] = int.tryParse(reelState.reelBearings);
    }
    if (reelState.reelRatio.isNotEmpty) {
      data['reel_ratio'] = reelState.reelRatio.trim();
    }
    if (reelState.reelCapacity.isNotEmpty) {
      data['reel_capacity'] = reelState.reelCapacity.trim();
    }
    if (reelState.reelBrakeType.isNotEmpty) {
      data['reel_brake_type'] = reelState.reelBrakeType.trim();
    }
    if (reelState.reelWeight.isNotEmpty) {
      data['reel_weight'] = reelState.reelWeight.trim();
      data['reel_weight_unit'] = reelState.reelWeightUnit;
    }
    if (reelState.reelLine.isNotEmpty) {
      data['reel_line'] = reelState.reelLine.trim();
    }
    if (reelState.reelLineNumber.isNotEmpty) {
      data['reel_line_number'] = reelState.reelLineNumber.trim();
    }
    if (reelState.reelLineLength.isNotEmpty) {
      data['reel_line_length'] = reelState.reelLineLength.trim();
      data['reel_line_length_unit'] = reelState.reelLineLengthUnit;
    }
    if (reelState.reelLineDate.isNotEmpty) {
      data['reel_line_date'] = reelState.reelLineDate.trim();
    }
  }
}

// =============================================================================
// Lure Notifier
// =============================================================================

class LureEditNotifier extends _BaseEquipmentEditNotifier {
  LureEditNotifier(
    EquipmentService equipmentService,
    String type,
    Map<String, dynamic>? equipment,
  ) : super(equipmentService, type, equipment);

  LureEditState get lureState => _state as LureEditState;

  @override
  void _loadData(Map<String, dynamic> e) {
    _updateState(lureState.copyWith(
      lureType: _getValue(e, 'lure_type')?.toString() ?? '',
      lureWeight: _getValue(e, 'lure_weight')?.toString() ?? '',
      lureWeightUnit: _getValue(e, 'lure_weight_unit')?.toString() ?? 'g',
      lureSize: _getValue(e, 'lure_size')?.toString() ?? '',
      lureSizeUnit: _getValue(e, 'lure_size_unit')?.toString() ?? 'cm',
      lureColor: _getValue(e, 'lure_color')?.toString() ?? '',
      lureQuantity: _getValue(e, 'lure_quantity')?.toString() ?? '',
      lureQuantityUnit: _getValue(e, 'lure_quantity_unit')?.toString() ?? '',
    ));
  }

  @override
  void updateLureType(String value) =>
      _updateState(lureState.copyWith(lureType: value));
  @override
  void updateLureWeight(String value) =>
      _updateState(lureState.copyWith(lureWeight: value));
  @override
  void updateLureWeightUnit(String value) =>
      _updateState(lureState.copyWith(lureWeightUnit: value));
  @override
  void updateLureSize(String value) =>
      _updateState(lureState.copyWith(lureSize: value));
  @override
  void updateLureSizeUnit(String value) =>
      _updateState(lureState.copyWith(lureSizeUnit: value));
  @override
  void updateLureColor(String value) =>
      _updateState(lureState.copyWith(lureColor: value));
  @override
  void updateLureQuantity(String value) =>
      _updateState(lureState.copyWith(lureQuantity: value));
  @override
  void updateLureQuantityUnit(String? value) =>
      _updateState(lureState.copyWith(lureQuantityUnit: value ?? ''));

  @override
  void _buildTypeSpecificData(Map<String, dynamic> data) {
    if (lureState.lureType.isNotEmpty) {
      data['lure_type'] = lureState.lureType.trim();
    }
    if (lureState.lureWeight.isNotEmpty) {
      data['lure_weight'] = lureState.lureWeight.trim();
      data['lure_weight_unit'] = lureState.lureWeightUnit;
    }
    if (lureState.lureSize.isNotEmpty) {
      data['lure_size'] = lureState.lureSize.trim();
      data['lure_size_unit'] = lureState.lureSizeUnit;
    }
    if (lureState.lureColor.isNotEmpty) {
      data['lure_color'] = lureState.lureColor.trim();
    }
    if (lureState.lureQuantity.isNotEmpty) {
      data['lure_quantity'] = int.tryParse(lureState.lureQuantity);
    }
    if (lureState.lureQuantityUnit.isNotEmpty) {
      data['lure_quantity_unit'] = lureState.lureQuantityUnit.trim();
    }
  }
}

// =============================================================================
// Main ViewModel (Delegates to Type-Specific Notifiers)
// =============================================================================

/// Main ViewModel that delegates to type-specific notifiers.
/// Maintains the existing API for backwards compatibility.
class EquipmentEditViewModel extends StateNotifier<EquipmentEditState> {
  final EquipmentService _equipmentService;
  late final _BaseEquipmentEditNotifier _delegate;

  EquipmentEditViewModel(
    this._equipmentService,
    String type,
    Map<String, dynamic>? equipment,
  ) : super(EquipmentEditState(type: type, equipment: equipment)) {
    _delegate = _createDelegate(type, equipment);
    state = _delegate.state.toEquipmentEditState();
  }

  _BaseEquipmentEditNotifier _createDelegate(
      String type, Map<String, dynamic>? equipment) {
    switch (type) {
      case 'rod':
        return RodEditNotifier(_equipmentService, type, equipment);
      case 'reel':
        return ReelEditNotifier(_equipmentService, type, equipment);
      case 'lure':
        return LureEditNotifier(_equipmentService, type, equipment);
      default:
        return RodEditNotifier(_equipmentService, type, equipment);
    }
  }

  void loadDataFromMap(Map<String, dynamic> equipment) {
    _delegate.loadDataFromMap(equipment);
    state = _delegate.state.toEquipmentEditState();
  }

  // Shared update methods
  void updateBrand(String value) {
    _delegate.updateBrand(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateModel(String value) {
    _delegate.updateModel(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updatePrice(String value) {
    _delegate.updatePrice(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updatePurchaseDate(String value) {
    _delegate.updatePurchaseDate(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateIsDefault(bool value) {
    _delegate.updateIsDefault(value);
    state = _delegate.state.toEquipmentEditState();
  }

  // Rod-specific update methods
  void updateCategoryType1(String value) {
    _delegate.updateCategoryType1(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateCategoryType2(String value) {
    _delegate.updateCategoryType2(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateLength(String value) {
    _delegate.updateLength(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateLengthUnit(String value) {
    _delegate.updateLengthUnit(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateSections(String value) {
    _delegate.updateSections(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateJointType(String value) {
    _delegate.updateJointType(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateMaterial(String value) {
    _delegate.updateMaterial(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateHardness(String value) {
    _delegate.updateHardness(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateRodAction(String value) {
    _delegate.updateRodAction(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateWeightRange(String value) {
    _delegate.updateWeightRange(value);
    state = _delegate.state.toEquipmentEditState();
  }

  // Reel-specific update methods
  void updateReelBearings(String value) {
    _delegate.updateReelBearings(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateReelRatio(String value) {
    _delegate.updateReelRatio(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateReelCapacity(String value) {
    _delegate.updateReelCapacity(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateReelBrakeType(String value) {
    _delegate.updateReelBrakeType(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateReelWeight(String value) {
    _delegate.updateReelWeight(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateReelWeightUnit(String value) {
    _delegate.updateReelWeightUnit(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateReelLine(String value) {
    _delegate.updateReelLine(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateReelLineNumber(String value) {
    _delegate.updateReelLineNumber(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateReelLineLength(String value) {
    _delegate.updateReelLineLength(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateReelLineLengthUnit(String value) {
    _delegate.updateReelLineLengthUnit(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateReelLineDate(String value) {
    _delegate.updateReelLineDate(value);
    state = _delegate.state.toEquipmentEditState();
  }

  // Lure-specific update methods
  void updateLureType(String value) {
    _delegate.updateLureType(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateLureWeight(String value) {
    _delegate.updateLureWeight(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateLureWeightUnit(String value) {
    _delegate.updateLureWeightUnit(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateLureSize(String value) {
    _delegate.updateLureSize(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateLureSizeUnit(String value) {
    _delegate.updateLureSizeUnit(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateLureColor(String value) {
    _delegate.updateLureColor(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateLureQuantity(String value) {
    _delegate.updateLureQuantity(value);
    state = _delegate.state.toEquipmentEditState();
  }

  void updateLureQuantityUnit(String? value) {
    _delegate.updateLureQuantityUnit(value);
    state = _delegate.state.toEquipmentEditState();
  }

  String? validatePrice(AppStrings strings) {
    return _delegate.validatePrice(strings);
  }

  Future<bool> save() async {
    final result = await _delegate.save();
    state = _delegate.state.toEquipmentEditState();
    return result;
  }
}

// =============================================================================
// Provider
// =============================================================================

final equipmentEditViewModelProvider = StateNotifierProvider.family<
    EquipmentEditViewModel,
    EquipmentEditState,
    ({String type, Map<String, dynamic>? equipment})>(
  (ref, params) => EquipmentEditViewModel(
    ref.read(equipmentServiceProvider),
    params.type,
    params.equipment,
  ),
);
