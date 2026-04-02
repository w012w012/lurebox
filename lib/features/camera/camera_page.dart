import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/constants.dart';
import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/models/equipment.dart';
import '../../core/models/fish_catch.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/app_settings_provider.dart';
import '../../core/utils/unit_converter.dart';
import '../../core/utils/file_utils.dart';
import '../../core/utils/image_compressor.dart';
import '../../core/camera/camera_view_model.dart';
import '../../core/camera/camera_state.dart';
import '../../core/services/weather_service.dart';

import '../../widgets/common/image_cache_helper.dart';
import '../../widgets/common/premium_button.dart';
import '../../widgets/common/premium_card.dart';
import '../../widgets/common/premium_input.dart';
import '../fish_detail/fish_detail_page.dart';
import '../equipment/equipment_list_page.dart';

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

    return _buildCameraView(state, vm, strings);
  }

  Widget _buildCameraView(
    CameraState state,
    CameraViewModel vm,
    AppStrings strings,
  ) {
    return Scaffold(
      appBar: AppBar(title: Text(strings.recordCatch)),
      body: Column(
        children: [
          Expanded(child: _buildCameraPreview(state, vm, strings)),
          _buildCameraControls(state, vm, strings),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(
    CameraState state,
    CameraViewModel vm,
    AppStrings strings,
  ) {
    if (state.errorMessage != null && !state.isCameraInitialized) {
      return _buildErrorView(state, vm, strings);
    }

    if (!state.isCameraInitialized || state.isLoading) {
      return _buildLoadingView(strings);
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CameraPreview(vm.cameraHelper.cameraController!),
      ),
    );
  }

  Widget _buildErrorView(
    CameraState state,
    CameraViewModel vm,
    AppStrings strings,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'Camera error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            PremiumButton(
              text: strings.retry,
              onPressed: () => vm.initializeCamera(),
              variant: PremiumButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView(AppStrings strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(strings.initializingCamera),
        ],
      ),
    );
  }

  Widget _buildCameraControls(
    CameraState state,
    CameraViewModel vm,
    AppStrings strings,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PremiumIconButton(
            icon: Icons.photo_library,
            onPressed: () => _pickImageFromGallery(vm),
            tooltip: strings.selectFromGallery,
            size: 48,
          ),
          GestureDetector(
            onTap:
                state.isTakingPicture ? null : () => _takePicture(vm, strings),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 4,
                ),
              ),
              child: Center(
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: state.isTakingPicture
                      ? Padding(
                          padding: const EdgeInsets.all(15),
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.surface,
                            strokeWidth: 2,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
          PremiumIconButton(
            icon: Icons.cameraswitch,
            onPressed: state.canSwitchCamera ? () => vm.switchCamera() : null,
            tooltip: strings.switchCamera,
            size: 48,
            color: state.canSwitchCamera
                ? null
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePreview(state),
            const SizedBox(height: 20),
            // Species field with skip button
            _buildSpeciesFieldWithSkipButton(state, vm, strings),
            const SizedBox(height: 16),
            _buildLengthField(strings, state, vm),
            const SizedBox(height: 16),
            _buildWeightField(state, strings, vm),
            const SizedBox(height: 20),
            _buildFateSelector(state, vm, strings),
            const SizedBox(height: 20),
            _buildEquipmentCard(state, vm, strings),
            const SizedBox(height: 20),
            if (state.locationName != null && state.locationName!.isNotEmpty)
              _buildLocationCard(state, strings),
            if (state.airTemperature != null ||
                state.pressure != null ||
                state.weatherCode != null)
              _buildWeatherCard(state, strings),
            _buildTimeCard(state, strings),
            const SizedBox(height: 24),
            _buildSaveButton(state, vm, strings),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(CameraState state) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image(
        image: ImageCacheHelper.getCachedThumbnailProvider(
          state.imagePath,
          width: 400,
          height: 400,
        ),
        height: 200,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildSpeciesFieldWithSkipButton(
    CameraState state,
    CameraViewModel vm,
    AppStrings strings,
  ) {
    // 过滤掉"待识别"等无效品种名
    final validHistory =
        state.speciesHistory.where((s) => s != '待识别' && s.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PremiumTextField(
                controller: _speciesController,
                label: strings.species,
                hint: strings.enterSpeciesName,
                prefixIcon: const Icon(Icons.set_meal),
                enabled: !state.pendingRecognition,
                onChanged: (value) {
                  vm.setSpecies(value);
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: () {
                  if (state.pendingRecognition) {
                    // 切换回正常模式
                    vm.setPendingRecognition(false);
                  } else {
                    _speciesController.text = '';
                    vm.setSpecies('');
                    vm.setPendingRecognition(true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: state.pendingRecognition
                      ? AppColors.warning.withOpacity(0.3)
                      : Theme.of(context).colorScheme.secondary,
                  foregroundColor: state.pendingRecognition
                      ? AppColors.warning
                      : Theme.of(context).colorScheme.onSecondary,
                ),
                child: Text(
                  state.pendingRecognition ? '↩ 取消待识别' : '⏭ 加入待识别',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
        ),
        if (validHistory.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: validHistory.map((species) {
                return Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: state.pendingRecognition
                        ? null
                        : () {
                            _speciesController.text = species;
                            vm.setSpecies(species);
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        species,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildLengthField(
    AppStrings strings,
    CameraState state,
    CameraViewModel vm,
  ) {
    return Row(
      children: [
        Expanded(
          child: PremiumTextField(
            controller: _lengthController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            label: strings.length,
            hint: strings.enterLength,
            prefixIcon: const Icon(Icons.straighten),
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: state.lengthUnit,
          items: [
            DropdownMenuItem(value: 'cm', child: Text(strings.centimeter)),
            DropdownMenuItem(value: 'm', child: Text(strings.meter)),
            DropdownMenuItem(value: 'inch', child: Text(strings.inch)),
            DropdownMenuItem(value: 'ft', child: Text(strings.foot)),
          ],
          onChanged: (value) {
            if (value != null) {
              vm.setLengthUnit(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildWeightField(
    CameraState state,
    AppStrings strings,
    CameraViewModel vm,
  ) {
    double? displayEstimatedWeight;
    if (state.estimatedWeight != null) {
      final lengthInCm = UnitConverter.toBaseCm(state.length, state.lengthUnit);
      final weightInGrams =
          lengthInCm * lengthInCm * lengthInCm * CameraState.weightCoefficient;
      final weightInKg = weightInGrams / 1000;
      displayEstimatedWeight = UnitConverter.convertWeight(
        weightInKg,
        'kg',
        state.weightUnit,
      );
    }

    final unitSymbol = UnitConverter.getWeightSymbol(state.weightUnit);

    return Row(
      children: [
        Expanded(
          child: PremiumTextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            label: '${strings.weight} (${strings.optional})',
            hint: displayEstimatedWeight != null
                ? '${strings.estimated}: ${displayEstimatedWeight.toStringAsFixed(2)} $unitSymbol'
                : strings.enterActualWeight,
            prefixIcon: const Icon(Icons.scale),
            onChanged: (value) {
              final weight = double.tryParse(value);
              ref.read(cameraViewModelProvider.notifier).setWeight(weight);
            },
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: state.weightUnit,
          items: [
            DropdownMenuItem(value: 'kg', child: Text(strings.kilogram)),
            DropdownMenuItem(value: 'g', child: Text(strings.gram)),
            DropdownMenuItem(value: 'lb', child: Text(strings.pound)),
            DropdownMenuItem(value: 'oz', child: Text(strings.ounce)),
          ],
          onChanged: (value) {
            if (value != null) {
              vm.setWeightUnit(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildFateSelector(
    CameraState state,
    CameraViewModel vm,
    AppStrings strings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.fate, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _FateButton(
                label: '🐟 ${strings.release}',
                isSelected: state.fate == FishFateType.release,
                color: AppColors.success,
                onTap: () => vm.setFate(FishFateType.release),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FateButton(
                label: '🍳 ${strings.keep}',
                isSelected: state.fate == FishFateType.keep,
                color: AppColors.warning,
                onTap: () => vm.setFate(FishFateType.keep),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEquipmentCard(
    CameraState state,
    CameraViewModel vm,
    AppStrings strings,
  ) {
    return PremiumCard(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.hardware,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(strings.useEquipment),
            trailing: PremiumButton(
              text: strings.modify,
              onPressed: () => _showEquipmentSheet(state, vm, strings),
              variant: PremiumButtonVariant.text,
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _EquipmentInfoRow(
                  label: '🎣 ${strings.rod}',
                  equipment: state.selectedRod,
                ),
                const SizedBox(height: 8),
                _EquipmentInfoRow(
                  label: '⚙️ ${strings.reel}',
                  equipment: state.selectedReel,
                ),
                const SizedBox(height: 8),
                _EquipmentInfoRow(
                  label: '🪝 ${strings.lure}',
                  equipment: state.selectedLure,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEquipmentSheet(
    CameraState state,
    CameraViewModel vm,
    AppStrings strings,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        Equipment? tempSelectedRod = state.selectedRod;
        Equipment? tempSelectedReel = state.selectedReel;
        Equipment? tempSelectedLure = state.selectedLure;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        strings.selectEquipment,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      PremiumButton(
                        text: strings.addEquipment,
                        icon: Icons.add,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EquipmentListPage(),
                            ),
                          ).then((_) => vm.loadEquipments());
                        },
                        variant: PremiumButtonVariant.text,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildEquipmentSection(
                    context: context,
                    title: '🎣 ${strings.rod}',
                    items: state.rods,
                    selected: tempSelectedRod,
                    onSelected: (equipment) {
                      setModalState(() => tempSelectedRod = equipment);
                      vm.setSelectedRod(equipment);
                    },
                  ),
                  _buildEquipmentSection(
                    context: context,
                    title: '⚙️ ${strings.reel}',
                    items: state.reels,
                    selected: tempSelectedReel,
                    onSelected: (equipment) {
                      setModalState(() => tempSelectedReel = equipment);
                      vm.setSelectedReel(equipment);
                    },
                  ),
                  _buildEquipmentSection(
                    context: context,
                    title: '🪝 ${strings.lure}',
                    items: state.lures,
                    selected: tempSelectedLure,
                    onSelected: (equipment) {
                      setModalState(() => tempSelectedLure = equipment);
                      vm.setSelectedLure(equipment);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEquipmentSection({
    required BuildContext context,
    required String title,
    required List<Equipment> items,
    required Equipment? selected,
    required ValueChanged<Equipment?> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const Text('暂无装备')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((equipment) {
              final isSelected = selected?.id == equipment.id;
              return FilterChip(
                label: Text(equipment.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  onSelected(selected ? equipment : null);
                },
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
              );
            }).toList(),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLocationCard(CameraState state, AppStrings strings) {
    return PremiumCard(
      child: ListTile(
        leading: Icon(
          Icons.location_on,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(strings.catchLocation),
        subtitle: Text(state.locationName ?? '未获取位置'),
        trailing: IconButton(
          icon: const Icon(Icons.edit, size: 20),
          onPressed: () => _editLocation(state),
          tooltip: '修改位置',
        ),
      ),
    );
  }

  Widget _buildTimeCard(CameraState state, AppStrings strings) {
    return PremiumCard(
      child: ListTile(
        leading: Icon(
          Icons.access_time,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(strings.catchTime),
        subtitle: Text(DateFormat(DateFormats.dateTime).format(
          state.catchTime ?? DateTime.now(),
        )),
        trailing: IconButton(
          icon: const Icon(Icons.edit, size: 20),
          onPressed: () => _editCatchTime(state),
          tooltip: '修改时间',
        ),
      ),
    );
  }

  Widget _buildWeatherCard(CameraState state, AppStrings strings) {
    final weatherTexts = <String>[];
    if (state.airTemperature != null) {
      weatherTexts.add('气温: ${state.airTemperature!.toStringAsFixed(1)}°C');
    }
    if (state.pressure != null) {
      weatherTexts.add('气压: ${state.pressure!.toStringAsFixed(0)}hPa');
    }
    if (state.weatherCode != null) {
      final weatherDesc = getWeatherDescription(state.weatherCode);
      if (weatherDesc.isNotEmpty) {
        weatherTexts.add('天气: $weatherDesc');
      }
    }

    return PremiumCard(
      child: ListTile(
        leading: Icon(
          Icons.wb_sunny,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('天气'),
        subtitle:
            Text(weatherTexts.isNotEmpty ? weatherTexts.join(' | ') : '未获取天气'),
        trailing: IconButton(
          icon: const Icon(Icons.edit, size: 20),
          onPressed: () => _editWeather(state),
          tooltip: '修改天气',
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
        // 导航到详情页后再重置状态，避免状态污染
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FishDetailPage(fishId: fishId),
          ),
        );
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

class _FateButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FateButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.2)
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
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? color
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

class _EquipmentInfoRow extends StatelessWidget {
  final String label;
  final Equipment? equipment;

  const _EquipmentInfoRow({required this.label, this.equipment});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const Spacer(),
        Text(
          equipment?.displayName ?? '-',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
