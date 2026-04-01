import 'package:flutter/material.dart';

import '../../core/design/theme/app_colors.dart';

class FishActionButtons extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final bool isDeleting;
  final bool isSharing;

  const FishActionButtons({
    super.key,
    this.onEdit,
    this.onDelete,
    this.onShare,
    this.isDeleting = false,
    this.isSharing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(icon: Icons.edit, label: '编辑', onPressed: onEdit),
        _ActionButton(
          icon: Icons.share,
          label: '分享',
          onPressed: isSharing ? null : onShare,
          isLoading: isSharing,
        ),
        _ActionButton(
          icon: Icons.delete_outline,
          label: '删除',
          onPressed: isDeleting ? null : onDelete,
          isLoading: isDeleting,
          isDestructive: true,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : null;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : Icon(icon,
                    color: onPressed != null ? color : AppColors.grey500),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: onPressed != null ? color : AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
