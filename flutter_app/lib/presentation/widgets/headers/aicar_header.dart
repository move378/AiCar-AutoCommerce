import 'package:flutter/material.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';

/// AiCar 페이지 헤더
///
/// 투명 배경, 중앙 타이틀, 선택적 뒤로가기/액션 버튼
class AiCarHeader extends StatelessWidget {
  const AiCarHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.onBack,
    this.actions,
  });

  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
        child: Row(
          children: [
            // ── Leading ──────────────────────────
            if (showBack)
              GestureDetector(
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.only(right: AppSpacing.space2),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
              )
            else
              const SizedBox(width: 28), // balance for centering

            // ── Title ────────────────────────────
            Expanded(
              child: Text(
                title,
                style: AppTypography.headingXl.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // ── Actions ──────────────────────────
            if (actions != null && actions!.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < actions!.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.space2),
                    actions![i],
                  ],
                ],
              )
            else
              const SizedBox(width: 28), // balance for centering
          ],
        ),
      ),
    );
  }
}
