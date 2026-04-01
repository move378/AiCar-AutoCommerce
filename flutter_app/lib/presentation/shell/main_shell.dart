import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/presentation/widgets/tab_bar/aicar_tab_bar.dart';

/// 메인 앱 Shell — GNB TabBar + 탭별 네비게이션 스택
///
/// GoRouter StatefulShellRoute의 builder에서 사용.
/// navigationShell이 탭별 상태를 보존하고, AiCarTabBar가 탭 전환을 담당.
class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: AiCarTabBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
