import 'package:aicar/domain/entities/auth_tokens.dart';
import 'package:aicar/domain/entities/user.dart';

abstract interface class IAuthRepository {
  Future<({AuthTokens tokens, User user})> loginWithKakao(String kakaoToken);
  Future<({AuthTokens tokens, User user})> loginWithApple({
    required String identityToken,
    required String authorizationCode,
  });
  Future<AuthTokens> refresh(String refreshToken);
  Future<void> logout(String refreshToken);
}
