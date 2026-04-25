# 路亚鱼护 (LureBox)

一款专为路亚钓鱼爱好者设计的鱼获记录工具，帮助钓友记录每次出钓的渔获。

**版本**: 1.0.5+5 | **Flutter**: 3.41.6+ | **Dart**: ^3.5.4

## 功能特点

- 📷 **拍照记录** - 快速拍摄鱼获照片，支持 AI 鱼种识别
- 📏 **尺寸记录** - 输入长度，自动估算重量
- 📍 **定位记录** - 自动记录钓获地点，支持位置管理
- 🏷️ **装备管理** - 管理鱼竿、鱼轮、鱼饵，支持设置默认装备
- 🔍 **筛选排序** - 按时间/尺寸/重量/地点筛选和排序
- 📊 **统计分析** - 今日/本月/本年/全部渔获统计，图表可视化
- 🏆 **成就系统** - 记录钓友里程碑
- 🔄 **批量操作** - 支持多选删除
- 📤 **分享** - 一键分享渔获到社交平台
- 💾 **备份导出** - 支持 CSV/JSON 导出，WebDAV 备份
- 🌐 **多语言** - 中英文双语支持，i18n mixin 国际化架构
- 🎓 **新手引导** - 首次使用 Onboarding 引导页
- 👤 **个人中心** - Me 页面，管理个人信息和设置

## 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.41.6 |
| 状态管理 | Riverpod |
| 路由 | GoRouter |
| 数据库 | SQLite (sqflite) |
| 定位 | geolocator + geocoding |
| 图表 | fl_chart |
| AI 识别 | 多 Provider 支持 (OpenAI/Claude/Gemini/MiniMax/百度/腾讯/阿里云等) |
| 相机 | camera + image_picker |
| 天气 | open_meteo |
| 分享 | share_plus |
| 导出 | csv + json |
| 备份 | archive + crypto |

## 项目结构

```
lib/
├── core/                    # 核心共享层
│   ├── models/              # 数据模型 (16个)
│   ├── providers/           # Riverpod providers (21个)
│   ├── services/            # 业务服务 (含13个AI adapter)
│   ├── repositories/        # 数据访问层
│   ├── database/            # SQLite 数据库
│   ├── router/              # GoRouter 配置
│   ├── di/                  # 依赖注入
│   ├── constants/           # 常量 (字符串/成就/价格区间)
│   ├── design/              # 主题/颜色
│   ├── utils/               # 工具类
│   └── exceptions/          # 自定义异常
├── features/                # 功能模块 (14个feature)
│   ├── home/                # 首页
│   ├── fish_list/           # 鱼获列表
│   ├── fish_detail/         # 鱼获详情
│   ├── camera/              # 拍照
│   ├── catch/               # 渔获记录
│   ├── equipment/           # 装备管理
│   ├── stats/               # 统计
│   ├── achievement/         # 成就
│   ├── settings/            # 设置
│   ├── onboarding/          # 新手引导
│   ├── me/                  # 个人中心
│   ├── location/            # 位置管理
│   ├── share/               # 分享功能
│   └── common/              # 通用功能
├── widgets/                 # 通用组件 (含settings/子目录)
└── main.dart                # 入口
```

## 运行与构建

```bash
# 安装依赖
flutter pub get

# 运行调试
flutter run

# 构建 Android
flutter build apk

# 构建 iOS (需要 macOS + Xcode)
flutter build ios

# 代码检查
flutter analyze

# 格式化
dart format .
```

## 测试

```bash
# 运行所有测试
flutter test

# 运行单个文件
flutter test test/fish_catch_model_test.dart

# 按名称运行
flutter test --name "fish catch"

# 生成覆盖率
flutter test --coverage
```

## 数据模型

- **鱼获记录**: 品种、尺寸、重量、去向（放流/保留）、时间、地点、装备、照片
- **装备管理**: 鱼竿、鱼轮、鱼饵（品牌、型号、长度、调性等参数）
- **品种历史**: 自动记录常用品种，支持别名
- **位置管理**: 钓点名称、坐标、钓获统计
- **i18n 字符串**: 中英文双语，通过 `AppStrings` mixin 在 Riverpod 中提供
- **路由参数验证**: GoRouter 路由参数白名单校验（如装备类型、鱼获 ID）

## 架构特点

- **状态管理**: Riverpod StateNotifierProvider 模式
- **数据层**: Repository 抽象模式（接口 + 实现分离）
- **AI 识别**: 可插拔 Provider 架构，13 种 AI 服务商支持
- **日志**: AppLogger 集中日志，Release 模式自动抑制
- **主题**: Tesla -inspired 设计系统，Electric Blue (#3E6AE1) + Carbon Dark (#171A20)，详细规范见 `DESIGN.md`

## 许可证

MIT
