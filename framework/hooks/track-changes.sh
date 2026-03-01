#!/usr/bin/env bash
# Hook: PostToolUse → matcher: Write|Edit (async: true)
# Purpose: Log file changes for progress visibility
# Never fails — async, fire-and-forget

# Read hook payload from stdin
INPUT=$(cat) || true

# Parse tool name and file path from JSON
PARSED=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    tool = data.get('tool_name', 'unknown')
    path = data.get('tool_input', {}).get('file_path', 'unknown')
    print(f'{tool}\t{path}')
except:
    print('unknown\tunknown')
" 2>/dev/null) || echo "unknown	unknown"

TOOL_NAME=$(echo "$PARSED" | cut -f1)
FILE_PATH=$(echo "$PARSED" | cut -f2)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ") || true

echo "[$TIMESTAMP] FILE_CHANGE tool=\"$TOOL_NAME\" file=\"$FILE_PATH\"" >> docs/teams/ACTIVITY.log 2>/dev/null || true

exit 0
