# Sutradhar

> *Sutradhar* (Sanskrit, सूत्रधार) — *thread-holder*, the director in classical Indian theatre who orchestrates the play.
>

Tmux-isolated multi-agent orchestration framework on Claude Code — file-system state sync, lifecycle hooks, cost-aware routing.

**30 specialized agents across 9 teams.** CPO, Architect, Design Lead, Frontend, Backend, DevOps, Security, Analytics, Growth, Business Strategy, Customer Experience. **9 lifecycle hooks** for security, TDD enforcement, drift tracking, and post-compaction recovery. **19 skills** for context generation, persona reviews, and team-specific workflows. **Single-command install.**

No database. No queue. No vendored runtime. Just primitives Claude Code already exposes — used opinionatedly.

---

## Why this exists

Three failure modes recur in nested-agent workflows:

1. **Context pollution.** Sub-agents inherit the parent's full context, including every prior tool call. After 30-40 turns the working window is mostly noise.
2. **Lost-in-the-middle.** LLMs follow a U-shaped attention curve — recall at the start and end of a context window is high, the middle is weak. Long planning sessions drop detail.
3. **Compaction is lossy.** Auto-compaction across `/clear` boundaries silently strips load-bearing context.

This framework picks specific answers to all three: **OS-level isolation** via tmux instead of in-process nesting, **a three-layer context hierarchy** (L0 always-loaded, L1 path-triggered, L2 on-demand) with a **deterministic health-score evaluator** that runs outside the agent, and **a context-recovery hook** that re-injects critical state after compaction.

Full design walkthrough: [`docs/DESIGN_RATIONALE.md`](docs/DESIGN_RATIONALE.md).

---

## Prerequisites

