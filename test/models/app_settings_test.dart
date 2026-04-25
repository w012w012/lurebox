import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/app_settings.dart';

void main() {
  group('UnitSettings', () {
    group('fromJson', () {
      test('with all fields parses correctly', () {
        final json = {
          'fishLengthUnit': 'inch',
          'fishWeightUnit': 'lb',
          'rodLengthUnit': 'ft',
          'lineLengthUnit': 'inch',
          'lureWeightUnit': 'oz',
          'lureLengthUnit': 'mm',
          'lureQuantityUnit': 'item',
          'temperatureUnit': 'F',
        };

        final settings = UnitSettings.fromJson(json);

        expect(settings.fishLengthUnit, equals('inch'));
        expect(settings.fishWeightUnit, equals('lb'));
        expect(settings.rodLengthUnit, equals('ft'));
        expect(settings.lineLengthUnit, equals('inch'));
        expect(settings.lureWeightUnit, equals('oz'));
        expect(settings.lureLengthUnit, equals('mm'));
        expect(settings.lureQuantityUnit, equals('item'));
        expect(settings.temperatureUnit, equals('F'));
      });

      test('with defaults uses correct fallback values', () {
        final json = <String, dynamic>{};

        final settings = UnitSettings.fromJson(json);

        expect(settings.fishLengthUnit, equals('cm'));
        expect(settings.fishWeightUnit, equals('kg'));
        expect(settings.rodLengthUnit, equals('m'));
        expect(settings.lineLengthUnit, equals('m'));
        expect(settings.lureWeightUnit, equals('g'));
        expect(settings.lureLengthUnit, equals('cm'));
        expect(settings.lureQuantityUnit, equals('piece'));
        expect(settings.temperatureUnit, equals('C'));
      });

      test('with null values uses defaults', () {
        final json = {
          'fishLengthUnit': null,
          'fishWeightUnit': null,
          'rodLengthUnit': null,
          'lineLengthUnit': null,
          'lureWeightUnit': null,
          'lureLengthUnit': null,
          'lureQuantityUnit': null,
          'temperatureUnit': null,
        };

        final settings = UnitSettings.fromJson(json);

        expect(settings.fishLengthUnit, equals('cm'));
        expect(settings.fishWeightUnit, equals('kg'));
        expect(settings.temperatureUnit, equals('C'));
      });

      test('with partial fields uses defaults for missing', () {
        final json = {
          'fishLengthUnit': 'ft',
          'fishWeightUnit': 'oz',
        };

        final settings = UnitSettings.fromJson(json);

        expect(settings.fishLengthUnit, equals('ft'));
        expect(settings.fishWeightUnit, equals('oz'));
        expect(settings.rodLengthUnit, equals('m'));
        expect(settings.lineLengthUnit, equals('m'));
        expect(settings.lureWeightUnit, equals('g'));
      });
    });

    group('toJson round-trip', () {
      test('serializes and deserializes correctly', () {
        const original = UnitSettings(
          fishLengthUnit: 'm',
          fishWeightUnit: 'g',
          rodLengthUnit: 'cm',
          lineLengthUnit: 'ft',
          lureWeightUnit: 'oz',
          lureLengthUnit: 'inch',
          lureQuantityUnit: 'box',
          temperatureUnit: 'F',
        );

        final json = original.toJson();
        final decoded = UnitSettings.fromJson(json);

        expect(decoded.fishLengthUnit, equals(original.fishLengthUnit));
        expect(decoded.fishWeightUnit, equals(original.fishWeightUnit));
        expect(decoded.rodLengthUnit, equals(original.rodLengthUnit));
        expect(decoded.lineLengthUnit, equals(original.lineLengthUnit));
        expect(decoded.lureWeightUnit, equals(original.lureWeightUnit));
        expect(decoded.lureLengthUnit, equals(original.lureLengthUnit));
        expect(decoded.lureQuantityUnit, equals(original.lureQuantityUnit));
        expect(decoded.temperatureUnit, equals(original.temperatureUnit));
      });

      test('default values round-trip correctly', () {
        const original = UnitSettings();

        final json = original.toJson();
        final decoded = UnitSettings.fromJson(json);

        expect(decoded.fishLengthUnit, equals(original.fishLengthUnit));
        expect(decoded.fishWeightUnit, equals(original.fishWeightUnit));
        expect(decoded.lureQuantityUnit, equals(original.lureQuantityUnit));
      });
    });

    group('encode / decode', () {
      test('encode produces valid JSON string', () {
        const settings = UnitSettings(
          fishLengthUnit: 'ft',
          fishWeightUnit: 'lb',
        );

        final encoded = settings.encode();

        expect(encoded, isA<String>());
        expect(() => jsonDecode(encoded), returnsNormally);
      });

      test('decode restores settings from encoded string', () {
        const original = UnitSettings(
          fishLengthUnit: 'inch',
          fishWeightUnit: 'oz',
          lureQuantityUnit: 'pack',
          temperatureUnit: 'C',
        );

        final encoded = original.encode();
        final decoded = UnitSettings.decode(encoded);

        expect(decoded.fishLengthUnit, equals(original.fishLengthUnit));
        expect(decoded.fishWeightUnit, equals(original.fishWeightUnit));
        expect(decoded.lureQuantityUnit, equals(original.lureQuantityUnit));
        expect(decoded.temperatureUnit, equals(original.temperatureUnit));
      });

      test('decode empty JSON uses defaults', () {
        final decoded = UnitSettings.decode('{}');

        expect(decoded.fishLengthUnit, equals('cm'));
        expect(decoded.fishWeightUnit, equals('kg'));
        expect(decoded.lureQuantityUnit, equals('piece'));
      });
    });

    group('copyWith', () {
      test('preserves unmodified fields', () {
        const original = UnitSettings();

        final modified = original.copyWith(temperatureUnit: 'F');

        expect(modified.fishLengthUnit, equals(original.fishLengthUnit));
        expect(modified.fishWeightUnit, equals(original.fishWeightUnit));
        expect(modified.rodLengthUnit, equals(original.rodLengthUnit));
        expect(modified.temperatureUnit, equals('F'));
      });

      test('original remains unchanged', () {
        const original = UnitSettings(
          fishLengthUnit: 'm',
          temperatureUnit: 'C',
        );

        original.copyWith(fishLengthUnit: 'ft');

        expect(original.fishLengthUnit, equals('m'));
        expect(original.temperatureUnit, equals('C'));
      });
    });
  });

  group('AppSettings', () {
    group('fromJson with DarkMode enum', () {
      test('parses dark mode system correctly', () {
        final json = {
          'darkMode': 'system',
          'language': 'chinese',
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.darkMode, equals(DarkMode.system));
      });

      test('parses dark mode light correctly', () {
        final json = {
          'darkMode': 'light',
          'language': 'english',
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.darkMode, equals(DarkMode.light));
      });

      test('parses dark mode dark correctly', () {
        final json = {
          'darkMode': 'dark',
          'language': 'chinese',
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.darkMode, equals(DarkMode.dark));
      });

      test('unknown darkMode falls back to system', () {
        final json = {
          'darkMode': 'unknown_mode',
          'language': 'chinese',
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.darkMode, equals(DarkMode.system));
      });

      test('null darkMode falls back to system', () {
        final json = {
          'darkMode': null,
          'language': 'english',
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.darkMode, equals(DarkMode.system));
      });
    });

    group('fromJson with AppLanguage enum', () {
      test('parses chinese correctly', () {
        final json = {
          'darkMode': 'dark',
          'language': 'chinese',
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.language, equals(AppLanguage.chinese));
      });

      test('parses english correctly', () {
        final json = {
          'darkMode': 'light',
          'language': 'english',
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.language, equals(AppLanguage.english));
      });

      test('unknown language falls back to chinese', () {
        final json = {
          'darkMode': 'system',
          'language': 'unknown_lang',
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.language, equals(AppLanguage.chinese));
      });

      test('null language falls back to chinese', () {
        final json = {
          'darkMode': 'dark',
          'language': null,
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.language, equals(AppLanguage.chinese));
      });
    });

    group('toJson round-trip', () {
      test('serializes and deserializes correctly', () {
        final original = AppSettings(
          units: const UnitSettings(
            fishLengthUnit: 'ft',
            fishWeightUnit: 'lb',
          ),
          darkMode: DarkMode.dark,
          language: AppLanguage.english,
          hasCompletedOnboarding: true,
        );

        final json = original.toJson();
        final decoded = AppSettings.fromJson(json);

        expect(decoded.units.fishLengthUnit, equals('ft'));
        expect(decoded.units.fishWeightUnit, equals('lb'));
        expect(decoded.darkMode, equals(DarkMode.dark));
        expect(decoded.language, equals(AppLanguage.english));
        expect(decoded.hasCompletedOnboarding, isTrue);
      });

      test('default values round-trip correctly', () {
        const original = AppSettings();

        final json = original.toJson();
        final decoded = AppSettings.fromJson(json);

        expect(decoded.units.fishLengthUnit, equals(original.units.fishLengthUnit));
        expect(decoded.darkMode, equals(original.darkMode));
        expect(decoded.language, equals(original.language));
        expect(decoded.hasCompletedOnboarding, equals(original.hasCompletedOnboarding));
      });

      test('toJson serializes enums as names', () {
        final settings = AppSettings(
          darkMode: DarkMode.dark,
          language: AppLanguage.english,
        );

        final json = settings.toJson();

        expect(json['darkMode'], equals('dark'));
        expect(json['language'], equals('english'));
      });
    });

    group('encode / decode', () {
      test('encode produces valid JSON string', () {
        final settings = AppSettings(
          darkMode: DarkMode.light,
          language: AppLanguage.english,
        );

        final encoded = settings.encode();

        expect(encoded, isA<String>());
        expect(() => jsonDecode(encoded), returnsNormally);
      });

      test('decode restores settings from encoded string', () {
        final original = AppSettings(
          units: const UnitSettings(
            fishLengthUnit: 'm',
            fishWeightUnit: 'kg',
            temperatureUnit: 'F',
          ),
          darkMode: DarkMode.light,
          language: AppLanguage.english,
          hasCompletedOnboarding: true,
        );

        final encoded = original.encode();
        final decoded = AppSettings.decode(encoded);

        expect(decoded.units.fishLengthUnit, equals('m'));
        expect(decoded.units.temperatureUnit, equals('F'));
        expect(decoded.darkMode, equals(DarkMode.light));
        expect(decoded.language, equals(AppLanguage.english));
        expect(decoded.hasCompletedOnboarding, isTrue);
      });

      test('decode empty JSON uses defaults', () {
        final decoded = AppSettings.decode('{}');

        expect(decoded.units.fishLengthUnit, equals('cm'));
        expect(decoded.darkMode, equals(DarkMode.system));
        expect(decoded.language, equals(AppLanguage.chinese));
        expect(decoded.hasCompletedOnboarding, isFalse);
      });
    });

    group('nested UnitSettings deserialization', () {
      test('deserializes nested UnitSettings correctly', () {
        final json = {
          'units': {
            'fishLengthUnit': 'inch',
            'fishWeightUnit': 'oz',
            'rodLengthUnit': 'ft',
            'lineLengthUnit': 'm',
            'lureWeightUnit': 'g',
            'lureLengthUnit': 'cm',
            'lureQuantityUnit': 'item',
            'temperatureUnit': 'F',
          },
          'darkMode': 'dark',
          'language': 'chinese',
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.units.fishLengthUnit, equals('inch'));
        expect(settings.units.fishWeightUnit, equals('oz'));
        expect(settings.units.rodLengthUnit, equals('ft'));
        expect(settings.units.temperatureUnit, equals('F'));
      });

      test('null units uses default UnitSettings', () {
        final json = {
          'units': null,
          'darkMode': 'light',
          'language': 'english',
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.units.fishLengthUnit, equals('cm'));
        expect(settings.units.fishWeightUnit, equals('kg'));
      });

      test('missing units key uses default UnitSettings', () {
        final json = {
          'darkMode': 'dark',
          'language': 'chinese',
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.units, const UnitSettings());
      });
    });

    group('copyWith', () {
      test('preserves unmodified fields', () {
        const original = AppSettings(
          darkMode: DarkMode.dark,
          language: AppLanguage.english,
        );

        final modified = original.copyWith(hasCompletedOnboarding: true);

        expect(modified.darkMode, equals(original.darkMode));
        expect(modified.language, equals(original.language));
        expect(modified.hasCompletedOnboarding, isTrue);
      });

      test('original remains unchanged', () {
        final original = AppSettings(
          darkMode: DarkMode.light,
          language: AppLanguage.chinese,
        );

        original.copyWith(darkMode: DarkMode.dark);

        expect(original.darkMode, equals(DarkMode.light));
        expect(original.language, equals(AppLanguage.chinese));
      });
    });
  });
}
