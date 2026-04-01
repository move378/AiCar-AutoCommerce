# AiCar (에이카) — PLANNING.md

> 수입차 AI 상담 및 Autocommerce 앱
> 최종 업데이트: 2026-04-01
> PL: @move378 (임상훈)

---

## 1. 프로젝트 개요

### 미션

수입차 구매 과정의 정보 비대칭을 해소하는 AI 컨시어지 앱.
AI 상담 → 차량 추천 카드 → 견적/가상차고 → 시승/구매 연결.

### 기술 스택

| 컴포넌트 | 스택 | 경로 | 담당 |
|---------|------|------|------|
| Mobile App | Flutter (Riverpod, GoRouter, Dio, freezed) | `flutter_app/` | PL |
| Backend API | Go (Gin, GORM, Wire, JWT) | `backend/` | Backend 개발자 |
| Backoffice | Next.js (TypeScript) | `backoffice/` | MVP 범위 외 |
| Infrastructure | Docker, Terraform (AWS) | `infra/` | MVP 범위 외 |
| 차량 탐색 웹 | SvelteKit (post-MVP) | 미생성 | post-MVP |

### MVP 범위

- **포함**: Flutter + Backend
- **제외**: Backoffice, Infrastructure (별도 담당)
- **스프린트**: 3주, 분할 없이 즉시 전체 병렬 진행

---

## 2. 아키텍처

### 2-1. 모노레포 구조 (ADR §1)

```
AiCar/
├── flutter_app/          # Flutter 모바일 앱
├── backend/              # Go API + Worker
├── backoffice/           # Next.js (MVP 외)
├── infra/                # Docker, Terraform (MVP 외)
├── docker-compose.yml
├── Makefile
└── .github/workflows/    # Path-based CI
```

### 2-2. 듀얼 백엔드 전략

| 항목 | 결정 |
|------|------|
| **기본 백엔드** | Go API (우선 개발) |
| **백업 백엔드** | Supabase (Go 디버깅 장기화 시 빠른 전환) |
| **스위칭 방식** | `dart-define` 환경변수 + `backendTypeProvider` (Riverpod) |
| **아키텍처** | 방식 B — Repository 구현체가 직접 통신 (datasource 레이어 제거) |
| **역할 분담** | 팀원이 Go 구현체, PL이 Supabase 전환 시 투입 |

```
[Go API 경로]
Provider → GoAuthRepositoryImpl → Dio → Go 서버 → AuthMapper.toEntity()

[Supabase 경로]
Provider → SupabaseAuthRepositoryImpl → Supabase SDK → AuthMapper.toEntity()
```

### 2-3. 인증 — JWT Stateless (ADR §2, §3)

- 서버 세션 없음. Access Token (15~30분) + Refresh Token (7일, Redis 저장 — `rt:{userID}`)
- 로그아웃 시 Access Token **블랙리스트** (Redis `bl:{token}`, TTL = 토큰 잔여 수명)
- 소셜 로그인 외부 API 응답 **Redis 캐싱** (SocialCacheRepository)
- 온보딩: SNS 로그인 (카카오/구글) + 공공API 차량소유 조회 (소유자명 + 차량번호)
- 디바이스별 토큰 관리 (DeviceRepository)

**Backend Auth 인터페이스 (실제 구현 — `feat/backend/auth`):**

| 인터페이스 | 저장소 | 역할 |
|-----------|--------|------|
| `UserRepository` | PostgreSQL | 사용자 CRUD |
| `SocialProviderRepository` | PostgreSQL | 소셜 로그인 provider 연동 |
| `SocialCacheRepository` | Redis | 소셜 API 응답 캐싱 |
| `DeviceRepository` | PostgreSQL | 디바이스 관리 |
| `TokenCacheRepository` | Redis | Refresh Token 저장 + Access Token 블랙리스트 |
| `TxManager` | PostgreSQL | 트랜잭션 관리 |

**Backend Auth Usecase (실제 구현):**

| Usecase | 역할 |
|---------|------|
| `AuthUsecase` | 로그인/로그아웃/토큰 갱신 |
| `UserUsecase` | 프로필 조회 |
| `SocialUsecase` | 소셜 로그인 공통 로직 |
| `KakaoUsecase` | 카카오 소셜 로그인 |
| `GoogleUsecase` | 구글 소셜 로그인 |

