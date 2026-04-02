# AiCar 개발 워크플로우 가이드

> Seed → PAUL → CARL 통합 워크플로우 + Figma→Flutter 구현 방법론
> 최종 업데이트: 2026-04-02 (Phase 8 Domain Separation 반영)

---

## 1. 도구 스택 개요

| 도구 | 역할 | 사용 시점 |
|------|------|----------|
| **SEED** | 프로젝트 기획/인큐베이션 | 프로젝트 시작 전, PLANNING.md 생성 |
| **PAUL** | 프로젝트 관리 (Plan→Apply→Unify 루프) | 개발 전체 라이프사이클 |
| **CARL** | 도메인 규칙 + 결정사항 추적 | 모든 세션에서 자동 주입 |
| **Figma MCP** | 디자인 컴포넌트 분석/에셋 추출 | 위젯/화면 구현 시 |
| **Dart MCP** | Flutter 분석/포맷/테스트 | 코드 검증 시 |

---

## 2. SEED → PAUL 연결

### SEED 단계 (기획)
```
/seed → 프로젝트 유형 선택 → 대화형 기획 → PLANNING.md 졸업
```
- PLANNING.md가 프로젝트 전체의 **단일 진실 소스**
- 아키텍처, 디자인 토큰, Figma 매핑, ADR 모두 포함

### PAUL 초기화
```
/paul:init → PLANNING.md 감지 → 자동 import → .paul/ 구조 생성
```
생성되는 파일:
- `.paul/PROJECT.md` — 비즈니스 컨텍스트, 요구사항
- `.paul/ROADMAP.md` — Phase 구조, 계획
- `.paul/STATE.md` — 현재 위치, 루프 상태, 세션 연속성
- `.paul/paul.json` — 외부 시스템용 매니페스트
- `.paul/phases/` — Phase별 PLAN/SUMMARY 파일

---

## 3. PAUL 루프 (핵심 워크플로우)

```
PLAN ──▶ APPLY ──▶ UNIFY
  ◉        ○        ○     [계획 중]
  ✓        ◉        ○     [실행 중]
  ✓        ✓        ◉     [정리 중]
  ✓        ✓        ✓     [완료 → 다음 PLAN]
```

### 3.1 PLAN 단계
```
/paul:plan
```
- Phase 범위 분석 → scope 분류 (quick-fix / standard / complex)
- PLAN.md 생성: objective, acceptance criteria, tasks, boundaries
- 각 task에 files + action + verify + done 필수
- **2-3 tasks per plan** 권장 (컨텍스트 50% 이내)

### 3.2 APPLY 단계
```
/paul:apply
```
- 각 task별 Execute/Qualify (E/Q) 루프:
  1. **Execute** — 코드 작성
  2. **Report** — DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED
  3. **Qualify** — 파일 재읽기 + verify 실행 + AC 비교 → PASS/GAP/DRIFT
- checkpoint 처리 (human-verify, decision, human-action)

### 3.3 UNIFY 단계
```
/paul:unify
```
- Plan vs Actual 비교 → SUMMARY.md 생성
- STATE.md 업데이트 (루프 위치, 진행률, 결정사항)
- **Phase 마지막 plan이면 → transition** (PROJECT.md 진화, ROADMAP 완료 처리, 커밋)

---

## 4. CARL 규칙 시스템

### 작동 방식
- 매 프롬프트마다 `<carl-rules>` 블록이 자동 주입
- 키워드 매칭으로 도메인 규칙 자동 로드 (flutter, figma 등)
- GLOBAL 규칙은 항상 적용

### 현재 도메인

| 도메인 | 트리거 키워드 | 규칙 수 |
|--------|-------------|---------|
| GLOBAL | always_on | 3 |
| FLUTTER | flutter, dart, widget, provider... | 10 |
| FIGMA | figma, design, 디자인, token... | 3 |

### 결정사항 추적
```
carl_log_decision(domain, decision, rationale, recall)
carl_search_decisions(keyword)
carl_get_decisions(domain)
```

---

## 5. Figma → Flutter 구현 워크플로우

### 5.1 전체 흐름

