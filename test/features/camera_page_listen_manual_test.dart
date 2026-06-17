import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/features/camera/services/camera_state.dart';
import 'package:lurebox/features/camera/services/camera_view_model.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/models/watermark_settings.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/services/equipment_service.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';
import 'package:lurebox/core/services/settings_service.dart';
import 'package:lurebox/features/camera/camera_page.dart';

import '../helpers/test_helpers.dart';

/// 提供可控 AppSettings 的服务替身。
class _MockSettingsService implements SettingsService {
  const _MockSettingsService();

  @override
  Future<AppSettings> getAppSettings() async => const AppSettings();
  @override
  Future<void> saveAppSettings(AppSettings settings) async {}
  @override
  Future<WatermarkSettings> getWatermarkSettings() async =>
      const WatermarkSettings();
  @override
  Future<void> saveWatermarkSettings(WatermarkSettings settings) async {}
  @override
  Future<AiRecognitionSettings> getAiRecognitionSettings() async =>
      const AiRecognitionSettings();
  @override
  Future<void> saveAiRecognitionSettings(AiRecognitionSettings s) async {}
  @override
  Future<void> deleteAiRecognitionSettings() async {}
}

/// 不触碰相机硬件的 CameraViewModel 替身，记录 initializeUnits 调用。
class _FakeCameraViewModel extends CameraViewModel {
  _FakeCameraViewModel()
      : super(
          FishCatchService(
            MockFishCatchRepository(),
            MockSpeciesHistoryRepository(),
            MockStatsRepository(),
          ),
          EquipmentService(MockEquipmentRepository()),
          AppStrings.chinese,
        );

  final List<UnitSettings> initializeUnitsCalls = [];

  @override
  Future<void> initializeCamera() async {}
  @override
  Future<void> switchCamera() async {}
  @override
  Future<void> loadSpeciesHistory() async {}
  @override
  Future<void> loadEquipments() async {}
  @override
  Future<void> getLocation() async {}

  @override
  void initializeUnits(UnitSettings settings) {
    initializeUnitsCalls.add(settings);
    super.initializeUnits(settings);
  }
}

void main() {
  setUpAll(() {
    setUpDatabaseForTesting();
    registerFallbackValues();
  });

  // FIX 1 (H-1): initState 内不能用 ref.listen（debug 断言失败 / release 失效），
  // 已改为 ref.listenManual。验证：进入页面后修改 appSettings 单位时，
  // ViewModel.initializeUnits 会被触发，且全程无异常。
  testWidgets(
      'CameraPage listens to unit changes via listenManual without throwing',
      (tester) async {
    final fakeVm = _FakeCameraViewModel();
    late AppSettingsNotifier settingsNotifier;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentStringsProvider.overrideWithValue(AppStrings.chinese),
          cameraViewModelProvider.overrideWith((ref) => fakeVm),
          appSettingsProvider.overrideWith((ref) {
            settingsNotifier =
                AppSettingsNotifier(const _MockSettingsService());
            return settingsNotifier;
          }),
        ],
        child: const MaterialApp(home: CameraPage()),
      ),
    );

    // 触发 post-frame _initialize 与 listenManual 注册
    await tester.pump();
    final callsAfterInit = fakeVm.initializeUnitsCalls.length;

    // 修改单位设置 → listenManual 回调应触发 initializeUnits
    await settingsNotifier.updateUnits(
      const UnitSettings(fishLengthUnit: 'inch', fishWeightUnit: 'lb'),
    );
    await tester.pump();

    expect(
      fakeVm.initializeUnitsCalls.length,
      greaterThan(callsAfterInit),
      reason: 'listenManual 回调应在单位变化时调用 initializeUnits',
    );
    expect(fakeVm.initializeUnitsCalls.last.fishLengthUnit, 'inch');
    expect(fakeVm.initializeUnitsCalls.last.fishWeightUnit, 'lb');

    // 没有 ref.listen-in-initState 的断言异常
    expect(tester.takeException(), isNull);
  });
}
