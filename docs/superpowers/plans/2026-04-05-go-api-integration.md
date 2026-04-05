# Go API Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Flutter 앱을 Go 백엔드(http://18.191.163.53:8080)에 연동 — Auth, Cars/Brands, Chat 세션, MyCar

**Architecture:** Vehicle 리네이밍 없이 CarDto/Mapper로 API 매핑 흡수. 기존 키워드 매칭 AI 응답 유지, 세션/메시지만 백엔드 영속화. 온보딩(device_id) → guest 토큰 → 카카오 소셜 로그인 2단계 인증.

**Tech Stack:** Flutter 3.22+, Riverpod 3, Dio 5, Freezed 3, GoRouter 17, kakao_flutter_sdk 1.9

**Spec:** `docs/superpowers/specs/2026-04-05-go-api-integration-design.md`

**변경 금지:** `lib/core/theme/`, `lib/data/datasources/local/` (Drift 테이블), `backend/`

---

### Task 1: Entities 확장 + ApiConstants 업데이트

**Files:**
- Modify: `flutter_app/lib/domain/entities/vehicle.dart`
- Modify: `flutter_app/lib/domain/entities/chat_message.dart`
- Modify: `flutter_app/lib/core/constants/api_constants.dart`
- Create: `flutter_app/lib/domain/entities/brand.dart`
- Create: `flutter_app/lib/domain/entities/my_car.dart`
- Create: `flutter_app/lib/domain/entities/chat_session.dart`
- Create: `flutter_app/lib/domain/entities/vehicle_image.dart`

- [ ] **Step 1: Update ApiConstants — 백엔드 실제 경로로 교체**

`flutter_app/lib/core/constants/api_constants.dart` 전체를 아래로 교체:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

- [ ] **Step 2: Create VehicleImage entity**

Create `flutter_app/lib/domain/entities/vehicle_image.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_image.freezed.dart';
part 'vehicle_image.g.dart';

/// 차량 이미지
@freezed
abstract class VehicleImage with _$VehicleImage {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory VehicleImage({
    required String id,
    required String imageUrl,
    @Default(false) bool isThumbnail,
    @Default(0) int sortOrder,
  }) = _VehicleImage;

  factory VehicleImage.fromJson(Map<String, dynamic> json) =>
      _$VehicleImageFromJson(json);
}
```

- [ ] **Step 3: Update Vehicle entity — nullable 필드 추가**

`flutter_app/lib/domain/entities/vehicle.dart` 전체를 아래로 교체:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aicar/domain/entities/vehicle_image.dart';

part 'vehicle.freezed.dart';
part 'vehicle.g.dart';

/// 차량 정보 엔티티 — 홈 탐색, 차량 스펙 중심
@freezed
abstract class Vehicle with _$Vehicle {
  const Vehicle._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Vehicle({
    required String id,
    required String brand,
    required String model,
    required int year,

    /// 가격 (원 단위 — API 기준)
    required int price,
    required String fuelType,
    String? imageUrl,

    // --- 추가 필드 (nullable, CardCacheTable JSON 호환) ---
    String? trimName,
    String? transmission,
    int? engineDisplacement,
    double? fuelEfficiency,
    String? status,
    String? modelId,
    List<VehicleImage>? images,

    // specs → nullable (Car API에는 power/torque/zeroToHundred 없음)
    VehicleSpecs? specs,
  }) = _Vehicle;

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);

  /// 가격 포맷 (예: "2,300만원")
  String get formattedPrice {
    final inManwon = price ~/ 10000;
    final formatted = inManwon.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '$formatted만원';
  }
}

/// 차량 스펙
@freezed
abstract class VehicleSpecs with _$VehicleSpecs {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory VehicleSpecs({
    /// 마력
    required int power,

    /// 토크 (kgm)
    required double torque,

    /// 연비 (km/L)
    required double fuelEfficiency,

    /// 제로백 (초)
    required double zeroToHundred,
  }) = _VehicleSpecs;

  factory VehicleSpecs.fromJson(Map<String, dynamic> json) =>
      _$VehicleSpecsFromJson(json);
}
```

**주의:** `specs`가 `required` → nullable로 변경됨. `price`는 이제 원 단위(API 기준 23000000)이므로 `formattedPrice`도 만원으로 변환하도록 수정. 기존 목업에서 `specs`를 필수로 사용하던 곳은 Task 4에서 수정.

- [ ] **Step 4: Update ChatMessage — feedback 필드 추가**

`flutter_app/lib/domain/entities/chat_message.dart` 전체를 아래로 교체:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';

/// 챗 메시지 역할
enum ChatRole { user, assistant }

/// AI 상담 채팅 메시지 엔티티
@freezed
abstract class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  const factory ChatMessage({
    required String id,
    required ChatRole role,
    required String content,
    required DateTime createdAt,
    String? sessionId,
    String? feedback,
  }) = _ChatMessage;

  bool get isUser => role == ChatRole.user;
  bool get isAssistant => role == ChatRole.assistant;
}
```

- [ ] **Step 5: Create Brand entity**

Create `flutter_app/lib/domain/entities/brand.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'brand.freezed.dart';
part 'brand.g.dart';

/// 브랜드 엔티티
@freezed
abstract class Brand with _$Brand {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Brand({
    required String id,
    required String name,
  }) = _Brand;

  factory Brand.fromJson(Map<String, dynamic> json) => _$BrandFromJson(json);
}
```

- [ ] **Step 6: Create MyCar entity**

Create `flutter_app/lib/domain/entities/my_car.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_car.freezed.dart';
part 'my_car.g.dart';

/// 사용자 등록 차량 (내 차고)
@freezed
abstract class MyCar with _$MyCar {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MyCar({
    required String id,
    required String userId,
    required String licensePlate,
    String? brand,
    String? model,
    int? year,
    String? fuelType,
    required DateTime createdAt,
  }) = _MyCar;

  factory MyCar.fromJson(Map<String, dynamic> json) => _$MyCarFromJson(json);
}
```

- [ ] **Step 7: Create ChatSession entity**

Create `flutter_app/lib/domain/entities/chat_session.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_session.freezed.dart';
part 'chat_session.g.dart';

/// 채팅 세션 (백엔드 연동)
@freezed
abstract class ChatSession with _$ChatSession {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ChatSession({
    required String id,
    String? title,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ChatSession;

  factory ChatSession.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionFromJson(json);
}
```

- [ ] **Step 8: Run build_runner**

```bash
cd /Users/lims/AiCar/flutter_app && dart run build_runner build --delete-conflicting-outputs
```

Expected: 생성 파일 출력, 0 errors. vehicle.freezed.dart, vehicle.g.dart 등 재생성.

- [ ] **Step 9: flutter analyze**

```bash
cd /Users/lims/AiCar/flutter_app && flutter analyze
```

Expected: `specs` 필수→nullable 변경으로 기존 목업 코드에서 경고/에러 발생 가능. Task 4에서 해결 예정이므로 여기서는 entity/dto 관련 에러만 0인지 확인.

- [ ] **Step 10: Commit**

```bash
cd /Users/lims/AiCar/flutter_app && git add lib/domain/entities/ lib/core/constants/api_constants.dart && git commit -m "feat(flutter): Vehicle 필드 확장 + Brand/MyCar/ChatSession 엔티티 + ApiConstants 업데이트"
```

