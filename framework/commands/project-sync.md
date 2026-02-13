Synchronize all team state updates into `docs/PROJECT_STATE.md`.

## Steps

1. **Read current state**
   - Read `docs/PROJECT_STATE.md` — current phase, deliverables, blockers, decisions table

2. **Collect team updates**
   For each directory in `docs/teams/`:
   - Read `STATE_UPDATE.md`
   - If it contains a `## State Update Request` section (not just "_No pending updates._"):
     - Extract: proposed phase change, completed deliverables, new decisions, resolved/new blockers
     - Record the team name and extracted data

3. **Process updates**
   For each team with pending updates:

   a. **Decisions** — append new decisions to `docs/teams/{team}/DECISIONS.md`:
      ```
      | N | [Decision text] | [Date] | [Context] |
      ```

   b. **Reset STATE_UPDATE.md** — overwrite with:
      ```
      # State Update — [Team] Team

      <!-- Written by head agent after completing work. Processed by /project-sync. -->

      _No pending updates._
      ```

4. **Update PROJECT_STATE.md**

   Apply all collected changes:
   - **Last Updated** → today's date
   - **Completed deliverables** → check off items confirmed by team updates
   - **Key Decisions** → prepend new rows to the decisions table (latest first)
   - **Blockers** → add new blockers; remove resolved ones
   - **Team table** → update "Last Update" dates for synced teams
   - **Phase** → only advance the phase if ALL deliverables for current phase are checked off AND user confirms. Ask before advancing.

5. **Report what changed**

   Output a sync summary:
   ```
   Sync complete — [date]

   Teams synced: [list]
   Decisions captured: [N]
   Deliverables checked off: [list or "none"]
   Blockers added: [list or "none"]
   Blockers resolved: [list or "none"]
   Phase: [unchanged / advanced to Phase N]
   ```

If no teams had pending updates, say so and skip the rest.
