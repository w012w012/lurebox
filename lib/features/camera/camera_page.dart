import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/strings.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/app_settings_provider.dart';
import '../../core/utils/file_utils.dart';
import '../../core/utils/image_compressor.dart';
import '../../core/camera/camera_view_model.dart';
import '../../core/camera/camera_state.dart';

import '../../widgets/common/image_cache_helper.dart';
import '../../widgets/common/premium_button.dart';
import '../../widgets/catch/equipment_rig_card.dart';
import '../../widgets/catch/auxiliary_info_row.dart';
import '../../widgets/catch/species_input_card.dart';
import '../../widgets/catch/length_input_field.dart';
import '../../widgets/catch/weight_input_field.dart';
import '../../widgets/catch/fate_selector_card.dart';
import '../../widgets/catch/equipment_selection_sheet.dart';
import '../../widgets/camera/camera_view_widget.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  final _speciesController = TextEditingController();
  final _lengthController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
    _lengthController.addListener(_onLengthChanged);
  }

  Future<void> _initialize() async {
    final vm = ref.read(cameraViewModelProvider.notifier);
    final appSettings = ref.read(appSettingsProvider);

    // 初始化 context，用于权限对话框
    vm.initialize(context);

    // 重置相机状态，确保每次进入页面都是干净状态
    vm.reset();
    vm.initializeUnits(appSettings.units);

    // 并行初始化，提高启动速度
    await Future.wait([
      vm.initializeCamera().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('相机初始化超时'),
          ),
      vm.loadSpeciesHistory().timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('加载物种历史超时'),
          ),
      vm.loadEquipments().timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('加载装备超时'),
          ),
      vm.getLocation().timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('获取位置超时'),
          ),
    ]);
  }

  void _onLengthChanged() {
    final text = _lengthController.text.trim();
    final length = double.tryParse(text);
    if (length != null && length > 0) {
      ref.read(cameraViewModelProvider.notifier).setLength(length);
    }
  }

  @override
  void dispose() {
    // 释放相机资源
    final vm = ref.read(cameraViewModelProvider.notifier);
    vm.disposeCamera();

    _lengthController.removeListener(_onLengthChanged);
    _speciesController.dispose();
    _lengthController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cameraViewModelProvider);
    final vm = ref.read(cameraViewModelProvider.notifier);
    final strings = ref.watch(currentStringsProvider);
    final appSettings = ref.watch(appSettingsProvider);

    final settingsUnits = appSettings.units;

    if (state.lengthUnit != settingsUnits.fishLengthUnit ||
        state.weightUnit != settingsUnits.fishWeightUnit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.initializeUnits(settingsUnits);
      });
    }

    if (state.captureState == CameraCaptureState.pictureTaken) {
      return _buildFormView(state, vm, strings);
    }

    return CameraViewWidget(
      state: state,
      vm: vm,
      strings: strings,
      onPickFromGallery: () => _pickImageFromGallery(vm),
      onTakePicture: () => _takePicture(vm, strings),
    );
  }

  Future<void> _pickImageFromGallery(CameraViewModel vm) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = FileUtils.generateTimestampFileName('jpg');
      final newPath = '${appDir.path}/$fileName';
      await File(pickedFile.path).copy(newPath);
      vm.setImagePath(newPath);
    }
  }

  Future<void> _takePicture(CameraViewModel vm, AppStrings strings) async {
    final path = await vm.takePicture();
    if (path == null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.cameraNotReady)));
    }
  }

  Widget _buildFormView(
    CameraState state,
    CameraViewModel vm,
    AppStrings strings,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.recordCatch),
        actions: [
          PremiumButton(
            text: strings.retake,
            onPressed: () {
              vm.clearImage();
            },
            variant: PremiumButtonVariant.text,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          final isTablet = constraints.maxWidth >= 600;

          // Landscape or tablet: use two-column layout
          if (isLandscape || isTablet) {
            return _buildLandscapeFormView(state, vm, strings, constraints);
          }

          // Mobile portrait: original single-column layout
          return _buildPortraitFormView(state, vm, strings);
        },
      ),
    );
  }

  Widget _buildPortraitFormView(
    CameraState state,
    CameraViewModel vm,
    AppStrings strings,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImagePreview(state),
          const SizedBox(height: 20),
          SpeciesInputCard(
            state: state,
            vm: vm,
            strings: strings,
            controller: _speciesController,
          ),
          const SizedBox(height: 16),
          LengthInputField(
            state: state,
            vm: vm,
            strings: strings,
            controller: _lengthController,
          ),
          const SizedBox(height: 16),
          WeightInputField(
            state: state,
            vm: vm,
            strings: strings,
            controller: _weightController,
          ),
          const SizedBox(height: 20),
          FateSelectorCard(
            state: state,
            vm: vm,
            strings: strings,
          ),
          const SizedBox(height: 20),
          EquipmentRigCard(
            state: state,
            vm: vm,
            strings: strings,
            onModifyPressed: () =>
                EquipmentSelectionSheet.show(context, state, vm, strings),
          ),
          const SizedBox(height: 20),
          AuxiliaryInfoRow(
            state: state,
            vm: vm,
            strings: strings,
            onEditLocation: () => _editLocation(state),
            onEditTime: () => _editCatchTime(state),
            onEditWeather: () => _editWeather(state),
          ),
          const SizedBox(height: 24),
          _buildSaveButton(state, vm, strings),
        ],
      ),
    );
  }

  Widget _buildLandscapeFormView(
    CameraState state,
    CameraViewModel vm,
    AppStrings strings,
    BoxConstraints constraints,
  ) {
    final contentWidth = constraints.maxWidth >= 900
        ? constraints.maxWidth * 0.4
        : constraints.maxWidth * 0.5;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: Image preview
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildImagePreview(state, isLandscape: true),
                const SizedBox(height: 16),
                AuxiliaryInfoRow(
                  state: state,
                  vm: vm,
                  strings: strings,
                  onEditLocation: () => _editLocation(state),
                  onEditTime: () => _editCatchTime(state),
                  onEditWeather: () => _editWeather(state),
                ),
              ],
            ),
          ),
        ),
        // Right side: Form fields
        SizedBox(
          width: contentWidth,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SpeciesInputCard(
                  state: state,
                  vm: vm,
                  strings: strings,
                  controller: _speciesController,
                ),
                const SizedBox(height: 12),
                LengthInputField(
                  state: state,
                  vm: vm,
                  strings: strings,
                  controller: _lengthController,
                ),
                const SizedBox(height: 12),
                WeightInputField(
                  state: state,
                  vm: vm,
                  strings: strings,
                  controller: _weightController,
                ),
                const SizedBox(height: 16),
                FateSelectorCard(
                  state: state,
                  vm: vm,
                  strings: strings,
                ),
                const SizedBox(height: 16),
                EquipmentRigCard(
                  state: state,
                  vm: vm,
                  strings: strings,
                  onModifyPressed: () =>
                      EquipmentSelectionSheet.show(context, state, vm, strings),
                ),
                const SizedBox(height: 20),
                _buildSaveButton(state, vm, strings),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(CameraState state, {bool isLandscape = false}) {
    final previewHeight = isLandscape ? 150.0 : 200.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: previewHeight,
        child: Image(
          image: ImageCacheHelper.getCachedThumbnailProvider(
            state.imagePath,
            width: 400,
            height: 400,
          ),
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              highlightColor: Theme.of(context).colorScheme.surface,
              child: Container(
                height: previewHeight,
                color: Colors.white,
              ),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            height: previewHeight,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.image,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 50,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(
    CameraState state,
    CameraViewModel vm,
    AppStrings strings,
  ) {
    final isSaving = state.captureState == CameraCaptureState.saving;

    return PremiumButton(
      text: strings.confirmSave,
      onPressed: isSaving ? null : () => _saveFishCatch(state, vm, strings),
      variant: PremiumButtonVariant.primary,
      isLoading: isSaving,
      isFullWidth: true,
      padding: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  Future<void> _saveFishCatch(
    CameraState state,
    CameraViewModel vm,
    AppStrings strings,
  ) async {
    if (state.imagePath == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.takePhotoFirst)));
      return;
    }

    if (state.species.isEmpty && !state.pendingRecognition) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.enterSpecies)));
      return;
    }

    if (state.length <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.enterValidLength)));
      return;
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = FileUtils.generateTimestampFileName('jpg');
      final newPath = '${appDir.path}/$fileName';

      // 使用图像压缩工具压缩图像
      await ImageCompressor.compressImage(
        inputPath: state.imagePath!,
        outputPath: newPath,
        quality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      vm.setImagePath(newPath);
      final fishId = await vm.saveFishCatch();

      if (fishId != null && fishId > 0 && mounted) {
        context.pushReplacement('/fish/$fishId');
      } else if (fishId == null || fishId <= 0) {
        // 从 viewModel 读取最新的错误信息
        final currentState = ref.read(cameraViewModelProvider);
        final errorFromState = currentState.errorMessage;

        // 重置 captureState 到 pictureTaken，让用户留在表单页面
        vm.resetCaptureStateToForm();
        if (mounted) {
          // 显示 viewModel 中的错误信息
          final debugInfo = '保存失败: fishId=$fishId\n'
              '${errorFromState != null ? '错误: $errorFromState\n' : ''}'
              'imagePath: ${state.imagePath != null ? "已设置" : "未设置"}\n'
              'species: "${state.species}" (empty: ${state.species.isEmpty})\n'
              'length: ${state.length}';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(
            content: Text(debugInfo),
            duration: const Duration(seconds: 15),
          ));
        }
      }
    } catch (e) {
      vm.resetCaptureStateToForm();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    }
  }

  // ===== Edit Methods =====

  Future<void> _editLocation(CameraState state) async {
    final controller = TextEditingController(text: state.locationName ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改钓获地点'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '地点名称',
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
              final name = controller.text.trim();
              if (name.isNotEmpty) Navigator.pop(context, name);
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
    if (result != null && mounted) {
      ref.read(cameraViewModelProvider.notifier).setLocationName(result);
    }
    controller.dispose();
  }

  Future<void> _editCatchTime(CameraState state) async {
    final initialTime = state.catchTime ?? DateTime.now();
    DateTime selectedDate = initialTime;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(initialTime);

    final datePicked = await showDatePicker(
      context: context,
      initialDate: initialTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (datePicked == null || !mounted) return;
    selectedDate = datePicked;

    final timePicked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (timePicked == null || !mounted) return;
    selectedTime = timePicked;

    final newTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    ref.read(cameraViewModelProvider.notifier).setCatchTime(newTime);
  }

  Future<void> _editWeather(CameraState state) async {
    final tempController = TextEditingController(
      text: state.airTemperature?.toStringAsFixed(1) ?? '',
    );
    final pressureController = TextEditingController(
      text: state.pressure?.toStringAsFixed(0) ?? '',
    );
    int? selectedWeatherCode = state.weatherCode ?? 0;

    final weatherOptions = [
      (0, '☀️ 晴'),
      (1, '⛅ 多云'),
      (2, '☁️ 阴'),
      (3, '🌧️ 小雨'),
      (4, '⛈️ 雷暴'),
      (5, '❄️ 雪'),
      (6, '🌫️ 雾'),
    ];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('修改天气信息'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tempController,
                  decoration: const InputDecoration(
                    labelText: '气温 (°C)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pressureController,
                  decoration: const InputDecoration(
                    labelText: '气压 (hPa)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedWeatherCode,
                  decoration: const InputDecoration(
                    labelText: '天气状况',
                    border: OutlineInputBorder(),
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
      ),
    );

    if (confirmed == true && mounted) {
      final temp = double.tryParse(tempController.text);
      final pressure = double.tryParse(pressureController.text);
      final vm = ref.read(cameraViewModelProvider.notifier);
      if (temp != null) vm.setAirTemperature(temp);
      if (pressure != null) vm.setPressure(pressure);
      vm.setWeatherCode(selectedWeatherCode);
    }
    tempController.dispose();
    pressureController.dispose();
  }
}
