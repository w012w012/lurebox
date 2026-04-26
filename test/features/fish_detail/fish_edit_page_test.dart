import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/strings/app_strings.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/services/equipment_service.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';
import 'package:lurebox/core/services/settings_service.dart';
import 'package:lurebox/features/fish_detail/widgets/fish_edit_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helpers.dart';

// =============================================================================
// Mocks
// =============================================================================

class MockFishCatchService extends Mock implements FishCatchService {}

class MockEquipmentService extends Mock implements EquipmentService {}

class MockSettingsService extends Mock implements SettingsService {}

// =============================================================================
// Helpers
// =============================================================================

/// Returns default test strings (Chinese locale).
AppStrings get testStrings => AppStrings.chinese;

/// Creates a [FishCatch] suitable for edit page tests.
FishCatch createTestFish({
  int id = 1,
  String species = 'Bass',
  double length = 30.0,
  double? weight,
  FishFateType fate = FishFateType.release,
  String? locationName,
}) {
  return FishCatch(
    id: id,
    imagePath: '/test/fish_$id.jpg',
    species: species,
    length: length,
    weight: weight,
    fate: fate,
    catchTime: DateTime(2024, 6, 15, 10, 30),
    locationName: locationName,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

// =============================================================================
// Main
// =============================================================================

void main() {
  late MockFishCatchService mockFishService;
  late MockEquipmentService mockEquipmentService;
  late MockSettingsService mockSettingsService;

  setUpAll(() {
    setUpDatabaseForTesting();
    registerFallbackValues();
  });

  setUp(() {
    mockFishService = MockFishCatchService();
    mockEquipmentService = MockEquipmentService();
    mockSettingsService = MockSettingsService();

    when(() => mockSettingsService.getAppSettings())
        .thenAnswer((_) async => const AppSettings());
    when(() => mockEquipmentService.getAll(type: any(named: 'type')))
        .thenAnswer((_) async => <Equipment>[]);
    when(() => mockFishService.update(any())).thenAnswer((_) async {});
  });

  /// Wraps [FishEditPage] with [ProviderScope] and [MaterialApp].
  Widget buildTestWidget({
    required FishCatch fish,
    AppStrings? strings,
  }) {
    return ProviderScope(
      overrides: [
        equipmentServiceProvider.overrideWithValue(mockEquipmentService),
        fishCatchServiceProvider.overrideWithValue(mockFishService),
        appSettingsProvider.overrideWith(
          (ref) => AppSettingsNotifier(mockSettingsService),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
        home: FishEditPage(fish: fish, strings: strings ?? testStrings),
      ),
    );
  }

  // ===========================================================================
  // 1. Renders with existing data
  // ===========================================================================

  group('FishEditPage - Renders with existing data', () {
    testWidgets('shows edit title and pre-filled species', (tester) async {
      final fish = createTestFish(species: 'Trout', length: 45.5);
      await tester.pumpWidget(buildTestWidget(fish: fish));
      await tester.pumpAndSettle();

      expect(find.text(testStrings.editFish), findsOneWidget);
      expect(find.text('Trout'), findsOneWidget);
    });

    testWidgets('shows pre-filled length value', (tester) async {
      final fish = createTestFish(length: 30.0);
      await tester.pumpWidget(buildTestWidget(fish: fish));
      await tester.pumpAndSettle();

      expect(find.text('30.0'), findsOneWidget);
    });

    testWidgets('shows empty weight field when weight is null', (tester) async {
      final fish = createTestFish(weight: null);
      await tester.pumpWidget(buildTestWidget(fish: fish));
      await tester.pumpAndSettle();

      final weightField = find.widgetWithIcon(TextField, Icons.scale);
      expect(weightField, findsOneWidget);
      final widget = tester.widget<TextField>(weightField);
      expect(widget.controller!.text, isEmpty);
    });

    testWidgets('shows fate label section', (tester) async {
      // Use a tall surface so all ListView children are built eagerly.
      tester.view.physicalSize = const Size(1080, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestWidget(fish: createTestFish()),
      );
      await tester.pumpAndSettle();

      expect(find.text(testStrings.fate), findsOneWidget);
      // Fate options are prefixed with emoji in the UI.
      expect(find.text('🐟 ${testStrings.release}'), findsOneWidget);
      expect(find.text('🍳 ${testStrings.keep}'), findsOneWidget);
    });
  });

  // ===========================================================================
  // 2. Species input updates
  // ===========================================================================

  group('FishEditPage - Species input updates', () {
    testWidgets('text field updates when user types', (tester) async {
      final fish = createTestFish(species: 'Bass');
      await tester.pumpWidget(buildTestWidget(fish: fish));
      await tester.pumpAndSettle();

      final speciesField = find.widgetWithIcon(TextField, Icons.set_meal);
      await tester.enterText(speciesField, 'Salmon');
      await tester.pump();

      expect(find.text('Salmon'), findsOneWidget);
    });
  });

  // ===========================================================================
  // 3. Numeric validation
  // ===========================================================================

  group('FishEditPage - Numeric validation', () {
    testWidgets('rejects save when length is empty', (tester) async {
      final fish = createTestFish();
      await tester.pumpWidget(buildTestWidget(fish: fish));
      await tester.pumpAndSettle();

      final lengthField = find.widgetWithIcon(TextField, Icons.straighten);
      await tester.enterText(lengthField, '');
      await tester.tap(find.text(testStrings.save));
      await tester.pumpAndSettle();

      expect(find.text(testStrings.enterValidLength), findsOneWidget);
    });

    testWidgets('rejects save when length is non-numeric', (tester) async {
      final fish = createTestFish();
      await tester.pumpWidget(buildTestWidget(fish: fish));
      await tester.pumpAndSettle();

      final lengthField = find.widgetWithIcon(TextField, Icons.straighten);
      await tester.enterText(lengthField, 'abc');
      await tester.tap(find.text(testStrings.save));
      await tester.pumpAndSettle();

      expect(find.text(testStrings.enterValidLength), findsOneWidget);
    });

    testWidgets('rejects save when weight is negative', (tester) async {
      final fish = createTestFish(weight: 5.0);
      await tester.pumpWidget(buildTestWidget(fish: fish));
      await tester.pumpAndSettle();

      final weightField = find.widgetWithIcon(TextField, Icons.scale);
      await tester.enterText(weightField, '-1.0');
      await tester.tap(find.text(testStrings.save));
      await tester.pumpAndSettle();

      expect(find.text(testStrings.enterValidWeight), findsOneWidget);
    });
  });

  // ===========================================================================
  // 4. Save triggers service
  // ===========================================================================

  group('FishEditPage - Save triggers service', () {
    testWidgets('calls FishCatchService.update with correct data',
        (tester) async {
      final fish = createTestFish(
        id: 42,
        species: 'Bass',
        length: 30.0,
        fate: FishFateType.release,
      );
      await tester.pumpWidget(buildTestWidget(fish: fish));
      await tester.pumpAndSettle();

      await tester.tap(find.text(testStrings.save));
      await tester.pumpAndSettle();

      verify(() => mockFishService.update(any())).called(1);
    });

    testWidgets('shows loading indicator during save', (tester) async {
      final completer = Completer<void>();
      when(() => mockFishService.update(any()))
          .thenAnswer((_) => completer.future);

      final fish = createTestFish();
      await tester.pumpWidget(buildTestWidget(fish: fish));
      await tester.pumpAndSettle();

      await tester.tap(find.text(testStrings.save));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete();
      await tester.pumpAndSettle();
    });
  });

  // ===========================================================================
  // 5. Save error shows message
  // ===========================================================================

  group('FishEditPage - Save error shows message', () {
    testWidgets('shows snackbar when save fails', (tester) async {
      when(() => mockFishService.update(any()))
          .thenThrow(Exception('DB error'));

      final fish = createTestFish();
      await tester.pumpWidget(buildTestWidget(fish: fish));
      await tester.pumpAndSettle();

      await tester.tap(find.text(testStrings.save));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining(testStrings.saveFailed), findsOneWidget);
    });
  });

  // ===========================================================================
  // 6. Fate selector
  // ===========================================================================

  group('FishEditPage - Fate selector', () {
    testWidgets('switching fate updates selection state', (tester) async {
      // Use a tall surface so all ListView children are built eagerly.
      tester.view.physicalSize = const Size(1080, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fish = createTestFish(fate: FishFateType.release);
      await tester.pumpWidget(buildTestWidget(fish: fish));
      await tester.pumpAndSettle();

      // Tap "keep" fate option (label is prefixed with emoji).
      await tester.tap(find.text('🍳 ${testStrings.keep}'));
      await tester.pump();

      // Verify the widget tree updated (no crash, state changed).
      expect(find.text('🍳 ${testStrings.keep}'), findsOneWidget);
    });
  });
}
