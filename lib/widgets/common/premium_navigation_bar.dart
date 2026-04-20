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
  /// 为 true 时，中间位置被 FAB 替代，destinations 只有 4 项（index 0,1,3,4）
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
          child: showCenterFab
              ? _buildWithCenterFab(context, isDark)
              : _buildStandard(context, isDark),
        ),
      ),
    );
  }

  /// 标准模式：5 个 Tab 均分
  Widget _buildStandard(BuildContext context, bool isDark) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: Colors.transparent,
      indicatorColor:
          TeslaColors.electricBlue.withValues(alpha: 0.12),
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
    );
  }

  /// FAB 模式：4 个 Tab 分列两侧，中间显示 FAB
  Widget _buildWithCenterFab(BuildContext context, bool isDark) {
    // showCenterFab=true 时，destinations 4 项：
    // index 0: home, index 1: fish, index 2: equipment, index 3: me
    // FAB 居中在 index 1 和 index 2 之间
    final tabs = destinations; // 4 items

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 4 个 Tab 均匀分布在可用空间
        Positioned.fill(
          child: Row(
            children: [
              // Tab 0: home
              _NavTab(
                isSelected: selectedIndex == 0,
                onTap: () => onDestinationSelected(0),
                icon: tabs[0].icon,
                selectedIcon: tabs[0].selectedIcon,
                label: tabs[0].label,
                isDark: isDark,
              ),
              // Tab 1: fish
              _NavTab(
                isSelected: selectedIndex == 1,
                onTap: () => onDestinationSelected(1),
                icon: tabs[1].icon,
                selectedIcon: tabs[1].selectedIcon,
                label: tabs[1].label,
                isDark: isDark,
              ),
              // 中心 FAB 占位（不响应 Tab 切换）
              const Expanded(child: SizedBox()),
              // Tab 2: equipment
              _NavTab(
                isSelected: selectedIndex == 2,
                onTap: () => onDestinationSelected(2),
                icon: tabs[2].icon,
                selectedIcon: tabs[2].selectedIcon,
                label: tabs[2].label,
                isDark: isDark,
              ),
              // Tab 3: me
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
        // 居中 FAB：向上突出 40px，更大更醒目
        Positioned(
          left: 0,
          right: 0,
          top: -40,
          child: Center(child: _buildCenterFab(context)),
        ),
      ],
    );
  }

  Widget _buildCenterFab(BuildContext context) {
    return GestureDetector(
      onTap: onCenterFabPressed,
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
    );
  }

}

/// 单个导航 Tab（用于 FAB 模式下的精确布局控制）
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
