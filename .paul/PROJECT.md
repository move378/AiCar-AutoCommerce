# AiCar (에이카)

## What This Is

수입차 AI 상담 및 Autocommerce 앱. 수입차 구매 과정에서 AI 상담을 통해 차량을 추천받고, 카드형 UI로 비교하며, 견적 확인과 가상차고 저장, 시승 예약까지 하나의 앱에서 처리할 수 있는 모바일 서비스.

## Core Value

수입차 구매 과정의 정보 비대칭을 해소하는 AI 컨시어지 앱.

## Current State

| Attribute | Value |
|-----------|-------|
| Type | Application |
| Version | 0.1.0 |
| Status | MVP Complete (Flutter UI) |
| Last Updated | 2026-04-02 |

## Requirements

### Core Features

- AI 상담 (키워드 매칭 MVP → Python RAG 전환 대비)
- 카드형 차량 추천 (최대 20종, 견적확인/가상차고 저장)
- 가상차고 (저장된 카드 목록 + 상담 기록)
- 온보딩 (차량번호/소유자명으로 공공API 차량조회, 스킵 가능)
- GNB Shell (홈/시승찾기/챗봇/차고 — 4탭)
- 마이페이지 (차고 헤더 톱니바퀴에서 진입, 로그인 필요)

### Validated (Shipped)
- [x] 디자인 토큰 (컬러/타이포/스페이싱/Shape/Elevation) — Phase 1
- [x] 공용 위젯 (Button, Input, Chip, TabBar, Tabs, Header, VehicleCard, Bookmark, MapPin) — Phase 2
- [x] App Shell & GNB (GoRouter + StatefulShellRoute 4탭) — Phase 3
- [x] 온보딩 (Splash + 차량조회 + Auth Guard) — Phase 4
- [x] AI Chat UI + 키워드 매칭 MVP + 상담 히스토리 — Phase 5
- [x] AI Card 카드형 차량 추천 (인라인 캐러셀 + 뒷면 + Radar chart) — Phase 6
- [x] 홈 차량 탐색 + 시승 WebView — Phase 7
- [x] 도메인 분리 (Vehicle/ConsultationCard/Bookmark/Garage) — Phase 8
- [x] 마이페이지 (프로필 수정 + 약관 + 로그아웃) — Phase 9

### Active (In Progress)
- [ ] Backend Auth (JWT Stateless, 카카오/구글 소셜 로그인) — `feat/backend/auth` 머지 완료
- [ ] 차량 데이터 파이프라인 (벤츠 크롤링 완료, 파싱 진행 중) — `feat/collector/vehicle`

### Planned (Next)
- [ ] Go API 연동 (차량 목록, AI Chat, 견적)
- [ ] Flutter ↔ Backend 통합 테스트

### Out of Scope
- Backoffice (Next.js) — 별도 담당
- Infrastructure (Terraform) — 별도 담당
- SvelteKit 차량 탐색 웹 — Post-MVP
- Python RAG 서비스 — Post-MVP

## Constraints

### Technical Constraints
- 듀얼 백엔드 전략: Go API 우선, Supabase 백업 (dart-define + backendTypeProvider 스위칭)
- Repository 직접 통신 방식 B (datasource 레이어 제거)
- Clean Architecture 3계층 (presentation → domain → data, 역방향 import 금지)
- JWT Stateless: Access Token (15~30분) + Refresh Token (7일, Redis)
- Flutter: Riverpod, GoRouter, Dio, freezed
- Backend: Go (Gin, GORM, Wire, JWT)

### Business Constraints
- MVP 스프린트: 3주
- 팀 구성: PL(Flutter/디자인) + Backend 개발자
- Squash Merge only, PR 제목이 main 커밋 메시지

## Key Decisions

| Decision | Rationale | Date | Status |
|----------|-----------|------|--------|
| 듀얼 백엔드 (Go + Supabase 백업) | Go 디버깅 장기화 시 빠른 전환 보장 | 2026-04-01 | Active |
| Repository 직접 통신 (방식 B) | datasource 레이어 제거로 복잡도 감소 | 2026-04-01 | Active |
| JWT Stateless + Redis | 서버 세션 없이 성능 우선 | 2026-04-01 | Active |
| AI Chat MVP 키워드 매칭 | 10 시나리오 목업, Python RAG 전환 대비 | 2026-04-01 | Active |
| GNB 4탭 (홈/시승찾기/챗봇/차고) | 마이 제거 → 차고 헤더 톱니바퀴에서 진입 | 2026-04-02 | Active |
| Tailwind v4 Slate+Emerald 디자인 토큰 | Pretendard 폰트, 라이트 모드 전용 | 2026-04-01 | Active |
| 차량 DB 정규화 7테이블 | 트림/제원 세분화 필요 | 2026-04-01 | Active |
| StatefulShellRoute.indexedStack | 탭 간 상태 보존 (GoRouter) | 2026-04-02 | Active |
| 온보딩: 차량조회 4단계 (SNS 로그인 없음) | Figma 기준, 로그인은 차고/마이 진입 시만 | 2026-04-02 | Active |
| Riverpod Notifier (v3) | StateNotifier deprecated | 2026-04-02 | Active |

## Success Metrics

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| MVP Flutter UI 완성 | 9 Phase 전체 구현 | 15 plans / ~183min | ✅ Complete |
| AI 상담 → 카드 추천 플로우 | 키워드 매칭 10 시나리오 동작 | UI 완성, mock 데이터 | ⏳ Backend 연동 대기 |
| 듀얼 백엔드 스위칭 | dart-define으로 Go/Supabase 전환 가능 | 인터페이스 준비 완료 | ⏳ Backend 연동 대기 |

## Tech Stack / Tools

| Layer | Technology | Notes |
|-------|------------|-------|
| Mobile App | Flutter (Riverpod, GoRouter, Dio, freezed) | `flutter_app/` |
| Backend API | Go (Gin, GORM, Wire, JWT) | `backend/` |
| Database | PostgreSQL + Redis | Redis: 토큰, 캐싱 |
| Design | Figma | 파일 ID: `o7szshz4qyL7DUEulcPNFq` |
| Font | Pretendard | Letter Spacing -2% |
| Color System | Tailwind v4 Slate + Emerald | 라이트 모드 전용 |
| Deployment | AWS EC2 + Docker Compose | api + worker + postgres + redis |

---
*Created: 2026-04-01*
*Last updated: 2026-04-02 after v0.1 MVP Release*
