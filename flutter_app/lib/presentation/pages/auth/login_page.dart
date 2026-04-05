import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aicar/core/providers/auth_provider.dart';
import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/presentation/widgets/headers/aicar_header.dart';

/// 로그인 페이지 — SNS 소셜 로그인 (카카오, Apple)
///
/// 차고 탭 진입 시 미로그인이면 push로 호출됨.
/// 로그인 완료 → consent 페이지로 이동.
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AiCarHeader(title: '로그인', showBack: true),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space6),
              child: Column(
                children: [
                  const Spacer(flex: 2),

              // ── 로고 & 타이틀 ──────────────────────
              Image.asset(
                'assets/images/character.png',
                width: 100,
                height: 100,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.directions_car,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                'AiCar',
                style: AppTypography.display4xl.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(
                '수입차 AI 컨시어지',
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const Spacer(flex: 3),

              // ── SNS 로그인 버튼 ────────────────────
              _SnsLoginButton(
                label: '카카오로 시작하기',
                backgroundColor: const Color(0xFFFEE500),
                foregroundColor: const Color(0xFF191919),
                icon: Icons.chat_bubble,
                onTap: () async {
                  try {
                    await ref.read(authProvider.notifier).loginWithKakao();
                  } catch (_) {
                    // 카카오 로그인 실패 시 무시 (SDK 미설정 등)
                  }
                  if (context.mounted) context.push('/consent');
                },
              ),
              const SizedBox(height: AppSpacing.space3),
              _SnsLoginButton(
                label: 'Apple로 시작하기',
                backgroundColor: AppColors.background,
                foregroundColor: AppColors.textPrimary,
                icon: Icons.apple,
                borderColor: AppColors.textDisabled,
                onTap: () {
                  // TODO: Apple 로그인 구현 예정
                  context.push('/consent');
                },
              ),

                  const SizedBox(height: AppSpacing.space10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// SNS 로그인 버튼 (카카오/Apple 브랜드 색상)
class _SnsLoginButton extends StatelessWidget {
  const _SnsLoginButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.onTap,
    this.borderColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final VoidCallback onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: foregroundColor, size: 22),
            const SizedBox(width: AppSpacing.space2),
            Text(
              label,
              style: AppTypography.bodyMd.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
