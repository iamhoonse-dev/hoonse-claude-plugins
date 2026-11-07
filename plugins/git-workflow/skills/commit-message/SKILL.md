---
name: commit-message
description: 커밋 메시지 작성의 기본 규약입니다. 프로젝트에 별도 규약이 없을 때 git commit 메시지 작성에 사용합니다.
user-invocable: false
---

## 커밋 메시지 기본 규약

> 이 문서는 git-workflow 플러그인의 **기본 규약**이에요.
> 프로젝트에 아래 중 하나가 있으면 그것을 우선해요.
>
> 1. 프로젝트의 `.claude/skills/commit-message/SKILL.md`
> 1. `CLAUDE.md` / `AGENTS.md` 의 커밋 규칙
> 1. 최근 커밋 기록(`git log`)에서 드러나는 일관된 형식

[Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) 을 따릅니다.

### 메시지 형식

```
<type>[(scope)][!]: <description>

[body]

[footer(s)]
```

### type

| type | 사용 시점 |
|------|-----------|
| `feat` | 새로운 기능 추가 |
| `fix` | 버그 수정 |
| `docs` | 문서만 변경 |
| `style` | 동작에 영향 없는 포매팅 |
| `refactor` | 동작 변화 없는 구조 개선 |
| `perf` | 성능 개선 |
| `test` | 테스트 추가/수정 |
| `build` | 빌드 도구, 의존성 변경 |
| `ci` | CI/CD 설정 변경 |
| `chore` | 그 외 유지보수 |

### scope

- 변경 범위가 분명하면 괄호로 표기해요. (예: `feat(auth):`)
- 모노레포라면 앱/패키지 이름을 scope 로 써요. (예: `fix(web):`)
- 여러 범위에 걸치거나 전역 변경이면 생략해요.

### 작성 규칙

- 첫째 줄은 72자 이내, 끝에 마침표를 붙이지 않아요.
- 언어는 프로젝트의 기존 커밋 언어를 따라요. 판단할 수 없으면 사용자와 대화하는 언어를 써요.
- body 에는 **무엇을, 왜** 바꿨는지 적어요. description 으로 충분하면 생략해요.
- 관련 이슈가 있으면 footer 에 `Refs #<번호>` 로 남겨요.
- 성격이 다른 변경은 커밋을 나눠요.

### Breaking Change

- `feat!:` / `feat(scope)!:` 처럼 `!` 를 붙이거나
- footer 에 `BREAKING CHANGE: <설명>` 을 추가해요.

### 예시

```
feat(auth): 소셜 로그인 추가

Refs #12
```

```
fix: 빈 목록에서 페이지네이션이 깨지는 오류 수정

항목이 0개일 때 전체 페이지 수가 0 으로 계산되어
이전/다음 버튼이 모두 비활성화되던 문제를 고침
```
