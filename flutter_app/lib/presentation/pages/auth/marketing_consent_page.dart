import 'package:flutter/material.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/presentation/widgets/headers/aicar_header.dart';

/// 마케팅 수신 동의 상세 페이지
class MarketingConsentPage extends StatelessWidget {
  const MarketingConsentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AiCarHeader(
            title: '마케팅 수신 동의',
            showBack: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.space6),
              child: Text(
                '에이카(AiCar)는 고객님께 유용한 정보를 제공하기 위해 '
                '아래와 같이 마케팅 정보를 수집 및 이용합니다.\n\n'
                '1. 수집항목: 이름, 이메일, 전화번호\n'
                '2. 이용목적: 신규 서비스 안내, 이벤트 정보 제공, '
                '맞춤형 차량 추천 알림\n'
                '3. 보유기간: 동의 철회 시까지\n\n'
                '본 동의는 선택사항이며, 동의하지 않으셔도 '
                '서비스 이용에 제한이 없습니다.\n\n'
                '동의를 철회하시려면 마이페이지 > 설정에서 '
                '변경하실 수 있습니다.',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
