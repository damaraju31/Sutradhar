---
name: design-ui-spec
description: >
  Write per-component UI specifications including all states, props,
  responsive behavior, and accessibility requirements. Use after
  design system is defined.
---

# Component UI Spec

## Prerequisites

Run `scripts/validate.sh` first. Requires: design system exists.

## Instructions

1. Read `docs/teams/design/DESIGN_SYSTEM.md` — all specs reference these tokens
2. Read `docs/teams/design/UX_FLOWS.md` — understand which components are needed
3. Read existing specs if iterating: `docs/teams/design/UI_SPEC.md`
4. For each component, spec using `templates/UI_SPEC.md`:

### Spec Process

a. **Identify components from UX flows** — what UI elements does each screen need?
b. **Spec each component completely:**
   - Props/API with types and defaults
   - ALL visual states (default, hover, active, focus, disabled, loading, error, empty, success)
   - Responsive behavior at each breakpoint
   - Accessibility: ARIA attributes, keyboard nav, focus management
   - Animations: transitions with duration and easing
   - Content limits: max characters, truncation, overflow
c. **Use design tokens for all values** — never hardcode colors, sizes, or spacing
d. **Start with shared components** (Button, Input, Card) before page-specific ones

5. Optionally delegate to `design-ui-spec` subagent for parallel spec writing
6. Append to `docs/teams/design/UI_SPEC.md`
7. Present to user for review

## Quality Checklist

- [ ] Every value references a design token (no hardcoded colors or sizes)
- [ ] All applicable states specified (minimum: default, hover, focus, disabled, error)
- [ ] Responsive behavior explicit at each breakpoint
- [ ] Accessibility requirements stated (ARIA, keyboard, focus order)
- [ ] Touch targets ≥ 44×44px for interactive elements
- [ ] Color contrast verified (4.5:1 for text, 3:1 for UI elements)
