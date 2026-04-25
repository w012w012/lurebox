import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/tesla_theme.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../widgets/common/premium_card.dart';
import '../../../widgets/common/premium_input.dart';

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
    final accentColor = TeslaColors.electricBlue;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: TeslaTheme.spacingMd,
          horizontal: TeslaTheme.spacingSm,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(TeslaTheme.spacingSm),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: TeslaTheme.spacingMd),
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
          const SizedBox(height: TeslaTheme.spacingSm),
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
                items: [
                  PremiumDropdownItem(value: 'piece', label: strings.quantityUnitPiece),
                  PremiumDropdownItem(value: 'item', label: strings.quantityUnitItem),
                  PremiumDropdownItem(value: 'pack', label: strings.quantityUnitPack),
                  PremiumDropdownItem(value: 'box', label: strings.quantityUnitBox),
                  PremiumDropdownItem(value: 'carton', label: strings.quantityUnitCarton),
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
            title: strings.temperature,
            icon: Icons.thermostat,
            children: [
              _buildUnitTile(
                context: context,
                title: strings.temperature,
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
          const SizedBox(height: TeslaTheme.spacingLg),
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
      margin: const EdgeInsets.symmetric(
        horizontal: TeslaTheme.spacingMd,
        vertical: TeslaTheme.spacingMicro,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, TeslaTheme.spacingSm),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: TeslaTheme.spacingSm),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: TeslaColors.electricBlue,
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
      padding: const EdgeInsets.symmetric(vertical: TeslaTheme.spacingMicro),
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
