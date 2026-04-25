import 'package:lurebox/core/constants/pagination_constants.dart';
import 'package:lurebox/core/database/database_provider.dart';
import 'package:lurebox/core/models/paginated_result.dart';
import 'package:lurebox/core/services/error_service.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;

/// Base class for all SQLite repository implementations.
///
/// Provides:
/// - [database] getter with test-injection support
/// - [paginate] helper for paginated queries
/// - [throwDbError] for consistent error wrapping
abstract class BaseSqliteRepository {

  BaseSqliteRepository();

  BaseSqliteRepository.withDatabase(Future<Database> testDb)
      : _testDb = testDb;
  /// Optional test database future (injected via [withDatabase]).
  Future<Database>? _testDb;

  /// Subclass must return the SQL table name.
  String get tableName;

  /// Returns the database instance — injected test DB or the real one.
  Future<Database> get database async {
    final testDb = _testDb;
    if (testDb != null) return testDb;
    return DatabaseProvider.instance.database;
  }

  /// Throws a [DatabaseException] with a consistent message format.
  Never throwDbError(String operation, Object error) {
    throw DatabaseException('Failed to $operation: $error');
  }

  /// Generic pagination helper.
  ///
  /// Runs [countQuery] for total, then [dataQuery] for the page slice.
  /// Returns a [PaginatedResult<T>] built from the results.
  Future<PaginatedResult<T>> paginate<T>({
    required int page,
    required int pageSize,
    required Future<int> Function(Database db) countQuery,
    required Future<List<Map<String, dynamic>>> Function(
      Database db,
      int offset,
      int limit,
    ) dataQuery,
    required T Function(Map<String, dynamic>) fromMap,
  }) async {
    final clampedSize =
        pageSize.clamp(1, PaginationConstants.maxPageSize);
    final db = await database;

    final totalCount = await countQuery(db);
    final offset = (page - 1) * clampedSize;
    final rows = await dataQuery(db, offset, clampedSize);
    final items = rows.map(fromMap).toList();

    return PaginatedResult<T>(
      items: items,
      totalCount: totalCount,
      page: page,
      pageSize: clampedSize,
      hasMore: offset + items.length < totalCount,
    );
  }
}
