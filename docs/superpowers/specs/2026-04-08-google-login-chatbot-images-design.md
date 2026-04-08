# 설계 문서 — Google 로그인 + 챗봇 구조화 + 이미지 파이프라인 (2026-04-08)

## 1. Google 로그인

### 배경
Backend에 `POST /auth/google-login`이 완전 구현됨. Flutter에 Google Sign-In SDK 연동만 추가하면 됨.

### 데이터 흐름
```
사용자 탭 → Google SDK → googleAccessToken
→ POST /api/v1/auth/google-login {provider_token: googleAccessToken}
→ {access_token, refresh_token, is_new_user}
→ SecureStorage 저장 → GET /user/me → 프로필 표시
```

### 변경 파일
| 파일 | 변경 |
|------|------|
| `pubspec.yaml` | `google_sign_in` 패키지 추가 |
| `domain/repositories/i_auth_repository.dart` | `loginWithGoogle(String googleAccessToken)` 메서드 추가 |
| `data/repositories/go_api/auth_repository_impl.dart` | `loginWithGoogle()` 구현 (POST /auth/google-login) |
| `data/repositories/supabase/auth_repository_impl.dart` | `loginWithGoogle()` 스텁 (UnimplementedError) |
| `core/providers/auth_provider.dart` | `loginWithGoogle()` 메서드 추가 (Google SDK → authRepo 호출) |
| `presentation/pages/auth/login_page.dart` | Google 로그인 버튼 추가 및 연결 |
| `core/constants/api_constants.dart` | google-login 경로 확인 (이미 존재) |

### Android/iOS 설정
- Android: `android/app/build.gradle`에 Google Services 플러그인 (필요 시)
- iOS: `ios/Runner/Info.plist`에 URL scheme 추가 (필요 시)
- Google Cloud Console에서 OAuth 2.0 클라이언트 ID 발급 필요

### 인증 흐름 (카카오와 동일 패턴)
1. Google SDK로 로그인 → accessToken 획득
2. 백엔드에 accessToken 전달 → JWT 교환
3. SecureStorage에 JWT 저장
4. AuthState 업데이트 (isLoggedIn: true, provider: 'google')

---

## 2. 챗봇 3단계 질문 시스템

### 배경
현재: 자유 입력 → 키워드 매칭 → 하드코딩 응답 (7개 카테고리)
목표: 단계별 구조화 질문 → 선택지 탭 → 차량 추천 카드

### 질문 구조

#### 1단계: 선호도 & 구매의사 (칩 선택)
| 질문 | 선택지 |
|------|--------|
| 브랜드 | 벤츠, BMW, 아우디, 볼보, 테슬라, 렉서스, 상관없음 |
| 차종 | SUV, 세단, 쿠페, 상관없음 |
| 예산 | 5천~7천, 7천~9천, 9천~1억, 상관없음 |

#### 2단계: 용도 & 라이프스타일 (칩 선택)
| 질문 | 선택지 |
|------|--------|
| 주 운전자 | 본인, 배우자, 가족 공용 |
| 주 용도 | 출퇴근, 주말 나들이, 장거리 여행, 업무용, 복합 |

#### 3단계: 핵심 고려 요소 (텍스트 입력)
- 자유 입력 → MVP에서는 저장만, 향후 RAG 연동 시 활용

### 결과
- 1~2단계 선택 기반으로 DB 필터링 (brand + body_type + price range)
- ConsultationCard 형태로 추천 차량 캐러셀 표시

### UI 방식
- 1~2단계: AI 버블 + 하단 칩/버튼 → 탭 시 사용자 버블로 올라감
- 3단계: AI 버블 + 텍스트 입력 (기존 입력 바 활용)
- 결과: AI 버블 + InlineCardCarousel (기존 컴포넌트 재활용)

### 데이터 모델

```dart
/// 질문 단계 상태
enum ConsultationStep { brand, vehicleType, budget, driver, purpose, freeText, result }

/// 누적된 사용자 답변
class ConsultationAnswers {
  String? brand;
  String? vehicleType;
  String? budgetRange;
  String? driver;
  String? purpose;
  String? freeText;
}

/// 질문 정의 (로컬 상수)
class ConsultationQuestion {
  final ConsultationStep step;
  final String question;
  final List<String>? choices; // null이면 텍스트 입력
}
```

