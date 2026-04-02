import 'package:aicar/data/datasources/local/app_database.dart';
import 'package:aicar/domain/repositories/i_bookmark_repository.dart';

/// Go API 백엔드용 북마크 Repository 구현체
///
/// MVP: Drift 기반 영속 저장 (앱 재시작 후 유지)
class BookmarkRepositoryImpl implements IBookmarkRepository {
  BookmarkRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<void> toggleBookmark(String vehicleId) async {
    final existing = await (_db.select(_db.bookmarkTable)
          ..where((t) => t.vehicleId.equals(vehicleId)))
        .getSingleOrNull();

    if (existing != null) {
      await (_db.delete(_db.bookmarkTable)
            ..where((t) => t.vehicleId.equals(vehicleId)))
          .go();
    } else {
      await _db.into(_db.bookmarkTable).insert(
            BookmarkTableCompanion.insert(
              vehicleId: vehicleId,
              bookmarkedAt: DateTime.now(),
            ),
          );
    }
  }

  @override
  Future<Set<String>> getBookmarkedIds() async {
    final rows = await _db.select(_db.bookmarkTable).get();
    return rows.map((r) => r.vehicleId).toSet();
  }

  @override
  Future<bool> isBookmarked(String vehicleId) async {
    final row = await (_db.select(_db.bookmarkTable)
          ..where((t) => t.vehicleId.equals(vehicleId)))
        .getSingleOrNull();
    return row != null;
  }
}
