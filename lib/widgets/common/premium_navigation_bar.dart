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

  /// FAB 模式：单行视觉，Stack 高 104px（= FAB 圆半径 36 + 上浮 40 + Tab 高 28）
  /// - FAB（z=2）：完全在 Stack 内，top:-18 → y=-18 到 y=62，圆形中心在 y=18
  /// - 背景（z=1）：Positioned(bottom:0, height:64) → y=40 到 y=104
  /// - 圆形在 y=18，底部 y=54 露出在背景上方（y=40），上方 y=-18 溢出进 safe-area
  /// - FAB 整个 80x80 触控区在 Stack 内，无 hit-test 越界问题
  Widget _buildFabNavBar(BuildContext context, bool isDark) {
    final tabs = destinations;
    final bgColor = isDark ? TeslaColors.carbonDark : TeslaColors.white;

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
          height: 104,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 背景（z=1）：y=40 到 y=104，遮住 FAB 底部阴影区域
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 64,
                child: Container(color: bgColor),
              ),

              // FAB（z=2）：top:-18 → y=-18 到 y=62，圆形视觉上浮在背景上方
              // 触控区 y=-18 到 y=62 完全在 Stack 内（0 到 104），无越界
              Positioned(
                left: 0,
                right: 0,
                top: -18,
                child: Center(child: _buildCenterFab(context)),
              ),

              // Tab 行（z=0）：y=40 到 y=104，底部与背景对齐
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 64,
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
                    // FAB 中间区域留透明，触摸穿透给 FAB
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
