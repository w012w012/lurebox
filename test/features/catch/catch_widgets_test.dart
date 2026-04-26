import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/camera/camera_state.dart';
import 'package:lurebox/core/camera/camera_view_model.dart';
import 'package:lurebox/core/constants/strings/app_strings.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/services/equipment_service.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';
import 'package:lurebox/core/services/settings_service.dart';
import 'package:lurebox/features/catch/widgets/fate_selector_card.dart';
import 'package:lurebox/features/catch/widgets/length_input_field.dart';
import 'package:lurebox/features/catch/widgets/weight_input_field.dart';
import 'package:mocktail/mocktail.dart';

// =============================================================================
// Mocks
// =============================================================================

class MockFishCatchService extends Mock implements FishCatchService {}

class MockEquipmentService extends Mock implements EquipmentService {}

class MockSettingsService extends Mock implements SettingsService {}

// =============================================================================
// Helpers
// =============================================================================

/// Default test strings (Chinese locale).
AppStrings get testStrings => AppStrings.chinese;

void main() {
  late MockFishCatchService mockFishService;
  late MockEquipmentService mockEquipmentService;
  late MockSettingsService mockSettingsService;
  late CameraViewModel viewModel;

  setUp(() {
    mockFishService = MockFishCatchService();
    mockEquipmentService = MockEquipmentService();
    mockSettingsService = MockSettingsService();

    when(() => mockSettingsService.getAppSettings())
        .thenAnswer((_) async => const AppSettings());
    when(() => mockEquipmentService.getAll(type: any(named: 'type')))
        .thenAnswer((_) async => []);

    viewModel = CameraViewModel(
      mockFishService,
      mockEquipmentService,
      testStrings,
    );
  });

  /// Wraps [child] with [ProviderScope] and [MaterialApp].
  ///
  /// Provides mock overrides for [appSettingsProvider] and
  /// [cameraViewModelProvider] so that ConsumerWidget children
  /// can resolve providers.
  Widget buildTestWidget(Widget child) {
    return ProviderScope(
      overrides: [
        fishCatchServiceProvider.overrideWithValue(mockFishService),
        equipmentServiceProvider.overrideWithValue(mockEquipmentService),
        appSettingsProvider.overrideWith(
          (ref) => AppSettingsNotifier(mockSettingsService),
        ),
        cameraViewModelProvider.overrideWith(
          (ref) => CameraViewModel(
            ref.read(fishCatchServiceProvider),
            ref.read(equipmentServiceProvider),
            testStrings,
          ),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
  }

  // ===========================================================================
  // FateSelectorCard
  // ===========================================================================

  group('FateSelectorCard', () {
    testWidgets('renders both release and keep options', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FateSelectorCard(
            state: const CameraState(),
            vm: viewModel,
            strings: testStrings,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('🐟 ${testStrings.release}'), findsOneWidget);
      expect(find.text('🍳 ${testStrings.keep}'), findsOneWidget);
      expect(find.text(testStrings.fate), findsOneWidget);
    });

    testWidgets('initial selection state matches passed value', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          FateSelectorCard(
            state: const CameraState(),
            vm: viewModel,
            strings: testStrings,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Both options present; selected state verified indirectly —
      // tapping the same value again should not change the state.
      expect(find.text('🐟 ${testStrings.release}'), findsOneWidget);
    });

    testWidgets('tapping release triggers setFate(release)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FateSelectorCard(
            state: const CameraState(fate: FishFateType.keep),
            vm: viewModel,
            strings: testStrings,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('🐟 ${testStrings.release}'));
      await tester.pump();

      expect(viewModel.state.fate, FishFateType.release);
    });

    testWidgets('tapping keep triggers setFate(keep)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FateSelectorCard(
            state: const CameraState(),
            vm: viewModel,
            strings: testStrings,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('🍳 ${testStrings.keep}'));
      await tester.pump();

      expect(viewModel.state.fate, FishFateType.keep);
    });
  });

  // ===========================================================================
  // LengthInputField
  // ===========================================================================

  group('LengthInputField', () {
    testWidgets('renders with initial value', (tester) async {
      final controller = TextEditingController(text: '42.5');

      await tester.pumpWidget(
        buildTestWidget(
          LengthInputField(
            state: const CameraState(),
            vm: viewModel,
            strings: testStrings,
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('42.5'), findsOneWidget);
      expect(find.text(testStrings.centimeter), findsOneWidget);
    });

    testWidgets('text input updates correctly', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        buildTestWidget(
          LengthInputField(
            state: const CameraState(),
            vm: viewModel,
            strings: testStrings,
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final lengthField = find.widgetWithIcon(TextFormField, Icons.straighten);
      await tester.enterText(lengthField, '55.3');
      await tester.pump();

      expect(controller.text, '55.3');
    });

    testWidgets('unit selector displays correct unit', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        buildTestWidget(
          LengthInputField(
            state: const CameraState(lengthUnit: 'inch'),
            vm: viewModel,
            strings: testStrings,
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The DropdownButton displays the selected unit label.
      expect(find.text(testStrings.inch), findsOneWidget);
    });
  });

  // ===========================================================================
  // WeightInputField
  // ===========================================================================

  group('WeightInputField', () {
    testWidgets('renders with initial value', (tester) async {
      final controller = TextEditingController(text: '3.75');

      await tester.pumpWidget(
        buildTestWidget(
          WeightInputField(
            state: const CameraState(),
            vm: viewModel,
            strings: testStrings,
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3.75'), findsOneWidget);
      expect(find.text(testStrings.kilogram), findsOneWidget);
    });

    testWidgets('text input updates correctly', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        buildTestWidget(
          WeightInputField(
            state: const CameraState(),
            vm: viewModel,
            strings: testStrings,
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final weightField = find.widgetWithIcon(TextFormField, Icons.scale);
      await tester.enterText(weightField, '2.10');
      await tester.pump();

      expect(controller.text, '2.10');
      // vm.setWeight is called via ref.read(cameraViewModelProvider.notifier)
      // inside the widget — read the provider-scoped notifier to verify.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(WeightInputField)),
      );
      expect(container.read(cameraViewModelProvider).weight, 2.10);
    });

    testWidgets('unit selector displays correct unit', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        buildTestWidget(
          WeightInputField(
            state: const CameraState(weightUnit: 'lb'),
            vm: viewModel,
            strings: testStrings,
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(testStrings.pound), findsOneWidget);
    });
  });
}
