---
description: "Initialize a new AI Agent Team project in the current directory"
disable-model-invocation: true
---

# /project-init

Initialize the current directory as an AI Agent Team project.

## Prerequisites

Run from your project root (where `package.json`, `pyproject.toml`, or similar lives — or an empty directory for a new project).

## Step 1 — Gather Project Info

Ask the user for the following (ask all at once in a single message):

1. **Project name** — short slug, no spaces (e.g., `my-app`)
2. **Project description** — 1-2 sentences describing what it does
3. **Tech stack** — comma-separated (e.g., `Next.js 14, TypeScript, Supabase, Tailwind CSS`)
4. **Coding conventions** — optional (e.g., `functional components only, no classes`). If not provided, use default.

## Step 2 — Select Teams

Show the user this team menu and ask them to pick (comma-separated numbers). Recommend starting with 1, 2, 3:

```
1. product     — CPO, Researcher, APM (strategy, PRD, user research)
2. engineering — Architect, Frontend, Backend, Reviewer, Tester (builds the product)
3. design      — Design Lead, UX Researcher, UI Spec (design system, flows, specs)
4. devops      — DevOps Lead, Infra, Monitoring (CI/CD, deployment, infra)
5. security    — Security Lead, Auditor, Privacy (threat modeling, audit, compliance)
6. analytics   — Analytics Lead, Analyst (metrics, dashboards, data)
7. business    — Strategist, Analyst, Pitch (revenue model, business analysis)
8. growth      — Growth Lead, SEO, Landing (GTM, SEO, conversion)
9. cx          — CX Lead, Docs, Feedback (support, documentation, feedback)

Recommended starting teams: 1, 2, 3
```

## Step 3 — Run Init Script

Map selected numbers to team names:
`1=product 2=engineering 3=design 4=devops 5=security 6=analytics 7=business 8=growth 9=cx`

Construct the comma-separated teams string (e.g., `product,engineering,design`), then run:

```bash
bash ~/.claude/skills/project-init/scripts/init.sh \
  --name "PROJECT_NAME" \
  --description "PROJECT_DESCRIPTION" \
  --stack "TECH_STACK" \
  --teams "TEAM1,TEAM2,TEAM3" \
  --conventions "CODING_CONVENTIONS" \
  --date "YYYY-MM-DD"
```

Use today's date for `--date`. If no conventions were provided, omit the `--conventions` flag.

## Step 4 — Report Results

After the script runs:
- If successful: show the launch commands printed by the script
- If failed: show the error and ask the user to fix it

## Step 5 — Next Steps

After successful init, tell the user:

```
Project initialized. Next steps:

1. Open a new terminal tab for each team
2. Run the launch command shown above for that team
3. Each head agent will greet you and orient to the project
4. Start with the Product team — run /product-ideate or /product-prd

Your project files:
  CLAUDE.md              — project context (auto-loaded by all agents)
  docs/PROJECT_STATE.md  — project status dashboard
  docs/teams/*/          — team briefs and decision logs
  .claude/agents/        — agent definitions
  .claude/commands/      — /project-status, /project-sync, /project-activate-team
```
