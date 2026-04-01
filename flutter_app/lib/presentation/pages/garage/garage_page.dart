import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aicar/core/providers/auth_provider.dart';
import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/presentation/widgets/buttons/aicar_button.dart';
import 'package:aicar/presentation/widgets/headers/aicar_header.dart';

/// 차고 탭 — 가상차고 (저장된 카드 목록 + 상담 기록)
///
/// 미로그인 시: 로그인 유도 화면
/// 로그인 완료 시: 헤더(톱니바퀴→마이) + 저장된 차량 목록 (Phase 8에서 구현)
class GaragePage extends ConsumerWidget {
  const GaragePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    if (!auth.isLoggedIn || !auth.hasConsented) {
      return _buildLoginPrompt(context);
    }

    return _buildGarageContent(context);
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
                Icons.garage_outlined,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                '차고를 이용하려면\n로그인이 필요해요',
                textAlign: TextAlign.center,
                style: AppTypography.heading2xl.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(
                '로그인하면 저장한 차량과\n상담 기록을 확인할 수 있어요',
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

  Widget _buildGarageContent(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AiCarHeader(
            title: '차고',
            actions: [
              GestureDetector(
                onTap: () => context.push('/my'),
                child: const Icon(
                  Icons.settings_outlined,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.garage_outlined,
                      size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 12),
                  Text(
                    '저장된 차량이 없습니다',
                    style: AppTypography.bodySm
                        .copyWith(color: AppColors.textTertiary),
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
