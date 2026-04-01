---
phase: 04-onboarding
plan: 01
subsystem: auth
tags: [flutter, onboarding, splash, vehicle-check, login, consent, auth, gnb-4tab]

provides:
  - SplashPage (로고 + 권한 획득 → onboarding)
  - VehicleCheckPage (4단계: 차량번호→소유자명→조회결과→등록완료, 스킵 가능)
  - LoginPage (카카오/Apple, 차고/마이 진입 시 트리거)
  - ConsentPage (필수2+선택1, 완료 시 차고 복귀)
  - AuthNotifier (Riverpod Notifier mock)
  - GaragePage auth guard + 헤더 톱니바퀴 → /my
  - MyPage auth guard (GNB 밖, push 진입)
  - GNB 5탭→4탭 변경 (마이 제거)

key-decisions:
  - "GNB 4탭: 마이를 제거하고 차고 헤더 톱니바퀴에서 진입"
  - "온보딩: SNS 로그인 없이 차량조회 4단계 (공공API mock)"
  - "로그인/약관동의는 차고·마이 진입 시만 트리거"
  - "GoRouter global redirect 제거 → 페이지 내부 auth guard"

duration: ~20min
completed: 2026-04-01T00:00:00Z
---

# Phase 4 Plan 01: Onboarding Summary

**Splash→차량조회(4단계)→Home + GNB 4탭 + 차고/마이 auth guard**

## Acceptance Criteria Results

| Criterion | Status | Notes |
|-----------|--------|-------|
| Splash → onboarding | Pass | 2초 후 /onboarding으로 전환 |
| Vehicle check 4단계 | Pass | 차량번호→소유자명→결과→완료, 스킵 가능 |
| GNB 4탭 (마이 제거) | Pass | 홈/시승찾기/챗봇/차고 |
| 차고/마이 auth guard | Pass | 미로그인→login→consent→복귀 |
| 마이: 차고 톱니바퀴 | Pass | /my push, GNB 밖 |
| Static analysis | Pass | dart analyze → No issues found |

---
*Phase: 04-onboarding, Plan: 01*
*Completed: 2026-04-01*
