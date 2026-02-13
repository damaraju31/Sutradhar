#!/usr/bin/env bash
# install.sh — Install agent-team-framework to ~/.claude/skills/project-init/
# Usage: bash install.sh

set -u

INSTALL_DIR="$HOME/.claude/skills/project-init"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ─── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { printf "  %s\n" "$1"; }
success() { printf "${GREEN}  ✓ %s${RESET}\n" "$1"; }
warn()    { printf "${YELLOW}  ⚠ %s${RESET}\n" "$1"; }
error()   { printf "${RED}  ✗ %s${RESET}\n" "$1"; }
header()  { printf "\n${BOLD}%s${RESET}\n" "$1"; }

# ─── Step 1: Check Claude Code ────────────────────────────────────────────────
header "Checking prerequisites..."

if ! command -v claude >/dev/null 2>&1; then
  error "Claude Code CLI not found."
  info  "Install it from: https://claude.ai/code"
  info  "Then run this script again."
  exit 1
fi
success "Claude Code found: $(claude --version 2>/dev/null | head -1 || echo 'installed')"

# ─── Step 2: Check Python 3 ───────────────────────────────────────────────────
if ! command -v python3 >/dev/null 2>&1; then
  error "Python 3 is required by the project init script."
  info  "Install it: brew install python3  (macOS)  |  apt install python3  (Linux)"
  exit 1
fi
success "Python 3 found: $(python3 --version 2>&1)"

# ─── Step 3: Check bash version (warn only) ───────────────────────────────────
BASH_MAJOR="${BASH_VERSION%%.*}"
if [ "$BASH_MAJOR" -lt 3 ]; then
  warn "bash 3.2+ recommended. You have $BASH_VERSION. Proceeding anyway."
fi

# ─── Step 4: Fresh install vs upgrade ─────────────────────────────────────────
header "Installing..."

if [ -d "$INSTALL_DIR" ]; then
  MODE="upgrade"
  OLD_VERSION="unknown"
  if [ -f "$INSTALL_DIR/VERSION" ]; then
    OLD_VERSION=$(cat "$INSTALL_DIR/VERSION" | tr -d '[:space:]')
  fi
  NEW_VERSION="unknown"
  if [ -f "$SCRIPT_DIR/VERSION" ]; then
    NEW_VERSION=$(cat "$SCRIPT_DIR/VERSION" | tr -d '[:space:]')
  fi
  info "Existing installation found (v${OLD_VERSION}). Upgrading to v${NEW_VERSION}..."

  # Back up existing install
  BACKUP_DIR="${INSTALL_DIR}.bak.$(date +%Y%m%d%H%M%S)"
  cp -r "$INSTALL_DIR" "$BACKUP_DIR"
  success "Backup saved to: $BACKUP_DIR"
else
  MODE="fresh"
  info "No existing installation found. Installing fresh..."
fi

# ─── Step 5: Create directories ───────────────────────────────────────────────
mkdir -p "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/scripts"
mkdir -p "$INSTALL_DIR/framework"

# ─── Step 6: Copy files ───────────────────────────────────────────────────────
cp "$SCRIPT_DIR/SKILL.md"          "$INSTALL_DIR/SKILL.md"
cp -r "$SCRIPT_DIR/scripts/"       "$INSTALL_DIR/scripts/"
cp -r "$SCRIPT_DIR/framework/"     "$INSTALL_DIR/framework/"

# Copy VERSION file
if [ -f "$SCRIPT_DIR/VERSION" ]; then
  cp "$SCRIPT_DIR/VERSION" "$INSTALL_DIR/VERSION"
fi

# Make scripts executable
chmod +x "$INSTALL_DIR/scripts/init.sh"
find "$INSTALL_DIR/framework/skills" -name "validate.sh" -exec chmod +x {} \;

# ─── Step 7: Verify installation ──────────────────────────────────────────────
FAILED=0
for f in \
  "$INSTALL_DIR/SKILL.md" \
  "$INSTALL_DIR/scripts/init.sh" \
  "$INSTALL_DIR/framework/agents/product-cpo.md" \
  "$INSTALL_DIR/framework/agents/engineering-architect.md" \
  "$INSTALL_DIR/framework/commands/launch-team.md" \
  "$INSTALL_DIR/framework/templates/CLAUDE.md.template"
do
  if [ ! -f "$f" ]; then
    error "Missing after install: $f"
    FAILED=1
  fi
done

if [ "$FAILED" -eq 1 ]; then
  error "Installation incomplete. The repo may not have been fully cloned."
  info  "Try: git clone --depth 1 <repo-url> && cd agent-team-framework && bash install.sh"
  exit 1
fi

FILE_COUNT=$(find "$INSTALL_DIR" -type f | wc -l | tr -d ' ')
success "Installed $FILE_COUNT files to $INSTALL_DIR"

# ─── Step 8: Success ──────────────────────────────────────────────────────────
printf "\n${GREEN}${BOLD}agent-team-framework installed successfully.${RESET}\n\n"
printf "  /project-init is now available in any Claude Code session.\n\n"
printf "${BOLD}To get started:${RESET}\n"
printf "  1. Go to your project:    cd my-project\n"
printf "  2. Open Claude Code:      claude\n"
printf "  3. Initialize the team:   /project-init\n\n"
printf "  Claude will ask for project name, description, tech stack,\n"
printf "  and which teams to activate. Then it scaffolds everything.\n\n"
printf "${BOLD}To upgrade later:${RESET}\n"
printf "  git pull && bash install.sh\n\n"
printf "${BOLD}To uninstall:${RESET}\n"
printf "  bash uninstall.sh\n\n"
