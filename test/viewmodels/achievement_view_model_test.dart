import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/achievement.dart';
import 'package:lurebox/core/providers/achievement_view_model.dart';
import 'package:lurebox/core/services/achievement_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAchievementService extends Mock implements AchievementService {}

class FakeAchievement extends Fake implements Achievement {}

void main() {
  late MockAchievementService mockService;
  late AchievementViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(FakeAchievement());
  });

  setUp(() {
    mockService = MockAchievementService();
  });

  tearDown(() {
    try {
      viewModel.dispose();
    } catch (_) {
      // viewModel may not be initialized in all tests
    }
  });

  Achievement createAchievement({
    String id = 'test_achievement',
    String title = 'Test Achievement',
    String description = 'Test description',
    String icon = '🏆',
    AchievementLevel level = AchievementLevel.bronze,
    String category = 'catch',
    int target = 10,
    int current = 5,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      level: level,
      category: category,
      target: target,
      current: current,
      unlockedAt: unlockedAt,
      progress: target > 0 ? (current / target * 100) : 0,
    );
  }

  group('AchievementViewModel', () {
    group('initial state', () {
      test('has correct default values before loading', () {
        viewModel = AchievementViewModel(mockService);

        expect(viewModel.state.achievements, isEmpty);
        expect(viewModel.state.filteredAchievements, isEmpty);
        expect(viewModel.state.category, AchievementCategory.all);
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, isNull);
        expect(viewModel.state.progress, isEmpty);
      });

      test('has correct unlockedCount and lockedCount before loading', () {
        viewModel = AchievementViewModel(mockService);

        expect(viewModel.state.unlockedCount, 0);
        expect(viewModel.state.lockedCount, 0);
        expect(viewModel.state.unlockProgress, 0);
      });
    });

    group('loadAchievements', () {
      test('loads achievements successfully', () async {
        final achievements = [
          createAchievement(
              id: 'catch_1',
              current: 10,
              unlockedAt: DateTime.now(),),
          createAchievement(id: 'catch_2'),
          createAchievement(id: 'length_1', current: 3, target: 30),
        ];

        when(() => mockService.getAllAchievements())
            .thenAnswer((_) async => achievements);

        viewModel = AchievementViewModel(mockService);
        await viewModel.loadAchievements();

        expect(viewModel.state.achievements.length, 3);
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, isNull);
        expect(viewModel.state.progress['catch_1'], 10);
        expect(viewModel.state.progress['catch_2'], 5);
        verify(() => mockService.getAllAchievements()).called(1);
      });

      test('handles error when loading achievements fails', () async {
        when(() => mockService.getAllAchievements())
            .thenThrow(Exception('Failed to load'));

        viewModel = AchievementViewModel(mockService);
        await viewModel.loadAchievements();

        expect(viewModel.state.achievements, isEmpty);
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, isNotNull);
        expect(viewModel.state.errorMessage, contains('Failed to load'));
        verify(() => mockService.getAllAchievements()).called(1);
      });

      test('filters achievements by category when setCategory is called',
          () async {
        final achievements = [
          createAchievement(id: 'catch_1'),
          createAchievement(id: 'catch_2'),
          createAchievement(id: 'species_1', category: 'species'),
          createAchievement(id: 'equipment_1', category: 'equipment'),
        ];

        when(() => mockService.getAllAchievements())
            .thenAnswer((_) async => achievements);

        viewModel = AchievementViewModel(mockService);
        await viewModel.loadAchievements();

        viewModel.setCategory(AchievementCategory.catchCount);

        expect(viewModel.state.filteredAchievements.length, 2);
        expect(
            viewModel.state.filteredAchievements
                .every((a) => a.category == 'catch'),
            true,);
        expect(viewModel.state.category, AchievementCategory.catchCount);
      });

      test('shows all achievements when category is all', () async {
        final achievements = [
          createAchievement(id: 'catch_1'),
          createAchievement(id: 'species_1', category: 'species'),
        ];

        when(() => mockService.getAllAchievements())
            .thenAnswer((_) async => achievements);

        viewModel = AchievementViewModel(mockService);
        await viewModel.loadAchievements();

        viewModel.setCategory(AchievementCategory.all);

        expect(viewModel.state.filteredAchievements.length, 2);
      });
    });

    group('AchievementState getters', () {
      test('unlockedCount returns correct count', () async {
        final achievements = [
          createAchievement(id: 'a1', current: 10),
          createAchievement(id: 'a2'),
          createAchievement(id: 'a3', current: 10),
        ];

        when(() => mockService.getAllAchievements())
            .thenAnswer((_) async => achievements);

        viewModel = AchievementViewModel(mockService);
        await viewModel.loadAchievements();

        expect(viewModel.state.unlockedCount, 2);
        expect(viewModel.state.lockedCount, 1);
      });

      test('unlockProgress returns correct percentage', () async {
        final achievements = [
          createAchievement(id: 'a1', current: 10),
          createAchievement(id: 'a2'),
        ];

        when(() => mockService.getAllAchievements())
            .thenAnswer((_) async => achievements);

        viewModel = AchievementViewModel(mockService);
        await viewModel.loadAchievements();

        expect(viewModel.state.unlockProgress, 0.5);
      });

      test('unlockProgress returns 0 when no achievements', () async {
        when(() => mockService.getAllAchievements())
            .thenAnswer((_) async => []);

        viewModel = AchievementViewModel(mockService);
        await viewModel.loadAchievements();

        expect(viewModel.state.unlockProgress, 0);
      });
    });

    group('getProgress', () {
      test('returns progress for existing achievement id', () async {
        final achievements = [
          createAchievement(id: 'catch_1', current: 7),
        ];

        when(() => mockService.getAllAchievements())
            .thenAnswer((_) async => achievements);

        viewModel = AchievementViewModel(mockService);
        await viewModel.loadAchievements();

        expect(viewModel.getProgress('catch_1'), 7);
      });

      test('returns 0 for non-existing achievement id', () async {
        when(() => mockService.getAllAchievements())
            .thenAnswer((_) async => []);

        viewModel = AchievementViewModel(mockService);
        await viewModel.loadAchievements();

        expect(viewModel.getProgress('non_existing'), 0);
      });
    });

    group('isUnlocked', () {
      test('returns true for unlocked achievement', () async {
        final achievements = [
          createAchievement(id: 'catch_1', current: 10),
        ];

        when(() => mockService.getAllAchievements())
            .thenAnswer((_) async => achievements);

        viewModel = AchievementViewModel(mockService);
        await viewModel.loadAchievements();

        expect(viewModel.isUnlocked('catch_1'), true);
      });

      test('returns false for locked achievement', () async {
        final achievements = [
          createAchievement(id: 'catch_1'),
        ];

        when(() => mockService.getAllAchievements())
            .thenAnswer((_) async => achievements);

        viewModel = AchievementViewModel(mockService);
        await viewModel.loadAchievements();

        expect(viewModel.isUnlocked('catch_1'), false);
      });

      test('returns false for non-existing achievement id', () async {
        when(() => mockService.getAllAchievements())
            .thenAnswer((_) async => []);

        viewModel = AchievementViewModel(mockService);
        await viewModel.loadAchievements();

        expect(viewModel.isUnlocked('non_existing'), false);
      });
    });

    group('AchievementCategory enum', () {
      test('has all category values', () {
        expect(AchievementCategory.values, contains(AchievementCategory.all));
        expect(AchievementCategory.values,
            contains(AchievementCategory.catchCount),);
        expect(
            AchievementCategory.values, contains(AchievementCategory.species),);
        expect(AchievementCategory.values,
            contains(AchievementCategory.equipment),);
        expect(
            AchievementCategory.values, contains(AchievementCategory.location),);
        expect(
            AchievementCategory.values, contains(AchievementCategory.release),);
        expect(
            AchievementCategory.values, contains(AchievementCategory.special),);
      });

      test('category values have correct string representations', () {
        expect(AchievementCategory.all.value, '');
        expect(AchievementCategory.catchCount.value, 'catch');
        expect(AchievementCategory.species.value, 'species');
        expect(AchievementCategory.equipment.value, 'equipment');
        expect(AchievementCategory.location.value, 'location');
        expect(AchievementCategory.release.value, 'release');
        expect(AchievementCategory.special.value, 'special');
      });
    });
  });

  group('Achievement model', () {
    test('isUnlocked returns true when current >= target', () {
      final achievement = createAchievement(current: 10);
      expect(achievement.isUnlocked, true);
    });

    test('isLocked returns true when current < target', () {
      final achievement = createAchievement();
      expect(achievement.isLocked, true);
    });

    test('progressPercent calculates correctly', () {
      final achievement = createAchievement(current: 50, target: 100);
      expect(achievement.progressPercent, 50.0);
    });

    test('progressPercent clamps to 100 when current exceeds target', () {
      final achievement = createAchievement(current: 150, target: 100);
      expect(achievement.progressPercent, 100.0);
    });

    test('progressPercent returns 0 when target is 0', () {
      final achievement = createAchievement(target: 0);
      expect(achievement.progressPercent, 0.0);
    });

    test('copyWith creates new instance with updated values', () {
      final original = createAchievement(id: 'original');
      final copied = original.copyWith(current: 10);

      expect(copied.id, 'original');
      expect(copied.current, 10);
      expect(original.current, 5);
    });
  });
}
