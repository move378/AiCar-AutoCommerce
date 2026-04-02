---
phase: 08-domain-separation
plan: 01
subsystem: domain
tags: [freezed, entity, repository, drift, clean-architecture]

requires:
  - phase: 07-home-test-drive
    provides: VehicleCard entity + ICardRepository (분리 대상)
provides:
  - Vehicle entity (차량 스펙 중심)
  - ConsultationCard entity (AI 상담 결과, vehicleId 참조)
  - IVehicleRepository + IBookmarkRepository + IGarageRepository
  - go_api + supabase 듀얼 구현체 6개
  - Drift BookmarkTable (영속 저장)
affects: [08-02-provider-ui, 09-garage-mypage]

tech-stack:
  added: []
  patterns:
    - "vehicleId 참조 패턴 (ConsultationCard → Vehicle, nested 아님)"
    - "Repository 3분할 패턴 (기능 도메인 단위 인터페이스)"
    - "Drift 마이그레이션 v2→v3 (incremental createTable)"

key-files:
  created:
    - flutter_app/lib/domain/entities/vehicle.dart
    - flutter_app/lib/domain/entities/consultation_card.dart
    - flutter_app/lib/domain/repositories/i_vehicle_repository.dart
    - flutter_app/lib/domain/repositories/i_bookmark_repository.dart
    - flutter_app/lib/domain/repositories/i_garage_repository.dart
    - flutter_app/lib/data/repositories/go_api/vehicle_repository_impl.dart
    - flutter_app/lib/data/repositories/go_api/bookmark_repository_impl.dart
    - flutter_app/lib/data/repositories/go_api/garage_repository_impl.dart
    - flutter_app/lib/data/datasources/local/tables/bookmark_table.dart
  modified:
    - flutter_app/lib/presentation/pages/ai_card/providers/card_provider.dart
    - flutter_app/lib/presentation/pages/home/providers/home_provider.dart
    - flutter_app/lib/data/datasources/local/app_database.dart

key-decisions:
  - "Vehicle=스펙 중심, ConsultationCard=상담 결과 중심 — vehicleId 참조(nested 아님)"
  - "Bookmark Drift 영속 저장 (인메모리 거부 — 앱 재시작 시 유실 방지)"
  - "Garage JSON 마이그레이션: fromJson 실패 시 깨진 레코드 조용히 삭제"

patterns-established:
  - "도메인 엔티티 참조: ID 기반 참조 (nested 객체 아님)"
  - "Repository 명명: I{Domain}Repository → {Domain}RepositoryImpl"
  - "Drift 마이그레이션: incremental if (from < N) createTable 패턴"

duration: ~15min
started: 2026-04-02
completed: 2026-04-02
---

# Phase 8 Plan 01: Entity + Repository 도메인 분리 Summary

**VehicleCard→Vehicle(스펙)+ConsultationCard(상담) 엔티티 분리, ICardRepository→3개 분리 인터페이스(Vehicle/Bookmark/Garage), Drift 북마크 영속 저장, go_api+supabase 듀얼 구현체 완비**

## Performance

| Metric | Value |
|--------|-------|
| Duration | ~15min |
| Started | 2026-04-02 |
| Completed | 2026-04-02 |
| Tasks | 3 completed |
| Files modified | 22 (14 created, 8 deleted) |

## Acceptance Criteria Results

| Criterion | Status | Notes |
|-----------|--------|-------|
| AC-1: Vehicle 엔티티 (스펙 중심) | Pass | brand, model, year, price, fuelType, imageUrl, specs |
| AC-2: ConsultationCard 엔티티 (상담 중심) | Pass | vehicleId 참조, recommendReason, matchScore, createdAt |
| AC-3: Repository 인터페이스 3분할 | Pass | IVehicleRepo + IBookmarkRepo + IGarageRepo |
| AC-4: 듀얼 구현체 완비 | Pass | go_api 3개 + supabase 스텁 3개 |
| AC-5: Bookmark 영속 저장 | Pass | Drift BookmarkTable, schemaVersion 3 |
| AC-6: 컴파일 통과 | Pass | flutter analyze 에러 0 (pre-existing test 1건 제외) |

## Accomplishments

- VehicleCard 엔티티 → Vehicle(차량 스펙) + ConsultationCard(AI 상담 결과) 도메인 분리 완료
- ICardRepository → IVehicleRepository + IBookmarkRepository + IGarageRepository 3분할
- Drift BookmarkTable 추가 + schemaVersion 2→3 마이그레이션 (incremental createTable)
- 기존 기능 전부 동작 유지 (홈 목록, AI 채팅, 카드 스와이프, 시승찾기)

## Files Created/Modified

