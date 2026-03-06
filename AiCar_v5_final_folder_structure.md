# AiCar 오토커머스 앱 — 폴더 구조 설계 (v5.1 최종)

> 3주 스프린트 최적화 + SWYP ADR 최종 결정 반영 + 검토 피드백 반영

---

## 변경 이력

| 버전 | 주요 변경 |
|------|----------|
| v1~v2 | 초기 설계 + 기능 커버리지 피드백 반영 |
| v3 | 기술 스택 관례 정합성 피드백 15개 반영 |
| v4 | 3주 스프린트 축소안 (Provider co-location, P0/P1 분류, Wire 분리, TF 4모듈) |
| v5 | ADR 반영 — JWT Stateless, domain/gateway, 토큰 관리 분리 |
| **v5.1** | **최종 검토 반영 — Crawler Worker 통합, handler/admin 리네이밍, i_token_storage 위치 이동, router 스켈레톤 추가** |

---

## v5 → v5.1 변경 추적표

| # | 영역 | 변경 | 근거 |
|---|------|------|------|
| 1 | Backend | `cmd/crawler/` 삭제 → `cmd/worker/`에 crawler job 통합 | ADR §7 |
| 2 | Backend | `domain/gateway/crawler_gateway.go` 삭제 | ADR §7 |
| 3 | Backend | `infra/external/crawler_client.go` 삭제 | ADR §7 |
| 4 | Backend | `handler/backoffice/` → `handler/admin/` 리네이밍 | 루트 `backoffice/`와 혼동 방지 |
| 5 | Backend | `common/` → `shared/` 리네이밍 | Go 커뮤니티 관례 정합 |
| 6 | Flutter | `domain/repositories/i_token_storage.dart` → `domain/services/` 이동 | Clean Architecture 레이어 정합 |
| 7 | Flutter | `presentation/router/` 스켈레톤 추가 | P0 auth flow 필수 의존 |
| 8 | Infra | `Dockerfile.crawler` 삭제 | `cmd/crawler/` 제거에 따른 정리 |

---

## v4 → v5 변경 추적표 (이전 버전 기록)

| # | 영역 | 변경 | ADR 근거 |
|---|------|------|---------|
| 1 | Backend | `domain/gateway/` 신규 (ai, social_auth, sms) | §4 |
| 2 | Backend | `redis/session_store.go` 삭제 (JWT Stateless) | §2 |
| 3 | Backend | `infra/external/kakao_client.go` 삭제 → `social_auth_gateway` 구현체로 통합 | §4 |
| 4 | Flutter | `i_session_repository.dart` → `i_token_storage.dart` 리네이밍 | §2, §3 |
| 5 | Flutter | auth usecase → `login_usecase.dart`, `logout_usecase.dart`, `refresh_token_usecase.dart` 분리 | §3 |
| 6 | 루트 | 브랜치 전략, Path-based CI, CODEOWNERS 문서화 | §1 |

---

## ADR §7: Crawler 통신 방식 — Worker 통합 (v5.1 신규)

### 결정

Crawler를 별도 바이너리(`cmd/crawler/`)로 분리하지 않고, **`cmd/worker/`에 crawler job으로 통합**한다.

### 맥락

Crawler는 외부 사이트(차량 시세, 딜러 정보 등)를 크롤링한 뒤 **내부 DB 데이터와 비교**해야 한다. 이 비교 로직이 핵심 요구사항이다.

### 검토한 대안

| 기준 | 방식 A: Gateway (별도 프로세스) | 방식 B: 공유 DB Worker (채택) |
|------|-------------------------------|-------------------------------|
| 내부 데이터 비교 | API 서버에 조회 요청 필요 | DB 직접 조회 가능 ✅ |
| 3주 스프린트 구현량 | gRPC/HTTP 서버 + 클라이언트 양쪽 | Worker job 하나만 구현 ✅ |
| 바이너리 수 | 3개 (api, worker, crawler) | 2개 (api, worker) ✅ |
| 운영 복잡도 | 서비스 3개 관리 | 서비스 2개 관리 ✅ |
| 실시간 크롤링 | 가능 | 배치/주기 실행 |

### 채택 근거

1. 차량 시세·딜러 정보는 **분 단위 갱신이 불필요** → 배치 처리로 충분
2. 내부 vehicle 데이터와 크롤링 데이터를 **같은 트랜잭션 안에서 비교**해야 하므로 DB 직접 접근이 유리
3. 이미 `cmd/worker/`가 존재하므로 **바이너리 추가 없이 job으로 등록** 가능
4. 3주 스프린트에서 **별도 서비스 간 통신 구현은 과도한 오버헤드**

