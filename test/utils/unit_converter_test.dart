import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/utils/unit_converter.dart';

void main() {
  group('UnitConverter - Length Conversions', () {
    group('toBaseCm', () {
      test('converts cm to cm (identity)', () {
        expect(UnitConverter.toBaseCm(100, 'cm'), 100);
      });

      test('converts m to cm', () {
        expect(UnitConverter.toBaseCm(1, 'm'), 100);
        expect(UnitConverter.toBaseCm(2.5, 'm'), 250);
      });

      test('converts mm to cm', () {
        expect(UnitConverter.toBaseCm(10, 'mm'), 1);
        expect(UnitConverter.toBaseCm(100, 'mm'), 10);
      });

      test('converts inch to cm', () {
        expect(UnitConverter.toBaseCm(1, 'inch'), 2.54);
        expect(UnitConverter.toBaseCm(10, 'inch'), 25.4);
      });

      test('converts ft to cm', () {
        expect(UnitConverter.toBaseCm(1, 'ft'), 30.48);
        expect(UnitConverter.toBaseCm(3, 'ft'), 91.44);
      });

      test('returns value for unknown unit', () {
        expect(UnitConverter.toBaseCm(5, 'unknown'), 5);
      });

      test('handles zero', () {
        expect(UnitConverter.toBaseCm(0, 'cm'), 0);
        expect(UnitConverter.toBaseCm(0, 'm'), 0);
      });

      test('handles negative values', () {
        expect(UnitConverter.toBaseCm(-10, 'cm'), -10);
        expect(UnitConverter.toBaseCm(-1, 'm'), -100);
      });

      test('handles large values', () {
        expect(UnitConverter.toBaseCm(1000000, 'cm'), 1000000);
        expect(UnitConverter.toBaseCm(10000, 'm'), 1000000);
      });
    });

    group('fromBaseCm', () {
      test('converts cm to cm (identity)', () {
        expect(UnitConverter.fromBaseCm(100, 'cm'), 100);
      });

      test('converts cm to m', () {
        expect(UnitConverter.fromBaseCm(100, 'm'), 1);
        expect(UnitConverter.fromBaseCm(250, 'm'), 2.5);
      });

      test('converts cm to mm', () {
        expect(UnitConverter.fromBaseCm(1, 'mm'), 10);
        expect(UnitConverter.fromBaseCm(10, 'mm'), 100);
      });

      test('converts cm to inch', () {
        expect(UnitConverter.fromBaseCm(2.54, 'inch'), 1);
        expect(UnitConverter.fromBaseCm(25.4, 'inch'), 10);
      });

      test('converts cm to ft', () {
        expect(UnitConverter.fromBaseCm(30.48, 'ft'), 1);
        expect(UnitConverter.fromBaseCm(91.44, 'ft'), 3);
      });

      test('returns value for unknown unit', () {
        expect(UnitConverter.fromBaseCm(5, 'unknown'), 5);
      });

      test('handles zero', () {
        expect(UnitConverter.fromBaseCm(0, 'cm'), 0);
        expect(UnitConverter.fromBaseCm(0, 'm'), 0);
      });

      test('handles negative values', () {
        expect(UnitConverter.fromBaseCm(-100, 'cm'), -100);
        expect(UnitConverter.fromBaseCm(-100, 'm'), -1); // -100 cm to m = -1 m
      });
    });

    group('convertLength', () {
      test('converts cm to m', () {
        expect(UnitConverter.convertLength(100, 'cm', 'm'), 1);
      });

      test('converts m to cm', () {
        expect(UnitConverter.convertLength(2, 'm', 'cm'), 200);
      });

      test('converts inch to ft', () {
        // 12 inches = 1 ft
        expect(
          UnitConverter.convertLength(12, 'inch', 'ft'),
          closeTo(1, 0.001),
        );
      });

      test('converts ft to inch', () {
        expect(
          UnitConverter.convertLength(1, 'ft', 'inch'),
          closeTo(12, 0.001),
        );
      });

      test('converts m to ft', () {
        // 1 m = 3.28084 ft
        expect(
          UnitConverter.convertLength(1, 'm', 'ft'),
          closeTo(3.28084, 0.001),
        );
      });

      test('handles same unit conversion', () {
        expect(UnitConverter.convertLength(100, 'cm', 'cm'), 100);
      });

      test('handles unknown units', () {
        expect(UnitConverter.convertLength(100, 'unknown', 'cm'), 100);
        expect(UnitConverter.convertLength(100, 'cm', 'unknown'), 100);
      });
    });
  });

  group('UnitConverter - Weight Conversions', () {
    group('toBaseKg', () {
      test('converts kg to kg (identity)', () {
        expect(UnitConverter.toBaseKg(1, 'kg'), 1);
      });

      test('converts lb to kg', () {
        expect(
          UnitConverter.toBaseKg(1, 'lb'),
          closeTo(0.453592, 0.000001),
        );
        expect(
          UnitConverter.toBaseKg(2.20462, 'lb'),
          closeTo(1, 0.0001),
        );
      });

      test('converts oz to kg', () {
        expect(
          UnitConverter.toBaseKg(1, 'oz'),
          closeTo(0.0283495, 0.0000001),
        );
        expect(
          UnitConverter.toBaseKg(35.274, 'oz'),
          closeTo(1, 0.001),
        );
      });

      test('converts g to kg', () {
        expect(UnitConverter.toBaseKg(1000, 'g'), 1);
        expect(UnitConverter.toBaseKg(500, 'g'), 0.5);
      });

      test('returns value for unknown unit', () {
        expect(UnitConverter.toBaseKg(5, 'unknown'), 5);
      });

      test('handles zero', () {
        expect(UnitConverter.toBaseKg(0, 'kg'), 0);
        expect(UnitConverter.toBaseKg(0, 'lb'), 0);
      });

      test('handles negative values', () {
        expect(UnitConverter.toBaseKg(-1, 'kg'), -1);
        expect(UnitConverter.toBaseKg(-2.20462, 'lb'), closeTo(-1, 0.0001));
      });

      test('handles large values', () {
        expect(UnitConverter.toBaseKg(1000, 'kg'), 1000);
        expect(
          UnitConverter.toBaseKg(2204.62, 'lb'),
          closeTo(1000, 0.01),
        );
      });
    });

    group('fromBaseKg', () {
      test('converts kg to kg (identity)', () {
        expect(UnitConverter.fromBaseKg(1, 'kg'), 1);
      });

      test('converts kg to lb', () {
        expect(
          UnitConverter.fromBaseKg(1, 'lb'),
          closeTo(2.20462, 0.0001),
        );
      });

      test('converts kg to oz', () {
        expect(
          UnitConverter.fromBaseKg(1, 'oz'),
          closeTo(35.274, 0.001),
        );
      });

      test('converts kg to g', () {
        expect(UnitConverter.fromBaseKg(1, 'g'), 1000);
        expect(UnitConverter.fromBaseKg(0.5, 'g'), 500);
      });

      test('returns value for unknown unit', () {
        expect(UnitConverter.fromBaseKg(5, 'unknown'), 5);
      });

      test('handles zero', () {
        expect(UnitConverter.fromBaseKg(0, 'kg'), 0);
        expect(UnitConverter.fromBaseKg(0, 'lb'), 0);
      });

      test('handles negative values', () {
        expect(UnitConverter.fromBaseKg(-1, 'kg'), -1);
        expect(UnitConverter.fromBaseKg(-1, 'lb'), closeTo(-2.20462, 0.0001));
      });
    });

    group('convertWeight', () {
      test('converts kg to lb', () {
        expect(
          UnitConverter.convertWeight(1, 'kg', 'lb'),
          closeTo(2.20462, 0.0001),
        );
      });

      test('converts lb to kg', () {
        expect(
          UnitConverter.convertWeight(2.20462, 'lb', 'kg'),
          closeTo(1, 0.0001),
        );
      });

      test('converts g to lb', () {
        expect(
          UnitConverter.convertWeight(453.592, 'g', 'lb'),
          closeTo(1, 0.001),
        );
      });

      test('converts oz to g', () {
        expect(
          UnitConverter.convertWeight(1, 'oz', 'g'),
          closeTo(28.3495, 0.001),
        );
      });

      test('handles same unit conversion', () {
        expect(UnitConverter.convertWeight(100, 'kg', 'kg'), 100);
      });

      test('handles unknown units', () {
        expect(UnitConverter.convertWeight(100, 'unknown', 'kg'), 100);
        expect(UnitConverter.convertWeight(100, 'kg', 'unknown'), 100);
      });
    });
  });

  group('UnitConverter - Distance Conversions', () {
    group('toBaseMeter', () {
      test('converts m to m (identity)', () {
        expect(UnitConverter.toBaseMeter(1, 'm'), 1);
      });

      test('converts km to m', () {
        expect(UnitConverter.toBaseMeter(1, 'km'), 1000);
        expect(UnitConverter.toBaseMeter(5, 'km'), 5000);
      });

      test('converts ft to m', () {
        expect(
          UnitConverter.toBaseMeter(1, 'ft'),
          closeTo(0.3048, 0.0001),
        );
        expect(
          UnitConverter.toBaseMeter(3.28084, 'ft'),
          closeTo(1, 0.0001),
        );
      });

      test('converts mile to m', () {
        expect(
          UnitConverter.toBaseMeter(1, 'mile'),
          closeTo(1609.344, 0.001),
        );
      });

      test('returns value for unknown unit', () {
        expect(UnitConverter.toBaseMeter(5, 'unknown'), 5);
      });

      test('handles zero', () {
        expect(UnitConverter.toBaseMeter(0, 'm'), 0);
        expect(UnitConverter.toBaseMeter(0, 'km'), 0);
      });

      test('handles negative values', () {
        expect(UnitConverter.toBaseMeter(-1, 'm'), -1);
        expect(UnitConverter.toBaseMeter(-1, 'km'), -1000);
      });

      test('handles large values', () {
        expect(UnitConverter.toBaseMeter(1000, 'km'), 1000000);
      });
    });

    group('fromBaseMeter', () {
      test('converts m to m (identity)', () {
        expect(UnitConverter.fromBaseMeter(1, 'm'), 1);
      });

      test('converts m to km', () {
        expect(UnitConverter.fromBaseMeter(1000, 'km'), 1);
        expect(UnitConverter.fromBaseMeter(5000, 'km'), 5);
      });

      test('converts m to ft', () {
        expect(
          UnitConverter.fromBaseMeter(1, 'ft'),
          closeTo(3.28084, 0.0001),
        );
      });

      test('converts m to mile', () {
        expect(
          UnitConverter.fromBaseMeter(1609.344, 'mile'),
          closeTo(1, 0.001),
        );
      });

      test('returns value for unknown unit', () {
        expect(UnitConverter.fromBaseMeter(5, 'unknown'), 5);
      });

      test('handles zero', () {
        expect(UnitConverter.fromBaseMeter(0, 'm'), 0);
        expect(UnitConverter.fromBaseMeter(0, 'km'), 0);
      });

      test('handles negative values', () {
        expect(UnitConverter.fromBaseMeter(-1, 'm'), -1);
        expect(UnitConverter.fromBaseMeter(-1000, 'km'), -1);
      });
    });

    group('convertDistance', () {
      test('converts km to mile', () {
        expect(
          UnitConverter.convertDistance(1, 'km', 'mile'),
          closeTo(0.621371, 0.0001),
        );
      });

      test('converts mile to km', () {
        expect(
          UnitConverter.convertDistance(1, 'mile', 'km'),
          closeTo(1.609344, 0.0001),
        );
      });

      test('converts ft to mile', () {
        expect(
          UnitConverter.convertDistance(5280, 'ft', 'mile'),
          closeTo(1, 0.01),
        );
      });

      test('converts m to km', () {
        expect(UnitConverter.convertDistance(1000, 'm', 'km'), 1);
      });

      test('handles same unit conversion', () {
        expect(UnitConverter.convertDistance(100, 'km', 'km'), 100);
      });

      test('handles unknown units', () {
        expect(UnitConverter.convertDistance(100, 'unknown', 'm'), 100);
        expect(UnitConverter.convertDistance(100, 'm', 'unknown'), 100);
      });
    });
  });

  group('UnitConverter - Temperature Conversions', () {
    group('toBaseCelsius', () {
      test('converts C to C (identity)', () {
        expect(UnitConverter.toBaseCelsius(0, 'C'), 0);
        expect(UnitConverter.toBaseCelsius(100, 'C'), 100);
      });

      test('converts F to C', () {
        expect(UnitConverter.toBaseCelsius(32, 'F'), 0);
        expect(UnitConverter.toBaseCelsius(212, 'F'), 100);
        expect(
          UnitConverter.toBaseCelsius(98.6, 'F'),
          closeTo(37, 0.001),
        );
      });

      test('returns value for unknown unit', () {
        expect(UnitConverter.toBaseCelsius(0, 'unknown'), 0);
      });

      test('handles zero', () {
        expect(UnitConverter.toBaseCelsius(0, 'C'), 0);
        expect(UnitConverter.toBaseCelsius(0, 'F'), closeTo(-17.7778, 0.001));
      });

      test('handles negative celsius', () {
        expect(UnitConverter.toBaseCelsius(-40, 'C'), -40);
      });

      test('handles negative fahrenheit', () {
        expect(
          UnitConverter.toBaseCelsius(-40, 'F'),
          closeTo(-40, 0.001),
        );
      });

      test('handles extreme values', () {
        expect(UnitConverter.toBaseCelsius(1000, 'F'), closeTo(537.778, 0.01));
      });
    });

    group('fromBaseCelsius', () {
      test('converts C to C (identity)', () {
        expect(UnitConverter.fromBaseCelsius(0, 'C'), 0);
        expect(UnitConverter.fromBaseCelsius(100, 'C'), 100);
      });

      test('converts C to F', () {
        expect(UnitConverter.fromBaseCelsius(0, 'F'), 32);
        expect(UnitConverter.fromBaseCelsius(100, 'F'), 212);
        expect(
          UnitConverter.fromBaseCelsius(37, 'F'),
          closeTo(98.6, 0.001),
        );
      });

      test('returns value for unknown unit', () {
        expect(UnitConverter.fromBaseCelsius(0, 'unknown'), 0);
      });

      test('handles zero', () {
        expect(UnitConverter.fromBaseCelsius(0, 'C'), 0);
        expect(UnitConverter.fromBaseCelsius(0, 'F'), 32);
      });

      test('handles negative celsius', () {
        expect(UnitConverter.fromBaseCelsius(-40, 'C'), -40);
        expect(UnitConverter.fromBaseCelsius(-40, 'F'), closeTo(-40, 0.001));
      });

      test('handles extreme values', () {
        expect(
          UnitConverter.fromBaseCelsius(537.778, 'F'),
          closeTo(1000, 0.01),
        );
      });
    });

    group('convertTemperature', () {
      test('converts C to F', () {
        expect(UnitConverter.convertTemperature(0, 'C', 'F'), 32);
        expect(UnitConverter.convertTemperature(100, 'C', 'F'), 212);
      });

      test('converts F to C', () {
        expect(UnitConverter.convertTemperature(32, 'F', 'C'), 0);
        expect(UnitConverter.convertTemperature(212, 'F', 'C'), 100);
      });

      test('converts F to F (identity)', () {
        expect(UnitConverter.convertTemperature(50, 'F', 'F'), 50);
      });

      test('converts C to C (identity)', () {
        expect(UnitConverter.convertTemperature(50, 'C', 'C'), 50);
      });

      test('handles unknown units', () {
        expect(UnitConverter.convertTemperature(100, 'unknown', 'C'), 100);
        expect(UnitConverter.convertTemperature(100, 'C', 'unknown'), 100);
      });

      test('handles negative temperatures', () {
        expect(
          UnitConverter.convertTemperature(-40, 'C', 'F'),
          closeTo(-40, 0.001),
        );
        expect(
          UnitConverter.convertTemperature(-40, 'F', 'C'),
          closeTo(-40, 0.001),
        );
      });
    });
  });

  group('UnitConverter - Symbol Getters', () {
    group('getLengthSymbol', () {
      test('returns Chinese symbols by default', () {
        expect(UnitConverter.getLengthSymbol('cm'), '厘米');
        expect(UnitConverter.getLengthSymbol('m'), '米');
        expect(UnitConverter.getLengthSymbol('mm'), '毫米');
        expect(UnitConverter.getLengthSymbol('inch'), '英寸');
        expect(UnitConverter.getLengthSymbol('ft'), '英尺');
      });

      test('returns English symbols when isChinese=false', () {
        expect(UnitConverter.getLengthSymbol('cm', isChinese: false), 'cm');
        expect(UnitConverter.getLengthSymbol('m', isChinese: false), 'm');
        expect(UnitConverter.getLengthSymbol('mm', isChinese: false), 'mm');
        expect(UnitConverter.getLengthSymbol('inch', isChinese: false), 'in');
        expect(UnitConverter.getLengthSymbol('ft', isChinese: false), 'ft');
      });

      test('returns unit itself for unknown unit', () {
        expect(UnitConverter.getLengthSymbol('unknown'), 'unknown');
        expect(
          UnitConverter.getLengthSymbol('unknown', isChinese: false),
          'unknown',
        );
      });
    });

    group('getWeightSymbol', () {
      test('returns Chinese symbols by default', () {
        expect(UnitConverter.getWeightSymbol('kg'), '千克');
        expect(UnitConverter.getWeightSymbol('lb'), '磅');
        expect(UnitConverter.getWeightSymbol('oz'), '盎司');
        expect(UnitConverter.getWeightSymbol('g'), '克');
      });

      test('returns English symbols when isChinese=false', () {
        expect(UnitConverter.getWeightSymbol('kg', isChinese: false), 'kg');
        expect(UnitConverter.getWeightSymbol('lb', isChinese: false), 'lb');
        expect(UnitConverter.getWeightSymbol('oz', isChinese: false), 'oz');
        expect(UnitConverter.getWeightSymbol('g', isChinese: false), 'g');
      });

      test('returns unit itself for unknown unit', () {
        expect(UnitConverter.getWeightSymbol('unknown'), 'unknown');
      });
    });

    group('getDistanceSymbol', () {
      test('returns Chinese symbols by default', () {
        expect(UnitConverter.getDistanceSymbol('m'), '米');
        expect(UnitConverter.getDistanceSymbol('km'), '千米');
        expect(UnitConverter.getDistanceSymbol('ft'), '英尺');
        expect(UnitConverter.getDistanceSymbol('mile'), '英里');
      });

      test('returns English symbols when isChinese=false', () {
        expect(UnitConverter.getDistanceSymbol('m', isChinese: false), 'm');
        expect(UnitConverter.getDistanceSymbol('km', isChinese: false), 'km');
        expect(UnitConverter.getDistanceSymbol('ft', isChinese: false), 'ft');
        expect(UnitConverter.getDistanceSymbol('mile', isChinese: false), 'mi');
      });

      test('returns unit itself for unknown unit', () {
        expect(UnitConverter.getDistanceSymbol('unknown'), 'unknown');
      });
    });

    group('getTemperatureSymbol', () {
      test('returns Chinese symbols by default', () {
        expect(UnitConverter.getTemperatureSymbol('C'), '摄氏度');
        expect(UnitConverter.getTemperatureSymbol('F'), '华氏度');
      });

      test('returns English symbols when isChinese=false', () {
        expect(UnitConverter.getTemperatureSymbol('C', isChinese: false), '°C');
        expect(UnitConverter.getTemperatureSymbol('F', isChinese: false), '°F');
      });

      test('returns unit itself for unknown unit', () {
        expect(UnitConverter.getTemperatureSymbol('unknown'), 'unknown');
      });
    });
  });

  group('UnitConverter - Format Methods', () {
    group('formatLength', () {
      test('formats with default parameters (1 decimal, Chinese)', () {
        expect(UnitConverter.formatLength(100, 'cm'), '100.0 厘米');
        expect(UnitConverter.formatLength(1.5, 'm'), '1.5 米');
      });

      test('formats with English symbols', () {
        expect(
          UnitConverter.formatLength(100, 'cm', isChinese: false),
          '100.0 cm',
        );
      });

      test('formats with custom decimals', () {
        expect(UnitConverter.formatLength(100.556, 'cm', decimals: 2),
            '100.56 厘米');
        expect(
            UnitConverter.formatLength(100.556, 'cm', decimals: 0), '101 厘米');
      });

      test('formats negative values', () {
        expect(UnitConverter.formatLength(-100, 'cm'), '-100.0 厘米');
      });

      test('formats zero', () {
        expect(UnitConverter.formatLength(0, 'cm'), '0.0 厘米');
      });
    });

    group('formatWeight', () {
      test('formats with default parameters (2 decimals, Chinese)', () {
        expect(UnitConverter.formatWeight(1.5, 'kg'), '1.50 千克');
        expect(UnitConverter.formatWeight(2.20462, 'lb'), '2.20 磅');
      });

      test('formats with English symbols', () {
        expect(
          UnitConverter.formatWeight(1.5, 'kg', isChinese: false),
          '1.50 kg',
        );
      });

      test('formats with custom decimals', () {
        expect(UnitConverter.formatWeight(1.556, 'kg', decimals: 1), '1.6 千克');
        expect(
            UnitConverter.formatWeight(1.556, 'kg', decimals: 3), '1.556 千克');
      });

      test('formats negative values', () {
        expect(UnitConverter.formatWeight(-1, 'kg'), '-1.00 千克');
      });

      test('formats zero', () {
        expect(UnitConverter.formatWeight(0, 'kg'), '0.00 千克');
      });
    });

    group('formatDistance', () {
      test('formats with default parameters (1 decimal, Chinese)', () {
        expect(UnitConverter.formatDistance(5.5, 'km'), '5.5 千米');
        expect(UnitConverter.formatDistance(1.5, 'm'), '1.5 米');
      });

      test('formats with English symbols', () {
        expect(
          UnitConverter.formatDistance(5.5, 'km', isChinese: false),
          '5.5 km',
        );
      });

      test('formats with custom decimals', () {
        expect(
          UnitConverter.formatDistance(5.556, 'km', decimals: 2),
          '5.56 千米',
        );
      });

      test('formats negative values', () {
        expect(UnitConverter.formatDistance(-5, 'km'), '-5.0 千米');
      });

      test('formats zero', () {
        expect(UnitConverter.formatDistance(0, 'km'), '0.0 千米');
      });
    });

    group('formatTemperature', () {
      test('formats with default parameters (1 decimal, Chinese)', () {
        expect(UnitConverter.formatTemperature(37, 'C'), '37.0摄氏度');
        expect(UnitConverter.formatTemperature(98.6, 'F'), '98.6华氏度');
      });

      test('formats with English symbols', () {
        expect(
          UnitConverter.formatTemperature(37, 'C', isChinese: false),
          '37.0°C',
        );
        expect(
          UnitConverter.formatTemperature(98.6, 'F', isChinese: false),
          '98.6°F',
        );
      });

      test('formats with custom decimals', () {
        expect(
          UnitConverter.formatTemperature(37.556, 'C', decimals: 2),
          '37.56摄氏度',
        );
      });

      test('formats negative temperatures', () {
        expect(UnitConverter.formatTemperature(-40, 'C'), '-40.0摄氏度');
      });

      test('formats zero', () {
        expect(UnitConverter.formatTemperature(0, 'C'), '0.0摄氏度');
      });
    });
  });

  group('UnitConverter - Edge Cases', () {
    test('very small non-zero values', () {
      expect(UnitConverter.toBaseCm(0.001, 'mm'), closeTo(0.0001, 0.000001));
      expect(
          UnitConverter.toBaseKg(0.001, 'g'), closeTo(0.000001, 0.000000001));
    });

    test('very large values', () {
      expect(UnitConverter.toBaseCm(1e15, 'm'), 1e17);
      expect(UnitConverter.toBaseKg(1e10, 'lb'), closeTo(4.53592e9, 1e6));
    });

    test('decimal precision in conversions', () {
      // Round-trip conversion should be stable
      final original = 75.5;
      final inInches = UnitConverter.convertLength(original, 'cm', 'inch');
      final backToCm = UnitConverter.convertLength(inInches, 'inch', 'cm');
      expect(backToCm, closeTo(original, 0.0001));
    });

    test('temperature round-trip precision', () {
      // Round-trip conversion should be stable
      final original = 25.0;
      final inF = UnitConverter.convertTemperature(original, 'C', 'F');
      final backToC = UnitConverter.convertTemperature(inF, 'F', 'C');
      expect(backToC, closeTo(original, 0.0001));
    });

    test('weight round-trip precision', () {
      // Round-trip conversion should be stable
      final original = 75.5;
      final inLb = UnitConverter.convertWeight(original, 'kg', 'lb');
      final backToKg = UnitConverter.convertWeight(inLb, 'lb', 'kg');
      expect(backToKg, closeTo(original, 0.0001));
    });

    test('distance round-trip precision', () {
      // Round-trip conversion should be stable
      final original = 42.195;
      final inKm = UnitConverter.convertDistance(original, 'km', 'mile');
      final backToKm = UnitConverter.convertDistance(inKm, 'mile', 'km');
      expect(backToKm, closeTo(original, 0.0001));
    });
  });
}
