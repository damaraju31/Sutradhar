#!/usr/bin/env bash
# Hook: SubagentStop → all agents (async: true)
# Purpose: Log completion + desktop notification + tmux notification
# Never fails, never blocks — all operations wrapped in || true

# Read hook payload from stdin
INPUT=$(cat) || true

# Parse agent type from JSON
AGENT_TYPE=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('agent_type', 'unknown'))
except:
    print('unknown')
" 2>/dev/null) || echo "unknown"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ") || true

# Log to activity log
echo "[$TIMESTAMP] AGENT_STOP agent=\"$AGENT_TYPE\"" >> docs/teams/ACTIVITY.log 2>/dev/null || true

# Desktop notification (macOS or Linux)
if command -v osascript &>/dev/null; then
  osascript -e "display notification \"$AGENT_TYPE completed work\" with title \"Agent Team\"" 2>/dev/null || true
elif command -v notify-send &>/dev/null; then
  notify-send "Agent Team" "$AGENT_TYPE completed work" 2>/dev/null || true
fi

# tmux notification (if inside tmux)
if [ -n "${TMUX:-}" ]; then
  tmux display-message -t 0 "Agent '$AGENT_TYPE' completed" 2>/dev/null || true
fi

exit 0
