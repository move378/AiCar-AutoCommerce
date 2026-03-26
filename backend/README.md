# AiCar Backend API

Go (Gin) 기반 수입차 AI 컨시어지 앱 백엔드 서버.

- **Base URL:** `http://localhost:8080/api/v1`
- **Swagger UI:** `http://localhost:8080/swagger/index.html`
- **인증 방식:** `Authorization: Bearer {accessToken}`

---

## 서버 실행

```bash
make docker-up     # PostgreSQL + Redis 컨테이너 실행
make migrate-up    # DB 마이그레이션 적용
make dev           # 핫리로드 개발 서버 실행
make swagger       # Swagger docs 재생성
```

---

## API 목록

### Auth — 인증

| 메서드 | 경로 | 인증 | 설명 |
|--------|------|:----:|------|
| POST | `/auth/onboard` | ✗ | 디바이스 최초 진입 시 호출. 디바이스 등록 + 게스트 유저 생성 + AccessToken/RefreshToken 발급. 앱 설치 후 가장 먼저 호출해야 하는 엔드포인트. |
| POST | `/auth/onboard/refresh` | ✗ | 게스트 디바이스 토큰 재발급. 앱 재설치 등으로 토큰이 만료된 게스트 유저가 재인증할 때 사용. 이미 회원가입된 유저는 사용 불가. |
| POST | `/auth/refresh` | ✗ | RefreshToken으로 AccessToken + RefreshToken 재발급. AccessToken 만료 시 호출. |
| POST | `/auth/agreed` | ✗ | 마케팅 활용 동의 여부 저장/수정. 온보딩 플로우 중 동의 화면에서 호출. |
| POST | `/auth/kakao-login` | ✓ | 카카오 AccessToken으로 소셜 로그인/회원가입. 게스트 유저가 카카오 계정과 연동될 때 호출. `is_new_user` 플래그로 신규/기존 유저 구분 가능. |
| POST | `/auth/google-login` | ✓ | 구글 ID 토큰으로 소셜 로그인/회원가입. |
| POST | `/auth/apple-login` | ✓ | 애플 Identity Token으로 소셜 로그인/회원가입. |

### User — 유저

| 메서드 | 경로 | 인증 | 설명 |
|--------|------|:----:|------|
| GET | `/user/me` | ✓ | 현재 로그인된 유저 프로필 조회. 닉네임, 이메일, 소셜 연동 여부 등 반환. |
| POST | `/user/logout` | ✓ | 로그아웃. 현재 AccessToken을 블랙리스트에 등록하여 즉시 무효화. |
| DELETE | `/user/me` | ✓ | 회원탈퇴. 유저 및 관련 데이터 삭제. |

---

### Vehicles — 차량 (크롤링 데이터 기반)

> 크롤러로 수집된 실제 수입차 스펙 데이터. 현재 Mercedes-Benz 데이터 적재됨.

| 메서드 | 경로 | 인증 | 설명 |
|--------|------|:----:|------|
| GET | `/vehicles` | ✗ | 차량 키워드 검색. `?q=벤츠`, `?q=E 200` 형태로 브랜드명(한국어 별칭 포함)·모델명·트림명 검색 가능. `page`, `size` 파라미터로 페이지네이션. |
| GET | `/vehicles/:id` | ✗ | 트림 ID로 상세 스펙 조회. 엔진/EV 스펙, 치수, 이미지 포함. |
| GET | `/vehicles/brands` | ✗ | 브랜드 목록 조회. 브랜드 ID, 이름, 국가, 로고 URL 반환. |

**검색 예시:**
```
GET /api/v1/vehicles?q=벤츠          → Mercedes-Benz 전체
GET /api/v1/vehicles?q=E 200         → E 200 트림
GET /api/v1/vehicles?q=GLE&page=1&size=5
```

---

### Cars — 차량 (레거시)

> `vehicles`로 대체 예정인 구형 차량 테이블.

| 메서드 | 경로 | 인증 | 설명 |
|--------|------|:----:|------|
| GET | `/cars` | ✗ | 차량 목록 조회. 키워드·브랜드·연료타입·가격 범위 등 필터 지원. |
| GET | `/cars/:id` | ✗ | 차량 상세 조회. |
| GET | `/cars/:id/images` | ✗ | 차량 이미지 목록 조회. |

---

### Brands — 브랜드 (레거시)

| 메서드 | 경로 | 인증 | 설명 |
|--------|------|:----:|------|
| GET | `/brands` | ✗ | 브랜드 목록 조회. (`vehicles/brands`와 다른 레거시 테이블) |

---

### My Car — 내 차량

| 메서드 | 경로 | 인증 | 설명 |
|--------|------|:----:|------|
| POST | `/cars/register` | ✗ | 내 차량 등록. 유저가 보유한 차량을 My Garage에 추가. |
| GET | `/cars/register/:user_id` | ✗ | 특정 유저의 등록 차량 목록 조회. |

---

### Chat — 채팅

> AI 컨시어지와의 대화 기록 저장/조회. AI 응답 생성은 별도 서비스에서 처리 후 이 API로 저장.

| 메서드 | 경로 | 인증 | 설명 |
|--------|------|:----:|------|
| POST | `/chat/sessions` | ✓ | 새 채팅 세션 생성. `title` 선택 입력 (없으면 NULL로 저장). |
| GET | `/chat/sessions` | ✓ | 내 채팅 세션 목록 조회. 최근 업데이트순 정렬. |
| DELETE | `/chat/sessions/:id` | ✓ | 채팅 세션 삭제 (soft delete). |
| POST | `/chat/sessions/:id/messages` | ✓ | 메시지 저장. `role`은 `user` 또는 `assistant`. 차량 추천 등 구조화 데이터는 `metadata`(JSON 문자열)에 담아 저장. |
| GET | `/chat/sessions/:id/messages` | ✓ | 세션의 전체 메시지 조회. 시간순 정렬. |
| PATCH | `/chat/messages/:id/feedback` | ✓ | AI 응답 메시지에 피드백 등록. `feedback`은 `"like"` 또는 `"dislike"`. |

**메시지 저장 예시:**
```json
POST /api/v1/chat/sessions/{id}/messages
{
  "role": "user",
  "content": "벤츠 E클래스 추천해줘"
}

POST /api/v1/chat/sessions/{id}/messages
{
  "role": "assistant",
  "content": "E 200 AVANTGARDE를 추천드립니다.",
  "metadata": "{\"vehicles\": [{\"id\": \"...\", \"name\": \"E 200\"}]}"
}
```

---

## 공통 응답 형식

```json
{
  "code": "SUCCESS",
  "data": { ... }
}
```

오류 시:
```json
{
  "code": "UNAUTHORIZED",
  "message": "유효하지 않은 토큰입니다"
}
```
