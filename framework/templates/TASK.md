---
id: {feature}_TASK_{n}
feature: [feature-name]
title: [Short task title]
status: pending
assigned_to: [agent-name]
created_by: [agent-name or user]
created_at: [YYYY-MM-DD]
completed_at:
depends_on: []
---

## Description

[What needs to be built or done. Be specific — this is the only context the coding agent starts with.]

## Context

[Relevant decisions, constraints, or background. Link to key docs:]
- PRD reference: docs/teams/product/
- Architecture: docs/ARCHITECTURE.md
- Design specs: docs/teams/design/

## Pre-Gathered Context

<!-- Head agent: use Explore to fill this BEFORE creating the coding task.
     Write: file paths to modify, existing patterns to follow, code conventions,
     relevant imports, adjacent examples. This is the subagent's starting knowledge. -->

_To be filled by head agent before delegation._

## Files to Reference

- [List specific files the agent should read before starting]

## Acceptance Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]
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
