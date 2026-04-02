# PAUL Handoff

**Date:** 2026-04-02
**Status:** paused (컨텍스트 윈도우 보존 — 08-03 plan 시작 직전)

---

## READ THIS FIRST

You have no prior context. This document tells you everything.

**Project:** AiCar (에이카) — 수입차 AI 컨시어지 앱
**Core value:** 수입차 구매 과정의 정보 비대칭을 해소하는 AI 컨시어지 앱

---

## Current State

**Milestone:** v0.1 MVP Release
**Phase:** 8 of 9 — Domain Separation (2/3 plans complete)
**Plan:** 08-03 next — 차고 3탭 UI

**Loop Position:**
```
PLAN ──▶ APPLY ──▶ UNIFY
  ✓        ✓        ✓     [Loop complete — ready for next PLAN]
```

**Milestone Progress:** 85% (Phase 8: 2/3 plans)
**Velocity:** 13 plans / ~145min (avg ~11min/plan)

---

## What Was Done (This Session)

### 08-01: Entity + Repository 분리
- VehicleCard → Vehicle(스펙 중심) + ConsultationCard(상담 결과, vehicleId 참조)
- ICardRepository → IVehicleRepository + IBookmarkRepository + IGarageRepository
- go_api + supabase 듀얼 구현체 6개
- Drift BookmarkTable (schemaVersion 3, 영속 저장)
- 기존 VehicleCard/ICardRepository 완전 삭제

### 08-02: Provider 분리 + VehicleDetailPage + _extractQuery 수정
- Repository Provider 3개 → core/providers/repository_providers.dart 공용화
- bookmarkProvider (Drift 영속, optimistic update)
- VehicleDetailPage 신규 (차량 상세 + 스펙 4개 + 북마크 토글)
- 홈 차량 탭 → VehicleDetailPage 라우팅 (이전: AI카드 페이지)
- _extractQuery 버그 수정: AI 응답 → 사용자 입력 기반 _findUserQuery로 교체

### ROADMAP 변경
- 08-03 추가: 차고 3탭 UI (가상차고 + 북마크 + 최근본)
- Phase 9 축소: MyPage만 남김 (차고 UI는 Phase 8로 흡수)

---

## What's Next: 08-03 차고 3탭 UI

### Figma 기반 차고 화면 구성 (사용자 제공 스크린샷)

**가상 차고 탭 (1번째):**
- 상단: ConsultationCard 가로 캐러셀 (dark card, 차량 정보 + 가격/월납부금/총비용 + "에이카 상담 기록 >" 링크)
- 하단: 내 주변 전시장 / 저장한 전시장 (칩 전환)
  - 전시장 카드: 브랜드 로고 + 거리 + 주소 + 영업시간 + 이미지
  - "상세 정보" / "시승 예약" 버튼

**북마크 탭 (2번째):**
- 카테고리 칩: 전체 / 일반 / 전기차
- 차량 카드 그리드 (2열) — 이미지 + 브랜드/모델 + 스펙 + 가격 + 월납부금 + 북마크 아이콘

**최근 본 탭 (3번째):**
- 카테고리 칩: 전체 / 일반 / 전기차
- 차량 카드 리스트 (수직) — 좌측 이미지 + 우측 정보 + 북마크 아이콘

### 사용 가능한 Provider/Repository
- garageRepositoryProvider → getSavedCards(), saveToGarage(), removeFromGarage()
- bookmarkProvider → bookmarkedIds, toggleBookmark()
- vehicleRepositoryProvider → getAllVehicles(), getVehicleById()

### 주의사항
- 전시장 데이터는 MVP에서 목업 (실제 위치 API 연동 X)
- 최근 본 차량 기능: 별도 히스토리 저장 필요 (인메모리 or Drift — MVP 결정 필요)
- ConsultationCard 캐러셀: garageRepo.getSavedCards()에서 vehicleId로 Vehicle 조회 필요 (join 패턴)
- 기존 garage_page.dart placeholder를 풀 구현으로 교체

---

## Key Decisions Made (This Session)

| Decision | Phase |
|----------|-------|
| Vehicle=스펙 중심, ConsultationCard=상담 결과(vehicleId 참조, nested 아님) | 08-01 |
| Bookmark Drift 영속 저장 (인메모리 거부) | 08-01 |
| Garage JSON 마이그레이션: fromJson 실패 시 try-catch 조용히 삭제 | 08-01 |
| Repository Provider → core/providers/ 공용화 (3+ feature 공유) | 08-02 |
| _extractQuery 삭제 → _findUserQuery (사용자 입력 기반) | 08-02 |
| Phase 8에 차고 3탭 UI 흡수, Phase 9는 MyPage만 | 08-02 |

CARL decision: flutter-008 (Vehicle/ConsultationCard 도메인 분리)

---

## Key Files

| File | Purpose |
|------|---------|
| `.paul/STATE.md` | Live project state |
| `.paul/ROADMAP.md` | Phase overview (08-03 추가됨) |
| `.paul/phases/08-domain-separation/08-01-SUMMARY.md` | Entity + Repo 분리 결과 |
| `.paul/phases/08-domain-separation/08-02-SUMMARY.md` | Provider + VehicleDetailPage 결과 |
| `flutter_app/lib/core/providers/repository_providers.dart` | 공용 Repository Provider |
| `flutter_app/lib/presentation/pages/home/providers/bookmark_provider.dart` | 북마크 Provider |
| `flutter_app/lib/presentation/pages/garage/garage_page.dart` | 차고 placeholder (08-03에서 교체) |
| `flutter_app/lib/domain/repositories/i_garage_repository.dart` | 가상차고 인터페이스 |
| `docs/screenshots/차고UI.png` | Figma 차고 UI 스크린샷 (3탭) |

---

## Git State

- Branch: `feat/flutter/domain-separation` (main + 08-01 + 08-02 변경사항)
- 아직 commit 안 됨 — pause 시 git push 필요 여부 확인

---

## Resume Instructions

1. `/paul:resume` 실행
2. 08-03 차고 3탭 UI → /paul:plan 진행
3. Figma 스크린샷 `docs/screenshots/차고UI.png` 참고
4. Task 구조 제안: T1=가상차고 탭, T2=북마크 탭, T3=최근 본 탭

---

*Handoff created: 2026-04-02*
