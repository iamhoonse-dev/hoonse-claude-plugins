#!/bin/bash

INPUT=$(cat)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

GIT_USER=$(git -C "$CLAUDE_PROJECT_DIR" config user.name 2>/dev/null || echo "unknown")
GIT_BRANCH=$(git -C "$CLAUDE_PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')

LOG_DIR="$CLAUDE_PROJECT_DIR/logs/iamhoonse-claude-code-plugin/$GIT_USER/$SESSION_ID"
LOG_FILE="$LOG_DIR/prompt.log"

mkdir -p "$LOG_DIR"

PROMPT=$(echo "$INPUT" | jq -r '.prompt')

echo "[$TIMESTAMP] [$GIT_BRANCH] $PROMPT" >> "$LOG_FILE"