# 에이카(AiCar) Flutter 앱 — Claude Code CLI 런북

> **용도**: Claude Code CLI에서 Figma Flutter MCP를 사용하여 UI를 구현하는 실전 가이드
> **프로젝트**: 스위프 앱 4기_에이카
> **Figma 파일**: `o7szshz4qyL7DUEulcPNFq`

---

## 사전 확인 (Claude Code CLI에서 실행)

```
/mcp
```

`figma-flutter` 서버가 **connected** 상태인지 확인한다.
문제가 있으면:

```
claude mcp remove figma-flutter
claude mcp add figma-flutter npx -- -y figma-flutter-mcp --figma-api-key=figd_YOUR_TOKEN --stdio
```

---

## Figma 링크 정리

| 화면 | node-id | 용도 |
|------|---------|------|
| 채팅 UI 1 | 2304-753 | 홈 채팅 화면 (메인) |
| 채팅 UI 2 | 2304-817 | 홈 채팅 화면 (상태 변형) |
| 채팅 UI 3 | 2304-870 | 홈 채팅 화면 (상태 변형) |
| 차량탐색 탭 | 2304-527 | 차량 검색/목록 화면 |
| 가상차고 | 2304-451 | 마이페이지/차량 관리 |

---

## Phase 0: 디자인 토큰 추출 → 앱 테마 생성

### 프롬프트 (Claude Code CLI에 복사)

```
아래 Figma 채팅 화면에서 앱 전체에서 사용할 디자인 토큰을 추출하고
Flutter 테마 파일을 생성해줘.

Figma 링크: https://www.figma.com/design/o7szshz4qyL7DUEulcPNFq/%EC%8A%A4%EC%9C%84%ED%94%84-%EC%95%B1-4%EA%B8%B0_%EC%97%90%EC%9D%B4%EC%B9%B4?node-id=2304-753&t=6ZBVt3TsbQkfMOdM-11

추출할 것:
- Primary / Secondary / Surface / Background 색상
- 텍스트 색상 (제목, 본문, 보조)
- 타이포그래피 (폰트 패밀리, 사이즈, weight)
- Border radius, 간격(padding/margin) 패턴
- 그림자/elevation 패턴

생성할 파일:
1. lib/core/theme/app_colors.dart
   - abstract final class AppColors 로 정의
   - 라이트/다크 모드 ColorScheme 포함
   
2. lib/core/theme/app_typography.dart
   - TextTheme 정의
   - 한국어 폰트 고려 (Pretendard 또는 Noto Sans KR)

3. lib/core/theme/app_theme.dart
   - ThemeData.light() / ThemeData.dark() 통합
   - Material 3 기반 (useMaterial3: true)

4. lib/core/theme/app_spacing.dart
   - 일관된 간격 상수 (4, 8, 12, 16, 20, 24, 32, 48)

모든 값은 const로 정의하고, 하드코딩은 금지.
```

### 확인

```
생성된 테마 파일들을 보여주고, 
main.dart에 ThemeData가 올바르게 적용됐는지 확인해줘.
flutter analyze로 문제 없는지도 검증해줘.
```

### 커밋

```
디자인 토큰 추출과 테마 파일 생성이 완료됐으니:
1. flutter analyze 실행
2. feature/design-system 브랜치 생성
3. "feat: extract design tokens and create app theme from Figma" 커밋
4. main에 머지
```

---

## Phase 1: 온보딩 / 스플래시

> 별도 Figma 디자인 없음 — 앱 컨셉에 맞게 자체 구성

### 1-1. 스플래시 화면

```
에이카(AiCar) 앱의 스플래시 화면을 만들어줘.
차량 관련 채팅 기반 앱이야.

요구사항:
- lib/features/onboarding/presentation/screens/splash_screen.dart
- 앱 로고(없으면 텍스트 로고 "AiCar") + 간단한 애니메이션
- 자동차 관련 앱다운 세련된 느낌
- 2초 후 온보딩 화면으로 자동 이동
- GoRouter 사용 (아직 없으면 설치 포함)
- AppTheme 색상 적용
- AnimatedOpacity 또는 간단한 fade-in 효과
```

### 1-2. 온보딩 화면

```
에이카 앱의 온보딩 화면을 만들어줘. 3개 슬라이드로 구성.

슬라이드 내용:
1. "AI와 대화하며 나에게 맞는 차를 찾아보세요" - 채팅 아이콘
2. "다양한 차량을 탐색하고 비교해보세요" - 차량 검색 아이콘  
3. "나만의 가상 차고에 관심 차량을 저장하세요" - 차고 아이콘

요구사항:
- lib/features/onboarding/presentation/screens/onboarding_screen.dart
- lib/features/onboarding/presentation/widgets/onboarding_page.dart (재사용 위젯)
- PageView + smooth_page_indicator 패키지
- 하단: dot indicator + "건너뛰기" / "다음" 버튼
- 마지막 슬라이드: "시작하기" 버튼 → 홈 화면으로
- 아이콘은 Material Icons 또는 lucide_icons 활용
- AppTheme 적용
- smooth_page_indicator 패키지 설치도 해줘
```

