import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aicar/presentation/pages/ai_chat/ai_chat_page.dart';
import 'package:aicar/presentation/pages/garage/garage_page.dart';
import 'package:aicar/presentation/pages/home/home_page.dart';
import 'package:aicar/presentation/pages/my/my_page.dart';
import 'package:aicar/presentation/pages/test_drive/test_drive_page.dart';
import 'package:aicar/presentation/router/route_names.dart';
import 'package:aicar/presentation/shell/main_shell.dart';

// 각 브랜치별 독립 네비게이터 키
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _testDriveNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'testDrive');
final _chatNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'chat');
final _garageNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'garage');
final _myNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'my');

/// GoRouter Provider — app.dart에서 ref.watch(appRouterProvider)로 사용
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      // ── GNB Shell (StatefulShellRoute for tab state preservation) ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // 0: 홈
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
          // 1: 시승찾기
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
          // 2: 챗봇
          StatefulShellBranch(
            navigatorKey: _chatNavigatorKey,
            routes: [
              GoRoute(
                path: '/chat',
                name: RouteNames.chat,
                builder: (context, state) => const AiChatPage(),
              ),
            ],
          ),
          // 3: 차고
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
          // 4: 마이
          StatefulShellBranch(
            navigatorKey: _myNavigatorKey,
            routes: [
              GoRoute(
                path: '/my',
                name: RouteNames.my,
                builder: (context, state) => const MyPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
