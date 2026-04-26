import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/constants/price_ranges.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/providers/equipment_edit_state.dart';
import 'package:lurebox/core/services/app_logger.dart';
import 'package:lurebox/core/services/equipment_service.dart';

// =============================================================================
// Base Notifier (Handles Shared Fields)
// =============================================================================

class _BaseEquipmentEditNotifier {
  _BaseEquipmentEditNotifier(
    this._equipmentService,
    this.type, [
    Equipment? equipment,
  ]) : _state = _createInitialState(type, equipment);
  final EquipmentService _equipmentService;
  EquipmentEditState _state;
  final String type;

  static EquipmentEditState _createInitialState(
    String type,
    Equipment? equipment,
  ) {
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

  EquipmentEditState get state => _state;

  void _updateState(EquipmentEditState newState) {
    _state = newState;
  }

  void loadFromEquipment(Equipment equipment) {
    AppLogger.d(
      'EquipmentEditViewModel',
      'loadFromEquipment START - equipment.length: ${equipment.length}',
    );

    // Load common fields from equipment
    final brandValue = equipment.brand ?? '';
    final modelValue = equipment.model ?? '';
    final priceValue =
        equipment.price != null ? equipment.price!.toStringAsFixed(2) : '';
    final purchaseDateValue =
        equipment.purchaseDate?.toIso8601String().split('T').first ?? '';
    final isDefaultValue = equipment.isDefault;

    // Load type-specific fields first
    _loadData(equipment);

    // Then overlay basic fields
    _state = _state.withUpdates(
      equipment: equipment,
      brand: brandValue,
      model: modelValue,
      price: priceValue,
      purchaseDate: purchaseDateValue,
      isDefault: isDefaultValue,
    );
  }

  void _loadData(Equipment e) {
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
  void updateReelDrag(String value) {}
  void updateReelDragUnit(String value) {}
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
    _updateState(_state.withUpdates(isSaving: true));

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
        equipmentId = _state.equipment!.id;
        final equipment = Equipment.fromMap({
          ...data,
          'id': equipmentId,
          'created_at': _state.equipment!.createdAt.toIso8601String(),
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
      AppLogger.e('EquipmentEditViewModel', 'Failed to save equipment', e);
      _updateState(
        _state.withUpdates(isSaving: false, errorMessage: e.toString()),
      );
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
    super.equipmentService,
    super.type,
    super.equipment,
  );

  RodEditState get rodState => _state as RodEditState;

  @override
  void _loadData(Equipment e) {
    var categoryType1 = '';
    var categoryType2 = '';

    AppLogger.d(
        'EquipmentEditViewModel', '[_loadData Rod] e.length: ${e.length}');

    final category = e.category;
    if (category != null && category.contains('|')) {
      final parts = category.split('|');
      categoryType1 = parts[0];
      categoryType2 = parts.length > 1 ? parts[1] : '';
    } else {
      categoryType1 = '';
      categoryType2 = category ?? '';
    }

    final lengthValue = e.length ?? '';
    AppLogger.d('EquipmentEditViewModel',
        '[_loadData Rod] lengthValue to set: $lengthValue');

    _updateState(
      rodState.copyWith(
        categoryType1: categoryType1,
        categoryType2: categoryType2,
        length: lengthValue,
        lengthUnit: e.lengthUnit,
        sections: e.sections ?? '',
        jointType: e.jointType ?? '',
        material: e.material ?? '',
        hardness: e.hardness ?? '',
        rodAction: e.rodAction ?? '',
        weightRange: e.weightRange ?? '',
      ),
    );

    AppLogger.d(
      'EquipmentEditViewModel',
      '[_loadData Rod] after copyWith, rodState.length: ${rodState.length}',
    );
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
    super.equipmentService,
    super.type,
    super.equipment,
  );

  ReelEditState get reelState => _state as ReelEditState;

  @override
  void _loadData(Equipment e) {
    var categoryType1 = '';
    var categoryType2 = '';

    final category = e.category;
    if (category != null && category.contains('|')) {
      final parts = category.split('|');
      categoryType1 = parts[0];
      categoryType2 = parts.length > 1 ? parts[1] : '';
    } else {
      categoryType1 = '';
      categoryType2 = category ?? '';
    }

    _updateState(
      reelState.copyWith(
        categoryType1: categoryType1,
        categoryType2: categoryType2,
        reelBearings: e.reelBearings?.toString() ?? '',
        reelRatio: e.reelRatio ?? '',
        reelCapacity: e.reelCapacity ?? '',
        reelBrakeType: e.reelBrakeType ?? '',
        reelDrag: e.reelDrag ?? '',
        reelDragUnit: e.reelDragUnit,
        reelWeight: e.reelWeight ?? '',
        reelWeightUnit: e.reelWeightUnit,
        reelLine: e.reelLine ?? '',
        reelLineNumber: e.reelLineNumber ?? '',
        reelLineLength: e.reelLineLength ?? '',
        reelLineLengthUnit: e.lineLengthUnit,
        reelLineDate: e.reelLineDate?.toIso8601String().split('T').first ?? '',
      ),
    );
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
  void updateReelDrag(String value) =>
      _updateState(reelState.copyWith(reelDrag: value));
  @override
  void updateReelDragUnit(String value) =>
      _updateState(reelState.copyWith(reelDragUnit: value));
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
    if (reelState.reelDrag.isNotEmpty) {
      data['reel_drag'] = reelState.reelDrag.trim();
      data['reel_drag_unit'] = reelState.reelDragUnit;
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
    super.equipmentService,
    super.type,
    super.equipment,
  );

  LureEditState get lureState => _state as LureEditState;

  @override
  void _loadData(Equipment e) {
    _updateState(
      lureState.copyWith(
        lureType: e.lureType ?? '',
        lureWeight: e.lureWeight ?? '',
        lureWeightUnit: e.lureWeightUnit,
        lureSize: e.lureSize ?? '',
        lureSizeUnit: e.lureSizeUnit,
        lureColor: e.lureColor ?? '',
        lureQuantity: e.lureQuantity?.toString() ?? '',
        lureQuantityUnit: e.lureQuantityUnit ?? '',
      ),
    );
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
  EquipmentEditViewModel(
    this._equipmentService,
    String type,
    Equipment? equipment,
  ) : super(_buildInitial(type, equipment)) {
    _delegate = _createDelegate(type, equipment);
    state = _delegate.state;
  }
  final EquipmentService _equipmentService;
  late _BaseEquipmentEditNotifier _delegate;

  static EquipmentEditState _buildInitial(
    String type,
    Equipment? equipment,
  ) =>
      switch (type) {
        'reel' => ReelEditState(type: 'reel', equipment: equipment),
        'lure' => LureEditState(type: 'lure', equipment: equipment),
        _ => RodEditState(type: 'rod', equipment: equipment),
      };

  _BaseEquipmentEditNotifier _createDelegate(
    String type,
    Equipment? equipment,
  ) {
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

  void loadFromEquipment(Equipment equipment) {
    _delegate.loadFromEquipment(equipment);
    state = _delegate.state;
  }

  // Shared update methods
  void updateBrand(String value) {
    _delegate.updateBrand(value);
    state = _delegate.state;
  }

  void updateModel(String value) {
    _delegate.updateModel(value);
    state = _delegate.state;
  }

  void updatePrice(String value) {
    _delegate.updatePrice(value);
    state = _delegate.state;
  }

  void updatePurchaseDate(String value) {
    _delegate.updatePurchaseDate(value);
    state = _delegate.state;
  }

  void updateIsDefault(bool value) {
    _delegate.updateIsDefault(value);
    state = _delegate.state;
  }

  void resetState() {
    // Re-create the delegate with fresh state for add mode
    _delegate = _createDelegate(state.type, null);
    state = _delegate.state;
  }

  // Rod-specific update methods
  void updateCategoryType1(String value) {
    _delegate.updateCategoryType1(value);
    state = _delegate.state;
  }

  void updateCategoryType2(String value) {
    _delegate.updateCategoryType2(value);
    state = _delegate.state;
  }

  void updateLength(String value) {
    _delegate.updateLength(value);
    state = _delegate.state;
  }

  void updateLengthUnit(String value) {
    _delegate.updateLengthUnit(value);
    state = _delegate.state;
  }

  void updateSections(String value) {
    _delegate.updateSections(value);
    state = _delegate.state;
  }

  void updateJointType(String value) {
    _delegate.updateJointType(value);
    state = _delegate.state;
  }

  void updateMaterial(String value) {
    _delegate.updateMaterial(value);
    state = _delegate.state;
  }

  void updateHardness(String value) {
    _delegate.updateHardness(value);
    state = _delegate.state;
  }

  void updateRodAction(String value) {
    _delegate.updateRodAction(value);
    state = _delegate.state;
  }

  void updateWeightRange(String value) {
    _delegate.updateWeightRange(value);
    state = _delegate.state;
  }

  // Reel-specific update methods
  void updateReelBearings(String value) {
    _delegate.updateReelBearings(value);
    state = _delegate.state;
  }

  void updateReelRatio(String value) {
    _delegate.updateReelRatio(value);
    state = _delegate.state;
  }

  void updateReelCapacity(String value) {
    _delegate.updateReelCapacity(value);
    state = _delegate.state;
  }

  void updateReelBrakeType(String value) {
    _delegate.updateReelBrakeType(value);
    state = _delegate.state;
  }

  void updateReelDrag(String value) {
    _delegate.updateReelDrag(value);
    state = _delegate.state;
  }

  void updateReelDragUnit(String value) {
    _delegate.updateReelDragUnit(value);
    state = _delegate.state;
  }

  void updateReelWeight(String value) {
    _delegate.updateReelWeight(value);
    state = _delegate.state;
  }

  void updateReelWeightUnit(String value) {
    _delegate.updateReelWeightUnit(value);
    state = _delegate.state;
  }

  void updateReelLine(String value) {
    _delegate.updateReelLine(value);
    state = _delegate.state;
  }

  void updateReelLineNumber(String value) {
    _delegate.updateReelLineNumber(value);
    state = _delegate.state;
  }

  void updateReelLineLength(String value) {
    _delegate.updateReelLineLength(value);
    state = _delegate.state;
  }

  void updateReelLineLengthUnit(String value) {
    _delegate.updateReelLineLengthUnit(value);
    state = _delegate.state;
  }

  void updateReelLineDate(String value) {
    _delegate.updateReelLineDate(value);
    state = _delegate.state;
  }

  // Lure-specific update methods
  void updateLureType(String value) {
    _delegate.updateLureType(value);
    state = _delegate.state;
  }

  void updateLureWeight(String value) {
    _delegate.updateLureWeight(value);
    state = _delegate.state;
  }

  void updateLureWeightUnit(String value) {
    _delegate.updateLureWeightUnit(value);
    state = _delegate.state;
  }

  void updateLureSize(String value) {
    _delegate.updateLureSize(value);
    state = _delegate.state;
  }

  void updateLureSizeUnit(String value) {
    _delegate.updateLureSizeUnit(value);
    state = _delegate.state;
  }

  void updateLureColor(String value) {
    _delegate.updateLureColor(value);
    state = _delegate.state;
  }

  void updateLureQuantity(String value) {
    _delegate.updateLureQuantity(value);
    state = _delegate.state;
  }

  void updateLureQuantityUnit(String? value) {
    _delegate.updateLureQuantityUnit(value);
    state = _delegate.state;
  }

  String? validatePrice(AppStrings strings) {
    return _delegate.validatePrice(strings);
  }

  Future<bool> save() async {
    final result = await _delegate.save();
    state = _delegate.state;
    return result;
  }
}

// =============================================================================
// Provider
// =============================================================================

final equipmentEditViewModelProvider = StateNotifierProvider.autoDispose.family<
    EquipmentEditViewModel,
    EquipmentEditState,
    ({String type, Equipment? equipment})>(
  (ref, params) => EquipmentEditViewModel(
    ref.read(equipmentServiceProvider),
    params.type,
    params.equipment,
  ),
);
