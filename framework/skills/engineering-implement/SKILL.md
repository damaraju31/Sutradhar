---
name: engineering-implement
description: >
  Implement a feature by creating a task file and delegating to the
  appropriate coding subagent (frontend or backend). Use when ready
  to build a specific feature from the PRD.
---

# Implement Feature

## Prerequisites

Run `scripts/validate.sh` first. Requires: project scaffolded.

## Instructions

1. Read `docs/teams/product/USER_STORIES.md` — identify the story to implement
2. Read `docs/ARCHITECTURE.md` and `docs/teams/engineering/API_DESIGN.md`

### Feature Decomposition

Before creating task files, break the feature into implementation units:
- **DB changes** — new tables, columns, migrations (→ engineering-backend)
- **API endpoints** — new routes, request/response shapes (→ engineering-backend)
- **Frontend components** — new UI, state management, API integration (→ engineering-frontend)
- **Order:** DB → API → Frontend. Each unit should be independently shippable.
- **Size:** Each task = 1-3 hours of work. If bigger, split further.

3. Create a task file at `docs/tasks/TASK_{number}_{slug}.md` using the template at `docs/tasks/TASK.md.template`. Fill it out as follows:

```markdown
---
id: TASK_{number}
title: {Short title}
status: pending
assigned_to: {engineering-frontend | engineering-backend}
created_by: engineering-architect
created_at: {YYYY-MM-DD}
completed_at:
depends_on: [{TASK_id if blocked by another task, else empty}]
---

## Description

[What needs to be built. Be specific — this is the primary context the coding agent uses.]

## Context

- Story: {reference to USER_STORIES.md story ID}
- PRD: docs/teams/product/PRD.md (relevant section)
- Architecture: docs/ARCHITECTURE.md (relevant section)
- Design: docs/teams/design/UI_SPEC.md (if frontend work)

## Files to Reference

- [Specific files the agent should read — be exact, not general]

## Acceptance Criteria

- [ ] [Technical criterion 1]
- [ ] [Technical criterion 2]
- [ ] Tests pass
- [ ] No linter errors

---

## Result

<!-- Filled by coding agent on completion. Do not edit above this line. -->

### What was implemented

### Files created/modified

### Decisions made

### Issues encountered

### Test results
```

4. Spawn the appropriate subagent via Task tool with the task file reference
5. After completion, review the Result section
6. If the task involves both frontend and backend:
   - Create separate task files for each
   - Implement backend first (API must exist before frontend integrates)
   - Then implement frontend

## Rules

- One task file per implementation unit. Don't bundle unrelated work.
- Backend before frontend when both are needed.
- Review the result before marking complete — read the actual code, not just the summary.
