import 'package:flutter/material.dart';

/// Blue-based 调色板 (iOS style)
class AppColors {
  // 主色系 - 深海蓝
  static const Color primaryLight = Color(0xFF1E3A5F); // 深海蓝
  static const Color primaryDark = Color(0xFF8FADC5); // 浅蓝（深色模式对比色）

  // 次要色系
  static const Color secondaryLight = Color(0xFF4A637E); // 中蓝灰
  static const Color secondaryDark = Color(0xFF8BA3B8); // 浅蓝灰

  // 强调色 - 亮蓝色
  static const Color accentLight = Color(0xFF3B82F6); // 亮蓝
  static const Color accentDark = Color(0xFF93C5FD); // 浅亮蓝

  // 表面色
  static const Color surfaceLight = Color(0xFFFFFFFF); // 白色
  static const Color surfaceDark = Color(0xFF0A0A0A); // 深黑（卡片色）

  // 背景色
  static const Color backgroundLight = Color(0xFFF7FAFC); // 极浅灰
  static const Color backgroundDark = Color(0xFF000000); // 纯黑（True Black）

  // 边框色
  static const Color borderLight = Color(0xFFE2E8F0); // 浅灰边框
  static const Color borderDark = Color(0xFF1E293B); // 深蓝灰边框

  // 文字色
  static const Color textPrimaryLight = Color(0xFF1E3A5F); // 主要文字（浅色模式）
  static const Color textSecondaryLight = Color(0xFF4A637E); // 次要文字（浅色模式）
  static const Color textPrimaryDark = Color(0xFFE2E8F0); // 主要文字（深色模式）
  static const Color textSecondaryDark = Color(0xFFA0AEC0); // 次要文字（深色模式）

  // 状态色
  static const Color success = Color(0xFF48BB78); // 成功（柔和绿）
  static const Color warning = Color(0xFFECC94B); // 警告（柔和黄）
  static const Color error = Color(0xFFFC8181); // 错误（柔和红）
  static const Color info = Color(0xFF63B3ED); // 信息（柔和蓝）

  // 奖牌色
  static const Color gold = Color(0xFFD69E2E); // 金牌
  static const Color silver = Color(0xFFA0AEC0); // 银牌
  static const Color bronze = Color(0xFFC77B3F); // 铜牌

  // 渔获状态色（放流/保留）
  static const Color release = Color(0xFF48BB78); // 放流（绿色）
  static const Color releaseBackground = Color(0xFFE6FFFA); // 放流背景
  static const Color keep = Color(0xFFED8936); // 保留（橙色）
  static const Color keepBackground = Color(0xFFFAF089); // 保留背景（浅橙）

  // 扩展灰色系
  static const Color grey100 = Color(0xFFF7FAFC);
  static const Color grey200 = Color(0xFFEDF2F7);
  static const Color grey300 = Color(0xFFE2E8F0);
  static const Color grey400 = Color(0xFFCBD5E0);
  static const Color grey500 = Color(0xFFA0AEC0);
  static const Color grey600 = Color(0xFF718096);
  static const Color grey700 = Color(0xFF4A5568);
  static const Color grey800 = Color(0xFF2D3748);
  static const Color grey900 = Color(0xFF1A202C);

  // 扩展调色板（用于图表等）
  static const Color blue = Color(0xFF3182CE); // 蓝色
  static const Color blueLight = Color(0xFFEBF8FF); // 浅蓝色背景
  static const Color cyan = Color(0xFF0D9488); // 青色
  static const Color purple = Color(0xFF805AD5); // 紫色
  static const Color pink = Color(0xFFD53F8C); // 粉色
  static const Color indigo = Color(0xFF5A67D8); // 靛蓝
  static const Color amber = Color(0xFFD69E2E); // 琥珀色
  static const Color teal = Color(0xFF319795); // 蓝绿色
  static const Color orange = Color(0xFFDD6B20); // 橙色
  static const Color brown = Color(0xFF975A16); // 棕色

  // 图表色板（扩展版）
  static const List<Color> chartColors = [
    Color(0xFF3182CE), // 蓝
    Color(0xFF38B2AC), // 青
    Color(0xFF805AD5), // 紫
    Color(0xFFDD6B20), // 橙
    Color(0xFF319795), // 青绿
    Color(0xFFD53F8C), // 粉
    Color(0xFF48BB78), // 绿
    Color(0xFFED8936), // 橙黄
    Color(0xFF0D9488), // 青色
    Color(0xFF5A67D8), // 靛蓝
  ];

  /// 创建完整的 ColorScheme
  static ColorScheme lightColorScheme() {
    return const ColorScheme.light(
      primary: primaryLight,
      onPrimary: surfaceLight,
      primaryContainer: Color(0xFFB8C5D6),
      onPrimaryContainer: primaryLight,
      secondary: secondaryLight,
      onSecondary: surfaceLight,
      secondaryContainer: Color(0xFFD1D9E0),
      onSecondaryContainer: secondaryLight,
      tertiary: accentLight,
      onTertiary: surfaceLight,
      tertiaryContainer: Color(0xFFDBEAFE),
      onTertiaryContainer: accentLight,
      error: error,
      onError: surfaceLight,
      surface: surfaceLight,
      onSurface: textPrimaryLight,
      surfaceContainerHighest: Color(0xFFF7FAFC),
      onSurfaceVariant: textSecondaryLight,
      outline: borderLight,
      outlineVariant: Color(0xFFCBD5E0),
      shadow: Color(0x1A000000),
      scrim: Color(0x80000000),
      inverseSurface: surfaceDark,
      onInverseSurface: surfaceLight,
      inversePrimary: primaryDark,
    );
  }

  /// 创建完整的 ColorScheme (Dark)
  static ColorScheme darkColorScheme() {
    return const ColorScheme.dark(
      primary: primaryDark,
      onPrimary: surfaceDark,
      primaryContainer: primaryLight,
      onPrimaryContainer: primaryDark,
      secondary: secondaryDark,
      onSecondary: surfaceDark,
      secondaryContainer: secondaryLight,
      onSecondaryContainer: secondaryDark,
      tertiary: accentDark,
      onTertiary: surfaceDark,
      tertiaryContainer: accentLight,
      onTertiaryContainer: accentDark,
      error: error,
      onError: surfaceDark,
      surface: surfaceDark,
      onSurface: textPrimaryDark,
      surfaceContainerHighest: Color(0xFF111111), // 输入框背景色
      onSurfaceVariant: textSecondaryDark,
      outline: borderDark,
      outlineVariant: Color(0xFF1E293B),
      shadow: Color(0x1A000000),
      scrim: Color(0x80000000),
      inverseSurface: surfaceLight,
      onInverseSurface: surfaceDark,
      inversePrimary: primaryLight,
    );
  }
}
