import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/services/backup_service.dart';
import 'package:lurebox/core/services/backup_zip_service.dart';
import 'package:lurebox/core/services/export_service.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';
import 'package:share_plus/share_plus.dart';

class SettingsState {

  const SettingsState({
    this.isLoading = false,
    this.errorMessage,
    this.totalCount = 0,
    this.appVersion = '1.0.5',
    this.isExporting = false,
    this.isImporting = false,
    this.isUploading = false,
    this.isCreatingZipBackup = false,
    this.isRestoringZipBackup = false,
    this.exportPath,
    this.errorDetail,
  });
  final bool isLoading;
  final String? errorMessage;
  final int totalCount;
  final String appVersion;
  final bool isExporting;
  final bool isImporting;
  final bool isUploading;
  final bool isCreatingZipBackup;
  final bool isRestoringZipBackup;
  final String? exportPath;
  final String? errorDetail;

  SettingsState copyWith({
    bool? isLoading,
    String? Function()? errorMessage,
    int? totalCount,
    String? appVersion,
    bool? isExporting,
    bool? isImporting,
    bool? isUploading,
    bool? isCreatingZipBackup,
    bool? isRestoringZipBackup,
    String? Function()? exportPath,
    String? Function()? errorDetail,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      totalCount: totalCount ?? this.totalCount,
      appVersion: appVersion ?? this.appVersion,
      isExporting: isExporting ?? this.isExporting,
      isImporting: isImporting ?? this.isImporting,
      isUploading: isUploading ?? this.isUploading,
      isCreatingZipBackup: isCreatingZipBackup ?? this.isCreatingZipBackup,
      isRestoringZipBackup: isRestoringZipBackup ?? this.isRestoringZipBackup,
      exportPath: exportPath != null ? exportPath() : this.exportPath,
      errorDetail: errorDetail != null ? errorDetail() : this.errorDetail,
    );
  }
}

class SettingsViewModel extends StateNotifier<SettingsState> {

  SettingsViewModel(
    this._backupService,
    this._backupZipService,
    this._fishCatchService,
  ) : super(const SettingsState()) {
    loadStats();
  }
  final BackupService _backupService;
  final BackupZipService _backupZipService;
  final FishCatchService _fishCatchService;

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final count = await _fishCatchService.getCount();
      state = state.copyWith(isLoading: false, totalCount: count);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString);
    }
  }

  Future<String?> exportData() async {
    state = state.copyWith(isExporting: true, errorMessage: () => null);
    try {
      final path = await _backupService.exportToJson();
      state = state.copyWith(isExporting: false, exportPath: () => path);
      return path;
    } catch (e) {
      state = state.copyWith(isExporting: false, errorMessage: e.toString);
      return null;
    }
  }

  Future<XFile?> exportDataWithFormat(
      {ExportFormat format = ExportFormat.json,}) async {
    state = state.copyWith(isExporting: true, errorMessage: () => null);
    try {
      final catches = await _fishCatchService.getAll();
      final xFile = await ExportService.exportToFile(
        catches: catches,
        format: format,
      );
      state = state.copyWith(isExporting: false);
      return xFile;
    } catch (e) {
      state = state.copyWith(isExporting: false, errorMessage: e.toString);
      return null;
    }
  }

  Future<int?> importData(String filePath) async {
    state = state.copyWith(isImporting: true, errorMessage: () => null);
    try {
      final count = await _backupService.importFromJson(filePath);
      state = state.copyWith(isImporting: false);
      await loadStats();
      return count;
    } catch (e) {
      state = state.copyWith(isImporting: false, errorMessage: e.toString);
      return null;
    }
  }

  Future<String?> uploadToWebDAV({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isUploading: true, errorMessage: () => null);
    try {
      final url = await _backupService.uploadToWebDAV(
        serverUrl: serverUrl,
        username: username,
        password: password,
      );
      state = state.copyWith(isUploading: false);
      return url;
    } catch (e) {
      state = state.copyWith(isUploading: false, errorMessage: e.toString);
      return null;
    }
  }

  Future<XFile?> exportZipBackup({bool includePhotos = true}) async {
    state = state.copyWith(isCreatingZipBackup: true, errorMessage: () => null);
    try {
      final options = BackupExportOptions(
        includePhotos: includePhotos,
        createRecoveryPoint: true,
      );
      final xFile = await _backupZipService.exportToZip(options: options);
      state = state.copyWith(isCreatingZipBackup: false);
      return xFile;
    } catch (e) {
      state = state.copyWith(
        isCreatingZipBackup: false,
        errorMessage: e.toString,
      );
      return null;
    }
  }

  /// 开始完整备份（后台运行，保存到文档目录）
  ///
  /// 备份完成后，用户可以在"导出和备份管理"页面查看和管理备份文件
  Future<String?> startZipBackup({bool includePhotos = true}) async {
    state = state.copyWith(isCreatingZipBackup: true, errorMessage: () => null);
    try {
      final options = BackupExportOptions(
        includePhotos: includePhotos,
        createRecoveryPoint: true,
      );
      final savedPath =
          await _backupZipService.exportToZipAndSave(options: options);
      state = state.copyWith(isCreatingZipBackup: false);
      return savedPath;
    } catch (e) {
      state = state.copyWith(
        isCreatingZipBackup: false,
        errorMessage: e.toString,
      );
      return null;
    }
  }

  Future<ImportResult> importZipBackup() async {
    state = state.copyWith(isRestoringZipBackup: true, errorMessage: () => null);
    try {
      final result = await _backupZipService.importFromZip();
      state = state.copyWith(isRestoringZipBackup: false);
      await loadStats();
      return result;
    } catch (e) {
      state = state.copyWith(
        isRestoringZipBackup: false,
        errorMessage: e.toString,
      );
      return ImportResult.failure(e.toString());
    }
  }

  void clearExportPath() {
    state = state.copyWith(exportPath: () => null);
  }

  void clearError() {
    state = state.copyWith(errorMessage: () => null, errorDetail: () => null);
  }

  void setError(String message, {String? detail}) {
    if (detail != null) {
      state = state.copyWith(
        errorMessage: () => message,
        errorDetail: () => detail,
      );
    } else {
      state = state.copyWith(
        errorMessage: () => message,
        errorDetail: () => null,
      );
    }
  }
}

final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, SettingsState>((ref) {
  return SettingsViewModel(
    ref.read(backupServiceProvider),
    ref.read(backupZipServiceProvider),
    ref.read(fishCatchServiceProvider),
  );
});
