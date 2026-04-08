import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

/// 权限请求结果
class PermissionResult {
  final bool granted;
  final bool permanentlyDenied;
  final String? errorMessage;

  PermissionResult({
    required this.granted,
    required this.permanentlyDenied,
    this.errorMessage,
  });
}

/// 权限类型信息
class PermissionInfo {
  final Permission permission;
  final String title;
  final String description;
  final String benefit;
  final IconData icon;

  const PermissionInfo({
    required this.permission,
    required this.title,
    required this.description,
    required this.benefit,
    required this.icon,
  });
}

/// 权限服务 - 统一处理权限请求和用户引导
class PermissionService {
  static final PermissionService _instance = PermissionService._();
  factory PermissionService() => _instance;
  PermissionService._();

  /// 相机权限信息
  static const cameraInfo = PermissionInfo(
    permission: Permission.camera,
    title: '相机权限',
    description: 'LureBox 需要使用相机来拍摄您的渔获照片',
    benefit: '记录每次出钓的精彩瞬间',
    icon: Icons.camera_alt,
  );

  /// 位置权限信息
  static const locationInfo = PermissionInfo(
    permission: Permission.locationWhenInUse,
    title: '位置权限',
    description: 'LureBox 需要获取您的位置信息来记录钓点',
    benefit: '自动记录钓鱼地点，方便回顾和分享',
    icon: Icons.location_on,
  );

  /// 照片库权限信息
  static const photosInfo = PermissionInfo(
    permission: Permission.photos,
    title: '照片库权限',
    description: '允许访问您的照片库来保存和选择渔获照片',
    benefit: '将渔获照片保存到相册，或从相册选择照片',
    icon: Icons.photo_library,
  );

  /// 请求相机权限（带教育引导）
  Future<PermissionResult> requestCameraPermission(BuildContext context) async {
    return _requestPermissionWithEducation(context, cameraInfo);
  }

  /// 请求位置权限（带教育引导）
  Future<PermissionResult> requestLocationPermission(
      BuildContext context) async {
    // 先检查位置服务是否开启
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return PermissionResult(
        granted: false,
        permanentlyDenied: false,
        errorMessage: '请开启设备定位服务',
      );
    }

    // 检查 context 是否仍然有效（防止在异步操作后使用已卸载的 context）
    if (!context.mounted) {
      return PermissionResult(
        granted: false,
        permanentlyDenied: false,
        errorMessage: '上下文已失效',
      );
    }

    return _requestPermissionWithEducation(context, locationInfo);
  }

  /// 请求照片库权限（带教育引导）
  Future<PermissionResult> requestPhotosPermission(BuildContext context) async {
    return _requestPermissionWithEducation(context, photosInfo);
  }

  /// 通用权限请求流程（带教育引导）
  Future<PermissionResult> _requestPermissionWithEducation(
    BuildContext context,
    PermissionInfo info,
  ) async {
    final status = await info.permission.status;

    // 已授权
    if (status.isGranted || status.isLimited) {
      return PermissionResult(granted: true, permanentlyDenied: false);
    }

    // 永久拒绝 - 引导到设置
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showSettingsDialog(context, info);
      }
      return PermissionResult(
        granted: false,
        permanentlyDenied: true,
        errorMessage: '${info.title}已被永久拒绝，请在系统设置中开启',
      );
    }

    // 首次或已拒绝 - 显示教育引导后请求
    if (context.mounted) {
      final shouldRequest = await _showEducationDialog(context, info);
      if (shouldRequest == true) {
        final newStatus = await info.permission.request();

        if (newStatus.isGranted || newStatus.isLimited) {
          return PermissionResult(granted: true, permanentlyDenied: false);
        }

        if (newStatus.isPermanentlyDenied && context.mounted) {
          await _showSettingsDialog(context, info);
          return PermissionResult(
            granted: false,
            permanentlyDenied: true,
            errorMessage: '${info.title}被拒绝，需要在系统设置中开启',
          );
        }
      }
    }

    return PermissionResult(
      granted: false,
      permanentlyDenied: false,
      errorMessage: '${info.title}被拒绝',
    );
  }

  /// 显示权限教育对话框
  Future<bool?> _showEducationDialog(
      BuildContext context, PermissionInfo info) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(info.icon, size: 48, color: Theme.of(context).primaryColor),
        title: Text('需要${info.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(info.description),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      info.benefit,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '我们不会收集或上传您的数据，所有信息都保存在本地设备上。',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('暂不授权'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('授权'),
          ),
        ],
      ),
    );
  }

  /// 显示引导到设置对话框
  Future<void> _showSettingsDialog(BuildContext context, PermissionInfo info) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('需要${info.title}'),
        content: Text(
          '您之前拒绝了${info.title}。\n\n请在系统设置中开启${info.title}，以使用相关功能。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('打开设置'),
          ),
        ],
      ),
    );
  }

  /// 检查权限状态
  Future<bool> isPermissionGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted || status.isLimited;
  }

  /// 检查权限是否永久拒绝
  Future<bool> isPermanentlyDenied(Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }

  /// 打开应用设置
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
