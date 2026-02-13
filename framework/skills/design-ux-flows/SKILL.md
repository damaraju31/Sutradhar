---
name: design-ux-flows
description: >
  Map user experience flows from the PRD. Produces screen-by-screen
  journeys with decision points, error states, and empty states.
  Use after PRD is approved.
---

# Map UX Flows

## Prerequisites

Run `scripts/validate.sh` first. Requires: PRD exists.

## Instructions

1. Read `docs/teams/product/PRD.md` — identify all user flows from features
2. Read `docs/teams/product/USER_STORIES.md` if it exists
3. Read existing flows if iterating: `docs/teams/design/UX_FLOWS.md`
4. For each major user flow, map using `templates/UX_FLOWS.md`:

### Flow Mapping Process

a. **Identify the core flows** from MVP features. Prioritize:
   - Primary flow (the #1 thing users do)
   - Onboarding / first-time experience
   - Authentication (sign up, sign in, password reset)
b. **Map each flow screen-by-screen:**
   - What does the user see?
   - What actions can they take?
   - Where does each action lead?
   - What happens on error?
   - What does the empty state look like?
c. **Identify decision points** — where does the flow branch?
d. **Map error paths** — what goes wrong and how do we recover?
e. **Consider first-time vs. returning user** differences

5. Optionally delegate to `design-ux-researcher` for deeper analysis
6. Write to `docs/teams/design/UX_FLOWS.md`
7. Present to user for review

## Quality Checklist

- [ ] Every MVP feature has at least one mapped flow
- [ ] Every flow includes error states (not just happy path)
- [ ] Empty states defined (what users see when there's no data)
- [ ] First-time user experience considered
- [ ] Each screen lists all available actions
- [ ] Navigation between screens is explicit (no "somehow gets to...")
- [ ] Keyboard-only and screen reader paths considered for primary flow
