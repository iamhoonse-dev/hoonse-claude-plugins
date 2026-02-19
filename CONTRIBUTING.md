# 🤝 기여 가이드

이 문서는 **hoonse-claude-plugins** 마켓플레이스 프로젝트에 기여하는 방법을 안내합니다. 새 플러그인을 추가하거나 기존 플러그인을 수정하려는 경우, 이 가이드에 따라 개발 환경을 구성하고 기여 절차를 진행해 주세요.

> **참고:** 이 문서의 "개발 환경 구성"은 이 마켓플레이스 프로젝트 **자체를 개발**하기 위한 가이드입니다. 외부 프로젝트에서 플러그인을 **사용**하려는 경우 [README.md](./README.md)의 "설치 방법"을 참고하세요.

## 🔧 개발 환경 구성

### 사전 준비

다음 도구가 설치되어 있어야 합니다.

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) — 플러그인 설치 및 관리에 사용
- [Git](https://git-scm.com/) — 저장소 클론 및 버전 관리

### 저장소 클론

```bash
git clone https://github.com/iamhoonse-dev/hoonse-claude-plugins.git
cd hoonse-claude-plugins
```

### 로컬 마켓플레이스 등록

클론한 로컬 경로를 마켓플레이스로 등록합니다. Claude Code를 실행한 후 아래 명령어를 입력합니다.

```bash
/plugin marketplace add /path/to/hoonse-claude-plugins
```

> `/path/to/hoonse-claude-plugins`를 실제 클론한 디렉토리의 절대 경로로 교체하세요.

등록이 완료되면 `hoonse-claude-plugins` 마켓플레이스를 통해 로컬 플러그인을 설치할 수 있습니다.

### 플러그인 설치 및 활성화

개별 플러그인을 설치하려면 아래 명령어를 사용합니다.

```bash
# 특정 플러그인 설치
/plugin install claude-logger@hoonse-claude-plugins
/plugin install hello-plugin@hoonse-claude-plugins
/plugin install technical-writing@hoonse-claude-plugins
/plugin install git-workflow@hoonse-claude-plugins
```

설치 후 플러그인이 활성화되어 있는지 확인하려면 프로젝트 루트의 `.claude/settings.json`을 확인합니다.

```json
{
  "enabledPlugins": {
    "claude-logger@hoonse-claude-plugins": true,
    "technical-writing@hoonse-claude-plugins": true,
    "git-workflow@hoonse-claude-plugins": true
  }
}
```

`enabledPlugins`에 플러그인이 `true`로 설정되어 있어야 동작합니다. 특정 플러그인을 비활성화하려면 해당 값을 `false`로 변경하거나 항목을 제거합니다.

## 📁 프로젝트 구조

```
hoonse-claude-plugins/
├── .claude/                          # 마켓플레이스 개발 설정
│   └── settings.json                 # 플러그인 활성화 설정
├── .claude-plugin/
│   └── marketplace.json              # 마켓플레이스 정의
├── plugins/                          # 플러그인 디렉토리
│   ├── claude-logger/                # 로깅 플러그인
│   │   ├── .claude-plugin/plugin.json
│   │   └── hooks/
│   │       ├── hooks.json
│   │       └── scripts/
│   ├── hello-plugin/                 # 개발 생산성 도구
│   │   ├── .claude-plugin/plugin.json
│   │   ├── agents/
│   │   └── skills/
│   ├── technical-writing/            # 기술 문서 작성
│   │   ├── .claude-plugin/plugin.json
│   │   ├── agents/
│   │   └── skills/
│   └── git-workflow/                 # Git 워크플로우
│       ├── .claude-plugin/plugin.json
│       ├── agents/
│       └── skills/
├── README.md
└── CONTRIBUTING.md
```

각 디렉토리의 역할은 다음과 같습니다.

- `.claude/` — 이 마켓플레이스 저장소에서 개발 시 사용하는 Claude Code 설정 파일 모음
- `.claude-plugin/marketplace.json` — 마켓플레이스 이름, 오너, 포함 플러그인 목록을 정의하는 파일
- `plugins/` — 각 플러그인의 소스 코드가 위치하는 최상위 디렉토리
- `plugins/<plugin-name>/.claude-plugin/plugin.json` — 플러그인 이름, 버전, 라이선스 등 메타정보
- `plugins/<plugin-name>/agents/` — 에이전트 정의 파일 (`.md` 형식)
- `plugins/<plugin-name>/skills/` — 스킬 정의 디렉토리 (스킬별 하위 디렉토리로 구성)
- `plugins/<plugin-name>/hooks/` — Hooks 설정 및 실행 스크립트

## 🧑‍💻 플러그인 개발 가이드

### 새 플러그인 생성

1. `plugins/` 하위에 플러그인 이름으로 디렉토리를 생성합니다.

   ```bash
   mkdir -p plugins/my-plugin/.claude-plugin
   ```

1. `.claude-plugin/plugin.json` 파일을 생성하고 메타정보를 작성합니다.

   ```json
   {
     "name": "my-plugin",
     "description": "플러그인 설명",
     "version": "0.0.1",
     "license": "MIT",
     "author": {
       "name": "iamhoonse",
       "email": "iamhoonse+dev@gmail.com"
     },
     "repository": "https://github.com/iamhoonse-dev/hoonse-claude-plugins"
   }
   ```

1. `.claude-plugin/marketplace.json`에 새 플러그인 항목을 추가합니다.

   ```json
   {
     "name": "my-plugin",
     "description": "플러그인 설명",
     "version": "0.0.1",
     "author": {
       "name": "iamhoonse",
       "email": "iamhoonse+dev@gmail.com"
     },
     "source": "./plugins/my-plugin",
     "category": "category-name",
     "homepage": "https://github.com/iamhoonse-dev/hoonse-claude-plugins"
   }
   ```

1. 필요한 구성 요소(Skills, Agents, Hooks) 디렉토리를 생성하고 내용을 작성합니다.

1. 플러그인을 로컬에 설치하여 동작을 검증합니다.

   ```bash
   /plugin install my-plugin@hoonse-claude-plugins
   ```

### 구성 요소 개발

#### Skills

스킬은 `plugins/<plugin-name>/skills/<skill-name>/` 디렉토리에 `SKILL.md` 파일로 정의합니다.

```bash
mkdir -p plugins/my-plugin/skills/my-skill
```

`SKILL.md` 파일은 다음 프론트매터 형식을 따릅니다.

```yaml
---
name: skill-name
description: 스킬 설명
user-invocable: true
---
```

- `user-invocable: true` — 사용자가 `/skill-name` 명령으로 직접 호출 가능한 스킬
- `user-invocable: false` — Claude가 내부적으로 참조하는 지침형 또는 지식형 스킬

직접 호출형 스킬의 경우 `context`, `agent` 등 추가 필드가 필요할 수 있습니다.

#### Hooks

Hooks는 `plugins/<plugin-name>/hooks/` 디렉토리에 `hooks.json` 파일과 실행 스크립트로 구성됩니다.

```bash
mkdir -p plugins/my-plugin/hooks/scripts
```

`hooks.json` 형식 예시:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "bash /path/to/script.sh"
          }
        ]
      }
    ],
    "UserPromptSubmit": []
  }
}
```

Hooks에서 사용하는 셸 스크립트는 반드시 실행 권한을 부여해야 합니다.

```bash
chmod +x plugins/my-plugin/hooks/scripts/my-script.sh
```

#### Agents

에이전트는 `plugins/<plugin-name>/agents/` 디렉토리에 `.md` 파일로 정의합니다.

```bash
mkdir -p plugins/my-plugin/agents
```

에이전트 정의 파일은 다음 프론트매터 형식을 따릅니다.

```yaml
---
name: agent-name
description: 에이전트 설명
tools: [Read, Write, Bash, Glob, Grep]
model: claude-sonnet-4-6
color: purple
memory:
  type: project
