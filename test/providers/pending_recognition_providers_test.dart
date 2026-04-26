import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/providers/pending_recognition_providers.dart';
import 'package:lurebox/core/repositories/fish_catch_repository.dart';

class MockFishCatchRepository extends Mock implements FishCatchRepository {}

class FakeFishCatch extends Fake implements FishCatch {}

void main() {
  late MockFishCatchRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeFishCatch());
  });

  setUp(() {
    mockRepository = MockFishCatchRepository();
  });

  group('pendingRecognitionCountProvider', () {
    test('returns count of pending recognition catches', () async {
      when(() => mockRepository.getPendingRecognitionCount())
          .thenAnswer((_) async => 5);

      final container = ProviderContainer(
        overrides: [
          fishCatchRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final count = await container.read(pendingRecognitionCountProvider.future);

      expect(count, 5);
    });

    test('returns zero when no pending catches', () async {
      when(() => mockRepository.getPendingRecognitionCount())
          .thenAnswer((_) async => 0);

      final container = ProviderContainer(
        overrides: [
          fishCatchRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final count = await container.read(pendingRecognitionCountProvider.future);

      expect(count, 0);
    });

    test('calls repository method', () async {
      when(() => mockRepository.getPendingRecognitionCount())
          .thenAnswer((_) async => 0);

      final container = ProviderContainer(
        overrides: [
          fishCatchRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(pendingRecognitionCountProvider.future);

      verify(() => mockRepository.getPendingRecognitionCount()).called(1);
    });
  });

  group('pendingRecognitionCatchesProvider', () {
    test('returns list of pending recognition catches', () async {
      final pendingCatches = [
        _createFishCatch(
          id: 1,
          species: 'Unknown',
          pendingRecognition: true,
        ),
        _createFishCatch(
          id: 2,
          species: 'Unknown',
          pendingRecognition: true,
        ),
      ];
      when(() => mockRepository.getPendingRecognitionCatches())
          .thenAnswer((_) async => pendingCatches);

      final container = ProviderContainer(
        overrides: [
          fishCatchRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final catches =
          await container.read(pendingRecognitionCatchesProvider.future);

      expect(catches.length, 2);
      expect(catches.every((c) => c.pendingRecognition), isTrue);
    });

    test('returns empty list when no pending catches', () async {
      when(() => mockRepository.getPendingRecognitionCatches())
          .thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [
          fishCatchRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final catches =
          await container.read(pendingRecognitionCatchesProvider.future);

      expect(catches, isEmpty);
    });

    test('calls repository method', () async {
      when(() => mockRepository.getPendingRecognitionCatches())
          .thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [
          fishCatchRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(pendingRecognitionCatchesProvider.future);

      verify(() => mockRepository.getPendingRecognitionCatches()).called(1);
    });
  });

  group('pending recognition state', () {
    test('fish catch with pendingRecognition flag', () {
      final catch1 = _createFishCatch(
        id: 1,
        species: 'Bass',
        pendingRecognition: false,
      );
      final catch2 = _createFishCatch(
        id: 2,
        species: 'Unknown',
        pendingRecognition: true,
      );

      expect(catch1.pendingRecognition, isFalse);
      expect(catch2.pendingRecognition, isTrue);
    });

    test('pending catches have pendingRecognition flag set', () {
      final catch1 = _createFishCatch(
        id: 1,
        species: 'Bass',
        pendingRecognition: true,
      );
      final catch2 = _createFishCatch(
        id: 2,
        species: ' Trout',
        pendingRecognition: false,
      );

      expect(catch1.pendingRecognition, isTrue);
      expect(catch2.pendingRecognition, isFalse);
    });
  });
}

FishCatch _createFishCatch({
  required int id,
  String species = 'Test Fish',
  bool pendingRecognition = false,
}) {
  final now = DateTime.now();
  return FishCatch(
    id: id,
    imagePath: '/test/fish_$id.jpg',
    species: species,
    length: 30.0,
    fate: FishFateType.release,
    catchTime: now,
    pendingRecognition: pendingRecognition,
    createdAt: now,
    updatedAt: now,
  );
}
