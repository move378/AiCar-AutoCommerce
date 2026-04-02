# AiCar 세션 작업 보고서 — Phase 8: Domain Separation

**날짜:** 2026-04-02
**브랜치:** `feat/flutter/domain-separation` (PR #24) + `feat/flutter/screen-garage`
**작업자:** PL (@move378) + Claude Code

---

## 세션 요약

Phase 8 Domain Separation 전체 완료 (3 plans). 도메인 레이어 분리 → Provider 연결 → 차고 3탭 UI까지 한 세션에 수행.

| 구분 | 값 |
|------|-----|
| 실행 시간 | ~45min (3 plans) |
| Plans 완료 | 14/14 (누적) |
| Phase 진행 | 8/9 complete |
| Milestone 진행률 | 89% |
| PR | #24 (08-01+08-02 squash merged) |
| UAT 통과 | T1-T6 전체 Pass |

---

## 완료된 Plans

### 08-01: Entity + Repository 분리 (~15min)

**핵심:** VehicleCard 엔티티 + ICardRepository 를 도메인 목적에 맞게 분할.

| Before | After |
|--------|-------|
| `VehicleCard` (혼합) | `Vehicle` (차량 스펙) + `ConsultationCard` (AI 상담 결과) |
| `ICardRepository` (혼합) | `IVehicleRepository` + `IBookmarkRepository` + `IGarageRepository` |
| go_api `CardRepositoryImpl` 1개 | go_api 3개 + supabase 3개 (듀얼 구현체) |
| - | Drift `BookmarkTable` (schemaVersion 3, 영속 저장) |

**핵심 결정:**
- ConsultationCard는 `vehicleId: String`으로 Vehicle 참조 (nested 아님 → 정규화)
- Bookmark은 Drift 영속 저장 (인메모리 거부 — 앱 재시작 시 유실 방지)
- Garage JSON 마이그레이션: fromJson 실패 시 깨진 레코드 조용히 삭제

### 08-02: Provider 분리 + VehicleDetailPage + 버그 수정 (~12min)

**핵심:** Presentation 레이어를 새 도메인 구조에 연결.

| 항목 | 내용 |
|------|------|
| Repository Provider 공용화 | `core/providers/repository_providers.dart` (vehicle/bookmark/garage) |
| bookmarkProvider | `BookmarkNotifier` — Drift 영속 + optimistic update |
| VehicleDetailPage | 차량 상세 (스펙 4개 + 가격 + 북마크 토글) |
| 홈 라우팅 수정 | 차량 탭 → VehicleDetailPage (이전: AI카드 스와이프 페이지) |
| _extractQuery 버그 수정 | AI 응답 → 사용자 입력 기반 `_findUserQuery` |

### 08-03: 차고 3탭 UI (~18min)

**핵심:** 차고 탭 placeholder → Figma 기반 3탭 풀 구현.

| 탭 | 구현 내용 |
|----|----------|
| 가상 차고 | ConsultationCard 다크 캐러셀 (PageView + dot indicator + 가격 3칸) + 전시장 목업 3개 (저장 + 스낵바) |
| 북마크 | 카테고리 칩 (전체/일반/전기차) + 2열 그리드 + 북마크 토글 |
| 최근 본 | recentlyViewedProvider (인메모리) + 카테고리 칩 + 수직 리스트 + 북마크 |

**UAT에서 발견/수정된 이슈:**
1. Riverpod build-time mutation → `ConsumerStatefulWidget` + `Future()` 전환
2. 가상차고 데이터 미갱신 → 탭 진입 시 `refresh()` 호출
3. 홈 VehicleCard 북마크 미연결 → `isBookmarked` + `onBookmarkTap` 연결
4. 전시장 저장 UX → 카드 전체 탭으로 저장 + 스낵바

---

## 주요 결정사항 (Phase 8)

| 결정 | 이유 | CARL ID |
|------|------|---------|
| Vehicle=스펙, ConsultationCard=상담 (vehicleId 참조) | 도메인 관심사 분리. nested 시 데이터 중복 | flutter-008 |
| Bookmark Drift 영속 | 인메모리는 앱 재시작 시 유실 — MVP라도 허용 불가 | flutter-008 |
| Repository Provider → core/providers/ | 3+ feature에서 공유 (P0/P1 규칙) | - |
| _findUserQuery (사용자 입력 기반) | AI 응답에서 키워드 추출 시 우선순위 충돌 | - |
| 최근 본: 인메모리 MVP | Drift 영속은 Post-MVP에서 추가 | - |
| Phase 8에 차고 3탭 흡수, Phase 9 → MyPage만 | ROADMAP 재구성 | - |

---

## 파일 변경 요약

### 생성 (21개)
```
domain/entities/vehicle.dart (+freezed, +g)
domain/entities/consultation_card.dart (+freezed, +g)
domain/repositories/i_vehicle_repository.dart
domain/repositories/i_bookmark_repository.dart
data/repositories/go_api/{vehicle,bookmark,garage}_repository_impl.dart
data/repositories/supabase/{vehicle,bookmark,garage}_repository_impl.dart
data/datasources/local/tables/bookmark_table.dart
core/providers/repository_providers.dart
presentation/pages/home/providers/bookmark_provider.dart
presentation/pages/home/vehicle_detail_page.dart
presentation/pages/garage/providers/{garage,recently_viewed}_provider.dart
presentation/pages/garage/widgets/{virtual_garage_tab,consultation_card_carousel,
  dealership_card,bookmark_tab,recently_viewed_tab}.dart
```

### 수정 (11개)
```
data/datasources/local/app_database.dart (schemaVersion 3)
presentation/pages/garage/garage_page.dart (3탭 리라이트)
presentation/pages/home/home_page.dart (북마크 연결)
presentation/pages/ai_card/providers/card_provider.dart (repo 공용화)
presentation/pages/home/providers/home_provider.dart (repo 공용화)
presentation/pages/ai_chat/{ai_chat_page,chat_history_page}.dart (_findUserQuery)
presentation/pages/ai_chat/widgets/inline_card_carousel.dart (repo 공용화)
presentation/pages/ai_card/{card_front,card_back}_widget.dart (Vehicle 타입)
presentation/pages/ai_card/widgets/radar_chart.dart (Vehicle import)
presentation/router/{app_router,route_names}.dart (VehicleDetail 라우트)
```

### 삭제 (8개)
```
domain/entities/vehicle_card.dart (+freezed, +g)
domain/repositories/i_card_repository.dart
data/repositories/go_api/card_repository_impl.dart
data/repositories/supabase/card_repository_impl.dart
data/repositories/{card,garage,estimate}_repository_impl.dart (빈 placeholder)
```

---

## PAUL 워크플로우 메트릭

| Phase | Plans | 시간 | 평균 |
|-------|-------|------|------|
| 01-design-tokens | 1 | ~10min | ~10min |
| 02-common-widgets | 3 | ~24min | ~8min |
| 03-app-shell | 1 | ~10min | ~10min |
| 04-onboarding | 1 | ~12min | ~12min |
| 05-ai-chat | 2 | ~25min | ~12min |
| 06-ai-card | 2 | ~22min | ~11min |
| 07-home-test-drive | 1 | ~15min | ~15min |
| **08-domain-separation** | **3** | **~45min** | **~15min** |
| **Total** | **14** | **~163min** | **~12min** |

---

## 다음 세션 가이드

```
git checkout -b feat/flutter/screen-mypage main
/paul:resume → Phase 9: My Page
```

**Phase 9 남은 작업:**

| Phase | 내용 | Plans |
|-------|------|-------|
| 9 | My Page (프로필 + 설정) | ~1 plan |

**Milestone 완료까지:** 1 phase (MyPage), ~1 plan 예상

---

*Generated: 2026-04-02*
*Session duration: ~1.5 hours (Phase 8 전체)*
*Plans completed: 3 (이번 세션), 14 (누적)*