---

### Task 2: DTOs + Mappers

**Files:**
- Create: `flutter_app/lib/data/dto/car_dto.dart`
- Create: `flutter_app/lib/data/dto/auth_dto.dart`
- Create: `flutter_app/lib/data/dto/chat_dto.dart`
- Create: `flutter_app/lib/data/dto/my_car_dto.dart`
- Create: `flutter_app/lib/data/mappers/car_mapper.dart`
- Create: `flutter_app/lib/data/mappers/my_car_mapper.dart`
- Create: `flutter_app/lib/data/mappers/chat_session_mapper.dart`

- [ ] **Step 1: Create car_dto.dart**

Create `flutter_app/lib/data/dto/car_dto.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'car_dto.g.dart';

/// /cars 목록 응답 아이템
@JsonSerializable(fieldRename: FieldRename.snake)
class CarDto {
  const CarDto({
    required this.id,
    required this.modelId,
    required this.brandName,
    required this.modelName,
    this.trimName,
    required this.year,
    required this.price,
    this.fuelType,
    this.fuelEfficiency,
    this.transmission,
    this.engineDisplacement,
    this.status,
    this.thumbnailUrl,
  });

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

  factory CarDto.fromJson(Map<String, dynamic> json) => _$CarDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CarDtoToJson(this);
}

/// /cars/{id} 상세 응답 — 이미지 포함
@JsonSerializable(fieldRename: FieldRename.snake)
class CarDetailDto {
  const CarDetailDto({
    required this.id,
    required this.modelId,
    required this.brandName,
    required this.modelName,
    this.trimName,
    required this.year,
    required this.price,
    this.fuelType,
    this.fuelEfficiency,
    this.transmission,
    this.engineDisplacement,
    this.status,
    this.thumbnailUrl,
    this.images,
  });

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
  final List<CarImageDto>? images;

  factory CarDetailDto.fromJson(Map<String, dynamic> json) =>
      _$CarDetailDtoFromJson(json);
}

/// 차량 이미지 DTO
@JsonSerializable(fieldRename: FieldRename.snake)
class CarImageDto {
  const CarImageDto({
    required this.id,
    required this.carId,
    required this.imageUrl,
    this.isThumbnail = false,
    this.sortOrder = 0,
  });

  final String id;
  final String carId;
  final String imageUrl;
  final bool isThumbnail;
  final int sortOrder;

  factory CarImageDto.fromJson(Map<String, dynamic> json) =>
      _$CarImageDtoFromJson(json);
}

/// /brands 응답 아이템
@JsonSerializable(fieldRename: FieldRename.snake)
class BrandDto {
  const BrandDto({required this.id, required this.name});

  final String id;
  final String name;

  factory BrandDto.fromJson(Map<String, dynamic> json) =>
      _$BrandDtoFromJson(json);
}
```

- [ ] **Step 2: Create auth_dto.dart**

Create `flutter_app/lib/data/dto/auth_dto.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'auth_dto.g.dart';

/// POST /auth/onboard 요청
@JsonSerializable(fieldRename: FieldRename.snake)
class OnboardingRequestDto {
  const OnboardingRequestDto({
    required this.deviceId,
    required this.deviceType,
    this.modelName,
    this.osVersion,
  });

  final String deviceId;
  final String deviceType;
  final String? modelName;
  final String? osVersion;

  Map<String, dynamic> toJson() => _$OnboardingRequestDtoToJson(this);
}

/// POST /auth/kakao-login 요청
@JsonSerializable(fieldRename: FieldRename.snake)
class SocialLoginRequestDto {
  const SocialLoginRequestDto({required this.providerToken});

  final String providerToken;

  Map<String, dynamic> toJson() => _$SocialLoginRequestDtoToJson(this);
}

/// POST /auth/refresh 요청
@JsonSerializable(fieldRename: FieldRename.snake)
class RefreshRequestDto {
  const RefreshRequestDto({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() => _$RefreshRequestDtoToJson(this);
}

/// 토큰 응답 (onboard, refresh)
@JsonSerializable(fieldRename: FieldRename.snake)
class TokenResponseDto {
  const TokenResponseDto({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory TokenResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseDtoFromJson(json);
}

/// 소셜 로그인 토큰 응답
@JsonSerializable(fieldRename: FieldRename.snake)
class SocialTokenResponseDto {
  const SocialTokenResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.isNewUser,
  });

  final String accessToken;
  final String refreshToken;
  final bool isNewUser;

  factory SocialTokenResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SocialTokenResponseDtoFromJson(json);
}

/// GET /user/me 응답
@JsonSerializable(fieldRename: FieldRename.snake)
class UserProfileDto {
  const UserProfileDto({
    required this.id,
    this.name,
    this.email,
    this.profileUrl,
    this.status,
  });

  final String id;
  final String? name;
  final String? email;
  final String? profileUrl;
  final String? status;

  factory UserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDtoFromJson(json);
}
```

- [ ] **Step 3: Create chat_dto.dart**

Create `flutter_app/lib/data/dto/chat_dto.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'chat_dto.g.dart';

/// 채팅 세션 응답
@JsonSerializable(fieldRename: FieldRename.snake)
class ChatSessionDto {
  const ChatSessionDto({
    required this.id,
    this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ChatSessionDto.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionDtoFromJson(json);
}

/// 채팅 메시지 응답
@JsonSerializable(fieldRename: FieldRename.snake)
class ChatMessageDto {
  const ChatMessageDto({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.metadata,
    this.feedback,
    required this.createdAt,
  });

  final String id;
  final String sessionId;
  final String role;
  final String content;
  final String? metadata;
  final String? feedback;
  final DateTime createdAt;

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageDtoFromJson(json);
}

/// 세션 생성 요청
@JsonSerializable(fieldRename: FieldRename.snake)
class CreateSessionRequestDto {
  const CreateSessionRequestDto({this.title});

  final String? title;

  Map<String, dynamic> toJson() => _$CreateSessionRequestDtoToJson(this);
}

/// 메시지 생성 요청
@JsonSerializable(fieldRename: FieldRename.snake)
class CreateMessageRequestDto {
  const CreateMessageRequestDto({
    required this.role,
    required this.content,
    this.metadata,
  });

  final String role;
  final String content;
  final String? metadata;

  Map<String, dynamic> toJson() => _$CreateMessageRequestDtoToJson(this);
}
```

- [ ] **Step 4: Create my_car_dto.dart**

Create `flutter_app/lib/data/dto/my_car_dto.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'my_car_dto.g.dart';

/// POST /cars/register 요청
@JsonSerializable(fieldRename: FieldRename.snake)
class RegisterMyCarRequestDto {
  const RegisterMyCarRequestDto({
    required this.userId,
    required this.licensePlate,
  });

  final String userId;
  final String licensePlate;

  Map<String, dynamic> toJson() => _$RegisterMyCarRequestDtoToJson(this);
}

/// 내 차량 응답
@JsonSerializable(fieldRename: FieldRename.snake)
class MyCarDto {
  const MyCarDto({
    required this.id,
    required this.userId,
    required this.licensePlate,
    this.brand,
    this.model,
    this.year,
    this.fuelType,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String licensePlate;
  final String? brand;
  final String? model;
  final int? year;
  final String? fuelType;
  final DateTime createdAt;

  factory MyCarDto.fromJson(Map<String, dynamic> json) =>
      _$MyCarDtoFromJson(json);
}
```

