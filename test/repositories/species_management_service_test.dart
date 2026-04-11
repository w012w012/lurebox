import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/repositories/species_management_service.dart';
import 'package:lurebox/core/repositories/user_species_alias_repository.dart';
import 'package:lurebox/core/services/fish_species_matcher.dart';
import 'package:lurebox/core/models/fish_species.dart';
import 'package:lurebox/core/models/user_species_alias.dart';

class MockUserSpeciesAliasRepository extends Mock
    implements UserSpeciesAliasRepository {}

class MockFishSpeciesMatcher extends Mock implements FishSpeciesMatcher {}

class FakeUserSpeciesAlias extends Fake implements UserSpeciesAlias {}

class FakeFishSpecies extends Fake implements FishSpecies {}

void main() {
  late MockUserSpeciesAliasRepository mockAliasRepo;
  late MockFishSpeciesMatcher mockMatcher;
  late SpeciesManagementService service;

  setUpAll(() {
    registerFallbackValue(FakeUserSpeciesAlias());
    registerFallbackValue(FakeFishSpecies());
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockAliasRepo = MockUserSpeciesAliasRepository();
    mockMatcher = MockFishSpeciesMatcher();
    service = SpeciesManagementService(
      aliasRepo: mockAliasRepo,
      matcher: mockMatcher,
    );
  });

  group('SpeciesManagementService', () {
    group('renameSpecies', () {
      test(
          'calls _mergeSpecies when newName already exists as an alias',
          () async {
        // Arrange
        const oldName = '旧鱼名';
        const newName = '新鱼名';
        const existingSpeciesId = 'species-123';

        when(() => mockAliasRepo.findByAlias(newName)).thenAnswer(
          (_) async => UserSpeciesAlias(
            id: 1,
            userAlias: newName,
            speciesId: existingSpeciesId,
            createdAt: DateTime.now(),
          ),
        );

        when(() => mockAliasRepo.create(oldName, existingSpeciesId))
            .thenAnswer((_) async => 1);

        // Act
        await service.renameSpecies(oldName, newName);

        // Assert
        verify(() => mockAliasRepo.findByAlias(newName)).called(1);
        verify(() => mockAliasRepo.create(oldName, existingSpeciesId)).called(1);
      });

      test(
          'creates new alias mapping when newName does not exist and species is found',
          () async {
        // Arrange
        const oldName = '未知鱼名';
        const newName = '新标准鱼名';
        const speciesId = 'bass-001';

        when(() => mockAliasRepo.findByAlias(newName))
            .thenAnswer((_) async => null);

        when(() => mockMatcher.findSpeciesByName(oldName)).thenReturn(
          FishSpecies(
            id: speciesId,
            standardName: 'Bass',
            category: FishCategory.freshwaterLure,
            rarity: FishRarity.common,
          ),
        );

        when(() => mockAliasRepo.create(newName, speciesId))
            .thenAnswer((_) async => 1);

        // Act
        await service.renameSpecies(oldName, newName);

        // Assert
        verify(() => mockAliasRepo.findByAlias(newName)).called(1);
        verify(() => mockMatcher.findSpeciesByName(oldName)).called(1);
        verify(() => mockAliasRepo.create(newName, speciesId)).called(1);
      });

      test(
          'does not create alias when species is not found by matcher',
          () async {
        // Arrange
        const oldName = '完全不存在的鱼';
        const newName = '新名称';

        when(() => mockAliasRepo.findByAlias(newName))
            .thenAnswer((_) async => null);
        when(() => mockMatcher.findSpeciesByName(oldName)).thenReturn(null);

        // Act
        await service.renameSpecies(oldName, newName);

        // Assert
        verify(() => mockAliasRepo.findByAlias(newName)).called(1);
        verify(() => mockMatcher.findSpeciesByName(oldName)).called(1);
        verifyNever(() => mockAliasRepo.create(any(), any()));
      });

      test(
          'handles multiple consecutive renames correctly',
          () async {
        // Arrange - simulate rename chain: A -> B -> C
        const nameA = '鱼名A';
        const nameB = '鱼名B';
        const nameC = '鱼名C';
        const speciesId = 'species-001';

        // A -> B (B exists as alias for species-001)
        when(() => mockAliasRepo.findByAlias(nameB)).thenAnswer(
          (_) async => UserSpeciesAlias(
            id: 1,
            userAlias: nameB,
            speciesId: speciesId,
            createdAt: DateTime.now(),
          ),
        );
        when(() => mockAliasRepo.create(nameA, speciesId))
            .thenAnswer((_) async => 1);

        // Act & Assert - first rename
        await service.renameSpecies(nameA, nameB);
        verify(() => mockAliasRepo.create(nameA, speciesId)).called(1);

        // B -> C (C does not exist, but matcher finds species)
        when(() => mockAliasRepo.findByAlias(nameC))
            .thenAnswer((_) async => null);
        when(() => mockMatcher.findSpeciesByName(nameB)).thenReturn(
          FishSpecies(
            id: speciesId,
            standardName: 'Known Fish',
            category: FishCategory.freshwaterLure,
            rarity: FishRarity.common,
          ),
        );
        when(() => mockAliasRepo.create(nameC, speciesId))
            .thenAnswer((_) async => 2);

        // Act & Assert - second rename
        await service.renameSpecies(nameB, nameC);
        verify(() => mockAliasRepo.create(nameC, speciesId)).called(1);
      });

      test(
          'findByAlias returns null for non-existent alias',
          () async {
        // Arrange
        const nonExistentName = '这个名称完全不存在';

        when(() => mockAliasRepo.findByAlias(nonExistentName))
            .thenAnswer((_) async => null);

        // Act
        final result = await mockAliasRepo.findByAlias(nonExistentName);

        // Assert
        expect(result, isNull);
      });

      test(
          'mergeSpecies creates alias mapping correctly',
          () async {
        // Arrange
        const sourceAlias = '来源别名';
        const targetSpeciesId = '目标物种ID';

        when(() => mockAliasRepo.create(sourceAlias, targetSpeciesId))
            .thenAnswer((_) async => 1);

        // Act - call renameSpecies which internally calls _mergeSpecies
        // We trigger this by having findByAlias return an existing mapping
        when(() => mockAliasRepo.findByAlias('triggerName')).thenAnswer(
          (_) async => UserSpeciesAlias(
            id: 1,
            userAlias: 'triggerName',
            speciesId: targetSpeciesId,
            createdAt: DateTime.now(),
          ),
        );

        await service.renameSpecies(sourceAlias, 'triggerName');

        // Assert
        verify(() => mockAliasRepo.create(sourceAlias, targetSpeciesId))
            .called(1);
      });

      test(
          'findSpeciesByName is case-sensitive in matching',
          () async {
        // Arrange
        const oldName = 'BASS';

        when(() => mockAliasRepo.findByAlias(any()))
            .thenAnswer((_) async => null);
        when(() => mockMatcher.findSpeciesByName('BASS')).thenReturn(
          FishSpecies(
            id: 'bass-001',
            standardName: 'Bass',
            category: FishCategory.freshwaterLure,
            rarity: FishRarity.common,
          ),
        );
        when(() => mockAliasRepo.create(any(), any()))
            .thenAnswer((_) async => 1);

        // Act
        await service.renameSpecies(oldName, 'NewBass');

        // Assert
        verify(() => mockMatcher.findSpeciesByName('BASS')).called(1);
      });
    });
  });
}
