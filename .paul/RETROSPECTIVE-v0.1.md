# v0.1 MVP Release — 회고

**날짜:** 2026-04-02
**범위:** 9 Phases / 15 Plans / ~183min

---

## 1. Phase 8 (Domain Separation) 중간 삽입 — 효과 분석

### 배경
Phase 1-7까지 `VehicleCard` 단일 엔티티 + `ICardRepository` 단일 인터페이스로 구현.
Phase 7 완료 후 도메인 혼동이 누적되어 Phase 8을 삽입 결정.

### 혼동이 발생한 구체적 패턴

| 혼동 | 증상 | 근본 원인 |
|------|------|-----------|
| **Card 네이밍** | `VehicleCard`가 차량 스펙이자 상담 결과로 이중 사용 | Claude가 "Card"를 UI 컴포넌트명으로 해석, 비즈니스 도메인(차량 vs 상담)을 구분하지 못함 |
| **북마크=차고 혼동** | `saveToGarage`로 북마크와 차고 저장을 동일 취급 | "찜하기"(북마크)와 "상담 결과 저장"(차고)의 사용자 의도 차이를 무시 |
| **_extractQuery 버그** | AI 응답 텍스트에서 키워드 추출 → "BMW 추천해줘"에 SUV 반환 | 사용자 입력 vs AI 응답의 데이터 흐름 방향을 혼동 |

### Phase 8 삽입 효과

**정량:**
- 22개 파일 수정/생성 (08-01), 11개 (08-02), 10개 (08-03) = 총 43개 파일
- 실행 시간: ~45min (전체의 24.6%)
- 3개 Plan으로 분할하여 점진적 리팩토링

**정성:**
- Vehicle(스펙) vs ConsultationCard(상담) 도메인 경계 확립 → Phase 9에서 혼동 0건
- ICardRepository → IVehicle + IBookmark + IGarage 3분할 → 책임 명확화
- Drift 영속 북마크 → 인메모리 유실 문제 해결
- `_extractQuery` 버그 근본 수정

### 결론
**Phase 8 삽입은 유효했다.** 중간 리팩토링 없이 Phase 9까지 진행했다면:
- 차고/마이페이지에서 "어떤 Card?"라는 질문이 매 Plan마다 반복
- 북마크와 차고 저장 로직이 계속 엉킴
- 기술 부채가 Post-MVP까지 이월

**교훈:** 도메인 모델 혼동이 2개 Phase 이상 누적되면, 다음 기능 추가 전에 분리 Phase를 삽입하는 것이 총 비용이 더 낮다.

---

## 2. Claude Code 비즈니스 로직 혼동 — 방지 패턴

### 관찰된 혼동 유형

#### Type A: 네이밍 기반 추론
Claude는 클래스명/변수명에서 비즈니스 의미를 추론한다. `VehicleCard`라는 이름만 보고 "차량 카드 UI"로 해석하지, "AI 상담 결과로 생성된 추천 카드"라는 비즈니스 맥락은 코드에서 읽지 못한다.

**방지 패턴:**
- 엔티티 생성 시 주석이 아닌 **이름 자체**에 비즈니스 의도를 반영
  - Bad: `VehicleCard` (UI인지 데이터인지 모호)
  - Good: `ConsultationCard` (AI 상담 결과임이 명확)
- CARL decision으로 도메인 용어 사전(Ubiquitous Language) 기록

#### Type B: 유사 기능 병합
Claude는 "비슷해 보이는" 기능을 하나로 합치려 한다. 북마크(찜)와 차고 저장은 UI가 비슷하지만 사용자 의도와 라이프사이클이 다르다.

**방지 패턴:**
- PLAN 단계에서 **"이 엔티티/기능이 2가지 이상 관심사를 가지는가?"** 체크리스트
- CARL decision에 도메인 분리 결정을 사전 기록 (Phase 8처럼 사후가 아닌 사전에)

