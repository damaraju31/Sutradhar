# Design System

## Brand Direction

**Product tone:** [Professional / Playful / Minimal / Bold / etc.]
**Target audience:** [From PRD]

## Colors

### Primary Palette

| Token | Value | Usage |
|-------|-------|-------|
| `--color-primary` | | Main brand color, primary CTAs |
| `--color-primary-hover` | | Hover state for primary |
| `--color-primary-light` | | Backgrounds, subtle highlights |
| `--color-secondary` | | Supporting brand color |

### Neutral Palette

| Token | Value | Usage |
|-------|-------|-------|
| `--color-neutral-50` | | Page background |
| `--color-neutral-100` | | Card/surface background |
| `--color-neutral-200` | | Borders, dividers |
| `--color-neutral-400` | | Placeholder text |
| `--color-neutral-600` | | Secondary text |
| `--color-neutral-800` | | Primary text |
| `--color-neutral-900` | | Headings |

### Semantic Colors

| Token | Value | Usage |
|-------|-------|-------|
| `--color-success` | | Success states, confirmations |
| `--color-warning` | | Warning states, caution |
| `--color-error` | | Error states, destructive actions |
| `--color-info` | | Informational states |

## Typography

| Token | Value | Usage |
|-------|-------|-------|
| `--font-sans` | | Primary font family |
| `--font-mono` | | Code, technical content |
| `--text-xs` | | Captions, labels |
| `--text-sm` | | Secondary text, metadata |
| `--text-base` | | Body text |
| `--text-lg` | | Large body, subheadings |
| `--text-xl` | | Section headings |
| `--text-2xl` | | Page headings |
| `--font-normal` | 400 | Body text |
| `--font-medium` | 500 | Emphasis, labels |
| `--font-semibold` | 600 | Subheadings |
| `--font-bold` | 700 | Headings, CTAs |

## Spacing

**Base unit:** 4px

| Token | Value | Usage |
|-------|-------|-------|
| `--space-1` | 4px | Tight spacing (icon gaps) |
| `--space-2` | 8px | Compact elements |
| `--space-3` | 12px | Default element gap |
| `--space-4` | 16px | Standard padding |
| `--space-6` | 24px | Section padding |
| `--space-8` | 32px | Large gaps |
| `--space-12` | 48px | Section margins |
| `--space-16` | 64px | Page-level spacing |

## Border Radius

| Token | Value |
|-------|-------|
| `--radius-none` | 0 |
| `--radius-sm` | 4px |
| `--radius-md` | 8px |
| `--radius-lg` | 12px |
| `--radius-full` | 9999px |

## Shadows

| Token | Value |
|-------|-------|
| `--shadow-sm` | |
| `--shadow-md` | |
| `--shadow-lg` | |
| `--shadow-xl` | |

## Z-Index

| Token | Value | Usage |
|-------|-------|-------|
| `--z-base` | 0 | Default content |
| `--z-dropdown` | 10 | Dropdowns, popovers |
| `--z-sticky` | 20 | Sticky headers |
| `--z-modal` | 30 | Modals, dialogs |
| `--z-toast` | 40 | Toast notifications |

## Breakpoints

| Token | Value | Description |
|-------|-------|-------------|
| `sm` | 640px | Large phone / small tablet |
| `md` | 768px | Tablet |
| `lg` | 1024px | Small desktop |
| `xl` | 1280px | Large desktop |

## Component Primitives

### Button

| Variant | Background | Text | Border |
|---------|-----------|------|--------|
| Primary | `--color-primary` | white | none |
| Secondary | transparent | `--color-primary` | `--color-primary` |
| Ghost | transparent | `--color-neutral-600` | none |
| Danger | `--color-error` | white | none |

**Sizes:** sm (h-8, text-sm), md (h-10, text-base), lg (h-12, text-lg)

### Input

**States:** default, focus, error, disabled
**Border:** `--color-neutral-200` → focus: `--color-primary`

## Implementation

### Tailwind Config

```javascript
// tailwind.config.js extension
// [Generated based on tokens above]
```

### CSS Custom Properties

```css
:root {
  /* [Generated from tokens above] */
}
```
