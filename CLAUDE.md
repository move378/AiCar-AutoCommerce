# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AiCar — 수입차 AI 컨시어지 앱. Mono-repo with 4 components.

| Component | Stack | Path |
|-----------|-------|------|
| Mobile App | Flutter (Riverpod, GoRouter, Dio) | `/flutter_app/` |
| Backend API | Go (Gin, GORM, JWT) | `/backend/` |
| Backoffice | Next.js (TypeScript) | `/backoffice/` |
| Infrastructure | Docker, Terraform (AWS) | `/infra/` |

## Common Commands

### Local Infrastructure
```bash
make docker-up    # Start PostgreSQL 18 (port 5433) + Redis 8.6 (port 6379)
make docker-down  # Stop containers
```

### Backend (from /backend/)
```bash
make setup          # Install Go tools (air, goose, swag) + go mod tidy
make dev            # Hot-reload dev server via air
make run            # Run API server directly
make migrate-up     # Apply DB migrations (goose)
make migrate-down   # Rollback last migration
make swagger        # Generate OpenAPI docs (swag init)
```

### Flutter (from /flutter_app/)
```bash
flutter pub get
flutter analyze
flutter run
flutter test
dart run build_runner build --delete-conflicting-outputs  # Generate .g.dart, .freezed.dart files
```

## Architecture

### Backend — Clean Architecture (Go)

```
cmd/api/         → HTTP server entry point
cmd/worker/      → Background jobs (includes crawler)
internal/
  domain/
    entity/      → Business entities
    repository/  → DB access interfaces (internal data only)
    gateway/     → External system interfaces (AI, OAuth, SMS)
  usecase/       → Business logic orchestration
  adapter/
    handler/
      app/       → Mobile app HTTP handlers
      admin/     → Backoffice HTTP handlers
    middleware/   → Auth, CORS, logging, rate-limit
    router/      → Route registration
  infra/
    persistence/ → PostgreSQL + Redis implementations
    external/    → Gateway implementations (ai_client, social_auth_client, sms_client)
    scraper/     → Web crawlers (encar, kbcha) — run as worker jobs, not gateways
  di/            → Wire ProviderSet definitions
  shared/        → Logger, validator, response helpers, error types
```

**Key distinction:** `repository/` = internal DB access. `gateway/` = external systems only (AI, OAuth, SMS). Crawler uses `repository/` directly since it needs DB access in the same transaction (ADR §7).

### Flutter — Clean Architecture (Dart)

```
lib/
  core/
    providers/   → Global providers (auth, dio, app_lifecycle) — only for 2+ feature sharing
    theme/       → Design tokens (AppColors, AppTheme)
    constants/   → API endpoint constants
    errors/      → Sealed exception hierarchy
  domain/
    entities/    → Business models
    repositories/ → Abstract interfaces (prefixed with I)
    services/    → Platform service interfaces (ITokenStorage, IBiometricService)
    usecases/    → Business logic (auth split: login, logout, refresh_token)
  data/
    datasources/ → Remote (HTTP) + Local (Drift SQLite) data sources
    repositories/ → Interface implementations
    services/    → Platform service implementations (flutter_secure_storage, etc.)
    dto/         → Data transfer objects
  presentation/
    router/      → GoRouter with auth guard
    pages/{feature}/
      providers/ → Feature-scoped Riverpod providers (co-located)
      widgets/   → Feature-specific widgets
      *_page.dart
```

**Provider placement rule:** Feature-specific → `pages/{feature}/providers/`. Shared by 2+ features → `core/providers/`. Page-local → inline.

**P0/P1 folder rule:** 2+ files → subfolder. 1 file → flat in parent directory.

### Authentication (JWT Stateless — ADR §2, §3)

- No server-side sessions. Access Token (short-lived) + Refresh Token (long-lived, stored in PostgreSQL).
- Flutter: `ITokenStorage` interface in `domain/services/`, implemented via `flutter_secure_storage`.
- Token refresh/validation logic lives in `usecases/auth/`, not in the storage layer.
- Dio interceptor handles automatic token injection and 401 → refresh flow.

## Branch & Commit Conventions

**Branches:** `<type>/<stack>/<description>` — e.g., `feat/flutter/survey-ui`, `fix/backend/token-expiry`
- Stacks: `backend`, `flutter`, `bo` (backoffice), `infra`

**Commits:** Conventional Commits — `<type>(<scope>): <description>`
- Types: feat, fix, docs, style, refactor, test, chore, ci

**Merge strategy:** Squash Merge only. PR title becomes the commit message on main.

## Figma Integration

MCP server `figma-flutter` is configured for extracting components from Figma.

| Screen | node-id |
|--------|---------|
| Chat UI (welcome) | 2304-753 |
| Chat UI (short conversation) | 2304-817 |
| Chat UI (full conversation) | 2304-870 |
| Chat UI (section) | 2306-1090 |
| Vehicle Search | 2304-527 |
| Virtual Garage | 2304-451 |
| Garage UI | 2534-1101 |
| My Page UI | 2450-1735 |
| UI Overview (all screens) | 2306-1089 |

Figma file ID: `o7szshz4qyL7DUEulcPNFq`

## Key Architecture Docs

- `swyp-architecture-decisions.md` — ADR §1-§7 (mono-repo, JWT stateless, gateway pattern, Wire DI, crawler integration)
- `AiCar_v5_final_folder_structure.md` — Complete folder structure with rationale
- `AiCar-runbook.md` — Figma-to-Flutter workflow guide
- `CONTRIBUTING.md` — Branch strategy, commit conventions, PR workflow

## Language

이 프로젝트는 한국어를 기본 언어로 사용합니다. 코드 리뷰, 커밋 메시지 설명, PR 본문, 사용자 대면 텍스트는 한국어로 작성합니다. 코드 자체(변수명, 함수명, 클래스명)는 영어를 사용합니다.
