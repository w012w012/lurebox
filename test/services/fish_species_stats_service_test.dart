import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/repositories/fish_catch_repository.dart';
import 'package:lurebox/core/services/fish_species_matcher.dart';
import 'package:lurebox/core/services/fish_species_stats_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFishCatchRepository extends Mock implements FishCatchRepository {}

class FakeFishCatch extends Fake implements FishCatch {}

void main() {
  late FishSpeciesStatsService service;
  late MockFishCatchRepository mockRepository;
  late FishSpeciesMatcher matcher;

  setUpAll(() {
    registerFallbackValue(FakeFishCatch());
  });

  setUp(() {
    mockRepository = MockFishCatchRepository();
    matcher = FishSpeciesMatcher();
    service = FishSpeciesStatsService(mockRepository, matcher);
  });

  tearDown(() {
    // No resources to clean up - mocks are garbage collected
  });

  group('FishSpeciesStatsService', () {
    group('getStats', () {
      test('returns empty stats for unknown species', () async {
        // Arrange
        when(() => mockRepository.getAll()).thenAnswer((_) async => []);

        // Act
        final result = await service.getStats('未知鱼种');

        // Assert
        expect(result.speciesId, isEmpty);
        expect(result.speciesName, equals('未知鱼种'));
        expect(result.totalCount, equals(0));
        expect(result.isUnlocked, isFalse);
      });

      test('returns empty stats when no catches found for species', () async {
        // Arrange
        when(() => mockRepository.getAll()).thenAnswer((_) async => []);

        // Act
        final result = await service.getStats('鳜鱼');

        // Assert
        expect(result.speciesId, equals('f001'));
        expect(result.speciesName, equals('鳜鱼'));
        expect(result.totalCount, equals(0));
        expect(result.isUnlocked, isFalse);
      });

      test('returns correct stats for species with catches', () async {
        // Arrange
        final catches = [
          _createFishCatch(
            id: 1,
            species: '鳜鱼',
            length: 30,
            weight: 1.5,
            catchTime: DateTime(2024, 1, 15),
          ),
          _createFishCatch(
            id: 2,
            species: '鳜鱼',
            length: 45,
            weight: 2.5,
            catchTime: DateTime(2024, 2, 20),
          ),
          _createFishCatch(
            id: 3,
            species: '鳜鱼',
            length: 25,
            weight: 1,
            catchTime: DateTime(2024, 3, 10),
          ),
        ];
        when(() => mockRepository.getAll()).thenAnswer((_) async => catches);

        // Act
        final result = await service.getStats('鳜鱼');

        // Assert
        expect(result.speciesId, equals('f001'));
        expect(result.speciesName, equals('鳜鱼'));
        expect(result.totalCount, equals(3));
        expect(result.maxLength, equals(45.0));
        expect(result.minLength, equals(25.0));
        expect(result.avgLength, closeTo(33.33, 0.01)); // (30+45+25)/3 = 33.33
        expect(result.maxWeight, equals(2.5));
        expect(result.firstCaughtAt, equals(DateTime(2024, 1, 15)));
        expect(result.isUnlocked, isTrue);
      });

      test('finds species by alias', () async {
        // Arrange
        final catches = [
          _createFishCatch(
            id: 1,
            species: '桂鱼', // alias for 鳜鱼
            length: 35,
            catchTime: DateTime(2024),
          ),
        ];
        when(() => mockRepository.getAll()).thenAnswer((_) async => catches);

        // Act
        final result = await service.getStats('桂鱼');

        // Assert
        expect(result.speciesId, equals('f001'));
        expect(result.speciesName, equals('鳜鱼'));
        expect(result.totalCount, equals(1));
        expect(result.isUnlocked, isTrue);
      });

      test('handles catches with no weight', () async {
        // Arrange
        final catches = [
          _createFishCatch(
            id: 1,
            species: '鳜鱼',
            length: 30,
            catchTime: DateTime(2024),
          ),
          _createFishCatch(
            id: 2,
            species: '鳜鱼',
            length: 35,
            catchTime: DateTime(2024, 2),
          ),
        ];
        when(() => mockRepository.getAll()).thenAnswer((_) async => catches);

        // Act
        final result = await service.getStats('鳜鱼');

        // Assert
        expect(result.maxWeight, isNull);
        expect(result.totalCount, equals(2));
      });

      test('handles single catch', () async {
        // Arrange
        final catches = [
          _createFishCatch(
            id: 1,
            species: '鳜鱼',
            length: 40,
            weight: 2,
            catchTime: DateTime(2024, 6, 15),
          ),
        ];
        when(() => mockRepository.getAll()).thenAnswer((_) async => catches);

        // Act
        final result = await service.getStats('鳜鱼');

        // Assert
        expect(result.totalCount, equals(1));
        expect(result.maxLength, equals(40.0));
        expect(result.minLength, equals(40.0));
        expect(result.avgLength, equals(40.0));
        expect(result.maxWeight, equals(2.0));
        expect(result.firstCaughtAt, equals(DateTime(2024, 6, 15)));
      });

      test('filters catches by standard name and aliases', () async {
        // Arrange - catches using both standard name and aliases
        final catches = [
          _createFishCatch(id: 1, species: '鳜鱼', length: 30), // standard name
          _createFishCatch(id: 2, species: '桂鱼', length: 35), // alias
          _createFishCatch(
              id: 3, species: '桂花鱼', length: 40,), // another alias
          _createFishCatch(
              id: 4, species: '其他鱼', length: 25,), // different species
        ];
        when(() => mockRepository.getAll()).thenAnswer((_) async => catches);

        // Act
        final result = await service.getStats('鳜鱼');

        // Assert - should only count the 3 matching catches
        expect(result.totalCount, equals(3));
        expect(result.maxLength, equals(40.0));
        expect(result.minLength, equals(30.0));
      });
    });

    group('getSizeDistribution', () {
      test('returns empty buckets when no catches found', () async {
        // Arrange
        when(() => mockRepository.getAll()).thenAnswer((_) async => []);

        // Act
        final result = await service.getSizeDistribution('鳜鱼');

        // Assert
        expect(result, hasLength(5));
        expect(result[0].range, equals('10-20'));
        expect(result[0].count, equals(0));
      });

      test('returns correct distribution for catches', () async {
        // Arrange
        final catches = [
          _createFishCatch(id: 1, species: '鳜鱼', length: 15), // 10-20
          _createFishCatch(id: 2, species: '鳜鱼', length: 18), // 10-20
          _createFishCatch(id: 3, species: '鳜鱼', length: 25), // 20-30
          _createFishCatch(id: 4, species: '鳜鱼', length: 35), // 30-40
          _createFishCatch(id: 5, species: '鳜鱼', length: 45), // 40-50
          _createFishCatch(id: 6, species: '鳜鱼', length: 55), // 50+
          _createFishCatch(id: 7, species: '鳜鱼', length: 60), // 50+
        ];
        when(() => mockRepository.getAll()).thenAnswer((_) async => catches);

        // Act
        final result = await service.getSizeDistribution('鳜鱼');

        // Assert
        expect(result, hasLength(5));
        expect(result[0].range, equals('10-20'));
        expect(result[0].count, equals(2));
        expect(result[1].range, equals('20-30'));
        expect(result[1].count, equals(1));
        expect(result[2].range, equals('30-40'));
        expect(result[2].count, equals(1));
        expect(result[3].range, equals('40-50'));
        expect(result[3].count, equals(1));
        expect(result[4].range, equals('50+'));
        expect(result[4].count, equals(2));
      });

      test('handles boundary values correctly', () async {
        // Arrange - catches at exact boundaries
        final catches = [
          _createFishCatch(
              id: 1, species: '鳜鱼', length: 10,), // should be in 10-20
          _createFishCatch(
              id: 2, species: '鳜鱼', length: 20,), // should be in 20-30
          _createFishCatch(
              id: 3, species: '鳜鱼', length: 30,), // should be in 30-40
          _createFishCatch(
              id: 4, species: '鳜鱼', length: 40,), // should be in 40-50
          _createFishCatch(
              id: 5, species: '鳜鱼', length: 50,), // should be in 50+
        ];
        when(() => mockRepository.getAll()).thenAnswer((_) async => catches);

        // Act
        final result = await service.getSizeDistribution('鳜鱼');

        // Assert
        expect(result[0].count, equals(1)); // 10-19.99 (10.0)
        expect(result[1].count, equals(1)); // 20-29.99 (20.0)
        expect(result[2].count, equals(1)); // 30-39.99 (30.0)
        expect(result[3].count, equals(1)); // 40-49.99 (40.0)
        expect(result[4].count, equals(1)); // 50+ (50.0)
      });

      test('returns empty buckets for unknown species name', () async {
        // Arrange
        when(() => mockRepository.getAll()).thenAnswer((_) async => []);

        // Act
        final result = await service.getSizeDistribution('未知鱼种');

        // Assert
        expect(result, hasLength(5));
        for (final bucket in result) {
          expect(bucket.count, equals(0));
        }
      });
    });

    group('FishSpeciesStats', () {
      test('empty factory creates correct empty stats', () {
        // Act
        final result = FishSpeciesStats.empty(speciesName: '测试输入');

        // Assert
        expect(result.speciesId, isEmpty);
        expect(result.speciesName, equals('测试输入'));
        expect(result.totalCount, equals(0));
        expect(result.maxLength, equals(0));
        expect(result.minLength, equals(0));
        expect(result.avgLength, equals(0));
        expect(result.maxWeight, isNull);
        expect(result.firstCaughtAt, isNull);
        expect(result.isUnlocked, isFalse);
      });

      test('equality works correctly', () {
        // Arrange
        final stats1 = FishSpeciesStats(
          speciesId: 'f001',
          speciesName: '鳜鱼',
          totalCount: 5,
          maxLength: 50,
          minLength: 20,
          avgLength: 35,
          maxWeight: 2.5,
          firstCaughtAt: DateTime(2024),
          isUnlocked: true,
        );

        final stats2 = FishSpeciesStats(
          speciesId: 'f001',
          speciesName: '鳜鱼',
          totalCount: 5,
          maxLength: 50,
          minLength: 20,
          avgLength: 35,
          maxWeight: 2.5,
          firstCaughtAt: DateTime(2024),
          isUnlocked: true,
        );

        // Assert
        expect(stats1, equals(stats2));
        expect(stats1.hashCode, equals(stats2.hashCode));
      });
    });

    group('SizeBucket', () {
      test('equality works correctly', () {
        // Arrange
        const bucket1 = SizeBucket(range: '10-20', count: 5);
        const bucket2 = SizeBucket(range: '10-20', count: 5);
        const bucket3 = SizeBucket(range: '20-30', count: 5);

        // Assert
        expect(bucket1, equals(bucket2));
        expect(bucket1, isNot(equals(bucket3)));
        expect(bucket1.hashCode, equals(bucket2.hashCode));
      });

      test('toString returns expected format', () {
        // Arrange
        const bucket = SizeBucket(range: '10-20', count: 5);

        // Assert
        expect(bucket.toString(), equals('SizeBucket(range: 10-20, count: 5)'));
      });
    });
  });
}

FishCatch _createFishCatch({
  required int id,
  required String species,
  required double length,
  double? weight,
  DateTime? catchTime,
}) {
  return FishCatch(
    id: id,
    imagePath: '/test/fish_$id.jpg',
    species: species,
    length: length,
    weight: weight,
    fate: FishFateType.release,
    catchTime: catchTime ?? DateTime.now(),
    createdAt: catchTime ?? DateTime.now(),
    updatedAt: catchTime ?? DateTime.now(),
  );
}
