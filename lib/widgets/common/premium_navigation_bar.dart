import 'package:flutter/material.dart';
import '../../core/design/theme/app_colors.dart';

/// Premium 导航栏组件
///
/// 支持两种模式：
/// - 标准模式：5 个 Tab 均分宽度
/// - FAB 模式（showCenterFab=true）：中间 Tab 位置被 FAB 替代，4 个 Tab 分列两侧
class PremiumNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<PremiumNavigationDestination> destinations;

  /// 是否在中间显示居中 FAB（记录按钮）
  /// 为 true 时，中间位置被 FAB 替代，destinations 只有 4 项
  final bool showCenterFab;

  /// FAB 点击回调（showCenterFab=true 时使用）
  final VoidCallback? onCenterFabPressed;

  const PremiumNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.showCenterFab = false,
    this.onCenterFabPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!showCenterFab) {
      return _buildStandardNavBar(isDark);
    }

    return _buildFabNavBar(context, isDark);
  }

  /// 标准模式
  Widget _buildStandardNavBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? TeslaColors.carbonDark : TeslaColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            backgroundColor: Colors.transparent,
            indicatorColor: TeslaColors.electricBlue.withValues(alpha: 0.12),
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            elevation: 0,
            height: 64,
            surfaceTintColor: Colors.transparent,
            destinations: destinations.map((dest) {
              return NavigationDestination(
                icon: Icon(dest.icon, size: 24),
                selectedIcon: Icon(dest.selectedIcon, size: 24),
                label: dest.label,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// FAB 模式：单行 64px，FAB 视觉上浮在中间，tabs 填满左右
  Widget _buildFabNavBar(BuildContext context, bool isDark) {
    final tabs = destinations;
    final bgColor = isDark ? TeslaColors.carbonDark : TeslaColors.white;

    // FAB 的 72px 圆形视觉顶部对齐导航栏顶部，bottom=40px 表示圆心在 (64-40)/2+36=58，
    // 这使得圆形视觉上在导航栏上方 40px，与原始设计完全一致。
    // 但由于 Stack height=64，FAB 的 bottom=-40+80=40 < 64，所以底部会被截断。
    // 为避免截断，用 Container(height: 64) + FAB(top: -40) + 背景填满透明区域。
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 背景填满整行（包括 FAB 中间的透明区域，防止 FAB 底部半圆露出来）
              Positioned.fill(child: Container(color: bgColor)),

              // 4 个 Tab 均分，左右各两个，中间留空给 FAB
              // tabs 占 64px 高度（无背景，背景由上面的 Container 提供）
              Positioned.fill(
                child: Row(
                  children: [
                    _NavTab(
                      isSelected: selectedIndex == 0,
                      onTap: () => onDestinationSelected(0),
                      icon: tabs[0].icon,
                      selectedIcon: tabs[0].selectedIcon,
                      label: tabs[0].label,
                      isDark: isDark,
                    ),
                    _NavTab(
                      isSelected: selectedIndex == 1,
                      onTap: () => onDestinationSelected(1),
                      icon: tabs[1].icon,
                      selectedIcon: tabs[1].selectedIcon,
                      label: tabs[1].label,
                      isDark: isDark,
                    ),
                    // FAB 区域占位，让 tabs 不占 FAB 中间的空间
                    const Expanded(child: SizedBox()),
                    _NavTab(
                      isSelected: selectedIndex == 2,
                      onTap: () => onDestinationSelected(2),
                      icon: tabs[2].icon,
                      selectedIcon: tabs[2].selectedIcon,
                      label: tabs[2].label,
                      isDark: isDark,
                    ),
                    _NavTab(
                      isSelected: selectedIndex == 3,
                      onTap: () => onDestinationSelected(3),
                      icon: tabs[3].icon,
                      selectedIcon: tabs[3].selectedIcon,
                      label: tabs[3].label,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              // FAB：top:-40 与原始设计一致，圆形视觉上浮在导航栏上方
              // 由于整行背景是 bgColor（不透明），FAB 底部半圆会被背景遮挡，视觉干净
              Positioned(
                left: 0,
                right: 0,
                top: -40,
                child: Center(child: _buildCenterFab(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterFab(BuildContext context) {
    return GestureDetector(
      onTap: onCenterFabPressed,
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 80,
          height: 80,
          child: Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: TeslaColors.electricBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: TeslaColors.electricBlue.withValues(alpha: 0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: TeslaColors.electricBlue.withValues(alpha: 0.25),
                    blurRadius: 28,
                    spreadRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 单个导航 Tab
class _NavTab extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isDark;

  const _NavTab({
    required this.isSelected,
    required this.onTap,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF3E6AE1);
    final inactiveColor = isDark ? const Color(0xFF9A9A9A) : const Color(0xFF5C5E62);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 24,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected ? activeColor : inactiveColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// 导航目标项
class PremiumNavigationDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const PremiumNavigationDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
