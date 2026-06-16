import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:permission_handler/permission_handler.dart' as perm_handler;

/// 权限请求结果
class PermissionResult {
  const PermissionResult({
    required this.granted,
    required this.permanentlyDenied,
    this.errorMessage,
  });
  final bool granted;
  final bool permanentlyDenied;
  final String? errorMessage;
}

/// Abstracts the permission_handler and geolocator platform calls so
/// [PermissionService] can be tested without device permissions.
abstract class PermissionPlatform {
  const PermissionPlatform();

  Future<perm_handler.PermissionStatus> status(
      perm_handler.Permission permission,);
  Future<perm_handler.PermissionStatus> request(
      perm_handler.Permission permission,);
  Future<bool> isLocationServiceEnabled();
  Future<void> openAppSettings();

  static const PermissionPlatform real = _RealPermissionPlatform();
}

class _RealPermissionPlatform extends PermissionPlatform {
  const _RealPermissionPlatform();

  @override
  Future<perm_handler.PermissionStatus> status(
          perm_handler.Permission permission,) =>
      permission.status;

  @override
  Future<perm_handler.PermissionStatus> request(
          perm_handler.Permission permission,) =>
      permission.request();

  @override
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  @override
  Future<void> openAppSettings() => perm_handler.openAppSettings();
}

/// 权限类型，用于在对话框构建时解析对应的本地化文案
enum PermissionKind { camera, location, photos }

/// 权限类型信息
class PermissionInfo {
  const PermissionInfo({
    required this.kind,
    required this.permission,
    required this.title,
    required this.description,
    required this.benefit,
    required this.icon,
  });
  final PermissionKind kind;
  final perm_handler.Permission permission;

  /// 中文兜底文案（当未传入 [AppStrings] 时使用，保证中文行为不变）
  final String title;
  final String description;
  final String benefit;
  final IconData icon;

  /// 解析本地化标题；无 [strings] 时回退到中文兜底
  String localizedTitle(AppStrings? strings) => switch (kind) {
        PermissionKind.camera => strings?.permissionCameraTitle ?? title,
        PermissionKind.location => strings?.permissionLocationTitle ?? title,
        PermissionKind.photos => strings?.permissionPhotosTitle ?? title,
      };

  /// 解析本地化描述；无 [strings] 时回退到中文兜底
  String localizedDescription(AppStrings? strings) => switch (kind) {
        PermissionKind.camera => strings?.permissionCameraDesc ?? description,
        PermissionKind.location =>
          strings?.permissionLocationDesc ?? description,
        PermissionKind.photos => strings?.permissionPhotosDesc ?? description,
      };

  /// 解析本地化收益说明；无 [strings] 时回退到中文兜底
  String localizedBenefit(AppStrings? strings) => switch (kind) {
        PermissionKind.camera => strings?.permissionCameraBenefit ?? benefit,
        PermissionKind.location =>
          strings?.permissionLocationBenefit ?? benefit,
        PermissionKind.photos => strings?.permissionPhotosBenefit ?? benefit,
      };
}

/// 权限服务 - 统一处理权限请求和用户引导
class PermissionService {
  factory PermissionService() => _instance;
  PermissionService._([PermissionPlatform? platform])
      : _platform = platform ?? PermissionPlatform.real;
  static final PermissionService _instance = PermissionService._();

  PermissionPlatform _platform;

  /// Allows test files in this package to inject a mock [PermissionPlatform].
  /// Not called by production code.
  // ignore: unused_element
  void setPlatformForTesting(PermissionPlatform platform) {
    _platform = platform;
  }

  /// 相机权限信息
  static const cameraInfo = PermissionInfo(
    kind: PermissionKind.camera,
    permission: perm_handler.Permission.camera,
    title: '相机权限',
    description: 'LureBox 需要使用相机来拍摄您的渔获照片',
    benefit: '记录每次出钓的精彩瞬间',
    icon: Icons.camera_alt,
  );

  /// 位置权限信息
  static const locationInfo = PermissionInfo(
    kind: PermissionKind.location,
    permission: perm_handler.Permission.locationWhenInUse,
    title: '位置权限',
    description: 'LureBox 需要获取您的位置信息来记录钓点',
    benefit: '自动记录钓鱼地点，方便回顾和分享',
    icon: Icons.location_on,
  );

  /// 照片库权限信息
  static const photosInfo = PermissionInfo(
    kind: PermissionKind.photos,
    permission: perm_handler.Permission.photos,
    title: '照片库权限',
    description: '允许访问您的照片库来保存和选择渔获照片',
    benefit: '将渔获照片保存到相册，或从相册选择照片',
    icon: Icons.photo_library,
  );

  /// 请求相机权限（带教育引导）
  Future<PermissionResult> requestCameraPermission(
    BuildContext context, {
    AppStrings? strings,
  }) async {
    return _requestPermissionWithEducation(context, cameraInfo,
        strings: strings,);
  }