- [Claude Code CLI](https://claude.ai/code) (`claude --version` works)
- Claude Max subscription (all model usage bills here)
- macOS or Linux, bash 3.2+, Python 3
- `tmux` for parallel team sessions, `jq` recommended (`grep`/`sed` fallback exists)

---

## Install

```bash
git clone https://github.com/damaraju31/sutradhar.git
cd sutradhar
bash install.sh
```

Installs the framework to `~/.claude/skills/project-init/` and registers `/project-bootstrap` globally.

To upgrade: `git pull && bash install.sh`. To remove: `bash uninstall.sh`.

---

## Quick start

```bash
cd my-project        # any directory: greenfield, mid-build, or mature
claude
```

Then in the Claude Code session:

```
/project-bootstrap
```

Greenfield → guided interview → scaffold. Existing code → 5-phase analysis (Haiku scan → 4 parallel Sonnet analyzers → Opus synthesis → Sonnet generation → Sonnet validation) → context hierarchy written from your actual code.

When at least one team is active:

```
/launch-team
```

Pick tmux (parallel, default), manual (single team), or experimental Agent Teams mode.

Full operator's guide: [`docs/USAGE.md`](docs/USAGE.md).

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  tmux session                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │ window: prod │  │ window: eng  │  │ window: dev  │  ...      │
│  │ CPO (opus)   │  │ Architect    │  │ DevOps       │           │
│  │              │  │ (opus)       │  │ (sonnet)     │           │
│  │  └─ subagent │  │  └─ subagent │  │              │           │
│  │  └─ subagent │  │  └─ subagent │  │              │           │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘           │
│         │                 │                 │                   │
│  ───────▼─────────────────▼─────────────────▼─────────────      │
│         file-system state sync (no DB, no queue)                │
│  ───────┬─────────────────┬─────────────────┬─────────────      │
│         │                 │                 │                   │
│         └────► docs/teams/<team>/STATE_UPDATE.md                │
│                docs/teams/URGENT.jsonl                          │
│                docs/PROJECT_STATE.md  (reconciled by user)      │
└─────────────────────────────────────────────────────────────────┘

  Lifecycle hooks injected at every CLI event:
   PreToolUse  → security-guard, file-lock-guard
   PostToolUse → context-maintenance, track-changes
   SubagentStop → code-quality-gate (TDD), notify-completion, ensure-state-update
   SessionStart → context-recovery (re-injects state after compaction)
   Per turn   → statusline (real-time observability)

  Context hierarchy:
   L0  CLAUDE.md                       always loaded     ≤100 lines
   L1  .claude/rules/*.md              auto on Read      ≤50 lines each
   L2  .claude/context/components/     on-demand         ≤150 lines each
       .claude/context/decisions/      on-demand (ADRs)  ≤30 lines each

  Cost-aware model routing:
   Opus     → strategic agents (Architect, CPO, Design Lead, Business)
   Sonnet   → workforce (Frontend, Backend, Reviewer, Tester) — ~80% of work
   Haiku    → disposable scouts (Tech Explorer, monitoring, budget analysis)
```

Deeper dive: [`docs/CONTEXT_HIERARCHY.md`](docs/CONTEXT_HIERARCHY.md), [`docs/DESIGN_RATIONALE.md`](docs/DESIGN_RATIONALE.md).

---

## What's inside

| Surface | Count | Path |
|---------|------:|------|
| Agent specifications | 30 | `framework/agents/*.md` |
| Composable skills | 19 | `framework/skills/<skill>/SKILL.md` |
| Slash commands | 6 | `framework/commands/*.md` |
| Lifecycle hooks | 9 | `framework/hooks/*.sh` |
| Context-layer templates | 5 | `framework/templates/context/` |
| Context-health evaluator | 636 LOC | `scripts/context-health-score.sh` |
| Token budgeting tool | — | `scripts/token-counter.py` |

The framework is the distributable: clone the repo, `install.sh` copies it to `~/.claude/skills/project-init/`. Edits to `framework/` flow through to all installed projects on the next install run.

---

## Roadmap

Currently single-machine, CLI-only, single-developer. Items below are explicitly *deferred*, not abandoned:

- **Multi-host orchestration.** v0.1 is single-machine via tmux by design — keeps the human as the serialization point. Multi-host needs a coordinator and conflict resolution layer.
- **Provider abstraction.** Built specifically for Claude Code's lifecycle hooks, Agent tool, and skill system. Portability would require abstracting the CLI layer.
- **Web UI / dashboard.** CLI-only. Real-time observability lives in the statusline.
- **Examples library.** Worked end-to-end demos (build a SaaS MVP, wire a custom security hook, etc.) coming in a follow-up.
- **Comparison page** vs. CrewAI / AutoGen / LangGraph — opinionated positioning doc.
- **MCP server wrapper** — expose the hooks/state surface so other Claude Code instances can integrate.
- **Phoenix / observability export** — agent traces to a tracing backend.

---

## Documentation

| Doc | Purpose |
|-----|---------|
| [`docs/USAGE.md`](docs/USAGE.md) | Install, bootstrap, run teams, add agents/hooks, troubleshooting |
| [`docs/DESIGN_RATIONALE.md`](docs/DESIGN_RATIONALE.md) | Why the framework is built this way — design choices, trade-offs |
| [`docs/CONTEXT_HIERARCHY.md`](docs/CONTEXT_HIERARCHY.md) | L0/L1/L2 spec, file structure, drift management |
| `framework/agents/*.md` | 30 worked agent specifications |
| `framework/hooks/*.sh` | 9 worked lifecycle hooks |
| `framework/commands/*.md` | 6 slash command implementations |
| `framework/skills/*/SKILL.md` | 19 composable skills |

---

## Contributing

Issues and PRs welcome. The framework is opinionated by design — proposals that change the core invariants (single-machine, file-system sync, no provider abstraction) need a strong case. See [`CONTRIBUTING.md`](CONTRIBUTING.md) (forthcoming) for issue templates.

---

## License

MIT. See [`LICENSE`](LICENSE).
