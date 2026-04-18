import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/strings.dart';
import '../../../core/design/theme/tesla_theme.dart';
import '../../../core/di/di.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/settings_view_model.dart';
import '../../../core/services/backup_service.dart';
import '../../../widgets/common/app_snack_bar.dart';

/// WebDAV 配置对话框
///
/// 允许用户配置 WebDAV 服务器连接信息：
/// - 服务器 URL（如 https://dav.example.com）
/// - 用户名
/// - 密码
///
/// 支持测试连接和保存配置
class WebDAVConfigDialog extends ConsumerStatefulWidget {
  const WebDAVConfigDialog({super.key});

  @override
  ConsumerState<WebDAVConfigDialog> createState() => _WebDAVConfigDialogState();
}

class _WebDAVConfigDialogState extends ConsumerState<WebDAVConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isTesting = false;
  String? _testResult;
  bool _isTestSuccess = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(currentStringsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.cloud_sync, color: colorScheme.primary),
          const SizedBox(width: TeslaTheme.spacingSm),
          const Text('WebDAV 备份'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 说明文字
              Text(
                '配置 WebDAV 服务器，将备份上传到云端。支持 Nextcloud、OwnCloud 等 WebDAV 服务。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: TeslaTheme.spacingLg),

              // 服务器 URL
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: '服务器地址',
                  hintText: 'https://dav.example.com',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                  helperText: '支持 WebDAV 协议的 URL',
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入服务器地址';
                  }
                  if (!value.startsWith('http://') &&
                      !value.startsWith('https://')) {
                    return 'URL 必须以 http:// 或 https:// 开头';
                  }
                  return null;
                },
              ),
              const SizedBox(height: TeslaTheme.spacingMd),

              // 用户名
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '用户名',
                  hintText: 'your-username',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入用户名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: TeslaTheme.spacingMd),

              // 密码
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '密码',
                  hintText: 'your-password',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入密码';
                  }
                  return null;
                },
              ),
              const SizedBox(height: TeslaTheme.spacingLg),

              // 连接测试结果
              if (_testResult != null) ...[
                Container(
                  padding: const EdgeInsets.all(TeslaTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: _isTestSuccess
                        ? colorScheme.primaryContainer
                        : colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isTestSuccess ? Icons.check_circle : Icons.error,
                        color: _isTestSuccess
                            ? colorScheme.primary
                            : colorScheme.error,
                      ),
                      const SizedBox(width: TeslaTheme.spacingSm),
                      Expanded(
                        child: Text(
                          _testResult!,
                          style: TextStyle(
                            color: _isTestSuccess
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TeslaTheme.spacingMd),
              ],

              // 按钮行
              Row(
                children: [
                  // 测试连接按钮
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isTesting ? null : _testConnection,
                      icon: _isTesting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.network_check),
                      label: const Text('测试连接'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton.icon(
          onPressed: _isLoading ? null : () => _uploadToWebDAV(strings),
          icon: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.cloud_upload, size: 18),
          label: Text(_isLoading ? '上传中...' : '立即备份'),
        ),
      ],
    );
  }

  /// 测试 WebDAV 连接
  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final backupService = BackupService(
        ref.read(databaseProvider),
      );

      final success = await backupService.testWebDAVConnection(
        serverUrl: _urlController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        setState(() {
          _isTesting = false;
          _isTestSuccess = success;
          _testResult =
              success ? '连接成功！可以正常访问 WebDAV 服务器。' : '连接失败。请检查服务器地址、用户名和密码是否正确。';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTesting = false;
          _isTestSuccess = false;
          _testResult = '测试失败: $e';
        });
      }
    }
  }

  /// 上传到 WebDAV
  Future<void> _uploadToWebDAV(AppStrings strings) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final viewModel = ref.read(settingsViewModelProvider.notifier);

    try {
      final url = await viewModel.uploadToWebDAV(
        serverUrl: _urlController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (url != null) {
        Navigator.pop(context);
        AppSnackBar.showSuccess(context, '备份已上传到云端');
      } else {
        setState(() {
          _isLoading = false;
          _isTestSuccess = false;
          _testResult = '上传失败。请检查配置并重试。';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isTestSuccess = false;
          _testResult = '上传失败: $e';
        });
      }
    }
  }
}
