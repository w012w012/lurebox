import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/utils/legacy_value_migrator.dart';

void main() {
  group('LegacyValueMigrator', () {
    group('migrateValue — sections', () {
      test('converts 1节 to 1', () {
        expect(LegacyValueMigrator.migrateValue('sections', '1节'), '1');
      });

      test('converts 多节 to multi', () {
        expect(LegacyValueMigrator.migrateValue('sections', '多节'), 'multi');
      });

      test('returns value unchanged when already English key', () {
        expect(LegacyValueMigrator.migrateValue('sections', '2'), '2');
      });

      test('returns value unchanged when unknown', () {
        expect(
          LegacyValueMigrator.migrateValue('sections', 'unknown'),
          'unknown',
        );
      });
    });

    group('migrateValue — joint_type', () {
      test('converts 正并继 to spigot', () {
        expect(
          LegacyValueMigrator.migrateValue('joint_type', '正并继'),
          'spigot',
        );
      });

      test('converts 逆并继 to reverse_spigot', () {
        expect(
          LegacyValueMigrator.migrateValue('joint_type', '逆并继'),
          'reverse_spigot',
        );
      });

      test('converts 印龙继 to dragon_spigot', () {
        expect(
          LegacyValueMigrator.migrateValue('joint_type', '印龙继'),
          'dragon_spigot',
        );
      });

      test('converts 伸缩 to telescopic', () {
        expect(
          LegacyValueMigrator.migrateValue('joint_type', '伸缩'),
          'telescopic',
        );
      });
    });

    group('migrateValue — rod_action', () {
      test('converts SS调（超慢调） to SS', () {
        expect(
          LegacyValueMigrator.migrateValue('rod_action', 'SS调（超慢调）'),
          'SS',
        );
      });

      test('converts F调（快调） to F', () {
        expect(
          LegacyValueMigrator.migrateValue('rod_action', 'F调（快调）'),
          'F',
        );
      });

      test('converts XF调（极快调） to XF', () {
        expect(
          LegacyValueMigrator.migrateValue('rod_action', 'XF调（极快调）'),
          'XF',
        );
      });

      test('converts all 8 rod actions', () {
        const expected = {
          'SS调（超慢调）': 'SS',
          'S调（慢调）': 'S',
          'MR调（中慢调）': 'MR',
          'R调（中调）': 'R',
          'RF调（中快调）': 'RF',
          'F调（快调）': 'F',
          'FF调（超快调）': 'FF',
          'XF调（极快调）': 'XF',
        };
        for (final entry in expected.entries) {
          expect(
            LegacyValueMigrator.migrateValue('rod_action', entry.key),
            entry.value,
            reason: '${entry.key} should map to ${entry.value}',
          );
        }
      });
    });

    group('migrateValue — reel_brake_type', () {
      test('converts all 5 brake types', () {
        const expected = {
          '传统磁力刹车': 'traditional_magnetic',
          '离心刹车': 'centrifugal',
          'DC刹车': 'dc',
          '浮动磁力刹车': 'floating_magnetic',
          '创新组合刹车': 'innovative',
        };
        for (final entry in expected.entries) {
          expect(
            LegacyValueMigrator.migrateValue(
              'reel_brake_type',
              entry.key,
            ),
            entry.value,
            reason: '${entry.key} should map to ${entry.value}',
          );
        }
      });
    });

    group('migrateValue — lure_quantity_unit', () {
      test('converts all 5 quantity units', () {
        const expected = {
          '条': 'piece',
          '只': 'item',
          '个': 'pack',
          '包': 'box',
          '盒': 'carton',
        };
        for (final entry in expected.entries) {
          expect(
            LegacyValueMigrator.migrateValue(
              'lure_quantity_unit',
              entry.key,
            ),
            entry.value,
            reason: '${entry.key} should map to ${entry.value}',
          );
        }
      });
    });

    group('migrateValue — unknown field', () {
      test('returns value unchanged for unknown field', () {
        expect(
          LegacyValueMigrator.migrateValue('unknown_field', 'some_value'),
          'some_value',
        );
      });

      test('returns empty string unchanged', () {
        expect(LegacyValueMigrator.migrateValue('sections', ''), '');
      });
    });

    group('migrateEquipmentMap', () {
      test('converts all legacy fields in a single map', () {
        final map = {
          'brand': 'Shimano',
          'sections': '3节',
          'joint_type': '正并继',
          'rod_action': 'F调（快调）',
          'reel_brake_type': 'DC刹车',
          'lure_quantity_unit': '盒',
        };

        final result = LegacyValueMigrator.migrateEquipmentMap(map);

        expect(result['brand'], 'Shimano');
        expect(result['sections'], '3');
        expect(result['joint_type'], 'spigot');
        expect(result['rod_action'], 'F');
        expect(result['reel_brake_type'], 'dc');
        expect(result['lure_quantity_unit'], 'carton');
      });

      test('does not modify non-migratable fields', () {
        final map = {
          'brand': 'Shimano',
          'model': 'Expride',
          'price': 99.99,
        };

        final result = LegacyValueMigrator.migrateEquipmentMap(map);

        expect(result['brand'], 'Shimano');
        expect(result['model'], 'Expride');
        expect(result['price'], 99.99);
      });

      test('skips non-string field values', () {
        final map = {
          'sections': 3,
          'joint_type': null,
          'rod_action': true,
        };

        final result = LegacyValueMigrator.migrateEquipmentMap(map);

        expect(result['sections'], 3);
        expect(result['joint_type'], isNull);
        expect(result['rod_action'], true);
      });

      test('passes through values already in English', () {
        final map = {
          'sections': 'multi',
          'joint_type': 'spigot',
        };

        final result = LegacyValueMigrator.migrateEquipmentMap(map);

        expect(result['sections'], 'multi');
        expect(result['joint_type'], 'spigot');
      });

      test('returns empty map unchanged', () {
        final result = LegacyValueMigrator.migrateEquipmentMap({});
        expect(result, isEmpty);
      });

      test('creates a new map (immutable output)', () {
        final original = {'sections': '1节'};
        final result = LegacyValueMigrator.migrateEquipmentMap(original);

        expect(original['sections'], '1节');
        expect(result['sections'], '1');
      });
    });
  });
}