### 결과

```
# 삭제
cmd/crawler/                          ← worker에 통합
domain/gateway/crawler_gateway.go     ← 불필요 (내부 처리)
infra/external/crawler_client.go      ← 불필요

# 유지
usecase/crawler/crawler_usecase.go    ← 크롤링 비즈니스 로직

# crawler_usecase 의존성 구조
type CrawlerUsecase struct {
    vehicleRepo  repository.VehicleRepository  // 내부 DB 직접 접근
    scraper      Scraper                       // 외부 사이트 스크래핑 인터페이스
}
```

`domain/gateway/`에는 **진짜 외부 시스템**(AI, 소셜 로그인, SMS)만 남는다.

---

## 1. Flutter 모바일 앱 (flutter_app/)

```
flutter_app/
├── pubspec.yaml
├── analysis_options.yaml
├── .env.example
│
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   ├── utils/
│   │   ├── extensions/
│   │   ├── errors/
│   │   └── providers/                     # 앱 전역 (2+ feature 공유만)
│   │       ├── auth_provider.dart
│   │       ├── dio_provider.dart
│   │       └── app_lifecycle_provider.dart
│   │
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── remote/
│   │   │   │   ├── auth/                          # P0 (파일 2개 이상 → 폴더)
│   │   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   │   └── social_auth_datasource.dart
│   │   │   │   ├── vehicle/                       # P0
│   │   │   │   │   ├── vehicle_remote_datasource.dart
│   │   │   │   │   └── vehicle_search_datasource.dart
│   │   │   │   ├── survey/                        # P0
│   │   │   │   │   └── survey_remote_datasource.dart
│   │   │   │   ├── card_datasource.dart           # P1 (파일 1개 → flat)
│   │   │   │   ├── garage_datasource.dart
│   │   │   │   ├── estimate_datasource.dart
│   │   │   │   └── promotion_datasource.dart
│   │   │   └── local/
│   │   │       ├── app_database.dart
│   │   │       ├── tables/
│   │   │       │   ├── survey_session_table.dart
│   │   │       │   ├── card_cache_table.dart
│   │   │       │   └── chat_history_table.dart
│   │   │       └── daos/
│   │   ├── dto/
│   │   │   ├── vehicle/
│   │   │   ├── user/
│   │   │   ├── card/
│   │   │   ├── survey/
│   │   │   ├── estimate/
│   │   │   └── promotion/
│   │   ├── mappers/
│   │   ├── repositories/
│   │   │   ├── auth/                              # P0
│   │   │   │   └── auth_repository_impl.dart
│   │   │   ├── vehicle/                           # P0
│   │   │   │   └── vehicle_repository_impl.dart
│   │   │   ├── survey/                            # P0
│   │   │   │   └── survey_repository_impl.dart
│   │   │   ├── card_repository_impl.dart          # P1 flat
│   │   │   ├── garage_repository_impl.dart
│   │   │   └── estimate_repository_impl.dart
│   │   └── services/
│   │       ├── biometric_service_impl.dart
│   │       ├── location_service_impl.dart
│   │       ├── notification_service_impl.dart
│   │       └── secure_storage_service_impl.dart   # i_token_storage 구현체
│   │
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   │   ├── i_auth_repository.dart
│   │   │   ├── i_vehicle_repository.dart
│   │   │   ├── i_survey_repository.dart
│   │   │   ├── i_card_repository.dart
│   │   │   ├── i_garage_repository.dart
│   │   │   ├── i_estimate_repository.dart
│   │   │   └── i_vehicle_link_repository.dart
│   │   ├── services/
│   │   │   ├── i_biometric_service.dart
│   │   │   ├── i_location_service.dart
│   │   │   ├── i_notification_service.dart
│   │   │   ├── i_secure_storage_service.dart
│   │   │   └── i_token_storage.dart               # ★ services/로 이동 (v5.1)
│   │   └── usecases/
│   │       ├── auth/                              # ★ 세분화
│   │       │   ├── login_usecase.dart
│   │       │   ├── logout_usecase.dart
│   │       │   └── refresh_token_usecase.dart
│   │       ├── survey/
│   │       ├── ai_chat/
│   │       ├── vehicle/
│   │       ├── card/
│   │       ├── garage_usecase.dart                # P1 flat
│   │       └── estimate_usecase.dart
│   │
│   └── presentation/
│       ├── router/                                # ★ 스켈레톤 추가 (v5.1)
│       │   ├── app_router.dart
│       │   └── route_names.dart
│       ├── widgets/
│       │   ├── buttons/
│       │   ├── cards/
│       │   ├── dialogs/
│       │   └── inputs/
│       └── pages/
│           ├── splash/
│           ├── auth/
│           │   ├── providers/
│           │   │   └── auth_form_provider.dart
│           │   ├── login_page.dart
│           │   ├── consent_page.dart
│           │   └── marketing_consent_page.dart
│           ├── home/
│           ├── ai_chat/
│           │   ├── providers/
│           │   │   ├── chat_provider.dart
│           │   │   └── streaming_provider.dart
│           │   ├── ai_chat_page.dart
│           │   └── widgets/
│           │       ├── chat_bubble.dart
│           │       ├── streaming_text.dart
│           │       ├── quick_action_bar.dart
│           │       └── message_input.dart
│           ├── survey/
│           │   ├── providers/
│           │   │   ├── survey_provider.dart
│           │   │   └── survey_step_provider.dart
│           │   ├── step1_page.dart
│           │   ├── step2_page.dart
│           │   ├── step3_page.dart
│           │   └── widgets/
│           ├── quick_question/
│           ├── vehicle_explore/
│           ├── ai_card/
│           │   ├── providers/
│           │   │   └── card_provider.dart
│           │   ├── card_list_page.dart
│           │   ├── card_front_widget.dart
│           │   ├── card_back_widget.dart
│           │   ├── card_customize_page.dart
│           │   └── widgets/
│           │       └── radar_chart.dart
│           ├── garage/
│           ├── estimate/
│           ├── promotion/
│           ├── qr/
│           ├── vehicle_link/
│           └── settings/
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
└── assets/
    ├── images/
    ├── icons/
    ├── fonts/
    └── lottie/
```

