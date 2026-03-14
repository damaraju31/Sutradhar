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

# Re-inject team brief if agent name is identifiable
AGENT_NAME="${CLAUDE_AGENT_NAME:-}"
if [ -n "$AGENT_NAME" ]; then
  for team_dir in docs/teams/*/; do
    if [ -f "${team_dir}TEAM_BRIEF.md" ]; then
      if grep -q "$AGENT_NAME" "${team_dir}TEAM_BRIEF.md" 2>/dev/null; then
        echo "=== TEAM BRIEF (re-injected after compaction) ==="
        cat "${team_dir}TEAM_BRIEF.md"
        echo ""
        break
      fi
    fi
  done
fi

# Check for active plan (skip if completed)
if [ -f "docs/ACTIVE_PLAN.md" ] && ! grep -qi "status.*completed" docs/ACTIVE_PLAN.md 2>/dev/null; then
  echo "=== ACTIVE PLAN FOUND ==="
  cat docs/ACTIVE_PLAN.md
  echo ""
  echo "Read the referenced plan file and resume execution."
fi

exit 0
