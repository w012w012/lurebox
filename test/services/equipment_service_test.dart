import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/models/paginated_result.dart';
import 'package:lurebox/core/repositories/equipment_repository.dart';
import 'package:lurebox/core/services/equipment_service.dart';

class MockEquipmentRepository extends Mock implements EquipmentRepository {}

class FakeEquipment extends Fake implements Equipment {}

Equipment createEquipment({
  int id = 1,
  EquipmentType type = EquipmentType.rod,
  String brand = 'TestBrand',
  String model = 'TestModel',
}) {
  return Equipment(
    id: id,
    type: type,
    brand: brand,
    model: model,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

void main() {
  late EquipmentService service;
  late MockEquipmentRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeEquipment());
  });

  setUp(() {
    mockRepository = MockEquipmentRepository();
    service = EquipmentService(mockRepository);
  });

  group('EquipmentService', () {
    group('create', () {
      test('delegates to repository create', () async {
        // Arrange
        final equipment = createEquipment(id: 1);
        when(() => mockRepository.create(any())).thenAnswer((_) async => 1);

        // Act
        final result = await service.create(equipment);

        // Assert
        expect(result, equals(1));
        verify(() => mockRepository.create(equipment)).called(1);
      });
    });

    group('update', () {
      test('delegates to repository update', () async {
        // Arrange
        final equipment = createEquipment(id: 1);
        when(() => mockRepository.update(any())).thenAnswer((_) async {});

        // Act
        await service.update(equipment);

        // Assert
        verify(() => mockRepository.update(equipment)).called(1);
      });
    });

    group('delete', () {
      test('delegates to repository delete', () async {
        // Arrange
        when(() => mockRepository.delete(any())).thenAnswer((_) async {});

        // Act
        await service.delete(1);

        // Assert
        verify(() => mockRepository.delete(1)).called(1);
      });
    });

    group('getAll', () {
      test('delegates to repository getAll without type filter', () async {
        // Arrange
        final equipmentList = [
          createEquipment(id: 1),
          createEquipment(id: 2),
        ];
        when(() => mockRepository.getAll(type: any(named: 'type')))
            .thenAnswer((_) async => equipmentList);

        // Act
        final result = await service.getAll();

        // Assert
        expect(result, equals(equipmentList));
        verify(() => mockRepository.getAll(type: null)).called(1);
      });

      test('delegates to repository getAll with type filter', () async {
        // Arrange
        final equipmentList = [
          createEquipment(id: 1, type: EquipmentType.rod),
        ];
        when(() => mockRepository.getAll(type: any(named: 'type')))
            .thenAnswer((_) async => equipmentList);

        // Act
        final result = await service.getAll(type: 'rod');

        // Assert
        expect(result, equals(equipmentList));
        verify(() => mockRepository.getAll(type: 'rod')).called(1);
      });
    });

    group('getById', () {
      test('delegates to repository getById', () async {
        // Arrange
        final equipment = createEquipment(id: 1);
        when(() => mockRepository.getById(any()))
            .thenAnswer((_) async => equipment);

        // Act
        final result = await service.getById(1);

        // Assert
        expect(result, equals(equipment));
        verify(() => mockRepository.getById(1)).called(1);
      });

      test('returns null when equipment not found', () async {
        // Arrange
        when(() => mockRepository.getById(any())).thenAnswer((_) async => null);

        // Act
        final result = await service.getById(999);

        // Assert
        expect(result, isNull);
        verify(() => mockRepository.getById(999)).called(1);
      });
    });

    group('getDefaultEquipment', () {
      test('delegates to repository getDefaultEquipment', () async {
        // Arrange
        final equipment = createEquipment(
          id: 1,
          type: EquipmentType.rod,
          brand: 'Shimano',
        );
        when(() => mockRepository.getDefaultEquipment(any()))
            .thenAnswer((_) async => equipment);

        // Act
        final result = await service.getDefaultEquipment('rod');

        // Assert
        expect(result, equals(equipment));
        verify(() => mockRepository.getDefaultEquipment('rod')).called(1);
      });

      test('returns null when no default equipment found', () async {
        // Arrange
        when(() => mockRepository.getDefaultEquipment(any()))
            .thenAnswer((_) async => null);

        // Act
        final result = await service.getDefaultEquipment('reel');

        // Assert
        expect(result, isNull);
        verify(() => mockRepository.getDefaultEquipment('reel')).called(1);
      });
    });

    group('setDefaultEquipment', () {
      test('delegates to repository setDefaultEquipment', () async {
        // Arrange
        when(() => mockRepository.setDefaultEquipment(any(), any()))
            .thenAnswer((_) async {});

        // Act
        await service.setDefaultEquipment(1, 'rod');

        // Assert
        verify(() => mockRepository.setDefaultEquipment(1, 'rod')).called(1);
      });
    });

    group('getPage', () {
      test('delegates to repository getPage with default parameters', () async {
        // Arrange
        final equipmentList = [
          createEquipment(id: 1),
          createEquipment(id: 2),
        ];
        final PaginatedResult<Equipment> paginatedResult = PaginatedResult(
          items: equipmentList,
          totalCount: 2,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              type: any(named: 'type'),
              orderBy: any(named: 'orderBy'),
            )).thenAnswer((_) async => paginatedResult);

        // Act
        final result = await service.getPage(page: 1);

        // Assert
        expect(result, equals(paginatedResult));
        verify(() => mockRepository.getPage(
              page: 1,
              pageSize: 20,
              type: null,
              orderBy: 'is_default DESC, created_at DESC',
            )).called(1);
      });

      test('delegates to repository getPage with custom parameters', () async {
        // Arrange
        final PaginatedResult<Equipment> paginatedResult = PaginatedResult(
          items: [],
          totalCount: 0,
          page: 2,
          pageSize: 10,
          hasMore: false,
        );
        when(() => mockRepository.getPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              type: any(named: 'type'),
              orderBy: any(named: 'orderBy'),
            )).thenAnswer((_) async => paginatedResult);

        // Act
        final result = await service.getPage(
          page: 2,
          pageSize: 10,
          type: 'reel',
          orderBy: 'created_at ASC',
        );

        // Assert
        expect(result, equals(paginatedResult));
        verify(() => mockRepository.getPage(
              page: 2,
              pageSize: 10,
              type: 'reel',
              orderBy: 'created_at ASC',
            )).called(1);
      });
    });

    group('getFilteredPage', () {
      test('delegates to repository getFilteredPage with all filters',
          () async {
        // Arrange
        final equipmentList = [
          createEquipment(
            id: 1,
            type: EquipmentType.rod,
            brand: 'Shimano',
            model: 'Tournament',
          ),
        ];
        final PaginatedResult<Equipment> paginatedResult = PaginatedResult(
          items: equipmentList,
          totalCount: 1,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );
        when(() => mockRepository.getFilteredPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              type: any(named: 'type'),
              brand: any(named: 'brand'),
              model: any(named: 'model'),
              category: any(named: 'category'),
              orderBy: any(named: 'orderBy'),
            )).thenAnswer((_) async => paginatedResult);

        // Act
        final result = await service.getFilteredPage(
          page: 1,
          pageSize: 20,
          type: 'rod',
          brand: 'Shimano',
          model: 'Tournament',
          category: 'spinning',
        );

        // Assert
        expect(result, equals(paginatedResult));
        verify(() => mockRepository.getFilteredPage(
              page: 1,
              pageSize: 20,
              type: 'rod',
              brand: 'Shimano',
              model: 'Tournament',
              category: 'spinning',
              orderBy: 'is_default DESC, created_at DESC',
            )).called(1);
      });

      test('delegates to repository getFilteredPage with partial filters',
          () async {
        // Arrange
        final PaginatedResult<Equipment> paginatedResult = PaginatedResult(
          items: [],
          totalCount: 0,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );
        when(() => mockRepository.getFilteredPage(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              type: any(named: 'type'),
              brand: any(named: 'brand'),
              model: any(named: 'model'),
              category: any(named: 'category'),
              orderBy: any(named: 'orderBy'),
            )).thenAnswer((_) async => paginatedResult);

        // Act
        final result = await service.getFilteredPage(
          page: 1,
          brand: 'Shimano',
        );

        // Assert
        expect(result, equals(paginatedResult));
        verify(() => mockRepository.getFilteredPage(
              page: 1,
              pageSize: 20,
              type: null,
              brand: 'Shimano',
              model: null,
              category: null,
              orderBy: 'is_default DESC, created_at DESC',
            )).called(1);
      });
    });

    group('getStats', () {
      test('delegates to repository getStats', () async {
        // Arrange
        final stats = {'rod': 5, 'reel': 3, 'lure': 20};
        when(() => mockRepository.getStats()).thenAnswer((_) async => stats);

        // Act
        final result = await service.getStats();

        // Assert
        expect(result, equals(stats));
        verify(() => mockRepository.getStats()).called(1);
      });
    });

    group('getBrands', () {
      test('delegates to repository getBrands', () async {
        // Arrange
        final brands = ['Shimano', 'Abu Garcia', 'Daiwa'];
        when(() => mockRepository.getBrands()).thenAnswer((_) async => brands);

        // Act
        final result = await service.getBrands();

        // Assert
        expect(result, equals(brands));
        verify(() => mockRepository.getBrands()).called(1);
      });
    });

    group('getModelsByBrand', () {
      test('delegates to repository getModelsByBrand', () async {
        // Arrange
        final models = ['Tournament', 'Stradivic', 'Antares'];
        when(() => mockRepository.getModelsByBrand(any()))
            .thenAnswer((_) async => models);

        // Act
        final result = await service.getModelsByBrand('Shimano');

        // Assert
        expect(result, equals(models));
        verify(() => mockRepository.getModelsByBrand('Shimano')).called(1);
      });
    });

    group('getCategoryDistribution', () {
      test('delegates to repository getCategoryDistribution', () async {
        // Arrange
        final distribution = {'spinning': 10, 'casting': 5};
        when(() => mockRepository.getCategoryDistribution(any()))
            .thenAnswer((_) async => distribution);

        // Act
        final result = await service.getCategoryDistribution('rod');

        // Assert
        expect(result, equals(distribution));
        verify(() => mockRepository.getCategoryDistribution('rod')).called(1);
      });
    });
  });
}
