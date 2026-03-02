# 🧰 hoonse-claude-plugins

코드 생성 및 코드 설명을 위한 개인용 Claude Code 플러그인 마켓플레이스

## 💁 개요

```mermaid
graph LR
    A[hoonse-claude-plugins] --> B[.claude]
    B --> B1[마켓플레이스 개발 시 사용되는<br/>claude 설정 및 리소스]
    A --> C[plugins]
    C --> D[claude-logger]
    D --> D1[도구 사용 및 프롬프트<br/>자동 로깅]
    C --> F[technical-writing]
    F --> F1[기술 문서 작성 전문 에이전트와<br/>README 구조 규약 제공]
    C --> G[git-workflow]
    G --> G1[로컬 Git 워크플로우 규약<br/>관리]
    C --> H[github-workflow]
    H --> H1[GitHub Issue 기반<br/>개발 워크플로우 자동화]
    C --> I[backend]
    I --> I1[RESTful API 설계 규약과<br/>FastAPI 백엔드 개발 전문 에이전트]
    C --> J[data-engineering]
    J --> J1[Apache Airflow DAG 개발<br/>전문 에이전트]
    C --> K[project-analyzer]
    K --> K1[프로젝트 구조·문서 품질·<br/>설정 정합성 자동 분석 및<br/>GitHub Issue 등록]
```

## ✨ 핵심 워크플로우

이 마켓플레이스의 가장 큰 특장점은 **개발 워크플로우 전체를 자동화하는 오케스트레이션 스킬**입니다.
Issue 분석부터 브랜치 생성, 구현, 커밋, PR 생성까지 하나의 스킬 호출로 처리할 수 있습니다.

| 스킬 | 플러그인 | 설명 |
|------|---------|------|
| [work-on-issue](./plugins/github-workflow/skills/work-on-issue/SKILL.md) | github-workflow | GitHub Issue 번호를 받아 이슈 분석 → 브랜치 생성 → 계획 수립 → 구현 및 커밋 → PR 생성까지 전체 워크플로우를 오케스트레이션합니다. |
| [work-from-scratch](./plugins/github-workflow/skills/work-from-scratch/SKILL.md) | github-workflow | Issue 없이 작업 설명을 받아 브랜치 생성부터 PR 생성까지 전체 워크플로우를 오케스트레이션합니다. |
| [work-on-pr](./plugins/github-workflow/skills/work-on-pr/SKILL.md) | github-workflow | GitHub PR 번호를 받아 리뷰 분석 → 피드백 반영 커밋 → PR 코멘트 작성까지 리뷰 대응 워크플로우를 오케스트레이션합니다. |
| [analyze-project](./plugins/project-analyzer/skills/analyze-project/SKILL.md) | project-analyzer | 플러그인 마켓플레이스 프로젝트를 자동 분석하여 구조·문서·설정 문제를 파악하고, 필요 시 GitHub Issue로 등록합니다. |

아래 차트는 각 오케스트레이션 스킬의 단계별 실행 흐름을 보여줍니다.