**Flutter 측:**
- `ITokenStorage` (domain/services/) → `SecureStorageServiceImpl` (data/services/)
- 토큰 갱신/검증은 usecase 레이어 (`usecases/auth/`)
- Dio interceptor → 자동 토큰 주입 + 401 → refresh 플로우

### 2-4. Backend — Clean Architecture (ADR §4, §7)

```
cmd/api/          → HTTP 서버
cmd/worker/       → Background jobs (crawler 포함)
internal/
  domain/
    entity/       → 비즈니스 엔티티
    repository/   → 내부 DB 인터페이스
    gateway/      → 외부 시스템 인터페이스 (AI, OAuth, SMS)
  usecase/        → 비즈니스 로직
  adapter/
    handler/app/  → 모바일 핸들러
    handler/admin/→ 백오피스 핸들러
    middleware/   → Auth, CORS, logging, rate-limit
  infra/
    persistence/  → PostgreSQL + Redis
    external/     → Gateway 구현체
    scraper/      → 크롤링 (encar, kbcha)
  di/             → Wire ProviderSet
  shared/         → Logger, validator, response, errors
```

**핵심 구분**: `repository/` = 내부 DB, `gateway/` = 외부 시스템. Crawler는 Worker job으로 통합 (ADR §7).

### 2-5. 배포

| 항목 | 결정 |
|------|------|
| 환경 | AWS EC2 단일 인스턴스 |
| 방식 | Docker Compose (api + worker + postgres + redis) |
| 데이터 시딩 | Crawler Worker가 서버에서 차량 데이터 수집 → DB 저장 |

---

## 3. Flutter 아키텍처

### 3-1. Clean Architecture 3계층

```
presentation → domain → data (역방향 import 금지)
```

### 3-2. 폴더 구조 v6 (듀얼 백엔드 반영)

```
flutter_app/lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/              # API 엔드포인트 등
│   ├── theme/                  # 디자인 토큰 (AppColors, AppTypography, AppSpacing)
│   ├── utils/
│   ├── extensions/
│   ├── errors/                 # Sealed exception hierarchy
│   └── providers/              # 앱 전역 (2+ feature 공유만)
│       ├── auth_provider.dart
│       ├── dio_provider.dart
│       ├── supabase_provider.dart
│       ├── backend_type_provider.dart    # dart-define → BackendType enum
│       ├── repository_providers.dart     # backendType 분기 → 구현체 선택
│       └── app_lifecycle_provider.dart
│
├── domain/
│   ├── entities/               # freezed 비즈니스 모델
│   ├── repositories/           # 추상 인터페이스 (I 접두사)
│   │   ├── i_auth_repository.dart
│   │   ├── i_vehicle_repository.dart
│   │   ├── i_survey_repository.dart
│   │   ├── i_card_repository.dart
│   │   ├── i_garage_repository.dart
│   │   ├── i_estimate_repository.dart
│   │   ├── i_ai_chat_repository.dart
│   │   └── i_vehicle_link_repository.dart
│   ├── services/               # 플랫폼 서비스 인터페이스
│   │   ├── i_token_storage.dart
│   │   ├── i_biometric_service.dart
│   │   ├── i_location_service.dart
│   │   └── i_notification_service.dart
│   └── usecases/
│       ├── auth/
│       │   ├── login_usecase.dart
│       │   ├── logout_usecase.dart
│       │   └── refresh_token_usecase.dart
│       ├── ai_chat/
│       ├── vehicle/
│       ├── card/
│       ├── survey/
│       ├── garage_usecase.dart
│       └── estimate_usecase.dart
│
├── data/
│   ├── datasources/
│   │   └── local/              # Drift SQLite 오프라인 캐시 (백엔드 무관)
│   │       ├── app_database.dart
│   │       ├── tables/
│   │       └── daos/
│   ├── repositories/
│   │   ├── go_api/             # Go API 구현체 (Dio 직접 통신)
│   │   │   ├── auth_repository_impl.dart
│   │   │   ├── vehicle_repository_impl.dart
│   │   │   ├── survey_repository_impl.dart
│   │   │   ├── card_repository_impl.dart
│   │   │   ├── garage_repository_impl.dart
│   │   │   ├── estimate_repository_impl.dart
│   │   │   └── ai_chat_repository_impl.dart
│   │   └── supabase/           # Supabase 구현체 (스텁, UnimplementedError)
│   │       ├── auth_repository_impl.dart
│   │       ├── vehicle_repository_impl.dart
│   │       ├── survey_repository_impl.dart
│   │       ├── card_repository_impl.dart
│   │       ├── garage_repository_impl.dart
│   │       ├── estimate_repository_impl.dart
│   │       └── ai_chat_repository_impl.dart
│   ├── dto/                    # 양쪽 공유 DTO (freezed)
│   ├── mappers/                # DTO ↔ Entity 변환
│   └── services/               # 플랫폼 서비스 구현체
│       ├── secure_storage_service_impl.dart
│       ├── biometric_service_impl.dart
│       ├── location_service_impl.dart
│       └── notification_service_impl.dart
│
└── presentation/
    ├── router/
    │   ├── app_router.dart     # GoRouter + auth guard
    │   └── route_names.dart
    ├── widgets/                # 공용 위젯 (design-system 브랜치)
    │   ├── buttons/
    │   ├── cards/
    │   ├── chips/
    │   ├── inputs/
    │   ├── dialogs/
    │   └── tab_bar/
    └── pages/
        ├── splash/
        ├── onboarding/         # SNS 로그인 + 차량소유 조회
        ├── home/               # GNB Shell + WebView (차량탐색)
        ├── test_drive/         # WebView (외부 브랜드 전시장)
        ├── ai_chat/            # AI 상담 (키워드 매칭 MVP)
        │   ├── providers/
        │   ├── widgets/
        │   └── ai_chat_page.dart
        ├── ai_card/            # 차량 추천 카드
        │   ├── providers/
        │   ├── widgets/
        │   └── card_list_page.dart
        ├── garage/             # 가상차고 (저장된 카드 목록)
        ├── my/                 # 마이페이지
        └── settings/
```

