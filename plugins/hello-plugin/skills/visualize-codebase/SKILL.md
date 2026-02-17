---
name: visualize-codebase
description: 코드베이스의 대화형 축소 가능한 트리 시각화를 생성합니다. 새 리포지토리 탐색, 프로젝트 구조 이해 또는 큰 파일 식별 시 사용합니다.
allowed-tools: Bash(python:*)
---

# 코드베이스 시각화기

프로젝트의 파일 구조를 축소 가능한 디렉토리로 보여주는 대화형 HTML 트리 보기를 생성합니다.

## 사용법

프로젝트 루트에서 시각화 스크립트를 실행합니다:

```bash
python .claude/skills/codebase-visualizer/scripts/visualize.py .
```

이렇게 하면 현재 디렉토리에 `codebase-map.html`이 생성되고 기본 브라우저에서 열립니다.

## 시각화가 표시하는 것

- **축소 가능한 디렉토리**: 폴더를 클릭하여 확장/축소
- **파일 크기**: 각 파일 옆에 표시됨
- **색상**: 파일 유형별로 다른 색상
- **디렉토리 합계**: 각 폴더의 집계 크기 표시
