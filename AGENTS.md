# LureBox Development Guide

## Project Overview
LureBox (路亚鱼护) is a Flutter app for recording fishing catches. It uses Riverpod for state management and SQLite for local storage.

**Environment**: Flutter 3.41.6+, Dart SDK ^3.11.4, version 1.0.4+4

## Build & Run Commands
```bash
flutter pub get              # Install dependencies
flutter run                  # Run on connected device
flutter build apk            # Build Android APK
flutter build ios            # Build iOS (requires macOS + Xcode)
```

## Lint & Format
```bash
flutter analyze              # Run static analysis (uses flutter_lints)
dart format .                # Format all Dart files
dart format --set-exit-if-changed .  # Check formatting (CI mode)
```

## CI/CD
**No CI/CD pipeline configured** - all builds are local:
- No GitHub Actions, no automated tests on push
- Run `flutter analyze` and `flutter test` manually before commits
- Consider adding `.github/workflows/flutter.yml` for automation

## Testing Commands
```bash
flutter test                           # Run all tests
flutter test test/fish_catch_model_test.dart  # Run single test file
flutter test --name "test name"        # Run test by name pattern
flutter test --coverage                # Generate coverage report
```

**Test setup for database tests:**
```dart
setUpAll(() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
});
```

Use helpers from `test/helpers/test_helpers.dart`:
- `MockDatabase`, `MockFishCatchRepository`, etc.
- `TestDataFactory.createFishCatch()`, `createEquipment()`
- `registerFallbackValues()` in `setUpAll`

## Anti-Patterns (THIS PROJECT)
- No anti-pattern comments (`DO NOT`, `NEVER`, `ALWAYS`, `DEPRECATED`) found in code
- **Architecture deviation**: Widgets exist in BOTH `lib/widgets/` AND nested in `lib/features/` - dual location creates confusion
- **Architecture deviation**: AI providers in `core/services/adapters/` (12 files) - non-standard location
- **Architecture deviation**: `core/camera/` separate from `features/camera/` - camera logic split

## Code Style

### Imports
```dart
// Flutter & packages first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Then relative project imports
import '../../core/models/fish_catch.dart';
import '../widgets/common/card.dart';
```

### Widget Structure
- Use `ConsumerWidget` for simple state consumption
- Use `ConsumerStatefulWidget` when local state + provider access needed
- Prefix private widgets with `_` (e.g., `_HomePageBody`)
- Use `const` constructors where possible
- Extract large widget trees into private helper methods (e.g., `_buildCatchCard()`)

### State Management (Riverpod)
```dart
// Providers in core/providers/
final homeViewModelProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref.read(fishCatchServiceProvider));
});
```
- Providers grouped by feature (e.g., `fish_list_view_model.dart`, `equipment_providers.dart`)
- Use `StateNotifierProvider` for complex state, `StateProvider` for simple values
- Notifiers live alongside providers in the same file

### Models
- Immutable classes with `const` constructors
- Implement `fromMap(Map<String, dynamic>)` factory
- Implement `toMap()` method for serialization
- Implement `copyWith()` for immutable updates
- Override `==` and `hashCode` based on `id`
- Use extensions for list operations (e.g., `FishCatchListExtension`)
- Enums use `.value` (int) and `.label` (String) pattern with `fromValue()` factory

### Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/methods: `camelCase`
- Private: prefix with `_`
- Enums: `PascalCase` with `.value` and `.label` fields
- Providers: `camelCaseProvider` (e.g., `homeViewModelProvider`)
- Services: `camelCaseService` (e.g., `FishCatchService`)

### Error Handling
- Use `ErrorView` widget for UI error states
- Use `AppSnackBar.showSuccess/showError/showInfo` for toast messages — do NOT use raw `ScaffoldMessenger`
- Services return `Future<T>` or `Future<T?>`
- Database operations wrapped in try-catch
- Use `FlutterError.onError` in main.dart
- Log errors with `debugPrint()` for debugging

### Design System (Tesla-Inspired)
Reference: `DESIGN.md` for full specification.

**Core tokens** in `core/design/theme/`:
- `TeslaColors` — Electric Blue (#3E6AE1), Carbon Dark (#171A20), Graphite (#393C41), etc.
- `TeslaTheme` — light/dark ThemeData, 4px button radius, 12px card radius
- `TeslaTokens` — spacing (8px base), radius, shadowNone
- `TeslaTypography` — 14px body (w400), 14px UI (w500), 40px hero (w500)
- `TeslaAnimation` — 330ms cubic-bezier(0.16, 1, 0.3, 1) transitions

**Rules** (from DESIGN.md):
- Electric Blue for CTAs only — never decorative
- No gradients, no shadows on cards
- Typography: w400 (body) / w500 (headings/UI) only — no bold
- 4px radius buttons, 12px radius cards
- frosted glass nav: `TeslaColors.frostedGlassWhite` / `frostedGlassDark`

**Preserved** (not migrated, used for semantic meaning):
- `AppColors.gold/silver/bronze` — trophy/achievement colors
- `AppColors.release`/`AppColors.keep` — fish fate status labels (green/orange, NOT TeslaColors)
- Legacy `AppColors`/`AppTheme` for test compatibility

**Color class usage rule**:
- `TeslaColors` — design tokens per TESLA spec (Electric Blue, Carbon Dark, Frosted Glass, etc.)
- `AppColors` — semantic/functional colors (release=green, keep=orange, success, danger, warning)
- Fate indicator components (selector, filter chips, list items) must use `AppColors.release/keep`, NOT `TeslaColors`

### Testing
- Group tests with `group('Description', () { ... })`
- Use `setUp()` for per-test initialization
- Use `setUpAll()` for one-time setup (database init)
- Mock repositories with `mocktail`
- Test models: creation, serialization, copyWith, equality
- Test extensions: filtering, sorting, searching

## Project Structure
```
lib/
├── core/
│   ├── models/           # Data models (17 models: FishCatch, Equipment, etc.)
│   ├── providers/        # Riverpod providers & notifiers (19 files)
│   ├── services/         # Business logic (18 services)
│   ├── database/         # DatabaseProvider singleton
│   ├── constants/        # AppStrings, achievements, price ranges
│   ├── design/           # Theme, colors (light/dark), styles
│   ├── utils/            # Helpers, converters
│   ├── exceptions/       # Custom exceptions (SpeciesAliasException)
│   └── widgets/          # Shared widgets
├── features/             # Feature modules (home, fish_list, fish_detail, etc.)
├── widgets/              # Common UI components (including settings/ subdirectory)
└── main.dart             # App entry point
```

## Key Dependencies
- `flutter_riverpod` - State management
- `sqflite` - SQLite database
- `camera` / `image_picker` - Photo capture
- `geolocator` - GPS location
- `flutter_map` - Map display
- `fl_chart` - Charts/statistics
- `open_meteo` - Weather data
- `mocktail` - Test mocking
- `share_plus` - Social sharing
- `csv`, `pdf`, `printing` - Export functionality
- `archive`, `crypto` - Backup functionality

## Database
- SQLite via sqflite
- Schema versioning in `DatabaseProvider._onUpgrade`
- Current version: **22** (defined in `database_provider.dart`)
- Tables: `fish_catches`, `equipments`, `species_history`, `settings`
- Foreign keys enabled via `PRAGMA foreign_keys = ON`
- Downgrade: no-op (preserves data)
