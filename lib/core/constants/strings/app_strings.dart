import 'package:lurebox/core/constants/strings/achievement_strings.dart';
import 'package:lurebox/core/constants/strings/camera_strings.dart';
import 'package:lurebox/core/constants/strings/catch_strings.dart';
import 'package:lurebox/core/constants/strings/common_strings.dart';
import 'package:lurebox/core/constants/strings/en_strings.dart';
import 'package:lurebox/core/constants/strings/equipment_strings.dart';
import 'package:lurebox/core/constants/strings/error_strings.dart';
import 'package:lurebox/core/constants/strings/export_strings.dart';
import 'package:lurebox/core/constants/strings/location_strings.dart';
import 'package:lurebox/core/constants/strings/onboarding_strings.dart';
import 'package:lurebox/core/constants/strings/settings_strings.dart';
import 'package:lurebox/core/constants/strings/stats_strings.dart';
import 'package:lurebox/core/constants/strings/strings_base.dart';
import 'package:lurebox/core/constants/strings/watermark_strings.dart';
import 'package:lurebox/core/constants/strings/weather_strings.dart';
import 'package:lurebox/core/constants/strings/zh_strings.dart';

/// Language string constants
class AppStrings extends StringsBase with
    CommonStringsMixin,
    CatchStringsMixin,
    EquipmentStringsMixin,
    CameraStringsMixin,
    StatsStringsMixin,
    WeatherStringsMixin,
    WatermarkStringsMixin,
    ExportStringsMixin,
    SettingsStringsMixin,
    ErrorStringsMixin,
    AchievementStringsMixin,
    LocationStringsMixin,
    OnboardingStringsMixin {

  const AppStrings({
    required this.appName,
    required this.home,
    required this.fishList,
    required this.equipment,
    required this.achievement,
    required this.viewAchievements,
    required this.me,
    required this.settings,
    required this.dataManagement,
    required this.appearanceSettings,
    required this.appearanceSettingsDesc,
    required this.fishCount,
    required this.release,
    required this.keep,
    required this.releaseRate,
    required this.species,
    required this.length,
    required this.weight,
    required this.location,
    required this.time,
    required this.rod,
    required this.reel,
    required this.lure,
    required this.rodLength,
    required this.rodHardness,
    required this.rodAction,
    required this.rodMaterial,
    required this.weightRange,
    required this.reelRatio,
    required this.reelCapacity,
    required this.reelBrakeType,
    required this.reelWeight,
    required this.reelWeightHint,
    required this.line,
    required this.lureType,
    required this.lureWeight,
    required this.lureSize,
    required this.lureColor,
    required this.todayCatch,
    required this.monthCatch,
    required this.yearCatch,
    required this.allCatch,
    required this.personalRecord,
    required this.noData,
    required this.noCatchYet,
    required this.goCatchFish,
    required this.recordCatch,
    required this.edit,
    required this.share,
    required this.template,
    required this.showStats,
    required this.showHashtags,
    required this.showWatermark,
    required this.delete,
    required this.save,
    required this.cancel,
    required this.confirm,
    required this.loading,
    required this.error,
    required this.retry,
    required this.about,
    required this.version,
    required this.unitSettings,
    required this.lengthUnit,
    required this.weightUnit,
    required this.unit,
    required this.darkMode,
    required this.language,
    required this.watermarkSettings,
    required this.watermarkSettingsDesc,
    required this.watermarkManagement,
    required this.watermarkManagementDesc,
    required this.backupAndExport,
    required this.backupAndExportDesc,
    required this.fileManagement,
    required this.fileManagementDesc,
    required this.exportCsv,
    required this.exportCsvDesc,
    required this.fullBackup,
    required this.fullBackupDesc,
    required this.restoreBackup,
    required this.restoreBackupDesc,
    required this.watermarkEnabled,
    required this.watermarkDisabled,
    required this.displayInfo,
    required this.dataBackup,
    required this.webdavBackup,
    required this.exportData,
    required this.importData,
    required this.exportTo,
    required this.importFrom,
    required this.serverAddress,
    required this.username,
    required this.password,
    required this.connect,
    required this.exportSuccess,
    required this.importSuccess,
    required this.exportFailed,
    required this.importFailed,
    required this.connectFailed,
    required this.connecting,
    required this.connected,
    required this.disconnected,
    required this.connectSuccess,
    required this.exportFunction,
    required this.importFunction,
    required this.webdavFunction,
    required this.connectWebdav,
    required this.serverAddressHint,
    required this.usernameHint,
    required this.passwordHint,
    required this.exportDataHint,
    required this.importDataHint,
    required this.speciesDistribution,
    required this.trendAnalysis,
    required this.locationAnalysis,
    required this.equipmentDistribution,
    required this.fishDetail,
    required this.totalWeight,
    required this.status,
    required this.today,
    required this.month,
    required this.year,
    required this.all,
    required this.byDay,
    required this.byMonth,
    required this.byYear,
    required this.last30Days,
    required this.last12Months,
    required this.yearlyTrend,
    required this.hourlyTrend,
    required this.dailyTrend,
    required this.monthlyTrend,
    required this.fishRod,
    required this.fishReel,
    required this.fishLure,
    required this.protectionEcology,
    required this.reasonableRelease,
    required this.fromLureBox,
    required this.fishCountUnit,
    required this.hour,
    required this.day,
    required this.monthUnit,
    required this.yearUnit,
    required this.total,
    required this.quantity,
    required this.search,
    required this.searchHint,
    required this.selectDateRange,
    required this.custom,
    required this.confirmDelete,
    required this.confirmDeleteSelected,
    required this.records,
    required this.selected,
    required this.items,
    required this.selectAll,
    required this.thisWeek,
    required this.thisMonth,
    required this.thisYear,
    required this.fate,
    required this.clearFilters,
    required this.filterActive,
    required this.expandFilter,
    required this.filter,
    required this.done,
    required this.noFishFound,
    required this.noMatchFound,
    required this.cameraNotReady,
    required this.switchCameraFailed,
    required this.takePhotoFirst,
    required this.enterSpecies,
    required this.enterValidLength,
    required this.enterValidWeight,
    required this.saveFailed,
    required this.switchCamera,
    required this.initializingCamera,
    required this.retake,
    required this.enterSpeciesName,
    required this.enterLength,
    required this.optional,
    required this.estimated,
    required this.estimatedWeight,
    required this.enterActualWeight,
    required this.useEquipment,
    required this.modify,
    required this.catchLocation,
    required this.catchTime,
    required this.confirmSave,
    required this.cameraPermissionRequired,
    required this.noCameraFound,
    required this.cameraInitFailed,
    required this.cameraControllerInitFailed,
    required this.cameraTakePictureFailed,
    required this.centimeter,
    required this.inch,
    required this.kilogram,
    required this.pound,
    required this.meter,
    required this.foot,
    required this.gram,
    required this.ounce,
    required this.kilometer,
    required this.mile,
    required this.celsius,
    required this.fahrenheit,
    required this.temperature,
    required this.millimeter,
    required this.unitsSettings,
    required this.followSystem,
    required this.off,
    required this.on,
    required this.simplifiedChinese,
    required this.enabled,
    required this.disabled,
    required this.locationManagement,
    required this.locationManagementDesc,
    required this.speciesManagement,
    required this.speciesManagementDesc,
    required this.aiConfiguration,
    required this.aiConfigurationDesc,
    required this.exportAndBackupManagement,
    required this.exportAndBackupManagementDesc,
    required this.syncToCloud,
    required this.exportToLocal,
    required this.importFromLocal,
    required this.appDescription,
    required this.features,
    required this.gotIt,
    required this.webdavSettings,
    required this.noAchievementData,
    required this.completed,
    required this.specialAchievement,
    required this.completion,
    required this.achievementOverview,
    required this.unlocked,
    required this.totalAchievements,
    required this.achievementUnit,
    required this.remainingAchievements,
    required this.noAchievements,
    required this.achieved,
    required this.editEquipment,
    required this.addEquipment,
    required this.basicInfo,
    required this.brand,
    required this.brandHint,
    required this.model,
    required this.modelHint,
    required this.price,
    required this.priceHint,
    required this.invalidPrice,
    required this.priceTooHigh,
    required this.purchaseDate,
    required this.tapToSelect,
    required this.setDefault,
    required this.autoAssociate,
    required this.rodParameters,
    required this.gunHandle,
    required this.spinningHandle,
    required this.handleType,
    required this.handleTypeHint,
    required this.usageType,
    required this.selectOrEnterUsage,
    required this.reelParameters,
    required this.baitcaster,
    required this.spinningReel,
    required this.reelType,
    required this.reelTypeHint,
    required this.reelUsageHint,
    required this.lineInfo,
    required this.brandAndName,
    required this.lineBrandHint,
    required this.lineNumber,
    required this.lineNumberHint,
    required this.lineLength,
    required this.lineLengthHint,
    required this.lineDate,
    required this.lureParameters,
    required this.type,
    required this.selectOrEnterType,
    required this.myEquipment,
    required this.expandAll,
    required this.collapseAll,
    required this.noEquipmentYet,
    required this.noEquipmentAddHint,
    required this.confirmDeleteEquipment,
    required this.defaultLabel,
    required this.unnamed,
    required this.record,
    required this.selectEquipment,
    required this.manageEquipment,
    required this.notSelected,
    required this.lengthHint,
    required this.sections,
    required this.sectionsHint,
    required this.material,
    required this.materialHint,
    required this.hardness,
    required this.hardnessHint,
    required this.action,
    required this.actionHint,
    required this.weightRangeHint,
    required this.bearings,
    required this.bearingsHint,
    required this.jointType,
    required this.jointTypeHint,
    required this.ratio,
    required this.ratioHint,
    required this.ratioFront,
    required this.ratioBack,
    required this.capacityHint,
    required this.capacityLineUnit,
    required this.brakeTypeHint,
    required this.lineType,
    required this.lineTypeHint,
    required this.lureTypeHint,
    required this.lureWeightHint,
    required this.lureSizeHint,
    required this.lureColorHint,
    required this.size,
    required this.selectAtLeast2Locations,
    required this.confirmMerge,
    required this.mergeLocationsTo,
    required this.mergedLocations,
    required this.mergeSuccess,
    required this.mergeFailed,
    required this.noAutoMergeLocations,
    required this.autoMerge,
    required this.found,
    required this.similarLocations,
    required this.mergeTo,
    required this.mergeAll,
    required this.autoMergeSuccess,
    required this.autoMergeFailed,
    required this.mergeSelected,
    required this.groups,
    required this.noLocationRecords,
    required this.enableWatermark,
    required this.watermarkPosition,
    required this.selectWatermarkInfo,
    required this.watermarkPreview,
    required this.watermarkPositionDesc,
    required this.watermarkPositionTopLeft,
    required this.watermarkPositionTopRight,
    required this.watermarkPositionBottomLeft,
    required this.watermarkPositionBottomRight,
    required this.watermarkPositionCenter,
    required this.watermarkDragToSort,
    required this.watermarkNotEnabled,
    required this.watermarkStyle,
    required this.watermarkBgRadius,
    required this.watermarkBgOpacity,
    required this.watermarkFontSize,
    required this.watermarkTemplateSimple,
    required this.watermarkTemplateSimpleDesc,
    required this.watermarkTemplateElegant,
    required this.watermarkTemplateElegantDesc,
    required this.watermarkTemplateBold,
    required this.watermarkTemplateBoldDesc,
    required this.watermarkTemplate,
    required this.watermarkColorWhite,
    required this.watermarkColorBlack,
    required this.watermarkColorRed,
    required this.watermarkColorGreen,
    required this.watermarkColorBlue,
    required this.watermarkColorYellow,
    required this.watermarkColorPurple,
    required this.watermarkColorCyan,
    required this.watermarkFontColor,
    required this.watermarkPositionTopLeftLabel,
    required this.watermarkPositionTopRightLabel,
    required this.watermarkPositionBottomLeftLabel,
    required this.watermarkPositionBottomRightLabel,
    required this.watermarkPositionCenterLabel,
    required this.watermarkPositionLabel,
    required this.watermarkCustomText,
    required this.watermarkCustomTextHint,
    required this.watermarkCustomTextPlaceholder,
    required this.watermarkPreviewSpecies,
    required this.watermarkPreviewLocation,
    required this.sharePreview,
    required this.resetPosition,
    required this.confirmShare,
    required this.dragToAdjustWatermark,
    required this.pinchToZoomWatermark,
    required this.rodDistribution,
    required this.reelDistribution,
    required this.lureDistribution,
    required this.statistics,
    required this.catchStatistics,
    required this.shareFailed,
    required this.confirmDeleteFish,
    required this.notFilled,
    required this.editFish,
    required this.mapLocation,
    required this.errorCameraPermission,
    required this.errorCameraInit,
    required this.errorCameraSwitch,
    required this.errorLocationPermission,
    required this.errorLocationFetch,
    required this.errorDatabaseRead,
    required this.errorDatabaseWrite,
    required this.errorFileDelete,
    required this.errorFileExport,
    required this.errorFileImport,
    required this.errorNetworkConnect,
    required this.errorWebDAVConnect,
    required this.errorWebDAVUpload,
    required this.errorWebDAVDownload,
    required this.errorShareFailed,
    required this.errorSaveFailed,
    required this.errorLoadFailed,
    required this.errorDeleteFailed,
    required this.errorUnknown,
    required this.rodHandleTypes,
    required this.rodUsageTypes,
    required this.reelTypes,
    required this.reelUsageTypes,
    required this.lureTypeOptions,
    required this.unknownEquipment,
    required this.equipmentOverview,
    required this.totalEquipment,
    required this.brandDistribution,
    required this.equipmentCatchStats,
    required this.equipmentId,
    required this.quantityStats,
    required this.equipmentCatchRanking,
    required this.noCatchData,
    required this.selectFromGallery,
    required this.zoomIn,
    required this.zoomOut,
    required this.locateMe,
    required this.noLocationCoordinates,
    required this.noLocationCoordinatesHint,
    required this.lastVisit,
    required this.noRecords,
    required this.coordinates,
    required this.navigate,
    required this.cannotOpenMapApp,
    required this.locationPermissionDenied,
    required this.locationTimeout,
    required this.geocodingTimeout,
    required this.unknownLocation,
    required this.catchCount,
    required this.exportFormat,
    required this.csvTable,
    required this.csvDescription,
    required this.jsonFullBackup,
    required this.jsonDescription,
    required this.exportingCsv,
    required this.csvExportSuccess,
    required this.generationFailed,
    required this.exportingJson,
    required this.lureboxBackup,
    required this.exporting,
    required this.generatingCsvFile,
    required this.exportConfirm,
    required this.confirmExport,
    required this.willExportNRecords,
    required this.exportOptions,
    required this.format,
    required this.yes,
    required this.no,
    required this.previewFirstN,
    required this.moreRecordsRemaining,
    required this.exportNRecords,
    required this.noMatchingRecords,
    required this.allTime,
    required this.startDate,
    required this.now,
    required this.timeRange,
    required this.speciesFilter,
    required this.clear,
    required this.otherOptions,
    required this.includeImagePaths,
    required this.includeLocationInfo,
    required this.confirmImportFile,
    required this.importingData,
    required this.importedCount,
    required this.pleaseFillCompleteInfo,
    required this.uploading,
    required this.enumerationSeparator,
    required this.catchRecordsExport,
    required this.allRecords,
    required this.dateRangeTo,
    required this.address,
    required this.weather,
    required this.tapToSet,
    required this.pendingRecognition,
    required this.addToPendingRecognition,
    required this.cancelPendingRecognition,
    required this.ascending,
    required this.descending,
    required this.noEquipment,
    required this.hideLocation,
    required this.showLocation,
    required this.totalCountPattern,
    required this.speciesCountPattern,
    required this.rodUnit,
    required this.reelUnit,
    required this.lureUnit,
    required this.configureRig,
    required this.rigType,
    required this.sinkerConfig,
    required this.sinkerWeight,
    required this.sinkerPosition,
    required this.hookConfig,
    required this.hookWeight,
    required this.hookSize,
    required this.customOption,
    required this.customRigTypeHint,
    required this.customHookTypeHint,
    required this.pendingFishCountPattern,
    required this.goToSpeciesManagement,
    required this.airTemperature,
    required this.pressure,
    required this.weatherInfo,
    required this.weatherClear,
    required this.weatherMainlyClear,
    required this.weatherPartlyCloudy,
    required this.weatherOvercast,
    required this.weatherFog,
    required this.weatherDrizzle,
    required this.weatherFreezingDrizzle,
    required this.weatherRain,
    required this.weatherFreezingRain,
    required this.weatherSnowFall,
    required this.weatherSnowGrains,
    required this.weatherRainShowers,
    required this.weatherSnowShowers,
    required this.weatherThunderstorm,
    required this.weatherThunderstormHail,
    required this.weatherUnknown,
    required this.weatherOption0,
    required this.weatherOption1,
    required this.weatherOption2,
    required this.weatherOption3,
    required this.weatherOption4,
    required this.weatherOption5,
    required this.weatherOption6,
    required this.modifyCatchLocation,
    required this.locationName,
    required this.modifyWeather,
    required this.notSet,
    required this.onboardingSkip,
    required this.onboardingGetStarted,
    required this.onboardingNext,
    required this.onboardingWelcomeTitle,
    required this.onboardingWelcomeDesc,
    required this.onboardingFeaturesTitle,
    required this.onboardingFeatureCameraTitle,
    required this.onboardingFeatureCameraDesc,
    required this.onboardingFeatureEquipmentTitle,
    required this.onboardingFeatureEquipmentDesc,
    required this.onboardingFeatureStatsTitle,
    required this.onboardingFeatureStatsDesc,
    required this.onboardingFeatureBackupTitle,
    required this.onboardingFeatureBackupDesc,
    required this.onboardingPermissionsTitle,
    required this.onboardingPermissionCameraTitle,
    required this.onboardingPermissionCameraDesc,
    required this.onboardingPermissionCameraExample,
    required this.onboardingPermissionLocationTitle,
    required this.onboardingPermissionLocationDesc,
    required this.onboardingPermissionLocationExample,
    required this.onboardingPrivacyNote,
    required this.onboardingSettingsTitle,
    required this.onboardingSettingsDesc,
    required this.onboardingSettingsItems,
    required this.onboardingReadyTitle,
    required this.onboardingReadyDesc,
    required this.onboardingPermissionsGrant,
    required this.onboardingPermissionsRequesting,
    required this.onboardingPermissionsGranted,
    required this.recognize,
    required this.notUsing,
    required this.sharing,
    required this.distribution,
    required this.fishListTitle,
    required this.invalidFishId,
    required this.fishNotFound,
    required this.discardChanges,
    required this.discardChangesMessage,
    required this.aboutFeatureCatchTitle,
    required this.aboutFeatureCatchDesc,
    required this.aboutFeatureEquipmentTitle,
    required this.aboutFeatureEquipmentDesc,
    required this.aboutFeatureStatsTitle,
    required this.aboutFeatureStatsDesc,
    required this.aboutFeatureAITitle,
    required this.aboutFeatureAIDesc,
    required this.aboutFeatureWatermarkTitle,
    required this.aboutFeatureWatermarkDesc,
    required this.aboutFeatureExportTitle,
    required this.aboutFeatureExportDesc,
    required this.aboutFeatureCloudTitle,
    required this.aboutFeatureCloudDesc,
    required this.aboutFeatureAchievementTitle,
    required this.aboutFeatureAchievementDesc,
    required this.aboutCopyright,
    required this.locationCancelSelect,
    required this.locationMergeTo,
    required this.locationEnterTargetName,
    required this.locationCount,
    required this.locationTotalFishCount,
    required this.locationSmartMergeSuggestion,
    required this.locationStartFishing,
    required this.locationEditName,
    required this.locationNewName,
    required this.locationEnterNewName,
    required this.locationEditSuccess,
    required this.locationEditFailed,
    required this.locationMergeConfirm,
    required this.locationConfirmAutoMerge,
    required this.locationAutoMergeConfirm,
    required this.locationSearchHint,
    required this.speciesManualRecognition,
    required this.speciesAssignToCatches,
    required this.speciesNameLabel,
    required this.speciesConfirm,
    required this.speciesAiResult,
    required this.speciesConfidence,
    required this.speciesEditableName,
    required this.speciesRename,
    required this.speciesEnterNewName,
    required this.speciesConfirmDelete,
    required this.speciesDeleteConfirmMsg,
    required this.speciesUpdated,
    required this.speciesUpdateFailed,
    required this.speciesRenamed,
    required this.speciesRenameFailed,
    required this.speciesDeleted,
    required this.speciesDeleteFailed,
    required this.speciesNoRecords,
    required this.speciesRecognitionComplete,
    required this.speciesSaved,
    required this.speciesImageNotFound,
    required this.speciesConfigureApiKey,
    required this.speciesAiResultTitle,
    required this.speciesAlternative,
    required this.speciesNoResult,
    required this.speciesRecognitionFailed,
    required this.aiConfigTitle,
    required this.aiProviderLabel,
    required this.aiCurrentProvider,
    required this.aiConfigured,
    required this.aiNotConfigured,
    required this.aiConfigureProvider,
    required this.aiEnterApiKey,
    required this.aiPleaseEnterApiKey,
    required this.aiBaseUrlRequired,
    required this.aiBaseUrlOptional,
    required this.aiOpenaiEndpointRequired,
    required this.aiCustomRequiresBaseUrl,
    required this.aiModelNameOptional,
    required this.aiSpecifyModelName,
    required this.aiTestConnection,
    required this.aiSaving,
    required this.aiConnectionSuccess,
    required this.aiConnectionFailed,
    required this.aiConfigSaved,
    required this.pendingRecognitionList,
    required this.pendingNoFish,
    required this.pendingAiRecognition,
    required this.pendingManual,
    required this.pendingRecognizing,
    required this.pendingRecognitionProgress,
    required this.pendingBatchRecognition,
    required this.pendingFishCount,
    required this.deleteSuccess,
    required this.exportFailedMsg,
    required this.fullBackupTitle,
    required this.fullBackupCreateDesc,
    required this.startBackup,
    required this.creatingBackup,
    required this.backupRunning,
    required this.backupComplete,
    required this.backupFailed,
    required this.restoreTitle,
    required this.restoreOverwriteWarning,
    required this.continueAction,
    required this.restoreSuccessMsg,
    required this.restoreFailedMsg,
    required this.restoreDetailPattern,
    required this.csvExport,
    required this.jsonExport,
    required this.lureboxCompleteBackup,
    required this.lureboxDataExport,
    required this.uploadingToCloud,
    required this.backupUploaded,
    required this.uploadFailed,
    required this.testing,
    required this.webdavTitle,
    required this.webdavConfigureServer,
    required this.webdavSupportedUrl,
    required this.webdavPleaseEnterAddress,
    required this.webdavUrlMustStartHttp,
    required this.webdavPleaseEnterUsername,
    required this.webdavPleaseEnterPassword,
    required this.backupNow,
    required this.testFailed,
    required this.cameraInitTimeout,
    required this.speciesHistoryTimeout,
    required this.equipmentLoadTimeout,
    required this.locationFetchTimeout,
    required this.saveFailedCheckInput,
    required this.saveFailedRetry,
    required this.savedLabel,
    required this.notSavedLabel,
    required this.errorDeviceLocationOff,
    required this.errorContextInvalid,
    required this.errorPermanentlyDenied,
    required this.errorDenied,
    required this.errorRejected,
    required this.permissionRequiredTitle,
    required this.permissionOpenSettings,
    required this.privacyNote,
    required this.permissionGrantLater,
    required this.permissionGrant,
    required this.unknownSpecies,
    required this.errorImageNotFound,
    required this.errorImageTooLarge,
    required this.errorUnsupportedFormat,
    required this.errorApiKeyNotConfigured,
    required this.errorProviderDisabled,
    required this.errorUnknownProvider,
    required this.similarLocationsLabel,
    required this.containsNSimilarLocations,
    required this.mergeButton,
    required this.fishCountSuffix,
    required this.locationFailed,
    required this.unlockProgress,
    required this.speciesCountPattern2,
    required this.monthlyNewSpecies,
    required this.categoryQuantity,
    required this.categorySize,
    required this.categorySpecies,
    required this.categoryLocation,
    required this.categoryEquipment,
    required this.categoryEco,
    required this.rodSection1,
    required this.rodSection2,
    required this.rodSection3,
    required this.rodSectionMulti,
    required this.jointMethod,
    required this.jointTypeSpigot,
    required this.jointTypeReverseSpigot,
    required this.jointTypeDragonSpigot,
    required this.jointTypeTelescopic,
    required this.rodActionSS,
    required this.rodActionS,
    required this.rodActionMR,
    required this.rodActionR,
    required this.rodActionRF,
    required this.rodActionF,
    required this.rodActionFF,
    required this.rodActionXF,
    required this.baitWeightLabel,
    required this.minValue,
    required this.maxValue,
    required this.lineLabel,
    required this.lineCapacity,
    required this.brakeTypeTraditionalMagnetic,
    required this.brakeTypeCentrifugal,
    required this.brakeTypeDC,
    required this.brakeTypeFloatingMagnetic,
    required this.brakeTypeInnovative,
    required this.quantityUnitPiece,
    required this.quantityUnitItem,
    required this.quantityUnitPack,
    required this.quantityUnitBox,
    required this.quantityUnitCarton,
    required this.cardJointMethod,
    required this.cardAction,
    required this.cardStrength,
    required this.cardColor,
    required this.quantityPrefix,
    required this.typeSpinningRod,
    required this.typeBaitcastingRod,
    required this.typeFlyRod,
    required this.typeTrollingRod,
    required this.typeSpinningReel,
    required this.typeBaitcastingReel,
    required this.typeFlyReel,
    required this.typeTrollingReel,
    required this.typeHardBait,
    required this.typeSoftBait,
    required this.typeSpoon,
    required this.typeJigHead,
    required this.typeNylonLine,
    required this.typePELine,
    required this.typeFluorocarbonLine,
    required this.countSuffix,
    required this.distributionTitle,
    required this.priceDistribution,
  });

  @override
  final String appName;
  @override
  final String home;
  @override
  final String fishList;
  @override
  final String equipment;
  @override
  final String achievement;
  @override
  final String viewAchievements;
  @override
  final String me;
  @override
  final String settings;
  @override
  final String dataManagement;
  @override
  final String appearanceSettings;
  @override
  final String appearanceSettingsDesc;
  @override
  final String fishCount;
  @override
  final String release;
  @override
  final String keep;
  @override
  final String releaseRate;
  @override
  final String species;
  @override
  final String length;
  @override
  final String weight;
  @override
  final String location;
  @override
  final String time;
  @override
  final String rod;
  @override
  final String reel;
  @override
  final String lure;
  @override
  final String rodLength;
  @override
  final String rodHardness;
  @override
  final String rodAction;
  @override
  final String rodMaterial;
  @override
  final String weightRange;
  @override
  final String reelRatio;
  @override
  final String reelCapacity;
  @override
  final String reelBrakeType;
  @override
  final String reelWeight;
  @override
  final String reelWeightHint;
  @override
  final String line;
  @override
  final String lureType;
  @override
  final String lureWeight;
  @override
  final String lureSize;
  @override
  final String lureColor;
  @override
  final String todayCatch;
  @override
  final String monthCatch;
  @override
  final String yearCatch;
  @override
  final String allCatch;
  @override
  final String personalRecord;
  @override
  final String noData;
  @override
  final String noCatchYet;
  @override
  final String goCatchFish;
  @override
  final String recordCatch;
  @override
  final String edit;
  @override
  final String share;
  @override
  final String template;
  @override
  final String showStats;
  @override
  final String showHashtags;
  @override
  final String showWatermark;
  @override
  final String delete;
  @override
  final String save;
  @override
  final String cancel;
  @override
  final String confirm;
  @override
  final String loading;
  @override
  final String error;
  @override
  final String retry;
  @override
  final String about;
  @override
  final String version;
  @override
  final String unitSettings;
  @override
  final String lengthUnit;
  @override
  final String weightUnit;
  @override
  final String unit;
  @override
  final String darkMode;
  @override
  final String language;
  @override
  final String watermarkSettings;
  @override
  final String watermarkSettingsDesc;
  @override
  final String watermarkManagement;
  @override
  final String watermarkManagementDesc;
  @override
  final String backupAndExport;
  @override
  final String backupAndExportDesc;
  @override
  final String fileManagement;
  @override
  final String fileManagementDesc;
  @override
  final String exportCsv;
  @override
  final String exportCsvDesc;
  @override
  final String fullBackup;
  @override
  final String fullBackupDesc;
  @override
  final String restoreBackup;
  @override
  final String restoreBackupDesc;
  @override
  final String watermarkEnabled;
  @override
  final String watermarkDisabled;
  @override
  final String displayInfo;
  @override
  final String dataBackup;
  @override
  final String webdavBackup;
  @override
  final String exportData;
  @override
  final String importData;
  @override
  final String exportTo;
  @override
  final String importFrom;
  @override
  final String serverAddress;
  @override
  final String username;
  @override
  final String password;
  @override
  final String connect;
  @override
  final String exportSuccess;
  @override
  final String importSuccess;
  @override
  final String exportFailed;
  @override
  final String importFailed;
  @override
  final String connectFailed;
  @override
  final String connecting;
  @override
  final String connected;
  @override
  final String disconnected;
  @override
  final String connectSuccess;
  @override
  final String exportFunction;
  @override
  final String importFunction;
  @override
  final String webdavFunction;
  @override
  final String connectWebdav;
  @override
  final String serverAddressHint;
  @override
  final String usernameHint;
  @override
  final String passwordHint;
  @override
  final String exportDataHint;
  @override
  final String importDataHint;
  @override
  final String speciesDistribution;
  @override
  final String trendAnalysis;
  @override
  final String locationAnalysis;
  @override
  final String equipmentDistribution;
  @override
  final String fishDetail;
  @override
  final String totalWeight;
  @override
  final String status;
  @override
  final String today;
  @override
  final String month;
  @override
  final String year;
  @override
  final String all;
  @override
  final String byDay;
  @override
  final String byMonth;
  @override
  final String byYear;
  @override
  final String last30Days;
  @override
  final String last12Months;
  @override
  final String yearlyTrend;
  @override
  final String hourlyTrend;
  @override
  final String dailyTrend;
  @override
  final String monthlyTrend;
  @override
  final String fishRod;
  @override
  final String fishReel;
  @override
  final String fishLure;
  @override
  final String protectionEcology;
  @override
  final String reasonableRelease;
  @override
  final String fromLureBox;
  @override
  final String fishCountUnit;
  @override
  final String hour;
  @override
  final String day;
  @override
  final String monthUnit;
  @override
  final String yearUnit;
  @override
  final String total;
  @override
  final String quantity;
  @override
  final String search;
  @override
  final String searchHint;
  @override
  final String selectDateRange;
  @override
  final String custom;
  @override
  final String confirmDelete;
  @override
  final String confirmDeleteSelected;
  @override
  final String records;
  @override
  final String selected;
  @override
  final String items;
  @override
  final String selectAll;
  @override
  final String thisWeek;
  @override
  final String thisMonth;
  @override
  final String thisYear;
  @override
  final String fate;
  @override
  final String clearFilters;
  @override
  final String filterActive;
  @override
  final String expandFilter;
  @override
  final String filter;
  @override
  final String done;
  @override
  final String noFishFound;
  @override
  final String noMatchFound;
  @override
  final String cameraNotReady;
  @override
  final String switchCameraFailed;
  @override
  final String takePhotoFirst;
  @override
  final String enterSpecies;
  @override
  final String enterValidLength;
  @override
  final String enterValidWeight;
  @override
  final String saveFailed;
  @override
  final String switchCamera;
  @override
  final String initializingCamera;
  @override
  final String retake;
  @override
  final String enterSpeciesName;
  @override
  final String enterLength;
  @override
  final String optional;
  @override
  final String estimated;
  @override
  final String estimatedWeight;
  @override
  final String enterActualWeight;
  @override
  final String useEquipment;
  @override
  final String modify;
  @override
  final String catchLocation;
  @override
  final String catchTime;
  @override
  final String confirmSave;
  @override
  final String cameraPermissionRequired;
  @override
  final String noCameraFound;
  @override
  final String cameraInitFailed;
  @override
  final String cameraControllerInitFailed;
  @override
  final String cameraTakePictureFailed;
  @override
  final String centimeter;
  @override
  final String inch;
  @override
  final String kilogram;
  @override
  final String pound;
  @override
  final String meter;
  @override
  final String foot;
  @override
  final String gram;
  @override
  final String ounce;
  @override
  final String kilometer;
  @override
  final String mile;
  @override
  final String celsius;
  @override
  final String fahrenheit;
  @override
  final String temperature;
  @override
  final String millimeter;
  @override
  final String unitsSettings;
  @override
  final String followSystem;
  @override
  final String off;
  @override
  final String on;
  @override
  final String simplifiedChinese;
  @override
  final String enabled;
  @override
  final String disabled;
  @override
  final String locationManagement;
  @override
  final String locationManagementDesc;
  @override
  final String speciesManagement;
  @override
  final String speciesManagementDesc;
  @override
  final String aiConfiguration;
  @override
  final String aiConfigurationDesc;
  @override
  final String exportAndBackupManagement;
  @override
  final String exportAndBackupManagementDesc;
  @override
  final String syncToCloud;
  @override
  final String exportToLocal;
  @override
  final String importFromLocal;
  @override
  final String appDescription;
  @override
  final String features;
  @override
  final String gotIt;
  @override
  final String webdavSettings;
  @override
  final String noAchievementData;
  @override
  final String completed;
  @override
  final String specialAchievement;
  @override
  final String completion;
  @override
  final String achievementOverview;
  @override
  final String unlocked;
  @override
  final String totalAchievements;
  @override
  final String achievementUnit;
  @override
  final String remainingAchievements;
  @override
  final String noAchievements;
  @override
  final String achieved;
  @override
  final String editEquipment;
  @override
  final String addEquipment;
  @override
  final String basicInfo;
  @override
  final String brand;
  @override
  final String brandHint;
  @override
  final String model;
  @override
  final String modelHint;
  @override
  final String price;
  @override
  final String priceHint;
  @override
  final String invalidPrice;
  @override
  final String priceTooHigh;
  @override
  final String purchaseDate;
  @override
  final String tapToSelect;
  @override
  final String setDefault;
  @override
  final String autoAssociate;
  @override
  final String rodParameters;
  @override
  final String gunHandle;
  @override
  final String spinningHandle;
  @override
  final String handleType;
  @override
  final String handleTypeHint;
  @override
  final String usageType;
  @override
  final String selectOrEnterUsage;
  @override
  final String reelParameters;
  @override
  final String baitcaster;
  @override
  final String spinningReel;
  @override
  final String reelType;
  @override
  final String reelTypeHint;
  @override
  final String reelUsageHint;
  @override
  final String lineInfo;
  @override
  final String brandAndName;
  @override
  final String lineBrandHint;
  @override
  final String lineNumber;
  @override
  final String lineNumberHint;
  @override
  final String lineLength;
  @override
  final String lineLengthHint;
  @override
  final String lineDate;
  @override
  final String lureParameters;
  @override
  final String type;
  @override
  final String selectOrEnterType;
  @override
  final String myEquipment;
  @override
  final String expandAll;
  @override
  final String collapseAll;
  @override
  final String noEquipmentYet;
  @override
  final String noEquipmentAddHint;
  @override
  final String confirmDeleteEquipment;
  @override
  final String defaultLabel;
  @override
  final String unnamed;
  @override
  final String record;
  @override
  final String selectEquipment;
  @override
  final String manageEquipment;
  @override
  final String notSelected;
  @override
  final String lengthHint;
  @override
  final String sections;
  @override
  final String sectionsHint;
  @override
  final String material;
  @override
  final String materialHint;
  @override
  final String hardness;
  @override
  final String hardnessHint;
  @override
  final String action;
  @override
  final String actionHint;
  @override
  final String weightRangeHint;
  @override
  final String bearings;
  @override
  final String bearingsHint;
  @override
  final String jointType;
  @override
  final String jointTypeHint;
  @override
  final String ratio;
  @override
  final String ratioHint;
  @override
  final String ratioFront;
  @override
  final String ratioBack;
  @override
  final String capacityHint;
  @override
  final String capacityLineUnit;
  @override
  final String brakeTypeHint;
  @override
  final String lineType;
  @override
  final String lineTypeHint;
  @override
  final String lureTypeHint;
  @override
  final String lureWeightHint;
  @override
  final String lureSizeHint;
  @override
  final String lureColorHint;
  @override
  final String size;
  @override
  final String selectAtLeast2Locations;
  @override
  final String confirmMerge;
  @override
  final String mergeLocationsTo;
  @override
  final String mergedLocations;
  @override
  final String mergeSuccess;
  @override
  final String mergeFailed;
  @override
  final String noAutoMergeLocations;
  @override
  final String autoMerge;
  @override
  final String found;
  @override
  final String similarLocations;
  @override
  final String mergeTo;
  @override
  final String mergeAll;
  @override
  final String autoMergeSuccess;
  @override
  final String autoMergeFailed;
  @override
  final String mergeSelected;
  @override
  final String groups;
  @override
  final String noLocationRecords;
  @override
  final String enableWatermark;
  @override
  final String watermarkPosition;
  @override
  final String selectWatermarkInfo;
  @override
  final String watermarkPreview;
  @override
  final String watermarkPositionDesc;
  @override
  final String watermarkPositionTopLeft;
  @override
  final String watermarkPositionTopRight;
  @override
  final String watermarkPositionBottomLeft;
  @override
  final String watermarkPositionBottomRight;
  @override
  final String watermarkPositionCenter;
  @override
  final String watermarkDragToSort;
  @override
  final String watermarkNotEnabled;
  @override
  final String watermarkStyle;
  @override
  final String watermarkBgRadius;
  @override
  final String watermarkBgOpacity;
  @override
  final String watermarkFontSize;
  @override
  final String watermarkTemplateSimple;
  @override
  final String watermarkTemplateSimpleDesc;
  @override
  final String watermarkTemplateElegant;
  @override
  final String watermarkTemplateElegantDesc;
  @override
  final String watermarkTemplateBold;
  @override
  final String watermarkTemplateBoldDesc;
  @override
  final String watermarkTemplate;
  @override
  final String watermarkColorWhite;
  @override
  final String watermarkColorBlack;
  @override
  final String watermarkColorRed;
  @override
  final String watermarkColorGreen;
  @override
  final String watermarkColorBlue;
  @override
  final String watermarkColorYellow;
  @override
  final String watermarkColorPurple;
  @override
  final String watermarkColorCyan;
  @override
  final String watermarkFontColor;
  @override
  final String watermarkPositionTopLeftLabel;
  @override
  final String watermarkPositionTopRightLabel;
  @override
  final String watermarkPositionBottomLeftLabel;
  @override
  final String watermarkPositionBottomRightLabel;
  @override
  final String watermarkPositionCenterLabel;
  @override
  final String watermarkPositionLabel;
  @override
  final String watermarkCustomText;
  @override
  final String watermarkCustomTextHint;
  @override
  final String watermarkCustomTextPlaceholder;
  @override
  final String watermarkPreviewSpecies;
  @override
  final String watermarkPreviewLocation;
  @override
  final String sharePreview;
  @override
  final String resetPosition;
  @override
  final String confirmShare;
  @override
  final String dragToAdjustWatermark;
  @override
  final String pinchToZoomWatermark;
  @override
  final String rodDistribution;
  @override
  final String reelDistribution;
  @override
  final String lureDistribution;
  @override
  final String statistics;
  @override
  final String catchStatistics;
  @override
  final String shareFailed;
  @override
  final String confirmDeleteFish;
  @override
  final String notFilled;
  @override
  final String editFish;
  @override
  final String mapLocation;
  @override
  final String errorCameraPermission;
  @override
  final String errorCameraInit;
  @override
  final String errorCameraSwitch;
  @override
  final String errorLocationPermission;
  @override
  final String errorLocationFetch;
  @override
  final String errorDatabaseRead;
  @override
  final String errorDatabaseWrite;
  @override
  final String errorFileDelete;
  @override
  final String errorFileExport;
  @override
  final String errorFileImport;
  @override
  final String errorNetworkConnect;
  @override
  final String errorWebDAVConnect;
  @override
  final String errorWebDAVUpload;
  @override
  final String errorWebDAVDownload;
  @override
  final String errorShareFailed;
  @override
  final String errorSaveFailed;
  @override
  final String errorLoadFailed;
  @override
  final String errorDeleteFailed;
  @override
  final String errorUnknown;
  @override
  final List<String> rodHandleTypes;
  @override
  final List<String> rodUsageTypes;
  @override
  final List<String> reelTypes;
  @override
  final List<String> reelUsageTypes;
  @override
  final List<String> lureTypeOptions;
  @override
  final String unknownEquipment;
  @override
  final String equipmentOverview;
  @override
  final String totalEquipment;
  @override
  final String brandDistribution;
  @override
  final String equipmentCatchStats;
  @override
  final String equipmentId;
  @override
  final String quantityStats;
  @override
  final String equipmentCatchRanking;
  @override
  final String noCatchData;
  @override
  final String selectFromGallery;
  @override
  final String zoomIn;
  @override
  final String zoomOut;
  @override
  final String locateMe;
  @override
  final String noLocationCoordinates;
  @override
  final String noLocationCoordinatesHint;
  @override
  final String lastVisit;
  @override
  final String noRecords;
  @override
  final String coordinates;
  @override
  final String navigate;
  @override
  final String cannotOpenMapApp;
  @override
  final String locationPermissionDenied;
  @override
  final String locationTimeout;
  @override
  final String geocodingTimeout;
  @override
  final String unknownLocation;
  @override
  final String catchCount;
  @override
  final String exportFormat;
  @override
  final String csvTable;
  @override
  final String csvDescription;
  @override
  final String jsonFullBackup;
  @override
  final String jsonDescription;
  @override
  final String exportingCsv;
  @override
  final String csvExportSuccess;
  @override
  final String generationFailed;
  @override
  final String exportingJson;
  @override
  final String lureboxBackup;
  @override
  final String exporting;
  @override
  final String generatingCsvFile;
  @override
  final String exportConfirm;
  @override
  final String confirmExport;
  @override
  final String willExportNRecords;
  @override
  final String exportOptions;
  @override
  final String format;
  @override
  final String yes;
  @override
  final String no;
  @override
  final String previewFirstN;
  @override
  final String moreRecordsRemaining;
  @override
  final String exportNRecords;
  @override
  final String noMatchingRecords;
  @override
  final String allTime;
  @override
  final String startDate;
  @override
  final String now;
  @override
  final String timeRange;
  @override
  final String speciesFilter;
  @override
  final String clear;
  @override
  final String otherOptions;
  @override
  final String includeImagePaths;
  @override
  final String includeLocationInfo;
  @override
  final String confirmImportFile;
  @override
  final String importingData;
  @override
  final String importedCount;
  @override
  final String pleaseFillCompleteInfo;
  @override
  final String uploading;
  @override
  final String enumerationSeparator;
  @override
  final String catchRecordsExport;
  @override
  final String allRecords;
  @override
  final String dateRangeTo;
  @override
  final String address;
  @override
  final String weather;
  @override
  final String tapToSet;
  @override
  final String pendingRecognition;
  @override
  final String addToPendingRecognition;
  @override
  final String cancelPendingRecognition;
  @override
  final String ascending;
  @override
  final String descending;
  @override
  final String noEquipment;
  @override
  final String hideLocation;
  @override
  final String showLocation;
  @override
  final String totalCountPattern;
  @override
  final String speciesCountPattern;
  @override
  final String rodUnit;
  @override
  final String reelUnit;
  @override
  final String lureUnit;
  @override
  final String configureRig;
  @override
  final String rigType;
  @override
  final String sinkerConfig;
  @override
  final String sinkerWeight;
  @override
  final String sinkerPosition;
  @override
  final String hookConfig;
  @override
  final String hookWeight;
  @override
  final String hookSize;
  @override
  final String customOption;
  @override
  final String customRigTypeHint;
  @override
  final String customHookTypeHint;
  @override
  final String pendingFishCountPattern;
  @override
  final String goToSpeciesManagement;
  @override
  final String airTemperature;
  @override
  final String pressure;
  @override
  final String weatherInfo;
  @override
  final String weatherClear;
  @override
  final String weatherMainlyClear;
  @override
  final String weatherPartlyCloudy;
  @override
  final String weatherOvercast;
  @override
  final String weatherFog;
  @override
  final String weatherDrizzle;
  @override
  final String weatherFreezingDrizzle;
  @override
  final String weatherRain;
  @override
  final String weatherFreezingRain;
  @override
  final String weatherSnowFall;
  @override
  final String weatherSnowGrains;
  @override
  final String weatherRainShowers;
  @override
  final String weatherSnowShowers;
  @override
  final String weatherThunderstorm;
  @override
  final String weatherThunderstormHail;
  @override
  final String weatherUnknown;
  @override
  final String weatherOption0;
  @override
  final String weatherOption1;
  @override
  final String weatherOption2;
  @override
  final String weatherOption3;
  @override
  final String weatherOption4;
  @override
  final String weatherOption5;
  @override
  final String weatherOption6;
  @override
  final String modifyCatchLocation;
  @override
  final String locationName;
  @override
  final String modifyWeather;
  @override
  final String notSet;

  // Onboarding
  @override
  final String onboardingSkip;
  @override
  final String onboardingGetStarted;
  @override
  final String onboardingNext;
  @override
  final String onboardingWelcomeTitle;
  @override
  final String onboardingWelcomeDesc;
  @override
  final String onboardingFeaturesTitle;
  @override
  final String onboardingFeatureCameraTitle;
  @override
  final String onboardingFeatureCameraDesc;
  @override
  final String onboardingFeatureEquipmentTitle;
  @override
  final String onboardingFeatureEquipmentDesc;
  @override
  final String onboardingFeatureStatsTitle;
  @override
  final String onboardingFeatureStatsDesc;
  @override
  final String onboardingFeatureBackupTitle;
  @override
  final String onboardingFeatureBackupDesc;
  @override
  final String onboardingPermissionsTitle;
  @override
  final String onboardingPermissionCameraTitle;
  @override
  final String onboardingPermissionCameraDesc;
  @override
  final String onboardingPermissionCameraExample;
  @override
  final String onboardingPermissionLocationTitle;
  @override
  final String onboardingPermissionLocationDesc;
  @override
  final String onboardingPermissionLocationExample;
  @override
  final String onboardingPrivacyNote;
  @override
  final String onboardingSettingsTitle;
  @override
  final String onboardingSettingsDesc;
  @override
  final String onboardingSettingsItems;
  @override
  final String onboardingReadyTitle;
  @override
  final String onboardingReadyDesc;
  @override
  final String onboardingPermissionsGrant;
  @override
  final String onboardingPermissionsRequesting;
  @override
  final String onboardingPermissionsGranted;

  @override
  final String recognize;
  @override
  final String notUsing;
  @override
  final String sharing;
  @override
  final String distribution;
  @override
  final String fishListTitle;
  @override
  final String invalidFishId;
  @override
  final String fishNotFound;
  @override
  final String discardChanges;
  @override
  final String discardChangesMessage;
  @override
  final String aboutFeatureCatchTitle;
  @override
  final String aboutFeatureCatchDesc;
  @override
  final String aboutFeatureEquipmentTitle;
  @override
  final String aboutFeatureEquipmentDesc;
  @override
  final String aboutFeatureStatsTitle;
  @override
  final String aboutFeatureStatsDesc;
  @override
  final String aboutFeatureAITitle;
  @override
  final String aboutFeatureAIDesc;
  @override
  final String aboutFeatureWatermarkTitle;
  @override
  final String aboutFeatureWatermarkDesc;
  @override
  final String aboutFeatureExportTitle;
  @override
  final String aboutFeatureExportDesc;
  @override
  final String aboutFeatureCloudTitle;
  @override
  final String aboutFeatureCloudDesc;
  @override
  final String aboutFeatureAchievementTitle;
  @override
  final String aboutFeatureAchievementDesc;
  @override
  final String aboutCopyright;
  @override
  final String locationCancelSelect;
  @override
  final String locationMergeTo;
  @override
  final String locationEnterTargetName;
  @override
  final String locationCount;
  @override
  final String locationTotalFishCount;
  @override
  final String locationSmartMergeSuggestion;
  @override
  final String locationStartFishing;
  @override
  final String locationEditName;
  @override
  final String locationNewName;
  @override
  final String locationEnterNewName;
  @override
  final String locationEditSuccess;
  @override
  final String locationEditFailed;
  @override
  final String locationMergeConfirm;
  @override
  final String locationConfirmAutoMerge;
  @override
  final String locationAutoMergeConfirm;
  @override
  final String locationSearchHint;
  @override
  final String speciesManualRecognition;
  @override
  final String speciesAssignToCatches;
  @override
  final String speciesNameLabel;
  @override
  final String speciesConfirm;
  @override
  final String speciesAiResult;
  @override
  final String speciesConfidence;
  @override
  final String speciesEditableName;
  @override
  final String speciesRename;
  @override
  final String speciesEnterNewName;
  @override
  final String speciesConfirmDelete;
  @override
  final String speciesDeleteConfirmMsg;
  @override
  final String speciesUpdated;
  @override
  final String speciesUpdateFailed;
  @override
  final String speciesRenamed;
  @override
  final String speciesRenameFailed;
  @override
  final String speciesDeleted;
  @override
  final String speciesDeleteFailed;
  @override
  final String speciesNoRecords;
  @override
  final String speciesRecognitionComplete;
  @override
  final String speciesSaved;
  @override
  final String speciesImageNotFound;
  @override
  final String speciesConfigureApiKey;
  @override
  final String speciesAiResultTitle;
  @override
  final String speciesAlternative;
  @override
  final String speciesNoResult;
  @override
  final String speciesRecognitionFailed;
  @override
  final String aiConfigTitle;
  @override
  final String aiProviderLabel;
  @override
  final String aiCurrentProvider;
  @override
  final String aiConfigured;
  @override
  final String aiNotConfigured;
  @override
  final String aiConfigureProvider;
  @override
  final String aiEnterApiKey;
  @override
  final String aiPleaseEnterApiKey;
  @override
  final String aiBaseUrlRequired;
  @override
  final String aiBaseUrlOptional;
  @override
  final String aiOpenaiEndpointRequired;
  @override
  final String aiCustomRequiresBaseUrl;
  @override
  final String aiModelNameOptional;
  @override
  final String aiSpecifyModelName;
  @override
  final String aiTestConnection;
  @override
  final String aiSaving;
  @override
  final String aiConnectionSuccess;
  @override
  final String aiConnectionFailed;
  @override
  final String aiConfigSaved;
  @override
  final String pendingRecognitionList;
  @override
  final String pendingNoFish;
  @override
  final String pendingAiRecognition;
  @override
  final String pendingManual;
  @override
  final String pendingRecognizing;
  @override
  final String pendingRecognitionProgress;
  @override
  final String pendingBatchRecognition;
  @override
  final String pendingFishCount;
  @override
  final String deleteSuccess;
  @override
  final String exportFailedMsg;
  @override
  final String fullBackupTitle;
  @override
  final String fullBackupCreateDesc;
  @override
  final String startBackup;
  @override
  final String creatingBackup;
  @override
  final String backupRunning;
  @override
  final String backupComplete;
  @override
  final String backupFailed;
  @override
  final String restoreTitle;
  @override
  final String restoreOverwriteWarning;
  @override
  final String continueAction;
  @override
  final String restoreSuccessMsg;
  @override
  final String restoreFailedMsg;
  @override
  final String restoreDetailPattern;
  @override
  final String csvExport;
  @override
  final String jsonExport;
  @override
  final String lureboxCompleteBackup;
  @override
  final String lureboxDataExport;
  @override
  final String uploadingToCloud;
  @override
  final String backupUploaded;
  @override
  final String uploadFailed;
  @override
  final String testing;
  @override
  final String webdavTitle;
  @override
  final String webdavConfigureServer;
  @override
  final String webdavSupportedUrl;
  @override
  final String webdavPleaseEnterAddress;
  @override
  final String webdavUrlMustStartHttp;
  @override
  final String webdavPleaseEnterUsername;
  @override
  final String webdavPleaseEnterPassword;
  @override
  final String backupNow;
  @override
  final String testFailed;
  @override
  final String cameraInitTimeout;
  @override
  final String speciesHistoryTimeout;
  @override
  final String equipmentLoadTimeout;
  @override
  final String locationFetchTimeout;
  @override
  final String saveFailedCheckInput;
  @override
  final String saveFailedRetry;
  @override
  final String savedLabel;
  @override
  final String notSavedLabel;
  @override
  final String errorDeviceLocationOff;
  @override
  final String errorContextInvalid;
  @override
  final String errorPermanentlyDenied;
  @override
  final String errorDenied;
  @override
  final String errorRejected;
  @override
  final String permissionRequiredTitle;
  @override
  final String permissionOpenSettings;
  @override
  final String privacyNote;
  @override
  final String permissionGrantLater;
  @override
  final String permissionGrant;
  @override
  final String unknownSpecies;
  @override
  final String errorImageNotFound;
  @override
  final String errorImageTooLarge;
  @override
  final String errorUnsupportedFormat;
  @override
  final String errorApiKeyNotConfigured;
  @override
  final String errorProviderDisabled;
  @override
  final String errorUnknownProvider;
  @override
  final String similarLocationsLabel;
  @override
  final String containsNSimilarLocations;
  @override
  final String mergeButton;
  @override
  final String fishCountSuffix;
  @override
  final String locationFailed;
  @override
  final String unlockProgress;
  @override
  final String speciesCountPattern2;
  @override
  final String monthlyNewSpecies;
  @override
  final String categoryQuantity;
  @override
  final String categorySize;
  @override
  final String categorySpecies;
  @override
  final String categoryLocation;
  @override
  final String categoryEquipment;
  @override
  final String categoryEco;
  @override
  final String rodSection1;
  @override
  final String rodSection2;
  @override
  final String rodSection3;
  @override
  final String rodSectionMulti;
  @override
  final String jointMethod;
  @override
  final String jointTypeSpigot;
  @override
  final String jointTypeReverseSpigot;
  @override
  final String jointTypeDragonSpigot;
  @override
  final String jointTypeTelescopic;
  @override
  final String rodActionSS;
  @override
  final String rodActionS;
  @override
  final String rodActionMR;
  @override
  final String rodActionR;
  @override
  final String rodActionRF;
  @override
  final String rodActionF;
  @override
  final String rodActionFF;
  @override
  final String rodActionXF;
  @override
  final String baitWeightLabel;
  @override
  final String minValue;
  @override
  final String maxValue;
  @override
  final String lineLabel;
  @override
  final String lineCapacity;
  @override
  final String brakeTypeTraditionalMagnetic;
  @override
  final String brakeTypeCentrifugal;
  @override
  final String brakeTypeDC;
  @override
  final String brakeTypeFloatingMagnetic;
  @override
  final String brakeTypeInnovative;
  @override
  final String quantityUnitPiece;
  @override
  final String quantityUnitItem;
  @override
  final String quantityUnitPack;
  @override
  final String quantityUnitBox;
  @override
  final String quantityUnitCarton;
  @override
  final String cardJointMethod;
  @override
  final String cardAction;
  @override
  final String cardStrength;
  @override
  final String cardColor;
  @override
  final String quantityPrefix;
  @override
  final String typeSpinningRod;
  @override
  final String typeBaitcastingRod;
  @override
  final String typeFlyRod;
  @override
  final String typeTrollingRod;
  @override
  final String typeSpinningReel;
  @override
  final String typeBaitcastingReel;
  @override
  final String typeFlyReel;
  @override
  final String typeTrollingReel;
  @override
  final String typeHardBait;
  @override
  final String typeSoftBait;
  @override
  final String typeSpoon;
  @override
  final String typeJigHead;
  @override
  final String typeNylonLine;
  @override
  final String typePELine;
  @override
  final String typeFluorocarbonLine;
  @override
  final String countSuffix;
  @override
  final String distributionTitle;
  @override
  final String priceDistribution;

  static const chinese = chineseStrings;
  static const english = englishStrings;
}