- [ ] **Step 5: Create car_mapper.dart**

Create `flutter_app/lib/data/mappers/car_mapper.dart`:

```dart
import 'package:aicar/data/dto/car_dto.dart';
import 'package:aicar/domain/entities/brand.dart';
import 'package:aicar/domain/entities/vehicle.dart';
import 'package:aicar/domain/entities/vehicle_image.dart';

/// CarDto (API) → Vehicle (domain) 변환
///
/// 데이터 흐름: GET /cars → JSON → CarDto → CarMapper → Vehicle
abstract final class CarMapper {
  /// 목록 아이템 변환
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

  /// 상세 응답 변환 (이미지 포함)
  static Vehicle fromDetailDto(CarDetailDto dto) => Vehicle(
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
        images: dto.images
            ?.map((img) => VehicleImage(
                  id: img.id,
                  imageUrl: img.imageUrl,
                  isThumbnail: img.isThumbnail,
                  sortOrder: img.sortOrder,
                ))
            .toList(),
      );

  /// BrandDto → Brand
  static Brand brandFromDto(BrandDto dto) => Brand(
        id: dto.id,
        name: dto.name,
      );
}
```

- [ ] **Step 6: Create my_car_mapper.dart**

Create `flutter_app/lib/data/mappers/my_car_mapper.dart`:

```dart
import 'package:aicar/data/dto/my_car_dto.dart';
import 'package:aicar/domain/entities/my_car.dart';

/// MyCarDto (API) → MyCar (domain) 변환
abstract final class MyCarMapper {
  static MyCar fromDto(MyCarDto dto) => MyCar(
        id: dto.id,
        userId: dto.userId,
        licensePlate: dto.licensePlate,
        brand: dto.brand,
        model: dto.model,
        year: dto.year,
        fuelType: dto.fuelType,
        createdAt: dto.createdAt,
      );
}
```

- [ ] **Step 7: Create chat_session_mapper.dart**

Create `flutter_app/lib/data/mappers/chat_session_mapper.dart`:

```dart
import 'package:aicar/data/dto/chat_dto.dart';
import 'package:aicar/domain/entities/chat_message.dart';
import 'package:aicar/domain/entities/chat_session.dart';

/// Chat DTO → Domain 변환
abstract final class ChatApiMapper {
  /// ChatSessionDto → ChatSession
  static ChatSession sessionFromDto(ChatSessionDto dto) => ChatSession(
        id: dto.id,
        title: dto.title,
        createdAt: dto.createdAt,
        updatedAt: dto.updatedAt,
      );

  /// ChatMessageDto → ChatMessage
  static ChatMessage messageFromDto(ChatMessageDto dto) => ChatMessage(
        id: dto.id,
        role: dto.role == 'user' ? ChatRole.user : ChatRole.assistant,
        content: dto.content,
        createdAt: dto.createdAt,
        sessionId: dto.sessionId,
        feedback: dto.feedback,
      );
}
```

- [ ] **Step 8: Run build_runner**

```bash
cd /Users/lims/AiCar/flutter_app && dart run build_runner build --delete-conflicting-outputs
```

Expected: DTO .g.dart 파일 생성, 0 errors.

- [ ] **Step 9: flutter analyze**

```bash
cd /Users/lims/AiCar/flutter_app && flutter analyze
```

Expected: DTO/mapper 관련 에러 0. Vehicle.specs 필수→nullable 변경으로 기존 목업 코드에서 에러 발생 가능 — Task 4에서 해결.

- [ ] **Step 10: Commit**

```bash
cd /Users/lims/AiCar/flutter_app && git add lib/data/dto/ lib/data/mappers/ && git commit -m "feat(flutter): CarDto/AuthDto/ChatDto/MyCarDto + 매퍼 추가"
```

---

### Task 3: Repository 인터페이스 업데이트

**Files:**
- Modify: `flutter_app/lib/domain/repositories/i_vehicle_repository.dart`
- Modify: `flutter_app/lib/domain/repositories/i_auth_repository.dart`
- Modify: `flutter_app/lib/domain/repositories/i_chat_repository.dart`
- Create: `flutter_app/lib/domain/repositories/i_my_car_repository.dart`

- [ ] **Step 1: Update IVehicleRepository — 페이지네이션 + getBrands()**

`flutter_app/lib/domain/repositories/i_vehicle_repository.dart` 전체를 아래로 교체:

```dart
import 'package:aicar/domain/entities/brand.dart';
import 'package:aicar/domain/entities/vehicle.dart';

/// 차량 카탈로그 Repository 인터페이스
///
/// 데이터 소스: GET /api/v1/cars, GET /api/v1/brands
abstract class IVehicleRepository {
  /// 차량 목록 (페이지네이션)
  Future<List<Vehicle>> getAllVehicles({int page = 1, int size = 20});

  /// 키워드 기반 차량 검색
  Future<List<Vehicle>> searchVehicles(String query, {int page = 1, int size = 20});

  /// ID로 차량 단건 조회 (이미지 포함)
  Future<Vehicle?> getVehicleById(String id);

  /// 브랜드 목록 조회
  Future<List<Brand>> getBrands();
}
```

- [ ] **Step 2: Update IAuthRepository — 온보딩 + 소셜 로그인**

`flutter_app/lib/domain/repositories/i_auth_repository.dart` 전체를 아래로 교체:

```dart
import 'package:aicar/domain/entities/auth_tokens.dart';
import 'package:aicar/domain/entities/user.dart';

/// 인증 Repository 인터페이스
///
/// 흐름: onboard(device_id) → guest 토큰 → loginWithKakao → 소셜 토큰
abstract interface class IAuthRepository {
  /// 디바이스 온보딩 — guest 토큰 발급
  Future<AuthTokens> onboard({
    required String deviceId,
    required String deviceType,
    String? modelName,
    String? osVersion,
  });

  /// 카카오 소셜 로그인 — 카카오 access_token → 서버 JWT
  Future<({AuthTokens tokens, bool isNewUser})> loginWithKakao(
      String kakaoAccessToken);

  /// 토큰 갱신
  Future<AuthTokens> refresh(String refreshToken);

  /// 로그아웃
  Future<void> logout();

  /// 프로필 조회
  Future<User> getProfile();
}
```

- [ ] **Step 3: Update IChatRepository — 세션 CRUD 추가**

`flutter_app/lib/domain/repositories/i_chat_repository.dart` 전체를 아래로 교체:

```dart
import 'package:aicar/domain/entities/chat_message.dart';
import 'package:aicar/domain/entities/chat_session.dart';

/// AI 상담 채팅 Repository 인터페이스
///
/// AI 응답: 로컬 키워드 매칭 (MVP)
/// 세션/메시지: 백엔드 API 영속화
abstract class IChatRepository {
  /// 사용자 메시지에 대한 AI 응답 (로컬 키워드 매칭)
  Future<String> getResponse(String userMessage);

  // --- 세션 관리 (백엔드) ---

  /// 새 세션 생성
  Future<ChatSession> createSession({String? title});

  /// 세션 목록 조회
  Future<List<ChatSession>> getSessions();

  /// 세션 삭제
  Future<void> deleteSession(String sessionId);

  // --- 메시지 (백엔드 영속화) ---

  /// 메시지 저장 (백엔드 API)
  Future<ChatMessage> saveMessage(String sessionId, ChatMessage message);

  /// 세션별 메시지 로드
  Future<List<ChatMessage>> loadMessages(String sessionId);

  // --- 로컬 (Drift, 하위 호환) ---

  /// 로컬 대화 기록 전체 로드
  Future<List<ChatMessage>> loadHistory();

  /// 로컬 대화 기록 초기화
  Future<void> clearHistory();
}
```