  /// 请求位置权限（带教育引导）
  Future<PermissionResult> requestLocationPermission(
    BuildContext context, {
    AppStrings? strings,
  }) async {
    // 先检查位置服务是否开启
    final serviceEnabled = await _platform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return PermissionResult(
        granted: false,
        permanentlyDenied: false,
        errorMessage: strings?.errorDeviceLocationOff ?? '请开启设备定位服务',
      );
    }

    // 检查 context 是否仍然有效（防止在异步操作后使用已卸载的 context）
    if (!context.mounted) {
      return PermissionResult(
        granted: false,
        permanentlyDenied: false,
        errorMessage: strings?.errorContextInvalid ?? '上下文已失效',
      );
    }

    return _requestPermissionWithEducation(context, locationInfo,
        strings: strings,);
  }

  /// 请求照片库权限（带教育引导）
  Future<PermissionResult> requestPhotosPermission(
    BuildContext context, {
    AppStrings? strings,
  }) async {
    return _requestPermissionWithEducation(context, photosInfo,
        strings: strings,);
  }

  /// 通用权限请求流程（带教育引导）
  Future<PermissionResult> _requestPermissionWithEducation(
    BuildContext context,
    PermissionInfo info, {
    AppStrings? strings,
  }) async {
    final status = await _platform.status(info.permission);

    // 已授权
    if (status.isGranted || status.isLimited) {
      return const PermissionResult(granted: true, permanentlyDenied: false);
    }

    // 永久拒绝 - 引导到设置
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showSettingsDialog(context, info, strings: strings);
      }
      return PermissionResult(
        granted: false,
        permanentlyDenied: true,
        errorMessage: strings?.errorPermanentlyDenied ??
            '${info.localizedTitle(strings)}已被永久拒绝，请在系统设置中开启',
      );
    }

    // 首次或已拒绝 - 显示教育引导后请求
    if (context.mounted) {
      final shouldRequest =
          await _showEducationDialog(context, info, strings: strings);
      if (shouldRequest ?? false) {
        final newStatus = await _platform.request(info.permission);

        if (newStatus.isGranted || newStatus.isLimited) {
          return const PermissionResult(
              granted: true, permanentlyDenied: false,);
        }

        if (newStatus.isPermanentlyDenied && context.mounted) {
          await _showSettingsDialog(context, info, strings: strings);
          return PermissionResult(
            granted: false,
            permanentlyDenied: true,
            errorMessage: strings?.errorPermanentlyDenied ??
                '${info.localizedTitle(strings)}被拒绝，需要在系统设置中开启',
          );
        }
      }
    }

    return PermissionResult(
      granted: false,
      permanentlyDenied: false,
      errorMessage:
          strings?.errorDenied ?? '${info.localizedTitle(strings)}被拒绝',
    );
  }

  /// 显示权限教育对话框
  Future<bool?> _showEducationDialog(
    BuildContext context,
    PermissionInfo info, {
    AppStrings? strings,
  }) {
    final localizedTitle = info.localizedTitle(strings);
    final dialogTitle = strings != null
        ? strings.permissionRequiredTitle.replaceFirst('%s', localizedTitle)
        : '需要$localizedTitle';
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(info.icon, size: 48, color: Theme.of(context).primaryColor),
        title: Text(dialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(info.localizedDescription(strings)),
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
                      info.localizedBenefit(strings),
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
              strings?.privacyNote ?? '我们不会收集或上传您的数据，所有信息都保存在本地设备上。',
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
            child: Text(strings?.permissionGrantLater ?? '暂不授权'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings?.permissionGrant ?? '授权'),
          ),
        ],
      ),
    );
  }

  /// 显示引导到设置对话框
  Future<void> _showSettingsDialog(BuildContext context, PermissionInfo info,
      {AppStrings? strings,}) {
    final localizedTitle = info.localizedTitle(strings);
    final dialogTitle = strings != null
        ? strings.permissionRequiredTitle.replaceFirst('%s', localizedTitle)
        : '需要$localizedTitle';
    final body = strings != null
        ? strings.permissionSettingsBody.replaceAll('%s', localizedTitle)
        : '您之前拒绝了$localizedTitle。\n\n请在系统设置中开启$localizedTitle，以使用相关功能。';
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dialogTitle),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings?.cancel ?? '取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _platform.openAppSettings();
            },
            child: Text(strings?.permissionOpenSettings ?? '打开设置'),
          ),
        ],
      ),
    );
  }

  /// 检查权限状态
  Future<bool> isPermissionGranted(perm_handler.Permission permission) async {
    final status = await _platform.status(permission);
    return status.isGranted || status.isLimited;
  }

  /// 检查权限是否永久拒绝
  Future<bool> isPermanentlyDenied(perm_handler.Permission permission) async {
    final status = await _platform.status(permission);
    return status.isPermanentlyDenied;
  }

  /// 打开应用设置
  Future<void> openSettings() async {
    await _platform.openAppSettings();
  }
}
