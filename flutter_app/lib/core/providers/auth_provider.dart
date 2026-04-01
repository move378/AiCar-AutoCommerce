import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 인증 상태
@immutable
class AuthState {
  const AuthState({
    this.isLoggedIn = false,
    this.hasConsented = false,
    this.userName,
    this.provider,
  });

  final bool isLoggedIn;
  final bool hasConsented;
  final String? userName;
  final String? provider; // 'kakao', 'google', 'apple'

  AuthState copyWith({
    bool? isLoggedIn,
    bool? hasConsented,
    String? userName,
    String? provider,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      hasConsented: hasConsented ?? this.hasConsented,
      userName: userName ?? this.userName,
      provider: provider ?? this.provider,
    );
  }
}

/// 인증 상태 관리 — MVP mock (실제 API 연동은 추후)
///
/// 로그인/약관 동의는 차고 탭 진입 시 트리거.
/// 온보딩(차량 조회)은 인증과 무관하게 splash 이후 진행.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  /// Mock 로그인
  void login(String provider) {
    state = state.copyWith(
      isLoggedIn: true,
      userName: '테스트 사용자',
      provider: provider,
    );
  }

  /// 약관 동의 완료
  void consent() {
    state = state.copyWith(hasConsented: true);
  }

  /// 로그아웃
  void logout() {
    state = const AuthState();
  }
}

/// Auth Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