### 3-3. Provider 배치 규칙 (ADR §5)

| 조건 | 위치 |
|------|------|
| 2+ feature 공유 | `core/providers/` |
| 단일 feature 전용 | `pages/{feature}/providers/` |
| page 하나에서만 사용 | 해당 page 파일 내부 |

### 3-4. P0/P1 폴더 규칙

- 파일 2개 이상 → 폴더
- 파일 1개 → flat

---

## 4. 사용자 여정 & GNB

### 4-1. GNB 탭 구성 (Figma 확정)

```
┌─────┬──────┬──────┬──────┬──────┐
│ 홈  │ 시승 │ 챗봇 │ 차고 │ 마이 │
└─────┴──────┴──────┴──────┴──────┘
```

| 탭 | 구현 | 설명 |
|----|------|------|
| **홈** | WebView placeholder (MVP: 네이티브 목록) | 차량 탐색 + 견적 + 프로모션. SvelteKit 전환 대비 |
| **시승** | WebView | 외부 브랜드 전시장 페이지로 리다이렉션 |
| **챗봇** | 네이티브 | AI 상담 → 카드형 차량 추천 |
| **차고** | 네이티브 | 저장된 카드 목록 + 상담 기록 |
| **마이** | 네이티브 | 마이페이지 |

### 4-2. 핵심 플로우

```
온보딩 (SNS 로그인 + 차량소유 조회)
  → GNB 홈
       │
       ├── [챗봇 탭] AI 상담
       │     └── 키워드 매칭 → 카드형 차량 추천 (최대 20종)
       │           ├── 카드 클릭 → "견적확인" → 홈(WebView) 이동
       │           └── 카드 클릭 → "가상차고 저장" → 차고 탭에 카드 저장
       │
       ├── [차고 탭] 저장된 카드 목록
       │     └── 카드 하단 "에이카 상담 기록 >" → 상담 기록 화면
       │
       ├── [홈 탭] 차량 탐색 / 견적 / 프로모션
       │     └── MVP: Go API 연동 네이티브 목록
       │     └── Post-MVP: SvelteKit WebView (SEO 최적화)
       │
       └── [시승 탭] 외부 브랜드 전시장 리다이렉션
```

### 4-3. AI Chat MVP 전략

| 항목 | 결정 |
|------|------|
| 방식 | 키워드 추출 + 사전 답변 10가지 시나리오 |
| 데이터 | 목업 데이터 |
| 인터페이스 | `IAiChatRepository` → Go 구현체에서 키워드 매칭 |
| Post-MVP | Python RAG 서비스 → 엔드포인트 교체만으로 전환 |

### 4-4. 차량 탐색 WebView 전환 계획

