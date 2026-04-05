# Go API Integration — Flutter Client 설계

> 날짜: 2026-04-05
> 범위: Auth + Cars/Brands + Chat 세션 영속화 + MyCar + APK 빌드

---

## 1. 배경

v0.1 MVP Flutter UI 완료 상태. 모든 Repository가 목업 데이터 사용 중.
Go 백엔드(http://18.191.163.53:8080)에 실제 API 연동하여 v0.2 완성.

### 동작 확인된 API

| 엔드포인트 | Auth | 데이터 |
|---|---|---|
| `GET /api/v1/brands` | X | Hyundai 1건 |
| `GET /api/v1/cars` | X | Avante Smart 1건 (시드) |
| `GET /api/v1/cars/{id}` | X | 상세 + images 포함 |
| `GET /api/v1/cars/{id}/images` | X | 이미지 1건 |
| `POST /api/v1/auth/onboard` | X | 디바이스 등록 + 토큰 발급 |
| `POST /api/v1/auth/kakao-login` | O (Bearer) | 카카오 토큰 → JWT |
| `POST /api/v1/auth/refresh` | X | 토큰 갱신 |
| `POST /api/v1/user/logout` | O | 로그아웃 |
| `GET /api/v1/user/me` | O | 프로필 조회 |
| `POST /api/v1/chat/sessions` | O | 세션 생성 |
| `GET /api/v1/chat/sessions` | O | 세션 목록 |
| `DELETE /api/v1/chat/sessions/{id}` | O | 세션 삭제 |
| `POST /api/v1/chat/sessions/{id}/messages` | O | 메시지 저장 |
| `GET /api/v1/chat/sessions/{id}/messages` | O | 메시지 조회 |
| `POST /api/v1/cars/register` | X* | 내 차량 등록 |
| `GET /api/v1/cars/register/{user_id}` | X* | 내 차량 조회 |

### 미동작 API (이번 범위 제외)

- `/api/v1/vehicles/*` — DB 테이블 미생성 (vehicles_trims, vehicles_brands)
- `/api/v1/estimates` — vehicles_trims 의존

---

## 2. 도메인 모델 설계

### 핵심 원칙

- **리네이밍 없음** — 기존 Vehicle 엔티티 유지, DTO/Mapper로 백엔드 매핑 흡수
- **카탈로그 vs 사용자 분리** — Car API는 카탈로그(public), MyCar/Bookmark/ConsultationCard는 사용자 연관

### 엔티티 맵

```
카탈로그 (Public, no user_id):
  GET /cars → CarDto → CarMapper → Vehicle (기존 엔티티, 필드 확장)
  GET /brands → BrandDto → Brand (신규)

사용자 연관 (user_id 있음):
  /cars/register → MyCarDto → MyCarMapper → MyCar (신규)
  ConsultationCard → 기존 유지 (vehicleId로 Vehicle 참조)
  Bookmark → 기존 유지 (vehicleId로 Vehicle 참조, Drift 로컬)

인증:
  /auth/onboard → OnboardingDto → AuthTokens (기존)
  /auth/kakao-login → SocialLoginDto → AuthTokens + User
  /auth/refresh → RefreshDto → AuthTokens

채팅:
  /chat/sessions → ChatSessionDto → ChatSession (신규, 로컬 sessionId 대체)
  /chat/sessions/{id}/messages → ChatMessageDto → ChatMessage (기존, 필드 확장)
```

### Vehicle 엔티티 변경 (필드 확장만, 리네이밍 없음)

```dart
// 현재
Vehicle(id, brand, model, year, price, fuelType, imageUrl, specs)

// 변경 후
Vehicle(
  id, brand, model, year, price, fuelType, imageUrl,
  trimName,           // 추가: API trim_name
  transmission,       // 추가: API transmission
  engineDisplacement, // 추가: API engine_displacement
  fuelEfficiency,     // specs에서 Vehicle 레벨로 이동 (API flat 구조)
  status,             // 추가: API status
  modelId,            // 추가: API model_id
  images,             // 추가: 상세 조회 시 이미지 목록
  specs,              // nullable로 변경 (Car API에는 power/torque/zeroToHundred 없음)
)
```

### 신규 엔티티

```dart
// Brand
Brand(id, name)

// MyCar
MyCar(id, userId, licensePlate, brand, model, year, fuelType, createdAt)

// ChatSession (신규 — 백엔드 세션 관리용)
ChatSession(id, title, createdAt, updatedAt)
```

### ChatMessage 변경

```dart
// 현재
ChatMessage(id, role, content, createdAt, sessionId)

// 변경 후 — feedback 필드 추가
ChatMessage(id, role, content, createdAt, sessionId, feedback)
```

---

## 3. 인증 흐름

### 온보딩 (앱 최초 실행)

```
앱 시작 → SecureStorage에 토큰 있는지 확인
  → 없음: POST /auth/onboard (device_id, device_type)
    → access_token + refresh_token 저장
    → guest 상태로 앱 진입
  → 있음: 토큰 유효성 검증 → 만료 시 /auth/refresh
```

### 카카오 로그인 (사용자 선택 시)

```
사용자 "카카오 로그인" 탭
  → KakaoSdk.login() → 카카오 access_token 획득
  → POST /auth/kakao-login (Authorization: Bearer {onboard_token})
    body: { provider_token: kakao_access_token }
  → 서버 응답: { access_token, refresh_token, is_new_user }
  → SecureStorage에 새 토큰 저장
  → AuthState 업데이트 (isLoggedIn: true, provider: 'kakao')
```

### Dio AuthInterceptor

```
모든 요청 전:
  → SecureStorage에서 access_token 읽기
  → Authorization: Bearer {access_token} 헤더 주입

401 응답 시:
  → POST /auth/refresh (refresh_token)
  → 성공: 새 토큰 저장 → 원래 요청 재시도
  → 실패: 로그아웃 처리 → 온보딩 화면
```

---

## 4. API Constants 수정

```dart
abstract final class ApiConstants {
  static String get baseUrl =>
    dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

  // Auth
  static const String onboard = '/api/v1/auth/onboard';
  static const String onboardRefresh = '/api/v1/auth/onboard/refresh';
  static const String kakaoLogin = '/api/v1/auth/kakao-login';
  static const String googleLogin = '/api/v1/auth/google-login';
  static const String appleLogin = '/api/v1/auth/apple-login';
  static const String refresh = '/api/v1/auth/refresh';
  static const String marketingConsent = '/api/v1/auth/agreed';

  // User
  static const String logout = '/api/v1/user/logout';
  static const String profile = '/api/v1/user/me';
  static const String deleteAccount = '/api/v1/user/me';

  // Cars (카탈로그)
  static const String cars = '/api/v1/cars';
  static String carDetail(String id) => '/api/v1/cars/$id';
  static String carImages(String id) => '/api/v1/cars/$id/images';

  // Brands
  static const String brands = '/api/v1/brands';

  // MyCar
  static const String registerCar = '/api/v1/cars/register';
  static String myCars(String userId) => '/api/v1/cars/register/$userId';

  // Chat
  static const String chatSessions = '/api/v1/chat/sessions';
  static String chatSession(String id) => '/api/v1/chat/sessions/$id';
  static String chatMessages(String sessionId) =>
    '/api/v1/chat/sessions/$sessionId/messages';
  static String chatFeedback(String messageId) =>
    '/api/v1/chat/messages/$messageId/feedback';
}
```

---

## 5. DTO 설계 (data/dto/)

### CarDto — /cars API 응답 그대로

```dart
@JsonSerializable(fieldRename: FieldRename.snake)
class CarDto {
  final String id;
  final String modelId;
  final String brandName;
  final String modelName;
  final String? trimName;
  final int year;
  final int price;
  final String? fuelType;
  final double? fuelEfficiency;
  final String? transmission;
  final int? engineDisplacement;
  final String? status;
  final String? thumbnailUrl;
}
```

### CarListResponseDto — 페이지네이션 래퍼

```dart
@JsonSerializable(fieldRename: FieldRename.snake)
class CarListResponseDto {
  final List<CarDto> items;
  final int page;
  final int size;
  final int total;
}
```

### CarDetailDto — 상세 조회 (이미지 포함)

```dart
@JsonSerializable(fieldRename: FieldRename.snake)
class CarDetailDto extends CarDto {
  final List<CarImageDto>? images;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CarImageDto {
  final String id;
  final String carId;
  final String imageUrl;
  final bool isThumbnail;
  final int sortOrder;
}
```

### Auth DTOs

```dart
@JsonSerializable(fieldRename: FieldRename.snake)
class OnboardingRequestDto {
  final String deviceId;
  final String deviceType; // "ios" | "android"
  final String? modelName;
  final String? osVersion;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SocialLoginRequestDto {
  final String providerToken;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TokenResponseDto {
  final String accessToken;
  final String refreshToken;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SocialTokenResponseDto extends TokenResponseDto {
  final bool isNewUser;
}
```

### API 공통 응답 래퍼

```dart
@JsonSerializable()
class ApiResponse<T> {
  final int status;
  final String code;
  final String? message;
  final T? data;
}
```

### Chat DTOs

```dart
@JsonSerializable(fieldRename: FieldRename.snake)
class ChatSessionDto {
  final String id;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ChatMessageDto {
  final String id;
  final String sessionId;
  final String role;
  final String content;
  final String? metadata;
  final String? feedback;
  final DateTime createdAt;
}
```

### MyCar DTOs

```dart
@JsonSerializable(fieldRename: FieldRename.snake)
class RegisterMyCarRequestDto {
  final String userId;
  final String licensePlate;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MyCarDto {
  final String id;
  final String userId;
  final String licensePlate;
  final String? brand;
  final String? model;
  final int? year;
  final String? fuelType;
  final DateTime createdAt;
}
```

---

## 6. Mapper 설계 (data/mappers/)

### CarMapper

```dart
abstract final class CarMapper {
  /// CarDto (API) → Vehicle (domain)
  static Vehicle fromDto(CarDto dto) => Vehicle(
    id: dto.id,
    brand: dto.brandName,
    model: dto.modelName,
    year: dto.year,
    price: dto.price,
    fuelType: dto.fuelType ?? '',
    imageUrl: dto.thumbnailUrl,
    trimName: dto.trimName,
    transmission: dto.transmission,
    engineDisplacement: dto.engineDisplacement,
    fuelEfficiency: dto.fuelEfficiency,
    status: dto.status,
    modelId: dto.modelId,
  );

  /// CarDetailDto → Vehicle (with images)
  static Vehicle fromDetailDto(CarDetailDto dto) => fromDto(dto).copyWith(
    images: dto.images?.map(CarImageMapper.fromDto).toList(),
  );
}
```

### MyCarMapper, ChatSessionMapper, ChatMessageMapper — 동일 패턴

---

## 7. Repository 변경

### IVehicleRepository (수정)

```dart
abstract interface class IVehicleRepository {
  Future<List<Vehicle>> getAllVehicles({int page = 1, int size = 20});
  Future<List<Vehicle>> searchVehicles(String query, {int page = 1, int size = 20});
  Future<Vehicle?> getVehicleById(String id);
  Future<List<Brand>> getBrands();
}
```

### IAuthRepository (수정)

```dart
abstract interface class IAuthRepository {
  Future<AuthTokens> onboard({required String deviceId, required String deviceType});
  Future<({AuthTokens tokens, bool isNewUser})> loginWithKakao(String kakaoAccessToken);
  Future<AuthTokens> refresh(String refreshToken);
  Future<void> logout();
  Future<User> getProfile();
}
```

### IChatRepository (수정)

```dart
abstract class IChatRepository {
  // AI 응답 (로컬 키워드 매칭 유지)
  Future<String> getResponse(String userMessage);

  // 세션 관리 (백엔드 연동)
  Future<ChatSession> createSession({String? title});
  Future<List<ChatSession>> getSessions();
  Future<void> deleteSession(String sessionId);

  // 메시지 (백엔드 영속화)
  Future<ChatMessage> saveMessage(String sessionId, ChatMessage message);
  Future<List<ChatMessage>> loadMessages(String sessionId);
}
```

### IMyCarRepository (신규)

```dart
abstract interface class IMyCarRepository {
  Future<MyCar> registerCar({required String userId, required String licensePlate});
  Future<List<MyCar>> getMyCars(String userId);
}
```

---

## 8. 플랫폼 설정 (카카오 로그인)

### 현재 상태

- .env: KAKAO_NATIVE_APP_KEY=8ee89d78fe4ba172d98b621c643929c4 (완료)
- main.dart: KakaoSdk.init() (완료)

### 필요한 설정

#### Android — AndroidManifest.xml

```xml
<activity
    android:name="com.kakao.sdk.flutter.AuthCodeCustomTabsActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="kakao8ee89d78fe4ba172d98b621c643929c4"
              android:host="oauth" />
    </intent-filter>
</activity>
```

#### iOS — Info.plist

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>kakao8ee89d78fe4ba172d98b621c643929c4</string>
        </array>
    </dict>
</array>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>kakaokompassauth</string>
    <string>kakaolink</string>
    <string>kakaoplus</string>
</array>
```

---

## 9. 변경 금지 영역

- `lib/core/theme/` — 디자인 토큰
- `lib/core/constants/` 중 api_constants.dart 외 파일
- `lib/data/datasources/local/` — Drift 테이블 구조 (BookmarkTable.vehicleId 유지)
- `backend/` — 백엔드 코드 수정 금지 (백엔드 팀 관리)

---

## 10. 파일 변경 목록

### 신규 파일 (~18개)

```
data/dto/
  car_dto.dart, car_image_dto.dart, car_list_response_dto.dart
  brand_dto.dart
  auth_dto.dart (onboarding, social_login, token_response)
  chat_session_dto.dart, chat_message_dto.dart
  my_car_dto.dart
  api_response.dart (공통 래퍼)

data/mappers/
  car_mapper.dart
  my_car_mapper.dart
  chat_session_mapper.dart (신규)

domain/entities/
  brand.dart (신규)
  my_car.dart (신규)
  chat_session.dart (신규)

domain/repositories/
  i_my_car_repository.dart (신규)

data/repositories/go_api/
  my_car_repository_impl.dart (신규)
data/repositories/supabase/
  my_car_repository_impl.dart (신규, UnimplementedError 스텁)
```

### 수정 파일 (~12개)

```
domain/entities/vehicle.dart — 필드 확장 (trimName, transmission 등)
domain/entities/chat_message.dart — feedback 필드 추가
domain/repositories/i_vehicle_repository.dart — 페이지네이션, getBrands() 추가
domain/repositories/i_auth_repository.dart — onboard, loginWithKakao 시그니처 수정
domain/repositories/i_chat_repository.dart — 세션 CRUD 메서드 추가
core/constants/api_constants.dart — 백엔드 실제 경로로 수정
core/providers/dio_provider.dart — AuthInterceptor 구현
core/providers/repository_providers.dart — 신규 provider 등록
core/providers/auth_provider.dart — 실제 인증 로직
data/repositories/go_api/vehicle_repository_impl.dart — 목업 → Dio 호출
data/repositories/go_api/chat_repository_impl.dart — 세션 API 연동
android/app/src/main/AndroidManifest.xml — 카카오 스킴
ios/Runner/Info.plist — 카카오 스킴
```

### Presentation 변경 (최소)

```
변경 없음 예상 — Vehicle 엔티티 이름 유지, provider 이름 유지
단, Vehicle 필드 추가로 인해 UI에서 새 필드 표시 시 일부 수정 가능
```
