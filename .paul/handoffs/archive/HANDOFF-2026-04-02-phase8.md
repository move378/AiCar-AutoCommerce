# PAUL Handoff

**Date:** 2026-04-02
**Status:** paused (세션 컨텍스트 전환)

---

## READ THIS FIRST

You have no prior context. This document tells you everything.

**Project:** AiCar (에이카) — 수입차 AI 컨시어지 앱
**Core value:** 수입차 구매 과정의 정보 비대칭을 해소하는 AI 컨시어지 앱

---

## Current State

**Milestone:** v0.1 MVP Release
**Phase:** 8 of 9 — Domain Separation (NOT STARTED)
**Plan:** 없음 — /paul:plan 실행 필요

**Loop Position:**
```
PLAN ──▶ APPLY ──▶ UNIFY
  ○        ○        ○     [Ready for PLAN]
```

**Milestone Progress:** 78% (7/9 phases done)
**Velocity:** 11 plans / ~118min (avg ~11min/plan)

---

## What Was Done (This Session)

- Phase 6-02 cherry-pick → PR #20 머지 (카드 뒷면 + Radar Chart)
- Phase 7 완료: 홈 차량 탐색 + 시승찾기 WebView (PR #21 머지)
- Phase 8 Garage/MyPage 구현 시도 → **도메인 혼합 문제 발견**
- ROADMAP 재구성: Phase 8 Domain Separation 삽입, 기존 Phase 8 → Phase 9
- 새 브랜치 `feat/flutter/domain-separation` 생성 (main 기반, Flutter 코드 클린)
- CARL 결정: flutter-009 (시승찾기 WebView 임베드)

---

## What's In Progress

- Phase 8: Domain Separation — **미시작** (/paul:plan 필요)
- 브랜치 `feat/flutter/domain-separation` 생성 완료, 코드는 main과 동일
- 브랜치 `feat/flutter/screen-garage-mypage`에 Phase 9 참고 코드 보존

---

## Critical Context: 도메인 분리 배경

### 현재 문제
`VehicleCard` 엔티티 + `ICardRepository` 가 4개 도메인을 혼합:
1. **홈**: 차량 탐색/북마크 → 홈에서 차량 탭 시 AI카드로 잘못 라우팅
2. **챗봇**: AI 추천 인라인 카드
3. **카드**: 추천 결과 스와이프/커스터마이즈
4. **차고**: 저장된 카드 관리 → 북마크가 가상차고로 잘못 저장

### 분리 방향 (사용자 확정)
```
Vehicle (차량 정보)                ConsultationCard (상담 추천)
├── Entity: Vehicle               ├── Entity: ConsultationCard
├── IVehicleRepository            ├── IGarageRepository
│   ├── getAllVehicles()           │   ├── saveToGarage()
│   └── getByCategory()           │   ├── getSavedCards()
├── IBookmarkRepository           │   └── removeFromGarage()
│   ├── toggleBookmark()          ├── consultationCardProvider
│   ├── getBookmarks()            └── AI카드 스와이프 화면
│   └── isBookmarked()
├── vehicleProvider
├── bookmarkProvider
└── 홈 목록 + VehicleDetailPage (신규)
```

### 영향 받는 파일 (~19개)
- Domain: 엔티티 3, 리포지토리 3
- Data: go_api + supabase 구현체 4
- Providers: 4
- Pages: 5+

### ROADMAP Plan 구조
- 08-01: Entity + Repository 분리 (Vehicle, Bookmark, Garage)
- 08-02: Provider + UI 연결 (홈 라우팅, 북마크 토글, 차고 분리)

---

## What's Next

**Immediate:** `/paul:plan` 실행 (Phase 8: Domain Separation, plan 08-01)

**After that:**
1. 08-01 APPLY: Entity + Repository 분리 + freezed 재생성
2. 08-02 PLAN/APPLY: Provider + UI 연결
3. Phase 9: Garage 3탭 UI + MyPage (분리된 도메인 기반)

---

## Key Decisions Made

| ID | Decision |
|----|----------|
| flutter-009 | 시승찾기 WebView 임베드 (url_launcher 대신) |
| (pending) | Vehicle/ConsultationCard 도메인 분리 결정 |
| (pending) | ICardRepository → IVehicleRepo + IBookmarkRepo + IGarageRepo 분리 |

---

## Key Files

| File | Purpose |
|------|---------|
| `.paul/STATE.md` | Live project state |
| `.paul/ROADMAP.md` | Phase overview (7/9 + Domain Separation 삽입) |
| `.paul/phases/08-domain-separation/` | Phase 8 디렉토리 (PLAN 미생성) |
| `.paul/phases/09-garage-mypage/08-01-PLAN.md` | 이전 Phase 8 계획 (참고용, 구조 변경 필요) |
| `flutter_app/lib/domain/entities/vehicle_card.dart` | 분리 대상 엔티티 |
| `flutter_app/lib/domain/repositories/i_card_repository.dart` | 분리 대상 인터페이스 |

---

## Git State

- Branch: `feat/flutter/domain-separation` (main 기반, 클린)
- `feat/flutter/screen-garage-mypage` — Phase 9 참고 코드 보존
- PR #20 (Phase 6-02), PR #21 (Phase 7) 머지 완료

---

## Resume Instructions

1. `/paul:resume` 실행
2. Phase 8 Domain Separation → /paul:plan 진행
3. CARL flutter 도메인 룰 확인 (듀얼 구현체, Clean Architecture 3계층)

---

*Handoff created: 2026-04-02*
