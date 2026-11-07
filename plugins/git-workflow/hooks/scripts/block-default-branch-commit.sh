#!/usr/bin/env bash
# 기본 브랜치(main / master)에 직접 커밋하는 Bash 명령을 막는 PreToolUse 훅
#
# - 입력: Claude Code 가 stdin 으로 넘기는 JSON (tool_input.command, cwd)
# - 차단: exit 2 + stderr 메시지 (Claude 에게 이유가 전달됨)
# - 허용 예외
#   - 커밋이 하나도 없는 빈 레포의 첫 커밋
#   - 명령에 GIT_WORKFLOW_ALLOW_DEFAULT_BRANCH_COMMIT=1 이 포함된 경우
#     (사용자가 명시적으로 허락했을 때만 사용)
#
# 함께 수정해야 하는 곳: 차단 대상 브랜치나 예외를 바꾸면
# plugins/git-workflow/README.md 의 "훅" 섹션도 같이 수정해요.

set -u

command -v jq >/dev/null 2>&1 || exit 0   # jq 가 없으면 검사하지 않음

input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty')"

[ -n "$cmd" ] || exit 0

# git commit 이 포함된 명령만 검사 (git -C <dir> commit, 체이닝 포함 / commit-tree 등은 제외)
commit_re='(^|[;&|[:space:](])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+commit([[:space:]]|$)'
printf '%s' "$cmd" | grep -Eq "$commit_re" || exit 0

# 명시적 허용
case "$cmd" in
  *GIT_WORKFLOW_ALLOW_DEFAULT_BRANCH_COMMIT=1*) exit 0 ;;
esac

# 커밋이 실행될 디렉토리 판별: git -C <dir> > 맨 앞의 cd <dir> && > 훅 입력의 cwd
target="${cwd:-$PWD}"
dir_c="$(printf '%s' "$cmd" | sed -nE 's/.*git[[:space:]]+-C[[:space:]]+("([^"]+)"|'"'"'([^'"'"']+)'"'"'|([^[:space:]]+))[[:space:]]+commit.*/\2\3\4/p' | head -n1)"
dir_cd="$(printf '%s' "$cmd" | sed -nE 's/^[[:space:]]*cd[[:space:]]+("([^"]+)"|'"'"'([^'"'"']+)'"'"'|([^[:space:];&]+))[[:space:]]*&&.*/\2\3\4/p' | head -n1)"
for d in "$dir_cd" "$dir_c"; do
  [ -n "$d" ] || continue
  d="${d/#\~/$HOME}"
  case "$d" in
    /*) target="$d" ;;
    *) target="$target/$d" ;;
  esac
done

[ -d "$target" ] || exit 0
git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# 빈 레포의 첫 커밋은 허용
git -C "$target" rev-parse --verify -q HEAD >/dev/null 2>&1 || exit 0

branch="$(git -C "$target" branch --show-current 2>/dev/null)"
default="$(git -C "$target" symbolic-ref --short -q refs/remotes/origin/HEAD 2>/dev/null)"
default="${default#origin/}"

case "$branch" in
  main | master | "$default")
    [ -n "$branch" ] || exit 0
    cat >&2 <<MSG
[git-workflow] 기본 브랜치 '$branch' 에 직접 커밋할 수 없어요.
작업 브랜치를 만든 뒤 커밋하고 PR 로 반영해 주세요. (예: git checkout -b feat/<short-description>)
사용자가 기본 브랜치 커밋을 명시적으로 허락한 경우에만 명령 앞에 GIT_WORKFLOW_ALLOW_DEFAULT_BRANCH_COMMIT=1 을 붙여 다시 실행하세요.
MSG
    exit 2
    ;;
esac

exit 0
