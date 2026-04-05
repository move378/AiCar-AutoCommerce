# AiCar 디버깅 & 테스트 가이드

## 1. API 연결 확인 (curl)

### 서버 상태 확인
```bash
# 전체 차량 목록 (가장 기본적인 동작 확인)
curl -s "http://18.191.163.53:8080/api/v1/cars?page=1&size=3" | python3 -m json.tool

# 브랜드 목록
curl -s "http://18.191.163.53:8080/api/v1/brands" | python3 -m json.tool

# 차량 상세 (이미지 포함)
curl -s "http://18.191.163.53:8080/api/v1/cars/33333333-3333-3333-3333-333333333333" | python3 -m json.tool

# 온보딩 (새 디바이스 토큰 발급)
curl -s -X POST http://18.191.163.53:8080/api/v1/auth/onboard \
  -H "Content-Type: application/json" \
  -d '{"device_id":"TEST-DEBUG-001","device_type":"android"}' | python3 -m json.tool

# 토큰으로 프로필 조회 (위 응답의 access_token 사용)
curl -s http://18.191.163.53:8080/api/v1/user/me \
  -H "Authorization: Bearer {access_token}" | python3 -m json.tool
```

### 이미지 URL 접근성 테스트
```bash
# HTTP 상태코드만 확인 (200이면 정상)
curl -sI -L "{이미지URL}" | head -3

# Content-Type 확인 (image/png, image/jpeg이어야 함 — image/svg+xml이면 Flutter에서 디코딩 실패)
curl -sI "{이미지URL}" | grep -i content-type
```

### vehicles API (아직 미동작 가능)
```bash
curl -s "http://18.191.163.53:8080/api/v1/vehicles?page=1&size=2" | python3 -m json.tool
# "vehicles_trims does not exist" → 마이그레이션 미적용
```

---

## 2. Flutter 디버그 로그

### 현재 앱에 포함된 디버그 출력

| 로그 태그 | 위치 | 내용 |
|---|---|---|
| `[Kakao]` | `main.dart` | 카카오 키 해시 |
| `[Splash]` | `splash_page.dart` | 온보딩 실패 시 에러 |
| `[Home]` | `home_provider.dart` | 차량별 imageUrl 값 |
| `[VehicleCard]` | `vehicle_card.dart` | 이미지 URL + 로드 실패 에러 |
| `*** Request/Response ***` | `dio_provider.dart` (LogInterceptor) | 모든 HTTP 요청/응답 |

### 로그 필터링
```bash
# flutter run 실행 중 터미널에서 grep으로 필터
# (별도 터미널에서 adb logcat 사용)
adb logcat -s flutter | grep "\[Home\]\|\[VehicleCard\]\|\[Kakao\]\|\[Splash\]"
```

### 이미지 로드 문제 디버깅 체크리스트

1. `[Home] ... imageUrl=null` → **CarMapper 매핑 문제** (thumbnail_url → imageUrl)
2. `[Home] ... imageUrl=https://...` + `[VehicleCard] Image load FAILED` → **이미지 포맷/네트워크 문제**
   - `Invalid image data` → SVG 또는 WebP를 Flutter가 디코딩 못함 → PNG/JPEG URL 필요
   - `SocketException` → 에뮬레이터 네트워크 문제
   - `404` → URL 자체가 잘못됨
3. `[Home]` 로그 자체가 안 나옴 → **API 호출 실패** (Dio 에러 로그 확인)
4. `[VehicleCard]` 로그가 안 나옴 → **home_page에서 imageUrl 전달 누락**

---

## 3. 인증 흐름 디버깅

### 정상 흐름
```
앱 시작
  → [Splash] onboard 호출
  → Dio: POST /auth/onboard → 200 {access_token, refresh_token}
  → SecureStorage에 토큰 저장
  → 홈 진입
  → Dio: GET /cars (Authorization: Bearer {token}) → 200

카카오 로그인
  → 카카오 SDK: 브라우저/앱 열림 → 사용자 인증 → code 수신
  → Dio: POST /auth/kakao-login → 200 {access_token, refresh_token, is_new_user}
  → Dio: GET /user/me → 200 {name, email}
```

### 인증 에러 케이스

| 증상 | 원인 | 해결 |
|---|---|---|
| onboard 500 | 서버 마이그레이션 미적용 (users/devices 테이블) | 백엔드: `make migrate-up` |
| kakao-login 401 | onboard 미완료 → Bearer 토큰 없음 | splash에서 onboard 먼저 호출 |
| keyHash validation failed | 카카오 콘솔에 키 해시 미등록 또는 앱 키 불일치 | `[Kakao] keyHash:` 로그 값을 콘솔에 등록 |
| 401 on /cars | 토큰 만료 + refresh 실패 | SecureStorage 초기화 후 재시작 |

### SecureStorage 초기화 (토큰 문제 시)
```dart
// 앱 데이터 삭제 또는 코드에서:
await ref.read(tokenStorageProvider).clearAll();
```
에뮬레이터: Settings → Apps → aicar → Storage → Clear Data

---

## 4. 마이그레이션 디버깅

### 서버에서 마이그레이션 상태 확인
```bash
# SSH 접속 후
make migrate-status  # 적용된/미적용 마이그레이션 목록

# 특정 마이그레이션만 적용
goose -dir migrations postgres "연결문자열" up-to 00031
```