| 단계 | 구현 |
|------|------|
| **MVP** | Go API 연동 네이티브 목록 (WebView 교체 가능 구조) |
| **Post-MVP** | SvelteKit으로 차량 탐색 웹 구축 + SEO 최적화 |
| **전환** | Flutter 홈 탭을 WebView로 교체 |

---

## 5. 디자인 시스템

### 5-1. Figma 파일 매핑

**파일 ID**: `o7szshz4qyL7DUEulcPNFq`

| 프레임 | node-id | 용도 |
|--------|---------|------|
| 디자인 시스템 (폰트/컬러) | 2405-629 | 토큰 추출 |
| Components | 2432-555 | 공용 컴포넌트 |
| 캐릭터 이미지 | 2395-656 | 캐릭터 에셋 |
| UI 전체 | 2306-1089 | 전체 화면 레퍼런스 |
| UI 홈 (WebView) | 2450-2274 | 홈 탭 |
| UI 시승 (WebView) | 2534-1829 | 시승 탭 |
| UI 챗봇 | 2306-1090 | 챗봇 탭 |
| UI 차고 | 2534-1101 | 차고 탭 |
| UI 마이 | 2450-1735 | 마이 탭 |
| 카드 UI | 2619-1838 | 차량 추천 카드 |
| 온보딩 (참고, 미확정) | 2413-826 | 참고용 이전 작업물 |

### 5-2. Figma 컴포넌트 → Flutter 위젯 매핑

| Figma 컴포넌트 | node-id | Flutter 위젯 |
|---------------|---------|-------------|
| Button (sm/lg, solid/outline/hover/disabled) | 2432-571 ~ 2432-599 | `AiCarButton` |
| Inputfield | — | `AiCarInputField` |
| Chip (selected/default) | 2451-1172 ~ | `AiCarChip` |
| Tabs | 2451-1136 ~ | `AiCarTabs` |
| Tab Bar (홈/시승/챗봇/차고/마이) | 2598-1904 ~ 2598-2008 | `AiCarTabBar` |
| card (List/Card) | 2450-3665, 2450-3684 | `VehicleCard` |
| 헤더 | — | `AiCarHeader` |
| Bookmark_light | — | `BookmarkButton` |
| Map pin | 2534-2574 ~ | `MapPin` |

### 5-3. 컬러 토큰

> Tailwind CSS v4 기반 — Slate + Emerald 팔레트

#### 시맨틱 컬러

| 역할 | Hex | 토큰 |
|------|-----|------|
| Primary | `#1E293B` | slate-800 |
| Secondary (Accent) | `#10B981` | emerald-500 |
| Secondary Hover | `#059669` | emerald-600 |

#### 배경

| 역할 | Hex | 토큰 |
|------|-----|------|
| Background | `#FFFFFF` | white |
| Surface | `#F8FAFC` | slate-50 |
| Card 배경 | `#64748B` | slate-500 |

#### 텍스트

| 역할 | Hex | 토큰 |
|------|-----|------|
| Text Primary | `#0F172A` | slate-900 |
| Text Secondary | `#64748B` | slate-500 |
| Text Tertiary | `#94A3B8` | slate-400 |
| Text Disabled | `#CBD5E1` | slate-300 |
| Text on Dark | `#FFFFFF` | white |
| Text Accent | `#059669` | emerald-600 |

#### 상태

| 역할 | Hex | 토큰 |
|------|-----|------|
| Success | `#10B981` | emerald-500 |
| Error | `#EF4444` | red-500 |
| Warning | `#F59E0B` | amber-500 |
| Info | `#3B82F6` | blue-500 |

#### GNB

| 역할 | Hex | 토큰 |
|------|-----|------|
| GNB 배경 | `#FFFFFF` | white |
| 탭 활성 | `#0F172A` | slate-900 |
| 탭 비활성 | `#94A3B8` | slate-400 |

#### 컴포넌트별

| 컴포넌트 | 상태 | Hex | 토큰 |
|---------|------|-----|------|
| Button Solid | default | `#1E293B` | slate-800 |
| Button Solid | disabled | `#F1F5F9` | slate-100 |
| Button Outline | default | `#FFFFFF` | white |
| Chip | selected | `#334155` | slate-700 |
| Chip | unselected | `#FFFFFF` | white |

### 5-4. 타이포그래피 토큰

