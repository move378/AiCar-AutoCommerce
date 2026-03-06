# SWYP 4기 — 아키텍처 결정 기록 (ADR)

> 최종 업데이트: 2026-03-06
> 작성: 임상훈 (PL / SW Architect)
> 프로젝트: 수입차 AI 컨시어지 — 3주 스프린트

---

## 1. 프로젝트 구조 — Mono-repo

### 결정

4개 프로젝트(Flutter, Backend, Backoffice, Infra)를 **단일 레포지토리**로 관리한다.

```
AiCar/
├── flutter_app/
├── backend/
├── backoffice/
├── infra/
├── docker-compose.yml
├── .github/
│   ├── workflows/
│   │   ├── backend-ci.yml
│   │   ├── flutter-ci.yml
│   │   ├── backoffice-ci.yml
│   │   └── deploy.yml
│   └── CODEOWNERS
├── docs/
├── .gitignore
├── README.md
└── Makefile
```

### 근거

- 팀 규모가 6명(실질 개발자 3명)으로 작아서, Multi-repo의 PR/이슈 분산 관리 오버헤드가 이점을 초과한다.
- API 스펙 변경 시 backend + Flutter + backoffice를 하나의 PR로 묶을 수 있어 cross-cutting 변경에 유리하다.
- `docker-compose.yml`이 루트에 위치하는 설계와 정합한다.

### 브랜치 전략

```
main                            ← production 배포 기준
└── develop                     ← 통합 브랜치
    ├── feat/flutter-auth       ← prefix로 스택 구분
    ├── feat/backend-survey
    ├── feat/bo-dashboard       ← bo = backoffice
    └── fix/backend-redis
```

### Path-based CI

각 워크플로우는 해당 폴더 변경 시에만 트리거된다.

```yaml
# 예시: .github/workflows/backend-ci.yml
on:
  push:
    paths:
      - 'backend/**'
      - '.github/workflows/backend-ci.yml'
```

### CODEOWNERS

```
/infra/         @shawn          # infra 변경은 PL 승인 필수
/backend/       @shawn @hyeran
/flutter_app/   @shawn
/backoffice/    @hyeran @yunseo
```

---

## 2. 인증 방식 — JWT Stateless

### 결정

서버 측 세션을 사용하지 않는 **JWT Stateless** 인증을 채택한다.

### 구조

```
[클라이언트]                     [서버]
    │                              │
    ├─ 소셜 로그인 요청 ──────────▶│
    │                              ├─ 소셜 provider 검증
    │                              ├─ Access Token 발급 (짧은 수명, 15~30분)
    │◀── Access + Refresh Token ───┤  Refresh Token 발급 (긴 수명, 7~30일)
    │                              └─ Refresh Token → DB 저장 (PostgreSQL)
    │
    ├─ API 요청 (Authorization: Bearer <access_token>) ──▶│
    │                              │
    ├─ 401 Unauthorized ◀──────────┤  (Access Token 만료 시)
    │                              │
    ├─ Refresh 요청 ──────────────▶│
    │◀── 새 Access Token ──────────┤  Refresh Token 검증 → 새 Access Token 발급
```

### 근거

- Redis sidecar 방식에서 ECS task 재배포 시 세션 데이터가 소실되는 문제를 원천 차단한다.
- ElastiCache 도입 없이 인프라를 단순화하여 3주 스프린트에 부합한다.
- Refresh Token은 PostgreSQL에 저장하므로 배포 시에도 유지된다.

### Backend 변경사항

- `infra/persistence/redis/session_store.go` → **삭제**
- `infra/persistence/redis/cache.go` → **유지** (순수 캐시 전용, 데이터 소실 허용)
- Refresh Token 저장소: `infra/persistence/postgres/` 내에서 처리 (user_repo 확장 또는 별도 token_repo)

### Flutter 변경사항

- `domain/repositories/i_session_repository.dart` → `i_token_storage.dart`로 **리네이밍**
- 세션 관리 로직 → `usecases/auth/`로 흡수

---

## 3. Flutter 토큰 관리 — Repository vs UseCase 분리

### 결정

토큰 **저장/조회**는 repository(storage) 레이어에, 토큰 **갱신/검증** 로직은 usecase 레이어에 배치한다.

### 분리 기준