- [ ] **Step 4: Create IMyCarRepository**

Create `flutter_app/lib/domain/repositories/i_my_car_repository.dart`:

```dart
import 'package:aicar/domain/entities/my_car.dart';

/// 내 차량 등록 Repository 인터페이스
///
/// 데이터 소스: POST /api/v1/cars/register, GET /api/v1/cars/register/{user_id}
abstract interface class IMyCarRepository {
  /// 번호판으로 차량 등록
  Future<MyCar> registerCar({
    required String userId,
    required String licensePlate,
  });

  /// 사용자의 등록 차량 목록 조회
  Future<List<MyCar>> getMyCars(String userId);
}
```

- [ ] **Step 5: Commit**

```bash
cd /Users/lims/AiCar/flutter_app && git add lib/domain/repositories/ && git commit -m "feat(flutter): Repository 인터페이스 업데이트 — 페이지네이션, 세션 CRUD, MyCar"
```

**주의:** 이 시점에서 flutter analyze는 실패함 (구현체가 인터페이스와 불일치). Task 4~6에서 해결.

---

### Task 4: Auth 시스템 구현 (플랫폼 + Interceptor + Repository)

**Files:**
- Modify: `flutter_app/android/app/src/main/AndroidManifest.xml`
- Modify: `flutter_app/ios/Runner/Info.plist`
- Modify: `flutter_app/lib/core/providers/dio_provider.dart`
- Modify: `flutter_app/lib/core/providers/auth_provider.dart`
- Modify: `flutter_app/lib/core/providers/repository_providers.dart`
- Create: `flutter_app/lib/data/repositories/go_api/auth_repository_impl.dart`
- Create: `flutter_app/lib/data/repositories/supabase/auth_repository_impl.dart`

- [ ] **Step 1: AndroidManifest.xml — 카카오 OAuth 스킴 등록**

`flutter_app/android/app/src/main/AndroidManifest.xml`의 `</application>` 직전에 추가:

```xml
        <!-- Kakao OAuth redirect -->
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

- [ ] **Step 2: Info.plist — 카카오 URL Scheme 등록**

`flutter_app/ios/Runner/Info.plist`의 `</dict>` (최종) 직전에 추가:

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

- [ ] **Step 3: Update dio_provider.dart — AuthInterceptor 구현**

`flutter_app/lib/core/providers/dio_provider.dart` 전체를 아래로 교체:

```dart
import 'package:aicar/core/constants/api_constants.dart';
import 'package:aicar/core/errors/app_exception.dart';
import 'package:aicar/data/dto/auth_dto.dart';
import 'package:aicar/data/services/secure_storage_service_impl.dart';
import 'package:aicar/domain/services/i_token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// TokenStorage provider — 기존 SecureStorageServiceImpl 재사용
final tokenStorageProvider = Provider<ITokenStorage>((ref) {
  return SecureStorageServiceImpl();
});

/// Dio provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final tokenStorage = ref.read(tokenStorageProvider);

  dio.interceptors.addAll([
    _AuthInterceptor(tokenStorage, dio),
    LogInterceptor(requestBody: true, responseBody: true),
  ]);

  return dio;
});

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._tokenStorage, this._dio);

  final ITokenStorage _tokenStorage;
  final Dio _dio;
  bool _isRefreshing = false;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 || _isRefreshing) {
      handler.next(err);
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        await _tokenStorage.clearAll();
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const UnauthorizedException(),
          ),
        );
        return;
      }

      // 토큰 갱신 시도 — interceptor 우회를 위해 새 Dio 사용
      final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await refreshDio.post(
        ApiConstants.refresh,
        data: RefreshRequestDto(refreshToken: refreshToken).toJson(),
      );

      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;
      final tokens = TokenResponseDto.fromJson(data);

      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      // 원래 요청 재시도
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      final retryResponse = await _dio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } on DioException {
      await _tokenStorage.clearAll();
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const UnauthorizedException(),
        ),
      );
    } finally {
      _isRefreshing = false;
    }
  }
}

```

**주의:** 기존 `SecureStorageServiceImpl`을 재사용하므로 `_LazyTokenStorage` 같은 래퍼 불필요.

- [ ] **Step 4: Create auth_repository_impl.dart (go_api)**

Create `flutter_app/lib/data/repositories/go_api/auth_repository_impl.dart`:

```dart
import 'dart:io';

import 'package:aicar/core/constants/api_constants.dart';
import 'package:aicar/data/dto/auth_dto.dart';
import 'package:aicar/domain/entities/auth_tokens.dart';
import 'package:aicar/domain/entities/user.dart';
import 'package:aicar/domain/repositories/i_auth_repository.dart';
import 'package:aicar/domain/services/i_token_storage.dart';
import 'package:dio/dio.dart';

/// Go API 인증 Repository 구현체
///
/// 데이터 흐름: Flutter → Dio → Go API → JWT 토큰 → SecureStorage
class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl(this._dio, this._tokenStorage);

  final Dio _dio;
  final ITokenStorage _tokenStorage;

  @override
  Future<AuthTokens> onboard({
    required String deviceId,
    required String deviceType,
    String? modelName,
    String? osVersion,
  }) async {
    final request = OnboardingRequestDto(
      deviceId: deviceId,
      deviceType: deviceType,
      modelName: modelName,
      osVersion: osVersion,
    );

    final response = await _dio.post(
      ApiConstants.onboard,
      data: request.toJson(),
    );

    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;
    final tokens = TokenResponseDto.fromJson(data);

    final authTokens = AuthTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );

    await _tokenStorage.saveTokens(
      accessToken: authTokens.accessToken,
      refreshToken: authTokens.refreshToken,
    );

    return authTokens;
  }

  @override
  Future<({AuthTokens tokens, bool isNewUser})> loginWithKakao(
      String kakaoAccessToken) async {
    final request = SocialLoginRequestDto(providerToken: kakaoAccessToken);

    final response = await _dio.post(
      ApiConstants.kakaoLogin,
      data: request.toJson(),
    );

    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;
    final socialResponse = SocialTokenResponseDto.fromJson(data);

    final tokens = AuthTokens(
      accessToken: socialResponse.accessToken,
      refreshToken: socialResponse.refreshToken,
    );

    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );

    return (tokens: tokens, isNewUser: socialResponse.isNewUser);
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    final request = RefreshRequestDto(refreshToken: refreshToken);

    final response = await _dio.post(
      ApiConstants.refresh,
      data: request.toJson(),
    );

    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;
    final tokenResponse = TokenResponseDto.fromJson(data);

    final tokens = AuthTokens(
      accessToken: tokenResponse.accessToken,
      refreshToken: tokenResponse.refreshToken,
    );

    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );

    return tokens;
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } finally {
      await _tokenStorage.clearAll();
    }
  }

  @override
  Future<User> getProfile() async {
    final response = await _dio.get(ApiConstants.profile);

    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;
    final profile = UserProfileDto.fromJson(data);

    return User(
      id: profile.id,
      email: profile.email ?? '',
      nickname: profile.name,
      profileImageUrl: profile.profileUrl,
      createdAt: DateTime.now(),
    );
  }

  /// 디바이스 ID 생성 유틸
  static String generateDeviceId() {
    return '${Platform.isIOS ? 'IOS' : 'ANDROID'}-${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 디바이스 타입 반환
  static String get deviceType => Platform.isIOS ? 'ios' : 'android';
}
```

- [ ] **Step 5: Create auth_repository_impl.dart (supabase stub)**

Create `flutter_app/lib/data/repositories/supabase/auth_repository_impl.dart`:

```dart
import 'package:aicar/domain/entities/auth_tokens.dart';
import 'package:aicar/domain/entities/user.dart';
import 'package:aicar/domain/repositories/i_auth_repository.dart';

