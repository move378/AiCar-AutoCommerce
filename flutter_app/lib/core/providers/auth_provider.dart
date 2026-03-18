import 'package:aicar/domain/entities/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
  });

  final AuthStatus status;
  final User? user;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({AuthStatus? status, User? user}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _checkAuthStatus();
    return const AuthState();
  }

  Future<void> _checkAuthStatus() async {
    // TODO: ITokenStorage 주입 후 저장된 토큰 확인
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  void setAuthenticated(User user) {
    state = AuthState(status: AuthStatus.authenticated, user: user);
  }

  void setUnauthenticated() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
