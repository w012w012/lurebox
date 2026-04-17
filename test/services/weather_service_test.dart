import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/services/weather_service.dart';
import 'package:lurebox/core/constants/strings.dart';

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

    test('returns 大雪 for code 73', () {
      expect(getWeatherDescription(73), equals('大雪'));
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

    test('returns 未知 for unknown code', () {
      expect(getWeatherDescription(999), equals('未知'));
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

    test('weatherDescription returns 未知 for unknown code', () {
      const data = WeatherData(weatherCode: 999);
      expect(data.weatherDescription, equals('未知'));
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

    test('fields are immutable after creation', () {
      const data = WeatherData(airTemperature: 25.0);
      expect(data.airTemperature, equals(25.0));
    });
  });

  group('WeatherService - getLocalizedWeatherDescription', () {
    const chinese = AppStrings.chinese;
    const english = AppStrings.english;

    test('returns empty string for null code', () {
      expect(getLocalizedWeatherDescription(null, chinese), equals(''));
    });

    test('returns weatherClear for code 0', () {
      expect(getLocalizedWeatherDescription(0, chinese), equals(chinese.weatherClear));
      expect(getLocalizedWeatherDescription(0, english), equals(english.weatherClear));
    });

    test('returns correct localized strings for clear/cloudy codes', () {
      expect(getLocalizedWeatherDescription(1, chinese), equals(chinese.weatherMainlyClear));
      expect(getLocalizedWeatherDescription(2, chinese), equals(chinese.weatherPartlyCloudy));
      expect(getLocalizedWeatherDescription(3, chinese), equals(chinese.weatherOvercast));
    });

    test('returns correct localized strings for fog codes', () {
      expect(getLocalizedWeatherDescription(45, chinese), equals(chinese.weatherFog));
      expect(getLocalizedWeatherDescription(48, chinese), equals(chinese.weatherFog));
    });

    test('returns correct localized strings for drizzle codes', () {
      expect(getLocalizedWeatherDescription(51, chinese), equals(chinese.weatherDrizzle));
      expect(getLocalizedWeatherDescription(53, chinese), equals(chinese.weatherDrizzle));
      expect(getLocalizedWeatherDescription(55, chinese), equals(chinese.weatherDrizzle));
    });

    test('returns correct localized strings for freezing drizzle codes', () {
      expect(getLocalizedWeatherDescription(56, chinese), equals(chinese.weatherFreezingDrizzle));
      expect(getLocalizedWeatherDescription(57, chinese), equals(chinese.weatherFreezingDrizzle));
    });

    test('returns correct localized strings for rain codes', () {
      expect(getLocalizedWeatherDescription(61, chinese), equals(chinese.weatherRain));
      expect(getLocalizedWeatherDescription(63, chinese), equals(chinese.weatherRain));
      expect(getLocalizedWeatherDescription(65, chinese), equals(chinese.weatherRain));
    });

    test('returns correct localized strings for freezing rain codes', () {
      expect(getLocalizedWeatherDescription(66, chinese), equals(chinese.weatherFreezingRain));
      expect(getLocalizedWeatherDescription(67, chinese), equals(chinese.weatherFreezingRain));
    });

    test('returns correct localized strings for snow codes', () {
      expect(getLocalizedWeatherDescription(71, chinese), equals(chinese.weatherSnowFall));
      expect(getLocalizedWeatherDescription(73, chinese), equals(chinese.weatherSnowFall));
      expect(getLocalizedWeatherDescription(75, chinese), equals(chinese.weatherSnowFall));
      expect(getLocalizedWeatherDescription(77, chinese), equals(chinese.weatherSnowGrains));
    });

    test('returns correct localized strings for shower codes', () {
      expect(getLocalizedWeatherDescription(80, chinese), equals(chinese.weatherRainShowers));
      expect(getLocalizedWeatherDescription(81, chinese), equals(chinese.weatherRainShowers));
      expect(getLocalizedWeatherDescription(82, chinese), equals(chinese.weatherRainShowers));
      expect(getLocalizedWeatherDescription(85, chinese), equals(chinese.weatherSnowShowers));
      expect(getLocalizedWeatherDescription(86, chinese), equals(chinese.weatherSnowShowers));
    });

    test('returns correct localized strings for thunderstorm codes', () {
      expect(getLocalizedWeatherDescription(95, chinese), equals(chinese.weatherThunderstorm));
      expect(getLocalizedWeatherDescription(96, chinese), equals(chinese.weatherThunderstormHail));
      expect(getLocalizedWeatherDescription(99, chinese), equals(chinese.weatherThunderstormHail));
    });

    test('returns weatherUnknown for unrecognized code', () {
      expect(getLocalizedWeatherDescription(999, chinese), equals(chinese.weatherUnknown));
    });

    test('chinese and english strings differ for known codes', () {
      expect(chinese.weatherClear, isNot(equals(english.weatherClear)));
    });
  });
}
