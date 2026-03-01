# Agent Team Framework

A full AI startup team for every software project — built on Claude Code's native primitives.

**29 agents across 9 teams:** CPO, Architect, Design Lead, DevOps, Security, Analytics, Growth, Business Strategy, and Customer Experience. Install once. Run `/project-init` in any project. Get a team.

---

## Prerequisites

- [Claude Code CLI](https://claude.ai/code) installed (`claude --version` works)
- Claude Max subscription (all usage bills here — no separate API key needed)
- macOS or Linux, bash 3.2+, Python 3

> **Important:** This framework uses Claude Code's native agent/skill/command system. It requires the Claude Code CLI — not the API or web interface.

---

## Install

```bash
git clone https://github.com/your-username/agent-team-framework.git
cd agent-team-framework
bash install.sh
```

That's it. `/project-init` is now available in every Claude Code session.

---

## Quick Start

### 1. Go to your project directory

```bash
cd my-project   # existing project, or an empty directory for a new one
```

### 2. Open Claude Code and initialize

```bash
claude
```

Then in the Claude Code session:

```
/project-init
```

Claude will ask four questions:

```
Project name?          → my-app
Description?           → A task management tool for solo developers
Tech stack?            → Next.js 14, TypeScript, Supabase, Tailwind
Teams to activate?     → 1, 2, 3  (Product, Engineering, Design — always a good start)
Coding conventions?    → (optional — add any project-specific rules)
```

After init, your project has a full `.claude/` directory with agents, skills, and commands, plus a `docs/` directory for team outputs.

### 3. Launch a team

In your control session, run:

```
/launch-team product
```

Claude outputs the exact command. **Recommended:** use tmux to manage sessions in separate windows.

```bash
# In a new tmux window (Ctrl-b c):
claude --agent product-cpo
```

> **Alternative:** Open a new terminal tab instead of a tmux window — the framework works either way. tmux is recommended because you can script window creation and keep all sessions visible in one terminal.

The CPO is live. Start with:

```
/product-ideate   → structure your raw idea
/product-prd      → write the PRD
```

### 4. Sync state (back in your control session)

After the CPO team produces output:

```
/project-sync     → merge team updates into PROJECT_STATE.md
/project-status   → full status report across all teams
```

### 5. Launch the next team

Once the PRD is approved:

```
/launch-team engineering   → gets the Architect session command
/launch-team design        → gets the Design Lead session command
```

Run each in a new tmux window (or terminal tab).

---

## How It Works

### The Session Model

You are the CEO. Each team runs as an independent `claude --agent` session in its own tmux window (or terminal tab). You switch between windows to interact with different teams — like switching Slack channels, but each "channel" is an expert AI agent with persistent memory and a team of subagents.

```
┌──────────────────────────────────────────────────────────────┐
│                    YOU (CEO / CTO)                            │
│     Switches between tmux windows (or tabs)                  │
│                                                               │
│  Window 1: Control Session    Window 2: CPO Session          │
│  ┌─────────────────────┐     ┌────────────────────────┐      │
│  │ claude               │     │ claude --agent          │      │
│  │                      │     │   product-cpo           │      │
│  │ /project-init        │     │                         │      │
│  │ /launch-team         │     │ Spawns via Agent tool:  │      │
│  │ /project-sync        │     │ ├── product-researcher  │      │
│  │ /project-status      │     │ └── product-apm         │      │
│  └─────────────────────┘     └────────────────────────┘      │
│                                                               │
│  Window 3: Architect Session  Window 4: Design Session       │
│  ┌─────────────────────┐     ┌────────────────────────┐      │
│  │ claude --agent       │     │ claude --agent          │      │
│  │   engineering-       │     │   design-lead           │      │
│  │   architect          │     │                         │      │
│  └─────────────────────┘     └────────────────────────┘      │
│                                                               │
│   All sessions share docs/ on disk. File-based coordination. │
└──────────────────────────────────────────────────────────────┘
```

### Head Agents and Subagents

Each team has a **head agent** (CPO, Architect, Design Lead, etc.) that runs at the Opus model level. Head agents think strategically and delegate detailed work to **subagents** from their team using Claude Code's built-in Agent tool.

Each subagent runs in an isolated context window — only the summary returns to the head agent. This prevents context bloat across long sessions and keeps each specialist focused on their scope.

### File-Based State — No Hidden State

Teams don't use APIs or messages to coordinate. They write output to `docs/teams/{team}/`. You run `/project-sync` to merge updates into the shared `docs/PROJECT_STATE.md`.

Every agent reads `CLAUDE.md` and `PROJECT_STATE.md` on session start — so a fresh session always picks up exactly where the last one left off. **All state is readable files in your project.**

---

## The 9 Teams

Teams are organized into three activation tiers. Activate what you need, when you need it.

### Tier 1: Core Build (activate at project start)

| Team | Head Agent | Model | Subagents | Primary Output |
|------|-----------|-------|-----------|---------------|
| **Product** | `product-cpo` | Opus | researcher, apm | PRD, user stories, competitive analysis |
| **Engineering** | `engineering-architect` | Opus | frontend, backend, reviewer, tester, tech-explorer | Architecture, code, reviews |
| **Design** | `design-lead` | Opus | ux-researcher, ui-spec | Design system, UX flows, component specs |
| **DevOps** | `devops-lead` | Sonnet | infra, monitoring | CI/CD pipeline, deploy config, infra spec |

### Tier 2: Growth (activate post-MVP)

| Team | Head Agent | Model | Subagents | Primary Output |
|------|-----------|-------|-----------|---------------|
| **Growth** | `growth-lead` | Sonnet | seo, landing | GTM strategy, launch plan |
| **CX** | `cx-lead` | Sonnet | docs, feedback | Documentation, support flows |
| **Analytics** | `analytics-lead` | Sonnet | analyst | Metrics plan, event schemas |

### Tier 3: Operations (activate for scaling / fundraising)

| Team | Head Agent | Model | Subagents | Primary Output |
|------|-----------|-------|-----------|---------------|
| **Business** | `business-strategist` | Opus | analyst, pitch | Revenue model, financial projections |
| **Security** | `security-lead` | Sonnet | auditor, privacy | Threat model, security audit |

Teams can be added or removed at any time:
```
/project-activate-team security
/project-deactivate-team cx
```

---

## Build Workflow

Skills are invoked inside team sessions. The phases enforce order — each phase produces artifacts that downstream phases depend on.

```
Phase 0: Ideation
  └── /product-ideate               → Structured idea analysis

Phase 1: Specification  (run in order — each feeds the next)
  ├── /product-prd                  → PRD (gates Engineering + Design)
  ├── /design-system                → Design tokens and system
  ├── /design-ux-flows              → User journey maps
  ├── /engineering-architect        → Technical architecture + ADRs
  └── /design-ui-spec               → Per-component specifications

Phase 2: Build  (engineering session — repeats per feature)
  ├── /engineering-scaffold         → Project structure (once)
  ├── /devops-cicd                  → CI/CD pipeline (once)
  ├── /engineering-implement        → Feature implementation
  └── /engineering-review           → Code review

Phase 3: Launch Prep
  ├── /devops-deploy                → Deployment configuration
  ├── /growth-launch-plan           → GTM strategy (if Growth active)
  └── /engineering-review           → Final comprehensive review

Phase 4: Post-Launch
  ├── Analytics setup               (if Analytics active)
  └── CX documentation setup        (if CX active)
```

**Phase gates are enforced.** `/launch-team engineering` won't run until `docs/teams/product/PRD.md` exists. This is intentional — each team's work depends on the previous team's output. If you get blocked, `/launch-team` will tell you exactly what to produce first.

---

## Commands Reference

All commands run in your **control session** (tmux window 1 or Tab 1 — plain `claude` without `--agent`).

| Command | When | What It Does |
|---------|------|-------------|
| `/project-init` | Once, before any teams | Scaffolds `.claude/`, `docs/`, team directories, copies all agents/skills/commands |
| `/launch-team <name>` | When starting a team | Checks prerequisites, outputs the exact `claude --agent` command to run |
| `/project-status` | Anytime | Full status report: phases, blockers, recent team output |
| `/project-sync` | After a team completes work | Reads `STATE_UPDATE.md` from each team, merges into `PROJECT_STATE.md` |
| `/project-activate-team <name>` | Adding a team mid-project | Adds team to `CLAUDE.md`, copies its agents and skills |
| `/project-deactivate-team <name>` | Pausing a team | Removes from active list, archives team docs |
| `/stop-all` | When shutting down | Signals all running team sessions to stop gracefully |

**Team names for `/launch-team`:** `product`, `engineering`, `design`, `devops`, `growth`, `cx`, `analytics`, `business`, `security`

---

## Project File Structure

After `/project-init`, your project looks like this:

```
your-project/
├── CLAUDE.md                          ← Auto-loaded by every agent (project identity + conventions)
│
├── docs/
│   ├── PROJECT_STATE.md               ← Single source of truth: current phase, blockers, decisions
│   ├── ARCHITECTURE.md                ← Created by Engineering team
│   ├── tasks/
│   │   ├── TASK.md.template           ← Copy this when Architect creates task files for coders
│   │   └── completed/                 ← Completed task files move here
│   ├── reviews/                       ← Code review reports from engineering-reviewer
│   └── teams/
│       ├── product/
│       │   ├── TEAM_BRIEF.md          ← Team mission and current status
│       │   ├── PRD.md                 ← Product Requirements Document
│       │   └── USER_STORIES.md
│       ├── engineering/
│       │   ├── TECH_SPEC.md
│       │   ├── API_DESIGN.md
│       │   └── ADR/                   ← Architecture Decision Records
│       ├── design/
│       │   ├── DESIGN_SYSTEM.md
│       │   ├── UX_FLOWS.md
│       │   └── UI_SPEC.md
│       ├── ACTIVITY.log               ← Append-only log of cross-team events
│       └── URGENT.jsonl               ← Urgent signals between sessions
│
└── .claude/
    ├── agents/                        ← 29 agent definition files (edit to customize)
    ├── skills/                        ← 13 skill workflows with templates
    ├── commands/                      ← 6 control commands
    ├── hooks/                         ← 6 hook scripts (activity logging, state sync)
    └── settings.json                  ← Hook configuration and tool permissions
```

---

## Customization

### Edit Agent Prompts — Instantly

After `/project-init`, open any agent file in `.claude/agents/`. The markdown body **is** the system prompt. Edit it and the change takes effect on the next session start — no restart, no rebuild.

```bash
# Make the CPO more opinionated about your specific domain
open .claude/agents/product-cpo.md

# Make the reviewer enforce your team's specific style rules
open .claude/agents/engineering-reviewer.md
```

### Add Your Own Agents

Create `.claude/agents/my-agent.md` with a YAML frontmatter block:

```yaml
---
name: my-agent
model: claude-sonnet-4-5-20250929
tools: Read, Grep, Glob, Edit, Write, Bash
---

Your agent's system prompt goes here.
```

It's immediately available: `claude --agent my-agent`

### Customize Skills and Templates

Skill templates are in `.claude/skills/{skill-name}/templates/`. Edit them to match your team's format — your company's PRD structure, your team's review checklist, your deploy runbook. The master copies in `~/.claude/skills/project-init/framework/` are untouched.

### Per-Project Isolation

Every file in `.claude/` is project-local. Changes to one project's agents never affect other projects. The master copies at `~/.claude/skills/project-init/` are only used when running `/project-init` in a new project.

---

## Resuming Sessions

Agents are designed to self-orient on startup. Even a fresh session picks up context because every agent reads `CLAUDE.md` and `docs/PROJECT_STATE.md` before acting.

```bash
# Fresh session — agent re-reads project context on start
claude --agent engineering-architect

# Resume a specific session by ID (faster startup, no re-orientation needed)
claude --agent engineering-architect -r SESSION_ID
```

Session IDs are logged by Claude Code on session start, or browse `~/.claude/projects/` for history.

---

## Upgrade

```bash
cd agent-team-framework
git pull
bash install.sh
```

`install.sh` backs up your current install before overwriting. Existing project `.claude/` directories are **not touched** — they are yours to edit and own.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `/project-init` not found | Confirm install: `ls ~/.claude/skills/project-init/SKILL.md` |
| "PRD not found" when launching Engineering | Run `/product-prd` in the Product team session first |
| Agent spawns wrong subagents | Check `tools:` field in `.claude/agents/{head-agent}.md` — an `Agent(agent1,agent2)` allowlist may be missing an agent name |
| `init.sh` fails: "python3 not found" | `brew install python3` (macOS) or `apt install python3` (Linux) |
| State looks stale after switching sessions | Run `/project-sync` in your control session, then launch a fresh team session |
| Want to reset a team's brief | Edit `docs/teams/{team}/TEAM_BRIEF.md` directly — agents read it on startup |

---

## Uninstall

```bash
bash uninstall.sh
```

Removes `~/.claude/skills/project-init/`. Does not touch any project `.claude/` directories.

---

## Contributing

PRs welcome. The implementation philosophy: agents are files, skills are folders, state is docs. Keep it simple.

Read `framework/agents/engineering-architect.md` for the agent format reference. Read `framework/skills/product-prd/SKILL.md` for the skill format reference.