#### Type C: 데이터 흐름 방향 혼동
`_extractQuery`가 사용자 입력이 아닌 AI 응답에서 키워드를 추출한 것처럼, 입력→처리→출력의 방향을 Claude가 혼동할 수 있다.

**방지 패턴:**
- PLAN의 task에 데이터 흐름 방향을 명시: "사용자 입력 → 키워드 추출 → API 쿼리" (어디서 읽고 어디로 보내는지)
- 함수명에 방향 힌트: `extractFromUserInput()` vs `extractFromResponse()`

---

## 3. CARL Decisions — PLAN 품질 기여도 분석

### 12개 Decision 활용도

| Decision | 활용 횟수 (추정) | 기여 유형 |
|----------|-----------------|-----------|
| flutter-001 (듀얼 백엔드) | 15/15 plans | **가드레일** — 매 Plan에서 go_api/supabase 양쪽 구현체 일관 유지 |
| flutter-002 (폴더 구조 v6) | 15/15 plans | **가드레일** — 파일 배치 결정을 매번 반복하지 않음 |
| flutter-003 (AI Chat MVP) | 2/15 plans | **범위 제한** — Phase 5에서 Python RAG 구현 충동 방지 |
| flutter-007 (GNB 탭 구성) | 5/15 plans | **일관성** — 탭 관련 결정을 재논의하지 않음 |
| flutter-008 (도메인 분리) | 4/15 plans | **도메인 모델** — Phase 8-9에서 엔티티 설계 가이드 |
| figma-003 (디자인 토큰) | 15/15 plans | **하드코딩 방지** — 모든 UI 코드에서 토큰 참조 강제 |
| figma-004 (디자이너 확인) | 8/15 plans | **디자인 일관성** — 상태 컬러, radius 등 매번 확인 불필요 |

### 효과적이었던 점
1. **반복 결정 제거:** 듀얼 백엔드 구조, GNB 탭 구성 등을 매 세션마다 재논의하지 않음
2. **recall 키워드:** `flutter`, `repository`, `figma` 등으로 관련 PLAN 작성 시 자동 로드
3. **PLAN coherence check에서 충돌 감지:** decision과 PLAN이 모순되는지 자동 확인

### 부족했던 점
1. **도메인 모델링 decision 부재 (Phase 1-7):** flutter-008은 Phase 8에서야 추가됨. Phase 5-6에서 VehicleCard가 이중 사용될 때 이를 잡을 decision이 없었음
2. **런타임 규칙 vs 아키텍처 규칙:** CARL rules는 코드 패턴(하드코딩 금지, const constructor)에 집중. 비즈니스 로직 규칙(엔티티 관심사 분리)은 없었음
3. **decision timing:** 대부분 Phase 1에서 일괄 등록. Phase 진행 중 새로운 decision 추가가 더 빈번해야 했음

### 개선 제안

**새 CARL Rule (FLUTTER 도메인):**
> "새 엔티티 생성 시, 해당 엔티티가 2가지 이상 사용자 시나리오(탐색 vs 저장 vs 추천)에 걸치면 반드시 분리를 검토하고 CARL decision으로 기록."

**PLAN 워크플로우에 도메인 체크 추가:**
> PLAN 생성 시 `<acceptance_criteria>` 작성 전에 "이 Plan에서 다루는 엔티티가 단일 관심사(Single Responsibility)를 유지하는가?" 확인 단계.

---

## 4. v0.2를 위한 워크플로우 개선 항목

| 항목 | 적용 시점 | 우선순위 |
|------|-----------|----------|
| 도메인 용어 사전 CARL decision 등록 | 마일스톤 시작 시 | High |
| PLAN에 엔티티 SRP 체크 단계 추가 | /paul:plan 실행 시 | High |
| Phase 3+ 시점에 도메인 모델 리뷰 | Phase 전환 시 | Medium |
| CARL decision을 Phase 진행 중에도 적극 추가 | 상시 | Medium |
| 데이터 흐름 방향을 task action에 명시 | PLAN 작성 시 | Low |

---
*Created: 2026-04-02 after v0.1 MVP Release*
