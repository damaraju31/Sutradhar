---
name: product-prd
description: >
  Write or refine a Product Requirements Document. Structures the product
  idea into problem statement, target users, features, MVP scope, and success
  metrics. Use when starting a new product or revising an existing PRD.
---

# Write PRD

## Prerequisites

Run `scripts/validate.sh` first. Requires: project initialized.

## Instructions

1. Read `docs/teams/product/PRD.md` if it exists (refine mode) or start fresh (create mode)
2. Read `docs/PROJECT_STATE.md` for current phase context
3. If creating: interview the user with these questions (skip any already answered):
   - What problem are you solving? For whom?
   - How do they solve it today? What's painful about that?
   - What's your unfair advantage or unique insight?
   - What does success look like in 6 months?
4. Structure the PRD using the template at `templates/PRD.md`
5. Apply ICE scoring (Impact × Confidence × Ease, each 1-10) to every feature
6. Separate features into: MVP (P0), Phase 2 (P1), Nice-to-have (P2)
7. Flag every assumption: `ASSUMPTION: [X] — validate by [method]`
8. Write the PRD to `docs/teams/product/PRD.md`
9. Present to the user for review before finalizing

## Quality Checklist

- [ ] Problem statement is one clear sentence
- [ ] Target user is specific (not "everyone")
- [ ] MVP scope is ruthlessly small — only the core job-to-be-done
- [ ] Every feature has ICE score and priority
- [ ] Success metrics are measurable (not "users like it")
- [ ] Assumptions are flagged with validation methods
- [ ] No technical implementation details (that's the Architect's job)