### Flutter 구조 규칙

| 규칙 | 설명 |
|------|------|
| P0/P1 폴더 기준 | 파일 2개 이상 → 폴더 / 파일 1개 → flat |
| Provider co-location | feature별 providers/ 폴더에 배치, 2+ feature 공유 시 core/providers/ |
| Token Storage 위치 | `domain/services/` (플랫폼 기능 접근이므로 repository가 아닌 service) |

---

## 2. Backend Go 서버 (backend/)

```
backend/
├── cmd/
│   ├── api/
│   │   ├── main.go
│   │   ├── wire.go
│   │   └── wire_gen.go
│   └── worker/                            # ★ crawler job 포함 (v5.1)
│       ├── main.go
│       ├── wire.go
│       └── wire_gen.go
│
├── internal/
│   ├── config/
│   │   └── config.go
│   │
│   ├── di/                                # Wire ProviderSet 정의
│   │   ├── repo_providers.go
│   │   ├── usecase_providers.go
│   │   ├── infra_providers.go
│   │   └── external_providers.go
│   │
│   ├── domain/
│   │   ├── entity/
│   │   │   ├── user.go
│   │   │   ├── vehicle.go
│   │   │   ├── card.go
│   │   │   ├── survey.go
│   │   │   ├── estimate.go
│   │   │   ├── promotion.go
│   │   │   ├── garage.go
│   │   │   ├── dealer.go
│   │   │   ├── consultation.go
│   │   │   ├── lead.go
│   │   │   └── crawl_job.go
│   │   ├── repository/                    # 내부 DB 접근만
│   │   │   ├── user_repository.go
│   │   │   ├── vehicle_repository.go
│   │   │   ├── card_repository.go
│   │   │   ├── survey_repository.go
│   │   │   ├── estimate_repository.go
│   │   │   ├── promotion_repository.go
│   │   │   ├── garage_repository.go
│   │   │   ├── dealer_repository.go
│   │   │   ├── consultation_repository.go
│   │   │   └── lead_repository.go
│   │   └── gateway/                       # 외부 시스템 통신만 (ADR §4)
│   │       ├── ai_gateway.go
│   │       ├── social_auth_gateway.go
│   │       └── sms_gateway.go            # ★ crawler_gateway 삭제 (v5.1)
│   │
│   ├── usecase/
│   │   ├── auth/
│   │   │   ├── auth_usecase.go
│   │   │   └── auth_usecase_test.go
│   │   ├── survey/
│   │   │   ├── survey_usecase.go
│   │   │   └── survey_usecase_test.go
│   │   ├── ai/
│   │   │   ├── recommendation_usecase.go
│   │   │   ├── recommendation_usecase_test.go
│   │   │   ├── chat_usecase.go
│   │   │   └── prompt_builder.go
│   │   ├── vehicle/
│   │   │   ├── vehicle_usecase.go
│   │   │   └── vehicle_usecase_test.go
│   │   ├── card/
│   │   │   ├── card_usecase.go
│   │   │   └── card_usecase_test.go
│   │   ├── garage/
│   │   │   └── garage_usecase.go
│   │   ├── estimate/
│   │   │   └── estimate_usecase.go
│   │   ├── promotion/
│   │   │   └── promotion_usecase.go
│   │   ├── consultation/
│   │   │   └── consultation_usecase.go
│   │   ├── data_import/
│   │   │   └── data_import_usecase.go
│   │   ├── crawler/                       # ★ 유지: worker에서 실행되는 job 로직
│   │   │   └── crawler_usecase.go
│   │   └── notification/
│   │       └── notification_usecase.go
│   │
│   ├── adapter/
│   │   ├── handler/
│   │   │   ├── app/
│   │   │   │   ├── auth_handler.go
│   │   │   │   ├── auth_handler_test.go
│   │   │   │   ├── survey_handler.go
│   │   │   │   ├── ai_handler.go
│   │   │   │   ├── vehicle_handler.go
│   │   │   │   ├── card_handler.go
│   │   │   │   ├── garage_handler.go
│   │   │   │   ├── estimate_handler.go
│   │   │   │   └── promotion_handler.go
│   │   │   └── admin/                     # ★ backoffice → admin 리네이밍 (v5.1)
│   │   │       ├── dashboard_handler.go
│   │   │       ├── vehicle_mgmt_handler.go
│   │   │       ├── promotion_mgmt_handler.go
│   │   │       ├── consultation_handler.go
│   │   │       ├── dealer_handler.go
│   │   │       ├── data_import_handler.go
│   │   │       ├── tax_settings_handler.go
│   │   │       └── messaging_handler.go
│   │   ├── middleware/
│   │   │   ├── auth_middleware.go
│   │   │   ├── cors_middleware.go
│   │   │   ├── logging_middleware.go
│   │   │   └── ratelimit_middleware.go
│   │   └── router/
│   │       └── router.go
│   │
│   ├── infra/
│   │   ├── persistence/
│   │   │   ├── postgres/
│   │   │   │   ├── user_repo.go
│   │   │   │   ├── user_repo_test.go
│   │   │   │   ├── vehicle_repo.go
│   │   │   │   ├── card_repo.go
│   │   │   │   ├── survey_repo.go
│   │   │   │   ├── estimate_repo.go
│   │   │   │   ├── promotion_repo.go
│   │   │   │   ├── garage_repo.go
│   │   │   │   ├── dealer_repo.go
│   │   │   │   ├── consultation_repo.go
│   │   │   │   └── lead_repo.go
│   │   │   └── redis/
│   │   │       └── cache.go
│   │   ├── external/                      # gateway 구현체 (외부 시스템만)
│   │   │   ├── ai_client.go               # → ai_gateway 구현
│   │   │   ├── social_auth_client.go      # → social_auth_gateway 구현 (카카오 포함)
│   │   │   └── sms_client.go              # → sms_gateway 구현
│   │   ├── scraper/                       # ★ 신규: 크롤링 전용 (v5.1)
│   │   │   ├── scraper.go                 # Scraper 인터페이스 구현
│   │   │   ├── encar_scraper.go           # 엔카 크롤링
│   │   │   └── kbcha_scraper.go           # KB차차차 크롤링
│   │   ├── messaging/
│   │   │   ├── producer.go
│   │   │   └── consumer.go
│   │   └── storage/
│   │       └── s3_storage.go
│   │
│   └── shared/                            # ★ common → shared 리네이밍 (v5.1)
│       ├── logger/
│       │   └── logger.go
│       ├── validator/
│       │   └── validator.go
│       ├── response/
│       │   └── response.go
│       └── errs/
│           └── errors.go
│
├── api/
│   ├── proto/
│   │   └── ai_service.proto
│   └── openapi/
│       └── swagger.yaml
│
├── migrations/
│   ├── 00001_enable_pgvector.sql
│   ├── 00002_create_users.sql
│   ├── 00003_create_vehicles.sql
│   ├── 00004_create_surveys.sql
│   ├── 00005_create_cards.sql
│   ├── 00006_create_estimates.sql
│   ├── 00007_create_promotions.sql
│   ├── 00008_create_garages.sql
│   ├── 00009_create_dealers.sql
│   ├── 00010_create_consultations.sql
│   └── 00011_create_leads.sql
│
├── test/
│   ├── integration/
│   └── e2e/
│
├── scripts/
│   └── seed.go
├── go.mod
├── go.sum
├── .env.example
├── Makefile                               # wire-all, wire-check 포함
└── README.md
```

