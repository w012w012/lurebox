import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lurebox/core/camera/camera_helper.dart';
import 'package:lurebox/core/camera/camera_state.dart';
import 'package:lurebox/core/camera/camera_view_model.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/features/catch/widgets/species_input_card.dart';

const defaultStrings = AppStrings.english;

/// Fake CameraViewModel for testing - extends StateNotifier properly
class FakeCameraViewModel extends StateNotifier<CameraState>
    implements CameraViewModel {
  FakeCameraViewModel([CameraState? initialState])
      : super(initialState ?? const CameraState());

  String? lastSpecies;
  bool? lastPendingRecognition;

  @override
  void setSpecies(String species) {
    lastSpecies = species;
  }

  @override
  void setPendingRecognition(bool value) {
    lastPendingRecognition = value;
  }

  // Stub all other CameraViewModel methods
  @override
  CameraHelper get cameraHelper => throw UnimplementedError();

  @override
  void initialize(BuildContext context) {}

  @override
  Future<void> initializeCamera() async {}

  @override
  Future<void> switchCamera() async {}

  @override
  Future<String?> takePicture() async => null;

  @override
  Future<void> getLocation() async {}

  @override
  Future<void> loadSpeciesHistory() async {}

  @override
  Future<void> loadEquipments() async {}

  @override
  void setImagePath(String path) {}

  @override
  void setCatchTime(DateTime time) {}

  @override
  void setAirTemperature(double temp) {}

  @override
  void setPressure(double pressure) {}

  @override
  void setWeatherCode(int? code) {}

  @override
  void setLocationName(String name) {}

  @override
  void setLength(double length) {}

  @override
  void setWeight(double? weight) {}

  @override
  void setLengthUnit(String unit) {}

  @override
  void setWeightUnit(String unit) {}

  @override
  void initializeUnits(UnitSettings settings) {}

  @override
  void setFate(FishFateType fate) {}

  @override
  void setLocation(
    String? name,
    double? lat,
    double? lng,
    double? temperature,
    double? pressure,
    int? weatherCode,
  ) {}

  @override
  void setSelectedRod(Equipment? rod) {}

  @override
  void setSelectedReel(Equipment? reel) {}

  @override
  void setSelectedLure(Equipment? lure) {}

  @override
  Future<int?> saveFishCatch() async => null;

  @override
  void reset() {}

  @override
  void setWatermarkedPath(String path) {}

  @override
  void clearImage() {}

  @override
  void resetCaptureStateToForm() {}

  @override
  void disposeCamera() {}

  @override
  bool updateShouldNotify(CameraState old, CameraState current) => true;

  @override
  CameraState get state => super.state;

  @override
  set state(CameraState value) {
    super.state = value;
  }
}

