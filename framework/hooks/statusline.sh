#!/usr/bin/env bash
# Agent Team Framework — Context-Aware Statusline
# Displays context usage, cost, model, agent, and git info
# SIDE EFFECT: Writes context data to /tmp/claude-context-status.json for agent access

input=$(cat)

# Extract raw values
MODEL=$(echo "$input" | jq -r '.model.display_name // "?"')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
REMAINING_PCT=$(echo "$input" | jq -r '.context_window.remaining_percentage // 100' | cut -d. -f1)
WINDOW_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
AGENT=$(echo "$input" | jq -r '.agent.name // ""')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
LINES_ADD=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REM=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
CACHE_WRITE=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')

# Compute derived values
REMAINING_TOKENS=$((WINDOW_SIZE * REMAINING_PCT / 100))
REMAINING_K=$((REMAINING_TOKENS / 1000))

# Cache efficiency: cache_read / (cache_read + input + cache_write) * 100
TOTAL_INPUT=$((CACHE_READ + INPUT_TOKENS + CACHE_WRITE))
if [ "$TOTAL_INPUT" -gt 0 ]; then
  CACHE_EFF=$((CACHE_READ * 100 / TOTAL_INPUT))
else
  CACHE_EFF=0
fi

# Cost per minute (guard against zero duration)
if [ "$DURATION_MS" -gt 0 ]; then
  COST_PER_MIN=$(echo "$COST $DURATION_MS" | awk '{printf "%.3f", $1 / ($2 / 60000)}')
else
  COST_PER_MIN="0.000"
fi

# Active plan check (only if not completed)
ACTIVE_PLAN=false
if [ -f "docs/ACTIVE_PLAN.md" ] && ! grep -qi "status.*completed" docs/ACTIVE_PLAN.md 2>/dev/null; then
  ACTIVE_PLAN=true
fi

# Write enriched context data to temp file for agent introspection
cat > /tmp/claude-context-status.json <<JSONEOF
{
  "used_pct": $PCT,
  "remaining_pct": $REMAINING_PCT,
  "remaining_tokens": $REMAINING_TOKENS,
  "window_size": $WINDOW_SIZE,
  "cache_efficiency_pct": $CACHE_EFF,
  "cost_usd": $COST,
  "cost_per_min": $COST_PER_MIN,
  "duration_ms": $DURATION_MS,
  "model": "$MODEL",
  "agent": "$AGENT",
  "active_plan": $ACTIVE_PLAN,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
JSONEOF

# ANSI colors
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'
CYAN='\033[36m'
DIM='\033[2m'
RESET='\033[0m'

# Color-code context percentage
if [ "$PCT" -ge 80 ]; then
  CTX_COLOR="$RED"
elif [ "$PCT" -ge 60 ]; then
  CTX_COLOR="$YELLOW"
else
  CTX_COLOR="$GREEN"
fi

# Progress bar (10 chars)
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && BAR=$(printf "%${FILLED}s" | tr ' ' '#')
[ "$EMPTY" -gt 0 ] && BAR="${BAR}$(printf "%${EMPTY}s" | tr ' ' '-')"

# Duration formatting
MINS=$((DURATION_MS / 60000))
SECS=$(((DURATION_MS % 60000) / 1000))

# Git branch (cached to avoid slowness)
CACHE_FILE="/tmp/statusline-git-cache"
if [ ! -f "$CACHE_FILE" ] || [ $(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0))) -gt 5 ]; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "")
  echo "$BRANCH" > "$CACHE_FILE"
else
  BRANCH=$(cat "$CACHE_FILE")
fi

# Line 1: Model, agent, git branch
LINE1="${CYAN}[${MODEL}]${RESET}"
[ -n "$AGENT" ] && LINE1="${LINE1} ${DIM}agent:${RESET}${AGENT}"
[ -n "$BRANCH" ] && LINE1="${LINE1} ${DIM}|${RESET} ${GREEN}${BRANCH}${RESET}"
[ "$ACTIVE_PLAN" = "true" ] && LINE1="${LINE1} ${YELLOW}[PLAN]${RESET}"

# Line 2: Context bar, remaining, cost, cache efficiency, duration, lines changed
COST_FMT=$(printf '$%.2f' "$COST")
WARNING=""
[ "$PCT" -ge 80 ] && WARNING=" !!!"
LINE2="${CTX_COLOR}${BAR} ${PCT}%%${RESET} ${DIM}|${RESET} ${REMAINING_K}k left ${DIM}|${RESET} ${YELLOW}${COST_FMT}${RESET} ${DIM}|${RESET} cache:${CACHE_EFF}%% ${DIM}|${RESET} ${MINS}m${SECS}s ${DIM}|${RESET} +${LINES_ADD}/-${LINES_REM}${WARNING}"

echo -e "$LINE1"
echo -e "$LINE2"