### Backend 구조 규칙

| 규칙 | 설명 |
|------|------|
| DI 역할 분리 | `internal/di/` = Wire ProviderSet 정의, `cmd/*/wire.go` = Injector 정의 |
| gateway vs repository | gateway = 외부 시스템(AI, OAuth, SMS), repository = 내부 DB |
| crawler 위치 | `usecase/crawler/` 로직은 유지, `cmd/worker/`의 job으로 실행 |
| scraper 위치 | `infra/scraper/` — 외부 사이트별 스크래핑 구현체 (gateway가 아닌 infra) |

### Crawler 의존성 다이어그램

```
cmd/worker/main.go
  └── usecase/crawler/crawler_usecase.go
        ├── domain/repository/vehicle_repository.go   ← 내부 DB 직접 접근
        ├── domain/repository/...                     ← 기타 내부 데이터 비교
        └── infra/scraper/scraper.go                  ← 외부 사이트 크롤링
              ├── encar_scraper.go
              └── kbcha_scraper.go
```

---

## 3. 백오피스 Next.js (backoffice/)

```
backoffice/
├── package.json
├── next.config.js
├── tsconfig.json
├── .env.example
│
├── public/
│   └── assets/
│
├── src/
│   ├── middleware.ts
│   ├── app/
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   ├── loading.tsx
│   │   ├── error.tsx
│   │   ├── not-found.tsx
│   │   ├── (auth)/
│   │   │   ├── layout.tsx
│   │   │   └── login/
│   │   │       └── page.tsx
│   │   └── (main)/
│   │       ├── layout.tsx
│   │       ├── dashboard/
│   │       │   ├── page.tsx
│   │       │   └── loading.tsx
│   │       ├── vehicles/
│   │       │   ├── page.tsx
│   │       │   ├── loading.tsx
│   │       │   ├── error.tsx
│   │       │   ├── [id]/
│   │       │   │   └── page.tsx
│   │       │   └── crawl-review/
│   │       │       └── page.tsx
│   │       ├── promotions/
│   │       │   ├── page.tsx
│   │       │   └── [id]/
│   │       │       └── page.tsx
│   │       ├── tax-settings/
│   │       │   └── page.tsx
│   │       ├── consultations/
│   │       │   ├── page.tsx
│   │       │   ├── loading.tsx
│   │       │   └── [id]/
│   │       │       └── page.tsx
│   │       ├── dealers/
│   │       │   ├── page.tsx
│   │       │   └── [id]/
│   │       │       └── page.tsx
│   │       ├── messaging/
│   │       │   └── page.tsx
│   │       └── data-upload/
│   │           └── page.tsx
│   │
│   ├── components/
│   │   ├── ui/
│   │   ├── charts/
│   │   ├── layout/
│   │   └── forms/
│   ├── lib/
│   │   ├── api/
│   │   ├── utils/
│   │   └── constants/
│   ├── stores/                            # 상태 관리 필요 시 활성화
│   ├── types/
│   └── styles/
│
└── test/
```

