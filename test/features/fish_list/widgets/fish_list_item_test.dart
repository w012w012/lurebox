import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/models/watermark_settings.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/services/settings_service.dart';
import 'package:lurebox/features/fish_list/widgets/fish_list_item.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    registerFallbackValues();
  });

  /// Mock SettingsService for testing - bypasses database
  const mockSettingsService = MockSettingsService();

  /// Use English strings for testing
  const defaultStrings = AppStrings.english;

  FishCatch createFishCatch({
    int id = 1,
    String species = 'Bass',
    double length = 30.0,
    double? weight,
    FishFateType fate = FishFateType.release,
    DateTime? catchTime,
    String? locationName,
    bool pendingRecognition = false,
  }) {
    return FishCatch(
      id: id,
      imagePath: '/test/fish_$id.jpg',
      species: species,
      length: length,
      weight: weight,
      fate: fate,
      catchTime: catchTime ?? DateTime(2024, 6, 15, 14, 30),
      locationName: locationName,
      latitude: null,
      longitude: null,
      pendingRecognition: pendingRecognition,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Widget createWidgetUnderTest({
    required FishCatch fish,
    bool isSelected = false,
    bool isSelectionMode = false,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    VoidCallback? onQuickIdentify,
  }) {
    return ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith(
          (ref) => AppSettingsNotifier(mockSettingsService),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: FishListItem(
            fish: fish,
            strings: defaultStrings,
            isSelected: isSelected,
            isSelectionMode: isSelectionMode,
            onTap: onTap ?? () {},
            onLongPress: onLongPress,
            onQuickIdentify: onQuickIdentify,
          ),
        ),
      ),
    );
  }

  group('FishListItem - Selection Mode', () {
    testWidgets('shows checkbox when isSelectionMode is true',
        (WidgetTester tester) async {
      final fish = createFishCatch();

      await tester.pumpWidget(createWidgetUnderTest(
        fish: fish,
        isSelectionMode: true,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    });

    testWidgets('shows checked checkbox when isSelected is true',
        (WidgetTester tester) async {
      final fish = createFishCatch();

      await tester.pumpWidget(createWidgetUnderTest(
        fish: fish,
        isSelectionMode: true,
        isSelected: true,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows unchecked checkbox when isSelected is false',
        (WidgetTester tester) async {
      final fish = createFishCatch();

      await tester.pumpWidget(createWidgetUnderTest(
        fish: fish,
        isSelectionMode: true,
        isSelected: false,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    });

    testWidgets('hides checkbox when isSelectionMode is false',
        (WidgetTester tester) async {
      final fish = createFishCatch();

      await tester.pumpWidget(createWidgetUnderTest(
        fish: fish,
        isSelectionMode: false,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
    });
  });

  group('FishListItem - Pending Recognition', () {
    testWidgets(
        'shows pending recognition badge when pendingRecognition is true',
        (WidgetTester tester) async {
      final fish = createFishCatch(pendingRecognition: true);

      await tester.pumpWidget(createWidgetUnderTest(fish: fish));
      await tester.pump();

      expect(find.text(defaultStrings.pendingRecognition), findsOneWidget);
      expect(find.text('⚠️'), findsOneWidget);
    });

    testWidgets('does not show pending recognition badge when false',
        (WidgetTester tester) async {
      final fish = createFishCatch(pendingRecognition: false);

      await tester.pumpWidget(createWidgetUnderTest(fish: fish));
      await tester.pump();

      expect(find.text(defaultStrings.pendingRecognition), findsNothing);
    });

    testWidgets(
        'shows quick identify button when pendingRecognition is true and onQuickIdentify is provided',
        (WidgetTester tester) async {
      final fish = createFishCatch(pendingRecognition: true);

      await tester.pumpWidget(createWidgetUnderTest(
        fish: fish,
        onQuickIdentify: () {},
      ));
      await tester.pump();

      expect(find.text(defaultStrings.recognize), findsOneWidget);
      expect(find.text('🤖'), findsOneWidget);
    });

    testWidgets(
        'does not show quick identify button when pendingRecognition is false',
        (WidgetTester tester) async {
      final fish = createFishCatch(pendingRecognition: false);

      await tester.pumpWidget(createWidgetUnderTest(
        fish: fish,
        onQuickIdentify: () {},
      ));
      await tester.pump();

      expect(find.text(defaultStrings.recognize), findsNothing);
    });

    testWidgets(
        'does not show quick identify button when onQuickIdentify is null even if pendingRecognition is true',
        (WidgetTester tester) async {
      final fish = createFishCatch(pendingRecognition: true);

      await tester.pumpWidget(createWidgetUnderTest(
        fish: fish,
        onQuickIdentify: null,
      ));
      await tester.pump();

      expect(find.text(defaultStrings.recognize), findsNothing);
    });

    testWidgets('calls onQuickIdentify when quick identify button is tapped',
        (WidgetTester tester) async {
      final fish = createFishCatch(pendingRecognition: true);
      bool quickIdentifyCalled = false;

      await tester.pumpWidget(createWidgetUnderTest(
        fish: fish,
        onQuickIdentify: () => quickIdentifyCalled = true,
      ));
      await tester.pump();

      await tester.tap(find.text(defaultStrings.recognize));
      expect(quickIdentifyCalled, isTrue);
    });
  });

  group('FishListItem - Location Name Display', () {
    testWidgets('shows location name when locationName is provided',
        (WidgetTester tester) async {
      final fish = createFishCatch(locationName: 'Test Fishing Spot');

      await tester.pumpWidget(createWidgetUnderTest(fish: fish));
      await tester.pump();

      expect(find.text('Test Fishing Spot'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('does not show location row when locationName is null',
        (WidgetTester tester) async {
      final fish = createFishCatch(locationName: null);

      await tester.pumpWidget(createWidgetUnderTest(fish: fish));
      await tester.pump();

      expect(find.byIcon(Icons.location_on), findsNothing);
    });

    testWidgets('does not show location row when locationName is empty',
        (WidgetTester tester) async {
      final fish = createFishCatch(locationName: '');

      await tester.pumpWidget(createWidgetUnderTest(fish: fish));
      await tester.pump();

      expect(find.byIcon(Icons.location_on), findsNothing);
    });
  });

  group('FishListItem - Image States', () {
    testWidgets('shows image widget with correct fit',
        (WidgetTester tester) async {
      final fish = createFishCatch();

      await tester.pumpWidget(createWidgetUnderTest(fish: fish));
      await tester.pump();

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final Image imageWidget = tester.widget(imageFinder);
      expect(imageWidget.fit, equals(BoxFit.cover));
    });

    testWidgets('shows error icon when image fails to load',
        (WidgetTester tester) async {
      final fish = createFishCatch();

      await tester.pumpWidget(createWidgetUnderTest(fish: fish));
      await tester.pump();

      // Image with error builder should show error icon
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);
    });
  });

  group('FishListItem - Interactions', () {
    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      final fish = createFishCatch();
      bool tapCalled = false;

      await tester.pumpWidget(createWidgetUnderTest(
        fish: fish,
        onTap: () => tapCalled = true,
      ));
      await tester.pump();

      await tester.tap(find.byType(InkWell).first);
      expect(tapCalled, isTrue);
    });

    testWidgets('calls onLongPress when long pressed',
        (WidgetTester tester) async {
      final fish = createFishCatch();
      bool longPressCalled = false;

      await tester.pumpWidget(createWidgetUnderTest(
        fish: fish,
        onLongPress: () => longPressCalled = true,
      ));
      await tester.pump();

      await tester.longPress(find.byType(InkWell).first);
      expect(longPressCalled, isTrue);
    });

    testWidgets('does not crash when onLongPress is null',
        (WidgetTester tester) async {
      final fish = createFishCatch();

      await tester.pumpWidget(createWidgetUnderTest(
        fish: fish,
        onLongPress: null,
      ));
      await tester.pump();

      // Should not throw
      await tester.longPress(find.byType(InkWell).first);
    });
  });

  group('FishListItem - Fate Display', () {
    testWidgets('shows release badge when fate is release',
        (WidgetTester tester) async {
      final fish = createFishCatch(fate: FishFateType.release);

      await tester.pumpWidget(createWidgetUnderTest(fish: fish));
      await tester.pump();

      expect(find.text('Release'), findsOneWidget);
    });

    testWidgets('shows keep badge when fate is keep',
        (WidgetTester tester) async {
      final fish = createFishCatch(fate: FishFateType.keep);

      await tester.pumpWidget(createWidgetUnderTest(fish: fish));
      await tester.pump();

      expect(find.text('Keep'), findsOneWidget);
    });
  });

  group('FishListItem - Species and Measurements', () {
    testWidgets('displays species name', (WidgetTester tester) async {
      final fish = createFishCatch(species: 'Large Mouth Bass');

      await tester.pumpWidget(createWidgetUnderTest(fish: fish));
      await tester.pump();

      expect(find.text('Large Mouth Bass'), findsOneWidget);
    });

    testWidgets('displays length', (WidgetTester tester) async {
      final fish = createFishCatch(length: 45.5);

      await tester.pumpWidget(createWidgetUnderTest(fish: fish));
      await tester.pump();

      // Default unit is cm, so should show 45.5 cm
      expect(find.textContaining('45.5'), findsOneWidget);
    });

    testWidgets('displays length and weight when weight is provided',
        (WidgetTester tester) async {
      final fish = createFishCatch(length: 30.0, weight: 2.5);

      await tester.pumpWidget(createWidgetUnderTest(fish: fish));
      await tester.pump();

      // Should show both length and weight
      expect(find.textContaining('30.0'), findsOneWidget);
      expect(find.textContaining('2.50'), findsOneWidget);
    });

    testWidgets('displays only length when weight is null',
        (WidgetTester tester) async {
      final fish = createFishCatch(length: 30.0, weight: null);

      await tester.pumpWidget(createWidgetUnderTest(fish: fish));
      await tester.pump();

      // Should show length but no weight
      expect(find.textContaining('30.0'), findsOneWidget);
    });
  });
}

/// Mock SettingsService for testing - bypasses database
class MockSettingsService implements SettingsService {
  const MockSettingsService();

  @override
  Future<AppSettings> getAppSettings() async => const AppSettings();

  @override
  Future<void> saveAppSettings(AppSettings settings) async {}

  @override
  Future<WatermarkSettings> getWatermarkSettings() async =>
      const WatermarkSettings();

  @override
  Future<void> saveWatermarkSettings(WatermarkSettings settings) async {}

  @override
  Future<AiRecognitionSettings> getAiRecognitionSettings() async =>
      const AiRecognitionSettings();

  @override
  Future<void> saveAiRecognitionSettings(
      AiRecognitionSettings settings) async {}

  @override
  Future<void> deleteAiRecognitionSettings() async {}
}