### 변경 파일
| 파일 | 변경 |
|------|------|
| `domain/entities/consultation_question.dart` | 신규: ConsultationStep, ConsultationAnswers, ConsultationQuestion |
| `data/repositories/go_api/chat_repository_impl.dart` | `getResponse()` → `getConsultationResponse()` 로 교체 (단계별 질문 반환) |
| `data/repositories/supabase/chat_repository_impl.dart` | 동일 인터페이스 스텁 |
| `domain/repositories/i_chat_repository.dart` | 인터페이스 업데이트 |
| `presentation/pages/ai_chat/providers/chat_provider.dart` | ConsultationStep 상태 관리, 선택지 처리 로직 |
| `presentation/pages/ai_chat/ai_chat_page.dart` | 칩 선택 UI, 단계별 렌더링 |
| `presentation/pages/ai_chat/widgets/choice_chips.dart` | 신규: 선택지 칩 위젯 |

### 필터링 로직
```
ConsultationAnswers → 필터 조건 변환:
  brand → WHERE brand_name = ?
  vehicleType → WHERE body_type = ?
  budgetRange → WHERE price BETWEEN ? AND ?
→ VehicleRepository.searchVehicles(filters) 호출
→ ConsultationCard 목록 반환
```

### 기존 자유 입력 채팅과의 관계
- 새 세션 시작 시 구조화 질문 흐름으로 진입
- 3단계 완료 후 결과 표시 → 이후 자유 입력 전환 가능
- 기존 키워드 매칭 로직은 자유 입력 모드에서 유지

---

## 3. 이미지 파이프라인 (EC2 로컬)

### 배경
현재 차량 이미지:
- 7대: placehold.co (텍스트 placeholder) — 사용 불가
- 2대: Audi 공식 URL — 사용 가능
- 1대: 벤츠 URL이 Volvo에 잘못 매핑

크롤러 수집 이미지(벤츠 60대):
- 동적 인증 URL → 직접 접근 401 → 다운로드 후 서빙 필요

### 아키텍처
```
크롤러 (Playwright)
  → 이미지 바이너리 다운로드
  → EC2 /var/data/images/{brand}/{model}_{trim}_{angle}.webp 저장

Go 서버
  → router.go: r.Static("/static", "/var/data") 추가
  → URL: http://18.191.163.53:8080/static/images/benz/glc_220d_front.webp

DB
  → vehicles_trim_images.image_url = 로컬 URL
  → cars.thumbnail_url = 로컬 URL (마이그레이션)
```

### 파일명 규칙
```
{brand}/{model}_{trim}_{angle}.webp
예: benz/glc_220d_4matic_front.webp
    benz/glc_220d_4matic_side.webp
    benz/glc_220d_4matic_interior.webp
```

### 변경 파일
| 파일 | 변경 |
|------|------|
| `vehicle_crawler/crawlers/_.py` (벤츠) | 이미지 다운로드 로직 추가 |
| `vehicle_crawler/crawlers/bmw/summary_crawler.py` | 이미지 다운로드 로직 추가 |
| `vehicle_crawler/db/db.py` | image_url에 로컬 경로 저장 |
| `backend/internal/adapter/router/router.go` | `r.Static("/static", "/var/data")` 추가 |
| `backend/migrations/00032_...sql` | 기존 placehold.co URL → 실제 URL 마이그레이션 |

### 의존성
- 서버 SSH 접속 필요
- Python venv + Playwright 서버 설치
- DB 접속 정보 (.env)

---

## 우선순위 & 실행 순서

| 순서 | 작업 | 복잡도 | 의존성 | 비고 |
|------|------|--------|--------|------|
| 1 | Google 로그인 | Light | 없음 | 즉시 가능, 카카오 패턴 복제 |
| 2 | 챗봇 3단계 질문 | Standard | 없음 | 즉시 가능, UI + 상태 관리 |
| 3 | 이미지 파이프라인 | Standard | 서버 접속 | 서버 셋업 후 진행 |

### 변경 금지 영역
- `lib/core/theme/` (디자인 토큰)
- `lib/core/constants/api_constants.dart` (google-login 경로 이미 존재)
- `backend/` 코드 직접 수정 (router.go Static 라우트 제외)
