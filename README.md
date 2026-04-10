# 路亚鱼护 (LureBox)

一款专为路亚钓鱼爱好者设计的鱼获记录工具，帮助钓友记录每次出钓的渔获。

**版本**: 1.0.4+4 | **Flutter**: 3.41.6+ | **Dart**: ^3.5.4

## 功能特点

- 📷 **拍照记录** - 快速拍摄鱼获照片，支持 AI 鱼种识别
- 📏 **尺寸记录** - 输入长度，自动估算重量
- 📍 **定位记录** - 自动记录钓获地点，支持地图展示
- 🏷️ **装备管理** - 管理鱼竿、鱼轮、鱼饵，支持设置默认装备
- 🔍 **筛选排序** - 按时间/尺寸/重量/地点筛选和排序
- 📊 **统计分析** - 今日/本月/本年/全部渔获统计，图表可视化
- 🏆 **成就系统** - 记录钓友里程碑
- 🔄 **批量操作** - 支持多选删除
- 📤 **分享** - 一键分享渔获到社交平台
- 💾 **备份导出** - 支持 CSV/PDF/JSON 导出，WebDAV 备份

## 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.41.6 |
| 状态管理 | Riverpod |
| 路由 | GoRouter |
| 数据库 | SQLite (sqflite) |
| 地图 | flutter_map + latlong2 |
| 图表 | fl_chart |
| AI 识别 | 多 Provider 支持 (OpenAI/Claude/Gemini/MiniMax/百度等) |
| 相机 | camera + image_picker |
| 定位 | geolocator + geocoding |
| 天气 | open_meteo |
| 分享 | share_plus |
| 导出 | csv + pdf + printing |
| 备份 | archive + crypto |

## 项目结构

```
lib/
├── core/                    # 核心共享层
│   ├── models/              # 数据模型 (17个)
│   ├── providers/           # Riverpod providers (19个)
│   ├── services/            # 业务服务 (含12个AI provider)
│   ├── repositories/        # 数据访问层
│   ├── database/            # SQLite 数据库
│   ├── router/              # GoRouter 配置
│   ├── di/                  # 依赖注入
│   ├── constants/           # 常量 (字符串/成就/价格区间)
│   ├── design/              # 主题/颜色
│   ├── utils/               # 工具类
│   └── exceptions/          # 自定义异常
├── features/                # 功能模块 (10个feature)
│   ├── home/                # 首页
│   ├── fish_list/           # 鱼获列表
│   ├── fish_detail/         # 鱼获详情
│   ├── camera/              # 拍照
│   ├── equipment/           # 装备管理
│   ├── stats/               # 统计
│   ├── achievement/         # 成就
│   └── settings/            # 设置
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

## 架构特点

- **状态管理**: Riverpod StateNotifierProvider 模式
- **数据层**: Repository 抽象模式（接口 + 实现分离）
- **AI 识别**: 可插拔 Provider 架构，12 种 AI 服务商支持
- **主题**: 双主题支持（light/dark），中文/英文国际化

## 许可证

MIT
