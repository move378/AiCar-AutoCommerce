import 'package:aicar/domain/repositories/i_bookmark_repository.dart';

/// Supabase 백엔드용 북마크 Repository 스텁
class BookmarkRepositoryImpl implements IBookmarkRepository {
  @override
  Future<void> toggleBookmark(String vehicleId) {
    throw UnimplementedError('Supabase bookmark not implemented');
  }

  @override
  Future<Set<String>> getBookmarkedIds() {
    throw UnimplementedError('Supabase bookmark not implemented');
  }

  @override
  Future<bool> isBookmarked(String vehicleId) {
    throw UnimplementedError('Supabase bookmark not implemented');
  }
}
