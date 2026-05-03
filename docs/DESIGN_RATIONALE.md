# Design Rationale

> Why the framework is built the way it is. Read this if you're evaluating it, comparing it to alternatives, or trying to understand a design choice that looks unusual at first.

The short version: most "multi-agent" frameworks paper over the same three failure modes — context pollution from nested agents, lost-in-the-middle attention drift on long sessions, and inconsistent behavior across `/clear` or auto-compaction. This framework picks specific, opinionated answers to all three using primitives Claude Code already exposes (tmux, hooks, skills, file-system state). No vendored runtime, no custom protocol, no database.

---

## 1. Process isolation over in-process nesting

**The problem.** Spawning a sub-agent from inside another agent inherits the parent's context — every prior tool call, every read file, every system reminder. Long sessions accumulate token noise that the child agent then has to wade through. There are also nesting-depth limits on the platform, so deep delegation chains hit a wall.

**The choice.** Each team's head agent runs as an independent top-level `claude --agent <name>` session, in its own tmux window. Sub-agents are spawned via the built-in `Agent` tool inside that session and are discarded on completion, recycling the context window automatically.

**Trade-offs.**
- Pro: true parallel execution, independent context budgets, restart-one-team without affecting others.
- Pro: the single-machine constraint is intentional — keeps the user as the serialization point, removes the need for a queue or coordinator.
- Con: doesn't scale across hosts. Multi-host orchestration is on the roadmap, not v0.1.

---

## 2. File-system state, not a database

**The problem.** Multiple parallel sessions need to share state. A database or message queue would solve this, but adds a dependency and a new class of bugs (write conflicts, replication lag, schema drift).

**The choice.** Pull-based file sync. Each team writes to `docs/teams/<team>/STATE_UPDATE.md`. The user runs `/project-sync`, which reads all pending updates, reconciles them deterministically, and updates `docs/PROJECT_STATE.md`. Cross-team urgencies go to `docs/teams/URGENT.jsonl` (append-only, JSON-per-line, checked by every agent on `SessionStart`).

**Why this works.** The human is the serialization point. There are no concurrent writers to a single file. Every state transition passes through the operator, which is the right granularity for a tool that's meant to keep a human in the loop on architectural decisions.

**Trade-offs.**
- Pro: zero infrastructure. `git diff` is your audit log.
- Con: requires running `/project-sync` periodically. Not autonomous.

---

## 3. Context engineering as a first-class concern

**The problem.** Liu et al. (2023) showed LLMs follow a U-shaped attention curve — they recall information at the *start* and *end* of their context window much better than the middle. Auto-compaction is lossy. After 30-40 turns, the working context is mostly noise. This isn't a Claude-specific failure; it's a property of the architecture.

**The choice.** A three-layer context hierarchy that keeps load-bearing rules in the primacy zone, lazy-loads domain rules on-demand, and pulls deep component context only when the agent explicitly asks.

| Layer | Where | Loaded When | Size cap |
|-------|-------|-------------|----------|
| L0 — Project identity | `CLAUDE.md` | Auto, every session | ≤100 lines |
| L1 — Domain rules | `.claude/rules/*.md` | Auto, when the agent reads a file matching the rule's `paths:` glob | ≤50 lines each |
| L2 — Component context | `.claude/context/components/*.md`, `decisions/ADR-*.md` | On-demand (agent reads explicitly) | ≤150 lines components, ≤30 lines ADRs |

Rules fire on `Read` operations only — not on `Grep` or `Glob`. This prevents context inflation during search.

**Health is measurable.** `scripts/context-health-score.sh` is a deterministic 0-100 evaluator (Coverage / Freshness / Accuracy / Completeness) that runs *outside* the agent. It can't be gamed by the LLM because the LLM doesn't run it. Static analysis on file references against actual source code; dates against git history.

**Worst-case context budget across all layers loaded simultaneously: ~940 lines.** Well within a 200k token window.

---

## 4. Cost-aware model routing

Three Claude tiers, three roles:

- **Opus** — strategic reasoning only. Architect, CPO, Design Lead, Business Strategist. These agents plan, synthesize, and decide. They never write production code directly.
- **Sonnet** — the workforce. Frontend, Backend, Reviewer, Tester, all spec writers. TDD implementation, detailed analysis. ~80% of total agent invocations.
- **Haiku** — disposable scouts. Tech Explorer, monitoring, budget analysis. Spawned in parallel for high-volume codebase scans where the cost of getting it wrong is zero (just respawn).

