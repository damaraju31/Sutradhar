#!/usr/bin/env bash
# Agent Team Framework — Project Initialization Script
# Compatible with bash 3.2+ (macOS default)
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FRAMEWORK_DIR="$SKILL_DIR/framework"
TODAY=$(date +%Y-%m-%d)

# ── Team data lookup functions (bash 3.2 compatible) ──────────────────────────

team_agents() {
  case "$1" in
    product)     echo "product-cpo product-researcher product-apm" ;;
    engineering) echo "engineering-architect engineering-frontend engineering-backend engineering-reviewer engineering-tester engineering-tech-explorer" ;;
    design)      echo "design-lead design-ux-researcher design-ui-spec" ;;
    devops)      echo "devops-lead devops-infra devops-monitoring" ;;
    security)    echo "security-lead security-auditor security-privacy" ;;
    analytics)   echo "analytics-lead analytics-analyst" ;;
    business)    echo "business-strategist business-analyst business-pitch" ;;
    growth)      echo "growth-lead growth-seo growth-landing" ;;
    cx)          echo "cx-lead cx-docs cx-feedback" ;;
    *)           echo ""; return 1 ;;
  esac
}

team_skills() {
  case "$1" in
    product)     echo "product-prd product-ideate" ;;
    engineering) echo "engineering-architect engineering-scaffold engineering-implement engineering-review" ;;
    design)      echo "design-system design-ux-flows design-ui-spec" ;;
    devops)      echo "devops-cicd devops-deploy" ;;
    business)    echo "business-revenue" ;;
    growth)      echo "growth-launch-plan" ;;
    security|analytics|cx) echo "" ;;
    *)           echo "" ;;
  esac
}

team_head() {
  case "$1" in
    product)     echo "product-cpo" ;;
    engineering) echo "engineering-architect" ;;
    design)      echo "design-lead" ;;
    devops)      echo "devops-lead" ;;
    security)    echo "security-lead" ;;
    analytics)   echo "analytics-lead" ;;
    business)    echo "business-strategist" ;;
    growth)      echo "growth-lead" ;;
    cx)          echo "cx-lead" ;;
    *)           echo ""; return 1 ;;
  esac
}

team_model() {
  case "$1" in
    product|engineering|design|business) echo "claude-opus-4-6" ;;
    *)                                   echo "claude-sonnet-4-5-20250929" ;;
  esac
}

team_tier() {
  case "$1" in
    product|engineering|design) echo "1" ;;
    devops|analytics|security)  echo "2" ;;
    *)                          echo "3" ;;
  esac
}

capitalize() {
  case "$1" in
    cx)      echo "CX" ;;
    devops)  echo "DevOps" ;;
    *)       echo "$(echo "${1:0:1}" | tr '[:lower:]' '[:upper:]')${1:1}" ;;
  esac
}

# ── Parse arguments ────────────────────────────────────────────────────────────
NAME="" DESCRIPTION="" STACK="" TEAMS="" CONVENTIONS=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --name)        NAME="$2";        shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --stack)       STACK="$2";       shift 2 ;;
    --teams)       TEAMS="$2";       shift 2 ;;
    --conventions) CONVENTIONS="$2"; shift 2 ;;
    --date)        TODAY="$2";       shift 2 ;;
    *) echo "Unknown argument: $1"; exit 1 ;;
  esac
done

# ── Validate required args ─────────────────────────────────────────────────────
for arg_name in NAME DESCRIPTION STACK TEAMS; do
  eval "val=\$$arg_name"
  if [[ -z "$val" ]]; then
    lower=$(echo "$arg_name" | tr '[:upper:]' '[:lower:]')
    echo "Error: --$lower is required"
    exit 1
  fi
done

# ── Parse and validate team list ───────────────────────────────────────────────
IFS=',' read -ra RAW_TEAMS <<< "$TEAMS"
SANITIZED_TEAMS=()
for t in "${RAW_TEAMS[@]}"; do
  t=$(echo "$t" | tr -d ' \t')
  if ! team_head "$t" > /dev/null 2>&1; then
    echo "Error: Unknown team '$t'. Valid: product engineering design devops security analytics business growth cx"
    exit 1
  fi
  SANITIZED_TEAMS+=("$t")