```
[1단계] Figma 구조 분석
    ↓
[2단계] 디자인 토큰 코드화 (lib/core/theme/)
    ↓
[3단계] 컴포넌트 위젯 구현 (presentation/widgets/)
    ↓
[4단계] 에셋 수동 추출 + 적용
    ↓
[5단계] Widget Catalog로 프리뷰
    ↓
[6단계] 스크린샷 비교 (에뮬레이터 vs Figma)
    ↓
[7단계] 차이점 수정 → 반복
    ↓
[8단계] 화면 조립 (공용 위젯 조합)
```

### 5.2 [1단계] Figma 구조 분석

**MCP 도구 사용 순서:**

```
① inspect_screen_structure(nodeId: "섹션ID")
   → 전체 프레임/컴포넌트 목록 파악

② list_component_variants(nodeId: "컴포넌트셋ID")
   → variant 축과 값 확인 (size, state, property 등)

③ inspect_component_structure(nodeId: "개별컴포넌트ID", showAllChildren: true)
   → 자식 노드 구조, 크기, 색상 확인

④ analyze_figma_component(nodeId: "컴포넌트ID", generateFlutterCode: false)
   → 스타일 속성 추출 (decoration, padding 등)
```

**실전 사례 — Components 섹션 분석:**
```
inspect_screen_structure(nodeId: "2432-555")
→ Button(8 variants), Chip(6), card(2), Bookmark(4),
  Tabs(3), Tab(6), Header(1), Map pin(4), Tab Bar(5)

list_component_variants(nodeId: "2432-570")  # Button set
→ size=sm/lg × state=solid/hover/disabled/outline
```

### 5.3 [2단계] 디자인 토큰 코드화

**원칙:** Figma 값 → `lib/core/theme/` 파일 → 위젯에서 참조. 하드코딩 0개.

```dart
// abstract final class 패턴 (Dart 3)
abstract final class AppColors {
  static const Color primary = Color(0xFF1E293B);    // slate-800
  static const Color secondary = Color(0xFF10B981);   // emerald-500
  ...
}
```

| 파일 | 내용 | Figma 소스 |
|------|------|-----------|
| `app_colors.dart` | 시맨틱 컬러 24종 | 디자인 시스템 프레임 |
| `app_typography.dart` | 9단계 타입 스케일 | 폰트/컬러 프레임 |
| `app_spacing.dart` | 4px 배수 8단계 | 컴포넌트 간격 측정 |
| `app_shape.dart` | Border Radius + Padding | 컴포넌트 속성 |
| `app_elevation.dart` | BoxShadow 3단계 | 카드/모달 그림자 |
| `app_theme.dart` | ThemeData 통합 | 전체 조합 |

### 5.4 [3단계] 컴포넌트 위젯 구현

**원칙:** Component-first. 위젯 단위 먼저 → 화면 조립.

**구현 순서:**
```
토큰 의존 위젯 (Button, Input, Chip)
  → 네비게이션 위젯 (TabBar, Tabs, Header)
    → 콘텐츠 위젯 (VehicleCard, MapPin, Bookmark)
```

**위젯 설계 패턴:**
```dart
class AiCarButton extends StatelessWidget {
  const AiCarButton({
    super.key,
    required this.label,
    required this.onPressed,    // null = disabled
    this.size = AiCarButtonSize.lg,
    this.style = AiCarButtonStyle.solid,
    this.leadingIcon,
    this.trailingIcon,
    this.isExpanded = false,
  });
  ...
}
```

- `required` 파라미터 먼저, optional은 기본값과 함께
- `onPressed: null` = disabled 패턴
- `Container + GestureDetector` > Material 위젯 (Figma-exact 스타일링)
- 모든 색상/사이즈는 토큰 참조 (AppColors, AppTypography, AppSpacing, AppShape)

### 5.5 [4단계] 에셋 수동 추출

**Figma MCP 한계:** 커스텀 아이콘, 브랜드 로고는 자동 추출 불가. 수동 export 필요.

**에셋 디렉토리 구조:**
```
flutter_app/assets/
├── icons/
│   ├── gnb/          # SVG — 탭바 아이콘 (active/inactive)
│   └── brands/       # PNG @2x — 브랜드 로고
├── images/           # PNG — 캐릭터, 일러스트
├── fonts/            # OTF — Pretendard
└── lottie/           # JSON — 애니메이션 (미사용)
```