/// Supabase 인증 Repository — UnimplementedError 스텁
class AuthRepositoryImpl implements IAuthRepository {
  @override
  Future<AuthTokens> onboard({
    required String deviceId,
    required String deviceType,
    String? modelName,
    String? osVersion,
  }) =>
      throw UnimplementedError('Supabase auth not implemented');

  @override
  Future<({AuthTokens tokens, bool isNewUser})> loginWithKakao(
          String kakaoAccessToken) =>
      throw UnimplementedError('Supabase auth not implemented');

  @override
  Future<AuthTokens> refresh(String refreshToken) =>
      throw UnimplementedError('Supabase auth not implemented');

  @override
  Future<void> logout() =>
      throw UnimplementedError('Supabase auth not implemented');

  @override
  Future<User> getProfile() =>
      throw UnimplementedError('Supabase auth not implemented');
}
```

- [ ] **Step 6: Update auth_provider.dart — 실제 인증 로직**

`flutter_app/lib/core/providers/auth_provider.dart` 전체를 아래로 교체:

```dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

import 'package:aicar/core/providers/dio_provider.dart';
import 'package:aicar/core/providers/repository_providers.dart';

/// 인증 상태
@immutable
class AuthState {
  const AuthState({
    this.isLoggedIn = false,
    this.isGuest = false,
    this.hasConsented = false,
    this.userName,
    this.userId,
    this.provider,
  });

  final bool isLoggedIn;
  final bool isGuest;
  final bool hasConsented;
  final String? userName;
  final String? userId;
  final String? provider;

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isGuest,
    bool? hasConsented,
    String? userName,
    String? userId,
    String? provider,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isGuest: isGuest ?? this.isGuest,
      hasConsented: hasConsented ?? this.hasConsented,
      userName: userName ?? this.userName,
      userId: userId ?? this.userId,
      provider: provider ?? this.provider,
    );
  }
}

/// 인증 상태 관리
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  /// 온보딩 (guest 토큰 발급)
  Future<void> onboard() async {
    final authRepo = ref.read(authRepositoryProvider);
    final tokenStorage = ref.read(tokenStorageProvider);

    // 이미 토큰이 있으면 스킵
    final existing = await tokenStorage.getAccessToken();
    if (existing != null) {
      state = state.copyWith(isGuest: true);
      return;
    }

    final deviceId =
        '${Platform.isIOS ? 'IOS' : 'ANDROID'}-${DateTime.now().millisecondsSinceEpoch}';

    await authRepo.onboard(
      deviceId: deviceId,
      deviceType: Platform.isIOS ? 'ios' : 'android',
    );

    state = state.copyWith(isGuest: true);
  }

  /// 카카오 로그인
  Future<void> loginWithKakao() async {
    final authRepo = ref.read(authRepositoryProvider);

    // 카카오 SDK 로그인
    kakao.OAuthToken kakaoToken;
    if (await kakao.isKakaoTalkInstalled()) {
      kakaoToken = await kakao.UserApi.instance.loginWithKakaoTalk();
    } else {
      kakaoToken = await kakao.UserApi.instance.loginWithKakaoAccount();
    }

    // 백엔드에 카카오 토큰 전송
    final result =
        await authRepo.loginWithKakao(kakaoToken.accessToken);

    state = state.copyWith(
      isLoggedIn: true,
      isGuest: false,
      provider: 'kakao',
    );

    // 프로필 조회
    try {
      final user = await authRepo.getProfile();
      state = state.copyWith(
        userName: user.nickname ?? user.email,
        userId: user.id,
      );
    } catch (_) {
      // 프로필 조회 실패해도 로그인 유지
    }
  }

  /// 약관 동의
  void consent() {
    state = state.copyWith(hasConsented: true);
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.logout();
    } finally {
      state = const AuthState();
    }
  }
}

/// Auth Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
```

- [ ] **Step 7: Update repository_providers.dart — auth provider 추가**

`flutter_app/lib/core/providers/repository_providers.dart`에 auth 관련 provider 추가:

파일 상단 import 추가:
```dart
import 'package:aicar/core/providers/dio_provider.dart';
import 'package:aicar/data/repositories/go_api/auth_repository_impl.dart'
    as go_api_auth;
import 'package:aicar/domain/repositories/i_auth_repository.dart';
```

파일 하단에 추가:
```dart
/// Auth Repository Provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final dio = ref.read(dioProvider);
  final tokenStorage = ref.read(tokenStorageProvider);
  return go_api_auth.AuthRepositoryImpl(dio, tokenStorage);
});
```

- [ ] **Step 8: flutter analyze**

```bash
cd /Users/lims/AiCar/flutter_app && flutter analyze
```

Expected: auth 관련 에러 0. Vehicle/Chat 구현체 불일치 에러는 아직 존재 — Task 5~6에서 해결.

- [ ] **Step 9: Commit**

```bash
cd /Users/lims/AiCar/flutter_app && git add android/ ios/ lib/core/providers/ lib/data/repositories/go_api/auth_repository_impl.dart lib/data/repositories/supabase/auth_repository_impl.dart && git commit -m "feat(flutter): 카카오 로그인 + Dio AuthInterceptor + 온보딩 구현"
```

---

### Task 5: Vehicle/Brand Repository 구현 (목업 → Dio)

**Files:**
- Modify: `flutter_app/lib/data/repositories/go_api/vehicle_repository_impl.dart`
- Modify: `flutter_app/lib/data/repositories/supabase/vehicle_repository_impl.dart`
- Modify: `flutter_app/lib/core/providers/repository_providers.dart`

- [ ] **Step 1: Update vehicle_repository_impl.dart (go_api) — Dio 호출**

`flutter_app/lib/data/repositories/go_api/vehicle_repository_impl.dart` 전체를 아래로 교체:

```dart
import 'package:aicar/core/constants/api_constants.dart';
import 'package:aicar/data/dto/car_dto.dart';
import 'package:aicar/data/mappers/car_mapper.dart';
import 'package:aicar/domain/entities/brand.dart';
import 'package:aicar/domain/entities/vehicle.dart';
import 'package:aicar/domain/repositories/i_vehicle_repository.dart';
import 'package:dio/dio.dart';