done

# ── Create directory structure ─────────────────────────────────────────────────
mkdir -p \
  .claude/agents \
  .claude/skills \
  .claude/commands \
  .claude/agent-memory \
  docs/tasks/completed \
  docs/reviews

echo "Created project directories."

# ── Copy agents for active teams ───────────────────────────────────────────────
for team in "${SANITIZED_TEAMS[@]}"; do
  for agent in $(team_agents "$team"); do
    src="$FRAMEWORK_DIR/agents/${agent}.md"
    if [[ -f "$src" ]]; then
      cp "$src" ".claude/agents/${agent}.md"
    else
      echo "Warning: Agent file not found: $src"
    fi
  done
done
echo "Copied agents."

# ── Copy skills for active teams ───────────────────────────────────────────────
for team in "${SANITIZED_TEAMS[@]}"; do
  skills=$(team_skills "$team")
  if [[ -n "$skills" ]]; then
    for skill in $skills; do
      src="$FRAMEWORK_DIR/skills/$skill"
      if [[ -d "$src" ]]; then
        cp -r "$src" ".claude/skills/$skill"
      else
        echo "Warning: Skill directory not found: $src"
      fi
    done
  fi
done
echo "Copied skills."

# ── Copy control commands ──────────────────────────────────────────────────────
if [[ -d "$FRAMEWORK_DIR/commands" ]]; then
  cp -r "$FRAMEWORK_DIR/commands/." ".claude/commands/"
  echo "Copied control commands."
fi

# ── Copy task template ─────────────────────────────────────────────────────────
if [[ -f "$FRAMEWORK_DIR/templates/TASK.md" ]]; then
  cp "$FRAMEWORK_DIR/templates/TASK.md" "docs/tasks/TASK.md.template"
  echo "Copied task template."
fi

# ── Build replacement content for templates ────────────────────────────────────

# Active Teams table for CLAUDE.md
ACTIVE_TEAMS_TABLE="| Team | Head Agent | Launch |
|------|-----------|--------|"
for team in "${SANITIZED_TEAMS[@]}"; do
  head=$(team_head "$team")
  cap=$(capitalize "$team")
  ACTIVE_TEAMS_TABLE="$ACTIVE_TEAMS_TABLE
