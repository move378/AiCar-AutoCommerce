import 'package:json_annotation/json_annotation.dart';

part 'auth_dto.g.dart';

/// POST /auth/onboard 요청
@JsonSerializable(fieldRename: FieldRename.snake)
class OnboardingRequestDto {
  const OnboardingRequestDto({
    required this.deviceId,
    required this.deviceType,
    this.modelName,
    this.osVersion,
  });

  final String deviceId;
  final String deviceType;
  final String? modelName;
  final String? osVersion;

  Map<String, dynamic> toJson() => _$OnboardingRequestDtoToJson(this);
}

/// POST /auth/kakao-login 요청
@JsonSerializable(fieldRename: FieldRename.snake)
class SocialLoginRequestDto {
  const SocialLoginRequestDto({required this.providerToken});

  final String providerToken;

  Map<String, dynamic> toJson() => _$SocialLoginRequestDtoToJson(this);
}

/// POST /auth/refresh 요청
@JsonSerializable(fieldRename: FieldRename.snake)
class RefreshRequestDto {
  const RefreshRequestDto({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() => _$RefreshRequestDtoToJson(this);
}

/// 토큰 응답 (onboard, refresh)
@JsonSerializable(fieldRename: FieldRename.snake)
class TokenResponseDto {
  const TokenResponseDto({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory TokenResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseDtoFromJson(json);
}

/// 소셜 로그인 토큰 응답
@JsonSerializable(fieldRename: FieldRename.snake)
class SocialTokenResponseDto {
  const SocialTokenResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.isNewUser,
  });

  final String accessToken;
  final String refreshToken;
  final bool isNewUser;

  factory SocialTokenResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SocialTokenResponseDtoFromJson(json);
}

/// GET /user/me 응답
@JsonSerializable(fieldRename: FieldRename.snake)
class UserProfileDto {
  const UserProfileDto({
    required this.id,
    this.name,
    this.email,
    this.profileUrl,
    this.status,
  });

  final String id;
  final String? name;
  final String? email;
  final String? profileUrl;
  final String? status;

  factory UserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDtoFromJson(json);
}