---

## 4. 인프라 (infra/) — MVP 4모듈

```
infra/
├── docker/
│   ├── Dockerfile.api
│   ├── Dockerfile.worker                  # ★ crawler job 포함
│   └── Dockerfile.backoffice
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── modules/
│   │   ├── vpc/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── ecs/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── alarms.tf
│   │   ├── rds/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── alarms.tf
│   │   └── s3/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   └── envs/
│       ├── dev/
│       │   ├── main.tf
│       │   ├── terraform.tfvars
│       │   ├── backend.tf
│       │   └── versions.tf
│       └── prod/
│           ├── main.tf
│           ├── terraform.tfvars
│           ├── backend.tf
│           └── versions.tf
│
└── scripts/
    ├── deploy.sh
    └── rollback.sh
```

---

## 5. 프로젝트 루트

```
AiCar/
├── docker-compose.yml
├── flutter_app/
├── backend/
├── backoffice/
├── infra/
├── .github/
│   ├── workflows/
│   │   ├── backend-ci.yml             # wire-check + ERD 자동생성 + path-based trigger
│   │   ├── flutter-ci.yml             # path: flutter_app/**
│   │   ├── backoffice-ci.yml          # path: backoffice/**
│   │   └── deploy.yml
│   └── CODEOWNERS
├── docs/
│   ├── architecture.md
│   ├── api-spec.md
│   ├── erd.md
│   ├── survey-flow.md
│   ├── error-code-mapping.md          # ★ 신규: Flutter↔Backend 에러 코드 매핑
│   └── eks-migration.md
├── .gitignore
├── README.md
└── Makefile
```