### 1-3. 네비게이션 설정

```
GoRouter를 설정해줘.

라우트 구조:
- / → SplashScreen
- /onboarding → OnboardingScreen  
- /home → MainShell (BottomNavigationBar)
  - /home/chat → ChatScreen (홈 탭)
  - /home/search → VehicleSearchScreen (차량탐색 탭)
  - /home/garage → GarageScreen (가상차고 탭)

요구사항:
- lib/core/router/app_router.dart
- ShellRoute으로 BottomNavigationBar 유지
- 3개 탭: 채팅(홈), 차량탐색, 가상차고
- 탭 아이콘은 적절히 선택
- riverpod Provider로 router 관리
```

### 커밋

```
온보딩과 라우터 설정이 완료됐으니:
1. flutter analyze 실행
2. feature/onboarding-and-router 브랜치 생성
3. "feat: implement splash, onboarding screens and GoRouter navigation" 커밋
4. main에 머지
```

---

## Phase 2: 홈 — 채팅 UI (핵심 화면)

> 3개 Figma 링크를 활용하여 컴포넌트 단위로 분해 구현

### 2-1. 메시지 버블 위젯

```
이 Figma 채팅 화면에서 메시지 버블 컴포넌트를 추출해서
Flutter 위젯으로 만들어줘.

Figma 링크: https://www.figma.com/design/o7szshz4qyL7DUEulcPNFq/%EC%8A%A4%EC%9C%84%ED%94%84-%EC%95%B1-4%EA%B8%B0_%EC%97%90%EC%9D%B4%EC%B9%B4?node-id=2304-753&t=6ZBVt3TsbQkfMOdM-11

요구사항:
- lib/features/chat/presentation/widgets/message_bubble.dart
- AI 메시지 (좌측 정렬) / 사용자 메시지 (우측 정렬) 구분
- 버블 색상, border radius, 패딩을 Figma에서 정확히 가져오기
- 타임스탬프 표시
- AI 메시지에는 아바타/아이콘 표시
- 긴 텍스트 자동 줄바꿈
- const constructor
- AppTheme 색상 적용
```

### 2-2. 채팅 입력창

```
같은 Figma 채팅 화면에서 하단 메시지 입력 영역을 추출해서
Flutter 위젯으로 만들어줘.

Figma 링크: https://www.figma.com/design/o7szshz4qyL7DUEulcPNFq/%EC%8A%A4%EC%9C%84%ED%94%84-%EC%95%B1-4%EA%B8%B0_%EC%97%90%EC%9D%B4%EC%B9%B4?node-id=2304-753&t=6ZBVt3TsbQkfMOdM-11

요구사항:
- lib/features/chat/presentation/widgets/chat_input_bar.dart
- TextField + 전송 버튼 (Figma 디자인 반영)
- 입력 텍스트가 있을 때만 전송 버튼 활성화 (색상 변화)
- SafeArea + 키보드 대응 (resizeToAvoidBottomInset)
- 입력창 포커스 시 미세한 elevation/border 변화
- Figma의 정확한 간격, 모서리 radius, 아이콘 반영
```

### 2-3. 채팅 화면의 다른 상태 확인

```
이 두 Figma 화면은 같은 채팅 UI의 다른 상태야. 
어떤 차이가 있는지 분석해줘.

링크 1: https://www.figma.com/design/o7szshz4qyL7DUEulcPNFq/%EC%8A%A4%EC%9C%84%ED%94%84-%EC%95%B1-4%EA%B8%B0_%EC%97%90%EC%9D%B4%EC%B9%B4?node-id=2304-817&t=6ZBVt3TsbQkfMOdM-11

링크 2: https://www.figma.com/design/o7szshz4qyL7DUEulcPNFq/%EC%8A%A4%EC%9C%84%ED%94%84-%EC%95%B1-4%EA%B8%B0_%EC%97%90%EC%9D%B4%EC%B9%B4?node-id=2304-870&t=6ZBVt3TsbQkfMOdM-11

분석해서:
- 첫 번째 화면(2304-753)과의 차이점을 정리
- 추가 위젯이 필요하면 생성
- 상태별 UI 변화 (로딩, 빈 상태, 추천 카드 등)가 있으면 구현
```

### 2-4. 전체 채팅 화면 조립

