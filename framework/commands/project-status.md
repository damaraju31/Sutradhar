Generate a comprehensive project status report for this project.

## Steps

1. **Read project foundation**
   - Read `CLAUDE.md` — identify active teams and tech stack
   - Read `docs/PROJECT_STATE.md` — current phase, deliverables, blockers

2. **Read team updates**
   For each active team directory in `docs/teams/`:
   - Read `STATE_UPDATE.md` — any pending state changes
   - Note: skip if it says "_No pending updates._"

3. **Scan active tasks**
   - Glob `docs/tasks/*.md` (exclude `completed/`)
   - For each task file, read the frontmatter (id, title, status, assigned_to)
   - Summarize: how many pending / in_progress / blocked

4. **Output status report**

Format the report as follows:

```
# Project Status — [PROJECT_NAME]
Generated: [today's date]

## Current Phase
Phase [N] — [Name] | Status: [Active/Not Started/Complete]

## Team Status
| Team | Head Agent | Last Update | Pending Changes |
|------|-----------|-------------|-----------------|
[one row per active team]

## Active Tasks
| ID | Title | Status | Assigned To |
|----|-------|--------|-------------|
[one row per active task, omit if none]

## Deliverables
[List checked/unchecked deliverables from PROJECT_STATE.md]

## Current Blockers
[List active blockers, or "None" if clear]

## Pending Team Updates
[List teams with pending STATE_UPDATE.md content, summarized]

## Recommended Next Actions
[3-5 concrete next steps based on current state]
```

Keep the report factual — only include what the files confirm. Do not infer or assume status.
