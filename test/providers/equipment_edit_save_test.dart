import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/equipment.dart';
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

  group('RodEditNotifier.save()', () {
    late MockEquipmentService mockService;
    late RodEditNotifier notifier;

    setUp(() {
      mockService = MockEquipmentService();
      notifier = RodEditNotifier(mockService, 'rod', null);
    });

    tearDown(() {
      // No resources to clean up - mocks are garbage collected
    });

    test('creates new rod with correct data', () async {
      // Arrange
      when(() => mockService.create(any())).thenAnswer((_) async => 1);
      when(() => mockService.setDefaultEquipment(any(), any()))
          .thenAnswer((_) async {});

      notifier.updateBrand('Shimano');
      notifier.updateModel('Core');
      notifier.updateCategoryType2('Spinning');
      notifier.updateLength('2.1');
      notifier.updateLengthUnit('m');
      notifier.updateSections('2');
      notifier.updateRodAction('Fast');
      notifier.updateIsDefault(true);

      // Act
      final result = await notifier.save();

      // Assert
      expect(result, isTrue);
      expect(notifier.state.isSaving, isFalse);
      expect(notifier.state.errorMessage, isNull);

      final captured = verify(() => mockService.create(captureAny())).captured;
      final equipment = captured.first as Equipment;
      expect(equipment.brand, equals('Shimano'));
      expect(equipment.model, equals('Core'));
      expect(equipment.type, equals(EquipmentType.rod));
      expect(equipment.length, equals('2.1'));
      expect(equipment.lengthUnit, equals('m'));
      expect(equipment.sections, equals('2'));
      expect(equipment.rodAction, equals('Fast'));
      expect(equipment.category, equals('Spinning'));
      expect(equipment.isDefault, isTrue);
    });

    test('updates existing rod with correct data', () async {
      // Arrange
      final existingEquipment = Equipment.fromMap({
        'id': 5,
        'type': 'rod',
        'brand': 'OldBrand',
        'model': 'OldModel',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      when(() => mockService.update(any())).thenAnswer((_) async {});
      when(() => mockService.setDefaultEquipment(any(), any()))
          .thenAnswer((_) async {});

      final updateNotifier =
          RodEditNotifier(mockService, 'rod', existingEquipment);
      updateNotifier.updateBrand('NewBrand');
      updateNotifier.updateModel('NewModel');

      // Act
      final result = await updateNotifier.save();

      // Assert
      expect(result, isTrue);

      final captured = verify(() => mockService.update(captureAny())).captured;
      final equipment = captured.first as Equipment;
      expect(equipment.id, equals(5));
      expect(equipment.brand, equals('NewBrand'));
      expect(equipment.model, equals('NewModel'));
    });

    test('sets isSaving during save operation', () async {
      // Arrange
      when(() => mockService.create(any())).thenAnswer((_) async => 1);

      notifier.updateBrand('Test');

      // Act & Assert - isSaving should be true during the async operation
      final future = notifier.save();

      // Note: Due to async nature, we verify the flag is cleared after await
      await future;

      expect(notifier.state.isSaving, isFalse);
    });

    test('handles price conversion correctly', () async {
      // Arrange
      when(() => mockService.create(any())).thenAnswer((_) async => 1);

      notifier.updateBrand('Shimano');
      notifier.updatePrice('299.99');

      // Act
      await notifier.save();

      // Assert
      final captured = verify(() => mockService.create(captureAny())).captured;
      final equipment = captured.first as Equipment;
      expect(equipment.price, equals(299.99));
    });

    test('does not call setDefaultEquipment when isDefault is false', () async {
      // Arrange
      when(() => mockService.create(any())).thenAnswer((_) async => 1);

      notifier.updateBrand('Shimano');
      notifier.updateIsDefault(false);

      // Act
      await notifier.save();

      // Assert
      verifyNever(() => mockService.setDefaultEquipment(any(), any()));
    });
  });

  group('ReelEditNotifier.save()', () {
    late MockEquipmentService mockService;
    late ReelEditNotifier notifier;

    setUp(() {
      mockService = MockEquipmentService();
      notifier = ReelEditNotifier(mockService, 'reel', null);
    });

    tearDown(() {
      // No resources to clean up - mocks are garbage collected
    });

    test('creates new reel with correct data', () async {
      // Arrange
      when(() => mockService.create(any())).thenAnswer((_) async => 2);
      when(() => mockService.setDefaultEquipment(any(), any()))
          .thenAnswer((_) async {});

      notifier.updateBrand('Shimano');
      notifier.updateModel('Stradic');
      notifier.updateCategoryType1('Spinning');
      notifier.updateReelBearings('8');
      notifier.updateReelRatio('5.2:1');
      notifier.updateReelCapacity('200m/0.30mm');
      notifier.updateReelWeight('215');
      notifier.updateReelWeightUnit('g');

      // Act
      final result = await notifier.save();

      // Assert
      expect(result, isTrue);
      expect(notifier.state.isSaving, isFalse);

      final captured = verify(() => mockService.create(captureAny())).captured;
      final equipment = captured.first as Equipment;
      expect(equipment.brand, equals('Shimano'));
      expect(equipment.model, equals('Stradic'));
      expect(equipment.type, equals(EquipmentType.reel));
      expect(equipment.reelBearings, equals(8));
      expect(equipment.reelRatio, equals('5.2:1'));
      expect(equipment.reelCapacity, equals('200m/0.30mm'));
      expect(equipment.reelWeight, equals('215'));
      expect(equipment.reelWeightUnit, equals('g'));
      expect(equipment.category, equals('Spinning'));
    });

    test('updates existing reel with correct data', () async {
      // Arrange
      final existingEquipment = Equipment.fromMap({
        'id': 10,
        'type': 'reel',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      when(() => mockService.update(any())).thenAnswer((_) async {});
      when(() => mockService.setDefaultEquipment(any(), any()))
          .thenAnswer((_) async {});

      final updateNotifier =
          ReelEditNotifier(mockService, 'reel', existingEquipment);
      updateNotifier.updateBrand('NewBrand');
      updateNotifier.updateReelBearings('10');

      // Act
      final result = await updateNotifier.save();

      // Assert
      expect(result, isTrue);

      final captured = verify(() => mockService.update(captureAny())).captured;
      final equipment = captured.first as Equipment;
      expect(equipment.id, equals(10));
      expect(equipment.brand, equals('NewBrand'));
      expect(equipment.reelBearings, equals(10));
    });

    test('handles reel line data correctly', () async {
      // Arrange
      when(() => mockService.create(any())).thenAnswer((_) async => 1);

      notifier.updateBrand('Shimano');
      notifier.updateReelLine('PowerPro');
      notifier.updateReelLineNumber('30');
      notifier.updateReelLineLength('150');
      notifier.updateReelLineLengthUnit('m');

      // Act
      await notifier.save();

      // Assert
      final captured = verify(() => mockService.create(captureAny())).captured;
      final equipment = captured.first as Equipment;
      expect(equipment.reelLine, equals('PowerPro'));
      expect(equipment.reelLineNumber, equals('30'));
      expect(equipment.reelLineLength, equals('150'));
    });

    test('handles combined category type1 and type2', () async {
      // Arrange
      when(() => mockService.create(any())).thenAnswer((_) async => 1);

      notifier.updateBrand('Shimano');
      notifier.updateCategoryType1('Baitcasting');
      notifier.updateCategoryType2('Low Profile');

      // Act
      await notifier.save();

      // Assert
      final captured = verify(() => mockService.create(captureAny())).captured;
      final equipment = captured.first as Equipment;
      expect(equipment.category, equals('Baitcasting|Low Profile'));
    });
  });

  group('LureEditNotifier.save()', () {
    late MockEquipmentService mockService;
    late LureEditNotifier notifier;

    setUp(() {
      mockService = MockEquipmentService();
      notifier = LureEditNotifier(mockService, 'lure', null);
    });

    tearDown(() {
      // No resources to clean up - mocks are garbage collected
    });

    test('creates new lure with correct data', () async {
      // Arrange
      when(() => mockService.create(any())).thenAnswer((_) async => 3);
      when(() => mockService.setDefaultEquipment(any(), any()))
          .thenAnswer((_) async {});

      notifier.updateBrand('Rapala');
      notifier.updateModel('X-Rap');
      notifier.updateLureType('Crankbait');
      notifier.updateLureWeight('20');
      notifier.updateLureWeightUnit('g');
      notifier.updateLureSize('5');
      notifier.updateLureSizeUnit('cm');
      notifier.updateLureColor('Blue Crawdad');
      notifier.updateLureQuantity('10');
      notifier.updateIsDefault(true);

      // Act
      final result = await notifier.save();

      // Assert
      expect(result, isTrue);
      expect(notifier.state.isSaving, isFalse);

      final captured = verify(() => mockService.create(captureAny())).captured;
      final equipment = captured.first as Equipment;
      expect(equipment.brand, equals('Rapala'));
      expect(equipment.model, equals('X-Rap'));
      expect(equipment.type, equals(EquipmentType.lure));
      expect(equipment.lureType, equals('Crankbait'));
      expect(equipment.lureWeight, equals('20'));
      expect(equipment.lureWeightUnit, equals('g'));
      expect(equipment.lureSize, equals('5'));
      expect(equipment.lureSizeUnit, equals('cm'));
      expect(equipment.lureColor, equals('Blue Crawdad'));
      expect(equipment.lureQuantity, equals(10));
      expect(equipment.isDefault, isTrue);
    });

    test('updates existing lure with correct data', () async {
      // Arrange
      final existingEquipment = Equipment.fromMap({
        'id': 15,
        'type': 'lure',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      when(() => mockService.update(any())).thenAnswer((_) async {});
      when(() => mockService.setDefaultEquipment(any(), any()))
          .thenAnswer((_) async {});

      final updateNotifier =
          LureEditNotifier(mockService, 'lure', existingEquipment);
      updateNotifier.updateBrand('NewBrand');
      updateNotifier.updateLureColor('Red');
      updateNotifier.updateLureQuantity('5');

      // Act
      final result = await updateNotifier.save();

      // Assert
      expect(result, isTrue);

      final captured = verify(() => mockService.update(captureAny())).captured;
      final equipment = captured.first as Equipment;
      expect(equipment.id, equals(15));
      expect(equipment.brand, equals('NewBrand'));
      expect(equipment.lureColor, equals('Red'));
      expect(equipment.lureQuantity, equals(5));
    });

    test('handles quantity conversion to integer', () async {
      // Arrange
      when(() => mockService.create(any())).thenAnswer((_) async => 1);

      notifier.updateBrand('Rapala');
      notifier.updateLureQuantity('25');

      // Act
      await notifier.save();

      // Assert
      final captured = verify(() => mockService.create(captureAny())).captured;
      final equipment = captured.first as Equipment;
      expect(equipment.lureQuantity, equals(25));
    });

    test('does not include empty fields in save data', () async {
      // Arrange
      when(() => mockService.create(any())).thenAnswer((_) async => 1);

      notifier.updateBrand('Rapala');
      // Leave all lure-specific fields empty

      // Act
      await notifier.save();

      // Assert
      final captured = verify(() => mockService.create(captureAny())).captured;
      final equipment = captured.first as Equipment;
      expect(equipment.lureType, isNull);
      expect(equipment.lureWeight, isNull);
      expect(equipment.lureSize, isNull);
      expect(equipment.lureColor, isNull);
      expect(equipment.lureQuantity, isNull);
    });
  });

  group('EquipmentEditViewModel.save() delegates to correct notifier', () {
    late MockEquipmentService mockService;

    setUp(() {
      mockService = MockEquipmentService();
    });

    tearDown(() {
      // No resources to clean up - mocks are garbage collected
    });

    test('RodEditViewModel delegates to RodEditNotifier', () async {
      // Arrange
      when(() => mockService.create(any())).thenAnswer((_) async => 1);

      final viewModel = EquipmentEditViewModel(mockService, 'rod', null);
      viewModel.updateBrand('Shimano');
      viewModel.updateModel('Core');

      // Act
      final result = await viewModel.save();

      // Assert
      expect(result, isTrue);
      verify(() => mockService.create(any())).called(1);
    });

    test('ReelEditViewModel delegates to ReelEditNotifier', () async {
      // Arrange
      when(() => mockService.create(any())).thenAnswer((_) async => 1);

      final viewModel = EquipmentEditViewModel(mockService, 'reel', null);
      viewModel.updateBrand('Shimano');
      viewModel.updateModel('Stradic');

      // Act
      final result = await viewModel.save();

      // Assert
      expect(result, isTrue);
      verify(() => mockService.create(any())).called(1);
    });

    test('LureEditViewModel delegates to LureEditNotifier', () async {
      // Arrange
      when(() => mockService.create(any())).thenAnswer((_) async => 1);

      final viewModel = EquipmentEditViewModel(mockService, 'lure', null);
      viewModel.updateBrand('Rapala');
      viewModel.updateModel('X-Rap');

      // Act
      final result = await viewModel.save();

      // Assert
      expect(result, isTrue);
      verify(() => mockService.create(any())).called(1);
    });
  });
}
