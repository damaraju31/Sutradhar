---
name: engineering-review
description: >
  Run a code review on recent changes. Spawns the engineering-reviewer
  subagent to analyze code for bugs, security issues, performance,
  and convention adherence. Outputs a structured review report.
---

# Code Review

## Instructions

1. Identify what to review:
   - If a task file is provided: review files listed in the task
   - If no task file: use `git diff` to find recently changed files
2. Spawn `engineering-reviewer` via Task tool with:
   - The list of files to review
   - Reference to the task file (if applicable)
   - Reference to `docs/ARCHITECTURE.md` for architectural conventions
3. The reviewer writes output to `docs/reviews/REVIEW_{task_id}.md` using the template
4. Read the review report
5. Present CRITICAL and WARNING findings to the user
6. If CRITICAL issues found: recommend fixing before merge

## Review Template

The reviewer outputs using `templates/REVIEW.md` format.

## Rules

- Never skip reviews on significant changes. Small typos can skip review.
- CRITICAL findings block the merge. WARNING findings should be fixed. SUGGESTION is optional.
- Review the reviewer's output — if findings seem incorrect, investigate before acting on them.
