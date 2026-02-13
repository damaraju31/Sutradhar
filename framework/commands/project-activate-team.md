Add a new team to this project.

## Available Teams

```
product     — CPO, Researcher, APM
engineering — Architect, Frontend, Backend, Reviewer, Tester, Tech Explorer
design      — Design Lead, UX Researcher, UI Spec
devops      — DevOps Lead, Infra, Monitoring
security    — Security Lead, Auditor, Privacy
analytics   — Analytics Lead, Analyst
business    — Strategist, Analyst, Pitch
growth      — Growth Lead, SEO, Landing
cx          — CX Lead, Docs, Feedback
```

## Steps

1. **Show current teams** — Read `CLAUDE.md` Active Teams section. List which teams are already active.

2. **Ask which team to activate** — Show only inactive teams. Ask user to choose.

3. **Copy team files** from the global framework:
   ```bash
   FRAMEWORK=~/.claude/skills/project-init/framework
   ```

   **Agents** — copy each agent for the selected team:
   ```bash
   cp $FRAMEWORK/agents/{agent}.md .claude/agents/
   ```

   Team → agents mapping:
   - product: `product-cpo product-researcher product-apm`
   - engineering: `engineering-architect engineering-frontend engineering-backend engineering-reviewer engineering-tester engineering-tech-explorer`
   - design: `design-lead design-ux-researcher design-ui-spec`
   - devops: `devops-lead devops-infra devops-monitoring`
   - security: `security-lead security-auditor security-privacy`
   - analytics: `analytics-lead analytics-analyst`
   - business: `business-strategist business-analyst business-pitch`
   - growth: `growth-lead growth-seo growth-landing`
   - cx: `cx-lead cx-docs cx-feedback`

   **Skills** — copy skill directories:
   - product: `product-prd product-ideate`
   - engineering: `engineering-architect engineering-scaffold engineering-implement engineering-review`
   - design: `design-system design-ux-flows design-ui-spec`
   - devops: `devops-cicd devops-deploy`
   - business: `business-revenue`
   - growth: `growth-launch-plan`
   _(security, analytics, cx have no dedicated skills yet)_

4. **Create team directory**:
   ```
   docs/teams/{team}/TEAM_BRIEF.md
   docs/teams/{team}/DECISIONS.md
   docs/teams/{team}/STATE_UPDATE.md
   ```
   Write `TEAM_BRIEF.md` with head agent, model, and supporting agents listed. Use today's date.
   Write `DECISIONS.md` with empty table header.
   Write `STATE_UPDATE.md` with `_No pending updates._`.

5. **Update CLAUDE.md** — Add the new team to the Active Teams table.

6. **Update docs/PROJECT_STATE.md** — Add the team to the Active Teams table with status "Active" and today's date.

7. **Confirm** — Tell the user the team is active and provide the launch command:
   ```
   Team activated. Launch with:
   claude --agent {head-agent}
   ```
