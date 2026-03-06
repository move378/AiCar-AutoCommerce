# AiCar-AutoCommerce 개발 가이드라인

> **최종 수정**: 2025-03-06
> **작성자**: @move378 (PL)
> **레포지토리**: [move378/AiCar-AutoCommerce](https://github.com/move378/AiCar-AutoCommerce)

---

## 목차

1. [프로젝트 개요](#1-프로젝트-개요)
2. [초기 환경 설정](#2-초기-환경-설정)
3. [브랜치 전략](#3-브랜치-전략)
4. [커밋 컨벤션](#4-커밋-컨벤션)
5. [PR 워크플로우](#5-pr-워크플로우)
6. [CODEOWNERS & 리뷰 규칙](#6-codeowners--리뷰-규칙)
7. [일상 작업 흐름](#7-일상-작업-흐름)
8. [주의사항 & 금지 행위](#8-주의사항--금지-행위)
9. [유용한 명령어 모음](#9-유용한-명령어-모음)
10. [FAQ](#10-faq)

---

## 1. 프로젝트 개요

### 기술 스택

| 영역 | 스택 | 경로 |
|------|------|------|
| Backend | Go (Gin + Wire) | `/backend/` |
| Mobile App | Flutter (Riverpod) | `/flutter_app/` |
| Backoffice | Next.js (TypeScript) | `/backoffice/` |
| Infrastructure | Docker + Terraform (AWS) | `/infra/` |

### 팀 구성

| 역할 | GitHub | 담당 영역 |
|------|--------|----------|
| PL / Backend / Flutter | @move378 | backend, flutter_app, infra |
| Backend / Backoffice | @ranio10 | backend, flutter_app, backoffice |
| Backoffice | @Avoler0 | backend, flutter_app, backoffice |

### 핵심 원칙

- **Git/GitHub 도구는 각자 편한 방식으로** 사용한다 (CLI, GUI, IDE 통합 등 자유)
- **GitHub 웹에서 코드 직접 수정, 파일 업로드는 금지**한다 (로컬 ↔ 원격 상태 불일치 방지)
- 브랜치 전략, 커밋 컨벤션, PR 워크플로우는 **공통 규칙을 따른다**

---

## 2. 초기 환경 설정

### 2-1. GitHub CLI 설치 및 인증

```bash
# 설치 (macOS)
brew install gh

# 인증
gh auth login
# → GitHub.com → HTTPS → Yes → Login with a web browser

# 인증 확인
gh auth status
```

### 2-2. Git 기본 설정

```bash
# 커밋 저자 정보 (본인 정보로 변경)
git config --global user.name "본인 이름"
git config --global user.email "GitHub 계정 이메일"

# 기본 브랜치명
git config --global init.defaultBranch main

# pull 시 rebase 기본값 (필수 — 불필요한 merge commit 방지)
git config --global pull.rebase true

# 같은 충돌 패턴 자동 기억
git config --global rerere.enabled true
```

> **`pull.rebase true`는 필수 설정이다.**
> 이 설정이 없으면 `git pull` 할 때마다 불필요한 merge commit이 생겨 히스토리가 지저분해진다.

### 2-3. 추천 Git Alias

```bash
git config --global alias.st "status -sb"       # 상태 요약
git config --global alias.lg "log --oneline --graph --decorate -20"  # 히스토리
git config --global alias.last "log -1 --stat"   # 마지막 커밋 확인
```

**사용 예시:**

```bash
git st     # 현재 상태를 간결하게 확인
git lg     # 최근 20개 커밋을 그래프로 확인
git last   # 마지막 커밋에서 변경된 파일 확인
```

### 2-4. 레포지토리 클론

```bash
gh repo clone move378/AiCar-AutoCommerce
cd AiCar-AutoCommerce
```

---

## 3. 브랜치 전략

### GitHub Flow 채택

```
main                                ← 항상 배포 가능한 상태 유지
├── feat/backend/auth-api           ← 기능 추가
├── feat/flutter/survey-ui
├── feat/bo/dashboard-charts
├── fix/backend/redis-connection    ← 버그 수정
├── hotfix/backend/critical-bug     ← 긴급 수정 (main에서 직접 분기)
├── chore/infra/docker-compose      ← 설정, 빌드 관련
└── docs/backend/api-spec           ← 문서 작업
```

- `develop` 브랜치 없이 **main + feature branches**만 사용한다
- 모든 작업은 feature 브랜치에서 진행하고 PR로 main에 머지한다
- hotfix는 main에서 직접 분기하여 main에 머지한다

### 브랜치 네이밍 규칙

```
<type>/<stack>/<description>
```

| 요소 | 설명 | 예시 |
|------|------|------|
| `type` | 작업 종류 | feat, fix, hotfix, chore, docs, refactor, test |
| `stack` | 대상 스택 | backend, flutter, bo, infra |
| `description` | 작업 설명 (kebab-case) | auth-api, survey-ui, redis-connection |

**올바른 예시:**

```
feat/backend/auth-api
feat/flutter/survey-step1
feat/bo/dealer-list-page
fix/backend/token-expiry
chore/infra/ci-workflow
docs/backend/api-spec
```

**잘못된 예시:**

```
feature/login              ← stack 구분 없음
feat/backend-auth          ← 슬래시 대신 하이픈 사용
my-branch                  ← type 없음
feat/Backend/Auth          ← 대문자 사용 금지
```

### Stack 약어

| 약어 | 의미 | 경로 |
|------|------|------|
| `backend` | Go 백엔드 | `/backend/` |
| `flutter` | Flutter 모바일 앱 | `/flutter_app/` |
| `bo` | Backoffice (Next.js) | `/backoffice/` |
| `infra` | 인프라 (Docker, Terraform) | `/infra/` |

---

## 4. 커밋 컨벤션

### Conventional Commits 형식

```
<type>(<scope>): <description>
```

### Type 목록

| Type | 설명 | 예시 |
|------|------|------|
| `feat` | 새로운 기능 | `feat(auth): Google OAuth 로그인 추가` |
| `fix` | 버그 수정 | `fix(survey): 3단계 진행률 계산 오류 수정` |
| `docs` | 문서 변경 | `docs(api): Swagger 스펙 업데이트` |
| `style` | 코드 포맷팅 (동작 변경 없음) | `style(handler): gofmt 적용` |
| `refactor` | 코드 구조 변경 (동작 변경 없음) | `refactor(usecase): 인터페이스 분리` |
| `test` | 테스트 추가/수정 | `test(auth): 토큰 만료 테스트 추가` |
| `chore` | 빌드, 설정, 의존성 등 | `chore(deps): go mod tidy` |
| `ci` | CI/CD 설정 변경 | `ci: backend CI 워크플로우 추가` |

### 커밋 메시지 규칙

- 제목은 **50자 이내**, 한국어 또는 영어 (팀 합의에 따름)
- 명령형 현재 시제 사용 ("추가한다" ❌ → "추가" ⭕)
- 마침표 없음
- feature 브랜치에서는 `wip` 커밋 허용 (Squash Merge 시 합쳐짐)

```bash
# 좋은 커밋 메시지
git commit -m "feat(auth): JWT 인증 미들웨어 구현"
git commit -m "fix(vehicle): 차량 검색 필터 누락 수정"

# 작업 중 임시 커밋 (feature 브랜치에서만)
git commit -m "wip: 토큰 검증 로직 작업 중"
```

> **중요:** PR 제목이 Squash Merge 시 main의 커밋 메시지가 된다.
> 따라서 **PR 제목을 Conventional Commits 형식으로 작성**하는 것이 핵심이다.

---

## 5. PR 워크플로우

### Merge 전략: Squash Merge Only

- **Squash Merge만 허용** (Merge Commit, Rebase Merge 비활성화)
- feature 브랜치의 모든 커밋이 하나로 합쳐져 main에 들어간다
- 머지 후 원격 feature 브랜치는 **자동 삭제**된다

### PR 생성

```bash
# 브랜치 push 후 PR 생성
git push origin feat/backend/auth-api

gh pr create \
  --title "feat(auth): JWT 인증 미들웨어 구현" \
  --body "## 변경사항
- JWT 토큰 발급/검증 미들웨어 추가
- 만료 시간 설정 config 추가

## 테스트
- auth_middleware_test.go 추가

## 관련 이슈
- closes #12" \
  --base main
```

### PR 제목 규칙

PR 제목은 Conventional Commits 형식을 따른다. 이 제목이 main 히스토리에 남는 커밋 메시지가 된다.

```
feat(auth): JWT 인증 미들웨어 구현        ← 이 제목이 main의 커밋 메시지가 됨
```

### PR 확인 및 머지

```bash
# 내 PR 목록
gh pr list --author @me

# PR 상세 확인
gh pr view <PR번호>

# PR diff 확인
gh pr diff <PR번호>

# 머지
gh pr merge <PR번호> --squash
```

### PR 머지 후 정리

```bash
# main으로 이동 + 최신화
git switch main
git pull

# 로컬 브랜치 삭제 (원격은 자동 삭제됨)
git branch -d feat/backend/auth-api
```

---

## 6. CODEOWNERS & 리뷰 규칙

### CODEOWNERS 설정

`.github/CODEOWNERS` 파일에 의해 PR 리뷰어가 자동 지정된다.

| 경로 | 리뷰어 | 비고 |
|------|--------|------|
| `/infra/` | @move378 | PL 승인 필수 |
| `/backend/` | @move378 @ranio10 @Avoler0 | 전원 작업 가능 |
| `/flutter_app/` | @move378 @ranio10 @Avoler0 | 전원 작업 가능 |
| `/backoffice/` | @move378 @ranio10 @Avoler0 | 전원 작업 가능 |
| `/.github/` | @move378 | CI/CD 설정 변경 |
| `/docker-compose.yml` | @move378 | |
| `/Makefile` | @move378 | |

### 리뷰 규칙 (팀원 합류 후 적용 예정)

- 최소 1명의 리뷰 승인이 필요하다
- 리뷰 승인 후 코드가 변경되면 승인이 자동 취소된다
- CODEOWNERS에 지정된 담당자의 승인이 필요하다

---

## 7. 일상 작업 흐름

### 전체 흐름 요약

```
main (최신화) → 브랜치 생성 → 작업 + 커밋 → push → PR 생성 → 리뷰 → 머지 → 정리
```

### 단계별 명령어

```bash
# ① main 최신화
git switch main
git pull

# ② 브랜치 생성
git switch -c feat/backend/survey-api

# ③ 작업 + 커밋 (여러 번 가능)
git st                                          # 상태 확인
git add .
git commit -m "feat(survey): 설문 API 엔드포인트 추가"
git commit -m "wip: 응답 저장 로직 작업 중"       # 중간 커밋 OK
git commit -m "test(survey): 설문 API 테스트 추가"

# ④ push
git push origin feat/backend/survey-api

# ⑤ PR 생성
gh pr create --title "feat(survey): 설문 API 구현" --body "변경사항 설명"

# ⑥ 리뷰 후 머지
gh pr merge <PR번호> --squash

# ⑦ 정리
git switch main
git pull
git branch -d feat/backend/survey-api
```

### 작업 중 main 변경사항 반영

다른 팀원의 머지가 main에 반영됐을 때, 내 브랜치에 최신 변경사항을 가져오는 방법이다.

```bash
# 내 feature 브랜치에서
git fetch origin
git rebase origin/main

# 충돌 발생 시
# → VSCode에서 충돌 파일 열어서 해결
# → git add <충돌 해결한 파일>
# → git rebase --continue
```

> **`git merge main` 대신 `git rebase origin/main`을 사용한다.**
> merge는 불필요한 merge commit을 만들고, rebase는 히스토리를 선형으로 유지한다.

---

## 8. 주의사항 & 금지 행위

### 절대 하지 말 것

| 금지 행위 | 이유 |
|-----------|------|
| GitHub 웹에서 코드 직접 수정 | 로컬과 상태 불일치 발생 |
| GitHub 웹에서 파일 업로드 | .gitignore 무시됨 |
| `main`에 직접 push | branch protection 위반 |
| `git push --force` 사용 | 다른 사람의 작업이 유실됨 |
| `.env` 파일 커밋 | 민감 정보 노출 |
| `terraform.tfvars` 커밋 | 인프라 비밀번호 노출 |
| `node_modules/` 커밋 | .gitignore 확인 필요 |

### 주의할 것

| 상황 | 대응 방법 |
|------|----------|
| force push가 꼭 필요할 때 | `--force-with-lease` 사용 (안전장치 있음) |
| 충돌 발생 | VSCode에서 시각적으로 해결 후 `git rebase --continue` |
| 잘못된 커밋 | `git commit --amend` (push 전), PR에서 추가 커밋 (push 후) |
| 잘못된 브랜치에서 작업 | `git stash` → 올바른 브랜치 이동 → `git stash pop` |

### .gitignore로 무시되는 주요 파일들

프로젝트 루트의 `.gitignore`에 의해 다음 파일/폴더는 GitHub에 올라가지 않는다.

- `.env`, `.env.*` (환경변수, 시크릿) — `.env.example`만 커밋
- `*.tfvars` (Terraform 변수) — `*.tfvars.example`만 커밋
- `*.tfstate` (Terraform 상태 파일)
- `.terraform/` (Terraform 프로바이더)
- `node_modules/` (npm 의존성)
- `flutter_app/build/` (Flutter 빌드 산출물)
- `backoffice/.next/` (Next.js 빌드 캐시)
- `.DS_Store` (macOS 시스템 파일)

---

## 9. 유용한 명령어 모음

### Git 명령어

```bash
# 상태 확인
git st                          # 현재 상태 (alias)
git lg                          # 커밋 히스토리 그래프 (alias)
git last                        # 마지막 커밋 상세 (alias)
git diff --stat                 # 변경 파일 요약

# 브랜치 관리
git switch main                 # main으로 이동
git switch -c <브랜치명>         # 브랜치 생성 + 이동
git branch -d <브랜치명>         # 로컬 브랜치 삭제
git branch --list "feat/*"      # feat 브랜치 목록

# 되돌리기
git restore <파일>              # 수정 취소 (스테이징 전)
git restore --staged <파일>     # 스테이징 취소 (add 취소)
git commit --amend              # 마지막 커밋 수정 (push 전)

# 임시 저장
git stash                       # 현재 작업 임시 저장
git stash pop                   # 임시 저장 복원
```

### GitHub CLI 명령어

```bash
# 레포
gh browse                       # 브라우저에서 레포 열기
gh repo view                    # 레포 정보 확인

# PR
gh pr create --title "..." --body "..."   # PR 생성
gh pr list                      # PR 목록
gh pr list --author @me         # 내 PR 목록
gh pr view <번호>               # PR 상세
gh pr diff <번호>               # PR 변경사항
gh pr merge <번호> --squash     # Squash Merge
gh pr view <번호> --web         # 브라우저에서 PR 열기

# 이슈
gh issue create --title "..." --label bug
gh issue list
gh issue list --label "bug"

# 팀원 관련
gh api repos/move378/AiCar-AutoCommerce/collaborators --jq '.[].login'
```

---

## 10. FAQ

### Q. feature 브랜치에서 커밋을 많이 해도 되나요?

네. Squash Merge를 사용하므로 feature 브랜치의 모든 커밋은 main에 머지될 때 하나로 합쳐진다. `wip`, `fix typo` 같은 중간 커밋을 자유롭게 해도 된다.

### Q. 다른 팀원의 feature 브랜치에서 같이 작업해도 되나요?

가능하지만 권장하지 않는다. 같은 브랜치에서 동시 작업하면 충돌이 빈번해진다. 기능을 더 작은 단위로 나누어 각자 별도 브랜치에서 작업하는 것을 권장한다.

### Q. 충돌이 발생하면 어떻게 하나요?

```bash
# rebase 중 충돌 발생 시
# 1. VSCode에서 충돌 파일을 열면 시각적으로 비교/해결 가능
code .

# 2. 충돌 해결 후
git add <충돌 해결한 파일>
git rebase --continue

# 3. rebase를 포기하고 원래 상태로 돌아가려면
git rebase --abort
```

### Q. 잘못된 브랜치에서 작업했어요

```bash
# 변경사항을 임시 저장
git stash

# 올바른 브랜치로 이동
git switch feat/backend/correct-branch

# 임시 저장한 변경사항 복원
git stash pop
```

### Q. push 한 커밋을 수정하고 싶어요

이미 push한 커밋은 `--amend`로 수정하면 force push가 필요하다. feature 브랜치에서는 괜찮지만, **main에서는 절대 force push 하지 않는다.**

```bash
# feature 브랜치에서 마지막 커밋 수정 후
git commit --amend -m "수정된 메시지"
git push --force-with-lease origin feat/backend/my-feature
```

### Q. `git push --force`와 `--force-with-lease`의 차이는?

- `--force`는 원격 브랜치를 무조건 덮어쓴다 (다른 사람 작업 유실 위험)
- `--force-with-lease`는 내가 마지막으로 본 상태와 원격이 다르면 거부한다 (안전장치)
- **항상 `--force-with-lease`를 사용한다**

---

> **이 가이드에 대한 질문이나 개선 제안은 GitHub Issue로 등록해주세요.**