void main() {
  late FakeCameraViewModel fakeVm;
  late CameraState state;
  late TextEditingController controller;

  setUp(() {
    fakeVm = FakeCameraViewModel();
    controller = TextEditingController();

    // Default state with species history
    state = const CameraState(
      speciesHistory: ['Bass', 'Trout', 'pending'],
    );
  });

  tearDown(() {
    controller.dispose();
    fakeVm.dispose();
  });

  Widget createWidgetUnderTest({
    CameraState? stateOverride,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SpeciesInputCard(
              state: stateOverride ?? state,
              vm: fakeVm,
              strings: defaultStrings,
              controller: controller,
            ),
          ),
        ),
      ),
    );
  }

  group('SpeciesInputCard - Rendering', () {
    testWidgets('renders PremiumTextField with label and hint',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text(defaultStrings.species), findsOneWidget);
      expect(find.text(defaultStrings.enterSpeciesName), findsOneWidget);
    });

    testWidgets('renders species history chips when available',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // 'pending' is NOT filtered out by the widget - only strings matching
      // strings.pendingRecognition (button text) are filtered
      expect(find.text('Bass'), findsOneWidget);
      expect(find.text('Trout'), findsOneWidget);
      expect(find.text('pending'), findsOneWidget);
    });

    testWidgets('does not render chips when speciesHistory is empty',
        (WidgetTester tester) async {
      final emptyState = state.copyWith(speciesHistory: []);
      await tester.pumpWidget(createWidgetUnderTest(stateOverride: emptyState));
      await tester.pump();

      // Should not find any of the original species
      expect(find.text('Bass'), findsNothing);
      expect(find.text('Trout'), findsNothing);
      expect(find.text('pending'), findsNothing);
    });

    testWidgets('renders pending recognition button with correct text',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(
        find.text(defaultStrings.addToPendingRecognition),
        findsOneWidget,
      );
    });

    testWidgets('button shows cancel text when pendingRecognition is true',
        (WidgetTester tester) async {
      final pendingState = state.copyWith(pendingRecognition: true);
      await tester
          .pumpWidget(createWidgetUnderTest(stateOverride: pendingState));
      await tester.pump();

      expect(
        find.text(defaultStrings.cancelPendingRecognition),
        findsOneWidget,
      );
    });

    testWidgets('text field is disabled when pendingRecognition is true',
        (WidgetTester tester) async {
      final pendingState = state.copyWith(pendingRecognition: true);
      await tester
          .pumpWidget(createWidgetUnderTest(stateOverride: pendingState));
      await tester.pump();

      final textField =
          tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, false);
    });

    testWidgets('text field is enabled when pendingRecognition is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final textField =
          tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, true);
    });

    testWidgets('renders with prefix icon', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byIcon(Icons.set_meal), findsOneWidget);
    });
  });

  group('SpeciesInputCard - Interactions', () {
    testWidgets('calls vm.setSpecies when text is entered',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.enterText(find.byType(TextFormField), 'Catfish');
      expect(controller.text, 'Catfish');
      expect(fakeVm.lastSpecies, 'Catfish');
    });

    testWidgets('tapping species chip sets text and calls setSpecies',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.text('Bass'));
      await tester.pump();

      expect(controller.text, 'Bass');
      expect(fakeVm.lastSpecies, 'Bass');
    });

    testWidgets('tapping chip does nothing when pendingRecognition is true',
        (WidgetTester tester) async {
      final pendingState = state.copyWith(pendingRecognition: true);
      await tester
          .pumpWidget(createWidgetUnderTest(stateOverride: pendingState));
      await tester.pump();

      // Find the InkWell for the chip and tap it
      final inkWells = find.byType(InkWell);
      await tester.tap(inkWells.first);
      await tester.pump();

      // setSpecies should not be called when pendingRecognition is true
      expect(fakeVm.lastSpecies, isNull);
    });

    testWidgets(
        'tapping add to pending button clears text and enables pending mode',
        (WidgetTester tester) async {
      controller.text = 'SomeFish';
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.text(defaultStrings.addToPendingRecognition));
      await tester.pump();

      expect(controller.text, '');
      expect(fakeVm.lastSpecies, '');
      expect(fakeVm.lastPendingRecognition, true);
    });

    testWidgets('tapping cancel pending button disables pending mode',
        (WidgetTester tester) async {
      final pendingState = state.copyWith(pendingRecognition: true);
      await tester
          .pumpWidget(createWidgetUnderTest(stateOverride: pendingState));
      await tester.pump();

      await tester.tap(find.text(defaultStrings.cancelPendingRecognition));
      await tester.pump();

      expect(fakeVm.lastPendingRecognition, false);
    });
  });

  group('SpeciesInputCard - Edge Cases', () {
    testWidgets('filters out empty strings from species history',
        (WidgetTester tester) async {
      final stateWithEmpty = state.copyWith(
        speciesHistory: ['Bass', '', 'Trout', ''],
      );
      await tester
          .pumpWidget(createWidgetUnderTest(stateOverride: stateWithEmpty));
      await tester.pump();

      expect(find.text('Bass'), findsOneWidget);
      expect(find.text('Trout'), findsOneWidget);
    });

    testWidgets('controller text is displayed in text field',
        (WidgetTester tester) async {
      controller.text = 'Pre-filled Fish';
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Pre-filled Fish'), findsOneWidget);
    });
  });
}
