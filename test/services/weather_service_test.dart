import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/services/weather_service.dart';

void main() {
  group('WeatherService - getWeatherDescription', () {
    final testCases = <(int?, String)>[
      (0, '晴'),
      (1, '晴间多云'),
      (2, '多云'),
      (3, '阴'),
      (45, '雾'),
      (48, '雾'),
      (51, '小雨'),
      (53, '小雨'),
      (55, '小雨'),
      (56, '冻雨'),
      (61, '中雨'),
      (63, '中雨'),
      (65, '中雨'),
      (66, '雨夹雪'),
      (71, '大雪'),
      (73, '大雪'),
      (75, '大雪'),
      (77, '雪粒'),
      (80, '暴雨'),
      (81, '暴雨'),
      (82, '暴雨'),
      (85, '阵雪'),
      (95, '雷暴'),
      (96, '雷暴加冰雹'),
      (99, '雷暴加冰雹'),
      (null, ''),
      (999, '未知'),
    ];

    for (final (code, expected) in testCases) {
      test('returns $expected for code $code', () {
        expect(getWeatherDescription(code), equals(expected));
      });
    }
  });

  group('WeatherService - WeatherData', () {
    test('isEmpty returns true when all fields are null', () {
      const data = WeatherData();
      expect(data.isEmpty, isTrue);
    });

    test('isEmpty returns false when temperature is set', () {
      const data = WeatherData(airTemperature: 25);
      expect(data.isEmpty, isFalse);
    });

    test('isEmpty returns false when pressure is set', () {
      const data = WeatherData(pressure: 1013);
      expect(data.isEmpty, isFalse);
    });

    test('isEmpty returns false when weatherCode is set', () {
      const data = WeatherData(weatherCode: 0);
      expect(data.isEmpty, isFalse);
    });

    test('isEmpty returns false when all fields are set', () {
      const data = WeatherData(
        airTemperature: 25,
        pressure: 1013,
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
      const data = WeatherData(airTemperature: 25);
      expect(data.airTemperature, equals(25.0));
    });
  });

  group('WeatherService - getLocalizedWeatherDescription', () {
    const chinese = AppStrings.chinese;
    const english = AppStrings.english;

    // (code, AppStrings getter)
    final testCases = <(int?, String Function(AppStrings))>[
      (null, (_) => ''),
      (0, (s) => s.weatherClear),
      (1, (s) => s.weatherMainlyClear),
      (2, (s) => s.weatherPartlyCloudy),
      (3, (s) => s.weatherOvercast),
      (45, (s) => s.weatherFog),
      (48, (s) => s.weatherFog),
      (51, (s) => s.weatherDrizzle),
      (53, (s) => s.weatherDrizzle),
      (55, (s) => s.weatherDrizzle),
      (56, (s) => s.weatherFreezingDrizzle),
      (57, (s) => s.weatherFreezingDrizzle),
      (61, (s) => s.weatherRain),
      (63, (s) => s.weatherRain),
      (65, (s) => s.weatherRain),
      (66, (s) => s.weatherFreezingRain),
      (67, (s) => s.weatherFreezingRain),
      (71, (s) => s.weatherSnowFall),
      (73, (s) => s.weatherSnowFall),
      (75, (s) => s.weatherSnowFall),
      (77, (s) => s.weatherSnowGrains),
      (80, (s) => s.weatherRainShowers),
      (81, (s) => s.weatherRainShowers),
      (82, (s) => s.weatherRainShowers),
      (85, (s) => s.weatherSnowShowers),
      (86, (s) => s.weatherSnowShowers),
      (95, (s) => s.weatherThunderstorm),
      (96, (s) => s.weatherThunderstormHail),
      (99, (s) => s.weatherThunderstormHail),
      (999, (s) => s.weatherUnknown),
    ];

    for (final (code, getExpected) in testCases) {
      test('returns correct string for code $code', () {
        expect(getLocalizedWeatherDescription(code, chinese), equals(getExpected(chinese)));
        expect(getLocalizedWeatherDescription(code, english), equals(getExpected(english)));
      });
    }

    test('chinese and english strings differ for known codes', () {
      expect(chinese.weatherClear, isNot(equals(english.weatherClear)));
    });
  });
}
