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

## Step 3 — Output Launch Command

Once prerequisites pass, print:

```
Open a new terminal tab in this project directory and run:

  claude --agent {head-agent}

The {Team} head agent will read project context automatically and orient to the current state.
```

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

## Step 4 — Update PROJECT_STATE.md

After giving the launch command, update `docs/PROJECT_STATE.md`:
- Set the team's "Last Update" to today's date in the Active Teams table
