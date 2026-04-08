import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/app_theme.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/providers/language_provider.dart';
import '../common/premium_card.dart';
import '../common/premium_input.dart';

class SettingsUnitsSection extends ConsumerWidget {
  const SettingsUnitsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);

    return PremiumCard(
      child: Column(
        children: [
          _buildSettingRow(
            context: context,
            icon: Icons.straighten,
            title: strings.unitsSettings,
            subtitle:
                '${strings.fishCountUnit}、${strings.equipment}、${strings.lure}',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/settings/units');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacingMd,
          horizontal: AppTheme.spacingSm,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class UnitSettingsPage extends ConsumerWidget {
  const UnitSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider);
    final strings = ref.watch(currentStringsProvider);
    final units = appSettings.units;

    return Scaffold(
      appBar: AppBar(title: Text(strings.unitsSettings)),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildUnitSection(
            context: context,
            title: strings.fishDetail,
            icon: Icons.set_meal,
            children: [
              _buildUnitTile(
                context: context,
                title: strings.length,
                value: units.fishLengthUnit,
                items: [
                  PremiumDropdownItem(value: 'cm', label: strings.centimeter),
                  PremiumDropdownItem(value: 'm', label: strings.meter),
                  PremiumDropdownItem(value: 'inch', label: strings.inch),
                  PremiumDropdownItem(value: 'ft', label: strings.foot),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .updateUnits(units.copyWith(fishLengthUnit: value));
                  }
                },
              ),
              _buildUnitTile(
                context: context,
                title: strings.weight,
                value: units.fishWeightUnit,
                items: [
                  PremiumDropdownItem(value: 'kg', label: strings.kilogram),
                  PremiumDropdownItem(value: 'g', label: strings.gram),
                  PremiumDropdownItem(value: 'lb', label: strings.pound),
                  PremiumDropdownItem(value: 'oz', label: strings.ounce),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .updateUnits(units.copyWith(fishWeightUnit: value));
                  }
                },
              ),
            ],
          ),
          _buildUnitSection(
            context: context,
            title: strings.equipment,
            icon: Icons.hardware,
            children: [
              _buildUnitTile(
                context: context,
                title: strings.rodLength,
                value: units.rodLengthUnit,
                items: [
                  PremiumDropdownItem(value: 'm', label: strings.meter),
                  PremiumDropdownItem(value: 'cm', label: strings.centimeter),
                  PremiumDropdownItem(value: 'ft', label: strings.foot),
                  PremiumDropdownItem(value: 'inch', label: strings.inch),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .updateUnits(units.copyWith(rodLengthUnit: value));
                  }
                },
              ),
              _buildUnitTile(
                context: context,
                title: strings.lineLength,
                value: units.lineLengthUnit,
                items: [
                  PremiumDropdownItem(value: 'm', label: strings.meter),
                  PremiumDropdownItem(value: 'cm', label: strings.centimeter),
                  PremiumDropdownItem(value: 'ft', label: strings.foot),
                  PremiumDropdownItem(value: 'inch', label: strings.inch),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .updateUnits(units.copyWith(lineLengthUnit: value));
                  }
                },
              ),
            ],
          ),
          _buildUnitSection(
            context: context,
            title: strings.lure,
            icon: Icons.pest_control,
            children: [
              _buildUnitTile(
                context: context,
                title: strings.weight,
                value: units.lureWeightUnit,
                items: [
                  PremiumDropdownItem(value: 'g', label: strings.gram),
                  PremiumDropdownItem(value: 'oz', label: strings.ounce),
                  PremiumDropdownItem(value: 'kg', label: strings.kilogram),
                  PremiumDropdownItem(value: 'lb', label: strings.pound),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .updateUnits(units.copyWith(lureWeightUnit: value));
                  }
                },
              ),
              _buildUnitTile(
                context: context,
                title: strings.size,
                value: units.lureLengthUnit,
                items: [
                  PremiumDropdownItem(value: 'cm', label: strings.centimeter),
                  PremiumDropdownItem(value: 'mm', label: strings.millimeter),
                  PremiumDropdownItem(value: 'inch', label: strings.inch),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .updateUnits(units.copyWith(lureLengthUnit: value));
                  }
                },
              ),
              _buildUnitTile(
                context: context,
                title: strings.quantity,
                value: units.lureQuantityUnit,
                items: const [
                  PremiumDropdownItem(value: '条', label: '条'),
                  PremiumDropdownItem(value: '只', label: '只'),
                  PremiumDropdownItem(value: '个', label: '个'),
                  PremiumDropdownItem(value: '包', label: '包'),
                  PremiumDropdownItem(value: '盒', label: '盒'),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .updateUnits(units.copyWith(lureQuantityUnit: value));
                  }
                },
              ),
            ],
          ),
          _buildUnitSection(
            context: context,
            title: strings.location,
            icon: Icons.location_on,
            children: [
              _buildUnitTile(
                context: context,
                title: strings.distanceUnit,
                value: units.distanceUnit,
                items: [
                  PremiumDropdownItem(value: 'm', label: strings.meter),
                  PremiumDropdownItem(value: 'km', label: strings.kilometer),
                  PremiumDropdownItem(value: 'ft', label: strings.foot),
                  PremiumDropdownItem(value: 'mile', label: strings.mile),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .updateUnits(units.copyWith(distanceUnit: value));
                  }
                },
              ),
              _buildUnitTile(
                context: context,
                title: 'Temperature',
                value: units.temperatureUnit,
                items: [
                  PremiumDropdownItem(value: 'C', label: strings.celsius),
                  PremiumDropdownItem(value: 'F', label: strings.fahrenheit),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .updateUnits(units.copyWith(temperatureUnit: value));
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildUnitSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return PremiumCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildUnitTile({
    required BuildContext context,
    required String title,
    required String value,
    required List<PremiumDropdownItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ),
          SizedBox(
            width: 140,
            child: PremiumDropdown<String>(
              value: value,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
