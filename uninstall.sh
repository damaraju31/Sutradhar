#!/usr/bin/env bash
# uninstall.sh — Remove agent-team-framework from ~/.claude/skills/project-init/
# Usage: bash uninstall.sh

set -u

INSTALL_DIR="$HOME/.claude/skills/project-init"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

# ─── Check if installed ───────────────────────────────────────────────────────
if [ ! -d "$INSTALL_DIR" ]; then
  echo "Nothing to uninstall — $INSTALL_DIR does not exist."
  exit 0
fi

# ─── Warn about scope ─────────────────────────────────────────────────────────
printf "\n${YELLOW}This will remove:${RESET}\n"
printf "  $INSTALL_DIR\n\n"
printf "  Files already copied into your projects (.claude/ dirs) are NOT affected.\n\n"

# ─── Confirm (interactive only) ───────────────────────────────────────────────
if [ -t 0 ]; then
  printf "Continue? [y/N] "
  read -r confirm
  case "$confirm" in
    [yY]) ;;
    *) echo "Aborted."; exit 0 ;;
  esac
fi

# ─── Remove ───────────────────────────────────────────────────────────────────
rm -rf "$INSTALL_DIR"

printf "\n${GREEN}${BOLD}agent-team-framework uninstalled.${RESET}\n"
printf "  Removed: $INSTALL_DIR\n"
printf "  Your existing projects are unchanged.\n\n"