### 마이그레이션 적용 안 되는 경우
1. **`git pull` 안 함** → 서버에 마이그레이션 파일이 없음
2. **이미 적용된 파일 수정** → Goose는 재실행 안 함 → 새 번호로 마이그레이션 생성
3. **SQL 문법 에러** → `make migrate-up` 출력에서 에러 메시지 확인
4. **파일명 문제** → 공백, 특수문자 확인 (예: `00003_create...providers .sql` ← 공백)

### 마이그레이션 순서
```
00001 pgvector → 00002 users → 00003 auth_providers → 00004 devices
→ 00005-00012 vehicles → 00014-00018 cars+brands+seed
→ 00019 marketing → 00022-00024 chat+promotions+estimates
→ 00025-00026 my_cars → 00027 car_samples → 00028-00031 이미지 수정
```

---

## 5. 에뮬레이터 네트워크 문제

### 에뮬레이터에서 외부 서버 접속 안 될 때
```bash
# DNS 확인
adb shell ping -c 3 18.191.163.53

# 에뮬레이터 Cold Boot (네트워크 초기화)
# Android Studio → Device Manager → Cold Boot Now

# 프록시 설정 확인
adb shell settings get global http_proxy
# 값이 있으면 제거:
adb shell settings delete global http_proxy
```

### localhost vs 에뮬레이터
- Android 에뮬레이터에서 호스트 머신의 localhost → `10.0.2.2` 사용
- .env의 `API_BASE_URL`이 `localhost`면 에뮬레이터에서 접속 불가
- 현재 설정: `http://18.191.163.53:8080` (외부 서버) → 정상

---

## 6. 빌드 문제

### build_runner 에러
```bash
cd flutter_app

# 충돌 파일 삭제 후 재생성
dart run build_runner build --delete-conflicting-outputs

# 특정 파일만 재생성
dart run build_runner build --delete-conflicting-outputs --build-filter="lib/domain/entities/vehicle.dart"
```

### flutter analyze 에러 분류

| 에러 유형 | 원인 | 해결 |
|---|---|---|
| `creation_with_non_type` (widget_test.dart) | 기존 테스트 파일 미업데이트 | 무시 또는 테스트 수정 |
| `specs` null 관련 | Vehicle.specs nullable 변경 | `vehicle.specs?.power ?? 0` |
| `saveMessage` signature | IChatRepository 시그니처 변경 | `saveMessage(sessionId, message)` |
| `chatRepositoryProvider` 중복 | core와 feature 양쪽에 정의 | feature 쪽 제거 |

### APK 빌드
```bash
flutter build apk --release
# 출력: build/app/outputs/flutter-apk/app-release.apk

# 에뮬레이터에 직접 설치
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 7. 데이터 흐름 추적

### Cars API → 홈 화면
```
GET /api/v1/cars
  → Dio (dio_provider.dart) — 토큰 주입, 로깅
  → VehicleRepositoryImpl.getAllVehicles() — JSON 파싱
  → CarDto.fromJson() — DTO 역직렬화
  → CarMapper.fromDto() — DTO → Vehicle 변환 (brand_name→brand, thumbnail_url→imageUrl)
  → HomeNotifier._loadVehicles() — state 업데이트
  → HomePage — Vehicle 목록 표시
  → VehicleCard(imageUrl: vehicle.imageUrl) — 이미지 로드
```

### 카카오 로그인 → 백엔드
```
LoginPage "카카오로 시작하기" 탭
  → AuthNotifier.loginWithKakao()
  → KakaoSdk.loginWithKakaoAccount() — 카카오 OAuth
  → 카카오 access_token 획득
  → AuthRepositoryImpl.loginWithKakao(kakaoAccessToken)
  → Dio: POST /auth/kakao-login {provider_token: kakaoAccessToken}
  → 서버: JWT {access_token, refresh_token, is_new_user} 반환
  → SecureStorage에 저장
  → AuthState 업데이트 (isLoggedIn: true)
  → GET /user/me → 프로필 조회
```

---

## 8. 자주 발생하는 문제 & 해결

| # | 문제 | 원인 | 해결 |
|---|---|---|---|
| 1 | 홈 화면 빈 목록 | API 호출 실패 또는 파싱 에러 | Dio 로그에서 Response 확인 |
| 2 | 이미지 placeholder 아이콘만 표시 | imageUrl null 또는 이미지 디코딩 실패 | `[Home]`/`[VehicleCard]` 로그 확인 |
| 3 | 이미지 `Invalid image data` | SVG 반환 (placehold.co 기본값) | URL에 `.png` 추가 |
| 4 | 카카오 로그인 keyHash 에러 | 키 해시 미등록 또는 앱 키 불일치 | `[Kakao] keyHash:` 출력값 확인 |
| 5 | 모든 API 401 | 토큰 만료 + refresh 실패 | 앱 데이터 삭제 후 재시작 |
| 6 | onboard 500 | 서버 DB 마이그레이션 미적용 | `make migrate-up` |
| 7 | 마이그레이션 적용 안 됨 | 파일 수정 후 재실행 시도 | 새 번호로 마이그레이션 생성 |
| 8 | 가격 0만원 표시 | price 단위 불일치 (원 vs 만원) | API는 원 단위, formattedPrice가 만원 변환 |
| 9 | specs 관련 null 에러 | Car API에 power/torque 없음 | `vehicle.specs?.field ?? fallback` |
| 10 | hot restart 후 변경 반영 안 됨 | AndroidManifest/gradle 변경 | `flutter run` 재실행 (full restart) |
