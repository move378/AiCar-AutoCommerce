import 'package:aicar/presentation/pages/ai_chat/ai_chat_page.dart';
import 'package:aicar/presentation/pages/auth/consent_page.dart';
import 'package:aicar/presentation/pages/auth/login_page.dart';
import 'package:aicar/presentation/pages/auth/marketing_consent_page.dart';
import 'package:aicar/presentation/pages/garage/garage_page.dart';
import 'package:aicar/presentation/pages/onboarding/onboarding_page.dart';
// import 'package:aicar/core/providers/auth_provider.dart';
import 'package:aicar/presentation/pages/splash/splash_page.dart';
import 'package:aicar/presentation/pages/vehicle_explore/vehicle_explore_page.dart';
import 'package:aicar/presentation/router/route_names.dart';
import 'package:aicar/presentation/shell/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // final authNotifier = ref.watch(authProvider.notifier);

  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      // /home → /home/chat (default tab)
      if (state.matchedLocation == RouteNames.home) {
        return RouteNames.chat;
      }
      return null;
    },
    // Auth redirect (disabled for now):
    // redirect: (context, state) {
    //   final authStatus = ref.read(authProvider).status;
    //   final location = state.matchedLocation;
    //
    //   if (authStatus == AuthStatus.initial) return null;
    //
    //   final isOnAuth = location == RouteNames.login ||
    //       location == RouteNames.consent ||
    //       location == RouteNames.marketingConsent;
    //
    //   if (authStatus == AuthStatus.unauthenticated && !isOnAuth) {
    //     return RouteNames.login;
    //   }
    //   if (authStatus == AuthStatus.authenticated && isOnAuth) {
    //     return RouteNames.home;
    //   }
    //   return null;
    // },
    // refreshListenable: _AuthStatusListenable(ref, authNotifier),
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.consent,
        builder: (_, __) => const ConsentPage(),
      ),
      GoRoute(
        path: RouteNames.marketingConsent,
        builder: (_, __) => const MarketingConsentPage(),
      ),
      GoRoute(
        path: RouteNames.survey,
        builder: (_, __) => const _PlaceholderPage(title: '설문조사'),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (_, __) => const _PlaceholderPage(title: '설정'),
      ),

      // ── Main shell with bottom navigation ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0 – 홈 (AI Chat)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.chat,
                builder: (_, __) => const AiChatPage(),
              ),
            ],
          ),
          // Tab 1 – 탐색 (Vehicle Explore)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.vehicleSearch,
                builder: (_, __) => const VehicleExplorePage(),
              ),
            ],
          ),
          // Tab 2 – 마이 (Garage)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.garage,
                builder: (_, __) => const GaragePage(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('페이지를 찾을 수 없습니다: ${state.error}')),
    ),
  );
});

/// GoRouter refreshListenable 어댑터
// class _AuthStatusListenable extends ChangeNotifier {
//   _AuthStatusListenable(Ref ref, AuthNotifier notifier) {
//     ref.listen(authProvider, (_, __) => notifyListeners());
//   }
// }

/// 아직 구현되지 않은 화면을 위한 플레이스홀더 페이지
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title\n(준비 중)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
