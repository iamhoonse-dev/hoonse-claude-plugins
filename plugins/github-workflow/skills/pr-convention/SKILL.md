---
name: pr-convention
description: Pull Request 작성의 기본 규약입니다. 프로젝트에 별도 규약이 없을 때 PR 생성에 사용합니다.
user-invocable: false
---

## Pull Request 기본 규약

> 이 문서는 github-workflow 플러그인의 **기본 규약**이에요.
> 프로젝트에 아래 중 하나가 있으면 그것을 우선해요.
>
> 1. 프로젝트의 `.claude/skills/pr-convention/SKILL.md`
> 1. `CLAUDE.md` / `AGENTS.md` 의 PR 규칙
> 1. 레포의 PR 템플릿 — 본문 구조는 템플릿을 그대로 따라요.
>    (`.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md`,
>    `.github/PULL_REQUEST_TEMPLATE/*.md`, `docs/`, 루트 등 GitHub 이 인식하는 위치)

### PR 제목

- 커밋 규약과 같은 형식을 써요. (기본: `<type>[(scope)]: <description>`)
- 72자 이내, 끝에 마침표를 붙이지 않아요.
- 언어는 프로젝트의 기존 커밋/PR 언어를 따라요.

### PR 본문

**PR 템플릿이 있으면** 템플릿의 섹션을 순서대로 **빠짐없이** 채워요.

- 체크박스 항목은 실제로 해당하는 것만 체크해요.
- 해당 사항이 없는 섹션은 지우지 말고 "해당 없음"이라고 적어요.
- 템플릿의 HTML 주석(`<!-- -->`)은 안내문이므로 지워도 돼요.

**템플릿이 없으면** 다음 구조를 써요.

```markdown
## 요약

- <왜 이 변경이 필요한지 1~3줄>

## 관련 이슈

Closes #<번호>

## 변경 사항

- <구체적인 변경 1>
- <구체적인 변경 2>

## 검증

- [x] <직접 확인한 것>
- [ ] <확인하지 못한 것 — 이유>

## 리뷰어에게

<함께 수정해야 하는 곳, 알려진 제한, 후속 작업 등>
```

### 공통 규칙

- 브랜치의 **모든 커밋**을 반영해요. 마지막 커밋만 보고 쓰지 않아요.
- 관련 이슈가 있으면 `Closes #<번호>` 로 연결해요.
- **검증한 것과 검증하지 못한 것을 구분**해서 적어요. (pr-verification 스킬 참고)
- 머지 후에만 확인할 수 있는 변경(GitHub Actions, 이슈 템플릿 등)은 머지 후 확인 절차를 적어요.

### 라벨

- 프로젝트 규약에 라벨 규칙이 있으면 따라요.
- 없으면 type 기준으로 기존 라벨만 붙여요: `feat`→`enhancement`, `fix`→`bug`, `docs`→`documentation`
- 붙이기 전에 `gh label list --search "<label>" --json name` 으로 존재 여부를 확인하고, 없는 라벨은 만들지 않고 건너뛰어요.

### `gh pr create` 형식

```bash
gh pr create --base <기본 브랜치> --title "<제목>" [--label "<라벨>"] --body "$(cat <<'BODY'
<본문>
BODY
)"
```
