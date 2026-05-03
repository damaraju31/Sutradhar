# Changelog

## v0.1.0 — 2026-05-03 (Open-source release)

First public release of Sutradhar (renamed from `agent-team-framework`).

### Added

- `LICENSE` (MIT), `CONTRIBUTING.md`, `.github/` issue + PR templates
- Public-facing documentation:
  - `docs/USAGE.md` — operator guide (install, bootstrap, run teams, extend, troubleshoot)
  - `docs/DESIGN_RATIONALE.md` — design choices and trade-offs
  - `docs/CONTEXT_HIERARCHY.md` — L0/L1/L2 operational spec
- `README.md` rewritten for a public audience (172 lines, ASCII architecture diagram)

### Changed

- Project renamed: `agent-team-framework` → `Sutradhar`
- Internal working notes (`spec/`, `docs/dev/`, project-local `CLAUDE.md`) gitignored
- `tests/` gitignored (kept locally; not part of the public distribution)

## v1.2.0 — 2026-03-14

Cultural DNA, context engineering, and prompt enhancements.

### Added

- **Three-layer context hierarchy** (L0/L1/L2):
  - L0 — `CLAUDE.md` always-loaded project identity (≤100 lines)
  - L1 — `.claude/rules/*.md` path-triggered domain rules (≤50 lines each)
  - L2 — `.claude/context/components/*.md` and `decisions/ADR-*.md` on-demand
- `scripts/context-health-score.sh` — 636-line deterministic 0-100 evaluator across Coverage / Freshness / Accuracy / Completeness dimensions. Runs outside the agent.
- `scripts/token-counter.py` — offline token estimator with `--from-task` extraction
- `context-budget-analyst` agent (30th agent) — Haiku-powered, learned multipliers
- New skills:
  - `context-create`, `context-refresh`, `project-bootstrap` (5-phase analysis pipeline)
  - `cpo-persona`, `cfo-persona`, `system-architect` (composable role lenses)
- New hooks:
  - `file-lock-guard.sh` — blocks Edit/Write to safety infrastructure
  - `context-maintenance.sh` — tracks source modifications for drift detection
  - `statusline.sh` — enriched 2-line terminal display + `/tmp/claude-context-status.json`
- `security-guard.sh` — 6 new patterns blocking writes to safety hooks themselves
- 12 cultural-DNA principles in `CLAUDE.md` (User-First, Own the Outcome, Plan Deep, etc.)
- Composable templates: `CLAUDE.md.base.template` + `CLAUDE.md.teams.template`
- `init.sh` rewritten — supports context-only mode (no teams), creates `.claude/rules/` and `.claude/context/` trees

### Changed

- `engineering-frontend` and `engineering-backend` enforce a two-outputs rule: every code change produces a paired context update (rule file, component file, or ADR + Provenance entry)
- `engineering-architect` and `product-cpo` reference persona skills via frontmatter
- `install.sh` registers `/project-bootstrap` as a global standalone skill

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
