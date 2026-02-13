Archive and deactivate a team from this project.

## Steps

1. **Show active teams** — Read `CLAUDE.md` Active Teams section. List which teams are currently active.

2. **Ask which team to deactivate** — Warn the user this will archive team files but not delete them. Ask for confirmation.

3. **Check for blockers** — Before proceeding:
   - Read `docs/teams/{team}/STATE_UPDATE.md` — if there are pending updates, ask: "This team has pending state updates. Sync first with /project-sync or they will be archived unprocessed. Continue?"
   - Check `docs/tasks/` for any in-progress tasks assigned to this team's agents. If found, warn the user.

4. **Archive team files**:
   ```bash
   mkdir -p docs/teams/_archived/{team}
   mv docs/teams/{team}/* docs/teams/_archived/{team}/
   rmdir docs/teams/{team}
   ```

5. **Remove agent files** from `.claude/agents/`:
   Remove only the files for this team's agents (do not remove agents shared with other teams — though currently none are shared).

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

6. **Remove skill directories** from `.claude/skills/` for this team (same team→skills mapping as /project-activate-team).

7. **Update CLAUDE.md** — Remove the team's row from the Active Teams table.

8. **Update docs/PROJECT_STATE.md** — Change the team's status to "Archived" in the Active Teams table.

9. **Confirm**:
   ```
   {Team} team deactivated. Files archived to docs/teams/_archived/{team}/.
   To reactivate later, run /project-activate-team.
   ```
