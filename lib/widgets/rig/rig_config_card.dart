import 'package:flutter/material.dart';

import '../../core/design/theme/app_colors.dart';
import '../../core/models/rig_config.dart';

/// 钓组配置卡片 - 可展开的钓组/鱼钩配置区域
///
/// 用于记录渔获时配置钓组搭配，包括：
/// - 钓组类型（预选+自定义）
/// - 插铅重量
/// - 插铅位置
/// - 鱼钩种类（预选+自定义）
/// - 钩号
/// - 鱼钩重量
class RigConfigCard extends StatefulWidget {
  final RigConfig config;
  final ValueChanged<RigConfig> onChanged;
  final bool initiallyExpanded;

  const RigConfigCard({
    super.key,
    required this.config,
    required this.onChanged,
    this.initiallyExpanded = false,
  });

  @override
  State<RigConfigCard> createState() => _RigConfigCardState();
}

class _RigConfigCardState extends State<RigConfigCard> {
  bool _isExpanded = false;
  final _sinkerWeightController = TextEditingController();
  final _freeSinkerWeightController = TextEditingController();
  final _hookWeightController = TextEditingController();
  final _rigTypeController = TextEditingController();
  final _hookTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _initializeValues();
  }

  @override
  void didUpdateWidget(RigConfigCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      _initializeValues();
    }
  }

  void _initializeValues() {
    _sinkerWeightController.text = widget.config.sinkerWeight ?? '';
    _freeSinkerWeightController.text = widget.config.freeSinkerWeight ?? '';
    _hookWeightController.text = widget.config.hookWeight ?? '';
    _rigTypeController.text = widget.config.rigType ?? '';
    _hookTypeController.text = widget.config.hookType ?? '';
  }

  @override
  void dispose() {
    _sinkerWeightController.dispose();
    _freeSinkerWeightController.dispose();
    _hookWeightController.dispose();
    _rigTypeController.dispose();
    _hookTypeController.dispose();
    super.dispose();
  }

  void _updateConfig(RigConfig newConfig) {
    widget.onChanged(newConfig);
  }

  String _getSummaryText() {
    final parts = <String>[];
    if (widget.config.rigType != null) parts.add(widget.config.rigType!);
    if (widget.config.hookType != null) parts.add(widget.config.hookType!);
    if (widget.config.hookSize != null) parts.add(widget.config.hookSize!);
    if (parts.isEmpty) return '配置钓组';
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
          },
          leading: Icon(
            Icons.settings_suggest,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            '钓组及鱼钩',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: !_isExpanded && widget.config.isNotEmpty
              ? Text(
                  _getSummaryText(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                )
              : _isExpanded
                  ? Text(
                      '仅软饵配置，非必填',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    )
                  : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.config.isNotEmpty)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 18,
                ),
              const SizedBox(width: 4),
              Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('钓组类型', Icons.landscape),
                  _buildRigTypeSelector(),
                  const SizedBox(height: 16),
                  _buildSectionTitle('插铅配置', Icons.circle),
                  _buildSinkerSection(),
                  const SizedBox(height: 16),
                  _buildFreeSinkerSection(),
                  const SizedBox(height: 16),
                  _buildSectionTitle('鱼钩配置', Icons.bolt),
                  _buildHookSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.secondaryLight),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRigTypeSelector() {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: widget.config.rigType ?? ''),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return RigType.presets;
        }
        return RigType.presets.where((option) =>
            option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        // Sync controller with initial value only on first build
        if (controller.text.isEmpty && widget.config.rigType != null) {
          controller.text = widget.config.rigType!;
        }
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: '钓组类型',
            hintText: '选择或输入',
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty && !RigType.presets.contains(value)) {
              _updateConfig(widget.config.copyWith(rigType: value));
            }
          },
        );
      },
      onSelected: (String selection) {
        _updateConfig(widget.config.copyWith(rigType: selection));
      },
    );
  }

  Widget _buildSinkerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: _sinkerWeightController,
                decoration: const InputDecoration(
                  labelText: '重量',
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  _updateConfig(widget.config.copyWith(
                    sinkerWeight: value.isNotEmpty ? value : null,
                  ));
                },
              ),
            ),
            const SizedBox(width: 4),
            const Text('g', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 12),
            Expanded(child: _buildSinkerPositionDropdown()),
          ],
        ),
      ],
    );
  }

  Widget _buildSinkerPositionDropdown() {
    return DropdownButtonFormField<String>(
      value: widget.config.sinkerPosition,
      decoration: const InputDecoration(
        labelText: '位置',
        isDense: true,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: SinkerPosition.presets
          .map((pos) => DropdownMenuItem(
              value: pos,
              child: Text(pos, style: const TextStyle(fontSize: 14))))
          .toList(),
      onChanged: (value) {
        _updateConfig(widget.config.copyWith(sinkerPosition: value));
      },
    );
  }

  Widget _buildFreeSinkerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('自由铅设置',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: _freeSinkerWeightController,
                decoration: const InputDecoration(
                  labelText: '重量',
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  _updateConfig(widget.config.copyWith(
                    freeSinkerWeight: value.isNotEmpty ? value : null,
                  ));
                },
              ),
            ),
            const SizedBox(width: 4),
            const Text('g', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 12),
            Expanded(child: _buildFreeSinkerShapeDropdown()),
          ],
        ),
      ],
    );
  }

  Widget _buildFreeSinkerShapeDropdown() {
    return DropdownButtonFormField<String>(
      value: widget.config.freeSinkerShape,
      decoration: const InputDecoration(
        labelText: '形状',
        isDense: true,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: FreeSinkerShape.presets
          .map((shape) => DropdownMenuItem(
              value: shape,
              child: Text(shape, style: const TextStyle(fontSize: 14))))
          .toList(),
      onChanged: (value) {
        _updateConfig(widget.config.copyWith(freeSinkerShape: value));
      },
    );
  }

  Widget _buildHookSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<String>(
          initialValue: TextEditingValue(text: widget.config.hookType ?? ''),
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return HookType.presets;
            }
            return HookType.presets.where((option) => option
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            // Sync controller with initial value only on first build
            if (controller.text.isEmpty && widget.config.hookType != null) {
              controller.text = widget.config.hookType!;
            }
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                labelText: '鱼钩类型',
                hintText: '选择或输入',
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty && !HookType.presets.contains(value)) {
                  _updateConfig(widget.config.copyWith(hookType: value));
                }
              },
            );
          },
          onSelected: (String selection) {
            _updateConfig(widget.config.copyWith(hookType: selection));
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildHookSizeDropdown()),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _hookWeightController,
                decoration: const InputDecoration(
                  labelText: '重量',
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  _updateConfig(widget.config.copyWith(
                    hookWeight: value.isNotEmpty ? value : null,
                  ));
                },
              ),
            ),
            const SizedBox(width: 4),
            const Text('g', style: TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildHookSizeDropdown() {
    final currentValue = widget.config.hookSize;

    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: const InputDecoration(
        labelText: '钩号',
        isDense: true,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: HookSize.presets
          .map((size) => DropdownMenuItem(value: size, child: Text(size)))
          .toList(),
      onChanged: (value) {
        _updateConfig(widget.config.copyWith(hookSize: value));
      },
    );
  }
}
