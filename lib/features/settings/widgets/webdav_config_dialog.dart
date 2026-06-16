import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/providers/data_refresh.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/providers/settings_view_model.dart';
import 'package:lurebox/widgets/common/app_snack_bar.dart';

/// WebDAV 配置对话框
///
/// 允许用户配置 WebDAV 服务器连接信息：
/// - 服务器 URL（如 https://dav.example.com）
/// - 用户名
/// - 密码
///
/// 支持测试连接、保存配置、上传备份与从云端恢复。
/// 打开时自动回填已保存的活跃配置；测试连接或上传成功后自动持久化，
/// 用户无需每次重新输入凭据。
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
  bool _isRestoring = false;
  String? _testResult;
  bool _isTestSuccess = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _prefillFromSavedConfig();
  }

  /// 打开对话框时回填已保存的活跃 WebDAV 配置。
  Future<void> _prefillFromSavedConfig() async {
    final config =
        await ref.read(enhancedBackupServiceProvider).getActiveWebDAVConfig();
    if (!mounted || config == null) return;
    setState(() {
      _urlController.text = config.serverUrl;
      _usernameController.text = config.username;
      _passwordController.text = config.password;
    });
  }

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
          Text(strings.webdavTitle),
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
                decoration: InputDecoration(
                  labelText: strings.serverAddress,
                  hintText: 'https://dav.example.com',
                  prefixIcon: const Icon(Icons.link),
                  border: const OutlineInputBorder(),
                  helperText: strings.webdavSupportedUrl,
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return strings.webdavPleaseEnterAddress;
                  }
                  if (!value.startsWith('https://')) {
                    return strings.webdavUrlMustStartHttp;
                  }
                  return null;
                },
              ),
              const SizedBox(height: TeslaTheme.spacingMd),

              // 用户名
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: strings.username,
                  hintText: 'your-username',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return strings.webdavPleaseEnterUsername;
                  }
                  return null;
                },
              ),
              const SizedBox(height: TeslaTheme.spacingMd),

              // 密码
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: strings.password,
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
                    tooltip: 'Show/hide password',
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return strings.webdavPleaseEnterPassword;
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

              // 按钮行：测试连接 + 从云端恢复
              Row(
                children: [
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
                      label: Text(strings.aiTestConnection),
                    ),
                  ),
                  const SizedBox(width: TeslaTheme.spacingSm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isRestoring ? null : _restoreFromCloud,
                      icon: _isRestoring
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_download),
                      label: const Text('从云端恢复'),
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
          child: Text(strings.cancel),
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
          label:
              Text(_isLoading ? strings.uploadingToCloud : strings.backupNow),
        ),
      ],
    );
  }

  /// 持久化当前表单中的 WebDAV 配置（密码写入安全存储，不入日志）。
  Future<void> _saveConfig() async {
    await ref.read(enhancedBackupServiceProvider).saveWebDAVConfig(
          serverUrl: _urlController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );
  }

  /// 测试 WebDAV 连接（成功则顺带持久化配置，便于下次免输）。
  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final backupService = ref.read(backupServiceProvider);

      final success = await backupService.testWebDAVConnection(
        serverUrl: _urlController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      // 连接成功即保存配置 —— 关键的可用性收益：用户测通后即被记住。
      if (success) {
        await _saveConfig();
      }

      if (mounted) {
        setState(() {
          _isTesting = false;
          _isTestSuccess = success;
          _testResult = success ? '连接成功！配置已保存。' : '连接失败。请检查服务器地址、用户名和密码是否正确。';
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _isTesting = false;
          _isTestSuccess = false;
          _testResult = '测试失败: $e';
        });
      }
    }
  }

  /// 上传到 WebDAV（成功后持久化配置并关闭对话框）。
  Future<void> _uploadToWebDAV(AppStrings strings) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final viewModel = ref.read(settingsViewModelProvider.notifier);
    // 弹窗 pop 后其 context 失效，提前捕获 messenger 以安全显示提示。
    final messenger = ScaffoldMessenger.of(context);

    try {
      final url = await viewModel.uploadToWebDAV(
        serverUrl: _urlController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (url != null) {
        // 上传成功也持久化配置（下次免输）。
        await _saveConfig();
        if (!mounted) return;
        Navigator.pop(context);
        AppSnackBar.showSuccessWith(messenger, strings.backupUploaded);
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _isTestSuccess = false;
          _testResult = '上传失败。请检查配置并重试。';
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isTestSuccess = false;
          _testResult = '上传失败: $e';
        });
      }
    }
  }

  /// 从 WebDAV 下载最新备份并恢复（成功后失效派生数据）。
  Future<void> _restoreFromCloud() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final strings = ref.read(currentStringsProvider);

    // 恢复会覆盖/合并本地数据，先确认。
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.restoreTitle),
        content: Text(strings.restoreOverwriteWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(strings.continueAction),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 先持久化配置，确保 restoreFromCloud 用到的活跃配置就是当前表单。
    await _saveConfig();

    if (!mounted) return;
    setState(() {
      _isRestoring = true;
    });

    final messenger = ScaffoldMessenger.of(context);

    try {
      final result =
          await ref.read(enhancedBackupServiceProvider).restoreFromCloud();

      if (!mounted) return;
      setState(() {
        _isRestoring = false;
      });

      if (result.isSuccess) {
        // 恢复成功后失效所有派生数据，避免界面继续显示恢复前的旧值。
        invalidateDerivedFishData(ref.invalidate);
        final stats = result.stats;
        final detail = stats == null
            ? ''
            : '（新增 ${stats.importedCount}，跳过 ${stats.skippedCount}）';
        Navigator.pop(context);
        AppSnackBar.showSuccessWith(
          messenger,
          '${strings.restoreSuccessMsg}$detail',
        );
      } else {
        setState(() {
          _isTestSuccess = false;
          _testResult = result.errorMessage ?? strings.restoreFailedMsg;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _isRestoring = false;
          _isTestSuccess = false;
          _testResult = '${strings.restoreFailedMsg}: $e';
        });
      }
    }
  }
}
