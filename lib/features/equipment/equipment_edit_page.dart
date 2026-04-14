import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/di/di.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/app_settings_provider.dart';
import '../../core/providers/equipment_edit_view_model.dart';
import '../../core/utils/unit_converter.dart';
import '../../widgets/common/premium_button.dart';
import '../../widgets/common/premium_card.dart';
import '../../widgets/common/premium_input.dart';
import 'widgets/rod_form.dart';
import 'widgets/reel_form.dart';
import 'widgets/lure_form.dart';

class EquipmentEditPage extends ConsumerStatefulWidget {
  final String type;
  final int? equipmentId;
  const EquipmentEditPage({super.key, required this.type, this.equipmentId});
  @override
  ConsumerState<EquipmentEditPage> createState() => _EquipmentEditPageState();
}

class _EquipmentEditPageState extends ConsumerState<EquipmentEditPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = true;
  Map<String, dynamic>? _loadedEquipment;

  ({String type, Map<String, dynamic>? equipment}) _params = (type: '', equipment: null);
  bool _isLoadingEquipment = false;

  @override
  void initState() {
    super.initState();
    _params = (type: widget.type, equipment: null);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading && widget.equipmentId != null && !_isLoadingEquipment) {
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
      if (equipment == null) {
        debugPrint('[_loadEquipmentData] equipment not found for id: ${widget.equipmentId}');
        return;
      }

      debugPrint('[_loadEquipmentData] loaded equipment - brand: ${equipment.brand}, model: ${equipment.model}, length: ${equipment.length}');

      final equipmentMap = equipment.toMap();
      _params = (type: widget.type, equipment: equipmentMap);

      // Update ViewModel FIRST - this populates the state
      ref
          .read(equipmentEditViewModelProvider(_params).notifier)
          .loadDataFromMap(equipmentMap);

      debugPrint('[_loadEquipmentData] state after load - type: ${widget.type}');

      // Create/update controllers with loaded values
      _getOrCreateController('brand', equipment.brand ?? '');
      _getOrCreateController('model', equipment.model ?? '');
      _getOrCreateController('price', equipment.price?.toString() ?? '');
      _getOrCreateController('purchaseDate',
          equipment.purchaseDate?.toIso8601String().split('T').first ?? '');

      // Sync type-specific controllers from equipment map (controllers may have been created with empty values on first build)
      _syncTypeSpecificControllers(equipmentMap);

      debugPrint('[_loadEquipmentData] controller length text: ${_controllers['length']?.text}');

      if (mounted) {
        setState(() {
          _loadedEquipment = equipmentMap;
          _isLoading = false;
          _params = (type: widget.type, equipment: equipmentMap);
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
        field, () => TextEditingController(text: value));
    // Update controller text if value changed (handles case where controller was created before data loaded)
    if (controller.text != value) {
      controller.text = value;
    }
    return controller;
  }

  void _syncTypeSpecificControllers(Map<String, dynamic> equipment) {
    // Sync rod/reel/lure controllers from equipment map in case they were created with empty values on first build
    switch (widget.type) {
      case 'rod':
        _getOrCreateController('length', equipment['length']?.toString() ?? '');
        _getOrCreateController('sections', equipment['sections']?.toString() ?? '');
        _getOrCreateController('material', equipment['material']?.toString() ?? '');
        final wr = equipment['weight_range']?.toString() ?? '';
        _getOrCreateController('weightRangeMin', _parseWeightRange(wr).$1);
        _getOrCreateController('weightRangeMax', _parseWeightRange(wr).$2);
        break;
      case 'reel':
        _getOrCreateController('reelBearings', equipment['reel_bearings']?.toString() ?? '');
        final ratio = equipment['reel_ratio']?.toString() ?? '';
        _getOrCreateController('reelRatioA', _parseRatio(ratio).$1);
        _getOrCreateController('reelRatioB', _parseRatio(ratio).$2);
        final cap = equipment['reel_capacity']?.toString() ?? '';
        _getOrCreateController('reelCapacityNumber', _parseCapacity(cap).$1);
        _getOrCreateController('reelCapacityLength', _parseCapacity(cap).$2);
        _getOrCreateController('reelWeight', equipment['reel_weight']?.toString() ?? '');
        _getOrCreateController('reelLine', equipment['reel_line']?.toString() ?? '');
        _getOrCreateController('reelLineNumber', equipment['reel_line_number']?.toString() ?? '');
        _getOrCreateController('reelLineLength', equipment['reel_line_length']?.toString() ?? '');
        break;
      case 'lure':
        _getOrCreateController('lureWeight', equipment['lure_weight']?.toString() ?? '');
        _getOrCreateController('lureSize', equipment['lure_size']?.toString() ?? '');
        _getOrCreateController('lureColor', equipment['lure_color']?.toString() ?? '');
        _getOrCreateController('lureQuantity', equipment['lure_quantity']?.toString() ?? '');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // DEBUG: Show loading state
    if (_isLoading && widget.equipmentId != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Loading... _isLoading=$_isLoading equipmentId=${widget.equipmentId} widget.type=${widget.type} _params.type=${_params.type}'),
            ],
          ),
        ),
      );
    }

    final strings = ref.watch(currentStringsProvider);
    final displayUnits = ref.watch(appSettingsProvider).units;
    final lineLengthSymbol =
        UnitConverter.getLengthSymbol(displayUnits.lineLengthUnit);
    final params = _params;
    final state = ref.watch(equipmentEditViewModelProvider(params));
    final notifier = ref.read(equipmentEditViewModelProvider(params).notifier);

    // DEBUG: Show state values on screen
    final debugInfo = 'type=${state.type} len=${state.length} sec=${state.sections} cat1=${state.categoryType1}';

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
              // DEBUG: Show state values
              Container(
                width: double.infinity,
                color: Colors.orange,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'DEBUG: $debugInfo',
                  style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
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
              if (widget.type == 'rod')
                _buildCard([
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
                      state.length,
                    ),
                    lengthUnit: state.lengthUnit,
                    onLengthUnitChanged: notifier.updateLengthUnit,
                    sectionsController: _getOrCreateController(
                      'sections',
                      state.sections,
                    ),
                    jointType: state.jointType,
                    onJointTypeChanged: notifier.updateJointType,
                    materialController: _getOrCreateController(
                      'material',
                      state.material,
                    ),
                    hardness: state.hardness,
                    onHardnessChanged: notifier.updateHardness,
                    action: state.rodAction,
                    onActionChanged: notifier.updateRodAction,
                    weightRangeMinController: _getOrCreateController(
                      'weightRangeMin',
                      _parseWeightRange(state.weightRange).$1,
                    ),
                    weightRangeMaxController: _getOrCreateController(
                      'weightRangeMax',
                      _parseWeightRange(state.weightRange).$2,
                    ),
                  ),
                ])
              else if (widget.type == 'reel') ...[
                _buildCard([
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
                      state.reelBearings,
                    ),
                    ratioAController: _getOrCreateController(
                      'reelRatioA',
                      _parseRatio(state.reelRatio).$1,
                    ),
                    ratioBController: _getOrCreateController(
                      'reelRatioB',
                      _parseRatio(state.reelRatio).$2,
                    ),
                    capacityNumberController: _getOrCreateController(
                      'reelCapacityNumber',
                      _parseCapacity(state.reelCapacity).$1,
                    ),
                    capacityLengthController: _getOrCreateController(
                      'reelCapacityLength',
                      _parseCapacity(state.reelCapacity).$2,
                    ),
                    weightController: _getOrCreateController(
                      'reelWeight',
                      state.reelWeight,
                    ),
                    weightUnit: state.reelWeightUnit,
                    onWeightUnitChanged: notifier.updateReelWeightUnit,
                    brakeType: state.reelBrakeType,
                    onBrakeTypeChanged: notifier.updateReelBrakeType,
                  ),
                ]),
                _buildCard([
                  _buildSectionTitle(strings.line),
                  const SizedBox(height: 12),
                  _buildTextField(
                    strings.brandAndName,
                    'reelLine',
                    state.reelLine,
                    notifier.updateReelLine,
                  ),
                  const SizedBox(height: 10),
                  _buildExpandedRow([
                    _buildTextField(
                      strings.lineNumber,
                      'reelLineNumber',
                      state.reelLineNumber,
                      notifier.updateReelLineNumber,
                    ),
                    _buildTextField(
                      strings.lineLength,
                      'reelLineLength',
                      state.reelLineLength,
                      notifier.updateReelLineLength,
                      suffix: lineLengthSymbol,
                    ),
                  ]),
                  const SizedBox(height: 10),
                  _buildDatePicker(
                    strings.lineDate,
                    state.reelLineDate,
                    notifier.updateReelLineDate,
                    strings,
                  ),
                ]),
              ] else if (widget.type == 'lure')
                _buildCard([
                  _buildSectionTitle(strings.lureParameters),
                  const SizedBox(height: 12),
                  _buildAutocomplete(
                    strings.type,
                    state.lureType,
                    notifier.updateLureType,
                    strings.lureTypeOptions,
                    strings.selectOrEnterType,
                  ),
                  const SizedBox(height: 10),
                  LureForm(
                    weightController: _getOrCreateController(
                      'lureWeight',
                      state.lureWeight,
                    ),
                    weightUnit: state.lureWeightUnit,
                    onWeightUnitChanged: notifier.updateLureWeightUnit,
                    sizeController: _getOrCreateController(
                      'lureSize',
                      state.lureSize,
                    ),
                    sizeUnit: state.lureSizeUnit,
                    onSizeUnitChanged: notifier.updateLureSizeUnit,
                    colorController: _getOrCreateController(
                      'lureColor',
                      state.lureColor,
                    ),
                    quantityController: _getOrCreateController(
                      'lureQuantity',
                      state.lureQuantity,
                    ),
                    quantityUnit: state.lureQuantityUnit,
                    onQuantityUnitChanged: notifier.updateLureQuantityUnit,
                  ),
                ]),
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
    for (final entry in _controllers.entries) {
      final field = entry.key;
      final value = entry.value.text;
      switch (field) {
        case 'brand':
          notifier.updateBrand(value);
          break;
        case 'model':
          notifier.updateModel(value);
          break;
        case 'price':
          notifier.updatePrice(value);
          break;
        case 'purchaseDate':
          notifier.updatePurchaseDate(value);
          break;
        case 'length':
          notifier.updateLength(value);
          break;
        case 'sections':
          notifier.updateSections(value);
          break;
        case 'material':
          notifier.updateMaterial(value);
          break;
        case 'hardness':
          notifier.updateHardness(value);
          break;
        case 'rodAction':
          notifier.updateRodAction(value);
          break;
        case 'weightRange':
          notifier.updateWeightRange(value);
          break;
        case 'reelBearings':
          notifier.updateReelBearings(value);
          break;
        case 'reelRatio':
          notifier.updateReelRatio(value);
          break;
        case 'reelCapacity':
          notifier.updateReelCapacity(value);
          break;
        case 'reelBrakeType':
          notifier.updateReelBrakeType(value);
          break;
        case 'reelWeight':
          notifier.updateReelWeight(value);
          break;
        case 'reelLine':
          notifier.updateReelLine(value);
          break;
        case 'reelLineNumber':
          notifier.updateReelLineNumber(value);
          break;
        case 'reelLineLength':
          notifier.updateReelLineLength(value);
          break;
        case 'reelLineDate':
          notifier.updateReelLineDate(value);
          break;
        case 'lureType':
          notifier.updateLureType(value);
          break;
        case 'lureWeight':
          notifier.updateLureWeight(value);
          break;
        case 'lureSize':
          notifier.updateLureSize(value);
          break;
        case 'lureColor':
          notifier.updateLureColor(value);
          break;
        case 'lureQuantity':
          notifier.updateLureQuantity(value);
          break;
        case 'lureQuantityUnit':
          notifier.updateLureQuantityUnit(value);
          break;
      }
    }

    final err = notifier.validatePrice(strings);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    final ok = await notifier.save();
    if (ok && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      final s = ref.read(
        equipmentEditViewModelProvider((
          type: widget.type,
          equipment: _loadedEquipment,
        )),
      );
      if (s.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${strings.saveFailed}: ${s.errorMessage}')),
        );
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
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
    final focusNode = FocusNode();

    return Autocomplete<String>(
      optionsBuilder: (t) =>
          t.text.isEmpty ? options : options.where((x) => x.contains(t.text)),
      onSelected: callback,
      initialValue: TextEditingValue(text: value),
      fieldViewBuilder: (ctx, ctrl, fn, _) {
        // Listen for focus changes to dismiss options on tap outside
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
          focusNode: focusNode,
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
                    ? AppColors.borderDark
                    : AppColors.borderLight,
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

  // 解析线杯容量格式 "a号/b米"
  (String, String) _parseCapacity(String? value) {
    if (value == null || value.isEmpty) return ('', '');
    final parts = value.split('/');
    if (parts.length == 2) {
      final number = parts[0].replaceAll('号', '');
      final length = parts[1].replaceAll('米', '');
      return (number, length);
    }
    return ('', '');
  }
}

/// 包裹 Autocomplete 文本字段，处理点击外部关闭
class _DismissibleAutocompleteField extends StatefulWidget {
  final FocusNode focusNode;
  final Widget child;

  const _DismissibleAutocompleteField({
    required this.focusNode,
    required this.child,
  });

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
  final void Function(T) onSelected;
  final Iterable<T> options;
  final FocusNode focusNode;

  const _DismissibleAutocompleteOptions({
    required this.onSelected,
    required this.options,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // 点击外部关闭
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              focusNode.unfocus();
            },
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
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
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
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
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
