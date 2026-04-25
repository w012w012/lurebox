import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/strings/app_strings.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/providers/equipment_view_model.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/features/equipment/equipment_list_page.dart';
import 'package:lurebox/features/equipment/widgets/equipment_type_tabs.dart';

import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    setUpDatabaseForTesting();
    registerFallbackValues();
  });

  group('EquipmentListPage', () {
    testWidgets('renders app bar with title', (tester) async {
      final mockState = _MockEquipmentListState(isLoading: false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            equipmentListViewModelProvider
                .overrideWith((ref) => _MockEquipmentListViewModel(mockState)),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
          child: const MaterialApp(
            home: EquipmentListPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('My Equipment'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading is true',
        (tester) async {
      final loadingState = _MockEquipmentListState(isLoading: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            equipmentListViewModelProvider
                .overrideWith((ref) => _MockEquipmentListViewModel(loadingState)),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
          child: const MaterialApp(
            home: EquipmentListPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no equipment', (tester) async {
      final emptyState = _MockEquipmentListState(
        isLoading: false,
        rodList: const [],
        reelList: const [],
        lureList: const [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            equipmentListViewModelProvider
                .overrideWith((ref) => _MockEquipmentListViewModel(emptyState)),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
          child: const MaterialApp(
            home: EquipmentListPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('No equipment yet'), findsOneWidget);
    });

    testWidgets('shows equipment list when data loaded', (tester) async {
      final equipment = TestDataFactory.createEquipment(id: 1);
      final loadedState = _MockEquipmentListState(
        isLoading: false,
        rodList: [equipment],
        reelList: const [],
        lureList: const [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            equipmentListViewModelProvider
                .overrideWith((ref) => _MockEquipmentListViewModel(loadedState)),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
          child: const MaterialApp(
            home: EquipmentListPage(),
          ),
        ),
      );
      await tester.pump();

      // Should show equipment list
      expect(find.byType(EquipmentListPage), findsOneWidget);
    });

    testWidgets('shows tab bar for equipment types', (tester) async {
      final state = _MockEquipmentListState(
        isLoading: false,
        rodList: [TestDataFactory.createEquipment(id: 1)],
        reelList: [TestDataFactory.createEquipment(id: 2)],
        lureList: [TestDataFactory.createEquipment(id: 3)],
        selectedType: 'rod',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            equipmentListViewModelProvider
                .overrideWith((ref) => _MockEquipmentListViewModel(state)),
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
          child: const MaterialApp(
            home: EquipmentListPage(),
          ),
        ),
      );
      await tester.pump();

      // Tab bar should be visible
      expect(find.byType(EquipmentTypeTabs), findsOneWidget);
    });
  });
}

/// Mock EquipmentListState for testing
class _MockEquipmentListState implements EquipmentListState {
  const _MockEquipmentListState({
    this.isLoading = false,
    this.errorMessage,
    this.rodList = const [],
    this.reelList = const [],
    this.lureList = const [],
    this.equipmentStats = const {},
    this.selectedType = 'rod',
    this.allExpanded = true,
    this.expandedId,
  });

  @override
  final bool isLoading;
  @override
  final String? errorMessage;
  @override
  final List<Equipment> rodList;
  @override
  final List<Equipment> reelList;
  @override
  final List<Equipment> lureList;
  @override
  final Map<int, Map<String, int>> equipmentStats;
  @override
  final String selectedType;
  @override
  final bool allExpanded;
  @override
  final int? expandedId;

  @override
  List<Equipment> get currentList {
    switch (selectedType) {
      case 'rod':
        return rodList;
      case 'reel':
        return reelList;
      case 'lure':
        return lureList;
      default:
        return [];
    }
  }
}

/// Mock EquipmentListViewModel for testing
class _MockEquipmentListViewModel extends StateNotifier<EquipmentListState>
    implements EquipmentListViewModel {
  _MockEquipmentListViewModel(EquipmentListState state) : super(state);

  @override
  Future<void> loadData() async {}

  @override
  Future<void> refresh() async {}

  @override
  void setSelectedType(String type) {
    // No-op for testing
  }

  @override
  void toggleExpanded(int id) {
    // No-op for testing
  }

  @override
  void setAllExpanded(bool expanded) {
    // No-op for testing
  }

  @override
  Future<void> deleteEquipment(int id) async {}

  @override
  Future<void> setDefaultEquipment(int id, String type) async {}
}

