import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/app_settings.dart';

void main() {
  group('UnitSettings', () {
    group('defaults', () {
      test('creates with correct default values', () {
        const settings = UnitSettings();

        expect(settings.fishLengthUnit, 'cm');
        expect(settings.fishWeightUnit, 'kg');
        expect(settings.rodLengthUnit, 'm');
        expect(settings.lineLengthUnit, 'm');
        expect(settings.lureWeightUnit, 'g');
        expect(settings.lureLengthUnit, 'cm');
        expect(settings.lureQuantityUnit, 'piece');
        expect(settings.temperatureUnit, 'C');
      });
    });

    group('toJson and fromJson round-trip', () {
      test('serializes and deserializes correctly', () {
        const original = UnitSettings(
          fishLengthUnit: 'inch',
          fishWeightUnit: 'lb',
          rodLengthUnit: 'ft',
          lineLengthUnit: 'ft',
          lureWeightUnit: 'oz',
          lureLengthUnit: 'mm',
          lureQuantityUnit: 'item',
          temperatureUnit: 'F',
        );

        final json = original.toJson();
        final decoded = UnitSettings.fromJson(json);

        expect(decoded.fishLengthUnit, original.fishLengthUnit);
        expect(decoded.fishWeightUnit, original.fishWeightUnit);
        expect(decoded.rodLengthUnit, original.rodLengthUnit);
        expect(decoded.lineLengthUnit, original.lineLengthUnit);
        expect(decoded.lureWeightUnit, original.lureWeightUnit);
        expect(decoded.lureLengthUnit, original.lureLengthUnit);
        expect(decoded.lureQuantityUnit, original.lureQuantityUnit);
        expect(decoded.temperatureUnit, original.temperatureUnit);
      });

      test('fromJson migrates legacy Chinese quantity unit values', () {
        final json = <String, dynamic>{
          'lureQuantityUnit': '条',
        };

        final settings = UnitSettings.fromJson(json);
        expect(settings.lureQuantityUnit, 'piece');
      });

      test('round-trip with all default values', () {
        const original = UnitSettings();

        final json = original.toJson();
        final decoded = UnitSettings.fromJson(json);

        expect(decoded.fishLengthUnit, original.fishLengthUnit);
        expect(decoded.fishWeightUnit, original.fishWeightUnit);
        expect(decoded.rodLengthUnit, original.rodLengthUnit);
        expect(decoded.lineLengthUnit, original.lineLengthUnit);
        expect(decoded.lureWeightUnit, original.lureWeightUnit);
        expect(decoded.lureLengthUnit, original.lureLengthUnit);
        expect(decoded.lureQuantityUnit, original.lureQuantityUnit);
        expect(decoded.temperatureUnit, original.temperatureUnit);
      });
    });

    group('fromJson with missing/null fields', () {
      test('null fields use defaults', () {
        final json = <String, dynamic>{
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

        expect(settings.fishLengthUnit, 'cm');
        expect(settings.fishWeightUnit, 'kg');
        expect(settings.rodLengthUnit, 'm');
        expect(settings.lineLengthUnit, 'm');
        expect(settings.lureWeightUnit, 'g');
        expect(settings.lureLengthUnit, 'cm');
        expect(settings.lureQuantityUnit, 'piece');
        expect(settings.temperatureUnit, 'C');
      });

      test('missing keys use defaults', () {
        final json = <String, dynamic>{};

        final settings = UnitSettings.fromJson(json);

        expect(settings.fishLengthUnit, 'cm');
        expect(settings.fishWeightUnit, 'kg');
        expect(settings.rodLengthUnit, 'm');
        expect(settings.lineLengthUnit, 'm');
        expect(settings.lureWeightUnit, 'g');
        expect(settings.lureLengthUnit, 'cm');
        expect(settings.lureQuantityUnit, 'piece');
        expect(settings.temperatureUnit, 'C');
      });

      test('partial keys only apply defaults for missing ones', () {
        final json = <String, dynamic>{
          'fishLengthUnit': 'inch',
          'fishWeightUnit': 'lb',
        };

        final settings = UnitSettings.fromJson(json);

        expect(settings.fishLengthUnit, 'inch');
        expect(settings.fishWeightUnit, 'lb');
        expect(settings.rodLengthUnit, 'm');
        expect(settings.lineLengthUnit, 'm');
        expect(settings.lureWeightUnit, 'g');
        expect(settings.lureLengthUnit, 'cm');
        expect(settings.lureQuantityUnit, 'piece');
        expect(settings.temperatureUnit, 'C');
      });
    });

    group('encode and decode', () {
      test('encode produces valid JSON string', () {
        const settings = UnitSettings(
          fishLengthUnit: 'ft',
          fishWeightUnit: 'oz',
        );

        final encoded = settings.encode();

        expect(encoded, isA<String>());
        expect(() => jsonDecode(encoded), returnsNormally);
      });

      test('decode restores settings from encoded string', () {
        const original = UnitSettings(
          fishLengthUnit: 'm',
          fishWeightUnit: 'kg',
          rodLengthUnit: 'cm',
          lineLengthUnit: 'inch',
          lureWeightUnit: 'g',
          lureLengthUnit: 'mm',
          lureQuantityUnit: 'item',
          temperatureUnit: 'F',
        );

        final encoded = original.encode();
        final decoded = UnitSettings.decode(encoded);

        expect(decoded.fishLengthUnit, original.fishLengthUnit);
        expect(decoded.fishWeightUnit, original.fishWeightUnit);
        expect(decoded.rodLengthUnit, original.rodLengthUnit);
        expect(decoded.lineLengthUnit, original.lineLengthUnit);
        expect(decoded.lureWeightUnit, original.lureWeightUnit);
        expect(decoded.lureLengthUnit, original.lureLengthUnit);
        expect(decoded.lureQuantityUnit, original.lureQuantityUnit);
        expect(decoded.temperatureUnit, original.temperatureUnit);
      });

      test('decode handles empty JSON object', () {
        final decoded = UnitSettings.decode('{}');

        expect(decoded.fishLengthUnit, 'cm');
        expect(decoded.fishWeightUnit, 'kg');
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        const original = UnitSettings();

        final modified = original.copyWith(
          fishLengthUnit: 'inch',
          fishWeightUnit: 'lb',
        );

        expect(modified.fishLengthUnit, 'inch');
        expect(modified.fishWeightUnit, 'lb');
        expect(modified.rodLengthUnit, 'm');
        expect(modified.lineLengthUnit, 'm');
        expect(modified.lureWeightUnit, 'g');
        expect(modified.lureLengthUnit, 'cm');
        expect(modified.lureQuantityUnit, 'piece');
        expect(modified.temperatureUnit, 'C');
      });

      test('original remains unchanged', () {
        const original = UnitSettings();

        original.copyWith(fishLengthUnit: 'ft');

        expect(original.fishLengthUnit, 'cm');
      });

      test('copyWith multiple fields', () {
        const original = UnitSettings();

        final modified = original.copyWith(
          fishLengthUnit: 'm',
          fishWeightUnit: 'g',
          temperatureUnit: 'F',
        );

        expect(modified.fishLengthUnit, 'm');
        expect(modified.fishWeightUnit, 'g');
        expect(modified.temperatureUnit, 'F');
        expect(modified.rodLengthUnit, 'm');
      });
    });
  });

  group('AppSettings', () {
    group('defaults', () {
      test('creates with correct default values', () {
        const settings = AppSettings();

        expect(settings.units, const UnitSettings());
        expect(settings.darkMode, DarkMode.system);
        expect(settings.language, AppLanguage.chinese);
      });
    });

    group('toJson and fromJson round-trip', () {
      test('serializes and deserializes correctly', () {
        final original = AppSettings(
          units: const UnitSettings(
            fishLengthUnit: 'inch',
            fishWeightUnit: 'lb',
            rodLengthUnit: 'ft',
            lineLengthUnit: 'ft',
            lureWeightUnit: 'oz',
            lureLengthUnit: 'mm',
            lureQuantityUnit: 'piece',
            temperatureUnit: 'F',
          ),
          darkMode: DarkMode.dark,
          language: AppLanguage.english,
        );

        final json = original.toJson();
        final decoded = AppSettings.fromJson(json);

        expect(decoded.units.fishLengthUnit, 'inch');
        expect(decoded.units.fishWeightUnit, 'lb');
        expect(decoded.units.rodLengthUnit, 'ft');
        expect(decoded.units.lineLengthUnit, 'ft');
        expect(decoded.units.lureWeightUnit, 'oz');
        expect(decoded.units.lureLengthUnit, 'mm');
        expect(decoded.units.lureQuantityUnit, 'piece');
        expect(decoded.units.temperatureUnit, 'F');
        expect(decoded.darkMode, DarkMode.dark);
        expect(decoded.language, AppLanguage.english);
      });

      test('round-trip with all default values', () {
        const original = AppSettings();

        final json = original.toJson();
        final decoded = AppSettings.fromJson(json);

        expect(decoded.units.fishLengthUnit, 'cm');
        expect(decoded.units.fishWeightUnit, 'kg');
        expect(decoded.darkMode, DarkMode.system);
        expect(decoded.language, AppLanguage.chinese);
      });

      test('toJson includes hasCompletedOnboarding', () {
        final withOnboarding = AppSettings(hasCompletedOnboarding: true);
        final withoutOnboarding = AppSettings(hasCompletedOnboarding: false);

        final jsonWith = withOnboarding.toJson();
        final jsonWithout = withoutOnboarding.toJson();

        expect(jsonWith['hasCompletedOnboarding'], isTrue);
        expect(jsonWithout['hasCompletedOnboarding'], isFalse);
      });

      test('fromJson restores hasCompletedOnboarding', () {
        final json = <String, dynamic>{
          'hasCompletedOnboarding': true,
        };

        final settings = AppSettings.fromJson(json);
        expect(settings.hasCompletedOnboarding, isTrue);
      });

      test('fromJson defaults hasCompletedOnboarding to false when null', () {
        final json = <String, dynamic>{
          'hasCompletedOnboarding': null,
        };

        final settings = AppSettings.fromJson(json);
        expect(settings.hasCompletedOnboarding, isFalse);
      });

      test('toJson serializes darkMode and language as enum names', () {
        final settings = AppSettings(
          darkMode: DarkMode.light,
          language: AppLanguage.english,
        );

        final json = settings.toJson();
        expect(json['darkMode'], equals('light'));
        expect(json['language'], equals('english'));
      });
    });

    group('fromJson with missing fields', () {
      test('null units uses default UnitSettings', () {
        final json = <String, dynamic>{
          'units': null,
          'darkMode': 'dark',
          'language': 'english',
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.units.fishLengthUnit, 'cm');
        expect(settings.units.fishWeightUnit, 'kg');
        expect(settings.darkMode, DarkMode.dark);
        expect(settings.language, AppLanguage.english);
      });

      test('missing units key uses default UnitSettings', () {
        final json = <String, dynamic>{
          'darkMode': 'light',
          'language': 'chinese',
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.units, const UnitSettings());
        expect(settings.darkMode, DarkMode.light);
        expect(settings.language, AppLanguage.chinese);
      });

      test('unknown darkMode uses default system', () {
        final json = <String, dynamic>{
          'darkMode': 'unknown_mode',
          'language': 'english',
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.darkMode, DarkMode.system);
        expect(settings.language, AppLanguage.english);
      });

      test('unknown language uses default chinese', () {
        final json = <String, dynamic>{
          'darkMode': 'dark',
          'language': 'unknown_lang',
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.darkMode, DarkMode.dark);
        expect(settings.language, AppLanguage.chinese);
      });

      test('empty JSON uses all defaults', () {
        final json = <String, dynamic>{};

        final settings = AppSettings.fromJson(json);

        expect(settings.units, const UnitSettings());
        expect(settings.darkMode, DarkMode.system);
        expect(settings.language, AppLanguage.chinese);
      });

      test('null darkMode and language use defaults', () {
        final json = <String, dynamic>{
          'darkMode': null,
          'language': null,
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.darkMode, DarkMode.system);
        expect(settings.language, AppLanguage.chinese);
      });
    });

    group('nested units deserialization', () {
      test('deserializes nested UnitSettings correctly', () {
        final json = <String, dynamic>{
          'units': {
            'fishLengthUnit': 'ft',
            'fishWeightUnit': 'oz',
            'rodLengthUnit': 'inch',
            'lineLengthUnit': 'm',
            'lureWeightUnit': 'oz',
            'lureLengthUnit': 'inch',
            'lureQuantityUnit': 'piece',
            'temperatureUnit': 'F',
          },
          'darkMode': 'light',
          'language': 'english',
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.units.fishLengthUnit, 'ft');
        expect(settings.units.fishWeightUnit, 'oz');
        expect(settings.units.rodLengthUnit, 'inch');
        expect(settings.units.lineLengthUnit, 'm');
        expect(settings.units.lureWeightUnit, 'oz');
        expect(settings.units.lureLengthUnit, 'inch');
        expect(settings.units.lureQuantityUnit, 'piece');
        expect(settings.units.temperatureUnit, 'F');
      });

      test('nested units with null fields use defaults', () {
        final json = <String, dynamic>{
          'units': {
            'fishLengthUnit': null,
          },
          'darkMode': 'dark',
          'language': 'chinese',
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.units.fishLengthUnit, 'cm');
        expect(settings.units.fishWeightUnit, 'kg');
      });
    });

    group('encode and decode', () {
      test('encode produces valid JSON string', () {
        final settings = AppSettings(
          darkMode: DarkMode.dark,
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
            rodLengthUnit: 'ft',
            lineLengthUnit: 'inch',
            lureWeightUnit: 'oz',
            lureLengthUnit: 'cm',
            lureQuantityUnit: 'item',
            temperatureUnit: 'C',
          ),
          darkMode: DarkMode.light,
          language: AppLanguage.english,
        );

        final encoded = original.encode();
        final decoded = AppSettings.decode(encoded);

        expect(decoded.units.fishLengthUnit, 'm');
        expect(decoded.units.fishWeightUnit, 'kg');
        expect(decoded.units.rodLengthUnit, 'ft');
        expect(decoded.units.lineLengthUnit, 'inch');
        expect(decoded.units.lureWeightUnit, 'oz');
        expect(decoded.units.lureLengthUnit, 'cm');
        expect(decoded.units.lureQuantityUnit, 'item');
        expect(decoded.units.temperatureUnit, 'C');
        expect(decoded.darkMode, DarkMode.light);
        expect(decoded.language, AppLanguage.english);
      });

      test('decode handles empty JSON object', () {
        final decoded = AppSettings.decode('{}');

        expect(decoded.units, const UnitSettings());
        expect(decoded.darkMode, DarkMode.system);
        expect(decoded.language, AppLanguage.chinese);
      });
    });

    group('copyWith', () {
      test('creates copy with updated units', () {
        const original = AppSettings();

        final modified = original.copyWith(
          units: const UnitSettings(fishLengthUnit: 'inch'),
        );

        expect(modified.units.fishLengthUnit, 'inch');
        expect(modified.units.fishWeightUnit, 'kg');
        expect(modified.darkMode, DarkMode.system);
        expect(modified.language, AppLanguage.chinese);
      });

      test('creates copy with updated darkMode', () {
        const original = AppSettings();

        final modified = original.copyWith(darkMode: DarkMode.dark);

        expect(modified.darkMode, DarkMode.dark);
        expect(modified.units, const UnitSettings());
        expect(modified.language, AppLanguage.chinese);
      });

      test('creates copy with updated language', () {
        const original = AppSettings();

        final modified = original.copyWith(language: AppLanguage.english);

        expect(modified.language, AppLanguage.english);
        expect(modified.units, const UnitSettings());
        expect(modified.darkMode, DarkMode.system);
      });

      test('original remains unchanged', () {
        const original = AppSettings(
          darkMode: DarkMode.dark,
          language: AppLanguage.english,
        );

        original.copyWith(darkMode: DarkMode.light);

        expect(original.darkMode, DarkMode.dark);
        expect(original.language, AppLanguage.english);
      });

      test('copyWith multiple fields', () {
        const original = AppSettings();

        final modified = original.copyWith(
          darkMode: DarkMode.dark,
          language: AppLanguage.english,
          units: const UnitSettings(temperatureUnit: 'F'),
        );

        expect(modified.darkMode, DarkMode.dark);
        expect(modified.language, AppLanguage.english);
        expect(modified.units.temperatureUnit, 'F');
      });

      test('copyWith updates hasCompletedOnboarding', () {
        const original = AppSettings(hasCompletedOnboarding: false);

        final modified = original.copyWith(hasCompletedOnboarding: true);

        expect(modified.hasCompletedOnboarding, isTrue);
        expect(original.hasCompletedOnboarding, isFalse);
      });
    });

    group('equality', () {
      test('equal settings have same hashCode', () {
        const settings1 = AppSettings(
          darkMode: DarkMode.dark,
          language: AppLanguage.english,
        );
        const settings2 = AppSettings(
          darkMode: DarkMode.dark,
          language: AppLanguage.english,
        );

        expect(settings1.hashCode, settings2.hashCode);
      });

      test('different settings have different hashCode', () {
        const settings1 = AppSettings(darkMode: DarkMode.dark);
        const settings2 = AppSettings(darkMode: DarkMode.light);

        expect(settings1.hashCode, isNot(settings2.hashCode));
      });
    });
  });
}
