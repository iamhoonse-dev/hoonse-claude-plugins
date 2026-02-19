---
name: pr-convention
description: 이 프로젝트의 Pull Request 작성 규약을 정의합니다. PR 생성 시 이 지침을 따릅니다.
user-invocable: false
---

## Pull Request 작성 규약

이 프로젝트는 `.github/PULL_REQUEST_TEMPLATE.md`의 구조를 기반으로 PR을 작성합니다.

### PR 제목 규칙

Conventional Commits와 동일한 형식을 사용합니다:

```
<type>[(scope)]: <description>
```

| 규칙 | 설명 |
|------|------|
| 형식 | `<type>[(scope)]: <description>` |
| 글자 수 | 72자 이내 |
| 언어 | 한국어 |
| 종결 | 명사형 (예: "로그인 기능 추가", "인증 오류 수정") |
| 마침표 | 붙이지 않음 |

### 허용되는 type 목록

`feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`

### scope 사용 기준

- 특정 플러그인 변경: 플러그인 이름을 scope로 사용 (예: `feat(github-workflow):`)
- 프로젝트 전역 변경: scope 생략 또는 대상 명시 (예: `docs(readme):`)
- 마켓플레이스 설정 변경: `marketplace`를 scope로 사용

### PR 본문 구조

PR 본문은 다음 섹션을 순서대로 포함합니다:

#### 1. Summary

- 변경의 "이유(why)"를 설명 (무엇을 했는지가 아님)
- 1~3개의 불릿 포인트로 요약

#### 2. Related Issue

- 관련 이슈 번호를 링크
- `Closes #<number>` 형식으로 자동 닫기 설정

#### 3. Change Type

- 해당하는 타입 하나를 체크박스로 선택
- 커밋 타입과 일치해야 함

#### 4. Affected Plugin(s)

- 영향받는 플러그인을 체크박스로 선택
- 복수 선택 가능

#### 5. Changes Made

- 구체적인 변경 사항을 불릿 리스트로 나열
- 파일 단위 또는 기능 단위로 정리

#### 6. Testing

- 수행한 테스트 단계를 체크리스트로 표시
- 기본 항목: 플러그인 설치, 스킬 동작, 에이전트 동작, 훅 동작, 세션 재시작 확인

#### 7. Checklist

- Conventional Commits 준수 여부
- plugin.json 버전 업데이트 여부
- marketplace.json 업데이트 여부
- 문서 업데이트 여부
- CONTRIBUTING.md 확인 여부

#### 8. Reviewer Notes (선택)

- 리뷰어에게 전달할 사항, 알려진 제한 사항, 후속 작업 등

### `gh pr create` 명령어 형식

PR 생성 시 다음 HEREDOC 형식을 사용합니다:

```bash
gh pr create --title "<type>[(scope)]: <description>" --body "$(cat <<'EOF'
## Summary

- <변경 이유 요약>

## Related Issue

Closes #<number>

## Change Type

- [x] `<type>` — <type description>

## Affected Plugin(s)

- [x] `<plugin-name>`

## Changes Made

- <변경 사항 1>
- <변경 사항 2>

## Testing

- [ ] Plugin installs successfully via `/plugin install`
- [ ] Skills appear in `/skills` and work as expected
- [ ] Agents appear in `/agents` and work as expected
- [ ] Hooks execute correctly on their configured events
- [ ] Verified after restarting Claude Code session

## Checklist

- [x] Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- [ ] `plugin.json` version is updated (if plugin changed)
- [ ] `marketplace.json` is updated (if plugin added or metadata changed)
- [ ] Documentation is updated (README, SKILL.md, etc.)
- [ ] I have read the [CONTRIBUTING.md](https://github.com/iamhoonse-dev/hoonse-claude-plugins/blob/main/CONTRIBUTING.md)

## Reviewer Notes

<선택 사항>
EOF
)"
```

### 예시

```
feat(github-workflow): GitHub Issue 기반 개발 워크플로우 플러그인 추가
```

```
fix(git-workflow): auto-committer에서 스테이징되지 않은 파일 처리 오류 수정
```