| 행위 | 레이어 | 이유 |
|------|--------|------|
| 토큰 저장, 조회, 삭제 | `i_token_storage` (domain/repositories) | 순수 데이터 접근, 비즈니스 판단 없음 |
| 토큰 만료 확인 | usecase (auth) | 비즈니스 판단 |
| 토큰 갱신 요청 → 저장 | usecase (auth) | 여러 저장소/API를 조합하는 오케스트레이션 |
| 로그아웃 (토큰 삭제 + 서버 알림 + 캐시 정리) | usecase (auth) | 복합 행위 |

### 코드 구조

```
domain/
  ├── repositories/
  │   └── i_token_storage.dart          # 저장/조회만
  └── usecases/
      └── auth/
          ├── login_usecase.dart
          ├── logout_usecase.dart
          └── refresh_token_usecase.dart # 갱신 로직
```

```dart
/// i_token_storage.dart — 순수 저장소 추상화
abstract class ITokenStorage {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clearAll();
}
```

```dart
/// refresh_token_usecase.dart — 비즈니스 로직
class RefreshTokenUseCase {
  final ITokenStorage _tokenStorage;
  final IAuthRepository _authRepo;

  Future<String> execute() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) throw NotAuthenticatedException();

    final newTokens = await _authRepo.refresh(refreshToken);

    await _tokenStorage.saveTokens(
      accessToken: newTokens.access,
      refreshToken: newTokens.refresh,
    );

    return newTokens.access;
  }
}
```

### 구현체 위치

`i_token_storage.dart`의 구현체는 `data/services/secure_storage_service_impl.dart`에서 Flutter Secure Storage를 사용하여 구현한다.

---

## 4. Backend Domain Gateway — 외부 서비스 인터페이스

### 결정

외부 시스템 통신에 대한 추상화를 `domain/gateway/`에 별도 분리한다.

### 구조

```
domain/
  ├── entity/           # 비즈니스 엔티티
  ├── repository/       # 내부 DB 접근 인터페이스 (기존 유지)
  │   ├── user_repository.go
  │   ├── vehicle_repository.go
  │   └── ...
  └── gateway/          # 외부 시스템 통신 인터페이스 (신규)
      ├── ai_gateway.go
      ├── social_auth_gateway.go
      ├── sms_gateway.go
      └── crawler_gateway.go
```

### 매핑 관계

| domain/gateway/ | 구현체 (infra/external/) |
|-----------------|------------------------|
| `ai_gateway.go` | `ai_client.go` |
| `social_auth_gateway.go` | `social_auth_client.go` |
| `sms_gateway.go` | `sms_client.go` |
| `crawler_gateway.go` | `crawler_client.go` |

`kakao_client.go`는 `social_auth_gateway.go`의 구현체 중 하나로 포함된다.

### 근거

- Repository는 **우리가 소유한 데이터 저장소**(PostgreSQL, Redis)에 대한 추상화이다.
- Gateway는 **외부 시스템과의 통신**(AI API, 소셜 로그인, SMS)에 대한 추상화이다.
- 이 둘을 같은 `repository/`에 섞으면 `ai_repository`처럼 의미가 어색한 네이밍이 발생한다.
- UseCase는 반드시 domain 인터페이스(gateway)를 통해 외부 시스템에 접근하며, infra 패키지를 직접 참조하지 않는다.

### 의존성 방향

```
usecase → domain/gateway/ai_gateway.go (인터페이스)
                ↑
        infra/external/ai_client.go (구현체)
```

Wire(DI)에서 `ai_gateway.go` 인터페이스에 `ai_client.go` 구현체를 바인딩한다.

---

## 5. Flutter Provider 배치 규칙

### 3줄 규칙

| 조건 | 위치 | 예시 |
|------|------|------|
| 2+ feature에서 사용 | `core/providers/` | `authProvider`, `dioProvider` |
| 단일 feature 전용 | `pages/{feature}/providers/` | `surveyProvider`, `chatProvider` |
| page 하나에서만 사용 | 해당 page 파일 내부 상단 | 일시적 UI 상태 |

### P1 폴더 승격 규칙

flat 파일이 **3개 이상**으로 성장하면 폴더로 승격한다.

```
# Before (flat)
├── card_repository_impl.dart
├── garage_repository_impl.dart
├── estimate_repository_impl.dart

# After (승격 — 파일이 3개 이상이 되면)
├── card/
│   └── card_repository_impl.dart
├── garage/
│   └── garage_repository_impl.dart
├── estimate/
│   └── estimate_repository_impl.dart
```

---

## 6. 리뷰 후 보완 예정 사항

아래 항목은 구조적 리스크가 낮아 **개발 진행 중 필요 시 반영**한다.

### 개발 시작 전 결정 (방향성)

