## Context Hierarchy

This project maintains structured context files so that knowledge persists across sessions and reaches the right agents automatically.

### How Context is Organized

```
CLAUDE.md                              ← L0: Always loaded. Critical rules, project overview.
.claude/rules/{domain}.md              ← L1: Auto-loaded when working in matching file paths.
.claude/context/components/{name}.md   ← L2: Read on demand when modifying that component.
.claude/context/decisions/ADR-*.md     ← Decisions: Read on demand when relevant.
```

L1 rules auto-load via `paths:` frontmatter when you **Read** a file matching the pattern (Grep and Glob do not trigger rule loading). To ensure domain context loads, read at least one file in the domain before making changes. L2 files are referenced from L1 rules as "Deep Dives" and read explicitly when you need component-level detail.

### When to Create Context Files

**New domain or module** (3+ files representing a distinct concern):
Create `.claude/rules/{domain}.md` with `paths:` frontmatter pointing to the directory. Use the template at `.claude/context/templates/rule.md.template`. A domain rule should be ≤50 lines — summaries and pointers, not encyclopedias.

**Complex component** (non-obvious behavior, known gaps, specific constraints):
Create `.claude/context/components/{name}.md`. Use the template at `.claude/context/templates/component.md.template`. A component file should be ≤150 lines.

**Architectural decision** (non-obvious choice that future sessions must respect):
Create `.claude/context/decisions/ADR-{NNN}-{slug}.md`. Use the template at `.claude/context/templates/adr.md.template`. An ADR should be ≤30 lines. Number sequentially.

### When to Update Context Files

**After fixing a documented known gap**: Update the component file immediately. Mark: `FIXED (date) — description`.

**After changing an established pattern**: Update the relevant rule file. If the old pattern is important to note, add to anti-patterns: "Previously used X. Now use Y because Z."

**After making an architectural decision**: Create an ADR. Even small decisions matter if they'd be non-obvious to the next session.

**After discovering a new constraint or anti-pattern**: Add to the relevant rule or component file.

### What Goes Where

| Content | Location | Size Limit | Why |
|---|---|---|---|
| Universal rules, project overview | `CLAUDE.md` | ≤100 lines | Always loaded — every line costs context |
| Domain patterns, key constraints | `.claude/rules/` | ≤50 lines each | Auto-loaded by path — keep lean |
| Component internals, known gaps | `.claude/context/components/` | ≤150 lines each | Read on demand — can be detailed |
| Architectural decisions | `.claude/context/decisions/` | ≤30 lines each | Read on demand — one decision per file |

### Promotion Rule

Information promotes UP the hierarchy only when it applies broadly:
- Component learning → domain rule: when it applies to all components in that domain
- Domain pattern → CLAUDE.md: when it applies across all domains
- Project insight → user CLAUDE.md or skill: when it applies across projects

Most knowledge stays at L2. Don't promote eagerly.

### Completion Protocol — Two Outputs Rule

Every task that modifies source code produces TWO outputs: (1) the code change, (2) any needed context updates. Before declaring work complete:

- [ ] New domain created → `.claude/rules/{domain}.md` exists with paths frontmatter
- [ ] Known gap fixed → component file updated, gap marked `FIXED (date)`
- [ ] Pattern changed → rule file updated, old pattern noted in Limitations
- [ ] Non-obvious decision made → ADR created with Evidence field filled
- [ ] New anti-pattern discovered → added to relevant rule or component file
- [ ] Context file modified → Provenance section updated with date, your identity, what changed
- [ ] Useful discovery during work → filed into relevant context file (don't let insights die in chat history)
