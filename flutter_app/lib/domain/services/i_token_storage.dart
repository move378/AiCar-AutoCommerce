/// 토큰 저장/조회/삭제만 담당 (비즈니스 로직 없음)
/// 구현체: data/services/secure_storage_service_impl.dart
abstract interface class ITokenStorage {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clearAll();
}
