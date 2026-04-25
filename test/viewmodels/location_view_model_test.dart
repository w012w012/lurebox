import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/providers/location_view_model.dart';
import 'package:lurebox/core/services/location_service.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationService extends Mock implements LocationService {}

void main() {
  late MockLocationService mockService;
  late LocationManagementViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    mockService = MockLocationService();
  });

  List<Map<String, dynamic>> createLocations(List<String> names) {
    return names.map((name) {
      return {
        'location_name': name,
        'latitude': 35.0,
        'longitude': 139.0,
        'fish_count': 5,
        'last_catch_time': DateTime.now().toIso8601String(),
      };
    }).toList();
  }

  group('LocationManagementViewModel', () {
    group('initial state', () {
      test('has correct default values', () {
        when(() => mockService.getAllLocations())
            .thenAnswer((_) async => createLocations(['Lake A']));
        when(() => mockService.findSimilarLocations(any())).thenReturn([]);

        viewModel = LocationManagementViewModel(mockService);

        expect(viewModel.state.locations, isEmpty);
        expect(viewModel.state.locationGroups, isEmpty);
        expect(viewModel.state.selectedLocations, isEmpty);
        expect(viewModel.state.isLoading, true);
        expect(viewModel.state.errorMessage, isNull);
        expect(viewModel.state.isMerging, false);
        expect(viewModel.state.mergeTargetName, isNull);
      });
    });

    group('loadData', () {
      test('loads locations successfully', () async {
        final locations = createLocations(['Lake A', 'Lake B', 'River C']);

        when(() => mockService.getAllLocations())
            .thenAnswer((_) async => locations);
        when(() => mockService.findSimilarLocations(any())).thenReturn([]);

        viewModel = LocationManagementViewModel(mockService);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(viewModel.state.locations.length, 3);
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, isNull);
      });

      test('handles error when loading locations fails', () async {
        when(() => mockService.getAllLocations())
            .thenThrow(Exception('Database error'));

        viewModel = LocationManagementViewModel(mockService);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(viewModel.state.locations, isEmpty);
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, contains('Database error'));
      });

      test('groups similar locations', () async {
        final locations = createLocations(['Lake A', 'Lake B', 'Lake C']);

        when(() => mockService.getAllLocations())
            .thenAnswer((_) async => locations);
        when(() => mockService
            .findSimilarLocations(['Lake A', 'Lake B', 'Lake C']),).thenReturn([
          ['Lake A', 'Lake B'],
          ['Lake C'],
        ]);
        when(() => mockService.getBestLocationName(['Lake A', 'Lake B']))
            .thenReturn('Lake A/B');
        when(() => mockService.getBestLocationName(['Lake C']))
            .thenReturn('Lake C');

        viewModel = LocationManagementViewModel(mockService);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(viewModel.state.locationGroups.length, 2);
      });
    });

    group('toggleSelection', () {
      test('adds location to selection when not selected', () async {
        when(() => mockService.getAllLocations())
            .thenAnswer((_) async => createLocations(['Lake A']));
        when(() => mockService.findSimilarLocations(any())).thenReturn([]);

        viewModel = LocationManagementViewModel(mockService);
        await Future.delayed(const Duration(milliseconds: 10));

        viewModel.toggleSelection('Lake A');

        expect(viewModel.state.selectedLocations.contains('Lake A'), true);
      });

      test('removes location from selection when already selected', () async {
        when(() => mockService.getAllLocations())
            .thenAnswer((_) async => createLocations(['Lake A']));
        when(() => mockService.findSimilarLocations(any())).thenReturn([]);

        viewModel = LocationManagementViewModel(mockService);
        await Future.delayed(const Duration(milliseconds: 10));

        viewModel.toggleSelection('Lake A');
        expect(viewModel.state.selectedLocations.contains('Lake A'), true);

        viewModel.toggleSelection('Lake A');
        expect(viewModel.state.selectedLocations.contains('Lake A'), false);
      });
    });

    group('clearSelection', () {
      test('clears all selected locations', () async {
        when(() => mockService.getAllLocations())
            .thenAnswer((_) async => createLocations(['Lake A', 'Lake B']));
        when(() => mockService.findSimilarLocations(any())).thenReturn([]);

        viewModel = LocationManagementViewModel(mockService);
        await Future.delayed(const Duration(milliseconds: 10));

        viewModel.toggleSelection('Lake A');
        viewModel.toggleSelection('Lake B');
        expect(viewModel.state.selectedLocations.length, 2);

        viewModel.clearSelection();

        expect(viewModel.state.selectedLocations, isEmpty);
      });
    });

    group('selectAll', () {
      test('selects all locations', () async {
        when(() => mockService.getAllLocations()).thenAnswer(
            (_) async => createLocations(['Lake A', 'Lake B', 'Lake C']),);
        when(() => mockService.findSimilarLocations(any())).thenReturn([]);

        viewModel = LocationManagementViewModel(mockService);
        await Future.delayed(const Duration(milliseconds: 10));

        viewModel.selectAll();

        expect(viewModel.state.selectedLocations.length, 3);
        expect(viewModel.state.selectedLocations.contains('Lake A'), true);
        expect(viewModel.state.selectedLocations.contains('Lake B'), true);
        expect(viewModel.state.selectedLocations.contains('Lake C'), true);
      });
    });

    group('setMergeTarget', () {
      test('sets merge target name', () async {
        when(() => mockService.getAllLocations())
            .thenAnswer((_) async => createLocations(['Lake A']));
        when(() => mockService.findSimilarLocations(any())).thenReturn([]);

        viewModel = LocationManagementViewModel(mockService);
        await Future.delayed(const Duration(milliseconds: 10));

        viewModel.setMergeTarget('New Lake');

        expect(viewModel.state.mergeTargetName, 'New Lake');
      });
    });

    group('mergeLocations', () {
      test('returns false when fewer than 2 locations selected', () async {
        when(() => mockService.getAllLocations())
            .thenAnswer((_) async => createLocations(['Lake A', 'Lake B']));
        when(() => mockService.findSimilarLocations(any())).thenReturn([]);

        viewModel = LocationManagementViewModel(mockService);
        await Future.delayed(const Duration(milliseconds: 10));

        viewModel.toggleSelection('Lake A');
        final result = await viewModel.mergeLocations('New Lake');

        expect(result, false);
        verifyNever(() => mockService.mergeLocations(any(), any()));
      });

      test('merges locations successfully when 2+ selected', () async {
        when(() => mockService.getAllLocations()).thenAnswer(
            (_) async => createLocations(['Lake A', 'Lake B', 'Lake C']),);
        when(() => mockService.findSimilarLocations(any())).thenReturn([]);
        when(() => mockService.mergeLocations(['Lake A', 'Lake B'], 'New Lake'))
            .thenAnswer((_) async {});

        viewModel = LocationManagementViewModel(mockService);
        await Future.delayed(const Duration(milliseconds: 10));

        viewModel.toggleSelection('Lake A');
        viewModel.toggleSelection('Lake B');
        final result = await viewModel.mergeLocations('New Lake');

        expect(result, true);
        verify(() =>
                mockService.mergeLocations(['Lake A', 'Lake B'], 'New Lake'),)
            .called(1);
      });

      test('handles error during merge', () async {
        when(() => mockService.getAllLocations())
            .thenAnswer((_) async => createLocations(['Lake A', 'Lake B']));
        when(() => mockService.findSimilarLocations(any())).thenReturn([]);
        when(() => mockService.mergeLocations(any(), any()))
            .thenThrow(Exception('Merge failed'));

        viewModel = LocationManagementViewModel(mockService);
        await Future.delayed(const Duration(milliseconds: 10));

        viewModel.toggleSelection('Lake A');
        viewModel.toggleSelection('Lake B');
        final result = await viewModel.mergeLocations('New Lake');

        expect(result, false);
        expect(viewModel.state.errorMessage, contains('Merge failed'));
      });
    });

    group('autoMergeGroup', () {
      test('returns false when group has fewer than 2 locations', () async {
        const group = LocationGroup(
          representative: 'Lake A',
          locations: ['Lake A'],
        );

        when(() => mockService.getAllLocations())
            .thenAnswer((_) async => createLocations(['Lake A']));
        when(() => mockService.findSimilarLocations(any())).thenReturn([]);

        viewModel = LocationManagementViewModel(mockService);
        await Future.delayed(const Duration(milliseconds: 10));

        final result = await viewModel.autoMergeGroup(group);

        expect(result, false);
      });

      test('merges group successfully when 2+ locations', () async {
        const group = LocationGroup(
          representative: 'Lake A/B',
          locations: ['Lake A', 'Lake B'],
        );

        when(() => mockService.getAllLocations())
            .thenAnswer((_) async => createLocations(['Lake A', 'Lake B']));
        when(() => mockService.findSimilarLocations(any())).thenReturn([]);
        when(() => mockService.mergeLocations(['Lake A', 'Lake B'], 'Lake A/B'))
            .thenAnswer((_) async {});

        viewModel = LocationManagementViewModel(mockService);
        await Future.delayed(const Duration(milliseconds: 10));

        final result = await viewModel.autoMergeGroup(group);

        expect(result, true);
      });
    });

    group('renameLocation', () {
      test('returns false when oldName is empty', () async {
        when(() => mockService.getAllLocations())
            .thenAnswer((_) async => createLocations(['Lake A']));
        when(() => mockService.findSimilarLocations(any())).thenReturn([]);

        viewModel = LocationManagementViewModel(mockService);
        await Future.delayed(const Duration(milliseconds: 10));

        final result = await viewModel.renameLocation('', 'New Name');

        expect(result, false);
      });

      test('returns false when newName is empty', () async {
        when(() => mockService.getAllLocations())
            .thenAnswer((_) async => createLocations(['Lake A']));
        when(() => mockService.findSimilarLocations(any())).thenReturn([]);

        viewModel = LocationManagementViewModel(mockService);
        await Future.delayed(const Duration(milliseconds: 10));

        final result = await viewModel.renameLocation('Lake A', '');

        expect(result, false);
      });

      test('returns false when oldName equals newName', () async {
        when(() => mockService.getAllLocations())
            .thenAnswer((_) async => createLocations(['Lake A']));
        when(() => mockService.findSimilarLocations(any())).thenReturn([]);

        viewModel = LocationManagementViewModel(mockService);
        await Future.delayed(const Duration(milliseconds: 10));

        final result = await viewModel.renameLocation('Lake A', 'Lake A');

        expect(result, false);
      });

      test('renames location successfully', () async {
        when(() => mockService.getAllLocations())
            .thenAnswer((_) async => createLocations(['Lake A']));
        when(() => mockService.findSimilarLocations(any())).thenReturn([]);
        when(() => mockService.renameLocation('Lake A', 'New Lake'))
            .thenAnswer((_) async {});

        viewModel = LocationManagementViewModel(mockService);
        await Future.delayed(const Duration(milliseconds: 10));

        final result = await viewModel.renameLocation('Lake A', 'New Lake');

        expect(result, true);
        verify(() => mockService.renameLocation('Lake A', 'New Lake'))
            .called(1);
      });

      test('handles error during rename', () async {
        when(() => mockService.getAllLocations())
            .thenAnswer((_) async => createLocations(['Lake A']));
        when(() => mockService.findSimilarLocations(any())).thenReturn([]);
        when(() => mockService.renameLocation(any(), any()))
            .thenThrow(Exception('Rename failed'));

        viewModel = LocationManagementViewModel(mockService);
        await Future.delayed(const Duration(milliseconds: 10));

        final result = await viewModel.renameLocation('Lake A', 'New Lake');

        expect(result, false);
        expect(viewModel.state.errorMessage, contains('Rename failed'));
      });
    });

    group('LocationGroup', () {
      test('creates LocationGroup with correct values', () {
        const group = LocationGroup(
          representative: 'Best Lake',
          locations: ['Lake A', 'Lake B', 'Lake C'],
        );

        expect(group.representative, 'Best Lake');
        expect(group.locations.length, 3);
        expect(group.locations, contains('Lake A'));
        expect(group.locations, contains('Lake B'));
        expect(group.locations, contains('Lake C'));
      });
    });
  });
}
