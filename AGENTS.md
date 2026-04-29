# LureBox Development Guide

## Project Overview
LureBox (路亚鱼护) is a Flutter app for recording fishing catches. It uses Riverpod for state management and SQLite for local storage.

**Environment**: Flutter 3.41.6+, Dart SDK ^3.5.4, version 1.0.5+5

**Android Config**: compileSdk=36, Kotlin 2.1.0

## Build & Run Commands
```bash
flutter pub get              # Install dependencies
flutter run                  # Run on connected device
flutter build apk            # Build Android APK
flutter build ios            # Build iOS (requires macOS + Xcode)
flutter analyze              # Run static analysis
dart format .                # Format all Dart files
```

## CI/CD
**No CI/CD pipeline configured** - all builds are local. Run `flutter analyze` and `flutter test` manually before commits.

## Anti-Patterns (THIS PROJECT)
- No anti-pattern comments (`DO NOT`, `NEVER`, `ALWAYS`, `DEPRECATED`) found in code
- **Architecture deviation**: Widgets exist in BOTH `lib/widgets/` AND nested in `lib/features/` - dual location creates confusion
- **Architecture deviation**: AI providers in `core/services/adapters/` (13 files) - non-standard location
- **Architecture deviation**: `core/camera/` separate from `features/camera/` - camera logic split

## Code Style

**Imports**: Flutter packages first, then relative project imports.

**Widgets**: `ConsumerWidget` (simple) or `ConsumerStatefulWidget` (local state). Prefix private with `_`. Extract `_buildXxx()` helpers.

**State (Riverpod)**: Providers in `core/providers/`. `StateNotifierProvider` for complex state, `StateProvider` for simple values.

**Models**: Immutable, `const` constructors. Implement `fromMap()`, `toMap()`, `copyWith()`. Override `==`/`hashCode` on `id`.

**Naming**: `snake_case.dart` files, `PascalCase` classes, `camelCase` vars/methods. Providers: `camelCaseProvider`.

**Error Handling**: `AppSnackBar.showSuccess/showError/showInfo` — NOT raw `ScaffoldMessenger`. Log with `AppLogger.e()`.

**Design (Tesla-Inspired)**: See `DESIGN.md`. Electric Blue CTAs only. No gradients/shadows. w400/w500 only.

**Color Classes**: `TeslaColors` = design tokens. `AppColors` = semantic (release=green, keep=orange).

## Project Structure
```
lib/                          # 335 Dart files, ~91k lines
├── core/                     # Shared infrastructure (109 files)
│   ├── models/               # Data models (16 models: FishCatch, Equipment, etc.)
│   ├── providers/            # Riverpod providers & notifiers (21 files)
│   ├── services/             # Business logic (34 files, including 13 AI adapters)
│   ├── repositories/         # Repository interfaces + implementations (16 files)
│   ├── database/             # DatabaseProvider singleton
│   ├── constants/            # AppStrings, achievements, price ranges
│   ├── design/               # Theme, colors (light/dark), styles
│   ├── utils/                # Helpers, converters
│   ├── exceptions/           # Custom exceptions (SpeciesAliasException)
│   └── widgets/              # Shared core widgets (ErrorView, AppEmptyState)
├── features/                 # 14 feature modules (55+ widgets)
│   ├── home/                 # 首页仪表盘
│   ├── fish_list/            # 鱼获列表
│   ├── fish_detail/          # 鱼获详情
│   ├── camera/               # 拍照识别
│   ├── catch/                # 渔获记录
│   ├── equipment/            # 装备管理
│   ├── stats/                # 统计分析
│   ├── achievement/          # 成就系统
│   ├── settings/             # 设置 (17 widgets - largest)
│   ├── onboarding/           # 新手引导
│   ├── me/                   # 个人中心
│   ├── location/             # 位置管理
│   ├── share/                # 分享功能
│   └── common/               # 通用功能
├── widgets/                  # Common UI components (17 files)
├── core.dart                 # Barrel export (95 exports)
├── features.dart             # Feature barrel export (39 exports)
└── main.dart                 # App entry point
test/                         # 99 test files, ~39k lines
├── helpers/                  # Shared mocks + TestDataFactory
├── providers/                # Provider tests (20 files - largest)
├── services/                 # Service tests (17 files)
├── repositories/             # Repository integration tests
├── models/                   # Model unit tests
├── viewmodels/               # ViewModel tests
├── features/                 # Feature widget tests
└── widgets/common/           # Widget tests
```

## Key Dependencies
- `flutter_riverpod` - State management
- `sqflite` - SQLite database
- `camera` / `image_picker` - Photo capture
- `geolocator` - GPS location
- `fl_chart` - Charts/statistics
- `open_meteo` - Weather data
- `mocktail` - Test mocking
- `share_plus` - Social sharing
- `csv` - Export functionality (CSV/JSON)
- `archive`, `crypto` - Backup functionality

## Database
- SQLite via sqflite
- Schema versioning in `DatabaseProvider._onUpgrade`
- Current version: **23** (defined in `database_provider.dart`)
- Tables: `fish_catches`, `equipments`, `species_history`, `settings`
- Foreign keys enabled via `PRAGMA foreign_keys = ON`
- Downgrade: no-op (preserves data)
