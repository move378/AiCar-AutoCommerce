import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aicar/core/providers/auth_provider.dart';
import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/presentation/widgets/buttons/aicar_button.dart';
import 'package:aicar/presentation/widgets/headers/aicar_header.dart';

/// 서비스 이용약관 동의 페이지
///
/// 차고 탭 → 로그인 → 약관 동의 → pop으로 차고 탭 복귀
class ConsentPage extends ConsumerStatefulWidget {
  const ConsentPage({super.key});

  @override
  ConsumerState<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends ConsumerState<ConsentPage> {
  bool _agreeTerms = false;
  bool _agreePrivacy = false;
  bool _agreeMarketing = false;

  bool get _allRequired => _agreeTerms && _agreePrivacy;
  bool get _allChecked => _agreeTerms && _agreePrivacy && _agreeMarketing;

  void _toggleAll(bool? value) {
    setState(() {
      _agreeTerms = value ?? false;
      _agreePrivacy = value ?? false;
      _agreeMarketing = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AiCarHeader(title: '약관 동의', showBack: true),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.space4),

                  Text(
                '서비스 이용을 위해\n약관에 동의해주세요',
                style: AppTypography.heading2xl.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppSpacing.space8),

              _ConsentItem(
                label: '전체 동의',
                isChecked: _allChecked,
                onChanged: _toggleAll,
                isBold: true,
              ),

              const Divider(height: AppSpacing.space6),

              _ConsentItem(
                label: '[필수] 서비스 이용약관',
                isChecked: _agreeTerms,
                onChanged: (v) => setState(() => _agreeTerms = v ?? false),
              ),
              const SizedBox(height: AppSpacing.space3),
              _ConsentItem(
                label: '[필수] 개인정보 처리방침',
                isChecked: _agreePrivacy,
                onChanged: (v) => setState(() => _agreePrivacy = v ?? false),
              ),
              const SizedBox(height: AppSpacing.space3),
              _ConsentItem(
                label: '[선택] 마케팅 수신 동의',
                isChecked: _agreeMarketing,
                onChanged: (v) =>
                    setState(() => _agreeMarketing = v ?? false),
                onDetailTap: () => context.push('/consent/marketing'),
              ),

              const Spacer(),

              AiCarButton(
                label: '동의하고 시작하기',
                onPressed: _allRequired
                    ? () {
                        ref.read(authProvider.notifier).consent();
                        // login → consent push 스택을 pop하여 차고 탭으로 복귀
                        context.go('/garage');
                      }
                    : null,
                size: AiCarButtonSize.lg,
                style: AiCarButtonStyle.solid,
                isExpanded: true,
              ),

                  const SizedBox(height: AppSpacing.space8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentItem extends StatelessWidget {
  const _ConsentItem({
    required this.label,
    required this.isChecked,
    required this.onChanged,
    this.isBold = false,
    this.onDetailTap,
  });

  final String label;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;
  final bool isBold;
  final VoidCallback? onDetailTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check_circle : Icons.check_circle_outline,
            color: isChecked ? AppColors.secondary : AppColors.textDisabled,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Text(
              label,
              style: (isBold ? AppTypography.bodyMd : AppTypography.bodySm)
                  .copyWith(
                color: AppColors.textPrimary,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          if (onDetailTap != null)
            GestureDetector(
              onTap: onDetailTap,
              child: Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
