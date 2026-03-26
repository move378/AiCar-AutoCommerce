# AiCar AutoCommerce - Project Context

## 프로젝트 개요
차량 데이터 플랫폼. 딜러십 매칭, 재고 정보 제공, 시승 위치 탐색 기능 포함.

---

## 기술 스택

### Go Backend
- **Framework**: Gin
- **DB**: PostgreSQL + GORM
- **Cache**: Redis (go-redis/v9)
- **Auth**: JWT (Access / Refresh 시크릿 분리)
- **Migration**: Goose
- **Hot Reload**: Air
- **Docs**: swaggo/swag
- **Docker**: DB + Redis만 컨테이너로 운영

### Python Crawler Pipeline
- **크롤러**: Playwright
- **DB**: PostgreSQL (직접 연결)
- **대상**: 메르세데스-벤츠 코리아, 한국에너지공단 수송통합시스템

---

## 아키텍처

### Go Backend - 클린 아키텍처
```
Handler → Usecase → Repository
```

#### 디렉토리 구조
```
app/
  auth/
    auth_handler.go
    social_handler.go
    user_handler.go
```

#### 주요 패턴
- **트랜잭션**: `TxManager` 인터페이스 + `GetTx(ctx, db)` 컨텍스트 키 방식
- **소셜 로그인**: Kakao / Google / Apple OAuth
- **토큰 블랙리스트**: Redis `bl:token` 키 (로그아웃 시에만 등록)
- **소셜 캐시 키**: `provider:providerToken` 형식

#### 구현 완료
- JWT 미들웨어
- Access Token 블랙리스트 (Redis)
- Refresh Token 관리
- 로그아웃 / 회원탈퇴 (`DeleteAccount` 트랜잭션)
- `OnboardingRefresh` (게스트 디바이스 재인증)
- `GetProfile` 엔드포인트
- 위치 정보 (lat/lng, `DECIMAL` 타입, `entity.User`에 저장)

---

### Python Crawler Pipeline

#### 파서 구조
| 파일 | 역할 |
|------|------|
| `summary_parser.py` | EV/ICE 분기, 이미지 URL 생성, `vehicles_trim_images` 테이블 |
| `inventory_parser.py` | baumuster 기반 트림 매핑 (앞 7자리) |
| `fuel_efficiency.py` | Playwright 크롤러, POST AHP_L.do 인터셉트 |
| `fuel_efficiency_parser.py` | 트림 매칭 (`normalize()`), ice_spec/ev_spec 업데이트 |

#### 핵심 규칙
- **baumuster**: 재고 ↔ 요약 매핑의 기준 키 (이름 매핑보다 신뢰도 높음)
- **CSRF 토큰**: 페이지 로드마다 동적으로 추출 필요
- **body_type**: 정규화 없이 raw 값 그대로 저장 (팀장님 결정)
- 이미지 POV 코드: `BE020`, `BE090`, `BIS1`
- EV → `ev_spec`, 나머지 → `ice_spec`

#### 데이터 저장 경로
```
crawlers/{brand}/data/fuel_efficiency.json
```

---

## 개발 규칙

- 네이밍: `social` 통일 (예: `SocialRepository`)
- `socialUsecase`는 `userUsecase`에 흡수됨
- `authUsecase`는 토큰 로직 전담
- Access Token TTL이 짧으므로 refresh 시 블랙리스트 불필요, 로그아웃 시에만 등록
- 불필요한 복잡도 지양, 가장 단순한 해결책 우선

---

## 미구현 / 예정

- 전화번호 인증 (보류)
- RBAC (소셜 로그인과 함께 구현 예정)
- AWS Secrets Manager (프로덕션 시크릿 관리)
- 배터리 용량 데이터 정확한 소스 확보
- 벤츠 외 브랜드 크롤러 확장