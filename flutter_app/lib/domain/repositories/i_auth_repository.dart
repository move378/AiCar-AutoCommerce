import 'package:aicar/domain/entities/auth_tokens.dart';
import 'package:aicar/domain/entities/user.dart';

/// 인증 Repository 인터페이스
///
/// 흐름: onboard(device_id) → guest 토큰 → loginWithKakao → 소셜 토큰
abstract interface class IAuthRepository {
  /// 디바이스 온보딩 — guest 토큰 발급
  Future<AuthTokens> onboard({
    required String deviceId,
    required String deviceType,
    String? modelName,
    String? osVersion,
  });

  /// 카카오 소셜 로그인 — 카카오 access_token → 서버 JWT
  Future<({AuthTokens tokens, bool isNewUser})> loginWithKakao(
      String kakaoAccessToken);

  /// Google 소셜 로그인 — Google access_token → 서버 JWT
  Future<({AuthTokens tokens, bool isNewUser})> loginWithGoogle(
      String googleAccessToken);

  /// 토큰 갱신
  Future<AuthTokens> refresh(String refreshToken);

  /// 로그아웃
  Future<void> logout();

  /// 프로필 조회
  Future<User> getProfile();

  /// 회원 탈퇴
  Future<void> deleteAccount();
}
