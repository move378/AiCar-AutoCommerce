---
phase: 08-domain-separation
plan: 03
subsystem: presentation
tags: [garage, tabs, carousel, bookmark, dealership, recently-viewed]

requires:
  - phase: 08-domain-separation/01
    provides: Vehicle/ConsultationCard entity, IVehicleRepo/IBookmarkRepo/IGarageRepo
  - phase: 08-domain-separation/02
    provides: vehicleRepositoryProvider, bookmarkProvider, garageRepositoryProvider, VehicleDetailPage
provides:
  - 차고 3탭 UI (가상차고/북마크/최근본)
  - garageProvider (ConsultationCard 관리)
  - recentlyViewedProvider (인메모리 최근 본 추적)
  - 전시장 목업 + 저장/스낵바
  - 홈 VehicleCard 북마크 버튼 연결
affects: [09-mypage]

tech-stack:
  added: []
  patterns:
    - "TabBar 3탭 구조 (DefaultTabController)"
    - "ConsumerStatefulWidget + Future() for post-build provider mutation"
    - "전시장 저장: 인메모리 Set (MVP)"

key-files:
  created:
    - flutter_app/lib/presentation/pages/garage/providers/garage_provider.dart
    - flutter_app/lib/presentation/pages/garage/providers/recently_viewed_provider.dart
    - flutter_app/lib/presentation/pages/garage/widgets/virtual_garage_tab.dart
    - flutter_app/lib/presentation/pages/garage/widgets/consultation_card_carousel.dart
    - flutter_app/lib/presentation/pages/garage/widgets/dealership_card.dart
    - flutter_app/lib/presentation/pages/garage/widgets/bookmark_tab.dart
    - flutter_app/lib/presentation/pages/garage/widgets/recently_viewed_tab.dart
  modified:
    - flutter_app/lib/presentation/pages/garage/garage_page.dart
    - flutter_app/lib/presentation/pages/home/vehicle_detail_page.dart
    - flutter_app/lib/presentation/pages/home/home_page.dart

key-decisions:
  - "VehicleDetailPage ConsumerWidget → ConsumerStatefulWidget (Riverpod build-time mutation 방지)"
  - "최근 본 차량: 인메모리 (MVP), Post-MVP에서 Drift 영속"
  - "전시장 저장: 인메모리 Set (MVP), 카드 전체 탭으로 저장"

duration: ~18min
started: 2026-04-02
completed: 2026-04-02
---

# Phase 8 Plan 03: 차고 3탭 UI Summary

**차고 탭 3탭 풀 구현 — 가상차고(ConsultationCard 캐러셀+전시장 목업) + 북마크(2열 그리드) + 최근본(수직 리스트) + 홈 북마크 버튼 연결**

## Performance

| Metric | Value |
|--------|-------|
| Duration | ~18min |
| Started | 2026-04-02 |
| Completed | 2026-04-02 |
| Tasks | 3 completed |
| Files modified | 10 (7 created, 3 updated) |

## Acceptance Criteria Results

| Criterion | Status | Notes |
|-----------|--------|-------|
| AC-1: 3탭 구조 + 탭 전환 | Pass | DefaultTabController + 가상차고/북마크/최근본 |
| AC-2: 가상차고 ConsultationCard 캐러셀 | Pass | 다크 카드 + 가격 3칸 + 전시장 목업 |
| AC-3: 북마크 탭 2열 그리드 | Pass | 카테고리 칩 + bookmarkProvider 연동 |
| AC-4: 최근 본 탭 리스트 | Pass | recentlyViewedProvider + VehicleDetailPage 연동 |
| AC-5: 컴파일 통과 | Pass | flutter analyze 에러 0 |

## Accomplishments

- 차고 탭 placeholder → 3탭 풀 구현 (가상차고/북마크/최근본)
- ConsultationCard 다크 캐러셀 (PageView + dot indicator + 가격 3칸 + 상담 기록 링크)
- 전시장 목업 3개 (BMW/벤츠/아우디) + 저장 기능 + 스낵바
- 북마크 탭 (카테고리 칩 + 2열 그리드 + 토글)
- 최근 본 탭 (인메모리 추적 + 카테고리 칩 + 수직 리스트)
- 홈 VehicleCard에 북마크 버튼 연결 (isBookmarked + onBookmarkTap)

## Deviations from Plan

### Summary

| Type | Count | Impact |
|------|-------|--------|
| Auto-fixed | 4 | Riverpod + 디자인 토큰 + 홈 북마크 |

### Auto-fixed Issues

**1. Riverpod build-time mutation**
- **Issue:** VehicleDetailPage.build()에서 addViewed() 호출 → 빨간 에러 화면
- **Fix:** ConsumerWidget → ConsumerStatefulWidget + initState() + Future()

**2. 디자인 토큰 불일치**
- **Issue:** AppShape.radiusSm, AppElevation.shadow1 미존재
- **Fix:** radiusSm → radiusMd, shadow1 → elevation1

**3. 가상차고 데이터 미갱신**
- **Issue:** garageProvider가 첫 빌드 시만 로드, 탭 재진입 시 갱신 안 됨
- **Fix:** VirtualGarageTab.initState()에서 Future(() => refresh())

**4. 홈 북마크 버튼 미연결**
- **Issue:** VehicleCard에 isBookmarked/onBookmarkTap 미전달
- **Fix:** home_page.dart에 bookmarkProvider 연동

## Next Phase Readiness

**Ready:**
- Phase 8 Domain Separation 완료 → Phase 9 MyPage 진행 가능
- 모든 도메인 Provider 구축 완료 (vehicle, bookmark, garage, recentlyViewed)

**Concerns:**
- None

**Blockers:**
- None

---
*Phase: 08-domain-separation, Plan: 03*
*Completed: 2026-04-02*
