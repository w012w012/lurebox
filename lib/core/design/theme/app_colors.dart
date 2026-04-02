import 'package:flutter/material.dart';

/// Premium Minimalist 调色板
class AppColors {
  // 主色系 - 中性高级灰
  static const Color primaryLight = Color(0xFF2D3748); // 炭灰
  static const Color primaryDark = Color(0xFFE2E8F0); // 浅灰

  // 次要色系
  static const Color secondaryLight = Color(0xFF718096); // 中灰
  static const Color secondaryDark = Color(0xFFA0AEC0); // 浅中灰

  // 强调色 - 青绿色（钓鱼/户外主题）
  static const Color accentLight = Color(0xFF319795); // 青绿
  static const Color accentDark = Color(0xFF81E6D9); // 浅青绿

  // 表面色
  static const Color surfaceLight = Color(0xFFFFFFFF); // 白色
  static const Color surfaceDark = Color(0xFF1A202C); // 深炭灰

  // 背景色
  static const Color backgroundLight = Color(0xFFF7FAFC); // 极浅灰
  static const Color backgroundDark = Color(0xFF171923); // 更深炭灰

  // 边框色
  static const Color borderLight = Color(0xFFE2E8F0); // 浅灰边框
  static const Color borderDark = Color(0xFF4A5568); // 深灰边框

  // 文字色
  static const Color textPrimaryLight = Color(0xFF2D3748); // 主要文字（浅色模式）
  static const Color textSecondaryLight = Color(0xFF718096); // 次要文字（浅色模式）
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
      primaryContainer: Color(0xFFE2E8F0),
      onPrimaryContainer: primaryLight,
      secondary: secondaryLight,
      onSecondary: surfaceLight,
      secondaryContainer: Color(0xFFE2E8F0),
      onSecondaryContainer: secondaryLight,
      tertiary: accentLight,
      onTertiary: surfaceLight,
      tertiaryContainer: Color(0xFFE6FFFA),
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
      primaryContainer: Color(0xFF2D3748),
      onPrimaryContainer: primaryDark,
      secondary: secondaryDark,
      onSecondary: surfaceDark,
      secondaryContainer: Color(0xFF2D3748),
      onSecondaryContainer: secondaryDark,
      tertiary: accentDark,
      onTertiary: surfaceDark,
      tertiaryContainer: Color(0xFF234E52),
      onTertiaryContainer: accentDark,
      error: error,
      onError: surfaceDark,
      surface: surfaceDark,
      onSurface: textPrimaryDark,
      surfaceContainerHighest: Color(0xFF2D3748),
      onSurfaceVariant: textSecondaryDark,
      outline: borderDark,
      outlineVariant: Color(0xFF4A5568),
      shadow: Color(0x1A000000),
      scrim: Color(0x80000000),
      inverseSurface: surfaceLight,
      onInverseSurface: surfaceDark,
      inversePrimary: primaryLight,
    );
  }
}
