---
phase: 08-domain-separation
plan: 02
subsystem: presentation
tags: [riverpod, provider, gorouter, bookmark, drift]

requires:
  - phase: 08-domain-separation/01
    provides: Vehicle/ConsultationCard entity, IVehicleRepo/IBookmarkRepo/IGarageRepo
provides:
  - Repository Provider 공용화 (core/providers/)
  - bookmarkProvider (Drift 영속 토글)
  - VehicleDetailPage (차량 상세 + 북마크)
  - 홈 → VehicleDetailPage 라우팅
  - _extractQuery 버그 수정 (사용자 입력 기반)
affects: [08-03-garage-ui, 09-mypage]

tech-stack:
  added: []
  patterns:
    - "Repository Provider 공용화: core/providers/에 3+ feature 공유 Provider"
    - "사용자 메시지 역추적: _findUserQuery로 assistant 응답의 트리거 메시지 찾기"
    - "Optimistic update: bookmark toggle 시 UI 먼저 업데이트 후 Drift 저장"

key-files:
  created:
    - flutter_app/lib/core/providers/repository_providers.dart
    - flutter_app/lib/presentation/pages/home/providers/bookmark_provider.dart
    - flutter_app/lib/presentation/pages/home/vehicle_detail_page.dart
  modified:
    - flutter_app/lib/presentation/pages/ai_card/providers/card_provider.dart
    - flutter_app/lib/presentation/pages/home/providers/home_provider.dart
    - flutter_app/lib/presentation/pages/home/home_page.dart
    - flutter_app/lib/presentation/pages/ai_chat/ai_chat_page.dart
    - flutter_app/lib/presentation/pages/ai_chat/chat_history_page.dart
    - flutter_app/lib/presentation/pages/ai_chat/widgets/inline_card_carousel.dart
    - flutter_app/lib/presentation/router/app_router.dart
    - flutter_app/lib/presentation/router/route_names.dart

key-decisions:
  - "Repository Provider → core/providers/ 공용화 (3+ feature 공유)"
  - "bookmarkProvider optimistic update 패턴 (UI 먼저, Drift 후속)"
  - "_extractQuery 삭제 → _findUserQuery: 사용자 입력 직접 전달"

patterns-established:
  - "공용 Provider 위치: core/providers/repository_providers.dart"
  - "사용자 메시지 역추적: assistant index에서 역방향 탐색"

duration: ~12min
started: 2026-04-02
completed: 2026-04-02
---

# Phase 8 Plan 02: Provider 분리 + VehicleDetailPage + _extractQuery 수정 Summary

**Repository Provider 공용화 + bookmarkProvider(Drift 영속) + VehicleDetailPage(차량 상세+북마크) + 홈 라우팅 수정 + _extractQuery 버그 수정(사용자 입력 기반)**

## Performance

| Metric | Value |
|--------|-------|
| Duration | ~12min |
| Started | 2026-04-02 |
| Completed | 2026-04-02 |
| Tasks | 3 completed |
| Files modified | 11 (3 created, 8 updated) |

## Acceptance Criteria Results

| Criterion | Status | Notes |
|-----------|--------|-------|
| AC-1: Repository Provider 공용화 | Pass | vehicleRepo/bookmarkRepo/garageRepo → core/providers/ |
| AC-2: bookmarkProvider 북마크 토글 | Pass | Drift 영속 + optimistic update + 앱 재시작 유지 확인 |
| AC-3: VehicleDetailPage + 홈 라우팅 | Pass | /home/vehicle/:vehicleId, 스펙 카드 4개 + 북마크 |
| AC-4: _extractQuery 버그 수정 | Pass | "BMW 추천해줘" → BMW 3대만 표시 (이전: SUV 4대) |
| AC-5: 컴파일 통과 | Pass | flutter analyze 에러 0 (pre-existing test 제외) |

## Accomplishments

- Repository Provider 3개를 core/providers/로 공용화 (card_provider에서 정의 제거)
- bookmarkProvider: Drift 기반 영속 저장 + optimistic UI update
- VehicleDetailPage: 차량 스펙 상세 + 북마크 토글 + AI 상담하기 버튼
- 홈 차량 탭 → VehicleDetailPage 라우팅 (이전: AI카드 스와이프 페이지)
- _extractQuery 버그 근본 수정: AI 응답이 아닌 사용자 입력에서 쿼리 추출

## Files Created/Modified

| File | Change | Purpose |
|------|--------|---------|
| `core/providers/repository_providers.dart` | Created | vehicleRepo/bookmarkRepo/garageRepo 공용 Provider |
| `home/providers/bookmark_provider.dart` | Created | BookmarkNotifier (Drift 영속 토글) |
| `home/vehicle_detail_page.dart` | Created | 차량 상세 (스펙 + 가격 + 북마크) |
| `ai_card/providers/card_provider.dart` | Modified | repo Provider 정의 제거, import 정리 |
| `home/providers/home_provider.dart` | Modified | repository_providers import |
| `home/home_page.dart` | Modified | _navigateToVehicle → /home/vehicle/:id |
| `ai_chat/ai_chat_page.dart` | Modified | _extractQuery → _findUserQuery |
| `ai_chat/chat_history_page.dart` | Modified | _extractQuery → _findUserQuery |
| `ai_chat/widgets/inline_card_carousel.dart` | Modified | repository_providers import |
| `router/app_router.dart` | Modified | /home/vehicle/:vehicleId 라우트 추가 |
| `router/route_names.dart` | Modified | vehicleDetail 추가 |

## Deviations from Plan

### Summary

| Type | Count | Impact |
|------|-------|--------|
| Auto-fixed | 1 | VehicleDetailPage 디자인 토큰 수정 |

### Auto-fixed Issues

**1. 디자인 토큰 불일치**
- **Found during:** Task 3 (flutter analyze)
- **Issue:** AppTypography.bodyXs, AppColors.border 미존재
- **Fix:** bodyXs → bodySm, border → textDisabled
- **Verification:** flutter analyze 에러 0

## Next Phase Readiness

**Ready:**
- 08-03 차고 3탭 UI: bookmarkProvider, garageRepositoryProvider 즉시 사용 가능
- VehicleDetailPage 패턴을 차고 북마크 탭에서 재사용 가능

**Concerns:**
- None

**Blockers:**
- None

---
*Phase: 08-domain-separation, Plan: 02*
*Completed: 2026-04-02*