---
```

프론트매터 하단에는 에이전트의 역할, 책임, 동작 방식을 마크다운으로 상세히 기술합니다.

## 📝 커밋 규약

이 프로젝트는 [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) 스펙을 따릅니다. 자세한 규약은 `git-workflow` 플러그인의 `commit-message` 스킬을 참고하세요.

### 메시지 형식

```
<type>[(scope)][!]: <description>

[body]

[footer(s)]
```

### 허용되는 type

| type | 의미 |
|------|------|
| `feat` | 새로운 기능 추가 |
| `fix` | 버그 수정 |
| `docs` | 문서 변경 |
| `style` | 코드 스타일 변경 |
| `refactor` | 리팩토링 |
| `perf` | 성능 개선 |
| `test` | 테스트 추가 또는 수정 |
| `build` | 빌드 시스템 변경 |
| `ci` | CI 설정 변경 |
| `chore` | 기타 유지보수 작업 |

### scope 사용 기준

이 프로젝트는 모노레포 구조이므로 scope를 다음과 같이 사용합니다.

- 프로젝트 전역 변경: scope 생략 또는 대상 명시 (예: `docs(readme):`)
- 특정 플러그인 변경: 플러그인 이름을 scope로 사용 (예: `feat(hello-plugin):`)
- 마켓플레이스 설정 변경: `marketplace`를 scope로 사용 (예: `fix(marketplace):`)
- 에이전트/스킬 변경: `agent`, `skill`을 scope로 사용 (예: `fix(agent):`)

### 작성 규칙

- 첫째 줄(type + scope + description) 전체는 **72자 이내**
- description은 **한국어**, **명사형 종결** 사용
- description 끝에 마침표(`.`) 붙이지 않음

### 예시

```
feat(hello-plugin): 코드 시각화 스킬 추가
```

```
fix(agent): tech-doc-writer에서 하드코딩된 절대 경로 제거
```

```
feat!: 단일 플러그인 구조에서 모노레포 구조로 변경
```

## ❓ 트러블슈팅

<details>
<summary>플러그인 인식 실패 — <code>/plugin install</code> 시 플러그인을 찾을 수 없는 경우</summary>

**원인:** 로컬 마켓플레이스가 Claude Code에 등록되지 않았기 때문입니다.

**해결 방법:**

Claude Code 세션에서 아래 명령어로 로컬 경로를 마켓플레이스로 등록합니다.

```bash
/plugin marketplace add /path/to/hoonse-claude-plugins
```

등록 후 다시 플러그인 설치를 시도합니다.

```bash
/plugin install my-plugin@hoonse-claude-plugins
```

</details>

<details>
<summary>Skills / Agents / Hooks 미표시 — 설치한 플러그인의 기능이 목록에 나타나지 않는 경우</summary>

**원인:** 플러그인이 설치되지 않은 상태입니다.

**해결 방법:**

해당 플러그인을 명시적으로 설치합니다.

```bash
/plugin install plugin-name@hoonse-claude-plugins
```

설치 후 `/skills`, `/agents` 명령으로 목록을 다시 확인합니다.

</details>

<details>
<summary>설치 후 미동작 — 플러그인을 설치했으나 기능이 동작하지 않는 경우</summary>

**원인:** `.claude/settings.json`에서 해당 플러그인이 비활성화되어 있습니다.

**해결 방법:**

`.claude/settings.json`을 열고 `enabledPlugins` 항목에서 해당 플러그인의 값을 `true`로 설정합니다.

```json
{
  "enabledPlugins": {
    "plugin-name@hoonse-claude-plugins": true
  }
}
```

변경 후 Claude Code 세션을 재시작합니다.

</details>

<details>
<summary>Hooks 미작동 — Hooks 이벤트가 발생해도 스크립트가 실행되지 않는 경우</summary>

**원인:** Hooks 스크립트 파일에 실행 권한이 없습니다.

**해결 방법:**

해당 스크립트에 실행 권한을 부여합니다.

```bash
chmod +x plugins/plugin-name/hooks/scripts/script-name.sh
```

권한 부여 후 Claude Code 세션을 재시작하여 동작을 확인합니다.

</details>

<details>
<summary>파일 수정 후 미반영 — SKILL.md, 에이전트, Hooks 등을 수정했으나 변경 사항이 반영되지 않는 경우</summary>

**원인:** Claude Code가 플러그인 구성 요소를 내부적으로 캐싱하여, 파일을 직접 수정해도 즉시 반영되지 않는 경우가 있습니다.

**해결 방법:**

다음 중 하나를 시도합니다.

1. **세션 재시작**: `/exit` 명령으로 Claude Code를 종료한 후 다시 실행합니다.

   ```bash
   /exit
   ```

1. **플러그인 재설치**: 세션 재시작 없이 변경 사항을 반영하려면 플러그인을 재설치합니다.

   ```bash
   /plugin install plugin-name@hoonse-claude-plugins
   ```

</details>

## 🔗 추가 참고 자료

- [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) — 커밋 메시지 규약 공식 문서
- [Claude Code 플러그인 문서](https://docs.anthropic.com/en/docs/claude-code/plugins) — 플러그인 개발 및 설치 가이드
- [Claude Code 플러그인 마켓플레이스](https://code.claude.com/docs/en/discover-plugins) — 플러그인 검색 및 설치 방법
- [hoonse-claude-plugins GitHub](https://github.com/iamhoonse-dev/hoonse-claude-plugins) — 이 프로젝트 저장소
