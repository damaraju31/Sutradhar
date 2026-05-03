#!/usr/bin/env bash
# Hook: PreToolUse → Edit, Write
# Purpose: Prevent modification of locked framework files (evaluators, harnesses)
# Exit 0 = allow, Exit 2 = block

INPUT=$(cat)

# Extract file_path from JSON input
if command -v jq >/dev/null 2>&1; then
  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
else
  FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

[ -z "$FILE_PATH" ] && exit 0

# Locked files — evaluators and harnesses that agents must not modify
LOCKED_PATTERNS=(
  'context-health-score'
  'file-lock-guard'
  'security-guard'
)

for pattern in "${LOCKED_PATTERNS[@]}"; do
  if echo "$FILE_PATH" | grep -q "$pattern"; then
    echo "BLOCKED: '$(basename "$FILE_PATH")' is a locked evaluator/harness. Do not modify." >&2
    exit 2
  fi
done

exit 0
