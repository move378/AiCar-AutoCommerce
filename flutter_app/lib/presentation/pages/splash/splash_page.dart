import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  double _logoOpacity = 0.0;
  double _subtitleOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    // Start logo fade-in
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() => _logoOpacity = 1.0);

    // Start subtitle fade-in after a short delay
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _subtitleOpacity = 1.0);

    // Navigate to onboarding after 2 seconds total
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _logoOpacity,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeIn,
              child: Text(
                'AiCar',
                style: AppTypography.h1.copyWith(
                  color: AppColors.white,
                  fontSize: 40,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedOpacity(
              opacity: _subtitleOpacity,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeIn,
              child: Text(
                '수입차 AI 컨시어지',
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
