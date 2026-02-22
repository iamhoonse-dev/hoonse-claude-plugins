---
name: issue-convention
description: project-analyzer가 생성하는 GitHub Issue의 작성 규약을 정의합니다. 분석 결과를 이슈로 변환할 때 이 지침을 따릅니다.
user-invocable: false
---

## Issue 작성 규약

이 규약은 `project-analyzer` 플러그인이 분석 결과를 GitHub Issue로 변환할 때 사용하는 표준 형식을 정의합니다.

> **프로젝트 독립적 설계**: 이 플러그인은 어떤 프로젝트에서든 사용될 수 있으므로, 특정 프로젝트의 `.github/ISSUE_TEMPLATE/`에 종속되지 않는 범용 규약을 따릅니다.

### Issue 제목 형식

```
[<severity>] <category>(<scope>): <description>
```

| 요소 | 설명 | 허용 값 |
|------|------|---------|
| severity | 심각도 | `error`, `warning`, `info` |
| category | 분석 카테고리 | `structure`, `docs`, `settings` |
| scope | 대상 범위 | 플러그인명 또는 `project` |
| description | 문제 설명 | 한국어, 명사형, 마침표 없음 |

#### 제목 예시

```
[error] structure(git-workflow): 필수 파일 plugin.json 누락
[warning] docs(git-workflow): README 필수 섹션 '설치 방법' 누락
[info] settings(project): marketplace.json에 미등록 플러그인 발견
```

### 라벨

프로젝트에 아래 라벨이 존재하면 사용하고, 없으면 라벨 없이 생성합니다. 라벨이 없더라도 제목의 `[severity]`와 `category`로 분류가 가능합니다.

| 라벨 | 용도 |
|------|------|
| `analyzer:structure` | 디렉토리 구조/프론트매터/네이밍 관련 |
| `analyzer:docs` | 문서 품질/정확성 관련 |
| `analyzer:settings` | 설정 파일 정합성 관련 |
| `severity:error` | 즉시 수정 필요 |
| `severity:warning` | 개선 권장 |

### Issue 본문 템플릿

```markdown
## 분석 결과

<발견된 문제에 대한 구체적 설명>

## 기대 상태

<올바른 상태가 무엇인지 설명>

## 제안 수정 방법

<문제 해결을 위한 구체적 단계>

## 관련 파일

- `<파일 경로 1>`
- `<파일 경로 2>`

---

> 이 이슈는 `project-analyzer` 플러그인에 의해 자동 생성되었습니다.
```

### 그룹핑 정책

분석 결과를 이슈로 변환할 때 다음 그룹핑 정책을 적용합니다:

| 심각도 | 정책 | 이유 |
|--------|------|------|
| `error` | **개별 이슈** 생성 | 즉시 수정이 필요하므로 독립 추적 |
| `warning` / `info` | 동일 플러그인+카테고리를 **하나의 이슈**에 체크리스트로 그룹 | 관련 항목을 한곳에서 관리 |

#### 그룹 이슈 제목 형식

```
[warning] docs(git-workflow): 문서 개선 사항 N건
```

#### 그룹 이슈 본문 (체크리스트)

```markdown
## 분석 결과

다음 항목들이 발견되었습니다:

- [ ] README 필수 섹션 '개요' 누락
- [ ] README 필수 섹션 '설치 방법' 누락
- [ ] Mermaid 다이어그램 미포함

## 기대 상태

각 항목이 플러그인 README 작성 규약에 따라 보완되어야 합니다.

## 제안 수정 방법

1. `plugins/git-workflow/README.md`를 열어 누락된 섹션을 추가합니다.
1. `plugin-readme-structure` 스킬의 규약을 참조하세요.

## 관련 파일

- `plugins/git-workflow/README.md`

---

> 이 이슈는 `project-analyzer` 플러그인에 의해 자동 생성되었습니다.
```

### `gh issue create` 명령어 형식

이슈 생성 시 다음 HEREDOC 형식을 사용합니다:

#### 개별 이슈

```bash
gh issue create --title "[error] structure(git-workflow): 필수 파일 plugin.json 누락" --body "$(cat <<'EOF'
## 분석 결과

`git-workflow` 플러그인 디렉토리에 필수 파일 `.claude-plugin/plugin.json`이 존재하지 않습니다.

## 기대 상태

모든 플러그인은 `.claude-plugin/plugin.json` 파일을 포함해야 합니다.

## 제안 수정 방법

1. `plugins/git-workflow/.claude-plugin/plugin.json` 파일을 생성합니다.
1. name, description, version, author 등 필수 필드를 작성합니다.

## 관련 파일

- `plugins/git-workflow/.claude-plugin/plugin.json` (누락)

---

> 이 이슈는 `project-analyzer` 플러그인에 의해 자동 생성되었습니다.
EOF
)"
```

#### 라벨 포함 (라벨이 존재하는 경우)

```bash
gh issue create --title "[error] structure(git-workflow): 필수 파일 plugin.json 누락" \
  --label "analyzer:structure" --label "severity:error" \
  --body "$(cat <<'EOF'
...
EOF
)"
```

### 중복 체크

이슈 생성 전 기존 이슈와 중복되지 않는지 확인합니다:

```bash
gh issue list --search "[error] structure(git-workflow)" --state open --json number,title
```

동일한 제목 패턴의 열린 이슈가 있으면 생성을 건너뛰고, 해당 이슈 번호를 보고합니다.
