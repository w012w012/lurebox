import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/di/di.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/equipment_edit_view_model.dart';
import '../../widgets/common/premium_button.dart';
import '../../widgets/common/premium_card.dart';
import '../../widgets/common/premium_input.dart';
import '../../widgets/equipment/rod_form.dart';
import '../../widgets/equipment/reel_form.dart';
import '../../widgets/equipment/lure_form.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading && widget.equipmentId != null) {
      _loadEquipmentData();
    }
  }

  Future<void> _loadEquipmentData() async {
    if (widget.equipmentId != null) {
      final service = ref.read(equipmentServiceProvider);
      final equipment = await service.getById(widget.equipmentId!);
      if (equipment != null && mounted) {
        final equipmentMap = equipment.toMap();
        setState(() {
          _loadedEquipment = equipmentMap;
          _isLoading = false;
        });
        // 更新 ViewModel
        final params = (type: widget.type, equipment: equipmentMap);
        ref
            .read(equipmentEditViewModelProvider(params).notifier)
            .loadDataFromMap(equipmentMap);
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _getOrCreateController(String field, String value) =>
      _controllers.putIfAbsent(field, () => TextEditingController(text: value));

  @override
  Widget build(BuildContext context) {
    if (_isLoading && widget.equipmentId != null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final strings = ref.watch(currentStringsProvider);
    final params = (type: widget.type, equipment: _loadedEquipment);
    final state = ref.watch(equipmentEditViewModelProvider(params));
    final notifier = ref.read(equipmentEditViewModelProvider(params).notifier);
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
                  state.brand,
                  notifier.updateBrand,
                ),
                _buildTextField(
                  strings.model,
                  'model',
                  state.model,
                  notifier.updateModel,
                ),
              ]),
              const SizedBox(height: 10),
              _buildExpandedRow([
                _buildTextField(
                  strings.price,
                  'price',
                  state.price,
                  notifier.updatePrice,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                _buildDatePicker(
                  strings.purchaseDate,
                  state.purchaseDate,
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
              ]),
            if (widget.type == 'reel') ...[
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
                    suffix: 'm',
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
            ],
            if (widget.type == 'lure')
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
  ) =>
      Autocomplete<String>(
        optionsBuilder: (t) =>
            t.text.isEmpty ? options : options.where((x) => x.contains(t.text)),
        onSelected: callback,
        initialValue: TextEditingValue(text: value),
        fieldViewBuilder: (ctx, ctrl, fn, _) => PremiumTextField(
          controller: ctrl,
          focusNode: fn,
          label: label,
          hint: hint,
          onChanged: callback,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      );
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
