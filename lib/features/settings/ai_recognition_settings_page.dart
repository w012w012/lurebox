import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/theme/app_colors.dart';
import '../../core/models/ai_recognition_settings.dart';
import '../../core/providers/ai_recognition_provider.dart';
import '../../widgets/common/premium_card.dart';
import 'widgets/ai_provider_config_dialog.dart';

/// AI 品种识别设置页面
///
/// 显示 6 个 AI 提供商的配置状态，允许用户：
/// - 查看每个提供商的 API Key 配置状态
/// - 配置单个提供商的 API Key
/// - 选择当前使用的 AI 提供商
/// - 开关自动识别功能
class AiRecognitionSettingsPage extends ConsumerWidget {
  const AiRecognitionSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiSettings = ref.watch(aiRecognitionSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 配置'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // 当前提供商选择
          _buildCurrentProviderSection(context, ref, aiSettings, isDark),
          const SizedBox(height: 24),
          // 提供商列表
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'AI 提供商',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          ...AiRecognitionProvider.values.map(
            (provider) => _buildProviderCard(
              context,
              ref,
              provider,
              aiSettings,
              isDark,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCurrentProviderSection(
    BuildContext context,
    WidgetRef ref,
    AiRecognitionSettings aiSettings,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '当前使用的 AI 提供商',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<AiRecognitionProvider>(
              value: aiSettings.currentProvider,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: AiRecognitionProvider.values.map((provider) {
                return DropdownMenuItem(
                  value: provider,
                  child: Text(provider.displayName),
                );
              }).toList(),
              onChanged: (provider) {
                if (provider != null) {
                  ref
                      .read(aiRecognitionSettingsProvider.notifier)
                      .updateProvider(provider);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard(
    BuildContext context,
    WidgetRef ref,
    AiRecognitionProvider provider,
    AiRecognitionSettings aiSettings,
    bool isDark,
  ) {
    final config = aiSettings.providerConfigs[provider];
    final isConfigured = config != null && config.apiKey.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: PremiumCard(
        onTap: () => _showConfigDialog(context, ref, provider, aiSettings),
        child: Row(
          children: [
            Icon(
              _getProviderIcon(provider),
              color: isDark ? AppColors.accentDark : AppColors.accentLight,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.displayName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isConfigured ? '已配置' : '未配置',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isConfigured
                              ? AppColors.success
                              : isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  IconData _getProviderIcon(AiRecognitionProvider provider) {
    switch (provider) {
      case AiRecognitionProvider.gemini:
        return Icons.psychology;
      case AiRecognitionProvider.openai:
        return Icons.smart_toy;
      case AiRecognitionProvider.claude:
        return Icons.smart_toy_outlined;
      case AiRecognitionProvider.minimax:
        return Icons.bolt;
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

  void _showConfigDialog(
    BuildContext context,
    WidgetRef ref,
    AiRecognitionProvider provider,
    AiRecognitionSettings aiSettings,
  ) {
    final config = aiSettings.providerConfigs[provider];
    showDialog(
      context: context,
      builder: (context) => AiProviderConfigDialog(
        provider: provider,
        config: config,
        onSave: (newConfig) {
          final newConfigs = Map<AiRecognitionProvider, AiProviderConfig>.from(
            aiSettings.providerConfigs,
          );
          newConfigs[provider] = newConfig;
          ref.read(aiRecognitionSettingsProvider.notifier).updateSettings(
                aiSettings.copyWith(providerConfigs: newConfigs),
              );
        },
      ),
    );
  }
}