**Export 가이드:**
- 아이콘: **SVG** (벡터, 색상 tint 가능)
- 로고/이미지: **PNG @2x** (래스터)
- pubspec.yaml에 경로 등록 필수
- SVG 사용 시 `flutter_svg` 패키지 필요

### 5.6 [5단계] Widget Catalog 프리뷰

**임시 프리뷰 페이지 생성:**
```
lib/presentation/pages/_dev/widget_catalog_page.dart
```

- 모든 위젯의 **모든 variant와 state** 를 한 페이지에 나열
- 인터랙티브 (탭, 토글, 입력 등 동작 확인)
- `main.dart`를 임시로 수정하여 이 페이지를 home으로 연결
- 개발 확인 후 삭제 또는 `.gitignore`

**main.dart 임시 연결:**
```dart
// 임시 Widget Catalog 모드
void main() {
  runApp(MaterialApp(
    theme: AppTheme.light,
    home: const WidgetCatalogPage(),
  ));
}
```

### 5.7 [6단계] 스크린샷 비교 (핵심!)

**가장 효과적인 품질 보증 단계.**

```
에뮬레이터 스크린샷          Figma 스크린샷
       │                         │
       └────── Claude에 전달 ─────┘
                    │
              차이점 분석
                    │
              수정 사항 도출
```

**실전 팁:**
- 스크린샷은 **컴포넌트별로 따로** (해상도/정확도에 유리)
- Figma에서 해당 컴포넌트 셋을 캡처 (모든 variant 보이게)
- 에뮬레이터에서 Widget Catalog 해당 섹션 캡처
- Claude에게 두 이미지를 함께 전달하면 **자동으로 차이점 테이블 생성**

**실제 발견된 차이점 사례:**

| 컴포넌트 | Figma | 초기 구현 | 수정 후 |
|---------|-------|----------|--------|
| GNB TabBar | Pill shape + 활성 원형 배경 | Flat + top border | Pill shape 재설계 |
| MapPin Selected | 말풍선 + 텍스트 라벨 | 핀만 (로고) | 말풍선/드롭핀 2형태 |
| MapPin 색상 | 브랜드별 (dark/light) | 단일 색상 | 자동 분기 |
| GNB 아이콘 | 커스텀 SVG | Material Icons | Figma SVG 적용 |
| GNB 레이블 | "시승찾기" | "시승" | 레이블 수정 |

### 5.8 [7단계] 차이점 수정 → 반복

스크린샷 비교에서 발견된 차이점을 수정하고 다시 비교. 보통 1-2회 반복으로 수렴.

### 5.9 [8단계] 화면 조립

공용 위젯이 Figma와 일치하면, 화면은 **위젯 조합**으로 빠르게 조립:

```dart
Scaffold(
  body: Column([
    AiCarHeader(title: '차고', actions: [톱니바퀴]),
    AiCarTabs(tabs: ['전체', '벤츠', 'BMW']),
    Expanded(ListView(children: [
      VehicleCard(variant: list, ...),
      VehicleCard(variant: list, ...),
    ])),
  ]),
  bottomNavigationBar: AiCarTabBar(...),
)
```

---

## 6. Git 워크플로우

### 브랜치 전략
```
main (보호)
  └── feat/flutter/design-system (Phase 1-4)
  └── feat/flutter/screen-chat (Phase 5)
  └── feat/flutter/screen-card (Phase 6)
  ...
```

### 머지 전략
```
1. 작업 브랜치에서 커밋 (Conventional Commits)
2. git fetch origin
3. git rebase main (최신 main 위에 얹기)
   - 충돌 시: git rebase main -X theirs (우리 버전 우선)
   - untracked 파일 충돌 시: /tmp로 임시 이동 → rebase → 복원
4. git push -u origin <branch> --force-with-lease
5. gh pr create → Squash Merge
```

### 세션 종료 체크리스트
```
□ 문서 최신화 (PAUL STATE/PROJECT/ROADMAP, paul.json, PLANNING.md)
□ git commit
□ git push origin main  ← 가장 먼저!
□ git fetch origin (동기화 확인)
□ 세션 보고서 작성
```

