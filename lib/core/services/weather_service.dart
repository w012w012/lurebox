import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/services/app_logger.dart';
import 'package:open_meteo/open_meteo.dart';

/// 天气代码转中文描述（默认行为，兼容旧代码）
/// 基于 WMO Weather interpretation codes (WW)
/// 参考: https://open-meteo.com/en/docs
String getWeatherDescription(int? code) {
  if (code == null) return '';
  switch (code) {
    case 0:
      return '晴';
    case 1:
      return '晴间多云';
    case 2:
      return '多云';
    case 3:
      return '阴';
    case 45:
    case 48:
      return '雾';
    case 51:
    case 53:
    case 55:
      return '小雨';
    case 56:
    case 57:
      return '冻雨';
    case 61:
    case 63:
    case 65:
      return '中雨';
    case 66:
    case 67:
      return '雨夹雪';
    case 71:
    case 73:
    case 75:
      return '大雪';
    case 77:
      return '雪粒';
    case 80:
    case 81:
    case 82:
      return '暴雨';
    case 85:
    case 86:
      return '阵雪';
    case 95:
      return '雷暴';
    case 96:
    case 99:
      return '雷暴加冰雹';
    default:
      return '未知';
  }
}

/// 根据语言环境返回天气描述
String getLocalizedWeatherDescription(int? code, AppStrings strings) {
  if (code == null) return '';
  switch (code) {
    case 0:
      return strings.weatherClear;
    case 1:
      return strings.weatherMainlyClear;
    case 2:
      return strings.weatherPartlyCloudy;
    case 3:
      return strings.weatherOvercast;
    case 45:
    case 48:
      return strings.weatherFog;
    case 51:
    case 53:
    case 55:
      return strings.weatherDrizzle;
    case 56:
    case 57:
      return strings.weatherFreezingDrizzle;
    case 61:
    case 63:
    case 65:
      return strings.weatherRain;
    case 66:
    case 67:
      return strings.weatherFreezingRain;
    case 71:
    case 73:
    case 75:
      return strings.weatherSnowFall;
    case 77:
      return strings.weatherSnowGrains;
    case 80:
    case 81:
    case 82:
      return strings.weatherRainShowers;
    case 85:
    case 86:
      return strings.weatherSnowShowers;
    case 95:
      return strings.weatherThunderstorm;
    case 96:
    case 99:
      return strings.weatherThunderstormHail;
    default:
      return strings.weatherUnknown;
  }
}

/// 天气数据
class WeatherData { // 天气代码（WMO）

  const WeatherData({this.airTemperature, this.pressure, this.weatherCode});
  final double? airTemperature; // 气温（摄氏度）
  final double? pressure; // 气压（hPa）
  final int? weatherCode;

  bool get isEmpty =>
      airTemperature == null && pressure == null && weatherCode == null;

  String? get weatherDescription =>
      weatherCode != null ? getWeatherDescription(weatherCode) : null;
}

/// 天气服务 - 通过 Open-Meteo API 获取天气数据
///
/// 使用 Open-Meteo 免费天气 API，无需 API 密钥
/// API 文档: https://open-meteo.com/en/docs
class WeatherService {
  final WeatherApi _weatherApi = const WeatherApi();

  /// 根据经纬度获取当前天气
  ///
  /// [latitude] 纬度
  /// [longitude] 经度
  ///
  /// 返回 [WeatherData]，包含气温、气压和天气代码
  Future<WeatherData> getWeather(double latitude, double longitude) async {
    try {
      final response = await _weatherApi.request(
        locations: {
          OpenMeteoLocation(latitude: latitude, longitude: longitude),
        },
        current: {
          WeatherCurrent.temperature_2m,
          WeatherCurrent.pressure_msl,
          WeatherCurrent.weather_code,
        },
      );

      final segment = response.segments.first;
      final current = segment.currentData;

      return WeatherData(
        airTemperature: current[WeatherCurrent.temperature_2m]?.value,
        pressure: current[WeatherCurrent.pressure_msl]?.value,
        weatherCode: current[WeatherCurrent.weather_code]?.value.toInt(),
      );
    } catch (e) {
      AppLogger.e('WeatherService', 'Failed to fetch weather data', e);
      return const WeatherData(
          );
    }
  }
}
