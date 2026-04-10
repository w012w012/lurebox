import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/error_service.dart' as error_service;
import '../services/permission_service.dart';
import '../services/weather_service.dart';

class CameraHelper {
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isInitialized = false;
  String? _errorMessage;
  int _currentCameraIndex = 0;
  String? _locationName;
  double? _latitude;
  double? _longitude;
  Position? _position;
  WeatherData? _weatherData;
  final WeatherService _weatherService = WeatherService();

  CameraController? get cameraController => _cameraController;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get canSwitchCamera => _cameras.length > 1;
  String? get locationName => _locationName;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  Position? get position => _position;
  double? get positionLat => _latitude;
  double? get positionLng => _longitude;
  WeatherData? get weatherData => _weatherData;

  Future<void> initCamera({BuildContext? context}) async {
    try {
      await error_service.ErrorService().wrap(() async {
        // Request camera permission with education dialog
        if (context != null) {
          final result =
              await PermissionService().requestCameraPermission(context);
          if (!result.granted) {
            _errorMessage = '需要相机权限';
            return;
          }
        } else {
          // Fallback: direct request without education
          final status = await Permission.camera.status;
          if (!status.isGranted) {
            await Permission.camera.request();
          }
        }

        _cameras = await availableCameras();
        if (_cameras.isEmpty) {
          _errorMessage = 'No cameras available';
          return;
        }
        await _initCameraController(_cameras[_currentCameraIndex]);
      }, context: '初始化相机');
    } catch (e) {
      _errorMessage = '相机初始化失败: $e';
      _isInitialized = false;
    }
  }

  Future<void> _initCameraController(CameraDescription camera) async {
    // 必须 await 旧控制器释放完成，否则会导致竞态条件（每隔一次失败）
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }
    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await _cameraController!.initialize();
      _isInitialized = true;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '相机控制器初始化失败: $e';
      _isInitialized = false;
    }
  }

  Future<bool> switchCamera() async {
    if (_cameras.length <= 1) return false;
    try {
      await error_service.ErrorService().wrap(() async {
        _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
        await _initCameraController(_cameras[_currentCameraIndex]);
      }, context: '切换相机');
      return _isInitialized;
    } catch (e) {
      return false;
    }
  }

  Future<String?> takePicture() async {
    if (!_isInitialized || _cameraController == null) return null;
    try {
      return await error_service.ErrorService().wrap(() async {
        final image = await _cameraController!.takePicture();
        return image.path;
      }, context: '拍照');
    } catch (e) {
      _errorMessage = '拍照失败: $e';
      return null;
    }
  }

  Future<void> getLocation({BuildContext? context}) async {
    try {
      await error_service.ErrorService().wrap(() async {
        // Request location permission with education dialog
        if (context != null) {
          final result =
              await PermissionService().requestLocationPermission(context);
          if (!result.granted) {
            _locationName = '位置权限未授权';
            return;
          }
        } else {
          // Fallback: direct request without education
          var status = await Permission.locationWhenInUse.status;
          if (!status.isGranted) {
            status = await Permission.locationWhenInUse.request();
            if (!status.isGranted) {
              _locationName = '位置权限未授权';
              return;
            }
          }
        }

        Position? position;
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw const error_service.LocationException('定位超时'),
          );
          _position = position;
        } catch (e) {
          _locationName = '定位失败';
          return;
        }

        _latitude = position.latitude;
        _longitude = position.longitude;
        _position = position;

        // 获取天气数据
        _weatherData = await _weatherService.getWeather(
          _latitude!,
          _longitude!,
        );

        try {
          final placemarks =
              await placemarkFromCoordinates(_latitude!, _longitude!).timeout(
            const Duration(seconds: 5),
            onTimeout: () =>
                throw const error_service.LocationException('地址解析超时'),
          );
          if (placemarks.isNotEmpty) {
            final place = placemarks[0];
            _locationName =
                '${place.administrativeArea ?? ''}${place.locality ?? ''}${place.name ?? ''}';
            if (_locationName == null || _locationName!.isEmpty) {
              _locationName = '未知位置';
            }
          } else {
            _locationName = '未知位置';
          }
        } catch (e) {
          _locationName = '未知位置';
        }
      }, context: '获取位置信息');
    } catch (e) {
      _locationName = '获取位置失败';
    }
  }

  void dispose() {
    // 释放相机控制器
    _cameraController?.dispose();
    _cameraController = null;

    // 释放位置数据
    _position = null;
    _latitude = null;
    _longitude = null;
    _locationName = null;

    // 释放天气数据
    _weatherData = null;

    // 重置状态
    _isInitialized = false;
    _errorMessage = null;
  }
}