| 속성 | 값 |
|-----|-----|
| Font Family | `Pretendard` |
| Fallback | `-apple-system, BlinkMacSystemFont, system-ui, sans-serif` |
| Weights | 400 (Normal), 500 (Medium), 600 (SemiBold), 700 (Bold) |
| Letter Spacing | `-2%` (전역) |

#### 타입 스케일

| Style | Size | Line Height | Weight | 시맨틱 |
|-------|------|-------------|--------|--------|
| 4xl | 36px | 44px | 700 Bold | **H1** |
| 3xl | 30px | 38px | 700 Bold | **H2** |
| 2xl | 24px | 32px | 600 SemiBold | **H3** |
| xl | 20px | 30px | 600 SemiBold | **H4 / Subtitle** |
| lg | 18px | 28px | 400 Normal | **Body Large** |
| md | 16px | 24px | 400 Normal | **Body Medium** |
| sm | 14px | 20px | 400 Normal | **Body Small** |
| xs | 12px | 16px | 400 Normal | **Caption** |
| 2xs | 11px | 14px | 500 Medium | **Overline** |

### 5-5. Shape 토큰

#### Border Radius

| 용도 | 값 |
|-----|-----|
| Button, Card, Input Field | `10px` |
| Chip (pill) | `100px` |
| Avatar | `999px` (circle) |

#### Padding

| 용도 | H (px) | V (px) |
|-----|--------|--------|
| Button (sm/lg) | 16 | 10 |
| Chip | 10 | 6 |
| Tab Bar | 16 | 0 |

### 5-6. 스페이싱 (4px 배수)

| 토큰 | 값 | 용도 |
|------|---|------|
| space-1 | 4px | 아이콘-텍스트 간격 |
| space-2 | 8px | 칩 간 간격, 인라인 |
| space-3 | 12px | 리스트 아이템 |
| space-4 | 16px | 카드 패딩, 섹션 간격 |
| space-5 | 20px | 섹션 간 간격 |
| space-6 | 24px | 큰 섹션 간격 |
| space-8 | 32px | 페이지 섹션 구분 |
| space-10 | 40px | 주요 블록 간격 |

### 5-7. Elevation (라이트 모드 전용)

| 레벨 | Shadow | 용도 |
|------|--------|------|
| 0 | none | 기본 상태 |
| 1 | `0 1px 3px rgba(15,23,42,0.08)` | 카드, 드롭다운 |
| 2 | `0 4px 12px rgba(15,23,42,0.12)` | 모달, FAB |
| 3 | `0 8px 24px rgba(15,23,42,0.16)` | 바텀시트, 오버레이 |

### 5-8. 개발 워크플로우

```
[1] design-system 브랜치
    → 디자인 토큰 코드화 (lib/core/theme/)
    → 공용 위젯 전부 작성 (presentation/widgets/)
    → main 머지

[2] feat/flutter/screen-* 브랜치들
    → Figma node-id로 화면 구조 분석 (Figma MCP)
    → 공용 위젯 조립하여 화면 구현
    → 각 화면별 PR → main 머지
```

---

## 6. 차량 데이터 파이프라인

### 6-1. 개요 (ADR §7)

| 항목 | 결정 |
|------|------|
| 데이터 소스 | 브랜드 사이트 직접 크롤링 (벤츠 등) + 엔카/KB차차차 |
| 구현 위치 | `usecase/crawler/` (로직) + `infra/scraper/` (크롤링) |
| 실행 방식 | `cmd/worker/` job으로 배치 실행 |
| DB 접근 | Vehicle Repository 직접 접근 (같은 트랜잭션) |
| Gateway 아님 | 내부 데이터 비교가 핵심 → Worker 통합 |
| 현재 진행 상태 | `feat/collector/vehicle` 브랜치 — 벤츠 크롤링 완료, 파싱 준비 중 |

### 6-2. 차량 DB 스키마 (정규화 7테이블)

```
vehicles_brands          ← 브랜드 (벤츠, BMW 등)
  └── vehicles_models    ← 모델 (E-Class, 3시리즈 등)
       └── vehicles_trims     ← 트림 (E300, 320d 등) + 바디타입, 제원, 가격
            ├── vehicles_ice_specs    ← 내연기관 제원 (배기량, 연비 등)
            ├── vehicles_ev_specs     ← 전기차 제원 (배터리, 주행거리 등)
            └── vehicles_trim_options ← 트림별 옵션 (가격, 기본/선택)
                 └── vehicles_options ← 옵션 마스터 (이름, 카테고리)
```

