# Milestones

Completed milestone log for this project.

| Milestone | Completed | Duration | Stats |
|-----------|-----------|----------|-------|
| v0.1 MVP Release | 2026-04-02 | 2 days | 9 phases, 15 plans |

---

## v0.1 MVP Release

**Completed:** 2026-04-02
**Duration:** 2 days (2026-04-01 ~ 2026-04-02)

### Stats

| Metric | Value |
|--------|-------|
| Phases | 9 |
| Plans | 15 |
| Total execution time | ~183min |
| Files changed | ~160 |

### Key Accomplishments

- 디자인 토큰 시스템 구축 (Tailwind v4 Slate+Emerald, Pretendard, 9단계 타입스케일)
- 공용 위젯 9종 완성 (Button, Input, Chip, TabBar, Tabs, Header, VehicleCard, Bookmark, MapPin)
- GNB 4탭 Shell + GoRouter StatefulShellRoute (탭 간 상태 보존)
- 온보딩 플로우 (Splash → 차량조회 4단계 → Home, Auth Guard)
- AI 챗봇 (키워드 매칭 MVP + 스트리밍 UI + 상담 히스토리)
- AI 카드형 차량 추천 (인라인 캐러셀 + 앞/뒷면 + Radar chart + Customize)
- 홈 차량 탐색 + 시승찾기 WebView (7개 브랜드)
- Vehicle/ConsultationCard 도메인 분리 + 차고 3탭 UI
- 마이페이지 (다크 프로필 카드 + 회원정보 수정 2탭 + 약관 3종 + 로그아웃/탈퇴)

### Key Decisions

| Decision | Phase | Date |
|----------|-------|------|
| 듀얼 백엔드 (Go + Supabase 백업), Repository 직접 통신 방식 B | Init | 2026-04-01 |
| GNB 4탭 (마이 제거 → 차고 헤더 톱니바퀴에서 push) | Phase 4 | 2026-04-02 |
| Riverpod Notifier v3, StatefulShellRoute.indexedStack | Phase 3-4 | 2026-04-02 |
| 카드 추천을 챗봇 내 인라인 캐러셀로 표시 | Phase 6 | 2026-04-02 |
| Vehicle/ConsultationCard 도메인 분리 (vehicleId 참조, nested 아님) | Phase 8 | 2026-04-02 |
| 마이페이지 3섹션 구조 (다크 프로필 카드 + 서비스 이용안내 + 앱 정보) | Phase 9 | 2026-04-02 |

---