```
지금까지 만든 message_bubble.dart, chat_input_bar.dart,
그리고 추가 위젯들을 사용해서 전체 채팅 화면을 조립해줘.

메인 Figma 참고: https://www.figma.com/design/o7szshz4qyL7DUEulcPNFq/%EC%8A%A4%EC%9C%84%ED%94%84-%EC%95%B1-4%EA%B8%B0_%EC%97%90%EC%9D%B4%EC%B9%B4?node-id=2304-753&t=6ZBVt3TsbQkfMOdM-11

요구사항:
- lib/features/chat/presentation/screens/chat_screen.dart
- AppBar: Figma 디자인 그대로 (타이틀, 아이콘 등)
- ListView.builder로 메시지 목록 (역순 스크롤, reverse: true)
- 하단 ChatInputBar 고정
- 더미 데이터로 대화 시나리오 구성:
  - AI: "안녕하세요! 어떤 차량을 찾고 계신가요?"
  - User: "출퇴근용 소형 SUV를 찾고 있어요"
  - AI: "출퇴근용 소형 SUV 추천드릴게요! 주행거리와 예산은 어떻게 되세요?"
  - User: "연 2만km, 3천만원 정도요"
  - AI: "좋은 선택지가 있어요. 현대 코나, 기아 셀토스, 쉐보레 트랙스를 비교해볼까요?"
- 새 메시지 전송 시 목록에 추가 + 자동 스크롤
- AI 응답은 1초 딜레이 후 표시 (타이핑 인디케이터 선택)
- Supabase 연동은 나중에 — 지금은 로컬 상태만
```

### 커밋

```
채팅 UI가 완성됐으니:
1. flutter analyze 실행
2. flutter test (테스트가 있다면)
3. feature/chat-ui 브랜치 생성
4. "feat: implement chat screen with AI message bubbles, input bar, and dummy conversation" 커밋
5. main에 머지
```

---

## Phase 3: 차량탐색 탭

### 3-1. 차량 카드 컴포넌트

```
이 Figma 차량탐색 화면에서 차량 카드 컴포넌트를 추출해서
Flutter 위젯으로 만들어줘.

Figma 링크: https://www.figma.com/design/o7szshz4qyL7DUEulcPNFq/%EC%8A%A4%EC%9C%84%ED%94%84-%EC%95%B1-4%EA%B8%B0_%EC%97%90%EC%9D%B4%EC%B9%B4?node-id=2304-527&t=6ZBVt3TsbQkfMOdM-11

요구사항:
- lib/features/vehicle_search/presentation/widgets/vehicle_card.dart
- 차량 이미지, 이름, 가격, 주요 스펙 표시
- Figma의 카드 레이아웃(shadow, radius, 패딩) 정확히 반영
- 좋아요/북마크 버튼 (있다면)
- 탭 시 상세 페이지로 이동 (onTap 콜백)
- 이미지는 placeholder로 (나중에 네트워크 이미지)
- const constructor
```

### 3-2. 검색/필터 영역

```
같은 Figma 차량탐색 화면에서 상단 검색바와 필터 영역을
Flutter 위젯으로 만들어줘.

Figma 링크: https://www.figma.com/design/o7szshz4qyL7DUEulcPNFq/%EC%8A%A4%EC%9C%84%ED%94%84-%EC%95%B1-4%EA%B8%B0_%EC%97%90%EC%9D%B4%EC%B9%B4?node-id=2304-527&t=6ZBVt3TsbQkfMOdM-11

요구사항:
- lib/features/vehicle_search/presentation/widgets/search_header.dart
- 검색 입력 필드 (Figma 디자인 반영)
- 필터 칩/태그 (차종, 가격대, 연식 등 - Figma에 있는 대로)
- 필터 칩 선택/해제 토글
```

### 3-3. 전체 차량탐색 화면 조립

```
vehicle_card.dart와 search_header.dart를 사용해서
전체 차량탐색 화면을 조립해줘.

Figma 링크: https://www.figma.com/design/o7szshz4qyL7DUEulcPNFq/%EC%8A%A4%EC%9C%84%ED%94%84-%EC%95%B1-4%EA%B8%B0_%EC%97%90%EC%9D%B4%EC%B9%B4?node-id=2304-527&t=6ZBVt3TsbQkfMOdM-11

요구사항:
- lib/features/vehicle_search/presentation/screens/vehicle_search_screen.dart
- 상단: SearchHeader (검색 + 필터)
- 본문: 차량 카드 리스트 (ListView 또는 GridView - Figma에 따라)
- 더미 차량 데이터 10대:
  - 현대 코나, 기아 셀토스, 쉐보레 트랙스, 르노 XM3, 
    쌍용 티볼리, 기아 니로, 현대 투싼, 기아 스포티지,
    현대 아이오닉5, 기아 EV6
  - 각각 가격, 연식, 주행거리, 연료 타입 포함
- 스크롤 시 AppBar 축소 (SliverAppBar - 필요시)
- Supabase 연동은 나중에
```

