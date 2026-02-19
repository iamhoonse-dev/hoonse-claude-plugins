---
name: branch-strategy
description: 이 프로젝트의 브랜치 전략을 정의합니다. 브랜치 생성 및 관리 시 이 지침을 따릅니다.
user-invocable: false
---

## 브랜치 전략

이 프로젝트는 **trunk-based development** 전략을 따릅니다. `main` 브랜치가 유일한 장기 브랜치이며, 모든 작업은 `main`에서 분기한 짧은 수명의 feature branch에서 진행합니다.

### 전략 선택 근거

| 특성 | 이 프로젝트의 상황 |
|------|---------------------|
| 배포 방식 | 별도의 빌드·배포 파이프라인 없음 (플러그인은 소스 그대로 사용) |
| 버전 관리 | 플러그인별 `plugin.json`의 version 필드로 개별 관리 |
| 메인테이너 규모 | 소규모 |
| 릴리스 주기 | 별도의 릴리스 브랜치 불필요 |

이러한 이유로 Git Flow의 `develop`, `release`, `hotfix` 브랜치는 불필요한 오버헤드이며, trunk-based development가 적합합니다.

### 브랜치 유형

| 브랜치 | 용도 | 수명 |
|--------|------|------|
| `main` | 프로덕션 코드, PR 머지 대상 | 영구 |
| `<type>/<short-description>` | 기능 개발, 버그 수정 등 작업 브랜치 | 단기 (머지 후 삭제) |

### 브랜치 이름 규칙

작업 브랜치의 이름은 다음 형식을 따릅니다:

```
<type>/<short-description>
```

#### type

Conventional Commits의 type을 그대로 사용합니다:

- `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`

#### short-description

- 영문 소문자와 하이픈(`-`)만 사용
- 변경 대상 플러그인이 있으면 플러그인 이름을 접두사로 포함
- 간결하되 작업 내용을 식별할 수 있을 만큼 구체적으로 작성

### 예시

```
feat/hello-plugin-add-visualize-skill
fix/git-workflow-commit-message-typo
docs/contributing-add-pr-guide
refactor/claude-logger-hook-cleanup
ci/add-github-issue-templates
```

### 작업 흐름

1. `main`에서 새 브랜치 분기

   ```bash
   git checkout main
   git pull origin main
   git checkout -b <type>/<short-description>
   ```

1. 작업 브랜치에서 커밋 (commit-message 스킬의 규약을 따름)

1. `main`을 base로 Pull Request 생성

1. 리뷰 및 승인 후 `main`으로 머지

1. 머지 완료된 작업 브랜치 삭제

### 금지 사항

- `main` 브랜치에 직접 push 금지 (반드시 PR을 통해 머지)
- 작업 브랜치에서 다른 작업 브랜치로 머지 금지
- `main` 외의 장기 브랜치 생성 금지
- force push 금지 (`--force`, `--force-with-lease` 모두 해당)
