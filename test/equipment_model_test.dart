import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/equipment.dart';

void main() {
  group('EquipmentType', () {
    test('enum values are correct', () {
      expect(EquipmentType.values.length, 3);
      expect(EquipmentType.values, contains(EquipmentType.rod));
      expect(EquipmentType.values, contains(EquipmentType.reel));
      expect(EquipmentType.values, contains(EquipmentType.lure));
    });

    test('fromValue returns correct type', () {
      expect(EquipmentType.fromValue('rod'), EquipmentType.rod);
      expect(EquipmentType.fromValue('reel'), EquipmentType.reel);
      expect(EquipmentType.fromValue('lure'), EquipmentType.lure);
    });

    test('fromValue returns default for unknown value', () {
      expect(EquipmentType.fromValue('unknown'), EquipmentType.rod);
      expect(EquipmentType.fromValue(''), EquipmentType.rod);
    });

    test('label returns correct value', () {
      expect(EquipmentType.rod.label, '鱼竿');
      expect(EquipmentType.reel.label, '渔轮');
      expect(EquipmentType.lure.label, '鱼饵');
    });

    test('value property returns correct string', () {
      expect(EquipmentType.rod.value, 'rod');
      expect(EquipmentType.reel.value, 'reel');
      expect(EquipmentType.lure.value, 'lure');
    });
  });

  group('Equipment', () {
    final now = DateTime(2024, 1, 1, 12, 0, 0);

    test('creates equipment with required fields', () {
      final equipment = Equipment(
        id: 1,
        type: EquipmentType.rod,
        createdAt: now,
        updatedAt: now,
      );

      expect(equipment.id, 1);
      expect(equipment.type, EquipmentType.rod);
      expect(equipment.brand, isNull);
      expect(equipment.model, isNull);
      expect(equipment.isDefault, false);
      expect(equipment.isDeleted, false);
    });

    test('fromMap creates equipment from map', () {
      final map = {
        'id': 2,
        'type': 'reel',
        'brand': 'Shimano',
        'model': 'Stradic CI4+',
        'length': null,
        'sections': null,
        'material': null,
        'hardness': null,
        'weight_range': null,
        'reel_bearings': 6,
        'reel_ratio': '5.0:1',
        'reel_capacity': '100m/10lb',
        'reel_brake_type': 'Front Drag',
        'lure_type': null,
        'lure_weight': null,
        'lure_size': null,
        'lure_color': null,
        'price': 199.99,
        'purchase_date': '2024-01-01T00:00:00.000',
        'is_default': 0,
        'is_deleted': 0,
        'category': null,
        'rod_action': null,
        'reel_line': null,
        'reel_line_date': null,
        'reel_line_number': null,
        'reel_line_length': null,
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final equipment = Equipment.fromMap(map);

      expect(equipment.id, 2);
      expect(equipment.type, EquipmentType.reel);
      expect(equipment.brand, 'Shimano');
      expect(equipment.model, 'Stradic CI4+');
      expect(equipment.reelBearings, 6);
      expect(equipment.reelRatio, '5.0:1');
      expect(equipment.price, 199.99);
      expect(equipment.isDefault, false);
      expect(equipment.isDeleted, false);
    });

    test('toMap returns correct map', () {
      final equipment = Equipment(
        id: 3,
        type: EquipmentType.lure,
        brand: 'Rapala',
        model: 'Shad Rap',
        lureType: 'Crankbait',
        lureWeight: '9g',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      );

      final map = equipment.toMap();

      expect(map['id'], 3);
      expect(map['type'], 'lure');
      expect(map['brand'], 'Rapala');
      expect(map['model'], 'Shad Rap');
      expect(map['lure_type'], 'Crankbait');
      expect(map['lure_weight'], '9g');
      expect(map['is_default'], 1);
      expect(map['is_deleted'], 0);
    });

    test('displayName returns brand and model when available', () {
      final equipment = Equipment(
        id: 1,
        type: EquipmentType.rod,
        brand: 'Daiwa',
        model: '裕光',
        createdAt: now,
        updatedAt: now,
      );

      expect(equipment.displayName, 'Daiwa 裕光');
    });

    test('displayName returns type label when brand and model are null', () {
      final equipment = Equipment(
        id: 1,
        type: EquipmentType.reel,
        createdAt: now,
        updatedAt: now,
      );

      expect(equipment.displayName, '渔轮');
    });

    test('displayName returns type label when brand and model are empty', () {
      final equipment = Equipment(
        id: 1,
        type: EquipmentType.lure,
        brand: '',
        model: '',
        createdAt: now,
        updatedAt: now,
      );

      expect(equipment.displayName, '鱼饵');
    });

    test('copyWith creates new instance with updated fields', () {
      final original = Equipment(
        id: 1,
        type: EquipmentType.rod,
        brand: 'Daiwa',
        createdAt: now,
        updatedAt: now,
      );

      final copied = original.copyWith(
        brand: () => 'Shimano',
        model: () => 'Twinpower',
      );

      expect(copied.id, 1);
      expect(copied.type, EquipmentType.rod);
      expect(copied.brand, 'Shimano');
      expect(copied.model, 'Twinpower');
      expect(original.brand, 'Daiwa');
      expect(original.model, isNull);
    });

    test('copyWith preserves original values when not specified', () {
      final original = Equipment(
        id: 1,
        type: EquipmentType.reel,
        isDefault: true,
        isDeleted: true,
        createdAt: now,
        updatedAt: now,
      );

      final copied = original.copyWith();

      expect(copied.isDefault, true);
      expect(copied.isDeleted, true);
    });

    test('equality is based on id', () {
      final equipment1 = Equipment(
        id: 1,
        type: EquipmentType.rod,
        brand: 'Brand A',
        createdAt: now,
        updatedAt: now,
      );

      final equipment2 = Equipment(
        id: 1,
        type: EquipmentType.reel,
        brand: 'Brand B',
        createdAt: now,
        updatedAt: now,
      );

      final equipment3 = Equipment(
        id: 2,
        type: EquipmentType.rod,
        createdAt: now,
        updatedAt: now,
      );

      expect(equipment1 == equipment2, true);
      expect(equipment1 == equipment3, false);
    });

    test('hashCode is based on id', () {
      final equipment1 = Equipment(
        id: 1,
        type: EquipmentType.rod,
        createdAt: now,
        updatedAt: now,
      );

      final equipment2 = Equipment(
        id: 1,
        type: EquipmentType.reel,
        createdAt: now,
        updatedAt: now,
      );

      expect(equipment1.hashCode, equipment2.hashCode);
    });
  });

  group('Equipment List Extensions', () {
    final now = DateTime(2024, 1, 1);

    List<Equipment> createTestList() {
      return [
        Equipment(
          id: 1,
          type: EquipmentType.rod,
          brand: 'Rod 1',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
        ),
        Equipment(
          id: 2,
          type: EquipmentType.rod,
          brand: 'Rod 2',
          isDeleted: true,
          createdAt: now,
          updatedAt: now,
        ),
        Equipment(
          id: 3,
          type: EquipmentType.reel,
          brand: 'Reel 1',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
        ),
        Equipment(
          id: 4,
          type: EquipmentType.reel,
          brand: 'Reel 2',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
        ),
        Equipment(
          id: 5,
          type: EquipmentType.lure,
          brand: 'Lure 1',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
        ),
        Equipment(
          id: 6,
          type: EquipmentType.lure,
          brand: 'Lure 2',
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
        ),
      ];
    }

    test('filterByType returns only matching type and non-deleted', () {
      final list = createTestList();

      final result = list.filterByType(EquipmentType.rod);

      expect(result.length, 1);
      expect(result.first.id, 1);
    });

    test('rods returns only rods that are not deleted', () {
      final list = createTestList();

      expect(list.rods.length, 1);
      expect(list.rods.first.id, 1);
    });

    test('reels returns only reels that are not deleted', () {
      final list = createTestList();

      expect(list.reels.length, 2);
      expect(list.reels.map((e) => e.id), containsAll([3, 4]));
    });

    test('lures returns only lures that are not deleted', () {
      final list = createTestList();

      expect(list.lures.length, 2);
      expect(list.lures.map((e) => e.id), containsAll([5, 6]));
    });

    test('active returns only non-deleted items', () {
      final list = createTestList();

      expect(list.active.length, 5);
    });

    test('defaults returns only default items', () {
      final list = [
        Equipment(
          id: 1,
          type: EquipmentType.rod,
          isDefault: true,
          createdAt: now,
          updatedAt: now,
        ),
        Equipment(
          id: 2,
          type: EquipmentType.rod,
          isDefault: false,
          createdAt: now,
          updatedAt: now,
        ),
        Equipment(
          id: 3,
          type: EquipmentType.reel,
          isDefault: true,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      expect(list.defaults.length, 2);
      expect(list.defaults.map((e) => e.id), containsAll([1, 3]));
    });
  });
}
