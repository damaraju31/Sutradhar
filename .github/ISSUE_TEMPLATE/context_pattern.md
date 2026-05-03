---
name: Context-rule pattern
about: Share a `.claude/rules/` template that worked well in your project
title: "[PATTERN] "
labels: context-pattern
assignees: ''
---

## Domain

What domain does this rule cover? (e.g., FastAPI backend, Next.js app router, Postgres migrations, Tailwind components, etc.)

## The rule itself

Paste the full content of your `.claude/rules/<name>.md` file:

```markdown
---
name: ...
description: ...
paths:
  - "..."
---

(rule body)
```

## What it solved

What recurring problem or correction does this rule prevent? An agent that kept making mistake X — what was the mistake?

## Validation

- How many tasks have you used this rule across?
- Has it caused any false positives (firing when it shouldn't)?
- Health-score impact (if measured)?

## Generalization

Is this specific to your stack, or could it be templated for `framework/templates/` so other users get it on bootstrap?
