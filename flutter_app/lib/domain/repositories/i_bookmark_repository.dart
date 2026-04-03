/// 차량 북마크(찜) Repository 인터페이스
///
/// 홈 탭에서 차량 찜하기. 가상차고와 독립.
/// go_api: Drift 기반 영속 저장 (MVP)
abstract class IBookmarkRepository {
  /// 북마크 토글 (있으면 제거, 없으면 추가)
  Future<void> toggleBookmark(String vehicleId);

  /// 북마크된 차량 ID 목록
  Future<Set<String>> getBookmarkedIds();

  /// 특정 차량 북마크 여부
  Future<bool> isBookmarked(String vehicleId);
}
