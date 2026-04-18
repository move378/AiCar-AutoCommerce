import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

import 'package:aicar/core/providers/database_provider.dart';
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
    this.userEmail,
    this.userId,
    this.provider,
  });

  final bool isLoggedIn;
  final bool isGuest;
  final bool hasConsented;
  final String? userName;
  final String? userEmail;
  final String? userId;
  final String? provider;

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isGuest,
    bool? hasConsented,
    String? userName,
    String? userEmail,
    String? userId,
    String? provider,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isGuest: isGuest ?? this.isGuest,
      hasConsented: hasConsented ?? this.hasConsented,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userId: userId ?? this.userId,
      provider: provider ?? this.provider,
    );
  }
}

/// JWT payload에서 user_id 추출
String? _extractUserIdFromJwt(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    var payload = parts[1];
    payload = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(payload));
    final map = jsonDecode(decoded) as Map<String, dynamic>;
    return map['user_id'] as String?;
  } catch (_) {
    return null;
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
    final result = await authRepo.loginWithKakao(kakaoToken.accessToken);

    // JWT에서 userId 추출
    final userId = _extractUserIdFromJwt(result.tokens.accessToken);

    state = state.copyWith(
      isLoggedIn: true,
      isGuest: false,
      provider: 'kakao',
      userId: userId,
    );

    // 프로필 조회
    await _loadProfile();
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
    final result = await authRepo.loginWithGoogle(accessToken);

    // JWT에서 userId 추출
    final userId = _extractUserIdFromJwt(result.tokens.accessToken);

    state = state.copyWith(
      isLoggedIn: true,
      isGuest: false,
      provider: 'google',
      userId: userId,
    );

    // 프로필 조회
    await _loadProfile();
  }

  /// 프로필 조회 (로그인 후 호출)
  Future<void> _loadProfile() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.getProfile();
      state = state.copyWith(
        userName: user.nickname,
        userEmail: user.email.isNotEmpty ? user.email : null,
      );
    } catch (_) {
      // 프로필 조회 실패해도 로그인 유지
    }
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
      await _clearLocalData();
      state = const AuthState();
    }
  }

  /// 회원 탈퇴
  Future<void> deleteAccount() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.deleteAccount();
    } finally {
      await _clearLocalData();
      state = const AuthState();
    }
  }

  /// 로컬 DB 초기화 (북마크, 차고, 채팅 캐시, 최근 본)
  Future<void> _clearLocalData() async {
    try {
      final db = ref.read(appDatabaseProvider);
      await db.delete(db.bookmarkTable).go();
      await db.delete(db.cardCacheTable).go();
      await db.delete(db.chatHistoryTable).go();
    } catch (_) {
      // 로컬 DB 초기화 실패해도 로그아웃은 진행
    }
  }
}

/// Auth Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
