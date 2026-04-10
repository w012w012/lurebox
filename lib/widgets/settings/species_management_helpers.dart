import 'package:flutter/material.dart';
import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/app_theme.dart';
import '../../../core/models/fish_catch.dart';
import 'pending_queue_widget.dart';

/// 品种管理页面辅助对话框
///
/// 提供重命名、删除、确认等对话框的静态构建方法
class SpeciesManagementDialogs {
  /// 显示手动识别对话框
  ///
  /// 返回用户输入的品种名称，如果取消则返回 null
  static Future<String?> showManualIdentifyDialog(
    BuildContext context,
    FishCatch fish,
  ) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('手动识别'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('为以下鱼获指定品种：'),
            Text(
              '${fish.catchTime.year}-${fish.catchTime.month.toString().padLeft(2, '0')}-${fish.catchTime.day.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '品种名称',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (confirmed == true) {
      return controller.text.trim();
    }
    return null;
  }

  /// 显示确认识别结果对话框
  ///
  /// 返回用户确认的品种名称（可能已修改），如果取消则返回 null
  static Future<String?> showConfirmRecognitionDialog(
    BuildContext context,
    AiRecognitionOption option,
  ) async {
    final controller = TextEditingController(text: option.speciesName);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认品种'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI 识别结果：${option.speciesName}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              '置信度：${(option.confidence * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '品种名称（可修改）',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = controller.text.trim();
      controller.dispose();
      return result.isNotEmpty ? result : null;
    }

    controller.dispose();
    return null;
  }

  /// 显示重命名品种对话框
  ///
  /// 返回用户输入的新名称，如果取消则返回 null
  static Future<String?> showRenameDialog(
    BuildContext context,
    String oldName,
  ) async {
    final controller = TextEditingController(text: oldName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名品种'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '新名称',
            hintText: '输入新物种名称',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != oldName) {
                Navigator.pop(context, newName);
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }

  /// 显示删除品种确认对话框
  ///
  /// 返回用户是否确认删除
  static Future<bool> showDeleteDialog(
    BuildContext context,
    String speciesName,
    int count,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text(
          '确定要删除品种 "$speciesName" 吗？\n\n这将同时删除 $count 条渔获记录，此操作不可恢复！',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );

    return confirmed == true;
  }
}
