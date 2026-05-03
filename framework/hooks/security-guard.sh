#!/usr/bin/env bash
# Hook: PreToolUse → Bash
# Purpose: Block destructive commands that could cause irreversible damage
# Exit 0 = allow, Exit 2 = block

set -euo pipefail

# Read tool input from stdin
INPUT=$(cat)

# Parse command from JSON — fail open if parsing fails
COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('tool_input', {}).get('command', ''))
except:
    print('')
" 2>/dev/null) || { exit 0; }

# Empty command — allow
if [ -z "$COMMAND" ]; then
  exit 0
fi

# Blocked patterns — catastrophic/irreversible operations
BLOCKED_PATTERNS=(
  'rm -rf /'
  'rm -rf --no-preserve-root'
  'DROP TABLE'
  'DROP DATABASE'
  'TRUNCATE TABLE'
  'git push.*--force.*main'
  'git push.*--force.*master'
  'git push.*-f.*main'
  'git push.*-f.*master'
  'dd if=.* of=/dev/'
  'mkfs\.'
  ':(){:|:&};:'
  '> /dev/sd'
  'chmod -R 777 /'
  'chown -R .* /'
  '.*> .*context-health-score'
  'sed.*context-health-score'
  'cp .* .*context-health-score'
  'mv .* .*context-health-score'
  '.*> .*file-lock-guard'
  '.*> .*security-guard'
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiE "$pattern"; then
    echo "BLOCKED: Destructive command detected — '$pattern'" >&2
    echo "If this is intentional, run the command manually outside Claude Code." >&2
    exit 2
  fi
done

exit 0
