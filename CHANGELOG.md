# Changelog

## v1.1.0 — 2026-03-01

Integration enhancement release: coordination layer, hooks, tmux, and shareability fixes.

### Added

- **Hooks system** — 6 automated hooks with `.claude/settings.json` configuration:
  - `security-guard.sh` — blocks destructive Bash commands (rm -rf /, DROP TABLE, force push to main)
  - `code-quality-gate.sh` — runs tests when coding subagents complete
  - `notify-completion.sh` — desktop notification (macOS + Linux) + tmux + activity log
  - `context-recovery.sh` — re-injects PROJECT_STATE.md after context compaction
  - `ensure-state-update.sh` — reminds agents to write STATE_UPDATE.md before stopping
  - `track-changes.sh` — logs file changes to ACTIVITY.log
- **tmux integration** — `launch-team` now creates tmux windows; `stop-all` command added
- **Agent Teams opt-in** — when `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is set, `/launch-team` offers Agent Teams as a launch option
- **Pre-gathered context pattern** — head agents fill task file context before delegating to coding subagents
- **Error escalation protocol** — blocked → STATE_UPDATE → URGENT.jsonl workflow
- **Progress visibility** — `docs/teams/ACTIVITY.log` and `docs/teams/URGENT.jsonl` created during init
- **Git rollback convention** — Architect creates `impl/{feature}` branches; coding agents aware of reset capability
- **Context compaction guidance** — `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=0.85` tip for long sessions
- **`maxTurns`** frontmatter for all 29 agents (200/150/100/75/50 by tier)
- **Cross-project memory** — 4 strategic agents (CPO, Architect, Design Lead, Business Strategist) use `memory: user` for cross-project wisdom

### Changed

- `tools: Task` → `tools: Agent` across all agent files (Claude Code v2.1.63 rename)
- CLAUDE.md template expanded with Coordination Model, Active Hooks, Branch Discipline sections
- SKILL.md updated with complete file list, hooks, tmux recommendation, python3 prerequisite
- `install.sh` now sets executable permissions on hook scripts and verifies hooks/settings installation
- `init.sh` copies hooks, creates settings.json, creates ACTIVITY.log/URGENT.jsonl, outputs tmux instructions

### Fixed

- Removed dead `skills: [coding-standards]` reference from engineering-frontend and engineering-backend agents
- `validate.sh` scripts now get `chmod +x` after skill copy (survives zip transfer)

## v1.0.0 — 2026-02-12

Initial release.

### What's Included

- 29 agents across 9 teams (Product, Engineering, Design, DevOps, Security, Analytics, Business, Growth, CX)
- 13 workflow skills with templates and validation scripts
- 5 control commands (launch-team, project-status, project-sync, activate/deactivate-team)
- 4 project templates (CLAUDE.md, PROJECT_STATE.md, TEAM_BRIEF.md, TASK.md)
- init.sh: per-project initialization with team selection, tech stack configuration, and full directory scaffold

### Agent Roster (29 total)

6 merges applied during design to eliminate redundancy:
- `devops-cicd` + `devops-cloud` → `devops-infra`
- `engineering-db` → merged into `engineering-backend`
- `analytics-metrics` + `analytics-dashboard` → `analytics-analyst`
- `business-revenue` + `business-pricing` → `business-analyst`
- `cx-faq` → merged into `cx-docs`
- `growth-content` → merged into `growth-lead`
