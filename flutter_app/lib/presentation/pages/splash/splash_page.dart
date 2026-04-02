import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_typography.dart';

/// 스플래시 화면 — 로고 표시 + 앱 권한 획득 후 온보딩으로 전환
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    // TODO: 앱 권한 획득 (카메라, 위치 등) — 추후 구현
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // 온보딩(차량 조회)으로 이동
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/character.png',
              width: 120,
              height: 120,
              errorBuilder: (_, __, ___) => Icon(
                Icons.directions_car,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'AiCar',
              style: AppTypography.display3xl.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '수입차 AI 컨시어지',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
