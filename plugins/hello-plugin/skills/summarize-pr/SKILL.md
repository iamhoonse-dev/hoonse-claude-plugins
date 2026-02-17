---
name: summarize-pr
description: 풀 요청의 변경 사항 요약
context: fork
agent: Explore
allowed-tools: Bash(gh:*)
---

## 풀 요청 컨텍스트
- PR diff: !`gh pr diff`
- PR 댓글: !`gh pr view --comments`
- 변경된 파일: !`gh pr diff --name-only`

## 작업
이 풀 요청을 요약합니다.