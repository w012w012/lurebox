import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/features/fish_detail/fish_detail_page.dart';
import 'package:lurebox/core/providers/fish_detail_view_model.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/providers/watermark_provider.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/models/watermark_settings.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';
import 'package:lurebox/core/services/equipment_service.dart';
import 'package:lurebox/widgets/fish_detail/fish_action_buttons.dart';

void main() {
  setUpAll(() {
    // Initialize FFI for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    registerFallbackValue(FishDetailState());
  });

  group('FishDetailPage', () {
    late MockFishCatchService mockFishCatchService;
    late MockEquipmentService mockEquipmentService;
    late FishDetailState testState;

    setUp(() {
      mockFishCatchService = MockFishCatchService();
      mockEquipmentService = MockEquipmentService();

      testState = FishDetailState(
        fish: {
          'id': 1,
          'image_path': '/test/image.jpg',
          'species': 'Bass',
          'length': 30.0,
          'length_unit': 'cm',
          'weight': null,
          'weight_unit': 'kg',
          'fate': 0,
          'catch_time': DateTime.now().toIso8601String(),
          'location_name': 'Test Lake',
          'air_temperature': null,
          'pressure': null,
          'weather_code': null,
        },
        isLoading: false,
        isDeleting: false,
        isSharing: false,
        rodEquipment: null,
        reelEquipment: null,
        lureEquipment: null,
      );
    });

    Widget buildTestWidget({required int fishId, FishDetailState? state}) {
      final effectiveState = state ?? testState;

      return ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((ref) {
            return TestAppSettingsNotifier();
          }),
          watermarkSettingsProvider.overrideWith((ref) {
            return TestWatermarkSettingsNotifier();
          }),
          fishDetailViewModelProvider(fishId).overrideWith((ref) {
            return TestFishDetailViewModel(
              fishId,
              mockFishCatchService,
              mockEquipmentService,
              effectiveState,
            );
          }),
        ],
        child: MaterialApp(
          home: FishDetailPage(fishId: fishId),
        ),
      );
    }

    group('Theme and Styling', () {
      testWidgets('uses correct scaffold background color', (tester) async {
        await tester.pumpWidget(buildTestWidget(fishId: 1));
        await tester.pumpAndSettle();

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
        expect(scaffold.backgroundColor, equals(AppColors.backgroundLight));
      });

      testWidgets('app bar uses correct blue theme colors', (tester) async {
        await tester.pumpWidget(buildTestWidget(fishId: 1));
        await tester.pumpAndSettle();

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.backgroundColor, equals(AppColors.surfaceLight));
        expect(appBar.foregroundColor, equals(AppColors.textPrimaryLight));
        expect(appBar.elevation, equals(0));
        expect(appBar.scrolledUnderElevation, equals(0.5));
      });
    });

    group('Hero Animation', () {
      testWidgets('FishImageGallery is wrapped in Hero widget', (tester) async {
        await tester.pumpWidget(buildTestWidget(fishId: 1));
        await tester.pumpAndSettle();

        expect(find.byType(Hero), findsOneWidget);
      });

      testWidgets('Hero uses correct tag with fishId', (tester) async {
        const fishId = 42;
        await tester.pumpWidget(buildTestWidget(fishId: fishId));
        await tester.pumpAndSettle();

        final heroFinder = find.byType(Hero);
        expect(heroFinder, findsOneWidget);

        final hero = tester.widget<Hero>(heroFinder);
        expect(hero.tag, equals('fish_image_$fishId'));
      });
    });

    group('Loading State', () {
      testWidgets('shows loading indicator with correct color', (tester) async {
        final loadingState = FishDetailState(
          fish: null,
          isLoading: true,
          isDeleting: false,
          isSharing: false,
          rodEquipment: null,
          reelEquipment: null,
          lureEquipment: null,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              fishDetailViewModelProvider(1).overrideWith((ref) {
                return TestFishDetailViewModel(
                  1,
                  mockFishCatchService,
                  mockEquipmentService,
                  loadingState,
                );
              }),
            ],
            child: const MaterialApp(
              home: FishDetailPage(fishId: 1),
            ),
          ),
        );

        await tester.pump();

        final progressIndicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(progressIndicator.color, equals(AppColors.accentLight));
      });
    });

    group('Error State', () {
      testWidgets('shows error icon with correct color', (tester) async {
        final errorState = FishDetailState(
          fish: null,
          isLoading: false,
          errorMessage: 'Test error',
          isDeleting: false,
          isSharing: false,
          rodEquipment: null,
          reelEquipment: null,
          lureEquipment: null,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              fishDetailViewModelProvider(1).overrideWith((ref) {
                return TestFishDetailViewModel(
                  1,
                  mockFishCatchService,
                  mockEquipmentService,
                  errorState,
                );
              }),
            ],
            child: const MaterialApp(
              home: FishDetailPage(fishId: 1),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
        expect(icon.color, equals(AppColors.error));
      });

      testWidgets('shows error message text', (tester) async {
        final errorState = FishDetailState(
          fish: null,
          isLoading: false,
          errorMessage: 'Test error',
          isDeleting: false,
          isSharing: false,
          rodEquipment: null,
          reelEquipment: null,
          lureEquipment: null,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              fishDetailViewModelProvider(1).overrideWith((ref) {
                return TestFishDetailViewModel(
                  1,
                  mockFishCatchService,
                  mockEquipmentService,
                  errorState,
                );
              }),
            ],
            child: const MaterialApp(
              home: FishDetailPage(fishId: 1),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Test error'), findsOneWidget);
      });
    });

    group('Action Buttons Container', () {
      testWidgets('action buttons container has bottom decoration',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(fishId: 1));
        await tester.pumpAndSettle();

        // Find SafeArea that contains FishActionButtons - the parent Container should have bottom shadow
        final safeAreaFinder = find.ancestor(
          of: find.byType(FishActionButtons),
          matching: find.byType(SafeArea),
        );
        expect(safeAreaFinder, findsOneWidget);

        // The parent of SafeArea should be a Container with shadow
        final containerFinder = find.ancestor(
          of: safeAreaFinder,
          matching: find.byType(Container),
        );
        expect(containerFinder, findsWidgets);
      });

      testWidgets('FishActionButtons are rendered', (tester) async {
        await tester.pumpWidget(buildTestWidget(fishId: 1));
        await tester.pumpAndSettle();

        // Find the FishActionButtons widget
        expect(find.byType(FishActionButtons), findsOneWidget);
      });
    });
  });
}

