# Roadmap: AiCar (에이카)

## Overview

수입차 AI 상담 및 Autocommerce 앱을 디자인 시스템 구축부터 시작하여, 공용 위젯 조립, GNB Shell, 각 화면 구현까지 Flutter MVP를 단계적으로 완성하는 여정. Phases 1-2는 `feat/flutter/design-system` 브랜치, Phases 3-8은 개별 `feat/flutter/screen-*` 브랜치.

## Current Milestone
**v0.1 MVP Release** (v0.1.0)
Status: In progress
Phases: 4 of 8 complete

## Phases

| Phase | Name | Plans | Status | Completed |
|-------|------|-------|--------|-----------|
| 1 | Design Tokens | 1 | Complete | 2026-04-01 |
| 2 | Common Widgets | 3 | Complete | 2026-04-01 |
| 3 | App Shell & GNB | 1 | Complete | 2026-04-01 |
| 4 | Onboarding | 1 | Complete | 2026-04-01 |
| 5 | AI Chat | 2 | Complete | 2026-04-02 |
| 6 | AI Card | 2 | Planning | - |
| 7 | Home & Test Drive | TBD | Not started | - |
| 8 | Garage & My Page | TBD | Not started | - |

## Phase Details

### Phase 1: Design Tokens
**Goal:** `lib/core/theme/` 에 모든 디자인 토큰 코드화 — AppColors, AppTypography, AppSpacing, AppElevation, AppShape, AppTheme
**Depends on:** Nothing (first phase)
**Research:** Unlikely (Figma 토큰 확정, PLANNING.md에 전부 정의됨)

**Scope:**
- 컬러 토큰 (시맨틱, 배경, 텍스트, 상태, GNB, 컴포넌트별)
- 타이포그래피 토큰 (Pretendard, 9단계 타입 스케일)
- 스페이싱 토큰 (4px 배수 체계)
- Shape 토큰 (border radius, padding)
- Elevation 토큰 (라이트 모드 3단계)
- AppTheme — ThemeData 통합

**Plans:**
- [x] 01-01: Design token files + AppTheme integration

### Phase 2: Common Widgets
**Goal:** `presentation/widgets/` 에 Figma 컴포넌트 기반 공용 위젯 전부 작성
**Depends on:** Phase 1 (토큰 사용)
**Research:** Unlikely (Figma 컴포넌트 확정)

**Scope:**
- AiCarButton (sm/lg, solid/outline, hover/disabled)
- AiCarInputField
- AiCarChip (selected/default)
- AiCarTabs
- AiCarTabBar (GNB 4탭: 홈/시승찾기/챗봇/차고)
- AiCarHeader
- VehicleCard (List/Card)
- BookmarkButton, MapPin

**Plans:**
- [x] 02-01: Core widgets (Button, InputField, Chip)
- [x] 02-02: Navigation widgets (TabBar, Tabs, Header)
- [x] 02-03: Content widgets (VehicleCard, BookmarkButton, MapPin)

### Phase 3: App Shell & GNB
**Goal:** GoRouter 설정 + GNB TabBar shell + 라우트 구조
**Depends on:** Phase 2 (AiCarTabBar 위젯)
**Research:** Unlikely (GoRouter 패턴 확립)

**Scope:**
- GoRouter configuration with auth guard
- MainShell with GNB
- Route definitions for all tabs

**Plans:**
- [x] 03-01: Router + MainShell + GNB integration

### Phase 4: Onboarding
**Goal:** Splash → 차량조회 온보딩(4단계) → Home + 차고/마이 auth guard
**Depends on:** Phase 3 (라우트 구조)
**Research:** Unlikely (공공API mock, 카카오 SDK 이미 설정)

**Scope:**
- Splash screen (앱 권한 획득)
- 차량조회 온보딩 (차량번호→소유자명→공공API 결과→등록완료, 스킵 가능)
- 차고/마이 auth guard (로그인→약관동의→복귀)
- 마이페이지 (차고 헤더 톱니바퀴에서 push)

**Plans:**
- [x] 04-01: Splash + VehicleCheck + Auth guard + My Page

### Phase 5: AI Chat
**Goal:** 챗봇 탭 — AI 상담 UI + 키워드 매칭 MVP
**Depends on:** Phase 3 (GNB Shell)
**Research:** Likely (키워드 매칭 로직 설계)

**Scope:**
- Chat page with message list
- Chat bubble, message input, quick action bar
- Streaming text display
- Chat provider (키워드 매칭 MVP)

**Plans:**
- [x] 05-01: Chat UI + 키워드 매칭 MVP (기존 위젯 재사용, ChatBubble 신규)
- [x] 05-02: 상담 히스토리 목록 (헤더 버튼 → 과거 상담 리스트)

### Phase 6: AI Card
**Goal:** 카드형 차량 추천 UI
**Depends on:** Phase 5 (챗봇에서 카드 추천 트리거)
**Research:** Unlikely (Figma 카드 디자인 확정)

**Scope:**
- Card list page
- Card front/back widgets
- Card customize page
- Radar chart widget

**Plans:**
- [ ] 06-01: Card 엔티티 + 앞면 위젯 + 카드 리스트 + 챗봇 연결
- [ ] 06-02: Card 뒷면 + Radar chart + Customize page

### Phase 7: Home & Test Drive
**Goal:** 홈 탭 (네이티브 목록 MVP) + 시승 탭 (WebView)
**Depends on:** Phase 3 (GNB Shell)
**Research:** Unlikely (WebView wrapper)

**Scope:**
- Home page with vehicle list (Go API 연동 준비)
- Test drive page (WebView to brand showroom)

**Plans:**
- [ ] 07-01: Home + TestDrive screens

### Phase 8: Garage & My Page
**Goal:** 가상차고 콘텐츠 + 마이페이지 콘텐츠
**Depends on:** Phase 6 (저장된 카드 데이터)
**Research:** Unlikely (CRUD 패턴)
**Note:** GNB는 4탭(마이 제거). 마이는 차고 헤더 톱니바퀴에서 push 진입.

**Scope:**
- Garage page with saved cards list
- My page with profile and settings

**Plans:**
- [ ] 08-01: Garage + MyPage screens

---
*Roadmap created: 2026-04-01*
*Last updated: 2026-04-02*