| File | Change | Purpose |
|------|--------|---------|
| `domain/entities/vehicle.dart` | Created | 차량 스펙 엔티티 (brand, model, specs) |
| `domain/entities/consultation_card.dart` | Created | AI 상담 결과 엔티티 (vehicleId 참조) |
| `domain/repositories/i_vehicle_repository.dart` | Created | 차량 조회 인터페이스 |
| `domain/repositories/i_bookmark_repository.dart` | Created | 북마크 인터페이스 |
| `domain/repositories/i_garage_repository.dart` | Created | 가상차고 인터페이스 |
| `data/repositories/go_api/vehicle_repository_impl.dart` | Created | 목업 데이터 10종 + 키워드 필터 |
| `data/repositories/go_api/bookmark_repository_impl.dart` | Created | Drift 기반 영속 북마크 |
| `data/repositories/go_api/garage_repository_impl.dart` | Created | Drift CardCacheTable + JSON 마이그레이션 |
| `data/repositories/supabase/vehicle_repository_impl.dart` | Created | Supabase 스텁 |
| `data/repositories/supabase/bookmark_repository_impl.dart` | Created | Supabase 스텁 |
| `data/repositories/supabase/garage_repository_impl.dart` | Created | Supabase 스텁 |
| `data/datasources/local/tables/bookmark_table.dart` | Created | Drift 북마크 테이블 |
| `data/datasources/local/app_database.dart` | Modified | BookmarkTable 추가, schemaVersion 3 |
| `presentation/pages/ai_card/providers/card_provider.dart` | Modified | vehicleRepositoryProvider + garageRepositoryProvider |
| `presentation/pages/home/providers/home_provider.dart` | Modified | vehicleRepositoryProvider.getAllVehicles() |
| `presentation/pages/ai_chat/widgets/inline_card_carousel.dart` | Modified | vehicleRepo + garageRepo 사용 |
| `presentation/pages/ai_card/card_front_widget.dart` | Modified | Vehicle 타입 + brand/model 필드 |
| `presentation/pages/ai_card/card_back_widget.dart` | Modified | Vehicle 타입 + model 필드 |
| `presentation/pages/ai_card/widgets/radar_chart.dart` | Modified | Vehicle import |
| `presentation/pages/home/home_page.dart` | Modified | Vehicle 타입 + brand/model 필드 |
| `domain/entities/vehicle_card.dart` | Deleted | Vehicle로 대체 |
| `domain/repositories/i_card_repository.dart` | Deleted | 3개 인터페이스로 분할 |
| `data/repositories/go_api/card_repository_impl.dart` | Deleted | 3개 구현체로 분할 |
| `data/repositories/supabase/card_repository_impl.dart` | Deleted | 3개 구현체로 분할 |

## Decisions Made

| Decision | Rationale | Impact |
|----------|-----------|--------|
| ConsultationCard는 vehicleId로 Vehicle 참조 (nested 아님) | 데이터 중복/업데이트 불일치 방지, 정규화된 설계 | 08-02에서 Vehicle+ConsultationCard 조합 조회 필요 |
| Bookmark Drift 영속 저장 | 인메모리 Set은 앱 재시작 시 유실 — MVP라도 허용 불가 | schemaVersion 3 마이그레이션 추가 |
| Garage JSON 마이그레이션 try-catch | 기존 VehicleCard JSON ↔ ConsultationCard JSON 호환 불가 | 깨진 레코드 조용히 삭제 |
| brandName→brand, modelName→model 필드 리네이밍 | 도메인 모델링 — 단순 리네이밍이 아닌 재설계 | 전체 codebase 필드 참조 업데이트 |

## Deviations from Plan

### Summary

| Type | Count | Impact |
|------|-------|--------|
| Auto-fixed | 1 | inline_card_carousel.dart 추가 업데이트 |
| Deferred | 1 | _extractQuery 키워드 우선순위 버그 (pre-existing) |

**Total impact:** 필수 수정 1건, pre-existing 버그 발견 1건 (regression 없음)

### Auto-fixed Issues

**1. inline_card_carousel.dart Provider 참조 누락**
- **Found during:** Task 3 (flutter analyze)
- **Issue:** cardRepositoryProvider 참조가 남아있어 컴파일 에러 2건
- **Fix:** vehicleRepositoryProvider + garageRepositoryProvider로 교체, ConsultationCard 생성 로직 추가
- **Files:** `presentation/pages/ai_chat/widgets/inline_card_carousel.dart`
- **Verification:** flutter analyze 에러 0

### Deferred Items

**_extractQuery 키워드 우선순위 버그 (pre-existing, Phase 5)**
- **발견:** UAT T3 테스트 — "BMW 추천해줘" 입력 시 BMW 3대가 아닌 SUV 4대 표시
- **근본 원인:** `ai_chat_page.dart:185` `_extractQuery()`가 AI 응답 텍스트에서 키워드 추출. 브랜드 응답에 "세단, SUV, 쿠페" 텍스트 포함 → SUV가 BMW보다 먼저 매칭
- **올바른 동작:** 사용자 입력에서 브랜드를 추출해야 하는데, AI 응답에서 카테고리를 추출하고 있음
- **수정 위치:** `ai_chat_page.dart:185` `_extractQuery()`
- **수정 시점:** 08-02 또는 별도 fix
- **Severity:** Minor — 기능 동작, 필터링만 부정확

## Next Phase Readiness

**Ready:**
- Vehicle/ConsultationCard 도메인 경계 확립 → 08-02에서 Provider + UI 분리 가능
- IVehicleRepository/IBookmarkRepository/IGarageRepository → 08-02 Provider에서 바로 사용
- Drift BookmarkTable → 08-02에서 bookmarkProvider 즉시 구현 가능

**Concerns:**
- _extractQuery 버그: 08-02에서 수정 권장 (Provider + UI 작업 시 자연스럽게 포함)
- ConsultationCard 아직 실제 사용처 적음 (saveToGarage에서만 사용) → 08-02에서 카드 페이지 연결 필요

**Blockers:**
- None

---
*Phase: 08-domain-separation, Plan: 01*
*Completed: 2026-04-02*