**Prompt caching makes the cultural-DNA layer free.** The ~10,500-token system overhead (CLAUDE.md + agent prompt + tool definitions) is cached after turn 1 — repeat-prefix costs drop ~90%. This is why `CLAUDE.md` is allowed to carry organizational principles without paying for them every turn.

---

## 5. Hooks as middleware, not magic

Nine bash hooks at four lifecycle events (`PreToolUse`, `PostToolUse`, `SubagentStop`, `SessionStart`). Each receives structured JSON on stdin, parses it, returns an exit code (0=allow, 2=block).

The four most consequential ones:

- **Security guard** — regex-blocks 18+ destructive command patterns at `PreToolUse:Bash`. Includes patterns that prevent agents from modifying the safety hooks themselves (the recursion problem — an agent that can edit the security guard can disable it).
- **File-lock guard** — blocks `Edit`/`Write` operations targeting any file in the safety infrastructure (security guard, file-lock guard, context-health-score). Same problem, different attack surface.
- **Code quality gate** — runs the test suite at `SubagentStop` for frontend/backend agents. Exit 2 (block) on failure sends the agent back to fix. Includes infinite-loop guard via `stop_hook_active`.
- **Context recovery** — re-injects `PROJECT_STATE.md`, `URGENT.jsonl`, the agent's `TEAM_BRIEF.md`, and any active plan after auto-compaction. Survives the lossy compaction event that would otherwise drop the agent's working memory.

All hooks parse JSON with `jq`, with a `grep`/`sed` fallback for environments without `jq`. Tested explicitly.

---

## 6. Plan-then-clear for long-running heads

**The problem.** Head agents (CPO, Architect, Design Lead) run long sessions. By turn 30-40 the context is mostly stale exploration results. Compaction drops detail; the agent loses thread.

**The choice.** Two-phase execution with a persistent bridge.

1. **PLAN phase** — agent explores, writes a self-contained `PLAN_{feature}.md` to disk.
2. **BRIDGE** — agent writes a pointer to `docs/ACTIVE_PLAN.md` and into its agent memory (redundancy on purpose). The context-recovery hook and `CLAUDE.md` recovery instructions ensure the plan is rediscovered after `/clear`.
3. **EXECUTE phase** — fresh context. Agent reads the high-signal plan and only the plan.

This is the lightweight version of what Anthropic's own [extended-thinking + scratchpad](https://docs.anthropic.com/en/docs/build-with-claude/extended-thinking) patterns address. The framework just makes it explicit and persistent.

---

## 7. Two outputs from every coding agent

Frontend and backend agents are required to produce *two* outputs per task: a code change AND a context update. If they changed a UI pattern, the matching `.claude/rules/` file gets updated. If they made a non-obvious decision, an ADR is written. Every context-file edit appends to that file's `## Provenance` section.

**Why.** Without this rule, context files drift from the code over weeks until they're worse than no context at all. The two-outputs rule and the context-maintenance hook (which logs every source modification) keep drift bounded. The health-score evaluator quantifies remaining drift on demand.

---

## 8. What the framework deliberately does not do

- **No autonomous loop.** The user is always the serialization point. `/project-sync` is a manual command. This is a feature.
- **No provider abstraction.** Built specifically for Claude Code's lifecycle hooks, Agent tool, and skill system. Portability would require abstracting the CLI layer; that work isn't free and isn't on the v0.1 roadmap.
- **No web UI.** CLI-only. Statusline gives real-time observability inside the terminal where the work happens.
- **No multi-host orchestration.** Single machine, tmux-based. Constraint by design for v0.1; multi-host is roadmap.

---

## Further reading

- `docs/CONTEXT_HIERARCHY.md` — operational guide to L0/L1/L2 file structure
- `docs/USAGE.md` — how to install, bootstrap a project, and run teams
- `framework/skills/project-bootstrap/SKILL.md` — the bootstrap orchestration pipeline
- `framework/commands/launch-team.md` — team launch mechanics, including tmux and Agent Teams modes
