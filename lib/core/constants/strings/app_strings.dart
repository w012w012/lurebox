import 'common_strings.dart';
import 'catch_strings.dart';
import 'equipment_strings.dart';
import 'camera_strings.dart';
import 'stats_strings.dart';
import 'weather_strings.dart';
import 'watermark_strings.dart';
import 'export_strings.dart';
import 'settings_strings.dart';
import 'error_strings.dart';
import 'achievement_strings.dart';
import 'location_strings.dart';

import 'strings_base.dart';
import 'zh_strings.dart';
import 'en_strings.dart';

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
    LocationStringsMixin {

  final String appName;
  final String home;
  final String fishList;
  final String equipment;
  final String achievement;
  final String viewAchievements;
  final String me;
  final String settings;
  final String dataManagement;
  final String appearanceSettings;
  final String appearanceSettingsDesc;
  final String fishCount;
  final String release;
  final String keep;
  final String releaseRate;
  final String species;
  final String length;
  final String weight;
  final String location;
  final String time;
  final String rod;
  final String reel;
  final String lure;
  final String rodLength;
  final String rodHardness;
  final String rodAction;
  final String rodMaterial;
  final String weightRange;
  final String reelRatio;
  final String reelCapacity;
  final String reelBrakeType;
  final String reelWeight;
  final String reelWeightHint;
  final String line;
  final String lureType;
  final String lureWeight;
  final String lureSize;
  final String lureColor;
  final String todayCatch;
  final String monthCatch;
  final String yearCatch;
  final String allCatch;
  final String personalRecord;
  final String noData;
  final String noCatchYet;
  final String goCatchFish;
  final String recordCatch;
  final String edit;
  final String share;
  final String delete;
  final String save;
  final String cancel;
  final String confirm;
  final String loading;
  final String error;
  final String retry;
  final String about;
  final String version;
  final String unitSettings;
  final String lengthUnit;
  final String weightUnit;
  final String unit;
  final String darkMode;
  final String language;
  final String watermarkSettings;
  final String watermarkSettingsDesc;
  final String watermarkManagement;
  final String watermarkManagementDesc;
  final String backupAndExport;
  final String backupAndExportDesc;
  final String fileManagement;
  final String fileManagementDesc;
  final String exportCsv;
  final String exportCsvDesc;
  final String fullBackup;
  final String fullBackupDesc;
  final String restoreBackup;
  final String restoreBackupDesc;
  final String watermarkEnabled;
  final String watermarkDisabled;
  final String displayInfo;
  final String dataBackup;
  final String webdavBackup;
  final String exportData;
  final String importData;
  final String exportTo;
  final String importFrom;
  final String serverAddress;
  final String username;
  final String password;
  final String connect;
  final String exportSuccess;
  final String importSuccess;
  final String exportFailed;
  final String importFailed;
  final String connectFailed;
  final String connecting;
  final String connected;
  final String disconnected;
  final String connectSuccess;
  final String exportFunction;
  final String importFunction;
  final String webdavFunction;
  final String connectWebdav;
  final String serverAddressHint;
  final String usernameHint;
  final String passwordHint;
  final String exportDataHint;
  final String importDataHint;
  final String speciesDistribution;
  final String trendAnalysis;
  final String locationAnalysis;
  final String equipmentDistribution;
  final String fishDetail;
  final String totalWeight;
  final String status;
  final String today;
  final String month;
  final String year;
  final String all;
  final String byDay;
  final String byMonth;
  final String byYear;
  final String last30Days;
  final String last12Months;
  final String yearlyTrend;
  final String hourlyTrend;
  final String dailyTrend;
  final String monthlyTrend;
  final String fishRod;
  final String fishReel;
  final String fishLure;
  final String protectionEcology;
  final String reasonableRelease;
  final String fromLureBox;
  final String yourFishingAssistant;
  final String fishCountUnit;
  final String hour;
  final String day;
  final String monthUnit;
  final String yearUnit;
  final String total;
  final String quantity;
  final String search;
  final String searchHint;
  final String selectDateRange;
  final String custom;
  final String confirmDelete;
  final String confirmDeleteSelected;
  final String records;
  final String selected;
  final String items;
  final String selectAll;
  final String thisWeek;
  final String thisMonth;
  final String thisYear;
  final String fate;
  final String clearFilters;
  final String filterActive;
  final String expandFilter;
  final String filter;
  final String done;
  final String noFishFound;
  final String noMatchFound;
  final String cameraNotReady;
  final String switchCameraFailed;
  final String takePhotoFirst;
  final String enterSpecies;
  final String enterValidLength;
  final String enterValidWeight;
  final String saveFailed;
  final String switchCamera;
  final String initializingCamera;
  final String retake;
  final String enterSpeciesName;
  final String enterLength;
  final String optional;
  final String estimated;
  final String estimatedWeight;
  final String enterActualWeight;
  final String useEquipment;
  final String modify;
  final String catchLocation;
  final String catchTime;
  final String confirmSave;
  final String cameraPermissionRequired;
  final String noCameraFound;
  final String cameraInitFailed;
  final String centimeter;
  final String inch;
  final String kilogram;
  final String pound;
  final String meter;
  final String foot;
  final String gram;
  final String ounce;
  final String kilometer;
  final String mile;
  final String celsius;
  final String fahrenheit;
  final String temperature;
  final String millimeter;
  final String unitsSettings;
  final String followSystem;
  final String off;
  final String on;
  final String simplifiedChinese;
  final String enabled;
  final String disabled;
  final String locationManagement;
  final String locationManagementDesc;
  final String speciesManagement;
  final String speciesManagementDesc;
  final String aiConfiguration;
  final String aiConfigurationDesc;
  final String exportAndBackupManagement;
  final String exportAndBackupManagementDesc;
  final String syncToCloud;
  final String exportToLocal;
  final String importFromLocal;
  final String appDescription;
  final String features;
  final String gotIt;
  final String webdavSettings;
  final String noAchievementData;
  final String completed;
  final String specialAchievement;
  final String completion;
  final String achievementOverview;
  final String unlocked;
  final String totalAchievements;
  final String achievementUnit;
  final String remainingAchievements;
  final String noAchievements;
  final String achieved;
  final String editEquipment;
  final String addEquipment;
  final String basicInfo;
  final String brand;
  final String brandHint;
  final String model;
  final String modelHint;
  final String price;
  final String priceHint;
  final String invalidPrice;
  final String priceTooHigh;
  final String purchaseDate;
  final String tapToSelect;
  final String setDefault;
  final String autoAssociate;
  final String rodParameters;
  final String gunHandle;
  final String spinningHandle;
  final String handleType;
  final String handleTypeHint;
  final String usageType;
  final String selectOrEnterUsage;
  final String reelParameters;
  final String baitcaster;
  final String spinningReel;
  final String reelType;
  final String reelTypeHint;
  final String reelUsageHint;
  final String lineInfo;
  final String brandAndName;
  final String lineBrandHint;
  final String lineNumber;
  final String lineNumberHint;
  final String lineLength;
  final String lineLengthHint;
  final String lineDate;
  final String lureParameters;
  final String type;
  final String selectOrEnterType;
  final String myEquipment;
  final String expandAll;
  final String collapseAll;
  final String noEquipmentYet;
  final String noEquipmentAddHint;
  final String confirmDeleteEquipment;
  final String defaultLabel;
  final String unnamed;
  final String record;
  final String selectEquipment;
  final String manageEquipment;
  final String notSelected;
  final String lengthHint;
  final String sections;
  final String sectionsHint;
  final String material;
  final String materialHint;
  final String hardness;
  final String hardnessHint;
  final String action;
  final String actionHint;
  final String weightRangeHint;
  final String bearings;
  final String bearingsHint;
  final String jointType;
  final String jointTypeHint;
  final String ratio;
  final String ratioHint;
  final String capacityHint;
  final String brakeTypeHint;
  final String lineType;
  final String lineTypeHint;
  final String lureTypeHint;
  final String lureWeightHint;
  final String lureSizeHint;
  final String lureColorHint;
  final String size;
  final String selectAtLeast2Locations;
  final String confirmMerge;
  final String mergeLocationsTo;
  final String mergedLocations;
  final String mergeSuccess;
  final String mergeFailed;
  final String noAutoMergeLocations;
  final String autoMerge;
  final String found;
  final String similarLocations;
  final String mergeTo;
  final String mergeAll;
  final String autoMergeSuccess;
  final String autoMergeFailed;
  final String mergeSelected;
  final String groups;
  final String noLocationRecords;
  final String enableWatermark;
  final String watermarkPosition;
  final String selectWatermarkInfo;
  final String watermarkPreview;
  final String watermarkPositionDesc;
  final String watermarkPositionTopLeft;
  final String watermarkPositionTopRight;
  final String watermarkPositionBottomLeft;
  final String watermarkPositionBottomRight;
  final String watermarkPositionCenter;
  final String watermarkDragToSort;
  final String watermarkNotEnabled;
  final String watermarkStyle;
  final String watermarkBgRadius;
  final String watermarkBgOpacity;
  final String watermarkFontSize;
  final String watermarkTemplateSimple;
  final String watermarkTemplateSimpleDesc;
  final String watermarkTemplateElegant;
  final String watermarkTemplateElegantDesc;
  final String watermarkTemplateBold;
  final String watermarkTemplateBoldDesc;
  final String watermarkTemplate;
  final String watermarkColorWhite;
  final String watermarkColorBlack;
  final String watermarkColorRed;
  final String watermarkColorGreen;
  final String watermarkColorBlue;
  final String watermarkColorYellow;
  final String watermarkColorPurple;
  final String watermarkColorCyan;
  final String watermarkFontColor;
  final String watermarkPositionTopLeftLabel;
  final String watermarkPositionTopRightLabel;
  final String watermarkPositionBottomLeftLabel;
  final String watermarkPositionBottomRightLabel;
  final String watermarkPositionCenterLabel;
  final String watermarkPositionLabel;
  final String watermarkCustomText;
  final String watermarkCustomTextHint;
  final String watermarkCustomTextPlaceholder;
  final String watermarkPreviewSpecies;
  final String watermarkPreviewLocation;
  final String rodDistribution;
  final String reelDistribution;
  final String lureDistribution;
  final String statistics;
  final String catchStatistics;
  final String shareFailed;
  final String confirmDeleteFish;
  final String notFilled;
  final String editFish;
  final String mapLocation;
  final String errorCameraPermission;
  final String errorCameraInit;
  final String errorCameraSwitch;
  final String errorLocationPermission;
  final String errorLocationFetch;
  final String errorDatabaseRead;
  final String errorDatabaseWrite;
  final String errorFileDelete;
  final String errorFileExport;
  final String errorFileImport;
  final String errorNetworkConnect;
  final String errorWebDAVConnect;
  final String errorWebDAVUpload;
  final String errorWebDAVDownload;
  final String errorShareFailed;
  final String errorSaveFailed;
  final String errorLoadFailed;
  final String errorDeleteFailed;
  final String errorUnknown;
  final List<String> rodHandleTypes;
  final List<String> rodUsageTypes;
  final List<String> reelTypes;
  final List<String> reelUsageTypes;
  final List<String> lureTypeOptions;
  final String unknownEquipment;
  final String equipmentOverview;
  final String totalEquipment;
  final String brandDistribution;
  final String equipmentCatchStats;
  final String equipmentId;
  final String quantityStats;
  final String equipmentCatchRanking;
  final String noCatchData;
  final String selectFromGallery;
  final String zoomIn;
  final String zoomOut;
  final String locateMe;
  final String noLocationCoordinates;
  final String noLocationCoordinatesHint;
  final String lastVisit;
  final String noRecords;
  final String coordinates;
  final String navigate;
  final String cannotOpenMapApp;
  final String locationPermissionDenied;
  final String locationTimeout;
  final String geocodingTimeout;
  final String unknownLocation;
  final String catchCount;
  final String exportFormat;
  final String csvTable;
  final String csvDescription;
  final String jsonFullBackup;
  final String jsonDescription;
  final String exportingCsv;
  final String csvExportSuccess;
  final String generationFailed;
  final String exportingJson;
  final String lureboxBackup;
  final String exporting;
  final String generatingCsvFile;
  final String exportConfirm;
  final String confirmExport;
  final String willExportNRecords;
  final String exportOptions;
  final String format;
  final String yes;
  final String no;
  final String previewFirstN;
  final String moreRecordsRemaining;
  final String exportNRecords;
  final String noMatchingRecords;
  final String allTime;
  final String startDate;
  final String now;
  final String timeRange;
  final String speciesFilter;
  final String clear;
  final String otherOptions;
  final String includeImagePaths;
  final String includeLocationInfo;
  final String confirmImportFile;
  final String importingData;
  final String importedCount;
  final String pleaseFillCompleteInfo;
  final String uploading;
  final String enumerationSeparator;
  final String catchRecordsExport;
  final String allRecords;
  final String dateRangeTo;
  final String address;
  final String weather;
  final String tapToSet;
  final String pendingRecognition;
  final String addToPendingRecognition;
  final String cancelPendingRecognition;
  final String ascending;
  final String descending;
  final String noEquipment;
  final String hideLocation;
  final String showLocation;
  final String totalCountPattern;
  final String speciesCountPattern;
  final String rodUnit;
  final String reelUnit;
  final String lureUnit;
  final String configureRig;
  final String rigType;
  final String sinkerConfig;
  final String sinkerWeight;
  final String sinkerPosition;
  final String hookConfig;
  final String hookWeight;
  final String hookSize;
  final String customOption;
  final String customRigTypeHint;
  final String customHookTypeHint;
  final String pendingFishCountPattern;
  final String goToSpeciesManagement;
  final String airTemperature;
  final String pressure;
  final String weatherClear;
  final String weatherMainlyClear;
  final String weatherPartlyCloudy;
  final String weatherOvercast;
  final String weatherFog;
  final String weatherDrizzle;
  final String weatherFreezingDrizzle;
  final String weatherRain;
  final String weatherFreezingRain;
  final String weatherSnowFall;
  final String weatherSnowGrains;
  final String weatherRainShowers;
  final String weatherSnowShowers;
  final String weatherThunderstorm;
  final String weatherThunderstormHail;
  final String weatherUnknown;
  final String weatherOption0;
  final String weatherOption1;
  final String weatherOption2;
  final String weatherOption3;
  final String weatherOption4;
  final String weatherOption5;
  final String weatherOption6;
  final String modifyCatchLocation;
  final String locationName;
  final String modifyWeather;
  final String notSet;

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
    required this.yourFishingAssistant,
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
    required this.capacityHint,
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
    required this.notSet
  });

  static const chinese = chineseStrings;
  static const english = englishStrings;
}
