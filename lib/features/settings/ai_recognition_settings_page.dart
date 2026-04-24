import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/design/theme/tesla_theme.dart';
import '../../core/models/ai_recognition_settings.dart';
import '../../core/providers/ai_recognition_provider.dart';
import '../../core/providers/language_provider.dart';
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
    final strings = ref.watch(currentStringsProvider);
    final aiSettings = ref.watch(aiRecognitionSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.aiConfigTitle),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: TeslaTheme.spacingMd),
          // 当前提供商选择
          _buildCurrentProviderSection(strings, context, ref, aiSettings),
          const SizedBox(height: TeslaTheme.spacingLg),
          // 提供商列表
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TeslaTheme.spacingMd,
            ),
            child: Text(
              strings.aiProviderLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: TeslaTheme.spacingSm),
          ...AiRecognitionProvider.values.map(
            (provider) => _buildProviderCard(
              strings,
              context,
              ref,
              provider,
              aiSettings,
            ),
          ),
          const SizedBox(height: TeslaTheme.spacingXl),
        ],
      ),
    );
  }

  Widget _buildCurrentProviderSection(
    AppStrings strings,
    BuildContext context,
    WidgetRef ref,
    AiRecognitionSettings aiSettings,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TeslaTheme.spacingMd,
      ),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.aiCurrentProvider,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: TeslaTheme.spacingSm),
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
    AppStrings strings,
    BuildContext context,
    WidgetRef ref,
    AiRecognitionProvider provider,
    AiRecognitionSettings aiSettings,
  ) {
    final config = aiSettings.providerConfigs[provider];
    final isConfigured = config != null && config.apiKey.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TeslaTheme.spacingMd,
        vertical: TeslaTheme.spacingMicro,
      ),
      child: PremiumCard(
        onTap: () => _showConfigDialog(context, ref, provider, aiSettings),
        child: Row(
          children: [
            Icon(
              _getProviderIcon(provider),
              color: TeslaColors.electricBlue,
            ),
            const SizedBox(width: TeslaTheme.spacingMd),
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
                    isConfigured ? strings.aiConfigured : strings.aiNotConfigured,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isConfigured
                              ? TeslaColors.electricBlue
                              : isDark
                                  ? const Color(0xFF9A9A9A)
                                  : TeslaColors.graphite,
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
