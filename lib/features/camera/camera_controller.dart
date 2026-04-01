import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/services/weather_service.dart';

/// 相机控制器，管理相机初始化、切换、拍照和位置获取
class CameraControllerHelper {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  int _currentCameraIndex = 0;
  bool _isInitialized = false;
  Position? _position;
  String? _locationName;
  String? _errorMessage;
  WeatherData? _weatherData;
  final WeatherService _weatherService = WeatherService();

  CameraController? get cameraController => _cameraController;
  List<CameraDescription>? get cameras => _cameras;
  bool get isInitialized => _isInitialized;
  Position? get position => _position;
  String? get locationName => _locationName;
  String? get errorMessage => _errorMessage;
  bool get canSwitchCamera => _cameras != null && _cameras!.length > 1;
  WeatherData? get weatherData => _weatherData;

  /// 初始化相机
  Future<bool> initCamera() async {
    try {
      // 检查权限
      var status = await Permission.camera.status;
      if (!status.isGranted) {
        status = await Permission.camera.request();
        if (!status.isGranted) {
          _errorMessage = '需要相机权限才能拍照';
          return false;
        }
      }

      // 获取可用相机
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        _errorMessage = '未找到可用的相机';
        return false;
      }

      // 初始化相机
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      _isInitialized = true;
      _errorMessage = null;
      return true;
    } catch (e) {
      debugPrint('相机初始化失败: $e');
      _errorMessage = '相机初始化失败: $e';
      return false;
    }
  }

  /// 切换摄像头
  Future<bool> switchCamera() async {
    if (!canSwitchCamera) return false;

    _isInitialized = false;
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;

    await _cameraController?.dispose();
    _cameraController = CameraController(
      _cameras![_currentCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('切换相机失败: $e');
      _errorMessage = '切换相机失败';
      return false;
    }
  }

  /// 拍照
  Future<String?> takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return null;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      return image.path;
    } catch (e) {
      debugPrint('拍照失败: $e');
      return null;
    }
  }

  /// 获取位置
  Future<void> getLocation() async {
    try {
      var status = await Permission.locationWhenInUse.status;
      if (!status.isGranted) {
        status = await Permission.locationWhenInUse.request();
        if (!status.isGranted) {
          _locationName = '位置权限未授权';
          return;
        }
      }

      if (status.isGranted) {
        try {
          _position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('定位超时');
            },
          );
        } catch (e) {
          debugPrint('GPS定位失败: $e');
          _locationName = '定位失败';
          return;
        }

        if (_position != null) {
          // 获取天气数据
          _weatherData = await _weatherService.getWeather(
            _position!.latitude,
            _position!.longitude,
          );

          try {
            final placemarks = await placemarkFromCoordinates(
              _position!.latitude,
              _position!.longitude,
            ).timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                throw Exception('地址解析超时');
              },
            );
            if (placemarks.isNotEmpty) {
              final place = placemarks[0];
              _locationName =
                  '${place.administrativeArea ?? ''}${place.locality ?? ''}${place.name ?? ''}';
              if (_locationName!.isEmpty) {
                _locationName = '未知位置';
              }
            }
          } catch (e) {
            debugPrint('地址解析失败: $e');
            _locationName = '未知位置';
          }
        }
      }
    } catch (e) {
      debugPrint('获取位置失败: $e');
      _locationName = '获取位置失败';
    }
  }

  /// 释放资源
  void dispose() {
    _cameraController?.dispose();
  }
}
