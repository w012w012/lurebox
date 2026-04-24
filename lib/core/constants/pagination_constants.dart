/// Pagination-related constants used across repositories and services.
class PaginationConstants {
  PaginationConstants._();

  /// Default page size for paginated queries.
  static const int defaultPageSize = 20;

  /// Maximum allowed page size to prevent unbounded queries.
  static const int maxPageSize = 100;

  /// Default limit for "top N" queries (e.g., top species).
  static const int topItemsLimit = 10;

  /// Limit for equipment distribution queries.
  static const int topEquipmentLimit = 8;

  /// Small top-N limit (e.g., top 3 longest catches).
  static const int topItemsSmall = 3;

  /// Sentinel value indicating total count is unknown (for non-first pages).
  static const int unknownTotalCount = -1;
}
