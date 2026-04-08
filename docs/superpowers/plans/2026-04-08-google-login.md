# Google 로그인 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Flutter에 Google Sign-In을 추가하여 백엔드 `/auth/google-login` 연동 완료

**Architecture:** 카카오 로그인과 동일 패턴 — Google SDK → accessToken → 백엔드 JWT 교환 → SecureStorage. 기존 `SocialLoginRequestDto`를 재사용.

**Tech Stack:** google_sign_in (Flutter), Go Backend (이미 구현됨)

**Spec:** `docs/superpowers/specs/2026-04-08-google-login-chatbot-images-design.md` §1

---

### Task 1: google_sign_in 패키지 추가

**Files:**
- Modify: `flutter_app/pubspec.yaml:40-41`

- [ ] **Step 1: 패키지 추가**

`pubspec.yaml` dependencies에 추가:

```yaml
  # 소셜 로그인
  kakao_flutter_sdk_user: ^1.9.8
  sign_in_with_apple: ^7.0.1
  google_sign_in: ^6.2.1
```

- [ ] **Step 2: 패키지 설치 확인**

Run: `cd /Users/lims/AiCar/flutter_app && flutter pub get`
Expected: "Got dependencies!" 메시지 출력

- [ ] **Step 3: 커밋**

```bash
git add flutter_app/pubspec.yaml flutter_app/pubspec.lock
git commit -m "chore(flutter): google_sign_in 패키지 추가"
```

---

### Task 2: IAuthRepository에 loginWithGoogle 메서드 추가

**Files:**
- Modify: `flutter_app/lib/domain/repositories/i_auth_repository.dart:17-18`

- [ ] **Step 1: 인터페이스에 메서드 추가**

`loginWithKakao` 아래에 추가:

```dart
  /// Google 소셜 로그인 — Google access_token → 서버 JWT
  Future<({AuthTokens tokens, bool isNewUser})> loginWithGoogle(
      String googleAccessToken);
```

- [ ] **Step 2: analyze 확인 (구현체 미구현으로 에러 예상)**

Run: `cd /Users/lims/AiCar/flutter_app && flutter analyze lib/domain/repositories/i_auth_repository.dart`
Expected: 파일 자체는 에러 없음 (abstract interface이므로)

- [ ] **Step 3: 커밋**

```bash
git add flutter_app/lib/domain/repositories/i_auth_repository.dart
git commit -m "feat(flutter): IAuthRepository에 loginWithGoogle 메서드 추가"
```

---

### Task 3: Go API AuthRepositoryImpl에 loginWithGoogle 구현

**Files:**
- Modify: `flutter_app/lib/data/repositories/go_api/auth_repository_impl.dart:54-79`
- Modify: `flutter_app/lib/data/repositories/supabase/auth_repository_impl.dart:16-19`

- [ ] **Step 1: Go API 구현체에 loginWithGoogle 추가**

`loginWithKakao()` 메서드 바로 아래에 추가 (카카오와 동일 패턴, 엔드포인트만 다름):

```dart
  @override
  Future<({AuthTokens tokens, bool isNewUser})> loginWithGoogle(
      String googleAccessToken) async {
    final request = SocialLoginRequestDto(providerToken: googleAccessToken);

    final response = await _dio.post(
      ApiConstants.googleLogin,
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
```

- [ ] **Step 2: Supabase 스텁에 loginWithGoogle 추가**

`loginWithKakao` 스텁 아래에 추가:

```dart
  @override
  Future<({AuthTokens tokens, bool isNewUser})> loginWithGoogle(
          String googleAccessToken) =>
      throw UnimplementedError('Supabase auth not implemented');
```

- [ ] **Step 3: analyze 확인**

Run: `cd /Users/lims/AiCar/flutter_app && flutter analyze lib/data/repositories/`
Expected: 에러 없음

- [ ] **Step 4: 커밋**

```bash
git add flutter_app/lib/data/repositories/go_api/auth_repository_impl.dart flutter_app/lib/data/repositories/supabase/auth_repository_impl.dart
git commit -m "feat(flutter): AuthRepositoryImpl에 loginWithGoogle 구현"
```

---

### Task 4: AuthProvider에 loginWithGoogle 메서드 추가

**Files:**
- Modify: `flutter_app/lib/core/providers/auth_provider.dart:76-107`

- [ ] **Step 1: import 추가**

파일 상단 import 영역에 추가:

```dart
import 'package:google_sign_in/google_sign_in.dart';
```

