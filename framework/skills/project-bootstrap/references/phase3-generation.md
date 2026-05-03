# Phase 3: Context File Generation — Agent Prompt Template

Spawn as a **sonnet** agent. Tools: Read, Write, Glob.

## Prompt

```
You are generating the context hierarchy files for a project. The orchestrator has
already analyzed the codebase and decided what goes where. Your job is to write
the files accurately and concisely.

Read these inputs:
1. The confirmed hierarchy structure at `.claude/context/_bootstrap/confirmed_hierarchy.md`
2. Analysis files in `.claude/context/_bootstrap/`:
   - `patterns.md` — code patterns and conventions
   - `architecture.md` — component map and data flows
   - `decisions.md` — discovered decisions
   - `fragility.md` — fragile areas and known gaps
3. Context templates in `.claude/context/templates/`:
   - `rule.md.template` — for rule files
   - `component.md.template` — for component files
   - `adr.md.template` — for ADR files
4. **CRITICAL: Read the existing `CLAUDE.md` before writing a new one.** Preserve all existing content that isn't being reorganized. Only modify/replace sections that the confirmed hierarchy specifies.
5. **Check for existing ADR files** in `.claude/context/decisions/` before numbering. Start numbering AFTER the highest existing ADR number, not from 001.

### Writing Rules

**Rule files (.claude/rules/{domain}.md)**:
- MUST be ≤50 lines
- MUST have valid `paths:` frontmatter (YAML array of glob strings)
- MUST start with a `> one-line summary` immediately after the title — this is what agents scan before deciding to read the full file
- Content: key patterns (bullets), constraints (bullets), integration points (bullets),
  limitations (what this doc doesn't cover), deep dive pointers to component files
- Include `## Provenance` at the bottom: `YYYY-MM-DD | bootstrap | Generated from {analysis files used}`
- Fill `## Limitations` from the fragility analysis — what's NOT documented, known inaccuracies
- Write SUMMARIES, not encyclopedias. If you need more detail, it goes in a component file.

**Component files (.claude/context/components/{name}.md)**:
- MUST be ≤150 lines
- MUST start with a `> one-line summary` after the title
- Content: how it works (mental model, not code walkthrough),
  contracts, known gaps, anti-patterns, related ADRs
- Include specific file:line references for key claims
- Mark known gaps with severity (from fragility analysis)
- Include `## Provenance` at the bottom: `YYYY-MM-DD | bootstrap | Generated from {analysis files used}`

**ADR files (.claude/context/decisions/ADR-{NNN}-{slug}.md)**:
- MUST be ≤30 lines
- MUST start with a `> one-line summary` after the title
- Number sequentially starting from 001
- Fill `Evidence:` metadata field — how this decision was discovered (bootstrap analysis, git history, explicit discussion, inferred from code)
- Include confidence level: confirmed | high | inferred
- For inferred decisions: note what evidence led to the inference
- Slug should be lowercase-hyphenated summary of the decision

**CLAUDE.md (if approved for modification)**:
- MUST be ≤100 lines
- Structure: project overview, tech stack, critical rules, active teams (if using framework),
  context navigation section, @import of context-protocol.md
- Everything domain-specific goes in rule files, NOT in CLAUDE.md

### Quality Checks

After writing each file:
- Count lines — reject if over limit
- Verify paths: frontmatter references real directories (use Glob)
- Verify component file pointers in rules reference files that were actually created
- Verify ADR numbering is sequential with no gaps

### Confirmed Hierarchy Structure:

[ORCHESTRATOR INSERTS THE CONFIRMED HIERARCHY HERE]
```
