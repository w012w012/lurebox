# Test Suite

**Layer type**: Testing  
**Parent**: `../AGENTS.md` (root)

## OVERVIEW
99 test files (~39k lines). Mirrors `lib/` structure. Uses mocktail + sqflite_ffi.

## STRUCTURE
```
test/
├── camera/           # Camera tests
├── core/constants/   # Constants tests
├── database/         # Database integration tests
├── design/           # Theme/color tests
├── di/               # DI tests
├── features/         # Feature widget tests (10 files)
├── fixtures/         # Test data (test_fish.jpg)
├── helpers/          # Shared mocks + factories
├── models/           # Model unit tests (9 files)
├── providers/        # Provider tests (20 files - LARGEST)
├── repositories/     # Repository integration tests (9 files)
├── services/         # Service tests (17 files)
├── utils/            # Utility tests
├── viewmodels/       # ViewModel tests (8 files)
└── widgets/common/   # Widget tests (7 files)
```

## WHERE TO LOOK
| Task | Location |
|------|----------|
| Add model test | `test/models/[model]_test.dart` |
| Add provider test | `test/providers/[provider]_test.dart` |
| Add service test | `test/services/[service]_test.dart` |
| Add widget test | `test/widgets/common/[widget]_test.dart` |
| Add feature test | `test/features/[feature]_page_test.dart` |
| Shared mocks | `test/helpers/test_helpers.dart` |
| Test data factory | `test/helpers/test_helpers.dart` → `TestDataFactory` |

## CONVENTIONS
- **Naming**: `[subject]_test.dart` mirrors `[subject].dart`
- **Grouping**: Use `group('Description', () { ... })` for nested tests
- **Mocking**: `mocktail` — no code generation needed
- **Database tests**: Use `sqfliteFfiInit()` + `databaseFactoryFfi` in `setUpAll`
- **In-memory DB**: `databaseFactoryFfi.openDatabase(inMemoryDatabasePath, ...)`
- **Test data**: Use `TestDataFactory.createFishCatch()` etc.

## UNIQUE PATTERNS
- **`test/helpers/test_helpers.dart`**: Central hub for mocks, fakes, factories
- **`registerFallbackValues()`**: Single function registers all mocktail fallbacks
- **`runOpenAICompatibleProviderTests()`**: Shared test suite for AI providers
- **Provider tests mirror lib/**: `providers/`, `viewmodels/`, `services/`, `repositories/`
- **Integration tests**: Use real in-memory SQLite with full schema

## ANTI-PATTERNS (THIS LAYER)
- **DO NOT** define mocks per-file — use `test/helpers/test_helpers.dart`
- **DO NOT** skip `registerFallbackValues()` in `setUpAll` — tests will fail
- **DO NOT** use real database — use `sqflite_ffi` in-memory

## COMMANDS
```bash
flutter test                           # Run all tests
flutter test test/models/              # Run model tests only
flutter test --name "fish catch"       # Run by name pattern
flutter test --coverage                # Generate coverage report
```

## NOTES
- 20 provider test files — largest test category
- AI provider tests share `runOpenAICompatibleProviderTests()` helper
- Database tests create full schema in `setUp()` — version 22
- `test/fixtures/` has test images for photo-related tests
