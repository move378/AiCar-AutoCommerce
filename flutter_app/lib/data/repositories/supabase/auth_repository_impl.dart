import 'package:aicar/domain/entities/auth_tokens.dart';
import 'package:aicar/domain/entities/user.dart';
import 'package:aicar/domain/repositories/i_auth_repository.dart';

/// Supabase 인증 Repository — UnimplementedError 스텁
class AuthRepositoryImpl implements IAuthRepository {
  @override
  Future<AuthTokens> onboard({
    required String deviceId,
    required String deviceType,
    String? modelName,
    String? osVersion,
  }) =>
      throw UnimplementedError('Supabase auth not implemented');

  @override
  Future<({AuthTokens tokens, bool isNewUser})> loginWithKakao(
          String kakaoAccessToken) =>
      throw UnimplementedError('Supabase auth not implemented');

  @override
  Future<({AuthTokens tokens, bool isNewUser})> loginWithGoogle(
          String googleAccessToken) =>
      throw UnimplementedError('Supabase auth not implemented');

  @override
  Future<AuthTokens> refresh(String refreshToken) =>
      throw UnimplementedError('Supabase auth not implemented');

  @override
  Future<void> logout() =>
      throw UnimplementedError('Supabase auth not implemented');

  @override
  Future<User> getProfile() =>
      throw UnimplementedError('Supabase auth not implemented');

  @override
  Future<void> deleteAccount() =>
      throw UnimplementedError('Supabase auth not implemented');
}