### 6-3. 의존성 구조

```
cmd/worker/main.go
  └── usecase/crawler/crawler_usecase.go
        ├── domain/repository/vehicle_repository.go   ← 내부 DB (7테이블)
        └── infra/scraper/scraper.go                  ← 외부 크롤링
              ├── encar_scraper.go                    (스켈레톤)
              └── kbcha_scraper.go                    (스켈레톤)
```

### 6-4. 구현 현황 (`feat/collector/vehicle`)

| 항목 | 상태 |
|------|------|
| DB 마이그레이션 (00005~00011) | ✅ 완료 |
| 벤츠 브랜드 사이트 크롤링 | ✅ 완료 |
| 크롤링 데이터 파싱 | 🔧 진행 중 |
| encar/kbcha scraper | 📋 스켈레톤 |
| crawler_usecase | 📋 스켈레톤 |

### 6-5. ADR 대비 실제 변경점

| ADR 계획 | 실제 구현 | 비고 |
|---------|---------|------|
| Refresh Token → PostgreSQL | Refresh Token → **Redis** | 성능 우선 판단으로 변경 |
| 단일 vehicles 테이블 | **정규화 7테이블** (brands/models/trims/specs/options) | 트림/제원 세분화 |
| KEMCO API 연동 | 브랜드 사이트 **직접 크롤링** 우선 | KEMCO는 추후 추가 가능 |
| container/ 없음 | `container/container.go` 수동 DI | Wire 대신 수동 DI 사용 중 |

---

## 7. 브랜치 & 커밋 컨벤션

### 브랜치 네이밍

```
<type>/<stack>/<description>
```

| 요소 | 값 |
|------|---|
| type | feat, fix, hotfix, chore, docs, refactor, test |
| stack | backend, flutter, bo, infra |
| description | kebab-case |

### 커밋

**Conventional Commits**: `<type>(<scope>): <description>`

| Type | 설명 |
|------|------|
| feat | 새 기능 |
| fix | 버그 수정 |
| refactor | 구조 변경 |
| docs | 문서 |
| style | 포맷팅 |
| test | 테스트 |
| chore | 빌드, 설정 |
| ci | CI/CD |

### Merge 전략

- **Squash Merge only** — PR 제목이 main 커밋 메시지
- 머지 후 원격 feature 브랜치 자동 삭제
- `pull.rebase true` 필수 설정

---

## 8. ADR 요약

| § | 제목 | 핵심 결정 |
|---|------|----------|
| §1 | 모노레포 | 4컴포넌트 단일 레포 + Path-based CI |
| §2 | JWT Stateless | Redis session 삭제, Refresh Token → Redis (실제 구현에서 변경) |
| §3 | Auth 분리 | login / logout / refresh_token usecase 3분할 |
| §4 | Gateway 패턴 | 외부 시스템 → gateway/, 내부 DB → repository/ |
| §5 | Provider 규칙 | 3줄 규칙 (core/feature/inline) + P0/P1 폴더 승격 |
| §6 | 보류 사항 | data/services → data/platform 리네이밍 등 구현 시 결정 |
| §7 | Crawler 통합 | Worker job으로 통합, DB 직접 접근 |
| **§8** | **듀얼 백엔드** | **Go 우선 + Supabase 백업, Repository 직접 통신 (방식 B)** |
| **§9** | **GNB 재정의** | **홈(WV)/시승(WV)/챗봇/차고/마이 — Figma 기준** |
| **§10** | **AI Chat MVP** | **키워드 매칭 10 시나리오, Python RAG 전환 대비** |
| **§11** | **디자인 토큰** | **Tailwind v4 Slate+Emerald, Pretendard, 라이트 모드** |

---

## 9. CODEOWNERS

```
/infra/          @move378
/backend/        @move378 @ranio10 @Avoler0
/flutter_app/    @move378 @ranio10 @Avoler0
/backoffice/     @move378 @ranio10 @Avoler0
/.github/        @move378
```

---

## 10. 참조 문서

| 문서 | 위치 | 설명 |
|------|------|------|
| CLAUDE.md | 루트 | Claude Code 아키텍처 가이드 |
| swyp-architecture-decisions.md | 루트 | ADR §1-§7 원본 |
| AiCar_v5_final_folder_structure.md | 루트 | 폴더 구조 설계 v5.1 |
| CONTRIBUTING.md | 루트 | 브랜치/커밋/PR 가이드 |