- [ ] **Step 2: loginWithGoogle 메서드 추가**

`loginWithKakao()` 메서드 아래에 추가:

```dart
  /// Google 로그인
  Future<void> loginWithGoogle() async {
    final authRepo = ref.read(authRepositoryProvider);

    // Google SDK 로그인
    final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
    final account = await googleSignIn.signIn();
    if (account == null) return; // 사용자가 취소

    final auth = await account.authentication;
    final accessToken = auth.accessToken;
    if (accessToken == null) throw Exception('Google accessToken이 null입니다');

    // 백엔드에 Google 토큰 전송
    await authRepo.loginWithGoogle(accessToken);

    state = state.copyWith(
      isLoggedIn: true,
      isGuest: false,
      provider: 'google',
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
```

- [ ] **Step 3: analyze 확인**

Run: `cd /Users/lims/AiCar/flutter_app && flutter analyze lib/core/providers/auth_provider.dart`
Expected: 에러 없음

- [ ] **Step 4: 커밋**

```bash
git add flutter_app/lib/core/providers/auth_provider.dart
git commit -m "feat(flutter): AuthProvider에 loginWithGoogle 메서드 추가"
```

---

### Task 5: LoginPage에 Google 로그인 버튼 추가

**Files:**
- Modify: `flutter_app/lib/presentation/pages/auth/login_page.dart:60-93`

- [ ] **Step 1: 카카오 버튼과 Apple 버튼 사이에 Google 버튼 추가**

카카오 `_SnsLoginButton` (라인 61-81) 아래, Apple 버튼 (라인 83) 위에 삽입:

```dart
              const SizedBox(height: AppSpacing.space3),
              _SnsLoginButton(
                label: 'Google로 시작하기',
                backgroundColor: AppColors.background,
                foregroundColor: AppColors.textPrimary,
                icon: Icons.g_mobiledata_rounded,
                borderColor: AppColors.textDisabled,
                onTap: () async {
                  try {
                    await ref.read(authProvider.notifier).loginWithGoogle();
                    if (context.mounted) context.push('/consent');
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Google 로그인 실패: $e'),
                          backgroundColor: const Color(0xFFEF4444),
                        ),
                      );
                    }
                  }
                },
              ),
```

- [ ] **Step 2: analyze 확인**

Run: `cd /Users/lims/AiCar/flutter_app && flutter analyze lib/presentation/pages/auth/login_page.dart`
Expected: 에러 없음

- [ ] **Step 3: 커밋**

```bash
git add flutter_app/lib/presentation/pages/auth/login_page.dart
git commit -m "feat(flutter): LoginPage에 Google 로그인 버튼 추가"
```

---

### Task 6: Android/iOS 설정

**Files:**
- Modify: `flutter_app/android/app/build.gradle` (필요 시)
- Modify: `flutter_app/ios/Runner/Info.plist` (필요 시)

- [ ] **Step 1: Android 설정 확인**

`google_sign_in`은 Android에서 별도 `google-services.json` 없이도 동작 가능 (웹 클라이언트 ID 기반).
단, Google Cloud Console에서 OAuth 2.0 클라이언트 ID가 필요합니다.

현재 `flutter_app/android/app/src/main/kotlin/kr/` 디렉토리가 이미 존재하므로 패키지명 `kr.aicar.app`으로 설정됨.

Google Cloud Console에서:
1. APIs & Services → Credentials → OAuth 2.0 Client IDs
2. Android 타입: 패키지명 `kr.aicar.app`, SHA-1 키 해시 등록
3. iOS 타입: Bundle ID 등록
4. Web 타입: Google Sign-In SDK가 내부적으로 사용

- [ ] **Step 2: iOS 설정 (필요 시)**

`ios/Runner/Info.plist`에 Google URL scheme 추가가 필요할 수 있음.
`google_sign_in` 패키지의 설치 문서 참조:
- `GoogleService-Info.plist` 추가
- 또는 `REVERSED_CLIENT_ID`를 URL scheme에 등록

> **Note:** Google Cloud Console 설정은 계정 접근 권한이 필요하므로, 이 Task는 PL이 직접 Google Cloud Console에서 OAuth 클라이언트를 생성한 후 완료됩니다. Flutter 코드 자체는 Task 1-5로 완료.

- [ ] **Step 3: 전체 analyze 확인**

Run: `cd /Users/lims/AiCar/flutter_app && flutter analyze`
Expected: 기존 에러 1개 (widget_test.dart) 외 신규 에러 없음