| 항목 | 현재 상태 | 결정 시점 |
|------|----------|----------|
| `data/services/` → `data/platform/` 리네이밍 | 보류 | 구현 착수 시 |
| backoffice `stores/` 폴더 유지 vs 삭제 | 빈 폴더 유지 | 상태 관리 필요성 발생 시 |
| `quick_question/`, `qr/` 우선순위 명시 | 미정 | 스프린트 플래닝 시 |

### 나중에 해도 되는 것 (Nice-to-have)

| 항목 | 비고 |
|------|------|
| `handler/backoffice/` → `handler/admin/` 리네이밍 | 프로젝트 루트 `backoffice/`와 혼동 방지 |
| `docs/eks-migration.md` → `docs/future/`로 이동 | 3주 스프린트 집중을 위해 향후 계획 격리 |
| `vehicle_explore/`와 `vehicle_search_datasource` 매핑 명확화 | 구현 시 자연스럽게 정리 |
| Migration에 index 전용 파일 추가 (`00012_create_indexes.sql`) | 성능 이슈 발생 시 |
| Terraform tfvars diff check CI 추가 | prod 배포 전까지 |
| `deploy.sh`와 `deploy.yml` 역할 분리 명시 | CI/CD 구축 시 |

---

## 7. 최종 확정 폴더 구조 변경 요약

### Backend (`backend/internal/domain/`)

```diff
  domain/
    ├── entity/
    ├── repository/          # 내부 DB 접근 (변경 없음)
+   └── gateway/             # 외부 시스템 통신 (신규)
+       ├── ai_gateway.go
+       ├── social_auth_gateway.go
+       ├── sms_gateway.go
+       └── crawler_gateway.go
```

### Backend (`backend/internal/infra/persistence/redis/`)

```diff
  redis/
    ├── cache.go             # 유지 (순수 캐시)
-   └── session_store.go     # 삭제 (JWT stateless 전환)
```

### Flutter (`flutter_app/lib/domain/repositories/`)

```diff
  repositories/
    ├── i_auth_repository.dart
    ├── i_vehicle_repository.dart
    ├── i_survey_repository.dart
    ├── i_card_repository.dart
    ├── i_garage_repository.dart
    ├── i_estimate_repository.dart
-   ├── i_session_repository.dart
+   ├── i_token_storage.dart          # 리네이밍: 토큰 저장/조회만
    └── i_vehicle_link_repository.dart
```

---

## 부록: 용어 정리

| 용어 | 설명 |
|------|------|
| **ADR** (Architecture Decision Record) | 아키텍처 의사결정을 기록하는 문서. "왜 이렇게 결정했는가"를 팀 전체가 공유하기 위한 목적 |
| **JWT** (JSON Web Token) | 서버 측 세션 없이 클라이언트가 토큰을 보관하는 인증 방식. 토큰 자체에 사용자 정보가 인코딩되어 있어 서버가 별도 저장소를 조회하지 않음 |
| **Stateless 인증** | 서버가 클라이언트의 상태(세션)를 저장하지 않는 방식. 매 요청마다 토큰으로 본인을 증명 |
| **Refresh Token** | Access Token 만료 시 새 Access Token을 발급받기 위한 장기 토큰. DB에 저장하여 탈취 시 서버 측에서 무효화 가능 |
| **Gateway 패턴** | 외부 시스템과의 통신을 추상화하는 인터페이스. Repository가 내부 저장소를 추상화하는 것과 대응되는 개념 |
| **의존성 역전 (DIP)** | 상위 모듈(usecase)이 하위 모듈(infra)에 직접 의존하지 않고, 추상화(interface)에 의존하는 원칙. 구현체 교체나 테스트 용이성을 확보 |
| **Wire** | Google의 Go 의존성 주입(DI) 코드 생성 도구. 인터페이스와 구현체의 바인딩을 컴파일 타임에 검증 |
| **Co-location** | 관련 코드를 물리적으로 가까운 위치에 배치하는 원칙. Feature 전용 provider를 해당 feature 폴더 안에 두는 것이 예시 |
| **ECS Sidecar** | AWS ECS task 내에서 메인 컨테이너와 함께 실행되는 보조 컨테이너. Task 생명주기를 공유하므로 task 종료 시 함께 소멸 |
| **Path-based CI** | Mono-repo에서 변경된 폴더 경로를 기준으로 해당 프로젝트의 CI만 선택적으로 실행하는 방식 |
| **CODEOWNERS** | GitHub 기능으로, 특정 파일/폴더 변경 시 지정된 reviewer의 승인을 필수로 요구 |
