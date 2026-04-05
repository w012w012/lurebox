import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/models/user_species_alias.dart';
import 'package:lurebox/core/repositories/user_species_alias_repository.dart';
import 'package:lurebox/core/repositories/species_management_service.dart';
import 'package:lurebox/core/services/fish_species_matcher.dart';

// Mock classes
class MockUserSpeciesAliasRepository extends Mock
    implements UserSpeciesAliasRepository {}

void main() {
  late MockUserSpeciesAliasRepository mockAliasRepo;
  late FishSpeciesMatcher matcher;
  late SpeciesManagementService service;

  setUpAll(() {
    mockAliasRepo = MockUserSpeciesAliasRepository();
    // Use FishSpeciesMatcher with default species data
    matcher = FishSpeciesMatcher();
    service = SpeciesManagementService(
      aliasRepo: mockAliasRepo,
      matcher: matcher,
    );
  });

  setUp(() {
    reset(mockAliasRepo);
  });

  group('SpeciesManagementService', () {
    group('renameSpecies', () {
      test('creates new alias mapping when newName does not exist', () async {
        // Arrange
        const oldName = '桂鱼';
        const newName = '新桂鱼';

        // Mock: newName does not have existing alias mapping
        when(() => mockAliasRepo.findByAlias(newName))
            .thenAnswer((_) async => null);

        // Mock: oldName maps to a valid species (e.g., 鳜鱼)
        when(() => mockAliasRepo.create(newName, any()))
            .thenAnswer((_) async => 1);

        // Act
        await service.renameSpecies(oldName, newName);

        // Assert
        verify(() => mockAliasRepo.findByAlias(newName)).called(1);
        verify(() => mockAliasRepo.create(newName, any())).called(1);
      });

      test('merges species when newName already has an alias mapping',
          () async {
        // Arrange
        const oldName = '桂鱼';
        const newName = '新桂鱼';
        const existingSpeciesId = 'bass';

        // Mock: newName already has an alias mapping
        final existingAlias = UserSpeciesAlias(
          id: 1,
          userAlias: newName,
          speciesId: existingSpeciesId,
          createdAt: DateTime.now(),
        );
        when(() => mockAliasRepo.findByAlias(newName))
            .thenAnswer((_) async => existingAlias);

        // Mock: merge should create mapping from oldName to existing speciesId
        when(() => mockAliasRepo.create(oldName, existingSpeciesId))
            .thenAnswer((_) async => 2);

        // Act
        await service.renameSpecies(oldName, newName);

        // Assert
        verify(() => mockAliasRepo.findByAlias(newName)).called(1);
        verify(() => mockAliasRepo.create(oldName, existingSpeciesId))
            .called(1);
      });

      test('does not create alias when oldName has no matching species',
          () async {
        // Arrange
        const oldName = '完全不存在的鱼名';
        const newName = '新名字';

        // Mock: newName does not have existing alias mapping
        when(() => mockAliasRepo.findByAlias(newName))
            .thenAnswer((_) async => null);

        // Mock: FishSpeciesMatcher returns null for unknown name
        // (no need to mock create since it shouldn't be called)

        // Act
        await service.renameSpecies(oldName, newName);

        // Assert
        verify(() => mockAliasRepo.findByAlias(newName)).called(1);
        verifyNever(() => mockAliasRepo.create(any(), any()));
      });
    });

    group('FishSpeciesMatcher', () {
      test('findSpeciesByName returns species for 桂鱼', () {
        // The FishGuideData should contain 桂鱼 as an alias for 鳜鱼
        final species = matcher.findSpeciesByName('桂鱼');
        expect(species, isNotNull);
        expect(species!.standardName, equals('鳜鱼'));
      });

      test('findSpeciesByName returns species for exact match', () {
        final species = matcher.findSpeciesByName('鳜鱼');
        expect(species, isNotNull);
        expect(species!.standardName, equals('鳜鱼'));
      });

      test('findSpeciesByName returns null for unknown species', () {
        final species = matcher.findSpeciesByName('未知鱼种');
        expect(species, isNull);
      });
    });
  });
}