```mermaid
graph TB
    subgraph WOI ["/work-on-issue  (github-workflow)"]
        WOI1["① @issue-fetcher"]
        WOI2["② @branch-creator"]
        WOI3["③ Plan Mode"]
        WOI4["④ 코드 구현\n+ @auto-committer"]
        WOI5["⑤ git push\n+ @pr-creator"]
        WOI1 --> WOI2 --> WOI3 --> WOI4 --> WOI5
    end

    subgraph WOP ["/work-on-pr  (github-workflow)"]
        WOP1["① @pr-fetcher"]
        WOP2["② 브랜치 체크아웃"]
        WOP3["③ Plan Mode"]
        WOP4["④ 코드 수정\n+ @auto-committer"]
        WOP5["⑤ git push\n+ gh pr comment"]
        WOP1 --> WOP2 --> WOP3 --> WOP4 --> WOP5
    end

    subgraph WFS ["/work-from-scratch  (github-workflow)"]
        WFS1["① 작업 정의"]
        WFS2["② @branch-creator"]
        WFS3["③ Plan Mode"]
        WFS4["④ 코드 구현\n+ @auto-committer"]
        WFS5["⑤ git push\n+ @pr-creator"]
        WFS1 --> WFS2 --> WFS3 --> WFS4 --> WFS5
    end

    subgraph ANAP ["/analyze-project  (project-analyzer)"]
        ANAP0["① 분석 범위 결정"]
        ANAP1["② 병렬 분석"]
        ANA1["@structure-analyzer"] & ANA2["@docs-analyzer"] & ANA3["@settings-analyzer"]
        ANAP2["③ 종합 리포트 작성"]
        ANA4["④ @issue-creator\n(선택)"]
        ANAP0 --> ANAP1
        ANAP1 --> ANA1 & ANA2 & ANA3
        ANA1 & ANA2 & ANA3 --> ANAP2
        ANAP2 -. "개발자 승인 후" .-> ANA4
    end

    classDef plan fill:#fef9c3,stroke:#ca8a04,color:#713f12
    class WOI3,WOP3,WFS3 plan
```

## 💾 설치 방법

이 마켓플레이스 프로젝트에서 제공하는 플러그인을 사용하려는 프로젝트의 루트 디렉토리에서 아래 명령어를 실행합니다.

### GitHub에서 추가

```bash
# 마켓플레이스 등록
/plugin marketplace add iamhoonse-dev/hoonse-claude-plugins

# 플러그인 설치
/plugin install git-workflow@hoonse-claude-plugins
```

### 로컬 경로에서 추가

```bash
# 마켓플레이스 등록
/plugin marketplace add /path/to/hoonse-claude-plugins

# 플러그인 설치
/plugin install git-workflow@hoonse-claude-plugins
```

## 🧑‍💻 사용 예시

### 📖 Skills

Skills는 `/<plugin-name>:<skill-name>` 형태로 호출합니다.

#### commit-message (git-workflow)

##### with plugin namespace

```
/git-workflow:commit-message
```

##### without plugin namespace

```
/commit-message
```

### 🤖 Agents

Agents는 대화 중 관련 요청 시 자동으로 활성화되거나, 직접 요청할 수 있습니다.

#### auto-committer (git-workflow)

##### with plugin namespace

```
@git-workflow:auto-committer 변경사항을 커밋해 줘
```

##### without plugin namespace

```
변경사항을 커밋해 줘
```

## 🛠️ 플러그인 목록

| 이름 | 설명 |
|------|------|
| [claude-logger](./plugins/claude-logger) | Claude Code 세션의 도구 사용 및 프롬프트를 자동으로 로깅하는 플러그인 |
| [technical-writing](./plugins/technical-writing) | 기술 문서 작성 전문 에이전트와 README 구조 규약을 제공하는 플러그인 |
| [git-workflow](./plugins/git-workflow) | 로컬 Git 워크플로우 규약(커밋 메시지, 브랜치 네이밍 등)을 관리하는 플러그인 |
| [github-workflow](./plugins/github-workflow) | GitHub 개발 워크플로우(이슈 기반 작업, 자유 작업, PR 리뷰 대응, PR 생성 등)를 자동화하는 플러그인 |
| [backend](./plugins/backend) | RESTful API 설계 규약과 FastAPI 백엔드 개발 전문 에이전트를 제공하는 플러그인 |
| [data-engineering](./plugins/data-engineering) | Apache Airflow DAG 개발 전문 에이전트를 제공하는 데이터 엔지니어링 플러그인 |
| [project-analyzer](./plugins/project-analyzer) | 플러그인 마켓플레이스 프로젝트의 구조 일관성, 문서 품질, 설정 정합성을 자동 분석하고 GitHub Issue로 등록하는 플러그인 |

## ⚖️ 라이선스

[MIT](LICENSE)
