#!/usr/bin/env bash
# Hook: SessionStart → matcher: compact
# Purpose: Re-inject PROJECT_STATE.md after context compaction
# stdout becomes context for Claude

# Output PROJECT_STATE if it exists
if [ -f "docs/PROJECT_STATE.md" ]; then
  echo "=== PROJECT STATE (re-injected after compaction) ==="
  cat docs/PROJECT_STATE.md
  echo ""
fi

# Surface urgent messages if non-empty
if [ -s "docs/teams/URGENT.jsonl" ]; then
  echo "=== URGENT MESSAGES (cross-team) ==="
  cat docs/teams/URGENT.jsonl
  echo ""
fi

exit 0
