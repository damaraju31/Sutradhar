Launch a team session for this project.

## Step 1 — Show Team Status

Read `CLAUDE.md` Active Teams table and `docs/PROJECT_STATE.md`. Display:

```
Active teams in this project:
  1. Product      → claude --agent product-cpo
  2. Engineering  → claude --agent engineering-architect
  ...

Which team do you want to launch?
```

Show only teams listed in CLAUDE.md Active Teams. If a team is not active, tell the user to run `/project-activate-team` first.

## Step 2 — Hard Prerequisite Check

Check prerequisites using these **exact file checks**. If the prerequisite file does not exist, **stop and do not provide the launch command** — tell the user what to do instead.

| Team | Prerequisite File | Blocked Message |
|------|------------------|-----------------|
| product | _(none)_ | Always launchable |
| engineering | `docs/teams/product/PRD.md` | "PRD not found. Launch the Product team first and run `/product-prd`." |
| design | `docs/teams/product/PRD.md` | "PRD not found. Launch the Product team first and run `/product-prd`." |
| devops | `docs/ARCHITECTURE.md` | "Architecture not found. Launch Engineering first and run `/engineering-architect`, then `/engineering-scaffold`." |
| security | `docs/ARCHITECTURE.md` | "Architecture not found. Launch Engineering first and design the architecture." |
| analytics | `docs/teams/product/PRD.md` | "PRD not found. Define the product first before setting up analytics." |
| business | `docs/teams/product/PRD.md` | "PRD not found. Define the product first before business analysis." |
| growth | `docs/teams/product/PRD.md` | "PRD not found. Define the product first before planning growth." |
| cx | `docs/teams/product/PRD.md` | "PRD not found. Define the product first before setting up CX." |

**No exceptions, no "launch anyway?" prompt.** The sequence exists for a reason — each team's context depends on the prior team's output.

## Step 3 — Launch (tmux or manual)

Head agents by team:
- product → `product-cpo`
- engineering → `engineering-architect`
- design → `design-lead`
- devops → `devops-lead`
- security → `security-lead`
- analytics → `analytics-lead`
- business → `business-strategist`
- growth → `growth-lead`
- cx → `cx-lead`

**First, check for Agent Teams:**

If `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` is set to `1`:
  Tell the user Agent Teams mode is available and offer it as an option:

  "Agent Teams mode detected. You can launch {team} as a teammate in the current session.
   This gives you: peer-to-peer messaging, shared task queue, idle notifications.

   Option 1 — Agent Teams (experimental):
     I'll spawn {head-agent} as a teammate in this session.

   Option 2 — tmux (stable):
     Create a tmux window for {head-agent}.

   Option 3 — Manual tab:
     Open a new terminal tab."

  If user chooses Agent Teams:
  - Use the Agent tool to spawn the head agent as a teammate
  - The head agent runs as a full session with its own context window
  - It can be reached via SendMessage from this session

  **Caveat:** When a head agent runs as an Agent Teams teammate (instead of a
  top-level `claude --agent` session), it **loses the ability to spawn subagents**
  (teammates can't spawn subagents — platform limitation). The head agent can
  still do all direct work (read, write, edit, bash, etc.) but cannot delegate
  to coding subagents. This makes Agent Teams mode best suited for:
  - Strategic/planning phases where the head agent works solo (PRD, architecture design)
  - NOT implementation phases where the head agent needs to spawn coding agents

  If user chooses tmux or manual: proceed with existing logic below.

Check if inside a tmux session: `[ -n "$TMUX" ]`

**If inside tmux:**
Create a named window and launch the agent:
```
tmux new-window -n {team}
tmux send-keys -t {team} "claude --agent {head-agent}" Enter
```
Tell the user: "Team '{team}' launched in tmux window. Switch with `Ctrl+b` then `w`."

**If NOT inside tmux:**
Offer two options:

**Option A (recommended):** Start a tmux session:
```
tmux new-session -s {project-name} -n control
```
Then re-run `/launch-team` from inside the tmux session.

**Option B:** Manual terminal tab:
```
Open a new terminal tab and run:
  claude --agent {head-agent}
```

**Important:** Head agents MUST run as `claude --agent <name>` (top-level sessions)
to retain full Agent tool access. Never spawn them as subagents.

## Step 4 — Update PROJECT_STATE.md

After giving the launch command, update `docs/PROJECT_STATE.md`:
- Set the team's "Last Update" to today's date in the Active Teams table
