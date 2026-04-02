# Project State

## Project Reference

See: .paul/PROJECT.md (updated 2026-04-02)

**Core value:** 수입차 구매 과정의 정보 비대칭을 해소하는 AI 컨시어지 앱.
**Current focus:** v0.1 MVP — Phase 8: Domain Separation

## Current Position

Milestone: v0.1 MVP Release
Phase: 8 of 9 (Domain Separation)
Plan: 없음 — Phase 신규 삽입
Status: Phase 추가됨 — 기존 Phase 8(Garage)은 Phase 9로 이동
Last activity: 2026-04-02 — Phase 8 Domain Separation 삽입

Progress:
- Milestone: [███████░░░] 78%
- Phase 8: [░░░░░░░░░░] 0%

## Loop Position

Current loop state:
```
PLAN ──▶ APPLY ──▶ UNIFY
  ○        ○        ○     [Ready for PLAN]
```

## Performance Metrics

**Velocity:**
- Total plans completed: 11
- Average duration: ~11min
- Total execution time: ~118min

**By Phase:**

| Phase | Plans | Total Time | Avg/Plan |
|-------|-------|------------|----------|
| 01-design-tokens | 1/1 | ~10min | ~10min |
| 02-common-widgets | 3/3 | ~24min | ~8min |
| 03-app-shell | 1/1 | ~10min | ~10min |
| 04-onboarding | 1/1 | ~12min | ~12min |
| 05-ai-chat | 2/2 | ~25min | ~12min |
| 06-ai-card | 2/2 | ~22min | ~11min |
| 07-home-test-drive | 1/1 | ~15min | ~15min |

## Accumulated Context

### Decisions
- GNB 4탭 (마이 제거) — 마이는 차고 헤더 톱니바퀴에서 push 진입 — Phase 4
- 온보딩: SNS 로그인 없이 차량조회(공공API) 4단계 → 스킵 가능 — Phase 4
- 로그인/약관동의는 차고·마이 탭 진입 시만 트리거 — Phase 4
- Riverpod Notifier (v3) — Phase 4
- 상담 히스토리 목록 → 05-02로 분리 (05-01은 Chat UI + MVP만) — Phase 5
- ChatBubble만 신규 위젯, 나머지 기존 디자인 시스템 재사용 — Phase 5
- ChatMessage freezed 엔티티 + 듀얼 Repository (go_api + supabase 스텁) — Phase 5
- 카드 추천을 별도 페이지가 아닌 채팅 내 인라인 캐러셀로 표시 (UX 단계 축소) — Phase 6
- 히스토리 상세에서도 인라인 카드 동일 패턴 적용 — Phase 6
- 시승찾기 WebView 임베드 (url_launcher 대신) — Phase 7
- 시승찾기 브랜드 7개 (BMW, Benz, Genesis, Tesla, Audi, Lexus, Volvo) — Phase 7

### Deferred Issues
None.

### Blockers/Concerns
None.

## Session Continuity

Last session: 2026-04-02
Stopped at: Phase 8 Domain Separation 준비 완료
Next action: /paul:plan (Phase 8: Domain Separation, plan 08-01)
Resume file: .paul/HANDOFF-2026-04-02-phase8.md
Branch: feat/flutter/domain-separation (main 기반 클린 상태)
Resume context:
- VehicleCard → Vehicle + ConsultationCard 분리 결정됨
- ICardRepository → IVehicleRepo + IBookmarkRepo + IGarageRepo 분리
- 브랜치 feat/flutter/screen-garage-mypage에 Phase 9 참고 코드 보존
- CARL: 듀얼 구현체(go_api + supabase) 필수

---
*STATE.md — Updated after every significant action*
