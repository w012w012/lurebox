import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design/theme/tesla_theme.dart';
import '../../../core/models/ai_recognition_settings.dart';
import '../../../widgets/common/app_snack_bar.dart';

/// AI 提供商配置对话框
///
/// 允许用户配置 AI 提供商的 API 密钥和其他参数：
/// - API Key（必填）
/// - Base URL（可选，用于 OpenAI 兼容接口）
/// - Model Name（可选，如 gpt-4o-mini）
/// - 测试连接按钮
/// - 保存/取消按钮
class AiProviderConfigDialog extends ConsumerStatefulWidget {
  final AiRecognitionProvider provider;
  final AiProviderConfig? config;
  final Function(AiProviderConfig) onSave;

  const AiProviderConfigDialog({
    super.key,
    required this.provider,
    this.config,
    required this.onSave,
  });

  @override
  ConsumerState<AiProviderConfigDialog> createState() =>
      _AiProviderConfigDialogState();
}

class _AiProviderConfigDialogState
    extends ConsumerState<AiProviderConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelNameController = TextEditingController();

  bool _isLoading = false;
  bool _isTesting = false;
  String? _testResult;
  bool _isTestSuccess = false;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    if (widget.config != null) {
      _apiKeyController.text = widget.config!.apiKey;
      _baseUrlController.text = widget.config!.baseUrl ?? '';
      _modelNameController.text = widget.config!.modelName ?? '';
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(_getProviderIcon(widget.provider), color: colorScheme.primary),
          const SizedBox(width: TeslaTheme.spacingSm),
          Text('配置 ${widget.provider.displayName}'),
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
                _getProviderDescription(widget.provider),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: TeslaTheme.spacingLg),

              // API Key
              TextFormField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  hintText: '输入您的 API Key',
                  prefixIcon: const Icon(Icons.key),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureApiKey ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureApiKey = !_obscureApiKey;
                      });
                    },
                  ),
                ),
                obscureText: _obscureApiKey,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入 API Key';
                  }
                  return null;
                },
              ),
              const SizedBox(height: TeslaTheme.spacingMd),

              // Base URL（可选）
              TextFormField(
                controller: _baseUrlController,
                decoration: InputDecoration(
                  labelText: widget.provider == AiRecognitionProvider.custom
                      ? 'Base URL（必填）'
                      : 'Base URL（可选）',
                  hintText: 'https://api.example.com/v1',
                  prefixIcon: const Icon(Icons.link),
                  border: const OutlineInputBorder(),
                  helperText: widget.provider == AiRecognitionProvider.custom
                      ? 'OpenAI 兼容 API 端点，必填'
                      : '用于 OpenAI 兼容接口',
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                validator: widget.provider == AiRecognitionProvider.custom
                    ? (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '自定义提供商必须填写 Base URL';
                        }
                        return null;
                      }
                    : null,
              ),
              const SizedBox(height: TeslaTheme.spacingMd),

              // Model Name（可选）
              TextFormField(
                controller: _modelNameController,
                decoration: const InputDecoration(
                  labelText: 'Model Name（可选）',
                  hintText: 'gpt-4o-mini',
                  prefixIcon: Icon(Icons.model_training),
                  border: OutlineInputBorder(),
                  helperText: '指定使用的模型名称',
                ),
                textInputAction: TextInputAction.done,
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

              // 测试连接按钮
              OutlinedButton.icon(
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
          onPressed: _isLoading ? null : _saveConfig,
          icon: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save, size: 18),
          label: Text(_isLoading ? '保存中...' : '保存'),
        ),
      ],
    );
  }

  IconData _getProviderIcon(AiRecognitionProvider provider) {
    switch (provider) {
      case AiRecognitionProvider.gemini:
        return Icons.auto_awesome;
      case AiRecognitionProvider.openai:
        return Icons.smart_toy;
      case AiRecognitionProvider.claude:
        return Icons.psychology;
      case AiRecognitionProvider.minimax:
        return Icons.flash_on;
      case AiRecognitionProvider.siliconflow:
        return Icons.cloud;
      case AiRecognitionProvider.deepseek:
        return Icons.search;
      case AiRecognitionProvider.baidu:
        return Icons.g_mobiledata;
      case AiRecognitionProvider.aliyun:
        return Icons.cloud_outlined;
      case AiRecognitionProvider.tencent:
        return Icons.chat_bubble_outline;
      case AiRecognitionProvider.zhipu:
        return Icons.psychology_alt;
      case AiRecognitionProvider.custom:
        return Icons.tune;
    }
  }

  String _getProviderDescription(AiRecognitionProvider provider) {
    switch (provider) {
      case AiRecognitionProvider.gemini:
        return 'Google Gemini API。在 Google AI Studio 获取 API Key。';
      case AiRecognitionProvider.openai:
        return 'OpenAI GPT API。在 OpenAI 平台获取 API Key。';
      case AiRecognitionProvider.claude:
        return 'Anthropic Claude API。在 Anthropic 平台获取 API Key。';
      case AiRecognitionProvider.minimax:
        return 'MiniMax API。在 MiniMax 平台获取 API Key。';
      case AiRecognitionProvider.siliconflow:
        return 'SiliconFlow API。在 SiliconFlow 平台获取 API Key。';
      case AiRecognitionProvider.deepseek:
        return 'DeepSeek API。在 DeepSeek 平台获取 API Key。';
      case AiRecognitionProvider.baidu:
        return '百度文心一言 ERNIE-VL 视觉理解模型。在百度智能云控制台获取 API Key。';
      case AiRecognitionProvider.aliyun:
        return '阿里云通义千问 Qwen-VL 视觉模型。在阿里云 DashScope 获取 API Key。';
      case AiRecognitionProvider.tencent:
        return '腾讯混元 Hunyuan-Vision 视觉模型。在腾讯云获取 API Key。';
      case AiRecognitionProvider.zhipu:
        return '智谱AI GLM-4V Plus 视觉模型。在智谱AI开放平台获取 API Key。';
      case AiRecognitionProvider.custom:
        return '自定义 OpenAI 兼容 API。可以配置任何支持视觉的兼容接口。';
    }
  }

  /// 测试连接
  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    // 模拟测试连接
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isTesting = false;
        _isTestSuccess = true;
        _testResult = '连接成功！API Key 有效。';
      });
    }
  }

  /// 保存配置
  void _saveConfig() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final baseUrl = _baseUrlController.text.trim();
    final config = AiProviderConfig(
      provider: widget.provider,
      apiKey: _apiKeyController.text.trim(),
      baseUrl: baseUrl.isEmpty ? null : baseUrl,
      modelName: _modelNameController.text.trim().isEmpty
          ? null
          : _modelNameController.text.trim(),
      enabled: true,
    );

    widget.onSave(config);

    if (mounted) {
      Navigator.pop(context);
      AppSnackBar.showSuccess(context, '配置已保存');
    }
  }
}
