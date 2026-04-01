import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/fish_catch.dart';

void main() {
  group('FishFateType', () {
    test('release has value 0', () {
      expect(FishFateType.release.value, 0);
    });

    test('keep has value 1', () {
      expect(FishFateType.keep.value, 1);
    });

    test('fromValue returns correct enum', () {
      expect(FishFateType.fromValue(0), FishFateType.release);
      expect(FishFateType.fromValue(1), FishFateType.keep);
    });

    test('fromValue returns release for unknown value', () {
      expect(FishFateType.fromValue(99), FishFateType.release);
    });
  });

  group('FishCatch', () {
    late FishCatch testFish;

    setUp(() {
      testFish = FishCatch(
        id: 1,
        imagePath: '/path/to/image.jpg',
        species: 'Bass',
        length: 30.5,
        weight: 2.5,
        fate: FishFateType.release,
        catchTime: DateTime(2024, 1, 15, 10, 30),
        locationName: 'Lake Michigan',
        latitude: 41.8781,
        longitude: -87.6298,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );
    });

    test('creates FishCatch with required fields', () {
      expect(testFish.id, 1);
      expect(testFish.imagePath, '/path/to/image.jpg');
      expect(testFish.species, 'Bass');
      expect(testFish.length, 30.5);
      expect(testFish.fate, FishFateType.release);
    });

    test('fromMap creates FishCatch from map', () {
      final map = {
        'id': 2,
        'image_path': '/test.jpg',
        'species': 'Trout',
        'length': 25.0,
        'weight': 1.5,
        'fate': 1,
        'catch_time': '2024-02-20T14:00:00.000',
        'location_name': 'River',
        'latitude': 40.0,
        'longitude': -85.0,
        'created_at': '2024-02-20T00:00:00.000',
        'updated_at': '2024-02-20T00:00:00.000',
      };

      final fish = FishCatch.fromMap(map);

      expect(fish.id, 2);
      expect(fish.species, 'Trout');
      expect(fish.length, 25.0);
      expect(fish.weight, 1.5);
      expect(fish.fate, FishFateType.keep);
      expect(fish.locationName, 'River');
    });

    test('toMap converts FishCatch to map', () {
      final map = testFish.toMap();

      expect(map['id'], 1);
      expect(map['image_path'], '/path/to/image.jpg');
      expect(map['species'], 'Bass');
      expect(map['length'], 30.5);
      expect(map['fate'], 0);
      expect(map['location_name'], 'Lake Michigan');
    });

    test('copyWith creates modified copy', () {
      final modified = testFish.copyWith(species: 'New Species', length: 40.0);

      expect(modified.species, 'New Species');
      expect(modified.length, 40.0);
      expect(modified.id, testFish.id);
      expect(modified.imagePath, testFish.imagePath);
    });

    test('equality based on id', () {
      final fish2 = testFish.copyWith(species: 'Different');

      expect(testFish == fish2, true);
    });

    test('hashCode based on id', () {
      expect(testFish.hashCode, 1.hashCode);
    });
  });

  group('FishCatch List Extensions', () {
    late List<FishCatch> catches;

    setUp(() {
      final now = DateTime.now();
      catches = [
        FishCatch(
          id: 1,
          imagePath: '/1.jpg',
          species: 'Bass',
          length: 30.0,
          fate: FishFateType.release,
          catchTime: now,
          createdAt: now,
          updatedAt: now,
        ),
        FishCatch(
          id: 2,
          imagePath: '/2.jpg',
          species: 'Trout',
          length: 25.0,
          fate: FishFateType.keep,
          catchTime: now,
          createdAt: now,
          updatedAt: now,
        ),
        FishCatch(
          id: 3,
          imagePath: '/3.jpg',
          species: 'Bass',
          length: 35.0,
          fate: FishFateType.release,
          catchTime: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];
    });

    test('filterByFate filters correctly', () {
      final release = catches.filterByFate(FishFateType.release);
      final keep = catches.filterByFate(FishFateType.keep);

      expect(release.length, 2);
      expect(keep.length, 1);
    });

    test('filterBySpecies filters correctly', () {
      final bass = catches.filterBySpecies('Bass');
      final trout = catches.filterBySpecies('Trout');

      expect(bass.length, 2);
      expect(trout.length, 1);
    });

    test('searchByKeyword searches species and location', () {
      final bass = catches.searchByKeyword('bass');
      expect(bass.length, 2);
    });

    test('sortBy sorts correctly', () {
      final byLength = catches.sortBy('length', false, null);
      expect(byLength.first.length, 35.0);

      final byLengthAsc = catches.sortBy('length', true, null);
      expect(byLengthAsc.first.length, 25.0);
    });

    test('uniqueSpecies returns sorted unique list', () {
      final species = catches.uniqueSpecies;
      expect(species, ['Bass', 'Trout']);
    });

    test('releaseCount returns correct count', () {
      expect(catches.releaseCount, 2);
    });

    test('keepCount returns correct count', () {
      expect(catches.keepCount, 1);
    });

    test('releaseRate calculates correctly', () {
      expect(catches.releaseRate, closeTo(0.666, 0.01));
    });

    test('releaseRate is 0 for empty list', () {
      final emptyList = <FishCatch>[];
      expect(emptyList.releaseRate, 0);
    });
  });

  group('FishCatch filterByTime', () {
    test('filters today correctly', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 12, 0);
      final yesterday = today.subtract(const Duration(days: 1));

      final testCatches = [
        FishCatch(
          id: 1,
          imagePath: '/1.jpg',
          species: 'Bass',
          length: 30.0,
          fate: FishFateType.release,
          catchTime: today,
          createdAt: now,
          updatedAt: now,
        ),
        FishCatch(
          id: 2,
          imagePath: '/2.jpg',
          species: 'Trout',
          length: 25.0,
          fate: FishFateType.keep,
          catchTime: yesterday,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final todayCatches = testCatches.filterByTime('today');
      expect(todayCatches.length, 1);
      expect(todayCatches.first.species, 'Bass');
    });

    test('filterByTime with all returns all', () {
      final now = DateTime.now();
      final testCatches = [
        FishCatch(
          id: 1,
          imagePath: '/1.jpg',
          species: 'Bass',
          length: 30.0,
          fate: FishFateType.release,
          catchTime: now.subtract(const Duration(days: 100)),
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final all = testCatches.filterByTime('all');
      expect(all.length, 1);
    });
  });
}
