# Feature Modules - UI Layer

**Layer type**: Presentation  
**Parent**: `../AGENTS.md` (root)

## OVERVIEW
14 feature modules, each with page + widgets subdirectory. All features import from `core/`.

## STRUCTURE
```
features/
├── achievement/      # 成就系统 (2 widgets, fish_guide_data/)
├── camera/           # 拍照识别 (1 widget)
├── catch/            # 渔获记录 (7 widgets)
├── common/           # 通用功能 (watermarked_image)
├── equipment/        # 装备管理 (6 widgets)
├── fish_detail/      # 鱼获详情 (4 widgets)
├── fish_list/        # 鱼获列表 (5 widgets)
├── home/             # 首页仪表盘
├── location/         # 位置管理 (5 widgets)
├── me/               # 个人中心
├── onboarding/       # 新手引导
├── settings/         # 设置 (17 widgets - LARGEST)
├── share/            # 分享功能 (3 widgets)
└── stats/            # 统计分析 (5 widgets)
```

## WHERE TO LOOK
| Task | Location |
|------|----------|
| Add new feature | Create `features/[name]/` with `[name]_page.dart` + `widgets/` |
| Add feature widget | `features/[name]/widgets/` |
| Feature barrel export | `features/features.dart` — add export here |
| Shared feature widget | `features/common/` |

## CONVENTIONS
- **Page naming**: `[feature]_page.dart` (e.g., `home_page.dart`)
- **Widget subdirectory**: Each feature has `widgets/` for local widgets
- **ConsumerWidget**: Use for simple state consumption
- **ConsumerStatefulWidget**: Use when local state + provider access needed
- **Private widgets**: Prefix with `_` (e.g., `_HomePageBody`)
- **Extract helpers**: Large widget trees → `_buildXxx()` methods

## ANTI-PATTERNS (THIS LAYER)
- **DO NOT** put shared widgets in feature `widgets/` — use `lib/widgets/common/` instead
- **DO NOT** create feature-specific providers here — use `core/providers/`
- **DO NOT** access database directly — use `core/repositories/`

## UNIQUE STYLES
- Settings has 17 widgets — largest feature module
- Achievement has `fish_guide_data/` subdirectory for static data
- Camera feature has split logic with `core/camera/` (infrastructure)
- Some features have 0 root files (location, catch) — only widgets subdirectory

## COMMANDS
```bash
flutter test test/features/    # Run feature tests
flutter analyze                # Check for issues
```

## NOTES
- 55+ widget files across features vs 17 in `lib/widgets/common/`
- Features barrel exports 39 items via `features.dart`
- Camera logic split between `core/camera/` and `features/camera/`
