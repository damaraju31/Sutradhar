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
<!-- HEAD AGENT: This section is MANDATORY. Fill it BEFORE delegating to coding agent. -->
<!-- The coding agent starts from THIS — if it's incomplete, the implementation will be incomplete. -->
<!-- Use Explore subagent or targeted grep/bash to gather this information. -->

**File paths to modify:**
<!-- Exact paths the coding agent needs to touch -->

**Existing patterns to follow:**
<!-- Copy 2-3 lines showing the convention/style the agent should match -->

**Relevant imports and dependencies:**
<!-- What's already imported/available that the agent should use -->

**Related test patterns:**
<!-- How existing tests are structured — the agent should match this -->

## Files to Reference

- [List specific files the agent should read before starting]

## Acceptance Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] Tests pass
- [ ] No linter errors

---

## Implementation Plan
<!-- Coding agent: fill this AFTER Phase 1 (Context Gathering), BEFORE Phase 2 (Implementation) -->
<!-- This section survives context compaction — it IS your working memory -->

**Approach:**
<!-- How will you implement this? What order? -->

**Key patterns to follow:**
<!-- What existing patterns did you find that this should match? -->

**Risks / things that could go wrong:**
<!-- What could break? What edge cases exist? -->

## Alignment Check
<!-- Coding agent: confirm before starting Phase 2 -->
- [ ] Task requirements match what I see in the codebase
- [ ] Pre-Gathered Context file paths are still valid
- [ ] No conflicts between task spec and existing code
- [ ] If any misalignment found: STOPPED and flagged to head agent

---

## Result

<!-- Filled by coding agent on completion. Do not edit above this line. -->

### What was implemented

### Files created/modified

### Decisions made

### Issues encountered

### Test results
