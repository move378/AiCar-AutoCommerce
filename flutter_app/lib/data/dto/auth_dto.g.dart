// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnboardingRequestDto _$OnboardingRequestDtoFromJson(
        Map<String, dynamic> json) =>
    OnboardingRequestDto(
      deviceId: json['device_id'] as String,
      deviceType: json['device_type'] as String,
      modelName: json['model_name'] as String?,
      osVersion: json['os_version'] as String?,
    );

Map<String, dynamic> _$OnboardingRequestDtoToJson(
        OnboardingRequestDto instance) =>
    <String, dynamic>{
      'device_id': instance.deviceId,
      'device_type': instance.deviceType,
      'model_name': instance.modelName,
      'os_version': instance.osVersion,
    };

SocialLoginRequestDto _$SocialLoginRequestDtoFromJson(
        Map<String, dynamic> json) =>
    SocialLoginRequestDto(
      providerToken: json['provider_token'] as String,
    );

Map<String, dynamic> _$SocialLoginRequestDtoToJson(
        SocialLoginRequestDto instance) =>
    <String, dynamic>{
      'provider_token': instance.providerToken,
    };

RefreshRequestDto _$RefreshRequestDtoFromJson(Map<String, dynamic> json) =>
    RefreshRequestDto(
      refreshToken: json['refresh_token'] as String,
    );

Map<String, dynamic> _$RefreshRequestDtoToJson(RefreshRequestDto instance) =>
    <String, dynamic>{
      'refresh_token': instance.refreshToken,
    };

TokenResponseDto _$TokenResponseDtoFromJson(Map<String, dynamic> json) =>
    TokenResponseDto(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );

Map<String, dynamic> _$TokenResponseDtoToJson(TokenResponseDto instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
    };

SocialTokenResponseDto _$SocialTokenResponseDtoFromJson(
        Map<String, dynamic> json) =>
    SocialTokenResponseDto(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      isNewUser: json['is_new_user'] as bool,
    );

Map<String, dynamic> _$SocialTokenResponseDtoToJson(
        SocialTokenResponseDto instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'is_new_user': instance.isNewUser,
    };

UserProfileDto _$UserProfileDtoFromJson(Map<String, dynamic> json) =>
    UserProfileDto(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      profileUrl: json['profile_url'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$UserProfileDtoToJson(UserProfileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'profile_url': instance.profileUrl,
      'status': instance.status,
    };
