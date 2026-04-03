import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/presentation/widgets/headers/aicar_header.dart';
import 'package:flutter/material.dart';

/// 약관 텍스트 타입
enum LegalTextType {
  terms,
  privacy,
  location,
}

/// 약관 텍스트 페이지 — 이용약관, 개인정보 처리방침, 위치기반 서비스 이용약관 공용
class LegalTextPage extends StatelessWidget {
  const LegalTextPage({super.key, required this.type});

  final LegalTextType type;

  String get _title => switch (type) {
        LegalTextType.terms => '이용약관',
        LegalTextType.privacy => '개인정보 처리방침',
        LegalTextType.location => '위치기반 서비스 이용약관',
      };

  String get _content => switch (type) {
        LegalTextType.terms => _termsContent,
        LegalTextType.privacy => _privacyContent,
        LegalTextType.location => _locationContent,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AiCarHeader(title: _title, showBack: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Text(
                _content,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── MVP Placeholder 약관 텍스트 ──────────────────────

const String _termsContent = '''에이카 서비스 이용약관

제1조 (목적)
이 약관은 에이카(이하 "회사")가 제공하는 에이카 서비스(이하 "서비스")의 이용 조건 및 절차, 회사와 이용자의 권리·의무 및 책임사항을 규정함을 목적으로 합니다.

제2조 (정의)
1. "서비스"란 회사가 제공하는 수입차 AI 상담, 차량 추천, 가상차고, 시승 예약 등 관련 일체의 서비스를 의미합니다.
2. "이용자"란 본 약관에 따라 회사가 제공하는 서비스를 이용하는 자를 말합니다.
3. "회원"이란 회사에 개인정보를 제공하여 회원등록을 한 자로서, 회사의 서비스를 지속적으로 이용할 수 있는 자를 말합니다.

제3조 (약관의 효력 및 변경)
1. 본 약관은 서비스를 이용하고자 하는 모든 이용자에 대하여 그 효력을 발생합니다.
2. 회사는 관련 법령을 위반하지 않는 범위 내에서 본 약관을 변경할 수 있으며, 약관이 변경된 경우에는 지체 없이 이를 공지합니다.

제4조 (서비스의 제공)
1. 회사는 다음 각 호의 서비스를 제공합니다.
   - AI 기반 차량 상담 및 추천 서비스
   - 차량 정보 조회 및 비교 서비스
   - 가상차고 (차량 저장 및 관리)
   - 시승 예약 중개 서비스
   - 기타 회사가 추가 개발하거나 제휴를 통해 제공하는 서비스

제5조 (서비스 이용의 제한)
회사는 다음 각 호에 해당하는 경우 서비스 이용을 제한할 수 있습니다.
1. 타인의 정보를 도용한 경우
2. 서비스 운영을 고의로 방해한 경우
3. 기타 관련 법령이나 회사가 정한 이용조건을 위반한 경우

제6조 (면책조항)
1. 회사는 천재지변, 전쟁, 기간통신사업자의 서비스 중지 등 불가항력적인 사유로 서비스를 제공할 수 없는 경우 책임을 지지 않습니다.
2. 회사는 이용자의 귀책사유로 인한 서비스 이용 장애에 대하여 책임을 지지 않습니다.

부칙
본 약관은 2026년 1월 1일부터 시행합니다.''';

const String _privacyContent = '''에이카 개인정보 처리방침

1. 개인정보의 수집 및 이용 목적
회사는 다음의 목적을 위하여 개인정보를 처리합니다.
- 회원가입 및 관리: 회원 식별, 서비스 이용 의사 확인, 본인 확인
- 서비스 제공: AI 차량 상담, 맞춤 추천, 가상차고 관리
- 마케팅 및 광고: 이벤트 정보 제공, 서비스 개선을 위한 통계 분석

2. 수집하는 개인정보의 항목
- 필수항목: 이름, 이메일, 소셜 로그인 식별자
- 선택항목: 차량번호, 소유자명, 프로필 이미지
- 자동수집항목: 접속 IP, 쿠키, 접속 로그, 서비스 이용 기록

3. 개인정보의 보유 및 이용기간
- 회원 탈퇴 시까지 (탈퇴 후 30일 이내 파기)
- 관계 법령에 의한 보존 필요 시 해당 기간

4. 개인정보의 제3자 제공
회사는 원칙적으로 이용자의 개인정보를 제3자에게 제공하지 않습니다.
다만, 다음의 경우에는 예외로 합니다.
- 이용자가 사전에 동의한 경우
- 법령의 규정에 의한 경우

5. 개인정보의 파기절차 및 방법
- 전자적 파일: 기술적 방법을 이용하여 복원이 불가능하도록 영구 삭제
- 종이 문서: 분쇄기로 분쇄하거나 소각

6. 개인정보 보호책임자
- 성명: 개인정보보호팀
- 연락처: privacy@aicar.kr

7. 개인정보 처리방침의 변경
이 개인정보 처리방침은 2026년 1월 1일부터 적용됩니다.
변경 사항이 있을 경우 시행일 7일 전부터 앱 내 공지를 통해 안내합니다.''';

const String _locationContent = '''에이카 위치기반 서비스 이용약관

제1조 (목적)
이 약관은 에이카(이하 "회사")가 제공하는 위치기반 서비스에 대해 회사와 개인위치정보주체(이하 "이용자")간의 권리·의무 및 책임사항을 규정함을 목적으로 합니다.

제2조 (정의)
1. "위치정보"란 이동성이 있는 물건 또는 개인이 특정한 시간에 존재하거나 존재하였던 장소에 관한 정보를 말합니다.
2. "위치기반서비스"란 위치정보를 이용한 서비스를 말합니다.

제3조 (서비스의 내용)
회사는 위치정보를 이용하여 다음과 같은 위치기반서비스를 제공합니다.
1. 주변 전시장·딜러 검색: 이용자의 현재 위치를 기반으로 가까운 수입차 전시장 및 딜러를 안내합니다.
2. 시승 예약 시 위치 안내: 시승 장소까지의 경로 및 거리 정보를 제공합니다.

제4조 (서비스 이용요금)
회사가 제공하는 위치기반서비스는 무료입니다.
단, 무선 서비스 이용 시 발생하는 데이터 통신료는 별도이며, 이용자가 가입한 통신사의 정책에 따릅니다.

제5조 (개인위치정보의 이용 또는 제공)
1. 회사는 개인위치정보를 이용하여 위치기반서비스를 제공하는 경우 그 이용 또는 제공사실을 이용자에게 통보합니다.
2. 회사는 이용자의 동의 없이 개인위치정보를 제3자에게 제공하지 않습니다.

제6조 (개인위치정보의 보유기간)
회사는 위치기반서비스 제공에 필요한 최소한의 기간 동안만 개인위치정보를 보유하며, 서비스 이용 종료 시 즉시 파기합니다.

제7조 (손해배상)
회사의 위치정보 이용·제공 관련 위법행위로 이용자에게 손해가 발생한 경우, 이용자는 회사에 대해 손해배상을 청구할 수 있습니다.

부칙
본 약관은 2026년 1월 1일부터 시행합니다.''';
