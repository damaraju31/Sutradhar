# Usage

> How to install the framework, bootstrap a project, run teams, and extend the system. For *why* it's built this way, see `DESIGN_RATIONALE.md`. For the context-hierarchy spec, see `CONTEXT_HIERARCHY.md`.

---

## Prerequisites

- [Claude Code CLI](https://claude.ai/code) — `claude --version` must work
- A Claude Max subscription (all model usage bills here; no separate API key needed)
- macOS or Linux, bash 3.2+, Python 3, `jq` recommended (`grep`/`sed` fallback exists)
- `tmux` if you want parallel team sessions

---

## Install

From a clone of this repo:

```bash
bash install.sh
```

That copies the framework to `~/.claude/skills/project-init/` and registers `/project-bootstrap` as a global skill, available in every Claude Code session on your machine.

To upgrade later: `git pull && bash install.sh`. To uninstall: `bash uninstall.sh`.

---

## Bootstrap a project

In any project directory (greenfield, mid-build, or mature):

```bash
cd my-project
claude
```

Then in the Claude Code session:

```
/project-bootstrap
```

The skill detects your project stage and runs the appropriate path:

- **Greenfield** (no source files) — guided interview, then scaffolds `CLAUDE.md`, `.claude/`, `docs/teams/`, foundation ADRs.
- **Mid-build / mature** (source files present) — five-phase analysis pipeline:
  1. Haiku scan — tech stack, file counts, entry points
  2. Four parallel Sonnet agents — pattern extractor, architecture mapper, decision archaeologist, fragility scanner
  3. Opus synthesis — proposes the L0/L1/L2 hierarchy, presents to you for confirmation
  4. Sonnet generation — writes all rule files, component files, ADRs from templates
  5. Sonnet validation — audits generated docs against actual source code

If a previous bootstrap exists, the skill offers merge / replace / refresh paths and creates timestamped backups before any destructive operation.

Full pipeline detail: `framework/skills/project-bootstrap/SKILL.md`.

---

## Run a team

Once bootstrap is done and at least one team is active, launch a team's head agent:

```
/launch-team
```

The command shows your active teams, checks prerequisites for each (e.g., Engineering needs `docs/teams/product/PRD.md`), and offers three launch modes:

| Mode | When to use |
|------|-------------|
| **tmux** (default) | Parallel work across teams. Each team gets its own tmux window with an isolated context window. |
| **Manual** | You want to run a single team in your current terminal. Outputs the `claude --agent <name>` invocation. |
| **Agent Teams (experimental)** | Spawns head agents as "teammates" within the current session. Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` first. Caveat: teammates can't spawn their own sub-agents — use only for strategic/planning phases, not implementation. |

Stop everything: `/stop-all`.

Full mechanics: `framework/commands/launch-team.md`.

---

## Day-to-day cycle

Inside a head-agent session, the rhythm is:

1. Head agent (Architect, CPO, etc.) reads the relevant context, plans, and writes a task file to `docs/tasks/<id>.md`. The task file includes a **Pre-Gathered Context** section listing the exact files the coding agent should read.
2. Head agent delegates to a coding sub-agent (Frontend, Backend, Tester) via the built-in `Agent` tool. Sub-agents follow the 3-phase coding protocol: gather → TDD implement → record outcomes + update context.
3. Sub-agent completes, returns. Code-quality-gate hook runs the test suite at `SubagentStop`. Failure → exit 2 → agent gets sent back.
4. Sub-agent writes outcomes to the task file's Result section and updates context (rule file, component file, or ADR + Provenance entry).
5. Head agent writes a `STATE_UPDATE.md` to its team directory.

When you're ready to reconcile state across teams, run `/project-sync`. It reads all pending `STATE_UPDATE.md` files, merges decisions into `DECISIONS.md`, updates `docs/PROJECT_STATE.md`, and resets the consumed updates.

Cross-team urgencies (e.g., Engineering hits a blocker that affects Product) get appended to `docs/teams/URGENT.jsonl`. Every agent reads this on `SessionStart`.

---

## Other commands

| Command | What it does |
|---------|--------------|
| `/project-bootstrap` | Initial setup (greenfield or existing codebase) |
| `/project-activate-team` | Add a team to an already-bootstrapped project |
| `/project-deactivate-team` | Remove a team |
| `/project-status` | Show team status, active tasks, urgent items |
| `/project-sync` | Reconcile `STATE_UPDATE.md` files into `PROJECT_STATE.md` |
| `/launch-team` | Launch a team's head agent (tmux / manual / Agent Teams) |
| `/stop-all` | Kill all tmux team windows |

Each command's full spec lives in `framework/commands/<name>.md`.

---

## Adding a custom agent

Agents are markdown files. Drop a new file in `.claude/agents/<name>.md`:

```markdown
---
description: One-line description (used by the Agent tool to decide when to invoke)
model: sonnet                      # opus | sonnet | haiku
tools: Agent, Read, Grep, Glob, Edit, Write, Bash
memory: project                    # project | user
maxTurns: 100
skills:
  - some-skill                     # optional
---

# Your Agent Name

System prompt body. Markdown is the prompt — write what you'd write to a contractor.
Cover: role, when to invoke, mandatory protocol, what to write back.
```

Then invoke with `claude --agent <name>` (filename stem, hyphens preserved).

For full registry conventions (model selection, memory scope, tier sizing), see the agent files in `framework/agents/` — 30 worked examples across 9 teams.

---

## Adding a custom hook

Hooks are bash scripts. Drop one in `.claude/hooks/<name>.sh` and register it in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/<name>.sh" }
        ]
      }
    ]
  }
}
```

Each hook reads structured JSON on stdin, returns an exit code:

- `0` — allow (or no-op)
- `2` — block (emit a message on stderr explaining why)

Available lifecycle events: `PreToolUse`, `PostToolUse`, `SubagentStop`, `SessionStart`. The nine framework hooks in `framework/hooks/` are full worked examples — copy and adapt.

---

## Token budgeting

Two tools help you size a task before launching an agent:

- **`scripts/token-counter.py`** — offline, supports per-file token estimation either via the Anthropic API (exact) or a character heuristic (~85-90% accuracy). Pass `--from-task <task-file>` to extract file lists from a task file. Outputs JSON with per-file counts, total, % of 200k budget, and a recommendation.
- **`context-budget-analyst` agent** — Haiku-powered, wraps the token counter and adds learned multipliers (cold start: implementation=8x, review=3x, research=2x; recalculates per project after 3+ completed tasks).

Use these when you suspect a task might overflow context, before paying for the run.

---

## Troubleshooting

**`/project-bootstrap` not found.** Ensure `install.sh` ran successfully. The skill should appear in `~/.claude/skills/project-bootstrap/SKILL.md`. Restart `claude`.

**Hook fails silently.** Check `~/.claude/logs/` and the hook's stderr. All shipped hooks fail-open on parse errors (exit 0) — a silent failure means JSON parsing failed but execution continued. Run the hook manually with `echo '{}' | bash .claude/hooks/<name>.sh` to reproduce.

**`jq: command not found`.** Hooks fall back to `grep`/`sed` parsing if `jq` is missing, but `jq` is more reliable. Install: `brew install jq` (macOS) or `apt-get install jq` (Linux).

**Tests block at SubagentStop in an infinite loop.** The `code-quality-gate` hook has a `stop_hook_active` guard, but if you customize it, ensure it short-circuits when the flag is set.

**Health score drops over time.** Expected — code drifts faster than context. Run `/context-refresh` to reconcile. The score history lives in `.claude/context/_health_history.log`.

**Notifications missing on Linux.** Install `notify-send` (part of `libnotify-bin`). The `notify-completion` hook fails open if the binary isn't present.

---

## Where to look next

- `docs/DESIGN_RATIONALE.md` — design choices and trade-offs
- `docs/CONTEXT_HIERARCHY.md` — L0/L1/L2 spec
- `framework/agents/` — 30 worked agent examples
- `framework/hooks/` — 9 worked hook examples
- `framework/commands/` — slash command implementations
- `framework/skills/` — composable skill library (19 skills)
