import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/providers/equipment_edit_state.dart';
import 'package:lurebox/core/providers/equipment_edit_view_model.dart';
import 'package:lurebox/core/services/equipment_service.dart';

class MockEquipmentService extends Mock implements EquipmentService {}

void main() {
  late MockEquipmentService mockService;
  final strings = AppStrings.chinese;

  setUp(() {
    mockService = MockEquipmentService();
    registerFallbackValue(Equipment.fromMap({
      'id': 0,
      'type': 'rod',
      'brand': '',
      'model': '',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }));
  });

  group('RodEditNotifier', () {
    test('initial state has rod type and empty fields', () {
      final notifier = RodEditNotifier(mockService, 'rod', null);
      final state = notifier.state as RodEditState;

      expect(state.type, 'rod');
      expect(state.isEdit, false);
      expect(state.brand, '');
      expect(state.model, '');
      expect(state.length, '');
      expect(state.lengthUnit, 'm');
      expect(state.isSaving, false);
      expect(state.errorMessage, isNull);
    });

    test('updateBrand updates brand in state', () {
      final notifier = RodEditNotifier(mockService, 'rod', null);
      notifier.updateBrand('Shimano');
      expect(notifier.state.brand, 'Shimano');
    });

    test('updateModel updates model in state', () {
      final notifier = RodEditNotifier(mockService, 'rod', null);
      notifier.updateModel('Expride');
      expect(notifier.state.model, 'Expride');
    });

    test('updateLength updates rod-specific field', () {
      final notifier = RodEditNotifier(mockService, 'rod', null);
      notifier.updateLength('2.4');
      final state = notifier.state as RodEditState;
      expect(state.length, '2.4');
    });

    test('updateMaterial updates rod material', () {
      final notifier = RodEditNotifier(mockService, 'rod', null);
      notifier.updateMaterial('carbon');
      final state = notifier.state as RodEditState;
      expect(state.material, 'carbon');
    });

    test('updateIsDefault updates default flag', () {
      final notifier = RodEditNotifier(mockService, 'rod', null);
      notifier.updateIsDefault(true);
      expect(notifier.state.isDefault, true);
    });

    test('loadDataFromMap populates rod fields', () {
      final notifier = RodEditNotifier(mockService, 'rod', null);
      notifier.loadDataFromMap({
        'id': 1,
        'type': 'rod',
        'brand': 'Daiwa',
        'model': 'Steez',
        'length': '2.1',
        'length_unit': 'm',
        'material': 'carbon',
        'hardness': 'M',
        'rod_action': 'fast',
        'is_default': 1,
        'price': '500',
        'purchase_date': '2024-01-15',
      });

      final state = notifier.state as RodEditState;
      expect(state.brand, 'Daiwa');
      expect(state.model, 'Steez');
      expect(state.length, '2.1');
      expect(state.material, 'carbon');
      expect(state.hardness, 'M');
      expect(state.rodAction, 'fast');
      expect(state.isDefault, true);
      expect(state.isEdit, true);
    });

    test('validatePrice returns null for valid price', () {
      final notifier = RodEditNotifier(mockService, 'rod', null);
      notifier.updatePrice('100');
      expect(notifier.validatePrice(strings), isNull);
    });

    test('validatePrice returns error for negative price', () {
      final notifier = RodEditNotifier(mockService, 'rod', null);
      notifier.updatePrice('-10');
      expect(notifier.validatePrice(strings), isNotNull);
    });

    test('validatePrice returns null for empty price', () {
      final notifier = RodEditNotifier(mockService, 'rod', null);
      expect(notifier.validatePrice(strings), isNull);
    });

    test('save creates new equipment successfully', () async {
      when(() => mockService.create(any())).thenAnswer((_) async => 42);

      final notifier = RodEditNotifier(mockService, 'rod', null);
      notifier.updateBrand('TestBrand');
      notifier.updateModel('TestModel');

      final result = await notifier.save();

      expect(result, true);
      expect(notifier.state.isSaving, false);
      expect(notifier.state.errorMessage, isNull);
      verify(() => mockService.create(any())).called(1);
    });

    test('save updates existing equipment', () async {
      when(() => mockService.update(any())).thenAnswer((_) async {});

      final notifier = RodEditNotifier(mockService, 'rod', {
        'id': 10,
        'type': 'rod',
        'brand': 'Old',
        'model': 'Rod',
        'created_at': '2024-01-01',
      });
      notifier.updateBrand('Updated');

      final result = await notifier.save();

      expect(result, true);
      verify(() => mockService.update(any())).called(1);
    });

    test('save returns false on error', () async {
      when(() => mockService.create(any())).thenThrow(Exception('DB error'));

      final notifier = RodEditNotifier(mockService, 'rod', null);
      final result = await notifier.save();

      expect(result, false);
      expect(notifier.state.isSaving, false);
      expect(notifier.state.errorMessage, contains('DB error'));
    });

    test('save sets default equipment when isDefault is true', () async {
      when(() => mockService.create(any())).thenAnswer((_) async => 1);
      when(() => mockService.setDefaultEquipment(any(), any()))
          .thenAnswer((_) async {});

      final notifier = RodEditNotifier(mockService, 'rod', null);
      notifier.updateIsDefault(true);
      await notifier.save();

      verify(() => mockService.setDefaultEquipment(1, 'rod')).called(1);
    });
  });

  group('ReelEditNotifier', () {
    test('initial state has reel type and empty fields', () {
      final notifier = ReelEditNotifier(mockService, 'reel', null);
      final state = notifier.state as ReelEditState;

      expect(state.type, 'reel');
      expect(state.reelRatio, '');
      expect(state.reelWeightUnit, 'g');
    });

    test('loadDataFromMap populates reel fields', () {
      final notifier = ReelEditNotifier(mockService, 'reel', null);
      notifier.loadDataFromMap({
        'id': 2,
        'type': 'reel',
        'brand': 'Shimano',
        'model': 'Vanquish',
        'reel_ratio': '5.8:1',
        'reel_weight': '180',
        'reel_weight_unit': 'g',
        'reel_capacity': 'PE 1.0 - 200m',
        'reel_brake_type': 'magnetic',
      });

      final state = notifier.state as ReelEditState;
      expect(state.brand, 'Shimano');
      expect(state.reelRatio, '5.8:1');
      expect(state.reelWeight, '180');
      expect(state.reelBrakeType, 'magnetic');
    });

    test('updateReelRatio updates reel-specific field', () {
      final notifier = ReelEditNotifier(mockService, 'reel', null);
      notifier.updateReelRatio('6.2:1');
      final state = notifier.state as ReelEditState;
      expect(state.reelRatio, '6.2:1');
    });
  });

  group('LureEditNotifier', () {
    test('initial state has lure type and empty fields', () {
      final notifier = LureEditNotifier(mockService, 'lure', null);
      final state = notifier.state as LureEditState;

      expect(state.type, 'lure');
      expect(state.lureWeightUnit, 'g');
      expect(state.lureSizeUnit, 'cm');
    });

    test('loadDataFromMap populates lure fields', () {
      final notifier = LureEditNotifier(mockService, 'lure', null);
      notifier.loadDataFromMap({
        'id': 3,
        'type': 'lure',
        'brand': 'Megabass',
        'model': 'Vision 110',
        'lure_type': 'hard_bait',
        'lure_weight': '14',
        'lure_weight_unit': 'g',
        'lure_size': '11',
        'lure_size_unit': 'cm',
        'lure_color': 'sexy shad',
      });

      final state = notifier.state as LureEditState;
      expect(state.brand, 'Megabass');
      expect(state.lureType, 'hard_bait');
      expect(state.lureWeight, '14');
      expect(state.lureColor, 'sexy shad');
    });

    test('updateLureWeight updates lure-specific field', () {
      final notifier = LureEditNotifier(mockService, 'lure', null);
      notifier.updateLureWeight('7.5');
      final state = notifier.state as LureEditState;
      expect(state.lureWeight, '7.5');
    });
  });

  group('Category parsing', () {
    test('category with pipe is split into type1 and type2', () {
      final notifier = RodEditNotifier(mockService, 'rod', null);
      notifier.loadDataFromMap({
        'type': 'rod',
        'category': 'spinning|M',
      });

      expect(notifier.state.categoryType1, 'spinning');
      expect(notifier.state.categoryType2, 'M');
    });

    test('category without pipe sets type2 only', () {
      final notifier = RodEditNotifier(mockService, 'rod', null);
      notifier.loadDataFromMap({
        'type': 'rod',
        'category': 'spinning',
      });

      expect(notifier.state.categoryType1, '');
      expect(notifier.state.categoryType2, 'spinning');
    });
  });
}
