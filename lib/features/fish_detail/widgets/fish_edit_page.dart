import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/strings.dart';
import '../../../core/design/theme/app_colors.dart';
import '../../../core/di/di.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/models/fish_catch.dart';
import '../../../core/models/equipment.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/services/weather_service.dart' show getLocalizedWeatherDescription;

class FishEditPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> fish;
  final AppStrings strings;

  const FishEditPage({super.key, required this.fish, required this.strings});

  @override
  ConsumerState<FishEditPage> createState() => _FishEditPageState();
}

class _FishEditPageState extends ConsumerState<FishEditPage> {
  late TextEditingController _speciesController;
  late TextEditingController _lengthController;
  late TextEditingController _weightController;
  late TextEditingController _locationController;
  late int _selectedFate;
  String _lengthUnit = 'cm';
  String _weightUnit = 'kg';
  int? _selectedRodId;
  int? _selectedReelId;
  int? _selectedLureId;
  bool _isSaving = false;
  DateTime? _catchTime;
  double? _airTemperature;
  double? _pressure;
  int? _weatherCode;

  List<Equipment> _rods = [];
  List<Equipment> _reels = [];
  List<Equipment> _lures = [];

  @override
  void initState() {
    super.initState();
    final fish = FishCatch.fromMap(widget.fish);
    _speciesController = TextEditingController(text: fish.species);
    _lengthController = TextEditingController(text: fish.length.toString());
    _weightController = TextEditingController(
      text: fish.weight?.toString() ?? '',
    );
    _locationController = TextEditingController(text: fish.locationName ?? '');
    _selectedFate = fish.fate.value;
    _lengthUnit = fish.lengthUnit;
    _weightUnit = fish.weightUnit;
    _selectedRodId = fish.rodId;
    _selectedReelId = fish.reelId;
    _selectedLureId = fish.lureId;
    _catchTime = fish.catchTime;
    _airTemperature = fish.airTemperature;
    _pressure = fish.pressure;
    _weatherCode = fish.weatherCode;
    _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    try {
      final equipmentService = ref.read(equipmentServiceProvider);
      final rods = await equipmentService.getAll(type: 'rod');
      final reels = await equipmentService.getAll(type: 'reel');
      final lures = await equipmentService.getAll(type: 'lure');
      if (mounted) {
        setState(() {
          _rods = rods;
          _reels = reels;
          _lures = lures;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _save() async {
    final species = _speciesController.text.trim();
    if (species.isEmpty) {
      _showSnackBar(widget.strings.enterSpecies);
      return;
    }
    final length = double.tryParse(_lengthController.text);
    if (length == null || length <= 0) {
      _showSnackBar(widget.strings.enterValidLength);
      return;
    }
    double? weight;
    final weightText = _weightController.text.trim();
    if (weightText.isNotEmpty) {
      weight = double.tryParse(weightText);
      if (weight == null || weight < 0) {
        _showSnackBar(widget.strings.enterValidWeight);
        return;
      }
    }

    setState(() => _isSaving = true);
    try {
      final originalFish = FishCatch.fromMap(widget.fish);
      final updatedFish = originalFish.copyWith(
        species: species,
        length: length,
        lengthUnit: _lengthUnit,
        weight: weight,
        weightUnit: _weightUnit,
        fate: FishFateType.fromValue(_selectedFate),
        locationName: () => _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        rodId: () => _selectedRodId,
        reelId: () => _selectedReelId,
        lureId: () => _selectedLureId,
        catchTime: _catchTime ?? originalFish.catchTime,
        airTemperature: () => _airTemperature,
        pressure: () => _pressure,
        weatherCode: () => _weatherCode,
        updatedAt: DateTime.now(),
      );
      await ref.read(fishCatchServiceProvider).update(updatedFish);
      if (mounted) Navigator.pop(context, {'success': true});
    } catch (e) {
      if (mounted) _showSnackBar('${widget.strings.saveFailed}: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final temperatureUnit =
        ref.watch(appSettingsProvider).units.temperatureUnit;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.editFish),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(s.save),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _textField(_speciesController, s.species, Icons.set_meal),
          const SizedBox(height: 16),
          _buildLengthField(s),
          const SizedBox(height: 16),
          _buildWeightField(s),
          const SizedBox(height: 16),
          _textField(
            _locationController,
            '${s.catchLocation} (${s.optional})',
            Icons.location_on,
          ),
          const SizedBox(height: 16),
          // 钓获时间
          Card(
            child: ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('钓获时间'),
              subtitle: Text(
                _catchTime != null
                    ? '${_catchTime!.year}-${_catchTime!.month.toString().padLeft(2, '0')}-${_catchTime!.day.toString().padLeft(2, '0')} ${_catchTime!.hour.toString().padLeft(2, '0')}:${_catchTime!.minute.toString().padLeft(2, '0')}'
                    : '未设置',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: _pickDateTime,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 天气信息
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.wb_sunny, size: 20),
                      const SizedBox(width: 8),
                      const Text('天气信息',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: _editWeather,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_getWeatherDisplayText(temperatureUnit)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            s.fate,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _fateOption(
                  '🐟 ${s.release}',
                  FishFateType.release.value,
                  AppColors.release,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _fateOption(
                  '🍳 ${s.keep}',
                  FishFateType.keep.value,
                  AppColors.keep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            s.useEquipment,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildEquipmentDropdown(
            label: s.rod,
            value: _selectedRodId,
            items: _rods,
            onChanged: (id) => setState(() => _selectedRodId = id),
          ),
          const SizedBox(height: 12),
          _buildEquipmentDropdown(
            label: s.reel,
            value: _selectedReelId,
            items: _reels,
            onChanged: (id) => setState(() => _selectedReelId = id),
          ),
          const SizedBox(height: 12),
          _buildEquipmentDropdown(
            label: s.lure,
            value: _selectedLureId,
            items: _lures,
            onChanged: (id) => setState(() => _selectedLureId = id),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentDropdown({
    required String label,
    required int? value,
    required List<Equipment> items,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int?>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('不使用')),
        ...items.map(
          (e) =>
              DropdownMenuItem<int?>(value: e.id, child: Text(e.displayName)),
        ),
      ],
      onChanged: onChanged,
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _fateOption(String label, int fate, Color color) {
    final isSelected = _selectedFate == fate;
    return GestureDetector(
      onTap: () => setState(() => _selectedFate = fate),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : AppColors.grey500,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final initialDate = _catchTime ?? DateTime.now();
    final datePicked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (datePicked == null || !mounted) return;

    final timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (timePicked == null || !mounted) return;

    setState(() {
      _catchTime = DateTime(
        datePicked.year,
        datePicked.month,
        datePicked.day,
        timePicked.hour,
        timePicked.minute,
      );
    });
  }

  Future<void> _editWeather() async {
    final appSettings = ref.read(appSettingsProvider);
    final temperatureUnit = appSettings.units.temperatureUnit;
    final isChinese = appSettings.language == AppLanguage.chinese;
    final tempSymbol = UnitConverter.getTemperatureSymbol(temperatureUnit,
        isChinese: isChinese);
    final tempController = TextEditingController(
      text: _airTemperature?.toStringAsFixed(1) ?? '',
    );
    final pressureController = TextEditingController(
      text: _pressure?.toStringAsFixed(0) ?? '',
    );
    int? selectedWeatherCode = _weatherCode ?? 0;

    final weatherOptions = [
      (0, widget.strings.weatherOption0),
      (1, widget.strings.weatherOption1),
      (2, widget.strings.weatherOption2),
      (3, widget.strings.weatherOption3),
      (4, widget.strings.weatherOption4),
      (5, widget.strings.weatherOption5),
      (6, widget.strings.weatherOption6),
    ];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(widget.strings.modifyWeather),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tempController,
                decoration: InputDecoration(
                  labelText: '${widget.strings.airTemperature} ($tempSymbol)',
                  border: const OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pressureController,
                decoration: InputDecoration(
                  labelText: '${widget.strings.pressure} (hPa)',
                  border: const OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: selectedWeatherCode,
                decoration: InputDecoration(
                  labelText: widget.strings.weather,
                  border: const OutlineInputBorder(),
                ),
                items: weatherOptions
                    .map((opt) => DropdownMenuItem(
                          value: opt.$1,
                          child: Text(opt.$2),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => selectedWeatherCode = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(widget.strings.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(widget.strings.confirm),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      final temp = double.tryParse(tempController.text);
      final pressure = double.tryParse(pressureController.text);
      setState(() {
        _airTemperature = temp;
        _pressure = pressure;
        _weatherCode = selectedWeatherCode;
      });
    }
    tempController.dispose();
    pressureController.dispose();
  }

  String _getWeatherDisplayText(String temperatureUnit) {
    final s = widget.strings;
    final parts = <String>[];
    if (_airTemperature != null) {
      parts.add(
          '${s.airTemperature}: ${UnitConverter.formatTemperature(_airTemperature!, temperatureUnit)}');
    }
    if (_pressure != null) {
      parts.add('${s.pressure}: ${_pressure!.toStringAsFixed(0)}hPa');
    }
    final simpleWeatherMap = <int, String>{
      0: s.weatherOption0,
      1: s.weatherOption1,
      2: s.weatherOption2,
      3: s.weatherOption3,
      4: s.weatherOption4,
      5: s.weatherOption5,
      6: s.weatherOption6,
    };
    if (_weatherCode != null && simpleWeatherMap.containsKey(_weatherCode)) {
      parts.add('${s.weather}: ${simpleWeatherMap[_weatherCode]}');
    }
    if (parts.isEmpty) return s.notSet;
    return parts.join(' | ');
  }

  Widget _buildLengthField(AppStrings s) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _lengthController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: s.length,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.straighten),
            ),
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: _lengthUnit,
          items: [
            DropdownMenuItem(value: 'cm', child: Text(s.centimeter)),
            DropdownMenuItem(value: 'm', child: Text(s.meter)),
            DropdownMenuItem(value: 'inch', child: Text(s.inch)),
            DropdownMenuItem(value: 'ft', child: Text(s.foot)),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _lengthUnit = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildWeightField(AppStrings s) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '${s.weight} (${s.optional})',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.scale),
            ),
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: _weightUnit,
          items: [
            DropdownMenuItem(value: 'kg', child: Text(s.kilogram)),
            DropdownMenuItem(value: 'g', child: Text(s.gram)),
            DropdownMenuItem(value: 'lb', child: Text(s.pound)),
            DropdownMenuItem(value: 'oz', child: Text(s.ounce)),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _weightUnit = value);
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _speciesController.dispose();
    _lengthController.dispose();
    _weightController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
