---
name: branch-strategy
description: 브랜치 전략의 기본 규약입니다. 프로젝트에 별도 규약이 없을 때 브랜치 생성 및 관리에 사용합니다.
user-invocable: false
---

## 브랜치 전략 기본 규약

> 이 문서는 git-workflow 플러그인의 **기본 규약**이에요.
> 프로젝트에 아래 중 하나가 있으면 그것을 우선해요.
>
> 1. 프로젝트의 `.claude/skills/branch-strategy/SKILL.md`
> 1. `CLAUDE.md` / `AGENTS.md` 의 브랜치 규칙
> 1. 기존 브랜치 이름(`git branch -a`)에서 드러나는 일관된 형식

### 전략

**trunk-based development** 를 기본으로 해요.

- 기본 브랜치(`main`, 없으면 `master`)가 유일한 장기 브랜치예요.
- 모든 작업은 최신 기본 브랜치에서 분기한 짧은 수명의 작업 브랜치에서 진행하고, PR 로 머지해요.

### 브랜치 이름

```
<type>/<short-description>
```

- `type`: Conventional Commits 의 type (`feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`)
- `short-description`: 영문 소문자, 숫자, 하이픈(`-`)만 사용해요.
  - 모노레포에서 특정 앱/패키지만 바꾸면 그 이름을 앞에 붙여요. (예: `feat/web-dark-mode`)
  - 이슈 기반 작업이면 이슈 번호를 넣어도 좋아요. (예: `fix/42-login-redirect`)

### 예시

```
feat/add-social-login
fix/42-login-redirect
docs/update-readme
chore/upgrade-dependencies
```

### 작업 흐름

1. 기본 브랜치를 최신화하고 작업 브랜치를 만들어요.

   ```bash
   git checkout main
   git pull origin main
   git checkout -b <type>/<short-description>
   ```

1. 작업 브랜치에서 커밋해요. (commit-message 규약)
1. 기본 브랜치를 base 로 PR 을 만들어요.
1. 머지 후 로컬 기본 브랜치를 최신화하고 작업 브랜치를 `git branch -d` 로 삭제해요.

### 금지 사항

- 기본 브랜치에 직접 커밋/push 하지 않아요. (git-workflow 의 훅이 직접 커밋을 막아요)
- 사용자 확인 없이 force push 하지 않아요.
