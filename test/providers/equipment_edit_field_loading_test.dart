import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/providers/equipment_edit_state.dart';
import 'package:lurebox/core/providers/equipment_edit_view_model.dart';
import 'package:lurebox/core/services/equipment_service.dart';
import 'package:mocktail/mocktail.dart';

class MockEquipmentService extends Mock implements EquipmentService {}

class FakeEquipment extends Fake implements Equipment {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeEquipment());
    registerFallbackValue(DateTime.now());
  });

  group('EquipmentEditViewModel.loadDataFromMap — Rod', () {
    late MockEquipmentService mockService;
    late EquipmentEditViewModel vm;

    setUp(() {
      mockService = MockEquipmentService();
      vm = EquipmentEditViewModel(mockService, 'rod', null);
    });

    test('loads fields from map with underscore-separated keys (SQLite format)',
        () {
      final map = <String, dynamic>{
        'id': 1,
        'type': 'rod',
        'brand': 'Shimano',
        'model': 'Core',
        'price': '299.99',
        'length': '2.10',
        'length_unit': 'm',
        'sections': '2',
        'rod_action': 'Fast',
        'material': 'Carbon',
        'is_default': 1,
      };

      vm.loadDataFromMap(map);

      final rodState = vm.state as RodEditState;
      expect(rodState.brand, equals('Shimano'));
      expect(rodState.model, equals('Core'));
      expect(rodState.price, equals('299.99'));
      expect(rodState.length, equals('2.10'));
      expect(rodState.lengthUnit, equals('m'));
      expect(rodState.sections, equals('2'));
      expect(rodState.rodAction, equals('Fast'));
      expect(rodState.material, equals('Carbon'));
      expect(rodState.isDefault, isTrue);
    });

    test('loads fields from map with space-separated keys', () {
      final map = <String, dynamic>{
        'brand': 'Daiwa',
        'model': 'Exist',
        'length': '2.13',
        'length unit': 'ft',
        'sections': '1',
        'rod action': 'Medium',
        'material': 'Graphite',
      };

      vm.loadDataFromMap(map);

      final rodState = vm.state as RodEditState;
      expect(rodState.brand, equals('Daiwa'));
      expect(rodState.model, equals('Exist'));
      expect(rodState.length, equals('2.13'));
      expect(rodState.lengthUnit, equals('ft'));
      expect(rodState.sections, equals('1'));
      expect(rodState.rodAction, equals('Medium'));
      expect(rodState.material, equals('Graphite'));
    });

    test('underscore key takes priority over space key for same field', () {
      // _getValue looks up exact key first. When both 'length_unit' and
      // 'length unit' exist, the underscore key matches first.
      final map = <String, dynamic>{
        'length_unit': 'm',
        'length unit': 'ft',
      };

      vm.loadDataFromMap(map);

      expect((vm.state as RodEditState).lengthUnit, equals('m'));
    });

    test('falls back to space key when underscore key absent', () {
      // _getValue: exact miss → underscore→space → matches 'length unit'
      final map = <String, dynamic>{
        'length unit': 'ft',
      };

      vm.loadDataFromMap(map);

      expect((vm.state as RodEditState).lengthUnit, equals('ft'));
    });

    test('falls back to underscore key when space key absent', () {
      // _getValue: exact miss → underscore→space → matches 'length_unit'
      final map = <String, dynamic>{
        'length_unit': 'm',
      };

      vm.loadDataFromMap(map);

      expect((vm.state as RodEditState).lengthUnit, equals('m'));
    });

    test('loads empty strings for missing fields', () {
      final map = <String, dynamic>{};

      vm.loadDataFromMap(map);

      final rodState = vm.state as RodEditState;
      expect(rodState.brand, equals(''));
      expect(rodState.model, equals(''));
      expect(rodState.price, equals(''));
      expect(rodState.length, equals(''));
    });

    test('handles compound underscore keys for rod-specific fields', () {
      final map = <String, dynamic>{
        'joint_type': 'Two-Piece',
        'weight_range': '10-40g',
        'hardness': 'Medium',
      };

      vm.loadDataFromMap(map);

      final rodState = vm.state as RodEditState;
      expect(rodState.jointType, equals('Two-Piece'));
      expect(rodState.weightRange, equals('10-40g'));
      expect(rodState.hardness, equals('Medium'));
    });

    test('handles compound space keys for rod-specific fields', () {
      final map = <String, dynamic>{
        'joint type': 'Two-Piece',
        'weight range': '10-40g',
        'hardness': 'Medium',
      };

      vm.loadDataFromMap(map);

      final rodState = vm.state as RodEditState;
      expect(rodState.jointType, equals('Two-Piece'));
      expect(rodState.weightRange, equals('10-40g'));
      expect(rodState.hardness, equals('Medium'));
    });

    test('loads category split from pipe-separated string', () {
      final map = <String, dynamic>{
        'category': 'Spinning|Bass',
      };

      vm.loadDataFromMap(map);

      expect(vm.state.categoryType1, equals('Spinning'));
      expect(vm.state.categoryType2, equals('Bass'));
    });

    test('loads single category when no pipe separator', () {
      final map = <String, dynamic>{
        'category': 'Casting',
      };

      vm.loadDataFromMap(map);

      expect(vm.state.categoryType1, equals(''));
      expect(vm.state.categoryType2, equals('Casting'));
    });

    test('accepts numeric is_default as integer 1', () {
      final map = <String, dynamic>{
        'brand': 'Brand',
        'model': 'Model',
        'is_default': 1,
      };

      vm.loadDataFromMap(map);

      expect(vm.state.isDefault, isTrue);
    });

    test('is_default of 0 results in false', () {
      final map = <String, dynamic>{
        'brand': 'Brand',
        'model': 'Model',
        'is_default': 0,
      };

      vm.loadDataFromMap(map);

      expect(vm.state.isDefault, isFalse);
    });
  });

  group('EquipmentEditViewModel.loadDataFromMap — Reel', () {
    late MockEquipmentService mockService;
    late EquipmentEditViewModel vm;

    setUp(() {
      mockService = MockEquipmentService();
      vm = EquipmentEditViewModel(mockService, 'reel', null);
    });

    test('loads reel-specific fields from underscore-separated map', () {
      final map = <String, dynamic>{
        'brand': 'Shimano',
        'model': 'Stradic',
        'reel_bearings': '6+1',
        'reel_ratio': '5.2:1',
        'reel_capacity': '150m/0.285mm',
        'reel_brake_type': 'Front',
        'reel_weight': '195',
        'reel_weight_unit': 'g',
      };

      vm.loadDataFromMap(map);

      final reelState = vm.state as ReelEditState;
      expect(reelState.brand, equals('Shimano'));
      expect(reelState.reelBearings, equals('6+1'));
      expect(reelState.reelRatio, equals('5.2:1'));
      expect(reelState.reelCapacity, equals('150m/0.285mm'));
      expect(reelState.reelBrakeType, equals('Front'));
      expect(reelState.reelWeight, equals('195'));
      expect(reelState.reelWeightUnit, equals('g'));
    });

    test('loads reel-specific fields from space-separated map', () {
      final map = <String, dynamic>{
        'brand': 'Daiwa',
        'model': 'Exist',
        'reel bearings': '8+1',
        'reel ratio': '6.4:1',
        'reel brake type': 'SVS',
      };

      vm.loadDataFromMap(map);

      final reelState = vm.state as ReelEditState;
      expect(reelState.brand, equals('Daiwa'));
      expect(reelState.reelBearings, equals('8+1'));
      expect(reelState.reelRatio, equals('6.4:1'));
      expect(reelState.reelBrakeType, equals('SVS'));
    });

    test('loads reel line sub-fields from underscore-separated map', () {
      final map = <String, dynamic>{
        'reel_line': 'Power Pro',
        'reel_line_number': '30',
        'reel_line_length': '150',
        'reel_line_length_unit': 'm',
        'reel_line_date': '2024-03-01',
      };

      vm.loadDataFromMap(map);

      final reelState = vm.state as ReelEditState;
      expect(reelState.reelLine, equals('Power Pro'));
      expect(reelState.reelLineNumber, equals('30'));
      expect(reelState.reelLineLength, equals('150'));
      expect(reelState.reelLineLengthUnit, equals('m'));
      expect(reelState.reelLineDate, equals('2024-03-01'));
    });

    test('loads reel line sub-fields from space-separated map', () {
      final map = <String, dynamic>{
        'reel line': 'Power Pro',
        'reel line number': '30',
        'reel line length': '150',
        'reel line length unit': 'm',
        'reel line date': '2024-03-01',
      };

      vm.loadDataFromMap(map);

      final reelState = vm.state as ReelEditState;
      expect(reelState.reelLine, equals('Power Pro'));
      expect(reelState.reelLineNumber, equals('30'));
      expect(reelState.reelLineLength, equals('150'));
      expect(reelState.reelLineLengthUnit, equals('m'));
      expect(reelState.reelLineDate, equals('2024-03-01'));
    });

    test('reel weight unit defaults to g when not provided', () {
      final map = <String, dynamic>{
        'reel_weight': '200',
      };

      vm.loadDataFromMap(map);

      final reelState = vm.state as ReelEditState;
      expect(reelState.reelWeight, equals('200'));
      expect(reelState.reelWeightUnit, equals('g'));
    });
  });

  group('EquipmentEditViewModel.loadDataFromMap — Lure', () {
    late MockEquipmentService mockService;
    late EquipmentEditViewModel vm;

    setUp(() {
      mockService = MockEquipmentService();
      vm = EquipmentEditViewModel(mockService, 'lure', null);
    });

    test('loads lure-specific fields from underscore-separated map', () {
      final map = <String, dynamic>{
        'brand': 'Rapala',
        'model': 'CountDown',
        'lure_type': 'Sinking',
        'lure_weight': '12',
        'lure_weight_unit': 'g',
        'lure_size': '7cm',
        'lure_color': 'Rainbow Trout',
        'lure_quantity': '3',
      };

      vm.loadDataFromMap(map);

      final lureState = vm.state as LureEditState;
      expect(lureState.brand, equals('Rapala'));
      expect(lureState.lureType, equals('Sinking'));
      expect(lureState.lureWeight, equals('12'));
      expect(lureState.lureWeightUnit, equals('g'));
      expect(lureState.lureSize, equals('7cm'));
      expect(lureState.lureColor, equals('Rainbow Trout'));
      expect(lureState.lureQuantity, equals('3'));
    });

    test('loads lure-specific fields from space-separated map', () {
      final map = <String, dynamic>{
        'brand': 'Megabass',
        'model': 'Vision',
        'lure type': 'Floating',
        'lure weight': '8',
        'lure size': '5cm',
        'lure color': 'Ghost Shiner',
        'lure quantity': '5',
      };

      vm.loadDataFromMap(map);

      final lureState = vm.state as LureEditState;
      expect(lureState.lureType, equals('Floating'));
      expect(lureState.lureWeight, equals('8'));
      expect(lureState.lureSize, equals('5cm'));
      expect(lureState.lureColor, equals('Ghost Shiner'));
      expect(lureState.lureQuantity, equals('5'));
    });

    test('lure size and quantity units use defaults when not provided', () {
      final map = <String, dynamic>{
        'lure_size': '10cm',
        // lure_size_unit and lure_quantity_unit omitted
      };

      vm.loadDataFromMap(map);

      final lureState = vm.state as LureEditState;
      expect(lureState.lureSize, equals('10cm'));
      expect(lureState.lureSizeUnit, equals('cm'));
    });
  });

  group('EquipmentEditViewModel.validatePrice', () {
    late MockEquipmentService mockService;
    late EquipmentEditViewModel vm;

    setUp(() {
      mockService = MockEquipmentService();
      vm = EquipmentEditViewModel(mockService, 'rod', null);
    });

    test('returns null for empty price (optional field)', () {
      vm.updatePrice('');
      expect(vm.validatePrice(AppStrings.english), isNull);
    });

    test('returns null for valid positive price', () {
      vm.updatePrice('299.99');
      expect(vm.validatePrice(AppStrings.english), isNull);
    });

    test('returns null for zero price', () {
      vm.updatePrice('0');
      expect(vm.validatePrice(AppStrings.english), isNull);
    });

    test('returns error message for non-numeric price', () {
      vm.updatePrice('abc');
      expect(vm.validatePrice(AppStrings.english),
          equals(AppStrings.english.invalidPrice),);
    });

    test('returns error message for negative price', () {
      vm.updatePrice('-50');
      expect(vm.validatePrice(AppStrings.english),
          equals(AppStrings.english.invalidPrice),);
    });

    test('returns error message for price exceeding maximum', () {
      const maxPrice = 1000000.0;
      vm.updatePrice('${maxPrice + 1}');
      expect(vm.validatePrice(AppStrings.english),
          equals(AppStrings.english.priceTooHigh),);
    });

    test('returns null for price at maximum boundary', () {
      const maxPrice = 1000000.0;
      vm.updatePrice('$maxPrice');
      expect(vm.validatePrice(AppStrings.english), isNull);
    });

    test('handles decimal prices correctly', () {
      vm.updatePrice('99.99');
      expect(vm.validatePrice(AppStrings.english), isNull);
    });

    test('handles integer string prices', () {
      vm.updatePrice('500');
      expect(vm.validatePrice(AppStrings.english), isNull);
    });

    test('handles prices with leading zeros', () {
      vm.updatePrice('007.50');
      expect(vm.validatePrice(AppStrings.english), isNull);
    });
  });

  group('EquipmentEditViewModel.save error handling', () {
    late MockEquipmentService mockService;
    late EquipmentEditViewModel vm;

    setUp(() {
      mockService = MockEquipmentService();
      vm = EquipmentEditViewModel(mockService, 'rod', null);
    });

    test('returns false and sets errorMessage when create throws', () async {
      when(() => mockService.create(any())).thenThrow(Exception('DB error'));

      vm.updateBrand('Shimano');
      vm.updateModel('Core');

      final result = await vm.save();

      expect(result, isFalse);
      expect(vm.state.errorMessage, isNotNull);
    });

    test('isSaving is false after save completes', () async {
      when(() => mockService.create(any()))
          .thenAnswer((_) async => 1);

      vm.updateBrand('Brand');
      vm.updateModel('Model');

      await vm.save();
      expect(vm.state.isSaving, isFalse);
    });
  });

  group('EquipmentEditViewModel.updateBrand / updateModel', () {
    late MockEquipmentService mockService;
    late EquipmentEditViewModel vm;

    setUp(() {
      mockService = MockEquipmentService();
      vm = EquipmentEditViewModel(mockService, 'rod', null);
    });

    test('updateBrand updates state', () {
      vm.updateBrand('Shimano');
      expect(vm.state.brand, equals('Shimano'));
    });

    test('updateModel updates state', () {
      vm.updateModel('Core');
      expect(vm.state.model, equals('Core'));
    });

    test('isEdit is false when equipment is null (add mode)', () {
      expect(vm.state.isEdit, isFalse);
    });
  });

  group('EquipmentEditViewModel.loadDataFromMap — common fields', () {
    late MockEquipmentService mockService;
    late EquipmentEditViewModel vm;

    setUp(() {
      mockService = MockEquipmentService();
      vm = EquipmentEditViewModel(mockService, 'rod', null);
    });

    test('loads brand and model from map', () {
      vm.loadDataFromMap({
        'brand': 'G. Loomis',
        'model': 'E6X',
      });

      expect(vm.state.brand, equals('G. Loomis'));
      expect(vm.state.model, equals('E6X'));
    });

    test('loads price and purchaseDate from map', () {
      vm.loadDataFromMap({
        'price': '450.00',
        'purchase_date': '2024-01-15',
      });

      expect(vm.state.price, equals('450.00'));
      expect(vm.state.purchaseDate, equals('2024-01-15'));
    });

    test('loads purchase_date with underscore fallback', () {
      // The method looks up 'purchase_date' exactly; map has underscore format
      vm.loadDataFromMap({
        'purchase_date': '2024-06-20',
      });

      expect(vm.state.purchaseDate, equals('2024-06-20'));
    });
  });
}
