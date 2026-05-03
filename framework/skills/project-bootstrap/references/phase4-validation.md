# Phase 4: Context Auditor — Agent Prompt Template

Spawn as a **sonnet** agent. Tools: Read, Grep, Glob, Bash.

## Prompt

```
You are auditing the context hierarchy that was just generated for this project.
Your job: verify claims against actual code, check coverage, and flag issues.

Write output to `.claude/context/_bootstrap/validation_report.md`.

### 1. Claim Verification

For each rule file in `.claude/rules/`:
- Read the file
- For each factual claim (pattern, constraint, convention):
  - Grep the codebase for supporting evidence
  - Mark: ✅ verified (found evidence) | ⚠️ uncertain (partial evidence) | ❌ incorrect (contradicted by code)
  - For uncertain/incorrect: note what you found instead

For each component file in `.claude/context/components/`:
- Same verification process
- Specifically check: do referenced functions/classes still exist? Are "Known Gaps" still gaps?

For each ADR in `.claude/context/decisions/`:
- Verify the decision is actually reflected in the code
- Check if any "inferred" decisions have explicit documentation elsewhere

### 2. Coverage Analysis

- List all top-level source directories with 3+ source files
- For each: does a matching rule file exist? If not, flag as "undocumented domain"
- List all files over 200 lines in source directories
- For each: does a matching component file exist? If not, assess complexity — flag if it looks like it needs one
- Count total ADRs vs estimated significant decisions (from architecture/pattern analysis)

### 3. Consistency Checks

- Do rule files reference component files that actually exist?
- Do component files reference ADRs that actually exist?
- Are ADR numbers sequential with no gaps?
- Do paths: patterns in rule files match real directories?
- Is the CLAUDE.md under 100 lines?

### 4. Completeness Checks

- Does every rule file have a `> summary` line after the title? (not a comment, actual content)
- Does every component file have a `> summary` line?
- Does every ADR have a `> summary` line and an `Evidence:` metadata field?
- Does every rule file have a `## Provenance` section with at least one entry?
- Does every rule file have a `## Limitations` section? (can be brief, but must acknowledge what's NOT covered)
- For each provenance evidence reference (e.g., "based on patterns.md"): does the referenced file exist?

### 4. Output Format

```markdown
## Validation Report

### Summary
- Rule files: X verified, Y with issues
- Component files: X verified, Y with issues
- ADRs: X verified, Y with issues
- Coverage: X/Y domains documented, Z components documented

### Claim Issues
[List each ⚠️ or ❌ finding with file, claim, and what was found instead]

### Coverage Gaps
[List undocumented domains and complex components without files]

### Consistency Issues
[List broken references, missing files, numbering gaps]

### Recommendations
[Prioritized list of fixes]
```
```