### 커밋

```
차량탐색 화면이 완성됐으니:
1. flutter analyze
2. feature/vehicle-search 브랜치 생성  
3. "feat: implement vehicle search screen with cards, search bar, and filters" 커밋
4. main에 머지
```

---

## Phase 4: 가상차고 (마이페이지)

### 4-1. 프로필/헤더 컴포넌트

```
이 Figma 가상차고 화면에서 상단 프로필/헤더 영역을 추출해서
Flutter 위젯으로 만들어줘.

Figma 링크: https://www.figma.com/design/o7szshz4qyL7DUEulcPNFq/%EC%8A%A4%EC%9C%84%ED%94%84-%EC%95%B1-4%EA%B8%B0_%EC%97%90%EC%9D%B4%EC%B9%B4?node-id=2304-451&t=6ZBVt3TsbQkfMOdM-11

요구사항:
- lib/features/garage/presentation/widgets/garage_header.dart
- 사용자 프로필 (아바타, 이름, 한줄 소개 등 - Figma에 따라)
- Figma 디자인 정확히 반영
- 설정/편집 버튼 (있다면)
```

### 4-2. 내 차량 카드

```
같은 Figma 가상차고 화면에서 저장된 차량 카드를 추출해서
Flutter 위젯으로 만들어줘.

Figma 링크: https://www.figma.com/design/o7szshz4qyL7DUEulcPNFq/%EC%8A%A4%EC%9C%84%ED%94%84-%EC%95%B1-4%EA%B8%B0_%EC%97%90%EC%9D%B4%EC%B9%B4?node-id=2304-451&t=6ZBVt3TsbQkfMOdM-11

요구사항:
- lib/features/garage/presentation/widgets/my_vehicle_card.dart
- vehicle_search의 vehicle_card.dart와 다른 점이 있으면 반영
- "저장됨" 상태 표시, 삭제 버튼 등 가상차고 특화 기능
- 차량 비교 선택 체크박스 (있다면)
```

### 4-3. 전체 가상차고 화면 조립

```
garage_header.dart와 my_vehicle_card.dart를 사용해서
전체 가상차고 화면을 조립해줘.

Figma 링크: https://www.figma.com/design/o7szshz4qyL7DUEulcPNFq/%EC%8A%A4%EC%9C%84%ED%94%84-%EC%95%B1-4%EA%B8%B0_%EC%97%90%EC%9D%B4%EC%B9%B4?node-id=2304-451&t=6ZBVt3TsbQkfMOdM-11

요구사항:
- lib/features/garage/presentation/screens/garage_screen.dart  
- 상단: GarageHeader (프로필)
- 본문: 저장된 차량 목록 (MyVehicleCard 리스트)
- 빈 상태: 저장된 차량이 없을 때 안내 메시지 + CTA
- 더미 데이터: 3대 저장 (현대 코나, 기아 셀토스, 현대 아이오닉5)
- 차량 삭제 기능 (로컬 상태)
- Supabase 연동은 나중에
```

### 커밋

```
가상차고 화면이 완성됐으니:
1. flutter analyze
2. feature/garage 브랜치 생성
3. "feat: implement virtual garage screen with profile header and saved vehicles" 커밋
4. main에 머지
```

---

## 최종 검증

```
모든 화면이 완성됐으니 전체 앱을 검증해줘:

1. flutter analyze — 린트 에러 0개 확인
2. 모든 화면 간 네비게이션 확인 (GoRouter)
3. BottomNavigationBar 탭 전환 정상 동작
4. 각 화면의 스크롤, 입력, 버튼 인터랙션 확인
5. 다크모드 전환 시 테마 적용 확인
6. 문제가 있으면 수정하고 결과 보고
```

---

## 트러블슈팅

### MCP가 Figma 노드를 읽지 못할 때

```
# Figma 링크에서 node-id 포맷 확인
# 올바른 형식: node-id=2304-753
# 잘못된 형식: node-id=2304:753 (콜론이 아닌 하이픈)

# MCP 서버 재시작
claude mcp remove figma-flutter
claude mcp add figma-flutter npx -- -y figma-flutter-mcp --figma-api-key=figd_TOKEN --stdio
```

### 생성된 코드에서 import 에러가 날 때

```
pubspec.yaml에 필요한 패키지가 모두 있는지 확인하고,
없는 패키지는 추가한 뒤 flutter pub get 실행해줘.
```

### 이미지 에셋이 누락됐을 때

```
Figma에서 이미지 에셋을 추출해서 assets/images/에 저장하고
pubspec.yaml의 assets 섹션도 업데이트해줘.
```
