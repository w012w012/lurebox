import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/providers/equipment_edit_state.dart';
import 'package:lurebox/core/providers/equipment_edit_view_model.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/utils/legacy_value_migrator.dart';
import 'package:lurebox/core/utils/unit_converter.dart';
import 'package:lurebox/features/equipment/widgets/lure_form.dart';
import 'package:lurebox/features/equipment/widgets/reel_form.dart';
import 'package:lurebox/features/equipment/widgets/rod_form.dart';
import 'package:lurebox/widgets/common/app_snack_bar.dart';
import 'package:lurebox/widgets/common/premium_button.dart';
import 'package:lurebox/widgets/common/premium_card.dart';
import 'package:lurebox/widgets/common/premium_input.dart';

class EquipmentEditPage extends ConsumerStatefulWidget {
  const EquipmentEditPage({required this.type, super.key, this.equipmentId});
  final String type;
  final int? equipmentId;
  @override
  ConsumerState<EquipmentEditPage> createState() => _EquipmentEditPageState();
}

class _EquipmentEditPageState extends ConsumerState<EquipmentEditPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  Equipment? _loadedEquipment;
  bool _isLoadingEquipment = false;

  // _params is computed dynamically to always match widget.type
  ({String type, Equipment? equipment}) get _params =>
      (type: widget.type, equipment: null);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Edit mode - load equipment data
    if (widget.equipmentId != null && !_isLoadingEquipment) {
      _loadEquipmentData();
    }
  }

  Future<void> _loadEquipmentData() async {
    if (widget.equipmentId == null || _isLoadingEquipment) return;

    _isLoadingEquipment = true;
    try {
      final service = ref.read(equipmentServiceProvider);
      final equipment = await service.getById(widget.equipmentId!);

      // Equipment not found - just return, don't show error for edit
      if (equipment == null) return;

      // Apply legacy migration to get English values
      final equipmentMap = LegacyValueMigrator.migrateEquipmentMap(
        equipment.toMap(),
      );
      // Create Equipment from migrated map to use with loadFromEquipment
      final migratedEquipment = Equipment.fromMap(equipmentMap);
      _loadedEquipment = migratedEquipment;

      // Update ViewModel with loaded data
      ref
          .read(equipmentEditViewModelProvider(_params).notifier)
          .loadFromEquipment(migratedEquipment);

      // Create/update controllers with loaded values
      _getOrCreateController('brand', migratedEquipment.brand ?? '');
      _getOrCreateController('model', migratedEquipment.model ?? '');
      _getOrCreateController(
          'price', migratedEquipment.price?.toString() ?? '');
      _getOrCreateController(
        'purchaseDate',
        migratedEquipment.purchaseDate?.toIso8601String().split('T').first ??
            '',
      );

      // Sync type-specific controllers from equipment
      _syncTypeSpecificControllers(migratedEquipment);

      if (mounted) {
        setState(() {
          _loadedEquipment = migratedEquipment;
        });
      }
    } finally {
      _isLoadingEquipment = false;
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _getOrCreateController(String field, String value) {
    final controller = _controllers.putIfAbsent(
      field,
      () => TextEditingController(text: value),
    );
    if (value.isNotEmpty && controller.text != value) {
      controller.text = value;
    }
    return controller;
  }

  void _syncTypeSpecificControllers(Equipment equipment) {
    switch (widget.type) {
      case 'rod':
        _getOrCreateController('length', equipment.length ?? '');
        _getOrCreateController('sections', equipment.sections ?? '');
        _getOrCreateController('material', equipment.material ?? '');
        final wr = equipment.weightRange ?? '';
        _getOrCreateController('weightRangeMin', _parseWeightRange(wr).$1);
        _getOrCreateController('weightRangeMax', _parseWeightRange(wr).$2);
      case 'reel':
        _getOrCreateController(
            'reelBearings', equipment.reelBearings?.toString() ?? '');
        final ratio = equipment.reelRatio ?? '';
        _getOrCreateController('reelRatioA', _parseRatio(ratio).$1);
        _getOrCreateController('reelRatioB', _parseRatio(ratio).$2);
        final cap = equipment.reelCapacity ?? '';
        _getOrCreateController('reelCapacityNumber', _parseCapacity(cap).$1);
        _getOrCreateController('reelCapacityLength', _parseCapacity(cap).$2);
        _getOrCreateController('reelWeight', equipment.reelWeight ?? '');
        _getOrCreateController('reelDrag', equipment.reelDrag ?? '');
        _getOrCreateController('reelLine', equipment.reelLine ?? '');
        _getOrCreateController(
            'reelLineNumber', equipment.reelLineNumber ?? '');
        _getOrCreateController(
            'reelLineLength', equipment.reelLineLength ?? '');
      case 'lure':
        _getOrCreateController('lureWeight', equipment.lureWeight ?? '');
        _getOrCreateController('lureSize', equipment.lureSize ?? '');
        _getOrCreateController('lureColor', equipment.lureColor ?? '');
        _getOrCreateController(
            'lureQuantity', equipment.lureQuantity?.toString() ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(currentStringsProvider);
    final displayUnits = ref.watch(appSettingsProvider).units;
    final lineLengthSymbol =
        UnitConverter.getLengthSymbol(displayUnits.lineLengthUnit);
    final params = _params;
    final state = ref.watch(equipmentEditViewModelProvider(params));
    final notifier = ref.read(equipmentEditViewModelProvider(params).notifier);

    // Show loading indicator while fetching equipment data
    if (_isLoadingEquipment && widget.equipmentId != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Loading... equipmentId=${widget.equipmentId}'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.isEdit ? strings.editEquipment : strings.addEquipment,
        ),
        centerTitle: true,
        actions: [
          PremiumButton(
            text: strings.save,
            variant: PremiumButtonVariant.text,
            isLoading: state.isSaving,
            onPressed: state.isSaving ? null : () => _save(strings, notifier),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              _buildCard([
                _buildSectionTitle(strings.basicInfo),
                const SizedBox(height: 12),
                _buildExpandedRow([
                  _buildTextField(
                    strings.brand,
                    'brand',
                    _controllers['brand']?.text ?? state.brand,
                    notifier.updateBrand,
                  ),
                  _buildTextField(
                    strings.model,
                    'model',
                    _controllers['model']?.text ?? state.model,
                    notifier.updateModel,
                  ),
                ]),
                const SizedBox(height: 10),
                _buildExpandedRow([
                  _buildTextField(
                    strings.price,
                    'price',
                    _controllers['price']?.text ?? state.price,
                    notifier.updatePrice,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  _buildDatePicker(
                    strings.purchaseDate,
                    _controllers['purchaseDate']?.text ?? state.purchaseDate,
                    notifier.updatePurchaseDate,
                    strings,
                  ),
                ]),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: Text(
                    strings.setDefault,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    strings.autoAssociate,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  value: state.isDefault,
                  onChanged: notifier.updateIsDefault,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ]),
              ...widget.type == 'rod'
                  ? [
                      () {
                        final rodState = state as RodEditState;
                        return _buildCard([
                          _buildSectionTitle(strings.rodParameters),
                          const SizedBox(height: 12),
                          _buildExpandedRow([
                            _buildAutocomplete(
                              strings.handleType,
                              state.categoryType1,
                              notifier.updateCategoryType1,
                              strings.rodHandleTypes,
                              strings.handleTypeHint,
                            ),
                            _buildAutocomplete(
                              strings.usageType,
                              state.categoryType2,
                              notifier.updateCategoryType2,
                              strings.rodUsageTypes,
                              strings.selectOrEnterUsage,
                            ),
                          ]),
                          const SizedBox(height: 10),
                          RodForm(
                            lengthController: _getOrCreateController(
                              'length',
                              rodState.length,
                            ),
                            lengthUnit: rodState.lengthUnit,
                            onLengthUnitChanged: notifier.updateLengthUnit,
                            sectionsController: _getOrCreateController(
                              'sections',
                              rodState.sections,
                            ),
                            jointType: rodState.jointType,
                            onJointTypeChanged: notifier.updateJointType,
                            materialController: _getOrCreateController(
                              'material',
                              rodState.material,
                            ),
                            hardness: rodState.hardness,
                            onHardnessChanged: notifier.updateHardness,
                            action: rodState.rodAction,
                            onActionChanged: notifier.updateRodAction,
                            weightRangeMinController: _getOrCreateController(
                              'weightRangeMin',
                              _parseWeightRange(rodState.weightRange).$1,
                            ),
                            weightRangeMaxController: _getOrCreateController(
                              'weightRangeMax',
                              _parseWeightRange(rodState.weightRange).$2,
                            ),
                          ),
                        ]);
                      }(),
                    ]
                  : widget.type == 'reel'
                      ? [
                          () {
                            final reelState = state as ReelEditState;
                            return _buildCard([
                              _buildSectionTitle(strings.reelParameters),
                              const SizedBox(height: 12),
                              _buildExpandedRow([
                                _buildAutocomplete(
                                  strings.reelType,
                                  state.categoryType1,
                                  notifier.updateCategoryType1,
                                  strings.reelTypes,
                                  strings.reelTypeHint,
                                ),
                                _buildAutocomplete(
                                  strings.usageType,
                                  state.categoryType2,
                                  notifier.updateCategoryType2,
                                  strings.reelUsageTypes,
                                  strings.reelUsageHint,
                                ),
                              ]),
                              const SizedBox(height: 10),
                              ReelForm(
                                bearingsController: _getOrCreateController(
                                  'reelBearings',
                                  reelState.reelBearings,
                                ),
                                ratioAController: _getOrCreateController(
                                  'reelRatioA',
                                  _parseRatio(reelState.reelRatio).$1,
                                ),
                                ratioBController: _getOrCreateController(
                                  'reelRatioB',
                                  _parseRatio(reelState.reelRatio).$2,
                                ),
                                capacityNumberController:
                                    _getOrCreateController(
                                  'reelCapacityNumber',
                                  _parseCapacity(reelState.reelCapacity).$1,
                                ),
                                capacityLengthController:
                                    _getOrCreateController(
                                  'reelCapacityLength',
                                  _parseCapacity(reelState.reelCapacity).$2,
                                ),
                                weightController: _getOrCreateController(
                                  'reelWeight',
                                  reelState.reelWeight,
                                ),
                                weightUnit: reelState.reelWeightUnit,
                                onWeightUnitChanged:
                                    notifier.updateReelWeightUnit,
                                dragController: _getOrCreateController(
                                  'reelDrag',
                                  reelState.reelDrag,
                                ),
                                dragUnit: reelState.reelDragUnit,
                                onDragUnitChanged:
                                    notifier.updateReelDragUnit,
                                brakeType: reelState.reelBrakeType,
                                onBrakeTypeChanged:
                                    notifier.updateReelBrakeType,
                              ),
                            ]);
                          }(),
                          () {
                            final reelState = state as ReelEditState;
                            return _buildCard([
                              _buildSectionTitle(strings.line),
                              const SizedBox(height: 12),
                              _buildTextField(
                                strings.brandAndName,
                                'reelLine',
                                reelState.reelLine,
                                notifier.updateReelLine,
                              ),
                              const SizedBox(height: 10),
                              _buildExpandedRow([
                                _buildTextField(
                                  strings.lineNumber,
                                  'reelLineNumber',
                                  reelState.reelLineNumber,
                                  notifier.updateReelLineNumber,
                                ),
                                _buildTextField(
                                  strings.lineLength,
                                  'reelLineLength',
                                  reelState.reelLineLength,
                                  notifier.updateReelLineLength,
                                  suffix: lineLengthSymbol,
                                ),
                              ]),
                              const SizedBox(height: 10),
                              _buildDatePicker(
                                strings.lineDate,
                                reelState.reelLineDate,
                                notifier.updateReelLineDate,
                                strings,
                              ),
                            ]);
                          }(),
                        ]
                      : widget.type == 'lure'
                          ? [
                              () {
                                final lureState = state as LureEditState;
                                return _buildCard([
                                  _buildSectionTitle(strings.lureParameters),
                                  const SizedBox(height: 12),
                                  _buildAutocomplete(
                                    strings.type,
                                    lureState.lureType,
                                    notifier.updateLureType,
                                    strings.lureTypeOptions,
                                    strings.selectOrEnterType,
                                  ),
                                  const SizedBox(height: 10),
                                  LureForm(
                                    weightController: _getOrCreateController(
                                      'lureWeight',
                                      lureState.lureWeight,
                                    ),
                                    weightUnit: lureState.lureWeightUnit,
                                    onWeightUnitChanged:
                                        notifier.updateLureWeightUnit,
                                    sizeController: _getOrCreateController(
                                      'lureSize',
                                      lureState.lureSize,
                                    ),
                                    sizeUnit: lureState.lureSizeUnit,
                                    onSizeUnitChanged:
                                        notifier.updateLureSizeUnit,
                                    colorController: _getOrCreateController(
                                      'lureColor',
                                      lureState.lureColor,
                                    ),
                                    quantityController: _getOrCreateController(
                                      'lureQuantity',
                                      lureState.lureQuantity,
                                    ),
                                    quantityUnit: lureState.lureQuantityUnit,
                                    onQuantityUnitChanged:
                                        notifier.updateLureQuantityUnit,
                                  ),
                                ]);
                              }(),
                            ]
                          : <Widget>[],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(
    AppStrings strings,
    EquipmentEditViewModel notifier,
  ) async {
    // 先同步 controller 的值到 state
    // 特殊处理：合并分字段为单个字段
    // 鱼竿 - 适合饵重
    final weightRangeMin = _controllers['weightRangeMin']?.text ?? '';
    final weightRangeMax = _controllers['weightRangeMax']?.text ?? '';
    notifier.updateWeightRange('$weightRangeMin-$weightRangeMax');

    // 鱼线轮 - 齿轮比
    final reelRatioA = _controllers['reelRatioA']?.text ?? '';
    final reelRatioB = _controllers['reelRatioB']?.text ?? '';
    notifier.updateReelRatio('$reelRatioA:$reelRatioB');

    // 鱼线轮 - 线容量
    final reelCapacityNumber = _controllers['reelCapacityNumber']?.text ?? '';
    final reelCapacityLength = _controllers['reelCapacityLength']?.text ?? '';
    notifier.updateReelCapacity('$reelCapacityNumber-$reelCapacityLength');

    for (final entry in _controllers.entries) {
      final field = entry.key;
      final value = entry.value.text;
      switch (field) {
        case 'weightRangeMin':
        case 'weightRangeMax':
        case 'reelRatioA':
        case 'reelRatioB':
        case 'reelCapacityNumber':
        case 'reelCapacityLength':
          // 已在上方特殊处理，跳过
          break;
        case 'brand':
          notifier.updateBrand(value);
        case 'model':
          notifier.updateModel(value);
        case 'price':
          notifier.updatePrice(value);
        case 'purchaseDate':
          notifier.updatePurchaseDate(value);
        case 'length':
          notifier.updateLength(value);
        case 'sections':
          notifier.updateSections(value);
        case 'material':
          notifier.updateMaterial(value);
        case 'hardness':
          notifier.updateHardness(value);
        case 'rodAction':
          notifier.updateRodAction(value);
        case 'weightRange':
          notifier.updateWeightRange(value);
        case 'reelBearings':
          notifier.updateReelBearings(value);
        case 'reelRatio':
          notifier.updateReelRatio(value);
        case 'reelCapacity':
          notifier.updateReelCapacity(value);
        case 'reelBrakeType':
          notifier.updateReelBrakeType(value);
        case 'reelWeight':
          notifier.updateReelWeight(value);
        case 'reelDrag':
          notifier.updateReelDrag(value);
        case 'reelLine':
          notifier.updateReelLine(value);
        case 'reelLineNumber':
          notifier.updateReelLineNumber(value);
        case 'reelLineLength':
          notifier.updateReelLineLength(value);
        case 'reelLineDate':
          notifier.updateReelLineDate(value);
        case 'lureType':
          notifier.updateLureType(value);
        case 'lureWeight':
          notifier.updateLureWeight(value);
        case 'lureSize':
          notifier.updateLureSize(value);
        case 'lureColor':
          notifier.updateLureColor(value);
        case 'lureQuantity':
          notifier.updateLureQuantity(value);
        case 'lureQuantityUnit':
          notifier.updateLureQuantityUnit(value);
      }
    }

    final err = notifier.validatePrice(strings);
    if (err != null) {
      AppSnackBar.showError(context, err);
      return;
    }
    final ok = await notifier.save();
    if (ok && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      final s = ref.read(
        equipmentEditViewModelProvider(
          (
            type: widget.type,
            equipment: _loadedEquipment,
          ),
        ),
      );
      if (s.errorMessage != null) {
        AppSnackBar.showError(context, strings.saveFailed,
            debugError: s.errorMessage);
      }
    }
  }

  Widget _buildCard(List<Widget> children) => PremiumCard(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        variant: PremiumCardVariant.flat,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );
  Widget _buildSectionTitle(String text) => Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
      );
  Widget _buildExpandedRow(List<Widget> children) => Row(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: children[i]),
          ],
        ],
      );
  Widget _buildTextField(
    String label,
    String field,
    String value,
    void Function(String) callback, {
    TextInputType? keyboardType,
    String? suffix,
    String? hint,
  }) =>
      PremiumTextField(
        controller: _getOrCreateController(field, value),
        label: label,
        hint: hint,
        suffix: suffix != null ? Text(suffix) : null,
        keyboardType: keyboardType,
        onChanged: callback,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );
  Widget _buildAutocomplete(
    String label,
    String value,
    void Function(String) callback,
    List<String> options,
    String hint,
  ) {
    // 使用局部变量捕获 Autocomplete 提供的 FocusNode，避免每次 build 泄漏
    FocusNode? capturedFocusNode;

    return Autocomplete<String>(
      optionsBuilder: (t) =>
          t.text.isEmpty ? options : options.where((x) => x.contains(t.text)),
      onSelected: callback,
      initialValue: TextEditingValue(text: value),
      fieldViewBuilder: (ctx, ctrl, fn, _) {
        capturedFocusNode = fn;
        return _DismissibleAutocompleteField(
          focusNode: fn,
          child: PremiumTextField(
            controller: ctrl,
            focusNode: fn,
            label: label,
            hint: hint,
            onChanged: callback,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return _DismissibleAutocompleteOptions(
          onSelected: onSelected,
          options: options,
          focusNode: capturedFocusNode!,
        );
      },
    );
  }

  Widget _buildDatePicker(
    String label,
    String value,
    void Function(String) callback,
    AppStrings strings,
  ) =>
      InkWell(
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: value.isNotEmpty
                ? DateTime.tryParse(value) ?? DateTime.now()
                : DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
          );
          if (d != null) callback(d.toIso8601String().split('T')[0]);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2A2D30)
                    : TeslaColors.cloudGray,
              ),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          child: Text(
            value.isEmpty ? strings.tapToSelect : value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );

  // 解析适合饵重格式 "a-b" 或 "a-b克"
  (String, String) _parseWeightRange(String? value) {
    if (value == null || value.isEmpty) return ('', '');
    // 移除"克"后缀
    final cleanValue = value.replaceAll('克', '');
    final parts = cleanValue.split('-');
    if (parts.length == 2) {
      return (parts[0], parts[1]);
    }
    return ('', '');
  }

  // 解析速比格式 "a:b"
  (String, String) _parseRatio(String? value) {
    if (value == null || value.isEmpty) return ('', '');
    final parts = value.split(':');
    if (parts.length == 2) {
      return (parts[0], parts[1]);
    }
    return ('', '');
  }

  // 解析线杯容量格式 "a-b" (与保存格式一致)
  (String, String) _parseCapacity(String? value) {
    if (value == null || value.isEmpty) return ('', '');
    final parts = value.split('-');
    if (parts.length == 2) {
      return (parts[0], parts[1]);
    }
    return ('', '');
  }
}

/// 包裹 Autocomplete 文本字段，处理点击外部关闭
class _DismissibleAutocompleteField extends StatefulWidget {
  const _DismissibleAutocompleteField({
    required this.focusNode,
    required this.child,
  });
  final FocusNode focusNode;
  final Widget child;

  @override
  State<_DismissibleAutocompleteField> createState() =>
      _DismissibleAutocompleteFieldState();
}

class _DismissibleAutocompleteFieldState
    extends State<_DismissibleAutocompleteField> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (!widget.focusNode.hasFocus) {
      // 当焦点失去时，关闭键盘和潜在的 Overlay
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// 可关闭的下拉选项面板 - 支持点击外部关闭
class _DismissibleAutocompleteOptions<T> extends StatelessWidget {
  const _DismissibleAutocompleteOptions({
    required this.onSelected,
    required this.options,
    required this.focusNode,
  });
  final void Function(T) onSelected;
  final Iterable<T> options;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // 点击外部关闭
        Positioned.fill(
          child: GestureDetector(
            onTap: focusNode.unfocus,
            child: Container(color: Colors.transparent),
          ),
        ),
        // 选项面板
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            color: isDark ? TeslaColors.carbonDark : TeslaColors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: options.map((option) {
                  return ListTile(
                    dense: true,
                    title: Text(
                      option.toString(),
                      style: TextStyle(
                        color:
                            isDark ? TeslaColors.white : TeslaColors.carbonDark,
                      ),
                    ),
                    onTap: () {
                      onSelected(option);
                      focusNode.unfocus();
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
