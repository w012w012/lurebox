import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/watermark_settings.dart';

void main() {
  group('WatermarkSettings', () {
    test('creates with default values', () {
      const settings = WatermarkSettings();

      expect(settings.enabled, isTrue);
      expect(settings.style, equals(WatermarkStyle.minimal));
      expect(settings.infoTypes, isNotEmpty);
      expect(settings.blurRadius, equals(10.0));
      expect(settings.backgroundOpacity, equals(0.5));
      expect(settings.backgroundColor, equals(0xFF000000));
      expect(settings.fontSize, equals(14.0));
      expect(settings.textColor, equals(0xFFFFFFFF));
      expect(settings.position, equals(WatermarkPosition.bottomLeft));
    });

    test('creates with custom values', () {
      const settings = WatermarkSettings(
        enabled: false,
        style: WatermarkStyle.minimal,
        infoTypes: [WatermarkInfoType.species, WatermarkInfoType.length],
        blurRadius: 20.0,
        backgroundOpacity: 0.8,
        backgroundColor: 0xFF123456,
        fontSize: 18.0,
        textColor: 0xFF000000,
        position: WatermarkPosition.topRight,
      );

      expect(settings.enabled, isFalse);
      expect(settings.position, equals(WatermarkPosition.topRight));
      expect(settings.infoTypes.length, equals(2));
    });

    test('copyWith updates only specified values', () {
      const original = WatermarkSettings();
      final updated = original.copyWith(
        enabled: false,
        fontSize: 20.0,
      );

      expect(updated.enabled, isFalse);
      expect(updated.fontSize, equals(20.0));
      // Unchanged values preserved
      expect(updated.blurRadius, equals(original.blurRadius));
      expect(updated.position, equals(original.position));
    });

    group('serialization', () {
      test('toJson creates correct map', () {
        const settings = WatermarkSettings(
          enabled: true,
          style: WatermarkStyle.minimal,
          infoTypes: [WatermarkInfoType.species, WatermarkInfoType.length],
          blurRadius: 15.0,
          backgroundOpacity: 0.7,
          backgroundColor: 0xFF999999,
          fontSize: 16.0,
          textColor: 0xFF111111,
          position: WatermarkPosition.center,
        );

        final json = settings.toJson();

        expect(json['enabled'], isTrue);
        expect(json['style'], equals('minimal'));
        expect(json['infoTypes'], equals(['species', 'length']));
        expect(json['blurRadius'], equals(15.0));
        expect(json['backgroundOpacity'], equals(0.7));
        expect(json['backgroundColor'], equals(0xFF999999));
        expect(json['fontSize'], equals(16.0));
        expect(json['textColor'], equals(0xFF111111));
        expect(json['position'], equals('center'));
      });

      test('fromJson creates correct instance', () {
        final json = {
          'enabled': false,
          'style': 'minimal',
          'infoTypes': ['species', 'location', 'time'],
          'blurRadius': 25.0,
          'backgroundOpacity': 0.9,
          'backgroundColor': 0xFFABCDEF,
          'fontSize': 20.0,
          'textColor': 0xFF000000,
          'position': 'topLeft',
        };

        final settings = WatermarkSettings.fromJson(json);

        expect(settings.enabled, isFalse);
        expect(settings.style, equals(WatermarkStyle.minimal));
        expect(settings.infoTypes, contains(WatermarkInfoType.species));
        expect(settings.infoTypes, contains(WatermarkInfoType.location));
        expect(settings.infoTypes, contains(WatermarkInfoType.time));
        expect(settings.blurRadius, equals(25.0));
        expect(settings.backgroundOpacity, equals(0.9));
        expect(settings.backgroundColor, equals(0xFFABCDEF));
        expect(settings.fontSize, equals(20.0));
        expect(settings.textColor, equals(0xFF000000));
        expect(settings.position, equals(WatermarkPosition.topLeft));
      });

      test('fromJson uses defaults for missing values', () {
        final json = <String, dynamic>{};

        final settings = WatermarkSettings.fromJson(json);

        expect(settings.enabled, isTrue);
        expect(settings.style, equals(WatermarkStyle.minimal));
        expect(settings.blurRadius, equals(10.0));
        expect(settings.backgroundOpacity, equals(0.5));
        expect(settings.backgroundColor, equals(0xFF000000));
        expect(settings.fontSize, equals(14.0));
        expect(settings.textColor, equals(0xFFFFFFFF));
        expect(settings.position, equals(WatermarkPosition.bottomLeft));
      });

      test('fromJson handles unknown style', () {
        final json = {'style': 'unknown_style'};

        final settings = WatermarkSettings.fromJson(json);

        expect(settings.style, equals(WatermarkStyle.minimal)); // default
      });

      test('fromJson handles unknown position', () {
        final json = {'position': 'unknown_position'};

        final settings = WatermarkSettings.fromJson(json);

        expect(
            settings.position, equals(WatermarkPosition.bottomLeft)); // default
      });

      test('fromJson handles unknown infoType', () {
        final json = {
          'infoTypes': ['species', 'unknown_type', 'length']
        };

        final settings = WatermarkSettings.fromJson(json);

        expect(settings.infoTypes, contains(WatermarkInfoType.species));
        expect(settings.infoTypes, contains(WatermarkInfoType.length));
        expect(settings.infoTypes.length, equals(2)); // unknown filtered out
      });

      test('round-trip serialization preserves data', () {
        const original = WatermarkSettings(
          enabled: false,
          style: WatermarkStyle.minimal,
          infoTypes: [WatermarkInfoType.weather, WatermarkInfoType.pressure],
          blurRadius: 30.0,
          backgroundOpacity: 0.6,
          backgroundColor: 0xFFFEDCBA,
          fontSize: 22.0,
          textColor: 0xFF123456,
          position: WatermarkPosition.bottomRight,
        );

        final json = original.toJson();
        final restored = WatermarkSettings.fromJson(json);

        expect(restored.enabled, equals(original.enabled));
        expect(restored.style, equals(original.style));
        expect(restored.infoTypes, equals(original.infoTypes));
        expect(restored.blurRadius, equals(original.blurRadius));
        expect(restored.backgroundOpacity, equals(original.backgroundOpacity));
        expect(restored.backgroundColor, equals(original.backgroundColor));
        expect(restored.fontSize, equals(original.fontSize));
        expect(restored.textColor, equals(original.textColor));
        expect(restored.position, equals(original.position));
      });
    });

    group('encode/decode', () {
      test('encode returns JSON string', () {
        const settings = WatermarkSettings();
        final encoded = settings.encode();

        expect(encoded, isA<String>());
        expect(encoded.contains('enabled'), isTrue);
      });

      test('decode creates settings from JSON string', () {
        const original = WatermarkSettings(
          enabled: false,
          fontSize: 25.0,
          position: WatermarkPosition.center,
        );

        final encoded = original.encode();
        final decoded = WatermarkSettings.decode(encoded);

        expect(decoded.enabled, equals(original.enabled));
        expect(decoded.fontSize, equals(original.fontSize));
        expect(decoded.position, equals(original.position));
      });

      test('decode handles invalid JSON', () {
        expect(
          () => WatermarkSettings.decode('invalid json'),
          throwsFormatException,
        );
      });
    });
  });

  group('WatermarkInfoType', () {
    test('all values are unique', () {
      final values = WatermarkInfoType.values.map((e) => e.name).toSet();
      expect(values.length, equals(WatermarkInfoType.values.length));
    });
  });

  group('WatermarkStyle', () {
    test('only has minimal value', () {
      expect(WatermarkStyle.values, hasLength(1));
      expect(WatermarkStyle.values.first, equals(WatermarkStyle.minimal));
    });
  });

  group('WatermarkPosition', () {
    test('has all expected positions', () {
      expect(WatermarkPosition.values, contains(WatermarkPosition.topLeft));
      expect(WatermarkPosition.values, contains(WatermarkPosition.topRight));
      expect(WatermarkPosition.values, contains(WatermarkPosition.bottomLeft));
      expect(WatermarkPosition.values, contains(WatermarkPosition.bottomRight));
      expect(WatermarkPosition.values, contains(WatermarkPosition.center));
    });
  });

  group('WatermarkInfoTypeInfo', () {
    test('allTypes has correct number of entries', () {
      expect(
        WatermarkInfoTypeInfo.allTypes.length,
        equals(WatermarkInfoType.values.length),
      );
    });

    test('allTypes contains info for all WatermarkInfoType values', () {
      for (final type in WatermarkInfoType.values) {
        final info = WatermarkInfoTypeInfo.allTypes.firstWhere(
          (i) => i.type == type,
        );
        expect(info.name, isNotEmpty);
        expect(info.icon, isNotEmpty);
      }
    });

    test('all info entries have valid type', () {
      for (final info in WatermarkInfoTypeInfo.allTypes) {
        expect(WatermarkInfoType.values, contains(info.type));
      }
    });
  });
}
