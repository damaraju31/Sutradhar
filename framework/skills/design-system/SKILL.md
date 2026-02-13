---
name: design-system
description: >
  Generate a design token system from the PRD. Produces color palette,
  typography scale, spacing, and implementation artifacts (Tailwind config,
  CSS custom properties). Use after PRD is approved.
---

# Design System

## Prerequisites

Run `scripts/validate.sh` first. Requires: PRD exists.

## Instructions

1. Read `docs/teams/product/PRD.md` — understand the product, audience, and tone
2. Read existing design system if iterating: `docs/teams/design/DESIGN_SYSTEM.md`
3. Generate the design system using the template at `templates/DESIGN_SYSTEM.md`

### Design Process

a. **Define brand direction** — present 2-3 color palette options based on product type and audience. User selects.
b. **Build the token system:**
   - Colors: primary, secondary, neutral, semantic (success/warning/error/info), surfaces, text
   - Typography: font families (max 2), size scale (xs through 2xl), weight scale, line heights
   - Spacing: base unit, scale (4px base recommended: 4, 8, 12, 16, 24, 32, 48, 64)
   - Border radius: scale (none, sm, md, lg, full)
   - Shadows: scale (sm, md, lg, xl)
   - Z-index: named layers (base, dropdown, sticky, modal, toast)
   - Breakpoints: mobile-first (sm: 640, md: 768, lg: 1024, xl: 1280)
c. **Generate implementation artifacts:**
   - Tailwind config extension (or full config)
   - CSS custom properties file
d. **Define component primitives** — Button, Input, Card, Badge patterns with token usage

4. Write to `docs/teams/design/DESIGN_SYSTEM.md`
5. Present to user for approval

## Quality Checklist

- [ ] All colors have semantic names (not `blue-500` but `primary`, `error`, `surface`)
- [ ] Color contrast meets WCAG 2.1 AA (4.5:1 for text, 3:1 for UI elements)
- [ ] Typography scale is consistent and limited (no arbitrary sizes)
- [ ] Spacing uses a consistent base unit
- [ ] Dark mode considered (even if not implemented in MVP)
- [ ] Implementation artifacts are valid and usable code
