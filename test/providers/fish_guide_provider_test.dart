import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/providers/fish_guide_provider.dart';
import 'package:lurebox/core/models/fish_species.dart';
import 'package:lurebox/core/services/fish_species_matcher.dart';
import 'package:lurebox/core/services/fish_species_stats_service.dart';
import 'package:lurebox/core/repositories/fish_catch_repository.dart';

class MockFishCatchRepository extends Mock implements FishCatchRepository {}

class FakeFishSpecies extends Fake implements FishSpecies {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeFishSpecies());
  });

  late FishGuideNotifier notifier;
  late MockFishCatchRepository mockRepository;
  late FishSpeciesMatcher matcher;
  late FishSpeciesStatsService statsService;

  setUp(() {
    mockRepository = MockFishCatchRepository();
    matcher = FishSpeciesMatcher();
    statsService = FishSpeciesStatsService(mockRepository, matcher);

    // Default mock behavior - return empty stats
    when(() => mockRepository.getAll()).thenAnswer((_) async => []);

    notifier = FishGuideNotifier(statsService);
  });

  group('FishGuideNotifier', () {
    group('initial state', () {
      test('has correct default values', () async {
        // Wait for initial async load to complete
        await Future.delayed(Duration.zero);
        expect(notifier.state.categoryFilter, FishGuideCategoryFilter.all);
        expect(notifier.state.selectedSpecies, isNull);
        expect(notifier.state.speciesList,
            isNotEmpty); // After load, species should be populated
        expect(notifier.state.isLoading, false);
        expect(notifier.state.error, isNull);
        expect(
            notifier.state.unlockedCount, 0); // No catches, so nothing unlocked
        expect(notifier.state.totalCount,
            greaterThan(0)); // Should have loaded species
      });
    });

    group('setCategoryFilter', () {
      test('changes category filter to freshwater', () async {
        // Wait for initial load to complete first
        await Future.delayed(Duration.zero);

        expect(notifier.state.categoryFilter, FishGuideCategoryFilter.all);
        expect(notifier.state.isLoading, false);

        notifier.setCategoryFilter(FishGuideCategoryFilter.freshwater);

        // Should trigger async load
        expect(
            notifier.state.categoryFilter, FishGuideCategoryFilter.freshwater);
      });

      test('changes to unlocked filter', () async {
        notifier.setCategoryFilter(FishGuideCategoryFilter.unlocked);

        expect(notifier.state.categoryFilter, FishGuideCategoryFilter.unlocked);
      });

      test('changes to saltwater filter', () async {
        notifier.setCategoryFilter(FishGuideCategoryFilter.saltwater);

        expect(
            notifier.state.categoryFilter, FishGuideCategoryFilter.saltwater);
      });
    });

    group('selectSpecies', () {
      test('selects a species', () {
        final species = FishSpecies(
          id: 'f001',
          standardName: '鳜鱼',
          category: FishCategory.freshwaterLure,
          rarity: FishRarity.rare,
        );

        expect(notifier.state.selectedSpecies, isNull);

        notifier.selectSpecies(species);

        expect(notifier.state.selectedSpecies, species);
        expect(notifier.state.selectedSpecies?.standardName, '鳜鱼');
      });

      test('can change selection', () {
        final species1 = FishSpecies(
          id: 'f001',
          standardName: '鳜鱼',
          category: FishCategory.freshwaterLure,
          rarity: FishRarity.rare,
        );
        final species2 = FishSpecies(
          id: 'f002',
          standardName: '大口黑鲈',
          category: FishCategory.freshwaterLure,
          rarity: FishRarity.uncommon,
        );

        notifier.selectSpecies(species1);
        expect(notifier.state.selectedSpecies, species1);

        notifier.selectSpecies(species2);
        expect(notifier.state.selectedSpecies, species2);
      });
    });

    group('clearSelection', () {
      test('clears selected species', () {
        final species = FishSpecies(
          id: 'f001',
          standardName: '鳜鱼',
          category: FishCategory.freshwaterLure,
          rarity: FishRarity.rare,
        );

        notifier.selectSpecies(species);
        expect(notifier.state.selectedSpecies, species);

        notifier.clearSelection();

        expect(notifier.state.selectedSpecies, isNull);
      });
    });
  });

  group('FishGuideCategoryFilter', () {
    test('has correct filter values', () {
      expect(FishGuideCategoryFilter.values.length, 4);
      expect(FishGuideCategoryFilter.all.label, '全部');
      expect(FishGuideCategoryFilter.unlocked.label, '已解锁');
      expect(FishGuideCategoryFilter.freshwater.label, '淡水');
      expect(FishGuideCategoryFilter.saltwater.label, '海水');
    });
  });

  group('FishSpeciesWithStats', () {
    test('creates with species and stats', () {
      final species = FishSpecies(
        id: 'f001',
        standardName: '鳜鱼',
        category: FishCategory.freshwaterLure,
        rarity: FishRarity.rare,
      );
      const stats = FishSpeciesStats(
        speciesId: 'f001',
        speciesName: '鳜鱼',
        totalCount: 5,
        maxLength: 50.0,
        minLength: 30.0,
        avgLength: 40.0,
        isUnlocked: true,
      );

      final withStats = FishSpeciesWithStats(species: species, stats: stats);

      expect(withStats.species, species);
      expect(withStats.stats, stats);
    });

    test('equality based on species id', () {
      final species1 = FishSpecies(
        id: 'f001',
        standardName: '鳜鱼',
        category: FishCategory.freshwaterLure,
        rarity: FishRarity.rare,
      );
      final species2 = FishSpecies(
        id: 'f001',
        standardName: '桂鱼', // Different name but same id
        category: FishCategory.freshwaterLure,
        rarity: FishRarity.rare,
      );

      const stats = FishSpeciesStats(
        speciesId: 'f001',
        speciesName: '鳜鱼',
        totalCount: 5,
        maxLength: 50.0,
        minLength: 30.0,
        avgLength: 40.0,
        isUnlocked: true,
      );

      final withStats1 = FishSpeciesWithStats(species: species1, stats: stats);
      final withStats2 = FishSpeciesWithStats(species: species2, stats: stats);

      // Same id means equal
      expect(withStats1 == withStats2, isTrue);
      expect(withStats1.hashCode, withStats2.hashCode);
    });

    test('copyWith creates new instance with updated values', () {
      final species = FishSpecies(
        id: 'f001',
        standardName: '鳜鱼',
        category: FishCategory.freshwaterLure,
        rarity: FishRarity.rare,
      );
      const stats = FishSpeciesStats(
        speciesId: 'f001',
        speciesName: '鳜鱼',
        totalCount: 5,
        maxLength: 50.0,
        minLength: 30.0,
        avgLength: 40.0,
        isUnlocked: true,
      );

      final withStats = FishSpeciesWithStats(species: species, stats: stats);
      final newSpecies = FishSpecies(
        id: 'f002',
        standardName: '大口黑鲈',
        category: FishCategory.freshwaterLure,
        rarity: FishRarity.uncommon,
      );

      final copied = withStats.copyWith(species: newSpecies);

      expect(copied.species, newSpecies);
      expect(copied.stats, stats); // unchanged
    });
  });

  group('FishGuideState', () {
    test('copyWith creates new instance with updated values', () {
      const initialState = FishGuideState(
        categoryFilter: FishGuideCategoryFilter.all,
        isLoading: false,
      );

      final newState = initialState.copyWith(
        categoryFilter: FishGuideCategoryFilter.unlocked,
      );

      expect(newState.categoryFilter, FishGuideCategoryFilter.unlocked);
      expect(initialState.categoryFilter,
          FishGuideCategoryFilter.all); // unchanged
    });

    test('copyWith with selectedSpecies function', () {
      const initialState = FishGuideState();

      final species = FishSpecies(
        id: 'f001',
        standardName: '鳜鱼',
        category: FishCategory.freshwaterLure,
        rarity: FishRarity.rare,
      );

      final newState = initialState.copyWith(
        selectedSpecies: () => species,
      );

      expect(newState.selectedSpecies, species);
    });

    test('copyWith with error function', () {
      const initialState = FishGuideState();

      final newState = initialState.copyWith(
        error: () => 'Test error',
      );

      expect(newState.error, 'Test error');
    });
  });
}