| $cap | \`$head\` | \`claude --agent $head\` |"
done

# Team table for PROJECT_STATE.md
TEAM_TABLE=""
i=1
for team in "${SANITIZED_TEAMS[@]}"; do
  head=$(team_head "$team")
  cap=$(capitalize "$team")
  row="| $i | $cap | $head | Active | $TODAY |"
  TEAM_TABLE="${TEAM_TABLE:+$TEAM_TABLE
}$row"
  i=$((i+1))
done

CONVENTIONS_TEXT="${CONVENTIONS:-Follow existing patterns. Prefer readability over cleverness. No premature optimization.}"

# Export multi-line vars so Python can read them via os.environ
export ACTIVE_TEAMS_TABLE
export TEAM_TABLE

# ── Process CLAUDE.md template ────────────────────────────────────────────────
sed \
  -e "s|{{PROJECT_NAME}}|$NAME|g" \
  -e "s|{{PROJECT_DESCRIPTION}}|$DESCRIPTION|g" \
  -e "s|{{TECH_STACK}}|$STACK|g" \
  -e "s|{{CODING_CONVENTIONS}}|$CONVENTIONS_TEXT|g" \
  "$FRAMEWORK_DIR/templates/CLAUDE.md.template" > CLAUDE.md

python3 - << 'PYEOF'
import os

with open('CLAUDE.md') as f:
    content = f.read()

table = os.environ.get('ACTIVE_TEAMS_TABLE', '')
content = content.replace('{{ACTIVE_TEAMS}}', table)

with open('CLAUDE.md', 'w') as f:
    f.write(content)
PYEOF

echo "Created CLAUDE.md."

# ── Process PROJECT_STATE.md template ─────────────────────────────────────────
sed \
  -e "s|{{PROJECT_NAME}}|$NAME|g" \
  -e "s|{{CREATED_DATE}}|$TODAY|g" \
  "$FRAMEWORK_DIR/templates/PROJECT_STATE.md.template" > docs/PROJECT_STATE.md

python3 - << 'PYEOF'
import os

with open('docs/PROJECT_STATE.md') as f:
    content = f.read()

table = os.environ.get('TEAM_TABLE', '')
content = content.replace('{{TEAM_TABLE}}', table)

with open('docs/PROJECT_STATE.md', 'w') as f:
    f.write(content)
PYEOF

echo "Created docs/PROJECT_STATE.md."

# ── Create team directories, briefs, and empty logs ───────────────────────────
for team in "${SANITIZED_TEAMS[@]}"; do
  team_dir="docs/teams/$team"
  mkdir -p "$team_dir"

  head=$(team_head "$team")
  cap=$(capitalize "$team")
  tier=$(team_tier "$team")
  model=$(team_model "$team")

  # Build supporting agents rows
  SUPPORTING_ROWS=""
  for agent in $(team_agents "$team"); do
    if [[ "$agent" != "$head" ]]; then
      SUPPORTING_ROWS="${SUPPORTING_ROWS:+$SUPPORTING_ROWS
}| $agent | sonnet | Supporting |"
    fi
  done

  sed \
    -e "s|{{TEAM_NAME}}|$cap|g" \
    -e "s|{{TEAM_TIER}}|Tier $tier|g" \
    -e "s|{{HEAD_AGENT}}|$head|g" \
    -e "s|{{HEAD_MODEL}}|$model|g" \
    -e "s|{{CREATED_DATE}}|$TODAY|g" \
    -e "s|{{TEAM_MISSION}}|[To be defined in first session with head agent]|g" \
    -e "s|{{SCOPE_IN}}|- [Defined in first session]|g" \
    -e "s|{{SCOPE_OUT}}|- [Defined in first session]|g" \
    -e "s|{{DELIVERABLES}}|- [Defined in first session]|g" \
    -e "s|{{DEPENDENCIES}}|- [Defined in first session]|g" \
    "$FRAMEWORK_DIR/templates/TEAM_BRIEF.md.template" > "$team_dir/TEAM_BRIEF.md"

  export SUPPORTING_ROWS
  BRIEF_PATH="$team_dir/TEAM_BRIEF.md"
  export BRIEF_PATH
  python3 - << 'PYEOF'
import os

brief_path = os.environ.get('BRIEF_PATH', '')
supporting = os.environ.get('SUPPORTING_ROWS', '')

with open(brief_path) as f:
    content = f.read()

content = content.replace('{{SUPPORTING_AGENTS}}', supporting)

with open(brief_path, 'w') as f:
    f.write(content)
PYEOF

  cat > "$team_dir/DECISIONS.md" << EOF
# Decisions — $cap Team

<!-- Latest first. Written by head agent, updated by /project-sync -->

| # | Decision | Date | Context |
|---|----------|------|---------|
| — | None yet | — | — |
EOF

  cat > "$team_dir/STATE_UPDATE.md" << EOF
# State Update — $cap Team

<!-- Written by head agent after completing work. Processed by /project-sync. -->

_No pending updates._
EOF

done
echo "Created team directories and briefs."

# ── Print success and launch commands ─────────────────────────────────────────
echo ""
echo "✓ $NAME initialized successfully!"
echo ""
echo "Launch commands (open one terminal tab per team):"
echo ""
for team in "${SANITIZED_TEAMS[@]}"; do
  head=$(team_head "$team")
  cap=$(capitalize "$team")
  printf "  %-15s claude --agent %s\n" "$cap:" "$head"
done
echo ""
echo "Tip: Start with the Product team. Run /product-ideate to begin."
