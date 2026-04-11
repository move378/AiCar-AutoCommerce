import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

import 'package:aicar/core/providers/dio_provider.dart';
import 'package:aicar/core/providers/repository_providers.dart';

/// 인증 상태
@immutable
class AuthState {
  const AuthState({
    this.isLoggedIn = false,
    this.isGuest = false,
    this.hasConsented = false,
    this.userName,
    this.userId,
    this.provider,
  });

  final bool isLoggedIn;
  final bool isGuest;
  final bool hasConsented;
  final String? userName;
  final String? userId;
  final String? provider;

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isGuest,
    bool? hasConsented,
    String? userName,
    String? userId,
    String? provider,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isGuest: isGuest ?? this.isGuest,
      hasConsented: hasConsented ?? this.hasConsented,
      userName: userName ?? this.userName,
      userId: userId ?? this.userId,
      provider: provider ?? this.provider,
    );
  }
}

/// 인증 상태 관리
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  /// 온보딩 (guest 토큰 발급)
  Future<void> onboard() async {
    final authRepo = ref.read(authRepositoryProvider);
    final tokenStorage = ref.read(tokenStorageProvider);

    // 이미 토큰이 있으면 스킵
    final existing = await tokenStorage.getAccessToken();
    if (existing != null) {
      state = state.copyWith(isGuest: true);
      return;
    }

    final deviceId =
        '${Platform.isIOS ? 'IOS' : 'ANDROID'}-${DateTime.now().millisecondsSinceEpoch}';

    await authRepo.onboard(
      deviceId: deviceId,
      deviceType: Platform.isIOS ? 'ios' : 'android',
    );

    state = state.copyWith(isGuest: true);
  }

  /// 카카오 로그인
  Future<void> loginWithKakao() async {
    final authRepo = ref.read(authRepositoryProvider);

    // 카카오 SDK 로그인
    kakao.OAuthToken kakaoToken;
    if (await kakao.isKakaoTalkInstalled()) {
      kakaoToken = await kakao.UserApi.instance.loginWithKakaoTalk();
    } else {
      kakaoToken = await kakao.UserApi.instance.loginWithKakaoAccount();
    }

    // 백엔드에 카카오 토큰 전송
    await authRepo.loginWithKakao(kakaoToken.accessToken);

    state = state.copyWith(
      isLoggedIn: true,
      isGuest: false,
      provider: 'kakao',
    );

    // 프로필 조회
    try {
      final user = await authRepo.getProfile();
      state = state.copyWith(
        userName: user.nickname ?? user.email,
        userId: user.id,
      );
    } catch (_) {
      // 프로필 조회 실패해도 로그인 유지
    }
  }

  /// Google 로그인
  Future<void> loginWithGoogle() async {
    final authRepo = ref.read(authRepositoryProvider);
    final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
    final account = await googleSignIn.signIn();
    if (account == null) return;
    final auth = await account.authentication;
    final accessToken = auth.accessToken;
    if (accessToken == null) throw Exception('Google accessToken이 null입니다');
    await authRepo.loginWithGoogle(accessToken);
    state = state.copyWith(
      isLoggedIn: true,
      isGuest: false,
      provider: 'google',
    );
    try {
      final user = await authRepo.getProfile();
      state = state.copyWith(
        userName: user.nickname ?? user.email,
        userId: user.id,
      );
    } catch (_) {}
  }

  /// 약관 동의
  void consent() {
    state = state.copyWith(hasConsented: true);
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.logout();
    } finally {
      state = const AuthState();
    }
  }
}

/// Auth Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