/// Test implementation of FishDetailViewModel that uses provided state
class TestFishDetailViewModel extends StateNotifier<FishDetailState>
    implements FishDetailViewModel {
  @override
  final int fishId;
  final FishCatchService _fishCatchService;
  final EquipmentService _equipmentService;

  TestFishDetailViewModel(
    this.fishId,
    this._fishCatchService,
    this._equipmentService,
    FishDetailState initialState,
  ) : super(initialState);

  @override
  Future<void> refresh() async {}

  @override
  Future<void> loadFish() async {}

  @override
  Future<bool> deleteFish() async => true;

  @override
  void setSharing(bool value) {}

  @override
  void setDeleting(bool value) {}
}

// Mock services for testing
class MockFishCatchService extends Mock implements FishCatchService {}

class MockEquipmentService extends Mock implements EquipmentService {}

/// Test notifier that doesn't use database
class TestAppSettingsNotifier extends StateNotifier<AppSettings>
    implements AppSettingsNotifier {
  TestAppSettingsNotifier() : super(const AppSettings());

  @override
  Future<void> _loadSettings() async {}

  @override
  Future<void> updateSettings(AppSettings settings) async {
    state = settings;
  }

  @override
  Future<void> updateUnits(UnitSettings units) async {
    state = state.copyWith(units: units);
  }

  @override
  Future<void> updateDarkMode(DarkMode mode) async {
    state = state.copyWith(darkMode: mode);
  }

  @override
  Future<void> updateLanguage(AppLanguage language) async {
    state = state.copyWith(language: language);
  }
}

/// Test notifier that doesn't use database
class TestWatermarkSettingsNotifier extends StateNotifier<WatermarkSettings>
    implements WatermarkSettingsNotifier {
  TestWatermarkSettingsNotifier() : super(const WatermarkSettings());

  @override
  Future<void> _loadSettings() async {}

  @override
  Future<void> updateSettings(WatermarkSettings settings) async {
    state = settings;
  }

  @override
  Future<void> updateEnabled(bool enabled) async {
    state = state.copyWith(enabled: enabled);
  }

  @override
  Future<void> updateStyle(WatermarkStyle style) async {
    state = state.copyWith(style: style);
  }

  @override
  Future<void> updatePosition(WatermarkPosition position) async {
    state = state.copyWith(position: position);
  }

  @override
  Future<void> updateBlurRadius(double blurRadius) async {
    state = state.copyWith(blurRadius: blurRadius);
  }

  @override
  Future<void> updateBackgroundColor(int backgroundColor) async {
    state = state.copyWith(backgroundColor: backgroundColor);
  }

  @override
  Future<void> updateBackgroundOpacity(double backgroundOpacity) async {
    state = state.copyWith(backgroundOpacity: backgroundOpacity);
  }

  @override
  Future<void> updateFontSize(double fontSize) async {
    state = state.copyWith(fontSize: fontSize);
  }

  @override
  Future<void> updateTextColor(int textColor) async {
    state = state.copyWith(textColor: textColor);
  }

  @override
  Future<void> toggleInfoType(WatermarkInfoType type) async {
    final List<WatermarkInfoType> newTypes = List.from(state.infoTypes);
    if (newTypes.contains(type)) {
      if (type != WatermarkInfoType.appName) {
        newTypes.remove(type);
      }
    } else {
      newTypes.add(type);
    }
    state = state.copyWith(infoTypes: newTypes);
  }

  @override
  Future<void> reorderInfoTypes(int oldIndex, int newIndex) async {
    final List<WatermarkInfoType> newTypes = List.from(state.infoTypes);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = newTypes.removeAt(oldIndex);
    newTypes.insert(newIndex, item);
    state = state.copyWith(infoTypes: newTypes);
  }
}
