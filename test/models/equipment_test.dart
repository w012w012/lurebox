import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/equipment.dart';

void main() {
  // Helper to create a minimal valid Equipment for testing
  // Uses the hasXXX pattern to distinguish between "not provided" and "explicitly null"
  Equipment createTestEquipment({
    int id = 1,
    EquipmentType type = EquipmentType.rod,
    bool hasBrand = true,
    String? brand,
    bool hasModel = true,
    String? model,
    Map<String, dynamic>? overrides,
  }) {
    final map = {
      'id': id,
      'type': type.value,
      if (hasBrand) 'brand': brand ?? 'TestBrand',
      if (hasModel) 'model': model ?? 'TestModel',
      'length': '2.4',
      'length_unit': 'm',
      'sections': '2',
      'joint_type': '分段',
      'material': '碳纤维',
      'hardness': 'MH',
      'weight_range': '10-30g',
      'reel_bearings': 5,
      'reel_ratio': '6.2:1',
      'reel_capacity': '0.25mm/200m',
      'reel_brake_type': '磁刹',
      'reel_weight': '215',
      'reel_weight_unit': 'g',
      'lure_type': 'crankbait',
      'lure_weight': '15',
      'lure_weight_unit': 'g',
      'lure_size': '5.0',
      'lure_size_unit': 'cm',
      'lure_color': '红色',
      'lure_quantity': 3,
      'lure_quantity_unit': '个',
      'price': 299.99,
      'purchase_date': '2024-01-15T10:30:00.000',
      'is_default': 1,
      'is_deleted': 0,
      'category': '路亚',
      'rod_action': '快调',
      'reel_line': 'PE线',
      'reel_line_date': '2024-03-01T00:00:00.000',
      'reel_line_number': '0.8',
      'reel_line_length': '100',
      'line_length_unit': 'm',
      'line_weight_unit': 'kg',
      'created_at': '2024-01-01T00:00:00.000',
      'updated_at': '2024-01-01T00:00:00.000',
      ...?overrides,
    };
    return Equipment.fromMap(map);
  }

  group('EquipmentType', () {
    test('value and label properties are correct', () {
      expect(EquipmentType.rod.value, equals('rod'));
      expect(EquipmentType.rod.label, equals('鱼竿'));

      expect(EquipmentType.reel.value, equals('reel'));
      expect(EquipmentType.reel.label, equals('渔轮'));

      expect(EquipmentType.lure.value, equals('lure'));
      expect(EquipmentType.lure.label, equals('鱼饵'));
    });

    test('fromValue returns rod for rod', () {
      expect(EquipmentType.fromValue('rod'), equals(EquipmentType.rod));
    });

    test('fromValue returns reel for reel', () {
      expect(EquipmentType.fromValue('reel'), equals(EquipmentType.reel));
    });

    test('fromValue returns lure for lure', () {
      expect(EquipmentType.fromValue('lure'), equals(EquipmentType.lure));
    });

    test('fromValue returns rod (default) for invalid values', () {
      expect(EquipmentType.fromValue('invalid'), equals(EquipmentType.rod));
      expect(EquipmentType.fromValue(''), equals(EquipmentType.rod));
      expect(EquipmentType.fromValue('unknown'), equals(EquipmentType.rod));
      expect(EquipmentType.fromValue('ROD'), equals(EquipmentType.rod));
    });
  });

  group('Equipment._getField fallback behavior', () {
    test('parses underscore key when underscore format exists (length_unit)', () {
      final equipment = Equipment.fromMap({
        'id': 1,
        'type': 'rod',
        'brand': 'Test',
        'model': 'Model',
        'length': '2.4',
        'length_unit': 'm',
        'sections': null,
        'joint_type': null,
        'material': null,
        'hardness': null,
        'weight_range': null,
        'reel_bearings': null,
        'reel_ratio': null,
        'reel_capacity': null,
        'reel_brake_type': null,
        'reel_weight': null,
        'reel_weight_unit': 'g',
        'lure_type': null,
        'lure_weight': null,
        'lure_weight_unit': 'g',
        'lure_size': null,
        'lure_size_unit': 'cm',
        'lure_color': null,
        'lure_quantity': null,
        'lure_quantity_unit': null,
        'price': null,
        'purchase_date': null,
        'is_default': 0,
        'is_deleted': 0,
        'category': null,
        'rod_action': null,
        'reel_line': null,
        'reel_line_date': null,
        'reel_line_number': null,
        'reel_line_length': null,
        'line_length_unit': 'm',
        'line_weight_unit': 'kg',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      });
      expect(equipment.length, equals('2.4'));
      expect(equipment.lengthUnit, equals('m'));
    });

    test('parses space key when only space format exists (length unit)', () {
      final equipment = Equipment.fromMap({
        'id': 1,
        'type': 'rod',
        'brand': 'Test',
        'model': 'Model',
        'length': '2.7',
        'length unit': 'ft',
        'sections': null,
        'joint_type': null,
        'material': null,
        'hardness': null,
        'weight_range': null,
        'reel_bearings': null,
        'reel_ratio': null,
        'reel_capacity': null,
        'reel_brake_type': null,
        'reel_weight': null,
        'reel_weight_unit': 'g',
        'lure_type': null,
        'lure_weight': null,
        'lure_weight_unit': 'g',
        'lure_size': null,
        'lure_size_unit': 'cm',
        'lure_color': null,
        'lure_quantity': null,
        'lure_quantity_unit': null,
        'price': null,
        'purchase_date': null,
        'is_default': 0,
        'is_deleted': 0,
        'category': null,
        'rod_action': null,
        'reel_line': null,
        'reel_line_date': null,
        'reel_line_number': null,
        'reel_line_length': null,
        'line_length_unit': 'm',
        'line_weight_unit': 'kg',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      });
      // _getField falls back to space format when underscore not found
      expect(equipment.length, equals('2.7'));
      expect(equipment.lengthUnit, equals('ft'));
    });

    test('uses default value when neither underscore nor space key exists', () {
      final equipment = Equipment.fromMap({
        'id': 1,
        'type': 'rod',
        'brand': 'Test',
        'model': 'Model',
        'length': '2.4',
        'sections': null,
        'joint_type': null,
        'material': null,
        'hardness': null,
        'weight_range': null,
        'reel_bearings': null,
        'reel_ratio': null,
        'reel_capacity': null,
        'reel_brake_type': null,
        'reel_weight': null,
        'reel_weight_unit': 'g',
        'lure_type': null,
        'lure_weight': null,
        'lure_weight_unit': 'g',
        'lure_size': null,
        'lure_size_unit': 'cm',
        'lure_color': null,
        'lure_quantity': null,
        'lure_quantity_unit': null,
        'price': null,
        'purchase_date': null,
        'is_default': 0,
        'is_deleted': 0,
        'category': null,
        'rod_action': null,
        'reel_line': null,
        'reel_line_date': null,
        'reel_line_number': null,
        'reel_line_length': null,
        'line_length_unit': 'm',
        'line_weight_unit': 'kg',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      });
      // Both length_unit and length unit missing - uses default 'm'
      expect(equipment.lengthUnit, equals('m'));
    });
  });

  group('Equipment.fromMap with standard keys', () {
    test('parses all standard fields correctly', () {
      final equipment = createTestEquipment(id: 42, type: EquipmentType.reel);

      expect(equipment.id, equals(42));
      expect(equipment.type, equals(EquipmentType.reel));
      expect(equipment.brand, equals('TestBrand'));
      expect(equipment.model, equals('TestModel'));
      expect(equipment.length, equals('2.4'));
      expect(equipment.lengthUnit, equals('m'));
      expect(equipment.sections, equals('2'));
      expect(equipment.jointType, equals('分段'));
      expect(equipment.material, equals('碳纤维'));
      expect(equipment.hardness, equals('MH'));
      expect(equipment.weightRange, equals('10-30g'));
      expect(equipment.reelBearings, equals(5));
      expect(equipment.reelRatio, equals('6.2:1'));
      expect(equipment.reelCapacity, equals('0.25mm/200m'));
      expect(equipment.reelBrakeType, equals('磁刹'));
      expect(equipment.reelWeight, equals('215'));
      expect(equipment.reelWeightUnit, equals('g'));
      expect(equipment.lureType, equals('crankbait'));
      expect(equipment.lureWeight, equals('15'));
      expect(equipment.lureWeightUnit, equals('g'));
      expect(equipment.lureSize, equals('5.0'));
      expect(equipment.lureSizeUnit, equals('cm'));
      expect(equipment.lureColor, equals('红色'));
      expect(equipment.lureQuantity, equals(3));
      expect(equipment.lureQuantityUnit, equals('个'));
      expect(equipment.price, equals(299.99));
      expect(equipment.isDefault, isTrue);
      expect(equipment.isDeleted, isFalse);
      expect(equipment.category, equals('路亚'));
      expect(equipment.rodAction, equals('快调'));
      expect(equipment.reelLine, equals('PE线'));
      expect(equipment.reelLineNumber, equals('0.8'));
      expect(equipment.reelLineLength, equals('100'));
      expect(equipment.lineLengthUnit, equals('m'));
      expect(equipment.lineWeightUnit, equals('kg'));
    });

    test('handles nullable fields as null', () {
      final map = {
        'id': 1,
        'type': 'rod',
        'brand': null,
        'model': null,
        'length': null,
        'length_unit': 'm',
        'sections': null,
        'joint_type': null,
        'material': null,
        'hardness': null,
        'weight_range': null,
        'reel_bearings': null,
        'reel_ratio': null,
        'reel_capacity': null,
        'reel_brake_type': null,
        'reel_weight': null,
        'reel_weight_unit': 'g',
        'lure_type': null,
        'lure_weight': null,
        'lure_weight_unit': 'g',
        'lure_size': null,
        'lure_size_unit': 'cm',
        'lure_color': null,
        'lure_quantity': null,
        'lure_quantity_unit': null,
        'price': null,
        'purchase_date': null,
        'is_default': 0,
        'is_deleted': 0,
        'category': null,
        'rod_action': null,
        'reel_line': null,
        'reel_line_date': null,
        'reel_line_number': null,
        'reel_line_length': null,
        'line_length_unit': 'm',
        'line_weight_unit': 'kg',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final equipment = Equipment.fromMap(map);

      expect(equipment.id, equals(1));
      expect(equipment.type, equals(EquipmentType.rod));
      expect(equipment.brand, isNull);
      expect(equipment.model, isNull);
      expect(equipment.length, isNull);
      expect(equipment.sections, isNull);
      expect(equipment.jointType, isNull);
      expect(equipment.material, isNull);
      expect(equipment.hardness, isNull);
      expect(equipment.weightRange, isNull);
      expect(equipment.reelBearings, isNull);
      expect(equipment.reelRatio, isNull);
      expect(equipment.reelCapacity, isNull);
      expect(equipment.reelBrakeType, isNull);
      expect(equipment.reelWeight, isNull);
      expect(equipment.lureType, isNull);
      expect(equipment.lureWeight, isNull);
      expect(equipment.lureSize, isNull);
      expect(equipment.lureColor, isNull);
      expect(equipment.lureQuantity, isNull);
      expect(equipment.lureQuantityUnit, isNull);
      expect(equipment.price, isNull);
      expect(equipment.purchaseDate, isNull);
      expect(equipment.category, isNull);
      expect(equipment.rodAction, isNull);
      expect(equipment.reelLine, isNull);
      expect(equipment.reelLineDate, isNull);
      expect(equipment.reelLineNumber, isNull);
      expect(equipment.reelLineLength, isNull);
    });

    test('uses default values for missing unit fields', () {
      final map = {
        'id': 1,
        'type': 'rod',
        'brand': 'Test',
        'model': 'Model',
        'length': '2.4',
        'length_unit': null, // will fall back to default 'm'
        'sections': '2',
        'joint_type': null,
        'material': null,
        'hardness': null,
        'weight_range': null,
        'reel_bearings': null,
        'reel_ratio': null,
        'reel_capacity': null,
        'reel_brake_type': null,
        'reel_weight': null,
        'reel_weight_unit': null, // will fall back to default 'g'
        'lure_type': null,
        'lure_weight': null,
        'lure_weight_unit': null, // will fall back to default 'g'
        'lure_size': null,
        'lure_size_unit': null, // will fall back to default 'cm'
        'lure_color': null,
        'lure_quantity': null,
        'lure_quantity_unit': null,
        'price': null,
        'purchase_date': null,
        'is_default': 0,
        'is_deleted': 0,
        'category': null,
        'rod_action': null,
        'reel_line': null,
        'reel_line_date': null,
        'reel_line_number': null,
        'reel_line_length': null,
        'line_length_unit': null, // will fall back to default 'm'
        'line_weight_unit': null, // will fall back to default 'kg'
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final equipment = Equipment.fromMap(map);

      expect(equipment.lengthUnit, equals('m'));
      expect(equipment.reelWeightUnit, equals('g'));
      expect(equipment.lureWeightUnit, equals('g'));
      expect(equipment.lureSizeUnit, equals('cm'));
      expect(equipment.lineLengthUnit, equals('m'));
      expect(equipment.lineWeightUnit, equals('kg'));
    });
  });

  group('Equipment.fromMap with alternate keys', () {
    test('parses underscore-separated keys from database format', () {
      final map = {
        'id': 1,
        'type': 'rod',
        'brand': 'Daiwa',
        'model': 'exist',
        'length': '2.7',
        'length unit': 'm', // alternate: space instead of underscore
        'sections': '3',
        'joint type': '一体',
        'material': '碳布',
        'hardness': 'MH',
        'weight range': '15-40g',
        'reel bearings': 8,
        'reel ratio': '7.1:1',
        'reel capacity': '0.3mm/150m',
        'reel brake type': '离心',
        'reel weight': '230',
        'reel weight unit': 'g',
        'lure type': 'spinnerbait',
        'lure weight': '21',
        'lure weight unit': 'g',
        'lure size': '6.5',
        'lure size unit': 'cm',
        'lure color': '银色',
        'lure quantity': 2,
        'lure quantity unit': '个',
        'price': 599.0,
        'purchase date': '2024-02-20T00:00:00.000',
        'is default': 1,
        'is deleted': 0,
        'category': '路亚',
        'rod action': '中快',
        'reel line': '尼龙线',
        'reel line date': '2024-03-15T00:00:00.000',
        'reel line number': '1.0',
        'reel line length': '150',
        'line length unit': 'm',
        'line weight unit': 'kg',
        'created at': '2024-01-01T00:00:00.000',
        'updated at': '2024-01-01T00:00:00.000',
      };

      final equipment = Equipment.fromMap(map);

      expect(equipment.id, equals(1));
      expect(equipment.type, equals(EquipmentType.rod));
      expect(equipment.brand, equals('Daiwa'));
      expect(equipment.model, equals('exist'));
      expect(equipment.length, equals('2.7'));
      expect(equipment.lengthUnit, equals('m'));
      expect(equipment.sections, equals('3'));
      expect(equipment.jointType, equals('一体'));
      expect(equipment.material, equals('碳布'));
      expect(equipment.hardness, equals('MH'));
      expect(equipment.weightRange, equals('15-40g'));
      expect(equipment.reelBearings, equals(8));
      expect(equipment.reelRatio, equals('7.1:1'));
      expect(equipment.reelCapacity, equals('0.3mm/150m'));
      expect(equipment.reelBrakeType, equals('离心'));
      expect(equipment.reelWeight, equals('230'));
      expect(equipment.reelWeightUnit, equals('g'));
      expect(equipment.lureType, equals('spinnerbait'));
      expect(equipment.lureWeight, equals('21'));
      expect(equipment.lureWeightUnit, equals('g'));
      expect(equipment.lureSize, equals('6.5'));
      expect(equipment.lureSizeUnit, equals('cm'));
      expect(equipment.lureColor, equals('银色'));
      expect(equipment.lureQuantity, equals(2));
      expect(equipment.lureQuantityUnit, equals('个'));
      expect(equipment.price, equals(599.0));
      expect(equipment.isDefault, isTrue);
      expect(equipment.category, equals('路亚'));
      expect(equipment.rodAction, equals('中快'));
      expect(equipment.reelLine, equals('尼龙线'));
      expect(equipment.reelLineNumber, equals('1.0'));
      expect(equipment.reelLineLength, equals('150'));
      expect(equipment.lineLengthUnit, equals('m'));
      expect(equipment.lineWeightUnit, equals('kg'));
    });

    test('prefers underscore key when both formats exist', () {
      final map = {
        'id': 1,
        'type': 'rod',
        'brand': 'UnderScore',
        'model': 'Model',
        'length': '2.4',
        'length_unit': 'ft', // underscore version
        'length unit': 'm', // space version - should NOT be used
        'sections': '2',
        'joint_type': '分段',
        'joint type': 'NOT_USED',
        'material': '碳纤维',
        'hardness': 'H',
        'weight_range': '10-20g',
        'reel_bearings': 6,
        'reel_ratio': '5.2:1',
        'reel_capacity': null,
        'reel_brake_type': null,
        'reel_weight': null,
        'reel_weight_unit': 'g',
        'lure_type': null,
        'lure_weight': null,
        'lure_weight_unit': 'g',
        'lure_size': null,
        'lure_size_unit': 'cm',
        'lure_color': null,
        'lure_quantity': null,
        'lure_quantity_unit': null,
        'price': null,
        'purchase_date': null,
        'is_default': 0,
        'is_deleted': 0,
        'category': null,
        'rod_action': null,
        'reel_line': null,
        'reel_line_date': null,
        'reel_line_number': null,
        'reel_line_length': null,
        'line_length_unit': 'm',
        'line_weight_unit': 'kg',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final equipment = Equipment.fromMap(map);

      expect(equipment.brand, equals('UnderScore'));
      expect(equipment.lengthUnit, equals('ft'));
      expect(equipment.jointType, equals('分段'));
    });
  });

  group('Equipment.displayName', () {
    test('returns type label when both brand and model are empty', () {
      final equipment = createTestEquipment(
        hasBrand: false,
        hasModel: false,
        overrides: {'brand': null, 'model': null},
      );
      expect(equipment.displayName, equals(EquipmentType.rod.label));
    });

    test('returns type label when both brand and model are empty strings', () {
      final equipment = createTestEquipment(
        brand: '',
        model: '',
      );
      expect(equipment.displayName, equals(EquipmentType.rod.label));
    });

    test('returns brand when only brand is set', () {
      final equipment = createTestEquipment(
        brand: 'Shimano',
        hasModel: false,
      );
      expect(equipment.displayName, equals('Shimano'));
    });

    test('returns model when only model is set', () {
      final equipment = createTestEquipment(
        hasBrand: false,
        model: 'Stradic',
      );
      expect(equipment.displayName, equals('Stradic'));
    });

    test('returns brand and model combined when both are set', () {
      final equipment = createTestEquipment(brand: 'Shimano', model: 'Stradic');
      expect(equipment.displayName, equals('Shimano Stradic'));
    });

    test('preserves whitespace in brand and model', () {
      final equipment = createTestEquipment(
        brand: '  Shimano  ',
        model: '  Stradic  ',
      );
      expect(equipment.displayName, equals('  Shimano     Stradic  '));
    });
  });

  group('Equipment.typeSafeParams', () {
    test('rodParams returns RodParams for rod type', () {
      final rodEquipment = createTestEquipment(type: EquipmentType.rod);

      final params = rodEquipment.rodParams;

      expect(params, isNotNull);
      expect(params!.length, equals('2.4'));
      expect(params.lengthUnit, equals('m'));
      expect(params.sections, equals('2'));
      expect(params.jointType, equals('分段'));
      expect(params.material, equals('碳纤维'));
      expect(params.hardness, equals('MH'));
      expect(params.rodAction, equals('快调'));
      expect(params.weightRange, equals('10-30g'));
    });

    test('rodParams returns null for reel type', () {
      final reelEquipment = createTestEquipment(type: EquipmentType.reel);
      expect(reelEquipment.rodParams, isNull);
    });

    test('rodParams returns null for lure type', () {
      final lureEquipment = createTestEquipment(type: EquipmentType.lure);
      expect(lureEquipment.rodParams, isNull);
    });

    test('reelParams returns ReelParams for reel type', () {
      final reelEquipment = createTestEquipment(type: EquipmentType.reel);

      final params = reelEquipment.reelParams;

      expect(params, isNotNull);
      expect(params!.bearings, equals(5));
      expect(params.ratio, equals('6.2:1'));
      expect(params.capacity, equals('0.25mm/200m'));
      expect(params.brakeType, equals('磁刹'));
      expect(params.weight, equals('215'));
      expect(params.weightUnit, equals('g'));
      expect(params.line, equals('PE线'));
      expect(params.lineNumber, equals('0.8'));
      expect(params.lineLength, equals('100'));
      expect(params.lineLengthUnit, equals('m'));
      expect(params.lineWeightUnit, equals('kg'));
    });

    test('reelParams returns null for rod type', () {
      final rodEquipment = createTestEquipment(type: EquipmentType.rod);
      expect(rodEquipment.reelParams, isNull);
    });

    test('reelParams returns null for lure type', () {
      final lureEquipment = createTestEquipment(type: EquipmentType.lure);
      expect(lureEquipment.reelParams, isNull);
    });

    test('lureParams returns LureParams for lure type', () {
      final lureEquipment = createTestEquipment(type: EquipmentType.lure);

      final params = lureEquipment.lureParams;

      expect(params, isNotNull);
      expect(params!.type, equals('crankbait'));
      expect(params.weight, equals('15'));
      expect(params.weightUnit, equals('g'));
      expect(params.size, equals('5.0'));
      expect(params.sizeUnit, equals('cm'));
      expect(params.color, equals('红色'));
      expect(params.quantity, equals(3));
      expect(params.quantityUnit, equals('个'));
    });

    test('lureParams returns null for rod type', () {
      final rodEquipment = createTestEquipment(type: EquipmentType.rod);
      expect(rodEquipment.lureParams, isNull);
    });

    test('lureParams returns null for reel type', () {
      final reelEquipment = createTestEquipment(type: EquipmentType.reel);
      expect(reelEquipment.lureParams, isNull);
    });
  });

  group('Equipment.toMap', () {
    test('creates map with snake_case keys', () {
      final equipment = createTestEquipment(
        id: 99,
        type: EquipmentType.lure,
        brand: 'Rapala',
        model: 'DT-6',
      );

      final map = equipment.toMap();

      expect(map['id'], equals(99));
      expect(map['type'], equals('lure'));
      expect(map['brand'], equals('Rapala'));
      expect(map['model'], equals('DT-6'));
      expect(map.containsKey('length_unit'), isTrue);
      expect(map.containsKey('is_default'), isTrue);
      expect(map.containsKey('is_deleted'), isTrue);
      expect(map.containsKey('purchase_date'), isTrue);
      expect(map['is_default'], equals(1));
      expect(map['is_deleted'], equals(0));
    });

    test('serializes date times correctly', () {
      final equipment = createTestEquipment();

      final map = equipment.toMap();

      expect(map['created_at'], isA<String>());
      expect(map['updated_at'], isA<String>());
      expect(map['purchase_date'], isA<String>());
      expect(map['reel_line_date'], isA<String>());
    });

    test('serializes null dates as null', () {
      final map = {
        'id': 1,
        'type': 'rod',
        'brand': 'Test',
        'model': 'Model',
        'length': '2.4',
        'length_unit': 'm',
        'sections': '2',
        'joint_type': null,
        'material': null,
        'hardness': null,
        'weight_range': null,
        'reel_bearings': null,
        'reel_ratio': null,
        'reel_capacity': null,
        'reel_brake_type': null,
        'reel_weight': null,
        'reel_weight_unit': 'g',
        'lure_type': null,
        'lure_weight': null,
        'lure_weight_unit': 'g',
        'lure_size': null,
        'lure_size_unit': 'cm',
        'lure_color': null,
        'lure_quantity': null,
        'lure_quantity_unit': null,
        'price': null,
        'purchase_date': null,
        'is_default': 0,
        'is_deleted': 0,
        'category': null,
        'rod_action': null,
        'reel_line': null,
        'reel_line_date': null,
        'reel_line_number': null,
        'reel_line_length': null,
        'line_length_unit': 'm',
        'line_weight_unit': 'kg',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final equipment = Equipment.fromMap(map);
      final result = equipment.toMap();

      expect(result['purchase_date'], isNull);
      expect(result['reel_line_date'], isNull);
    });
  });

  group('Equipment equality', () {
    test('two Equipment with same id are equal', () {
      final equipment1 = createTestEquipment(id: 42);
      final equipment2 = createTestEquipment(id: 42);

      expect(equipment1 == equipment2, isTrue);
      expect(equipment1.hashCode, equals(equipment2.hashCode));
    });

    test('two Equipment with different ids are not equal', () {
      final equipment1 = createTestEquipment(id: 42);
      final equipment2 = createTestEquipment(id: 99);

      expect(equipment1 == equipment2, isFalse);
    });

    test('Equipment equals same instance (identical)', () {
      final equipment = createTestEquipment(id: 42);

      expect(equipment == equipment, isTrue);
    });

    test('Equipment is not equal to other types', () {
      final equipment = createTestEquipment(id: 42);

      expect(equipment == 'not an equipment', isFalse);
      expect(equipment == 42, isFalse);
      expect(equipment == null, isFalse);
    });
  });

  group('Equipment.toString', () {
    test('returns readable format with id type and name', () {
      final equipment = createTestEquipment(
        id: 42,
        type: EquipmentType.rod,
        brand: 'Shimano',
        model: 'Expride',
      );

      final str = equipment.toString();

      expect(str, contains('id: 42'));
      expect(str, contains('type: 鱼竿'));
      expect(str, contains('brand: Shimano'));
      expect(str, contains('model: Expride'));
    });
  });

  group('Equipment edge cases', () {
    test('handles very large price values', () {
      final equipment = createTestEquipment(overrides: {
        'price': 9999999.99,
      });

      expect(equipment.price, equals(9999999.99));
    });

    test('handles int price values correctly', () {
      final map = {
        'id': 1,
        'type': 'rod',
        'brand': 'Test',
        'model': 'Model',
        'length': '2.4',
        'length_unit': 'm',
        'sections': null,
        'joint_type': null,
        'material': null,
        'hardness': null,
        'weight_range': null,
        'reel_bearings': null,
        'reel_ratio': null,
        'reel_capacity': null,
        'reel_brake_type': null,
        'reel_weight': null,
        'reel_weight_unit': 'g',
        'lure_type': null,
        'lure_weight': null,
        'lure_weight_unit': 'g',
        'lure_size': null,
        'lure_size_unit': 'cm',
        'lure_color': null,
        'lure_quantity': null,
        'lure_quantity_unit': null,
        'price': 300, // int instead of double
        'purchase_date': null,
        'is_default': 0,
        'is_deleted': 0,
        'category': null,
        'rod_action': null,
        'reel_line': null,
        'reel_line_date': null,
        'reel_line_number': null,
        'reel_line_length': null,
        'line_length_unit': 'm',
        'line_weight_unit': 'kg',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final equipment = Equipment.fromMap(map);

      expect(equipment.price, equals(300.0));
      expect(equipment.price, isA<double>());
    });

    test('handles negative int fields like reel_bearings', () {
      final map = {
        'id': 1,
        'type': 'reel',
        'brand': 'Test',
        'model': 'Model',
        'length': null,
        'length_unit': 'm',
        'sections': null,
        'joint_type': null,
        'material': null,
        'hardness': null,
        'weight_range': null,
        'reel_bearings': -1, // invalid value
        'reel_ratio': null,
        'reel_capacity': null,
        'reel_brake_type': null,
        'reel_weight': null,
        'reel_weight_unit': 'g',
        'lure_type': null,
        'lure_weight': null,
        'lure_weight_unit': 'g',
        'lure_size': null,
        'lure_size_unit': 'cm',
        'lure_color': null,
        'lure_quantity': null,
        'lure_quantity_unit': null,
        'price': null,
        'purchase_date': null,
        'is_default': 0,
        'is_deleted': 0,
        'category': null,
        'rod_action': null,
        'reel_line': null,
        'reel_line_date': null,
        'reel_line_number': null,
        'reel_line_length': null,
        'line_length_unit': 'm',
        'line_weight_unit': 'kg',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final equipment = Equipment.fromMap(map);

      expect(equipment.reelBearings, equals(-1));
    });

    test('handles zero values correctly', () {
      final map = {
        'id': 1,
        'type': 'lure',
        'brand': '',
        'model': '',
        'length': null,
        'length_unit': 'm',
        'sections': null,
        'joint_type': null,
        'material': null,
        'hardness': null,
        'weight_range': null,
        'reel_bearings': null,
        'reel_ratio': null,
        'reel_capacity': null,
        'reel_brake_type': null,
        'reel_weight': null,
        'reel_weight_unit': 'g',
        'lure_type': null,
        'lure_weight': null,
        'lure_weight_unit': 'g',
        'lure_size': null,
        'lure_size_unit': 'cm',
        'lure_color': null,
        'lure_quantity': 0, // zero quantity
        'lure_quantity_unit': null,
        'price': 0.0, // zero price
        'purchase_date': null,
        'is_default': 0,
        'is_deleted': 0,
        'category': null,
        'rod_action': null,
        'reel_line': null,
        'reel_line_date': null,
        'reel_line_number': null,
        'reel_line_length': null,
        'line_length_unit': 'm',
        'line_weight_unit': 'kg',
        'created_at': '2024-01-01T00:00:00.000',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final equipment = Equipment.fromMap(map);

      expect(equipment.lureQuantity, equals(0));
      expect(equipment.price, equals(0.0));
    });

    test('round-trip serialization preserves data', () {
      final original = createTestEquipment(
        id: 123,
        type: EquipmentType.reel,
        brand: 'Abu Garcia',
        model: 'Revo',
      );

      final map = original.toMap();
      final restored = Equipment.fromMap(map);

      expect(restored.id, equals(original.id));
      expect(restored.type, equals(original.type));
      expect(restored.brand, equals(original.brand));
      expect(restored.model, equals(original.model));
      expect(restored.length, equals(original.length));
      expect(restored.lengthUnit, equals(original.lengthUnit));
      expect(restored.sections, equals(original.sections));
      expect(restored.jointType, equals(original.jointType));
      expect(restored.material, equals(original.material));
      expect(restored.hardness, equals(original.hardness));
      expect(restored.weightRange, equals(original.weightRange));
      expect(restored.reelBearings, equals(original.reelBearings));
      expect(restored.reelRatio, equals(original.reelRatio));
      expect(restored.reelCapacity, equals(original.reelCapacity));
      expect(restored.reelBrakeType, equals(original.reelBrakeType));
      expect(restored.reelWeight, equals(original.reelWeight));
      expect(restored.reelWeightUnit, equals(original.reelWeightUnit));
      expect(restored.lureType, equals(original.lureType));
      expect(restored.lureWeight, equals(original.lureWeight));
      expect(restored.lureWeightUnit, equals(original.lureWeightUnit));
      expect(restored.lureSize, equals(original.lureSize));
      expect(restored.lureSizeUnit, equals(original.lureSizeUnit));
      expect(restored.lureColor, equals(original.lureColor));
      expect(restored.lureQuantity, equals(original.lureQuantity));
      expect(restored.lureQuantityUnit, equals(original.lureQuantityUnit));
      expect(restored.price, equals(original.price));
      expect(restored.isDefault, equals(original.isDefault));
      expect(restored.isDeleted, equals(original.isDeleted));
      expect(restored.category, equals(original.category));
      expect(restored.rodAction, equals(original.rodAction));
      expect(restored.reelLine, equals(original.reelLine));
      expect(restored.lineLengthUnit, equals(original.lineLengthUnit));
      expect(restored.lineWeightUnit, equals(original.lineWeightUnit));
    });
  });

  group('RodParams', () {
    test('has correct default values', () {
      const params = RodParams();

      expect(params.length, isNull);
      expect(params.lengthUnit, equals('m'));
      expect(params.sections, isNull);
      expect(params.jointType, isNull);
      expect(params.material, isNull);
      expect(params.hardness, isNull);
      expect(params.rodAction, isNull);
      expect(params.weightRange, isNull);
    });
  });

  group('ReelParams', () {
    test('has correct default values', () {
      const params = ReelParams();

      expect(params.bearings, isNull);
      expect(params.ratio, isNull);
      expect(params.capacity, isNull);
      expect(params.brakeType, isNull);
      expect(params.weight, isNull);
      expect(params.weightUnit, equals('g'));
      expect(params.line, isNull);
      expect(params.lineDate, isNull);
      expect(params.lineNumber, isNull);
      expect(params.lineLength, isNull);
      expect(params.lineLengthUnit, equals('m'));
      expect(params.lineWeightUnit, equals('kg'));
    });
  });

  group('LureParams', () {
    test('has correct default values', () {
      const params = LureParams();

      expect(params.type, isNull);
      expect(params.weight, isNull);
      expect(params.weightUnit, equals('g'));
      expect(params.size, isNull);
      expect(params.sizeUnit, equals('cm'));
      expect(params.color, isNull);
      expect(params.quantity, isNull);
      expect(params.quantityUnit, isNull);
    });
  });
}
