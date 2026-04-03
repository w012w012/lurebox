import 'package:open_meteo/open_meteo.dart';

/// 天气代码转中文描述
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
      return '';
  }
}

/// 天气数据
class WeatherData {
  final double? airTemperature; // 气温（摄氏度）
  final double? pressure; // 气压（hPa）
  final int? weatherCode; // 天气代码（WMO）

  const WeatherData({this.airTemperature, this.pressure, this.weatherCode});

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
      // 返回 null 让调用者知道获取天气失败
      return const WeatherData(
          airTemperature: null, pressure: null, weatherCode: null);
    }
  }
}
