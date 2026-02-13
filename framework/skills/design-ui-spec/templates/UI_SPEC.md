# UI Component Specifications

## Component Index

| Component | Category | Status |
|-----------|----------|--------|
| | Shared / Page-specific | Draft / Final |

---

## {ComponentName}

**Category:** Shared | Page-specific
**Used in:** [List of screens/flows]

### Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| | | | | |

### Visual States

| State | Background | Text | Border | Other |
|-------|-----------|------|--------|-------|
| Default | `token` | `token` | `token` | |
| Hover | | | | |
| Active | | | | |
| Focus | | | | `outline: 2px solid --color-primary` |
| Disabled | | | | `opacity: 0.5, cursor: not-allowed` |
| Loading | | | | |
| Error | | | | |
| Empty | | | | |
| Success | | | | |

### Responsive Behavior

| Breakpoint | Changes |
|-----------|---------|
| Mobile (< sm) | |
| Tablet (sm-lg) | |
| Desktop (> lg) | |

### Accessibility

- **Role:** [ARIA role if not implicit from HTML element]
- **ARIA attributes:** [aria-label, aria-describedby, etc.]
- **Keyboard:** [Tab, Enter, Escape, Arrow keys behavior]
- **Focus:** [Focus ring style, focus order]
- **Screen reader:** [Announced text]

### Animations

| Trigger | Property | Duration | Easing |
|---------|----------|----------|--------|
| Hover | | 150ms | ease-in-out |
| Focus | | 100ms | ease-out |
| State change | | 200ms | ease-in-out |

### Content Limits

| Content | Max | Overflow |
|---------|-----|----------|
| | | truncate / wrap / ellipsis |