---

## 브랜치 전략

```
main                    ← production 배포 기준
└── develop             ← 통합 브랜치
    ├── feat/flutter-*  ← prefix로 스택 구분
    ├── feat/backend-*
    ├── feat/bo-*       ← backoffice
    └── fix/backend-*
```

---

## CODEOWNERS

```
/infra/         @shawn
/backend/       @shawn @hyeran
/flutter_app/   @shawn
/backoffice/    @hyeran @yunseo
```

> **참고**: `/flutter_app/`이 단독 owner이므로, 리뷰 병목 발생 시 secondary reviewer 지정 또는 self-merge 정책 명시 필요

---

## 보완 예정 사항

### 개발 시작 전 결정

| 항목 | 현재 | 결정 시점 |
|------|------|----------|
| `data/services/` → `data/platform/` | 보류 | 구현 착수 시 |
| `backoffice stores/` 유지 vs 삭제 | 빈 폴더 유지 | 상태 관리 필요 시 |
| `quick_question/`, `qr/` 우선순위 | 미정 | 스프린트 플래닝 시 |
| `error-code-mapping.md` 작성 | 미작성 | **스프린트 시작 전 (30분)** |

### Nice-to-have

| 항목 | 비고 |
|------|------|
| `docs/eks-migration.md` → `docs/future/` | 향후 계획 격리 |
| `00012_create_indexes.sql` | 성능 이슈 발생 시 |

---

## Verification Plan

```bash
# 1. 전체 구조 검증
tree -I 'node_modules|.git'

# 2. Backend: gateway에 crawler 없음 확인
ls backend/internal/domain/gateway/
# 기대: ai_gateway.go  social_auth_gateway.go  sms_gateway.go (3개만)

# 3. Backend: cmd/crawler/ 부재 확인
test ! -d backend/cmd/crawler && echo "OK: crawler removed"

# 4. Backend: scraper 폴더 존재 확인
ls backend/internal/infra/scraper/

# 5. Backend: shared/ 리네이밍 확인
test -d backend/internal/shared && echo "OK: common → shared"

# 6. Backend: handler/admin/ 리네이밍 확인
test -d backend/internal/adapter/handler/admin && echo "OK: backoffice → admin"

# 7. Flutter: i_token_storage.dart가 services/에 위치 확인
ls flutter_app/lib/domain/services/i_token_storage.dart

# 8. Flutter: auth usecase 3파일 확인
ls flutter_app/lib/domain/usecases/auth/

# 9. Flutter: router 스켈레톤 확인
ls flutter_app/lib/presentation/router/

# 10. Go: Wire 동작 검증
cd backend && make wire-all && make wire-check
```

---

## ADR 전체 목록 (Quick Reference)

| § | 제목 | 핵심 결정 |
|---|------|----------|
| §1 | 브랜치 전략 | prefix 기반 구분 + Path-based CI |
| §2 | 인증 방식 | JWT Stateless (Redis session 삭제) |
| §3 | Auth Usecase 분리 | login / logout / refresh_token 3분할 |
| §4 | Gateway 패턴 | 외부 시스템 통신 인터페이스 분리 (repository와 구분) |
| §5 | DI 전략 | Google Wire 채택 (cmd/=injector, di/=provider) |
| §6 | 보류 사항 | 구현 착수 시 결정할 항목 목록 |
| **§7** | **Crawler 통합** | **별도 바이너리 불가 → Worker job으로 통합, DB 직접 접근** |
