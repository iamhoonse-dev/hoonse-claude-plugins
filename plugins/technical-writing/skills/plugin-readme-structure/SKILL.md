---
name: plugin-readme-structure
description: 이 마켓플레이스 프로젝트에 포함된 각 플러그인에 대한 README.md 작성 규약을 정의합니다. 각 플러그인에 대한 README.md 작성 또는 수정 시 이 지침을 따릅니다.
user-invocable: false
---

## README 작성 규약

이 프로젝트는 여러 Claude Code 플러그인들을 포함하는 모노레포 형태의 마켓플레이스 레포지토리로, 각 플러그인별 README.md는 아래 구조와 규칙을 따릅니다.

### 필수 섹션 (순서 준수)

1. **제목 및 한 줄 소개**: 플러그인 이름과 간결한 설명
1. **개요**: 프로젝트 구조를 시각적으로 표현한 다이어그램
1. **설치 방법**: 플러그인 설치 명령어
1. **사용 예시**: 주요 기능의 실제 사용 예시
1. **기능 목록**: 플러그인이 제공하는 구성 요소를 종류별로 정리
   - Skills, Hooks, Agents, MCP, LSP 등 해당하는 항목만 포함
1. **(선택) 커스터마이징**: 플러그인이 제공하는 스킬을 프로젝트 레벨에서 오버라이딩하거나 동작을 커스터마이징하는 방법 안내. 오버라이딩 가능한 스킬이 있는 경우에만 포함.
1. **라이선스**: 라이선스 표기

### 추가 리소스

- 작성 양식은 [template.md](template.md) 참조

### 작성 규칙

- 언어: 한국어로 작성
- ordered list는 각 항목마다 1.으로 시작하여 자동 번호 매김 활용
- 해당 플러그인의 .claude-plugin/plugin.json의 name, description, version, repository 정보와 일관성을 유지
- 다이어그램은 Mermaid 또는 PlantUML을 사용하여 작성
  - 가급적 Mermaid 사용 권장하나, PlantUML이 더 적합한 경우 허용
  - 1 depth 로 .claude, plugins 까지 포함하고, 각 플러그인별로 1 depth 추가하여 표현
   - 예시:
      ```mermaid
      graph LR
       A[hello-plugin] --> B[Hooks]
       A --> C[Agents]
       A --> D[Skills]

       C --> D1[code-improver<br/>코드 품질 개선]

       D --> B1[dive-deep<br/>주제 심층 연구]
       D --> B2[explain-code<br/>코드 시각적 설명]
       D --> B3[fix-issue<br/>GitHub 이슈 수정]
       D --> B4[summarize-pr<br/>PR 요약]
       D --> B5[visualize-codebase<br/>코드베이스 시각화]

       B --> C1[PreToolUse<br/>도구 사용 로깅]
       B --> C2[UserPromptSubmit<br/>프롬프트 로깅]
      ```
   - 각 구성 요소들의 배치 순서는 hooks, agents, skills 순으로 배치하되, 플러그인마다 구성 요소의 수가 다르므로 적절히 조정하여 가독성 높게 작성
- 각 기능 설명은 1~2문장으로 간결하게
  - 스킬에는 "타입" 칼럼에 분류도 명시 (직접 호출형 or 지침형 or 지식형)
- 코드 블록에는 반드시 언어 태그 명시 (`bash`, `json` 등)
- 설치 명령어는 복사-붙여넣기로 바로 사용 가능하도록 작성
- 설치 명령어는 https://code.claude.com/docs/en/discover-plugins 의 내용을 참조하여 작성
- 설치 명령어는 마켓플레이스 등록과 플러그인 설치 명령어를 모두 포함
- 사용 예시는 실제로 플러그인에서 작동하는 명령어와 출력 예시를 포함
- 사용 예시는 모든 플러그인의 모든 기능에 대한 예시를 포함할 필요는 없으며, 주요 기능 위주로 2가지 정도 포함
- 스킬 사용 예시에는 플러그인 네임스페이스를 명시하는 예시도 병기 (예: `/plugin-name:skill-name` 형태)
- 커스터마이징 섹션은 오버라이딩 가능한 스킬이 있는 경우에만 포함
  - 오버라이딩 대상 스킬명, 파일 경로, 간단한 절차를 포함
  - 오버라이딩 예시 디렉토리 구조를 코드 블록으로 제시

### 기능 목록 작성 형식

```markdown
## 기능

### Skills
| 이름 | 타입 | 설명 |
|------|----|----|
| skill-name | 타입 분류 | 한 줄 설명 |

### Hooks
| 이벤트 | 설명 |
|--------|------|
| EventName | 한 줄 설명 |
```

기능 종류(Skills, Hooks, Agents 등)별로 테이블로 정리하되, 해당 플러그인에 존재하는 항목만 포함합니다.
