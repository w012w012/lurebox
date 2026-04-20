# Core Layer - Shared Infrastructure

**Layer type**: Domain + Data + Shared Services  
**Parent**: `../AGENTS.md` (root)

## OVERVIEW
Central shared layer: models, providers, services, repositories, database. All features import from here.

## STRUCTURE
```
core/
├── models/          # 17 data models (FishCatch, Equipment, etc.)
├── providers/       # 19 Riverpod providers/notifiers
├── services/       # 18 business logic services (+ secure_storage_service)
├── repositories/   # Repository interfaces + implementations
├── database/       # DatabaseProvider singleton
├── router/         # GoRouter configuration
├── di/             # Riverpod DI setup
├── constants/      # AppStrings, achievements, price ranges
├── design/         # Theme, colors (light/dark)
├── utils/          # Helpers, converters
├── exceptions/     # Custom exception types (SpeciesAliasException, etc.)
└── widgets/        # Shared core widgets (ErrorView, AppEmptyState, LoadingView)
```

## WHERE TO LOOK
| Task | Location |
|------|----------|
| Add/modify model | `models/` - follow fromMap/toMap/copyWith pattern |
| Add provider | `providers/` - StateNotifierProvider or Provider |
| Add service | `services/` - async methods, try-catch |
| Add repository | `repositories/` - interface + impl in same dir |
| DI configuration | `di/di.dart` - override providers here |
| Database schema | `database/database_provider.dart` - schema v22 |
| Theme/colors | `design/theme/` - AppColors, AppTheme |
| String constants | `constants/strings.dart` - AppStrings class |

## CONVENTIONS
- **Barrel exports**: `core.dart` exports all core modules
- **Provider naming**: `camelCaseProvider` suffix
- **Service naming**: `CamelCaseService`
- **Repository**: interface in `repositories/`, impl in `*_repository_impl.dart`
- **AI providers**: 12 implementations in `services/adapters/` (openai, claude, gemini, minimax, etc.)
- **No anti-pattern comments** in code

## ANTI-PATTERNS (THIS LAYER)
- **DO NOT** put feature-specific widgets in `core/widgets/` - use `lib/widgets/` instead
- **DO NOT** create new barrel exports without updating `core.dart`
- **DO NOT** bypass repository pattern for database access

## UNIQUE STYLES
- State classes are inner classes (e.g., `HomeState` in `home_view_model.dart`)
- Provider `hide` directives in `providers.dart` exports to prevent circular deps
- Settings use `SettingsRepository` abstraction pattern
- AI recognition has pluggable provider architecture in `services/providers/`

## COMMANDS
```bash
flutter pub get
flutter analyze
```

## NOTES
- 199 Dart files in lib/, 109 exports via `core.dart` barrel
- All features depend on this layer - changes here affect everything
- `core/services/adapters/` has 12 AI provider implementations
