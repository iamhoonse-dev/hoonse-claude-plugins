---
name: api-convention
description: RESTful API 설계 규약을 정의합니다. API 엔드포인트, 요청/응답 형식, 에러 처리 등 백엔드 API 설계 시 이 지침을 따릅니다.
user-invocable: false
---

## RESTful API 설계 규약

이 문서는 RESTful API를 설계할 때 따라야 하는 규약을 정의합니다.

### 1. URL 설계 규칙

| 규칙 | 올바른 예 | 잘못된 예 |
|------|-----------|-----------|
| 리소스는 복수 명사 사용 | `/users`, `/orders` | `/user`, `/order` |
| kebab-case 사용 | `/order-items` | `/orderItems`, `/order_items` |
| 계층 관계는 경로로 표현 | `/users/{id}/orders` | `/getUserOrders` |
| 동사 사용 금지 | `GET /users` | `GET /getUsers` |
| 소문자만 사용 | `/users` | `/Users` |
| 끝에 슬래시 없음 | `/users` | `/users/` |

```
# 기본 리소스
GET    /api/v1/users
GET    /api/v1/users/{user_id}

# 하위 리소스
GET    /api/v1/users/{user_id}/orders
GET    /api/v1/users/{user_id}/orders/{order_id}

# 비-CRUD 동작 (예외적으로 동사 허용)
POST   /api/v1/users/{user_id}/activate
POST   /api/v1/orders/{order_id}/cancel
```

### 2. HTTP 메서드 사용 규칙

| 메서드 | 용도 | 멱등성 | 요청 본문 | 예시 |
|--------|------|--------|-----------|------|
| `GET` | 리소스 조회 | O | X | `GET /users/{id}` |
| `POST` | 리소스 생성 | X | O | `POST /users` |
| `PUT` | 리소스 전체 교체 | O | O | `PUT /users/{id}` |
| `PATCH` | 리소스 부분 수정 | X | O | `PATCH /users/{id}` |
| `DELETE` | 리소스 삭제 | O | X | `DELETE /users/{id}` |

**멱등성 원칙**: 같은 요청을 여러 번 보내도 결과가 동일해야 하는 메서드(`GET`, `PUT`, `DELETE`)는 반드시 멱등하게 구현합니다.

### 3. 상태 코드 규칙

#### 2xx 성공

| 코드 | 의미 | 사용 시점 |
|------|------|-----------|
| `200 OK` | 성공 | `GET`, `PUT`, `PATCH` 성공 시 |
| `201 Created` | 생성 완료 | `POST`로 리소스 생성 시 |
| `204 No Content` | 본문 없는 성공 | `DELETE` 성공 시 |

#### 4xx 클라이언트 오류

| 코드 | 의미 | 사용 시점 |
|------|------|-----------|
| `400 Bad Request` | 잘못된 요청 | 요청 형식 오류, 유효성 검사 실패 |
| `401 Unauthorized` | 인증 필요 | 인증 토큰 누락 또는 만료 |
| `403 Forbidden` | 권한 없음 | 인증되었으나 해당 리소스 접근 권한 없음 |
| `404 Not Found` | 리소스 없음 | 요청한 리소스가 존재하지 않음 |
| `409 Conflict` | 충돌 | 중복 생성, 동시 수정 충돌 |
| `422 Unprocessable Entity` | 처리 불가 | 형식은 맞지만 비즈니스 규칙 위반 |

#### 5xx 서버 오류

| 코드 | 의미 | 사용 시점 |
|------|------|-----------|
| `500 Internal Server Error` | 서버 내부 오류 | 예상치 못한 서버 오류 |
| `502 Bad Gateway` | 게이트웨이 오류 | 업스트림 서버 응답 오류 |
| `503 Service Unavailable` | 서비스 불가 | 서버 과부하, 유지보수 중 |

### 4. 요청/응답 형식

모든 요청과 응답은 `application/json`을 기본으로 합니다.

#### 단일 리소스 응답

```json
{
  "id": 1,
  "email": "user@example.com",
  "name": "홍길동",
  "created_at": "2024-01-15T09:30:00Z"
}
```

#### 목록 응답

```json
{
  "items": [
    {
      "id": 1,
      "email": "user@example.com",
      "name": "홍길동"
    }
  ],
  "total": 100,
  "limit": 20,
  "offset": 0
}
```

#### 생성 요청

