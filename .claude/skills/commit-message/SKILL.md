---
name: commit-message
description: 이 프로젝트의 커밋 메시지 작성 규약을 정의합니다. git commit 메시지 작성 시 이 지침을 따릅니다.
user-invocable: false
---

## 커밋 메시지 작성 규약

이 프로젝트는 [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) 스펙을 따릅니다.

### 메시지 형식

```
<type>[(scope)][!]: <description>

[body]

[footer(s)]
```

### 구성 요소

| 요소 | 필수 여부 | 설명 |
|------|-----------|------|
| type | 필수 | 변경 사항의 종류를 나타내는 접두사 |
| scope | 선택 | 변경 범위를 괄호로 감싸서 표기 (예: `feat(agent):`) |
| `!` | 선택 | Breaking Change 표시, 콜론 바로 앞에 위치 (예: `feat!:`) |
| description | 필수 | 변경 사항에 대한 간결한 요약 |
| body | 선택 | 변경의 동기나 맥락을 설명, 빈 줄로 구분 |
| footer | 선택 | `BREAKING CHANGE:`, `Co-Authored-By:` 등 메타데이터 |

### 허용되는 type 목록

| type | 의미 | 사용 시점 |
|------|------|-----------|
| `feat` | 새로운 기능 추가 | 완전히 새로운 기능을 도입할 때 |
| `fix` | 버그 수정 | 기존 동작의 오류를 고칠 때 |
| `docs` | 문서 변경 | README, SKILL.md 등 문서만 수정할 때 |
| `style` | 코드 스타일 변경 | 포매팅, 세미콜론 등 동작에 영향 없는 변경 |
| `refactor` | 리팩토링 | 기능 변경 없이 코드 구조를 개선할 때 |
| `perf` | 성능 개선 | 성능을 향상시키는 코드 변경 |
| `test` | 테스트 | 테스트 추가 또는 수정 |
| `build` | 빌드 시스템 | 빌드 도구, 의존성 등의 변경 |
| `ci` | CI 설정 | CI/CD 파이프라인 설정 변경 |
| `chore` | 기타 작업 | 위 분류에 해당하지 않는 유지보수 작업 |

### scope 사용 기준

이 프로젝트는 모노레포 구조이므로 scope를 다음과 같이 사용합니다:

- 프로젝트 전역 변경: scope 생략 또는 대상 명시 (예: `docs(readme):`)
- 특정 플러그인 변경: 플러그인 이름을 scope로 사용 (예: `feat(git-workflow):`)
- 마켓플레이스 설정 변경: `marketplace`를 scope로 사용 (예: `fix(marketplace):`)
- 에이전트/스킬 변경: `agent`, `skill`을 scope로 사용 (예: `fix(agent):`)

### 글자 수 제한

- **첫째 줄(type + scope + description) 전체**: 72자 이내
- **body 각 줄**: 72자 이내로 줄바꿈

### description 작성 규칙

- 한국어로 작성
- 명사형 종결 사용 (예: "로그인 기능 추가", "인증 오류 수정")
- 끝에 마침표(`.`) 붙이지 않음
- "무엇을 했는가"보다 "왜 했는가"에 초점

### body 작성 규칙

- 한국어로 작성
- description만으로 충분하면 생략 가능
- 변경의 동기, 이전 동작과의 차이점 등을 설명

### Breaking Change 표기

다음 두 가지 방법 중 하나 이상 사용:

1. type/scope 뒤에 `!` 추가: `feat!:` 또는 `feat(scope)!:`
1. footer에 `BREAKING CHANGE: 설명` 추가 (반드시 대문자)

### 예시

```
feat(git-workflow): 자동 커밋 에이전트 추가
```

```
fix(agent): tech-doc-writer에서 하드코딩된 절대 경로의
agent memory 섹션 제거

memory: project frontmatter 설정이 런타임에 올바른 경로로
자동 주입하므로 본문에 하드코딩된 Persistent Agent Memory
섹션은 중복이자 다른 작업자 환경에서 잘못된 경로를 가리키는
원인이 됨
```

```
feat!: 단일 플러그인 구조에서 모노레포 구조로 변경

BREAKING CHANGE: 기존 단일 플러그인 디렉토리 구조가
plugins/ 하위의 모노레포 구조로 변경됨
```
