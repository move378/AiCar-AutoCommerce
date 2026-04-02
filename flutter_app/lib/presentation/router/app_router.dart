import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aicar/presentation/pages/ai_chat/ai_chat_page.dart';
import 'package:aicar/presentation/pages/ai_chat/chat_history_page.dart';
import 'package:aicar/presentation/pages/auth/consent_page.dart';
import 'package:aicar/presentation/pages/auth/login_page.dart';
import 'package:aicar/presentation/pages/auth/marketing_consent_page.dart';
import 'package:aicar/presentation/pages/garage/garage_page.dart';
import 'package:aicar/presentation/pages/home/home_page.dart';
import 'package:aicar/presentation/pages/my/my_page.dart';
import 'package:aicar/presentation/pages/onboarding/vehicle_check_page.dart';
import 'package:aicar/presentation/pages/splash/splash_page.dart';
import 'package:aicar/presentation/pages/test_drive/test_drive_page.dart';
import 'package:aicar/presentation/router/route_names.dart';
import 'package:aicar/presentation/shell/main_shell.dart';

// 각 브랜치별 독립 네비게이터 키
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _testDriveNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'testDrive');
final _chatNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'chat');
final _garageNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'garage');

/// GoRouter Provider
///
/// 플로우:
/// splash → onboarding(차량조회) → home (GNB 4탭)
/// 차고/마이 진입 시: 미로그인 → login → consent → 복귀
/// 마이: 차고 헤더 톱니바퀴 → /my (push, GNB 밖)
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // ── 진입 플로우 (Shell 밖) ──────────────────
      GoRoute(
        path: '/splash',
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const VehicleCheckPage(),
      ),

      // ── Auth 플로우 (차고/마이 진입 시 트리거, Shell 밖) ──
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/consent',
        name: RouteNames.consent,
        builder: (context, state) => const ConsentPage(),
        routes: [
          GoRoute(
            path: 'marketing',
            builder: (context, state) => const MarketingConsentPage(),
          ),
        ],
      ),

      // ── 마이페이지 (Shell 밖, 차고 헤더에서 push) ──
      GoRoute(
        path: '/my',
        name: RouteNames.my,
        builder: (context, state) => const MyPage(),
      ),

      // ── GNB Shell (4탭: 홈/시승찾기/챗봇/차고) ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                name: RouteNames.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _testDriveNavigatorKey,
            routes: [
              GoRoute(
                path: '/test-drive',
                name: RouteNames.testDrive,
                builder: (context, state) => const TestDrivePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _chatNavigatorKey,
            routes: [
              GoRoute(
                path: '/chat',
                name: RouteNames.chat,
                builder: (context, state) => const AiChatPage(),
                routes: [
                  GoRoute(
                    path: 'history',
                    name: RouteNames.chatHistory,
                    builder: (context, state) => const ChatHistoryPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _garageNavigatorKey,
            routes: [
              GoRoute(
                path: '/garage',
                name: RouteNames.garage,
                builder: (context, state) => const GaragePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