/// Go API 차량 Repository 구현체
///
/// 데이터 흐름: GET /cars → JSON → CarDto → CarMapper → Vehicle
class VehicleRepositoryImpl implements IVehicleRepository {
  VehicleRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Vehicle>> getAllVehicles({int page = 1, int size = 20}) async {
    final response = await _dio.get(
      ApiConstants.cars,
      queryParameters: {'page': page, 'size': size},
    );

    final json = response.data as Map<String, dynamic>;
    final items = json['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => CarMapper.fromDto(CarDto.fromJson(e as Map<String, dynamic>)))
        .toList();
  }

  @override
  Future<List<Vehicle>> searchVehicles(
    String query, {
    int page = 1,
    int size = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.cars,
      queryParameters: {'q': query, 'page': page, 'size': size},
    );

    final json = response.data as Map<String, dynamic>;
    final items = json['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => CarMapper.fromDto(CarDto.fromJson(e as Map<String, dynamic>)))
        .toList();
  }

  @override
  Future<Vehicle?> getVehicleById(String id) async {
    try {
      final response = await _dio.get(ApiConstants.carDetail(id));
      final json = response.data as Map<String, dynamic>;
      return CarMapper.fromDetailDto(CarDetailDto.fromJson(json));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<Brand>> getBrands() async {
    final response = await _dio.get(ApiConstants.brands);
    final json = response.data as Map<String, dynamic>;
    final items = json['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => CarMapper.brandFromDto(
            BrandDto.fromJson(e as Map<String, dynamic>)))
        .toList();
  }
}
```

- [ ] **Step 2: Update vehicle_repository_impl.dart (supabase stub)**

`flutter_app/lib/data/repositories/supabase/vehicle_repository_impl.dart` 전체를 아래로 교체:

```dart
import 'package:aicar/domain/entities/brand.dart';
import 'package:aicar/domain/entities/vehicle.dart';
import 'package:aicar/domain/repositories/i_vehicle_repository.dart';

/// Supabase 차량 Repository — UnimplementedError 스텁
class VehicleRepositoryImpl implements IVehicleRepository {
  @override
  Future<List<Vehicle>> getAllVehicles({int page = 1, int size = 20}) =>
      throw UnimplementedError('Supabase vehicle not implemented');

  @override
  Future<List<Vehicle>> searchVehicles(String query,
          {int page = 1, int size = 20}) =>
      throw UnimplementedError('Supabase vehicle not implemented');

  @override
  Future<Vehicle?> getVehicleById(String id) =>
      throw UnimplementedError('Supabase vehicle not implemented');

  @override
  Future<List<Brand>> getBrands() =>
      throw UnimplementedError('Supabase vehicle not implemented');
}
```

- [ ] **Step 3: Update repository_providers.dart — Dio 주입**

`flutter_app/lib/core/providers/repository_providers.dart`의 vehicleRepositoryProvider 수정:

기존:
```dart
final vehicleRepositoryProvider = Provider<IVehicleRepository>((ref) {
  return go_api_vehicle.VehicleRepositoryImpl();
});
```

변경:
```dart
final vehicleRepositoryProvider = Provider<IVehicleRepository>((ref) {
  final dio = ref.read(dioProvider);
  return go_api_vehicle.VehicleRepositoryImpl(dio);
});
```

- [ ] **Step 4: flutter analyze**

```bash
cd /Users/lims/AiCar/flutter_app && flutter analyze
```

Expected: Vehicle/Brand 관련 에러 0. 기존 목업에서 `specs` 필수 사용하던 곳에서 에러 발생 가능 — 해당 파일도 이 단계에서 수정. `VehicleSpecs`를 사용하는 곳을 찾아서 null 체크 추가.

- [ ] **Step 5: 기존 코드 호환성 수정 (specs nullable 대응)**

`vehicle_repository_impl.dart`의 기존 목업이 제거되었으므로, `home_provider.dart` 등에서 `vehicle.specs.fuelEfficiency` 같은 접근이 있다면 `vehicle.specs?.fuelEfficiency ?? vehicle.fuelEfficiency` 로 수정. 또는 `vehicle.fuelEfficiency`를 직접 사용하도록 변경.

해당 파일들을 찾아서 수정 (flutter analyze 출력 참고).

- [ ] **Step 6: Commit**

```bash
cd /Users/lims/AiCar/flutter_app && git add lib/data/repositories/ lib/core/providers/repository_providers.dart && git commit -m "feat(flutter): Vehicle/Brand Repository — 목업 → Go API Dio 연동"
```

---

### Task 6: Chat Repository + MyCar Repository 구현

**Files:**
- Modify: `flutter_app/lib/data/repositories/go_api/chat_repository_impl.dart`
- Modify: `flutter_app/lib/data/repositories/supabase/chat_repository_impl.dart`
- Create: `flutter_app/lib/data/repositories/go_api/my_car_repository_impl.dart`
- Create: `flutter_app/lib/data/repositories/supabase/my_car_repository_impl.dart`
- Modify: `flutter_app/lib/core/providers/repository_providers.dart`

- [ ] **Step 1: Update chat_repository_impl.dart (go_api) — 세션 API 추가**

`flutter_app/lib/data/repositories/go_api/chat_repository_impl.dart` 전체를 아래로 교체:

```dart
import 'package:drift/drift.dart';

import 'package:aicar/core/constants/api_constants.dart';
import 'package:aicar/data/datasources/local/app_database.dart';
import 'package:aicar/data/dto/chat_dto.dart';
import 'package:aicar/data/mappers/chat_message_mapper.dart';
import 'package:aicar/data/mappers/chat_session_mapper.dart';
import 'package:aicar/domain/entities/chat_message.dart';
import 'package:aicar/domain/entities/chat_session.dart';
import 'package:aicar/domain/repositories/i_chat_repository.dart';
import 'package:dio/dio.dart';

/// Go API 채팅 Repository 구현체
///
/// AI 응답: 로컬 키워드 매칭 (MVP)
/// 세션/메시지: 백엔드 API 영속화 + 로컬 Drift 캐시
class ChatRepositoryImpl implements IChatRepository {
  ChatRepositoryImpl(this._db, this._dio);

  final AppDatabase _db;
  final Dio _dio;

  // ─── AI 응답 (로컬 키워드 매칭) ───

  @override
  Future<String> getResponse(String userMessage) async {
    final lower = userMessage.toLowerCase();

    if (_matchesAny(lower, ['3천', '5천', '예산', '가격대', '만원'])) {
      return '예산에 맞는 수입차를 추천해 드릴게요!\n\n'
          '3,000만원대: BMW 3시리즈, 벤츠 A클래스, 아우디 A3\n'
          '5,000만원대: BMW 5시리즈, 벤츠 C클래스, 아우디 A4\n\n'
          '더 자세한 추천을 원하시면 선호하는 차종(세단/SUV)을 알려주세요!';
    }
    if (_matchesAny(lower, ['suv', '에스유브이'])) {
      return '인기 수입 SUV를 추천해 드릴게요!\n\n'
          '컴팩트: BMW X1, 벤츠 GLA, 아우디 Q3\n'
          '중형: BMW X3, 벤츠 GLC, 아우디 Q5\n'
          '대형: BMW X5, 벤츠 GLE, 아우디 Q7';
    }
    if (_matchesAny(lower, ['세단', 'sedan'])) {
      return '인기 수입 세단을 추천해 드릴게요!\n\n'
          '엔트리: BMW 3시리즈, 벤츠 C클래스, 아우디 A4\n'
          '프리미엄: BMW 5시리즈, 벤츠 E클래스, 아우디 A6';
    }
    if (_matchesAny(lower, ['벤츠', 'bmw', '아우디', '렉서스', '볼보'])) {
      final brand = _extractBrand(lower);
      return '$brand의 인기 모델을 안내해 드릴게요!\n\n'
          '관심 있는 차종이나 예산을 알려주시면 맞춤 추천해 드릴게요!';
    }
    if (_matchesAny(lower, ['연비', '하이브리드', '전기차', 'ev'])) {
      return '연비 좋은 수입차를 찾고 계시군요!\n\n'
          '하이브리드: BMW 330e, 렉서스 ES300h\n'
          '전기차: BMW iX, 벤츠 EQE, 아우디 e-tron';
    }
    if (_matchesAny(lower, ['견적', '할인', '프로모션', '가격', '얼마'])) {
      return '견적 확인을 도와드릴게요!\n\n'
          '관심 있는 차량 모델을 알려주시면 가격 정보를 안내해 드릴게요.';
    }

    return '안녕하세요! 에이카 AI 상담사입니다.\n\n'
        '수입차 구매에 관한 모든 것을 도와드릴게요!\n'
        '예산, 차종, 브랜드 등을 말씀해 주세요.';
  }

  // ─── 세션 관리 (백엔드 API) ───

  @override
  Future<ChatSession> createSession({String? title}) async {
    final request = CreateSessionRequestDto(title: title);
    final response = await _dio.post(
      ApiConstants.chatSessions,
      data: request.toJson(),
    );
    final json = response.data as Map<String, dynamic>;
    return ChatApiMapper.sessionFromDto(ChatSessionDto.fromJson(json));
  }

  @override
  Future<List<ChatSession>> getSessions() async {
    final response = await _dio.get(ApiConstants.chatSessions);
    final json = response.data;

    // 응답이 리스트인 경우와 {items: [...]} 래핑인 경우 모두 처리
    final List<dynamic> items;
    if (json is List) {
      items = json;
    } else if (json is Map<String, dynamic>) {
      items = json['items'] as List<dynamic>? ?? [];
    } else {
      items = [];
    }

    return items
        .map((e) =>
            ChatApiMapper.sessionFromDto(ChatSessionDto.fromJson(e as Map<String, dynamic>)))
        .toList();
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _dio.delete(ApiConstants.chatSession(sessionId));
  }

  // ─── 메시지 (백엔드 영속화) ───

  @override
  Future<ChatMessage> saveMessage(
      String sessionId, ChatMessage message) async {
    final request = CreateMessageRequestDto(
      role: message.role.name,
      content: message.content,
    );

    final response = await _dio.post(
      ApiConstants.chatMessages(sessionId),
      data: request.toJson(),
    );

    final json = response.data as Map<String, dynamic>;
    final dto = ChatMessageDto.fromJson(json);
    final saved = ChatApiMapper.messageFromDto(dto);

    // 로컬 Drift에도 캐시
    await _db.into(_db.chatHistoryTable).insert(
          ChatMessageMapper.toDrift(saved),
        );

    return saved;
  }

  @override
  Future<List<ChatMessage>> loadMessages(String sessionId) async {
    final response = await _dio.get(ApiConstants.chatMessages(sessionId));
    final json = response.data;

    final List<dynamic> items;
    if (json is List) {
      items = json;
    } else if (json is Map<String, dynamic>) {
      items = json['items'] as List<dynamic>? ?? [];
    } else {
      items = [];
    }

    return items
        .map((e) => ChatApiMapper.messageFromDto(
            ChatMessageDto.fromJson(e as Map<String, dynamic>)))
        .toList();
  }

  // ─── 로컬 (Drift, 하위 호환) ───

  @override
  Future<List<ChatMessage>> loadHistory() async {
    final rows = await (_db.select(_db.chatHistoryTable)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          ]))
        .get();
    return rows.map(ChatMessageMapper.fromDrift).toList();
  }

  @override
  Future<void> clearHistory() async {
    await _db.delete(_db.chatHistoryTable).go();
  }

  // ─── 유틸 ───

  bool _matchesAny(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));