```json
{
  "email": "user@example.com",
  "name": "홍길동",
  "password": "securePassword123"
}
```

### 5. 에러 응답 형식

#### 표준 에러 구조

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "요청한 사용자를 찾을 수 없습니다.",
    "details": null
  }
}
```

#### 유효성 검사 에러

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "요청 데이터 유효성 검사에 실패했습니다.",
    "details": [
      {
        "field": "email",
        "message": "올바른 이메일 형식이 아닙니다."
      },
      {
        "field": "password",
        "message": "비밀번호는 최소 8자 이상이어야 합니다."
      }
    ]
  }
}
```

#### 에러 코드 규칙

| 카테고리 | 코드 예시 | 설명 |
|----------|-----------|------|
| 인증 | `UNAUTHORIZED`, `TOKEN_EXPIRED` | 인증 관련 오류 |
| 권한 | `FORBIDDEN`, `INSUFFICIENT_PERMISSIONS` | 권한 관련 오류 |
| 리소스 | `RESOURCE_NOT_FOUND`, `RESOURCE_ALREADY_EXISTS` | 리소스 관련 오류 |
| 유효성 | `VALIDATION_ERROR`, `INVALID_FORMAT` | 입력값 관련 오류 |
| 서버 | `INTERNAL_ERROR`, `SERVICE_UNAVAILABLE` | 서버 관련 오류 |

### 6. 페이지네이션

offset/limit 기반 페이지네이션을 사용합니다.

#### 요청

```
GET /api/v1/users?offset=0&limit=20
```

| 파라미터 | 타입 | 기본값 | 설명 |
|----------|------|--------|------|
| `offset` | integer | `0` | 건너뛸 항목 수 |
| `limit` | integer | `20` | 반환할 최대 항목 수 (최대 100) |

#### 응답

```json
{
  "items": [...],
  "total": 100,
  "limit": 20,
  "offset": 0
}
```

### 7. 필터링 및 정렬

#### 필터링

쿼리 파라미터로 필터링합니다. 필드명은 snake_case를 사용합니다.

```
GET /api/v1/users?status=active&role=admin
GET /api/v1/orders?created_after=2024-01-01&min_amount=10000
```

#### 정렬

`sort` 파라미터를 사용합니다. `-` 접두사는 내림차순을 의미합니다.

```
GET /api/v1/users?sort=created_at        # 오름차순
GET /api/v1/users?sort=-created_at       # 내림차순
GET /api/v1/users?sort=-created_at,name  # 복합 정렬
```

### 8. API 버전 관리

URL path 방식으로 버전을 관리합니다.

```
/api/v1/users
/api/v2/users
```

| 규칙 | 설명 |
|------|------|
| 형식 | `/api/v{major}/...` |
| 버전 변경 시점 | Breaking Change 발생 시 |
| 하위 호환 변경 | 기존 버전에서 처리 (필드 추가 등) |
| 지원 정책 | 이전 버전은 최소 6개월 유지 |

### 9. 인증 및 보안

#### Bearer Token 인증

```
Authorization: Bearer <access_token>
```

#### 인증 상태별 응답

| 상황 | 상태 코드 | 에러 코드 |
|------|-----------|-----------|
| 토큰 누락 | `401 Unauthorized` | `UNAUTHORIZED` |
| 토큰 만료 | `401 Unauthorized` | `TOKEN_EXPIRED` |
| 토큰 유효하지만 권한 부족 | `403 Forbidden` | `FORBIDDEN` |
| 토큰 형식 오류 | `401 Unauthorized` | `INVALID_TOKEN` |

#### 보안 필수 사항

- 모든 API는 HTTPS를 통해서만 제공
- 민감 정보(비밀번호, 토큰 등)는 응답에 포함하지 않음
- Rate limiting 적용 (`429 Too Many Requests` 반환)
- CORS 설정은 허용된 도메인만 명시적으로 지정

### 10. 네이밍 규칙

| 대상 | 규칙 | 예시 |
|------|------|------|
| URL 경로 | kebab-case | `/order-items` |
| 쿼리 파라미터 | snake_case | `?created_at=...` |
| JSON 필드 (요청/응답) | snake_case | `"user_name"`, `"created_at"` |
| Path 파라미터 | snake_case | `/{user_id}` |
| 에러 코드 | UPPER_SNAKE_CASE | `RESOURCE_NOT_FOUND` |
| HTTP 헤더 | 표준 형식 | `Authorization`, `Content-Type` |
