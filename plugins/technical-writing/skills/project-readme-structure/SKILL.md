---
name: project-readme-structure
description: 이 마켓플레이스 프로젝트에 대한 README.md 작성 규약을 정의합니다. 프로젝트 루트의 README.md 작성 또는 수정 시 이 지침을 따릅니다.
user-invocable: false
---

## README 작성 규약

이 프로젝트는 여러 Claude Code 플러그인들을 포함하는 모노레포 형태의 마켓플레이스 레포지토리로, 프로젝트 루트의 README.md는 아래 구조와 규칙을 따릅니다.

### 필수 섹션 (순서 준수)

1. **제목 및 한 줄 소개**: 프로젝트 이름과 간결한 설명
1. **개요**: 프로젝트 구조를 시각적으로 표현한 다이어그램
1. **설치 방법**: 마켓플레이스 등록 및 플러그인 설치 명령어
1. **사용 예시**: 주요 기능의 실제 사용 예시
1. **플러그인 목록**: 프로젝트에서 제공하는 주요 플러그인들을 정리
1. **라이선스**: 라이선스 표기

### 추가 리소스

- 작성 양식은 [template.md](template.md) 참조

### 작성 규칙

- 언어: 한국어로 작성
- ordered list는 각 항목마다 1.으로 시작하여 자동 번호 매김 활용
- 프로젝트의 .claude-plugin/marketplace.json의 name, description 등의 정보와 일관성을 유지
- 다이어그램은 Mermaid 또는 PlantUML을 사용하여 작성
  - 가급적 Mermaid 사용 권장하나, PlantUML이 더 적합한 경우 허용
  - 1 depth 로 .claude, plugins 까지 포함하고, 각 플러그인별로 1 depth 추가하여 표현
   - 예시:
      ```mermaid
      graph LR
        A[hoonse-claude-plugins] --> B[.claude]
        B[.claude] --> B1[마켓플레이스 개발 시 사용되는 claude 설정 및 리소스]
        A[hoonse-claude-plugins] --> C[plugins]
        C[plugins] --> D[plugin-a]
        C[plugins] --> E[plugin-b]
        D[plugin-a] --> D1[plugin-a의 주요 기능]
        E[plugin-b] --> E1[plugin-b의 주요 기능]
      ```
- 각 플러그인 설명은 1~2문장으로 간결하게
- 코드 블록에는 반드시 언어 태그 명시 (`bash`, `json` 등)
- 설치 명령어는 복사-붙여넣기로 바로 사용 가능하도록 작성
- 설치 명령어는 https://code.claude.com/docs/en/discover-plugins 의 내용을 참조하여 작성
- 설치 명령어는 마켓플레이스 등록과 플러그인 설치 명령어를 모두 포함
- 사용 예시는 실제로 플러그인에서 작동하는 명령어와 출력 예시를 포함
- 사용 예시는 모든 플러그인의 모든 기능에 대한 예시를 포함할 필요는 없으며, 주요 기능 위주로 2가지 정도 포함
- 스킬 사용 예시에는 플러그인 네임스페이스를 명시하는 예시도 병기 (예: `/plugin-name:skill-name` 형태)

### 플러그인 목록 작성 형식

```markdown
## 플러그인

| 이름 | 설명 |
|--------|------|
| 플러그인 이름 | 한 줄 설명 |
```
