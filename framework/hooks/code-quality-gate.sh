#!/usr/bin/env bash
# Hook: SubagentStop → matcher: engineering-frontend|engineering-backend
# Purpose: Run tests before accepting coding subagent work
# Exit 0 = allow stop, Exit 2 = block stop (send agent back to fix)

set -euo pipefail

# Read hook payload from stdin
INPUT=$(cat)

# Check for stop_hook_active to prevent infinite loops
STOP_HOOK_ACTIVE=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('stop_hook_active', False))
except:
    print('False')
" 2>/dev/null) || true

if [ "$STOP_HOOK_ACTIVE" = "True" ] || [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

# Detect test runner
TEST_CMD=""
if [ -f "package.json" ]; then
  # Check for test script in package.json
  HAS_TEST=$(python3 -c "
import json
try:
    pkg = json.load(open('package.json'))
    scripts = pkg.get('scripts', {})
    test_cmd = scripts.get('test', '')
    if test_cmd and 'no test specified' not in test_cmd:
        print('yes')
    else:
        print('no')
except:
    print('no')
" 2>/dev/null) || echo "no"
  if [ "$HAS_TEST" = "yes" ]; then
    TEST_CMD="npm test"
  fi
elif [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "setup.cfg" ]; then
  if command -v pytest &>/dev/null; then
    TEST_CMD="pytest --tb=short -q"
  fi
elif [ -f "Cargo.toml" ]; then
  TEST_CMD="cargo test"
fi

# No test runner detected — allow
if [ -z "$TEST_CMD" ]; then
  exit 0
fi

# Run tests
echo "Running tests: $TEST_CMD" >&2
if eval "$TEST_CMD" >&2 2>&1; then
  echo "Tests passed." >&2
  # Log success
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  echo "[$TIMESTAMP] TEST_PASS command=\"$TEST_CMD\"" >> docs/teams/ACTIVITY.log 2>/dev/null || true
  exit 0
else
  echo "Tests FAILED. Fix the failing tests before completing." >&2
  # Log failure
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  echo "[$TIMESTAMP] TEST_FAIL command=\"$TEST_CMD\"" >> docs/teams/ACTIVITY.log 2>/dev/null || true
  exit 2
fi
