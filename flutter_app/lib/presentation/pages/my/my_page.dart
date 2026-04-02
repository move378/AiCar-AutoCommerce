import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aicar/core/providers/auth_provider.dart';
import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/presentation/widgets/buttons/aicar_button.dart';
import 'package:aicar/presentation/widgets/headers/aicar_header.dart';

/// 마이 탭 — 마이페이지
///
/// 미로그인 시: 로그인 유도 화면
/// 로그인 완료 시: 프로필 + 설정 (Phase 8에서 구현)
class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    if (!auth.isLoggedIn || !auth.hasConsented) {
      return _buildLoginPrompt(context);
    }

    return _buildMyContent(auth);
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                '마이페이지를 이용하려면\n로그인이 필요해요',
                textAlign: TextAlign.center,
                style: AppTypography.heading2xl.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(
                '로그인하면 프로필과\n설정을 관리할 수 있어요',
                textAlign: TextAlign.center,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              AiCarButton(
                label: '로그인하기',
                onPressed: () => context.push('/login'),
                size: AiCarButtonSize.lg,
                style: AiCarButtonStyle.solid,
                isExpanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyContent(AuthState auth) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AiCarHeader(title: '마이페이지', showBack: true),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 48, color: AppColors.primary),
                  const SizedBox(height: 12),
                  Text(
                    auth.userName ?? '마이',
                    style: AppTypography.heading2xl
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${auth.provider ?? ''} 로그인',
                    style: AppTypography.bodySm
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
