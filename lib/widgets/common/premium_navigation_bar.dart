import 'package:flutter/material.dart';
import '../../core/design/theme/app_colors.dart';

/// Premium 极简导航栏
class PremiumNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<PremiumNavigationDestination> destinations;

  const PremiumNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: isDark ? TeslaColors.carbonDark : TeslaColors.white,
      indicatorColor:
          TeslaColors.electricBlue.withValues(alpha: 0.12),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      elevation: 0,
      height: 80,
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
