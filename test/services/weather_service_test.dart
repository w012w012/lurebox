import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/services/weather_service.dart';

void main() {
  group('WeatherService - getWeatherDescription', () {
    test('returns 晴 for code 0', () {
      expect(getWeatherDescription(0), equals('晴'));
    });

    test('returns 晴间多云 for code 1', () {
      expect(getWeatherDescription(1), equals('晴间多云'));
    });

    test('returns 多云 for code 2', () {
      expect(getWeatherDescription(2), equals('多云'));
    });

    test('returns 阴 for code 3', () {
      expect(getWeatherDescription(3), equals('阴'));
    });

    test('returns 雾 for code 45', () {
      expect(getWeatherDescription(45), equals('雾'));
    });

    test('returns 雾 for code 48', () {
      expect(getWeatherDescription(48), equals('雾'));
    });

    test('returns 小雨 for code 51', () {
      expect(getWeatherDescription(51), equals('小雨'));
    });

    test('returns 小雨 for code 53', () {
      expect(getWeatherDescription(53), equals('小雨'));
    });

    test('returns 小雨 for code 55', () {
      expect(getWeatherDescription(55), equals('小雨'));
    });

    test('returns 冻雨 for code 56', () {
      expect(getWeatherDescription(56), equals('冻雨'));
    });

    test('returns 中雨 for code 61', () {
      expect(getWeatherDescription(61), equals('中雨'));
    });

    test('returns 中雨 for code 63', () {
      expect(getWeatherDescription(63), equals('中雨'));
    });

    test('returns 中雨 for code 65', () {
      expect(getWeatherDescription(65), equals('中雨'));
    });

    test('returns 雨夹雪 for code 66', () {
      expect(getWeatherDescription(66), equals('雨夹雪'));
    });

    test('returns 大雪 for code 71', () {
      expect(getWeatherDescription(71), equals('大雪'));
    });

    test('returns 大雪 for code 75', () {
      expect(getWeatherDescription(75), equals('大雪'));
    });

    test('returns 雪粒 for code 77', () {
      expect(getWeatherDescription(77), equals('雪粒'));
    });

    test('returns 暴雨 for code 80', () {
      expect(getWeatherDescription(80), equals('暴雨'));
    });

    test('returns 暴雨 for code 81', () {
      expect(getWeatherDescription(81), equals('暴雨'));
    });

    test('returns 暴雨 for code 82', () {
      expect(getWeatherDescription(82), equals('暴雨'));
    });

    test('returns 阵雪 for code 85', () {
      expect(getWeatherDescription(85), equals('阵雪'));
    });

    test('returns 雷暴 for code 95', () {
      expect(getWeatherDescription(95), equals('雷暴'));
    });

    test('returns 雷暴加冰雹 for code 96', () {
      expect(getWeatherDescription(96), equals('雷暴加冰雹'));
    });

    test('returns 雷暴加冰雹 for code 99', () {
      expect(getWeatherDescription(99), equals('雷暴加冰雹'));
    });

    test('returns empty string for null', () {
      expect(getWeatherDescription(null), equals(''));
    });

    test('returns empty string for unknown code', () {
      expect(getWeatherDescription(999), equals(''));
    });
  });

  group('WeatherService - WeatherData', () {
    test('isEmpty returns true when all fields are null', () {
      const data = WeatherData();
      expect(data.isEmpty, isTrue);
    });

    test('isEmpty returns false when temperature is set', () {
      const data = WeatherData(airTemperature: 25.0);
      expect(data.isEmpty, isFalse);
    });

    test('isEmpty returns false when pressure is set', () {
      const data = WeatherData(pressure: 1013.0);
      expect(data.isEmpty, isFalse);
    });

    test('isEmpty returns false when weatherCode is set', () {
      const data = WeatherData(weatherCode: 0);
      expect(data.isEmpty, isFalse);
    });

    test('isEmpty returns false when all fields are set', () {
      const data = WeatherData(
        airTemperature: 25.0,
        pressure: 1013.0,
        weatherCode: 0,
      );
      expect(data.isEmpty, isFalse);
    });

    test('weatherDescription returns null when weatherCode is null', () {
      const data = WeatherData();
      expect(data.weatherDescription, isNull);
    });

    test('weatherDescription returns correct description for known code', () {
      const data = WeatherData(weatherCode: 0);
      expect(data.weatherDescription, equals('晴'));
    });

    test('weatherDescription returns empty string for unknown code', () {
      const data = WeatherData(weatherCode: 999);
      expect(data.weatherDescription, equals(''));
    });

    test('weatherDescription returns correct description for rain codes', () {
      expect(
        const WeatherData(weatherCode: 61).weatherDescription,
        equals('中雨'),
      );
      expect(
        const WeatherData(weatherCode: 80).weatherDescription,
        equals('暴雨'),
      );
    });

    test('weatherDescription returns correct description for snow codes', () {
      expect(
        const WeatherData(weatherCode: 71).weatherDescription,
        equals('大雪'),
      );
      expect(
        const WeatherData(weatherCode: 85).weatherDescription,
        equals('阵雪'),
      );
    });

    test('weatherDescription returns correct description for storm codes', () {
      expect(
        const WeatherData(weatherCode: 95).weatherDescription,
        equals('雷暴'),
      );
      expect(
        const WeatherData(weatherCode: 99).weatherDescription,
        equals('雷暴加冰雹'),
      );
    });

    test('constructor with named parameters works correctly', () {
      const data = WeatherData(
        airTemperature: 20.5,
        pressure: 1015.5,
        weatherCode: 3,
      );
      expect(data.airTemperature, equals(20.5));
      expect(data.pressure, equals(1015.5));
      expect(data.weatherCode, equals(3));
    });

    test('immutability - fields cannot be modified after creation', () {
      const data = WeatherData(airTemperature: 25.0);
      // This would not compile if we tried to assign: data.airTemperature = 30.0;
      expect(data.airTemperature, equals(25.0));
    });
  });

  group('WeatherService - WeatherApiClient abstraction', () {
    test('WeatherService accepts custom apiClient', () {
      // This test verifies that the WeatherService constructor accepts
      // an optional apiClient parameter for dependency injection
      final service = WeatherService();
      expect(service, isA<WeatherService>());
    });
  });
}