  String _extractBrand(String text) {
    if (text.contains('벤츠')) return '메르세데스-벤츠';
    if (text.contains('bmw')) return 'BMW';
    if (text.contains('아우디')) return '아우디';
    if (text.contains('렉서스')) return '렉서스';
    if (text.contains('볼보')) return '볼보';
    return '해당 브랜드';
  }
}
```

- [ ] **Step 2: Update chat_repository_impl.dart (supabase stub)**

`flutter_app/lib/data/repositories/supabase/chat_repository_impl.dart` 전체를 아래로 교체:

```dart
import 'package:aicar/domain/entities/chat_message.dart';
import 'package:aicar/domain/entities/chat_session.dart';
import 'package:aicar/domain/repositories/i_chat_repository.dart';

/// Supabase 채팅 Repository — UnimplementedError 스텁
class ChatRepositoryImpl implements IChatRepository {
  @override
  Future<String> getResponse(String userMessage) =>
      throw UnimplementedError('Supabase chat not implemented');

  @override
  Future<ChatSession> createSession({String? title}) =>
      throw UnimplementedError('Supabase chat not implemented');

  @override
  Future<List<ChatSession>> getSessions() =>
      throw UnimplementedError('Supabase chat not implemented');

  @override
  Future<void> deleteSession(String sessionId) =>
      throw UnimplementedError('Supabase chat not implemented');

  @override
  Future<ChatMessage> saveMessage(String sessionId, ChatMessage message) =>
      throw UnimplementedError('Supabase chat not implemented');

  @override
  Future<List<ChatMessage>> loadMessages(String sessionId) =>
      throw UnimplementedError('Supabase chat not implemented');

  @override
  Future<List<ChatMessage>> loadHistory() =>
      throw UnimplementedError('Supabase chat not implemented');

  @override
  Future<void> clearHistory() =>
      throw UnimplementedError('Supabase chat not implemented');
}
```

- [ ] **Step 3: Create my_car_repository_impl.dart (go_api)**

Create `flutter_app/lib/data/repositories/go_api/my_car_repository_impl.dart`:

```dart
import 'package:aicar/core/constants/api_constants.dart';
import 'package:aicar/data/dto/my_car_dto.dart';
import 'package:aicar/data/mappers/my_car_mapper.dart';
import 'package:aicar/domain/entities/my_car.dart';
import 'package:aicar/domain/repositories/i_my_car_repository.dart';
import 'package:dio/dio.dart';

/// Go API 내 차량 Repository 구현체
///
/// 데이터 흐름: 사용자 입력(번호판) → POST /cars/register → 백엔드 CarInfoProvider 조회 → MyCar
class MyCarRepositoryImpl implements IMyCarRepository {
  MyCarRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<MyCar> registerCar({
    required String userId,
    required String licensePlate,
  }) async {
    final request = RegisterMyCarRequestDto(
      userId: userId,
      licensePlate: licensePlate,
    );

    final response = await _dio.post(
      ApiConstants.registerCar,
      data: request.toJson(),
    );

    final json = response.data as Map<String, dynamic>;
    return MyCarMapper.fromDto(MyCarDto.fromJson(json));
  }

