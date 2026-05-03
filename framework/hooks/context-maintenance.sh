#!/bin/bash
# Context Maintenance Hook
# Trigger: PostToolUse on Write, Edit
# Purpose: Track which source directories have been modified so /context-refresh
#          can detect staleness. Also maintains a lightweight staleness log.
#
# NOTE: PostToolUse stdout is NOT visible to Claude in normal mode.
# This hook maintains state files — it does not communicate directly with the agent.
# Agent reminders come from CLAUDE.md instructions and completion protocols.

# Read tool input from stdin (Claude Code passes JSON via stdin)
INPUT=$(cat)

# Extract file_path from the JSON input
# Requires jq, falls back to grep-based extraction
if command -v jq >/dev/null 2>&1; then
  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
else
  # Fallback: extract file_path with grep/sed (less reliable but works without jq)
  FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Normalize path — remove leading ./ and make relative to project root
FILE_PATH="${FILE_PATH#./}"
# If absolute path, try to make relative to current directory
if [[ "$FILE_PATH" == /* ]]; then
  PROJ_DIR="$(pwd)"
  FILE_PATH="${FILE_PATH#$PROJ_DIR/}"
fi

# Skip non-source files
case "$FILE_PATH" in
  .claude/*|docs/*|*.md|*.json|*.yml|*.yaml|*.toml|*.cfg|*.ini|*.env*|*.lock|*.txt)
    exit 0
    ;;
  __pycache__/*|node_modules/*|.git/*|dist/*|build/*|venv/*|*.pyc|*.egg-info/*)
    exit 0
    ;;
esac

# Extract the top-level source directory
TOP_DIR=$(echo "$FILE_PATH" | cut -d'/' -f1)

# Skip root-level files (no directory structure)
if [ "$TOP_DIR" = "$FILE_PATH" ]; then
  exit 0
fi

# Maintain a modification log for /context-refresh to consume
# Format: timestamp | directory | file_path
LOG_FILE=".claude/context/_modifications.log"
if [ -d ".claude/context" ]; then
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) | ${TOP_DIR} | ${FILE_PATH}" >> "$LOG_FILE"

  # Keep log under 200 lines (rotate oldest)
  if [ -f "$LOG_FILE" ]; then
    LINE_COUNT=$(wc -l < "$LOG_FILE" | tr -d ' ')
    if [ "$LINE_COUNT" -gt 200 ]; then
      tail -100 "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
    fi
  fi
fi

exit 0
