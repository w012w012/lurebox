// Core library barrel export
// This file provides a single point of import for all core modules

// Models
export 'models/achievement.dart';
export 'models/ai_recognition_settings.dart';
export 'models/app_settings.dart';
export 'models/backup_history.dart';
export 'models/cloud_config.dart';
export 'models/equipment.dart';
export 'models/fish_catch.dart';
export 'models/fish_filter.dart';
export 'models/fishing_location.dart';
export 'models/location_models.dart';
export 'models/paginated_result.dart';
export 'models/species_history.dart';
export 'models/stats_models.dart';
export 'models/watermark_settings.dart';

// Providers
export 'providers/achievement_provider.dart';
export 'providers/achievement_view_model.dart';
export 'providers/ai_recognition_provider.dart'
    hide aiRecognitionSettingsProvider;
export 'providers/app_settings_provider.dart';
export 'providers/equipment_edit_view_model.dart';
export 'providers/equipment_providers.dart';
export 'providers/equipment_view_model.dart';
export 'providers/fish_detail_view_model.dart';
export 'providers/fish_list_state.dart' hide FishListState;
export 'providers/fish_list_view_model.dart';
export 'providers/fish_providers.dart' hide top3LongestCatchesProvider;
export 'providers/home_view_model.dart';
export 'providers/language_provider.dart';
export 'providers/location_view_model.dart';
export 'providers/pending_recognition_providers.dart';
export 'providers/providers.dart';
export 'providers/settings_view_model.dart';
export 'providers/stats_provider.dart' hide top3LongestCatchesProvider;
export 'providers/stats_view_model.dart';
export 'providers/watermark_provider.dart';

// Services
export 'services/achievement_service.dart';
export 'services/backup_service.dart';
export 'services/backup_zip_service.dart';
export 'services/csv_exporter.dart';
export 'services/database_service.dart';
export 'services/enhanced_backup_service.dart';
export 'services/equipment_service.dart';
export 'services/error_service.dart';
export 'services/export_options.dart' hide ExportFormat;
export 'services/export_service.dart';
export 'services/fish_catch_service.dart';
export 'services/fish_recognition_service.dart';
export 'services/location_service.dart';
export 'services/settings_service.dart';
export 'services/share_card_service.dart';
export 'services/share_template.dart';
export 'services/weather_service.dart';

// Repositories
export 'repositories/backup_config_repository.dart';
export 'repositories/equipment_repository.dart';
export 'repositories/equipment_repository_impl.dart';
export 'repositories/fish_catch_repository.dart';
export 'repositories/fish_catch_repository_impl.dart';
export 'repositories/location_repository.dart';
export 'repositories/location_repository_impl.dart';
export 'repositories/settings_repository.dart';
export 'repositories/settings_repository_impl.dart';
export 'repositories/species_history_repository.dart';
export 'repositories/species_history_repository_impl.dart';
export 'repositories/stats_repository.dart';
export 'repositories/stats_repository_impl.dart';

// Database
export 'database/database.dart';
export 'database/database_provider.dart';

// Constants
export 'constants/achievements.dart';
export 'constants/constants.dart';
export 'constants/price_ranges.dart';
export 'constants/strings.dart';

// Design
export 'design/theme/app_colors.dart';
export 'design/theme/app_theme.dart';
export 'design/theme/theme_wrapper.dart';
export 'design/responsive/responsive_utils.dart';

// Utils
export 'utils/date_utils.dart';
export 'utils/file_utils.dart';
export 'utils/image_compressor.dart';
export 'utils/unit_converter.dart';

// Widgets
export 'widgets/error_toast.dart';
export 'widgets/error_view.dart';

// Router
export 'router/app_router.dart';

// DI
export 'di/di.dart';