  @override
  Future<List<MyCar>> getMyCars(String userId) async {
    final response = await _dio.get(ApiConstants.myCars(userId));
    final json = response.data;

    final List<dynamic> items;
    if (json is List) {
      items = json;
    } else if (json is Map<String, dynamic>) {
      items = json['items'] as List<dynamic>? ?? [];
    } else {
      items = [];
    }

    return items
        .map((e) =>
            MyCarMapper.fromDto(MyCarDto.fromJson(e as Map<String, dynamic>)))
        .toList();
  }
}
```

- [ ] **Step 4: Create my_car_repository_impl.dart (supabase stub)**

Create `flutter_app/lib/data/repositories/supabase/my_car_repository_impl.dart`:

```dart
import 'package:aicar/domain/entities/my_car.dart';
import 'package:aicar/domain/repositories/i_my_car_repository.dart';

/// Supabase 내 차량 Repository — UnimplementedError 스텁
class MyCarRepositoryImpl implements IMyCarRepository {
  @override
  Future<MyCar> registerCar({
    required String userId,
    required String licensePlate,
  }) =>
      throw UnimplementedError('Supabase my_car not implemented');

  @override
  Future<List<MyCar>> getMyCars(String userId) =>
      throw UnimplementedError('Supabase my_car not implemented');
}
```

- [ ] **Step 5: Update repository_providers.dart — 전체 provider 등록**

`flutter_app/lib/core/providers/repository_providers.dart` 전체를 아래로 교체:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aicar/core/providers/database_provider.dart';
import 'package:aicar/core/providers/dio_provider.dart';
import 'package:aicar/data/repositories/go_api/auth_repository_impl.dart'
    as go_api_auth;
import 'package:aicar/data/repositories/go_api/bookmark_repository_impl.dart'
    as go_api_bookmark;
import 'package:aicar/data/repositories/go_api/chat_repository_impl.dart'
    as go_api_chat;
import 'package:aicar/data/repositories/go_api/garage_repository_impl.dart'
    as go_api_garage;
import 'package:aicar/data/repositories/go_api/my_car_repository_impl.dart'
    as go_api_mycar;
import 'package:aicar/data/repositories/go_api/vehicle_repository_impl.dart'
    as go_api_vehicle;
import 'package:aicar/domain/repositories/i_auth_repository.dart';
import 'package:aicar/domain/repositories/i_bookmark_repository.dart';
import 'package:aicar/domain/repositories/i_chat_repository.dart';
import 'package:aicar/domain/repositories/i_garage_repository.dart';
import 'package:aicar/domain/repositories/i_my_car_repository.dart';
import 'package:aicar/domain/repositories/i_vehicle_repository.dart';

/// Auth Repository Provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final dio = ref.read(dioProvider);
  final tokenStorage = ref.read(tokenStorageProvider);
  return go_api_auth.AuthRepositoryImpl(dio, tokenStorage);
});

/// Vehicle Repository Provider — Go API (/cars 엔드포인트)
final vehicleRepositoryProvider = Provider<IVehicleRepository>((ref) {
  final dio = ref.read(dioProvider);
  return go_api_vehicle.VehicleRepositoryImpl(dio);
});

/// Bookmark Repository Provider — Drift 로컬
final bookmarkRepositoryProvider = Provider<IBookmarkRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  return go_api_bookmark.BookmarkRepositoryImpl(db);
});

/// Garage Repository Provider — Drift 로컬
final garageRepositoryProvider = Provider<IGarageRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  return go_api_garage.GarageRepositoryImpl(db);
});

/// Chat Repository Provider — 키워드 매칭(로컬) + 세션/메시지(백엔드)
final chatRepositoryProvider = Provider<IChatRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  final dio = ref.read(dioProvider);
  return go_api_chat.ChatRepositoryImpl(db, dio);
});

/// MyCar Repository Provider — Go API (/cars/register 엔드포인트)
final myCarRepositoryProvider = Provider<IMyCarRepository>((ref) {
  final dio = ref.read(dioProvider);
  return go_api_mycar.MyCarRepositoryImpl(dio);
});
```

- [ ] **Step 6: flutter analyze**

```bash
cd /Users/lims/AiCar/flutter_app && flutter analyze
```

Expected: 0 issues. 모든 인터페이스와 구현체가 일치하는지 확인.

에러가 있으면 이 단계에서 수정:
- `pages/ai_chat/providers/chat_provider.dart`에 feature-scoped `chatRepositoryProvider`가 이미 정의됨 → 이를 제거하고 `core/providers/repository_providers.dart`의 `chatRepositoryProvider`를 import하도록 변경
- `IChatRepository.saveMessage` 시그니처 변경 (`String sessionId` 추가) → chat_provider.dart의 호출부에서 sessionId 파라미터 추가
- `IChatRepository`에서 `getSessionIds()`, `loadSession()` 메서드가 제거됨 → 이를 사용하는 코드가 있다면 `getSessions()`, `loadMessages()` 로 교체
- `specs` nullable 대응 → `vehicle.specs.fuelEfficiency` 같은 접근을 `vehicle.fuelEfficiency ?? vehicle.specs?.fuelEfficiency` 로 수정

- [ ] **Step 7: Commit**

```bash
cd /Users/lims/AiCar/flutter_app && git add lib/ && git commit -m "feat(flutter): Chat 세션 API + MyCar Repository + 전체 Provider 연결"
```

---

### Task 7: 통합 검증 + APK 빌드

**Files:** 없음 (검증만)

- [ ] **Step 1: API 연결 확인 — curl로 onboard 테스트**

```bash
curl -s -X POST http://18.191.163.53:8080/api/v1/auth/onboard \
  -H "Content-Type: application/json" \
  -d '{"device_id":"TEST-FLUTTER-001","device_type":"android"}' | python3 -m json.tool
```

Expected: `{ "data": { "access_token": "...", "refresh_token": "..." } }`

- [ ] **Step 2: build_runner 최종 실행**

```bash
cd /Users/lims/AiCar/flutter_app && dart run build_runner build --delete-conflicting-outputs
```

Expected: 0 errors, 모든 .g.dart/.freezed.dart 최신 상태.

- [ ] **Step 3: flutter analyze**

```bash
cd /Users/lims/AiCar/flutter_app && flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 4: flutter test**

```bash
cd /Users/lims/AiCar/flutter_app && flutter test
```

Expected: 기존 테스트 통과 (있다면). 새 테스트 추가는 이번 범위 외.

- [ ] **Step 5: flutter build apk --release**

```bash
cd /Users/lims/AiCar/flutter_app && flutter build apk --release
```

Expected: `build/app/outputs/flutter-apk/app-release.apk` 생성.

- [ ] **Step 6: 최종 Commit**

```bash
cd /Users/lims/AiCar/flutter_app && git add . && git commit -m "feat(flutter): Go API 연동 완료 — Auth/Cars/Chat/MyCar + release APK 빌드"
```

- [ ] **Step 7: git push 안내**

사용자에게 push 안내:
```bash
git push origin main
```
