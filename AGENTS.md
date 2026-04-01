# LureBox Development Guide

## Project Overview
LureBox (路亚鱼护) is a Flutter app for recording fishing catches. It uses Riverpod for state management and SQLite for local storage.

**Environment**: Flutter 3.11+, Dart SDK ^3.5.4, version 1.0.3+3

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
- Services return `Future<T>` or `Future<T?>`
- Database operations wrapped in try-catch
- Use `FlutterError.onError` in main.dart
- Log errors with `debugPrint()` for debugging

### Design System
- Colors defined in `core/design/theme/app_colors.dart` with light/dark variants
- Theme configuration in `core/design/theme/app_theme.dart`
- Use `AppColors.primaryLight`, `AppColors.accentLight`, etc.
- Status colors: `AppColors.release` (green), `AppColors.keep` (orange)
- Chinese string constants in `core/constants/strings.dart` (`AppStrings` class)

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
│   ├── models/           # Data models (13 models: FishCatch, Equipment, etc.)
│   ├── providers/        # Riverpod providers & notifiers (19 files)
│   ├── services/         # Business logic (17 services)
│   ├── database/         # DatabaseProvider singleton
│   ├── constants/        # AppStrings, achievements, price ranges
│   ├── design/           # Theme, colors (light/dark), styles
│   ├── utils/            # Helpers, converters
│   └── widgets/          # Shared widgets
├── features/             # Feature modules (home, fish_list, fish_detail, etc.)
├── widgets/              # Common UI components
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
- Current version: **11** (defined in `database_provider.dart`)
- Tables: `fish_catches`, `equipments`, `species_history`, `settings`
- Foreign keys enabled via `PRAGMA foreign_keys = ON`
- Downgrade: no-op (preserves data)