---

## 7. 유용한 PAUL 명령어

| 명령어 | 용도 |
|--------|------|
| `/paul:init` | 프로젝트 초기화 |
| `/paul:plan` | 새 계획 생성 |
| `/paul:apply` | 계획 실행 |
| `/paul:unify` | 결과 정리/루프 종료 |
| `/paul:progress` | 현재 진행 상황 확인 |
| `/paul:resume` | 세션 재개 |
| `/paul:pause` | 세션 일시 정지 |
| `/paul:handoff` | 상세 핸드오프 문서 생성 |
| `/paul:verify` | UAT 수동 검증 가이드 |

---

## 8. 실전 팁

### 효율적인 Phase 진행
- Phase당 1-3 plans. 큰 Phase는 분할
- Plan 승인 → Apply → Unify를 한 흐름으로 연속 실행
- 사용자가 "1"로 승인하면 자동 진행 가능

### 디자인 시스템 우선
- **토큰 → 위젯 → 화면** 순서 (Component-first)
- 하드코딩 0개 — 모든 값은 토큰 참조
- `abstract final class` 패턴으로 토큰 namespace

### 에러 대응
- `dart analyze` 에러 시 구버전 파일 잔여 확인
- Riverpod v3: `Notifier` 사용 (`StateNotifier` deprecated)
- GoRouter `StatefulShellRoute`: 탭 상태 보존 필수

### 도메인 분리 (Phase 8 교훈)
- **엔티티 분리 ≠ 리네이밍.** 관심사가 다르면 필드 구조도 달라야 함
  - Vehicle: 차량 스펙 (brand, model, year, price, fuelType, specs)
  - ConsultationCard: AI 상담 결과 (vehicleId 참조, recommendReason, matchScore)
- **ID 참조 vs nested**: ConsultationCard는 `vehicleId: String`으로 Vehicle 참조 (데이터 중복 방지)
- **인메모리 ≠ MVP 허용**: 북마크처럼 사용자가 저장한 데이터는 MVP라도 영속 필요 (Drift)
- **Repository Provider 위치**: 3+ feature에서 공유하면 `core/providers/`로 이동
- **Riverpod build-time mutation 금지**: `build()` 안에서 provider 상태 변경 시 빨간 에러
  - 해결: `ConsumerStatefulWidget` + `initState()` + `Future(() { ... })`

### Phase 분할 전략 (Phase 8 교훈)
- **도메인 분리는 3단계로 분할**:
  1. Entity + Repository (도메인/데이터 레이어)
  2. Provider + UI 연결 (presentation 레이어)
  3. 새 UI 구현 (차고 3탭 등)
- **ROADMAP 재구성**: Phase 실행 중에도 plan 추가/phase 흡수 가능
  - Phase 8에 차고 3탭 흡수 → Phase 9는 MyPage만 남김
- **UAT → 즉시 수정**: verify에서 발견된 이슈는 같은 세션에서 수정 후 재테스트

---

## 9. 현재 프로젝트 상태 (2026-04-02)

### Milestone 진행률

```
v0.1 MVP Release — 89% (8/9 phases)

Phase 1-7: Complete (디자인 시스템 → 홈/시승찾기)
Phase 8: Complete (도메인 분리 + 차고 3탭)
Phase 9: Pending (MyPage)
```

### CARL 결정사항

| Domain | 결정 수 | 주요 내용 |
|--------|---------|----------|
| FLUTTER | 8 | 듀얼 백엔드, 폴더 구조, AI Chat MVP, Vehicle/ConsultationCard 분리 |
| FIGMA | 4 | 파일 매핑, 디자인 토큰, 확인 항목 |

### PAUL 메트릭

- **14 plans** 완료 / ~163min 소요 / 평균 ~12min per plan
- **0 blockers**, 1 deferred issue (수정 완료)
- **UAT 전체 Pass** (Phase 8: T1-T6)

---

*이 문서는 AiCar 프로젝트에서 검증된 워크플로우입니다.*
*다른 Flutter 프로젝트에도 동일하게 적용 가능합니다.*
