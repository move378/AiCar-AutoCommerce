import 'package:aicar/core/constants/api_constants.dart';
import 'package:aicar/data/dto/auth_dto.dart';
import 'package:aicar/domain/entities/auth_tokens.dart';
import 'package:aicar/domain/entities/user.dart';
import 'package:aicar/domain/repositories/i_auth_repository.dart';
import 'package:aicar/domain/services/i_token_storage.dart';
import 'package:dio/dio.dart';

/// Go API 인증 Repository 구현체
///
/// 데이터 흐름: Flutter → Dio → Go API → JWT 토큰 → SecureStorage
class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl(this._dio, this._tokenStorage);

  final Dio _dio;
  final ITokenStorage _tokenStorage;

  @override
  Future<AuthTokens> onboard({
    required String deviceId,
    required String deviceType,
    String? modelName,
    String? osVersion,
  }) async {
    final request = OnboardingRequestDto(
      deviceId: deviceId,
      deviceType: deviceType,
      modelName: modelName,
      osVersion: osVersion,
    );

    final response = await _dio.post(
      ApiConstants.onboard,
      data: request.toJson(),
    );

    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;
    final tokens = TokenResponseDto.fromJson(data);

    final authTokens = AuthTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );

    await _tokenStorage.saveTokens(
      accessToken: authTokens.accessToken,
      refreshToken: authTokens.refreshToken,
    );

    return authTokens;
  }

  @override
  Future<({AuthTokens tokens, bool isNewUser})> loginWithKakao(
      String kakaoAccessToken) async {
    final request = SocialLoginRequestDto(providerToken: kakaoAccessToken);

    final response = await _dio.post(
      ApiConstants.kakaoLogin,
      data: request.toJson(),
    );

    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;
    final socialResponse = SocialTokenResponseDto.fromJson(data);

    final tokens = AuthTokens(
      accessToken: socialResponse.accessToken,
      refreshToken: socialResponse.refreshToken,
    );

    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );

    return (tokens: tokens, isNewUser: socialResponse.isNewUser);
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    final request = RefreshRequestDto(refreshToken: refreshToken);

    final response = await _dio.post(
      ApiConstants.refresh,
      data: request.toJson(),
    );

    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;
    final tokenResponse = TokenResponseDto.fromJson(data);

    final tokens = AuthTokens(
      accessToken: tokenResponse.accessToken,
      refreshToken: tokenResponse.refreshToken,
    );

    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );

    return tokens;
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } finally {
      await _tokenStorage.clearAll();
    }
  }

  @override
  Future<User> getProfile() async {
    final response = await _dio.get(ApiConstants.profile);

    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;
    final profile = UserProfileDto.fromJson(data);

    return User(
      id: profile.id,
      email: profile.email ?? '',
      nickname: profile.name,
      profileImageUrl: profile.profileUrl,
      createdAt: DateTime.now(),
    );
  }
}
