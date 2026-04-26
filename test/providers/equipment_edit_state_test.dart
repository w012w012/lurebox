import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/providers/equipment_edit_state.dart';

void main() {
  group('RodEditState', () {
    group('initial state defaults', () {
      test('has correct default values', () {
        const state = RodEditState(type: 'rod');

        expect(state.type, 'rod');
        expect(state.equipment, isNull);
        expect(state.isSaving, false);
        expect(state.errorMessage, isNull);
        expect(state.brand, '');
        expect(state.model, '');
        expect(state.price, '');
        expect(state.purchaseDate, '');
        expect(state.isDefault, false);
        expect(state.categoryType1, '');
        expect(state.categoryType2, '');
        // Rod-specific defaults
        expect(state.length, '');
        expect(state.lengthUnit, 'm');
        expect(state.sections, '');
        expect(state.jointType, '');
        expect(state.material, '');
        expect(state.hardness, '');
        expect(state.rodAction, '');
        expect(state.weightRange, '');
      });
    });

    group('constructor with custom values', () {
      test('accepts all custom values', () {
        final testEquipment = Equipment(
          id: 1,
          type: EquipmentType.rod,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final state = RodEditState(
          type: 'rod',
          equipment: testEquipment,
          isSaving: true,
          errorMessage: 'Error',
          brand: 'Shimano',
          model: 'Tournament',
          price: '299.99',
          purchaseDate: '2024-01-15',
          isDefault: true,
          categoryType1: 'Bass',
          categoryType2: 'Freshwater',
          length: '2.1',
          lengthUnit: 'm',
          sections: '2',
          jointType: 'Spigot',
          material: 'Graphite',
          hardness: 'Medium',
          rodAction: 'Fast',
          weightRange: '10-30g',
        );

        expect(state.type, 'rod');
        expect(state.equipment, testEquipment);
        expect(state.isSaving, true);
        expect(state.errorMessage, 'Error');
        expect(state.brand, 'Shimano');
        expect(state.model, 'Tournament');
        expect(state.price, '299.99');
        expect(state.purchaseDate, '2024-01-15');
        expect(state.isDefault, true);
        expect(state.categoryType1, 'Bass');
        expect(state.categoryType2, 'Freshwater');
        expect(state.length, '2.1');
        expect(state.lengthUnit, 'm');
        expect(state.sections, '2');
        expect(state.jointType, 'Spigot');
        expect(state.material, 'Graphite');
        expect(state.hardness, 'Medium');
        expect(state.rodAction, 'Fast');
        expect(state.weightRange, '10-30g');
      });
    });

    group('copyWith', () {
      test('with no args returns equal object', () {
        const original = RodEditState(
          type: 'rod',
          brand: 'Shimano',
          model: 'Tournament',
          length: '2.1',
        );

        final copy = original.copyWith();

        expect(copy.type, original.type);
        expect(copy.brand, original.brand);
        expect(copy.model, original.model);
        expect(copy.length, original.length);
        expect(copy.lengthUnit, original.lengthUnit);
        expect(copy.sections, original.sections);
        expect(copy.isDefault, original.isDefault);
        // Verify it's a new instance
        expect(identical(copy, original), false);
      });

      test('with single field change', () {
        const original = RodEditState(
          type: 'rod',
          brand: 'Shimano',
          model: 'Tournament',
          isDefault: false,
        );

        final copy = original.copyWith(brand: ' Daiwa');

        expect(copy.brand, ' Daiwa');
        expect(copy.model, original.model);
        expect(copy.isDefault, original.isDefault);
      });

      test('with multiple field changes', () {
        const original = RodEditState(
          type: 'rod',
          brand: 'Shimano',
          model: 'Tournament',
          price: '200',
          length: '2.1',
          sections: '2',
        );

        final copy = original.copyWith(
          brand: 'Daiwa',
          price: '250',
          length: '2.4',
          sections: '3',
        );

        expect(copy.brand, 'Daiwa');
        expect(copy.model, original.model);
        expect(copy.price, '250');
        expect(copy.length, '2.4');
        expect(copy.sections, '3');
        // Unchanged fields remain the same
        expect(copy.type, original.type);
        expect(copy.model, original.model);
      });

      test('with rod-specific fields only', () {
        const original = RodEditState(
          type: 'rod',
          length: '2.1',
          lengthUnit: 'm',
          sections: '2',
        );

        final copy = original.copyWith(
          length: '2.7',
          lengthUnit: 'ft',
          sections: '4',
          material: 'Carbon',
          rodAction: 'Extra Fast',
        );

        expect(copy.length, '2.7');
        expect(copy.lengthUnit, 'ft');
        expect(copy.sections, '4');
        expect(copy.material, 'Carbon');
        expect(copy.rodAction, 'Extra Fast');
      });

      test('preserves null errorMessage in copyWith', () {
        const original = RodEditState(
          type: 'rod',
          errorMessage: null,
        );

        final copy = original.copyWith(brand: 'NewBrand');

        expect(copy.errorMessage, isNull);
        expect(copy.brand, 'NewBrand');
      });

      test('allows clearing errorMessage explicitly', () {
        const original = RodEditState(
          type: 'rod',
          errorMessage: 'Some error',
        );

        final copy = original.copyWith(errorMessage: null);

        expect(copy.errorMessage, isNull);
      });
    });

    group('withUpdates', () {
      test('delegates to copyWith correctly', () {
        const original = RodEditState(
          type: 'rod',
          brand: 'Shimano',
          model: 'Tournament',
          isSaving: false,
        );

        final updated = original.withUpdates(
          brand: 'Daiwa',
          isSaving: true,
          length: '2.4',
        );

        expect(updated.brand, 'Daiwa');
        expect(updated.isSaving, true);
        expect(updated.length, '2.4');
        expect(updated.model, original.model);
      });

      test('returns RodEditState type', () {
        const original = RodEditState(type: 'rod');

        final updated = original.withUpdates(brand: 'NewBrand');

        expect(updated, isA<RodEditState>());
      });

      test('partial updates only change specified fields', () {
        const original = RodEditState(
          type: 'rod',
          brand: 'Original',
          model: 'Original',
          material: 'Graphite',
          rodAction: 'Fast',
        );

        final updated = original.withUpdates(material: 'Carbon');

        expect(updated.material, 'Carbon');
        expect(updated.brand, 'Original');
        expect(updated.model, 'Original');
        expect(updated.rodAction, 'Fast');
      });
    });

    group('isEdit', () {
      test('returns false when equipment is null', () {
        const state = RodEditState(type: 'rod', equipment: null);

        expect(state.isEdit, false);
      });

      test('returns true when equipment is provided', () {
        final testEquipment = Equipment(
          id: 1,
          type: EquipmentType.rod,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final state = RodEditState(
          type: 'rod',
          equipment: testEquipment,
        );

        expect(state.isEdit, true);
      });

      test('returns true even with empty equipment map', () {
        final testEquipment = Equipment(
          id: 1,
          type: EquipmentType.rod,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final state = RodEditState(
          type: 'rod',
          equipment: testEquipment,
        );

        expect(state.isEdit, true);
      });
    });
  });

  group('ReelEditState', () {
    group('initial state defaults', () {
      test('has correct default values', () {
        const state = ReelEditState(type: 'reel');

        expect(state.type, 'reel');
        expect(state.equipment, isNull);
        expect(state.isSaving, false);
        expect(state.errorMessage, isNull);
        expect(state.brand, '');
        expect(state.model, '');
        expect(state.price, '');
        expect(state.purchaseDate, '');
        expect(state.isDefault, false);
        expect(state.categoryType1, '');
        expect(state.categoryType2, '');
        // Reel-specific defaults
        expect(state.reelBearings, '');
        expect(state.reelRatio, '');
        expect(state.reelCapacity, '');
        expect(state.reelBrakeType, '');
        expect(state.reelWeight, '');
        expect(state.reelWeightUnit, 'g');
        expect(state.reelLine, '');
        expect(state.reelLineNumber, '');
        expect(state.reelLineLength, '');
        expect(state.reelLineLengthUnit, 'm');
        expect(state.reelLineDate, '');
      });
    });

    group('constructor with custom values', () {
      test('accepts all custom values', () {
        final testEquipment = Equipment(
          id: 2,
          type: EquipmentType.reel,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final state = ReelEditState(
          type: 'reel',
          equipment: testEquipment,
          isSaving: true,
          errorMessage: 'Reel error',
          brand: 'Shimano',
          model: 'Stradic',
          price: '349.99',
          purchaseDate: '2024-03-10',
          isDefault: true,
          categoryType1: 'Spinning',
          categoryType2: 'Saltwater',
          reelBearings: '5+1',
          reelRatio: '6.2:1',
          reelCapacity: '150m/0.25mm',
          reelBrakeType: 'Front Drag',
          reelWeight: '285',
          reelWeightUnit: 'g',
          reelLine: 'Power Pro',
          reelLineNumber: '0.25',
          reelLineLength: '150',
          reelLineLengthUnit: 'm',
          reelLineDate: '2024-06-01',
        );

        expect(state.type, 'reel');
        expect(state.equipment, testEquipment);
        expect(state.isSaving, true);
        expect(state.errorMessage, 'Reel error');
        expect(state.brand, 'Shimano');
        expect(state.model, 'Stradic');
        expect(state.price, '349.99');
        expect(state.purchaseDate, '2024-03-10');
        expect(state.isDefault, true);
        expect(state.categoryType1, 'Spinning');
        expect(state.categoryType2, 'Saltwater');
        expect(state.reelBearings, '5+1');
        expect(state.reelRatio, '6.2:1');
        expect(state.reelCapacity, '150m/0.25mm');
        expect(state.reelBrakeType, 'Front Drag');
        expect(state.reelWeight, '285');
        expect(state.reelWeightUnit, 'g');
        expect(state.reelLine, 'Power Pro');
        expect(state.reelLineNumber, '0.25');
        expect(state.reelLineLength, '150');
        expect(state.reelLineLengthUnit, 'm');
        expect(state.reelLineDate, '2024-06-01');
      });
    });

    group('copyWith', () {
      test('with no args returns equal object', () {
        const original = ReelEditState(
          type: 'reel',
          brand: 'Shimano',
          reelRatio: '6.2:1',
          reelBearings: '5+1',
        );

        final copy = original.copyWith();

        expect(copy.type, original.type);
        expect(copy.brand, original.brand);
        expect(copy.reelRatio, original.reelRatio);
        expect(copy.reelBearings, original.reelBearings);
        expect(copy.reelWeightUnit, original.reelWeightUnit);
        expect(copy.reelLineLengthUnit, original.reelLineLengthUnit);
        // Verify it's a new instance
        expect(identical(copy, original), false);
      });

      test('with single reel-specific field change', () {
        const original = ReelEditState(
          type: 'reel',
          reelRatio: '6.2:1',
        );

        final copy = original.copyWith(reelRatio: '7.5:1');

        expect(copy.reelRatio, '7.5:1');
        expect(copy.reelBearings, original.reelBearings);
      });

      test('with multiple reel-specific field changes', () {
        const original = ReelEditState(
          type: 'reel',
          reelBearings: '4+1',
          reelRatio: '5.1:1',
          reelWeight: '250',
        );

        final copy = original.copyWith(
          reelBearings: '6+1',
          reelRatio: '8.1:1',
          reelWeight: '300',
          reelWeightUnit: 'oz',
        );

        expect(copy.reelBearings, '6+1');
        expect(copy.reelRatio, '8.1:1');
        expect(copy.reelWeight, '300');
        expect(copy.reelWeightUnit, 'oz');
      });

      test('with reel line fields', () {
        const original = ReelEditState(
          type: 'reel',
          reelLine: '',
          reelLineNumber: '',
          reelLineLength: '',
        );

        final copy = original.copyWith(
          reelLine: 'Fluorocarbon',
          reelLineNumber: '0.30',
          reelLineLength: '200',
          reelLineLengthUnit: 'yd',
        );

        expect(copy.reelLine, 'Fluorocarbon');
        expect(copy.reelLineNumber, '0.30');
        expect(copy.reelLineLength, '200');
        expect(copy.reelLineLengthUnit, 'yd');
      });
    });

    group('withUpdates', () {
      test('delegates to copyWith correctly', () {
        const original = ReelEditState(
          type: 'reel',
          brand: 'Shimano',
          reelRatio: '6.2:1',
        );

        final updated = original.withUpdates(
          brand: 'Daiwa',
          reelRatio: '8.1:1',
          reelBearings: '6+1',
        );

        expect(updated.brand, 'Daiwa');
        expect(updated.reelRatio, '8.1:1');
        expect(updated.reelBearings, '6+1');
      });

      test('returns ReelEditState type', () {
        const original = ReelEditState(type: 'reel');

        final updated = original.withUpdates(reelWeight: '285');

        expect(updated, isA<ReelEditState>());
      });

      test('partial updates preserve unchanged fields', () {
        const original = ReelEditState(
          type: 'reel',
          brand: 'Original',
          reelLine: 'Original Line',
          reelCapacity: 'Original Capacity',
        );

        final updated = original.withUpdates(reelCapacity: 'New Capacity');

        expect(updated.reelCapacity, 'New Capacity');
        expect(updated.brand, 'Original');
        expect(updated.reelLine, 'Original Line');
      });
    });

    group('isEdit', () {
      test('returns false when equipment is null', () {
        const state = ReelEditState(type: 'reel');

        expect(state.isEdit, false);
      });

      test('returns true when equipment is provided', () {
        final testEquipment = Equipment(
          id: 2,
          type: EquipmentType.reel,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final state = ReelEditState(
          type: 'reel',
          equipment: testEquipment,
        );

        expect(state.isEdit, true);
      });
    });
  });

  group('LureEditState', () {
    group('initial state defaults', () {
      test('has correct default values', () {
        const state = LureEditState(type: 'lure');

        expect(state.type, 'lure');
        expect(state.equipment, isNull);
        expect(state.isSaving, false);
        expect(state.errorMessage, isNull);
        expect(state.brand, '');
        expect(state.model, '');
        expect(state.price, '');
        expect(state.purchaseDate, '');
        expect(state.isDefault, false);
        expect(state.categoryType1, '');
        expect(state.categoryType2, '');
        // Lure-specific defaults
        expect(state.lureType, '');
        expect(state.lureWeight, '');
        expect(state.lureWeightUnit, 'g');
        expect(state.lureSize, '');
        expect(state.lureSizeUnit, 'cm');
        expect(state.lureColor, '');
        expect(state.lureQuantity, '');
        expect(state.lureQuantityUnit, 'pcs');
      });
    });

    group('constructor with custom values', () {
      test('accepts all custom values', () {
        final testEquipment = Equipment(
          id: 3,
          type: EquipmentType.lure,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final state = LureEditState(
          type: 'lure',
          equipment: testEquipment,
          isSaving: true,
          errorMessage: 'Lure error',
          brand: 'Rapala',
          model: 'X-Rap',
          price: '15.99',
          purchaseDate: '2024-05-20',
          isDefault: true,
          categoryType1: 'Crankbait',
          categoryType2: 'Hard Bait',
          lureType: 'Crankbait',
          lureWeight: '20',
          lureWeightUnit: 'g',
          lureSize: '5',
          lureSizeUnit: 'cm',
          lureColor: 'Chartreuse',
          lureQuantity: '10',
          lureQuantityUnit: 'pcs',
        );

        expect(state.type, 'lure');
        expect(state.equipment, testEquipment);
        expect(state.isSaving, true);
        expect(state.errorMessage, 'Lure error');
        expect(state.brand, 'Rapala');
        expect(state.model, 'X-Rap');
        expect(state.price, '15.99');
        expect(state.purchaseDate, '2024-05-20');
        expect(state.isDefault, true);
        expect(state.categoryType1, 'Crankbait');
        expect(state.categoryType2, 'Hard Bait');
        expect(state.lureType, 'Crankbait');
        expect(state.lureWeight, '20');
        expect(state.lureWeightUnit, 'g');
        expect(state.lureSize, '5');
        expect(state.lureSizeUnit, 'cm');
        expect(state.lureColor, 'Chartreuse');
        expect(state.lureQuantity, '10');
        expect(state.lureQuantityUnit, 'pcs');
      });
    });

    group('copyWith', () {
      test('with no args returns equal object', () {
        const original = LureEditState(
          type: 'lure',
          brand: 'Rapala',
          lureType: 'Crankbait',
          lureColor: 'Blue',
        );

        final copy = original.copyWith();

        expect(copy.type, original.type);
        expect(copy.brand, original.brand);
        expect(copy.lureType, original.lureType);
        expect(copy.lureColor, original.lureColor);
        expect(copy.lureWeightUnit, original.lureWeightUnit);
        expect(copy.lureSizeUnit, original.lureSizeUnit);
        expect(copy.lureQuantityUnit, original.lureQuantityUnit);
        // Verify it's a new instance
        expect(identical(copy, original), false);
      });

      test('with single lure-specific field change', () {
        const original = LureEditState(
          type: 'lure',
          lureType: 'Spinnerbait',
        );

        final copy = original.copyWith(lureType: 'Jig');

        expect(copy.lureType, 'Jig');
        expect(copy.lureColor, original.lureColor);
      });

      test('with multiple lure-specific field changes', () {
        const original = LureEditState(
          type: 'lure',
          lureWeight: '15',
          lureSize: '4',
          lureColor: 'White',
          lureQuantity: '5',
        );

        final copy = original.copyWith(
          lureWeight: '25',
          lureSize: '6',
          lureColor: 'Chartreuse',
          lureQuantity: '12',
          lureWeightUnit: 'oz',
        );

        expect(copy.lureWeight, '25');
        expect(copy.lureSize, '6');
        expect(copy.lureColor, 'Chartreuse');
        expect(copy.lureQuantity, '12');
        expect(copy.lureWeightUnit, 'oz');
      });

      test('with quantity fields', () {
        const original = LureEditState(
          type: 'lure',
          lureQuantity: '',
          lureQuantityUnit: 'pcs',
        );

        final copy = original.copyWith(
          lureQuantity: '50',
          lureQuantityUnit: 'g',
        );

        expect(copy.lureQuantity, '50');
        expect(copy.lureQuantityUnit, 'g');
      });
    });

    group('withUpdates', () {
      test('delegates to copyWith correctly', () {
        const original = LureEditState(
          type: 'lure',
          brand: 'Rapala',
          lureType: 'Crankbait',
        );

        final updated = original.withUpdates(
          brand: 'Berkley',
          lureType: 'Jig',
          lureWeight: '30',
        );

        expect(updated.brand, 'Berkley');
        expect(updated.lureType, 'Jig');
        expect(updated.lureWeight, '30');
      });

      test('returns LureEditState type', () {
        const original = LureEditState(type: 'lure');

        final updated = original.withUpdates(lureColor: 'Red');

        expect(updated, isA<LureEditState>());
      });

      test('partial updates preserve unchanged fields', () {
        const original = LureEditState(
          type: 'lure',
          brand: 'Original',
          lureType: 'Original Type',
          lureSize: '5',
        );

        final updated = original.withUpdates(lureSize: '7');

        expect(updated.lureSize, '7');
        expect(updated.brand, 'Original');
        expect(updated.lureType, 'Original Type');
      });
    });

    group('isEdit', () {
      test('returns false when equipment is null', () {
        const state = LureEditState(type: 'lure');

        expect(state.isEdit, false);
      });

      test('returns true when equipment is provided', () {
        final testEquipment = Equipment(
          id: 3,
          type: EquipmentType.lure,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final state = LureEditState(
          type: 'lure',
          equipment: testEquipment,
        );

        expect(state.isEdit, true);
      });
    });
  });

  group('Common field behavior', () {
    group('brand/model/price fields work across all types', () {
      test('RodEditState', () {
        const state = RodEditState(
          type: 'rod',
          brand: 'Shimano',
          model: 'Tournament 1000',
          price: '299.99',
        );

        expect(state.brand, 'Shimano');
        expect(state.model, 'Tournament 1000');
        expect(state.price, '299.99');
      });

      test('ReelEditState', () {
        const state = ReelEditState(
          type: 'reel',
          brand: 'Daiwa',
          model: 'Ballistic 4000',
          price: '449.99',
        );

        expect(state.brand, 'Daiwa');
        expect(state.model, 'Ballistic 4000');
        expect(state.price, '449.99');
      });

      test('LureEditState', () {
        const state = LureEditState(
          type: 'lure',
          brand: 'Rapala',
          model: 'X-Rap 10',
          price: '12.99',
        );

        expect(state.brand, 'Rapala');
        expect(state.model, 'X-Rap 10');
        expect(state.price, '12.99');
      });
    });

    group('isDefault toggle works', () {
      test('RodEditState', () {
        final testEquipment = Equipment(
          id: 1,
          type: EquipmentType.rod,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final state = RodEditState(
          type: 'rod',
          equipment: testEquipment,
          isDefault: false,
        );

        expect(state.isDefault, false);

        final toggled = state.copyWith(isDefault: true);

        expect(toggled.isDefault, true);
        expect(toggled.equipment, state.equipment);
      });

      test('ReelEditState', () {
        const state = ReelEditState(
          type: 'reel',
          isDefault: false,
        );

        final toggled = state.copyWith(isDefault: true);

        expect(toggled.isDefault, true);
      });

      test('LureEditState', () {
        const state = LureEditState(
          type: 'lure',
          isDefault: false,
        );

        final toggled = state.copyWith(isDefault: true);

        expect(toggled.isDefault, true);
      });
    });

    group('categoryType1/categoryType2 parsing', () {
      test('RodEditState stores category types', () {
        const state = RodEditState(
          type: 'rod',
          categoryType1: 'Bass',
          categoryType2: 'Freshwater/Spinning',
        );

        expect(state.categoryType1, 'Bass');
        expect(state.categoryType2, 'Freshwater/Spinning');
      });

      test('ReelEditState stores category types', () {
        const state = ReelEditState(
          type: 'reel',
          categoryType1: 'Spinning',
          categoryType2: 'Saltwater',
        );

        expect(state.categoryType1, 'Spinning');
        expect(state.categoryType2, 'Saltwater');
      });

      test('LureEditState stores category types', () {
        const state = LureEditState(
          type: 'lure',
          categoryType1: 'Crankbait',
          categoryType2: 'Hard Bait/Topwater',
        );

        expect(state.categoryType1, 'Crankbait');
        expect(state.categoryType2, 'Hard Bait/Topwater');
      });

      test('copyWith preserves category types', () {
        const original = RodEditState(
          type: 'rod',
          categoryType1: 'Trout',
          categoryType2: 'Ultralight',
        );

        final copy = original.copyWith(model: 'New Model');

        expect(copy.categoryType1, 'Trout');
        expect(copy.categoryType2, 'Ultralight');
      });
    });

    group('type-specific default units are preserved', () {
      test('RodEditState has meter default', () {
        const state = RodEditState(type: 'rod');

        expect(state.lengthUnit, 'm');
      });

      test('ReelEditState has gram and meter defaults', () {
        const state = ReelEditState(type: 'reel');

        expect(state.reelWeightUnit, 'g');
        expect(state.reelLineLengthUnit, 'm');
      });

      test('LureEditState has gram, cm, and pcs defaults', () {
        const state = LureEditState(type: 'lure');

        expect(state.lureWeightUnit, 'g');
        expect(state.lureSizeUnit, 'cm');
        expect(state.lureQuantityUnit, 'pcs');
      });
    });

    group('copyWith returns new instance not same reference', () {
      test('RodEditState', () {
        const original = RodEditState(type: 'rod');

        final copy = original.copyWith(brand: 'New');

        expect(identical(copy, original), false);
        expect(copy, isNot(same(original)));
      });

      test('ReelEditState', () {
        const original = ReelEditState(type: 'reel');

        final copy = original.copyWith(brand: 'New');

        expect(identical(copy, original), false);
        expect(copy, isNot(same(original)));
      });

      test('LureEditState', () {
        const original = LureEditState(type: 'lure');

        final copy = original.copyWith(brand: 'New');

        expect(identical(copy, original), false);
        expect(copy, isNot(same(original)));
      });
    });
  });
}
