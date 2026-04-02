# AiCar 세션 작업 보고서

**날짜:** 2026-04-02
**브랜치:** `feat/flutter/design-system` → `main` (Squash Merge)
**PR:** [#16](https://github.com/move378/AiCar-AutoCommerce/pull/16)
**작업자:** PL (@move378) + Claude Code

---

## 완료된 Phase 요약

### Phase 1: Design Tokens
디자인 토큰을 `lib/core/theme/`에 코드화.

| 파일 | 내용 |
|------|------|
| `app_colors.dart` | 24 시맨틱 컬러 (Tailwind v4 Slate+Emerald) |
| `app_typography.dart` | 9단계 타입 스케일 (Pretendard, -2% letterSpacing) |
| `app_spacing.dart` | 4px 배수 8단계 스페이싱 |
| `app_shape.dart` | Border Radius (10/100/999px) + 컴포넌트 패딩 |
| `app_elevation.dart` | 라이트 모드 3단계 BoxShadow |
| `app_theme.dart` | Material 3 ThemeData 통합 |

### Phase 2: Common Widgets (9종)

| 위젯 | 파일 | 설명 |
|------|------|------|
| AiCarButton | `widgets/buttons/aicar_button.dart` | sm/lg, solid/outline, disabled, icons |
| AiCarInputField | `widgets/inputs/aicar_input_field.dart` | label, hint, error, prefix/suffix |
| AiCarChip | `widgets/chips/aicar_chip.dart` | selected/default 토글, AnimatedContainer |
| AiCarTabBar | `widgets/tab_bar/aicar_tab_bar.dart` | GNB 4탭, pill shape, Figma SVG 아이콘 |
| AiCarTabs | `widgets/tab_bar/aicar_tabs.dart` | 수평 콘텐츠 탭, underline 인디케이터 |
| AiCarHeader | `widgets/headers/aicar_header.dart` | 뒤로가기, 타이틀, 액션 버튼 |
| VehicleCard | `widgets/cards/vehicle_card.dart` | List/Card variant, 이미지+정보+북마크 |
| BookmarkButton | `widgets/buttons/bookmark_button.dart` | saved/unsaved 토글 |
| MapPin | `widgets/map/map_pin.dart` | Selected=말풍선+텍스트, Default=드롭핀, 브랜드별 색상 |

### Phase 3: App Shell & GNB

| 파일 | 내용 |
|------|------|
| `router/route_names.dart` | 라우트 이름 상수 |
| `router/app_router.dart` | GoRouter + StatefulShellRoute (탭 상태 보존) |
| `shell/main_shell.dart` | Scaffold + AiCarTabBar (GNB 4탭) |
| `pages/home/home_page.dart` | 홈 placeholder |
| `pages/test_drive/test_drive_page.dart` | 시승찾기 placeholder |
| `pages/ai_chat/ai_chat_page.dart` | 챗봇 placeholder |
| `pages/garage/garage_page.dart` | 차고 (auth guard + 톱니바퀴→마이) |
| `pages/my/my_page.dart` | 마이페이지 (auth guard) |

### Phase 4: Onboarding

| 파일 | 내용 |
|------|------|
| `pages/splash/splash_page.dart` | 로고 + 2초 → 차량조회 온보딩 |
| `pages/onboarding/vehicle_check_page.dart` | 4단계: 차량번호→소유자명→공공API 결과→등록완료 |
| `pages/auth/login_page.dart` | 카카오/Apple SNS 로그인 (차고/마이 진입 시) |
| `pages/auth/consent_page.dart` | 서비스 이용약관 동의 (필수2+선택1) |
| `pages/auth/marketing_consent_page.dart` | 마케팅 수신 동의 상세 |
| `core/providers/auth_provider.dart` | AuthNotifier (Riverpod Notifier, mock) |

---

## 주요 결정사항

| 결정 | 이유 |
|------|------|
| GNB 5탭 → 4탭 (마이 제거) | 차고 헤더 톱니바퀴에서 마이 진입. UX 간결화 |
| 온보딩: 차량조회 4단계 (SNS 로그인 없음) | Figma 기준. 로그인은 차고/마이 진입 시만 |
| abstract final class 토큰 패턴 | Dart 3, 순수 namespace, instantiation 방지 |
| Container+GestureDetector > Material 위젯 | Figma-exact 스타일링 제어 |
| StatefulShellRoute.indexedStack | 탭 간 상태 보존 (스크롤 위치 등) |
| Riverpod Notifier (v3) | StateNotifier deprecated. 최신 API 사용 |
| MapPin: 말풍선(selected) / 드롭핀(default) | Figma 2가지 형태 반영 |
| 브랜드별 색상 분기 (dark/light) | Benz=slate-800, BMW=white 자동 판단 |

---

## Figma 에셋 적용

| 에셋 | 경로 | 수량 |
|------|------|------|
| GNB SVG 아이콘 | `assets/icons/gnb/` | 10개 (5탭 × active/inactive) |
| 브랜드 로고 PNG | `assets/icons/brands/` | 2개 (benz, bmw) |
| 캐릭터 이미지 | `assets/images/character.png` | 1개 |
| Pretendard 폰트 | `assets/fonts/` | 4개 (Regular/Medium/SemiBold/Bold) |

---

## Git 히스토리

```
b0c4e78 Feat/flutter/design-system — 디자인 시스템 + 앱 골격 (Phase 1-4) (#16)
  ↑ Squash Merge (7 commits → 1)

원본 커밋:
  bb6c288 feat(flutter): 디자인 토큰 코드화
  c7775f6 docs: PLANNING.md 추가 및 PAUL 프로젝트 관리 초기화
  9644c79 feat(flutter): 공용 위젯 9종 구현
  0c5a45a fix(flutter): GNB TabBar pill shape, MapPin 재설계, Figma 에셋
  0604e9c feat(flutter): App Shell — GoRouter + MainShell(GNB) + 5탭 placeholder
  eaca246 feat(flutter): 온보딩 플로우 + GNB 4탭 + 차고/마이 auth guard
  9125501 refactor(flutter): main 구버전 survey-ui 잔여 파일 정리
```

---

## 추가 작업물

| 항목 | 설명 |
|------|------|
| Widget Catalog | `pages/_dev/widget_catalog_page.dart` — 9종 위젯 프리뷰 (임시, 삭제 예정) |
| PAUL 프로젝트 관리 | `.paul/` — PROJECT, ROADMAP, STATE, Phase 1-4 PLAN/SUMMARY |
| PLANNING.md | 프로젝트 전체 아키텍처/요구사항 정의서 (GNB 4탭 반영) |

---

## 다음 세션 가이드

```
git checkout -b feat/flutter/screen-chat main
/paul:resume → Phase 5: AI Chat
```

**Phase 5-8 남은 작업:**

| Phase | 내용 | 예상 |
|-------|------|------|
| 5 | AI Chat (챗봇 UI + 키워드 매칭 MVP) | Figma node 2306-1090 |
| 6 | AI Card (카드형 차량 추천 UI) | Figma node 2619-1838 |
| 7 | Home & Test Drive (네이티브 목록 + WebView) | Figma node 2450-2274, 2534-1829 |
| 8 | Garage & My Page (콘텐츠 구현) | Figma node 2534-1101, 2450-1735 |

**Milestone 진행률:** 50% (4/8 phases)

---

*Generated: 2026-04-02*
*Session duration: ~2 hours*
*Plans completed: 6 (PAUL loop)*
