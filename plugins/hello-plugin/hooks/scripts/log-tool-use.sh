#!/bin/bash

INPUT=$(cat)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

GIT_USER=$(git -C "$CLAUDE_PROJECT_DIR" config user.name 2>/dev/null || echo "unknown")
GIT_BRANCH=$(git -C "$CLAUDE_PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')

LOG_DIR="$CLAUDE_PROJECT_DIR/logs/hoonse-claude-plugins/hello-plugin/$GIT_USER/$SESSION_ID"
LOG_FILE="$LOG_DIR/tool-use.log"

mkdir -p "$LOG_DIR"

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')

case "$TOOL_NAME" in
  Bash)
    DETAIL=$(echo "$INPUT" | jq -r '.tool_input | "\(.command) - \(.description // "No description")"')
    ;;
  Read|Write|Edit)
    DETAIL=$(echo "$INPUT" | jq -r '.tool_input.file_path')
    ;;
  Grep|Glob)
    DETAIL=$(echo "$INPUT" | jq -r '.tool_input | "\(.pattern) (\(.path // "."))"')
    ;;
  *)
    DETAIL=$(echo "$INPUT" | jq -c '.tool_input')
    ;;
esac

echo "[$TIMESTAMP] [$GIT_BRANCH] [$TOOL_NAME] $DETAIL" >> "$LOG_FILE"
