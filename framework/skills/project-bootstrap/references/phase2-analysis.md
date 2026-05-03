# Phase 2: Deep Analysis — Agent Prompt Templates

Spawn all 4 as **sonnet** agents in parallel. Each reads the project profile first.

All agents: Tools: Read, Grep, Glob, Bash. Read `.claude/context/_bootstrap/project_profile.md` first.

**Git fallback**: If the project has no git history (no `.git/` directory or 0 commits), skip all `git log` and `git` commands gracefully. Report "No git history available" in the relevant sections and focus on code-based analysis only. Do not fail — produce partial findings.

---

## Agent 1: Pattern Extractor

```
Read the project profile at `.claude/context/_bootstrap/project_profile.md`.

Your job: extract the established code patterns and conventions in this codebase.
Write output to `.claude/context/_bootstrap/patterns.md`.

For each pattern category below, read 3-5 representative files and identify the
consistent patterns. Note deviations explicitly.

### Patterns to Extract:

1. **Service/Module Structure**
   - How are services organized? (class-based, function-based, static methods)
   - Method signatures (what params are standard? session? user_id? context?)
   - Import patterns (relative vs absolute, what's imported from where)

2. **Error Handling**
   - Custom exception classes? Where defined?
   - Try/except patterns (bare except? specific types? re-raise?)
   - HTTP error responses (format, status codes, error payloads)

3. **Database Access**
   - ORM patterns (session management, query building, transaction scope)
   - Common query patterns (filtering, joining, eager loading)
   - Migration conventions (naming, one-per-change vs batched)

4. **API Conventions**
   - Route naming (/api/v1/resource, /resource, etc.)
   - Request/response models (Pydantic, TypeScript interfaces, etc.)
   - Authentication pattern (middleware, decorators, dependencies)
   - Pagination, filtering, sorting patterns

5. **Logging**
   - Logger setup (stdlib, structlog, winston, etc.)
   - Log levels used and when
   - Structured vs unstructured

6. **Configuration**
   - How config is loaded (env vars, config files, settings class)
   - Secret management pattern

7. **Testing Patterns**
   - Fixture/setup patterns
   - Mock vs integration approach
   - Test naming conventions

For each pattern, provide:
- The pattern itself (concise description)
- 1-2 file:line references showing it in use
- Any deviations found (and where)

Keep the output factual. If a pattern is inconsistent, say so — don't pick a winner.
```

---

## Agent 2: Architecture Mapper

```
Read the project profile at `.claude/context/_bootstrap/project_profile.md`.

Your job: map the system architecture — components, data flow, ownership, integrations.
Write output to `.claude/context/_bootstrap/architecture.md`.

### Map the following:

1. **Component Inventory**
   For each significant directory (3+ source files):
   - Name and purpose (inferred from code, not guessed)
   - Key files and their roles
   - What it owns (data, state, behavior)
   - Approximate complexity (file count, line count)

2. **Data Flow**
   Trace the primary data paths through the system:
   - User input → processing → storage → output
   - Background job flows
   - External data ingestion flows
   - Draw these as text diagrams:
     ```
     Component A → Component B → Component C
                         ↓
                    Component D
     ```

3. **External Integrations**
   For each external service:
   - What service, what it's used for
   - How it's called (sync/async, SDK/raw HTTP)
   - Where the client code lives
   - Error handling approach

4. **Database Schema Overview**
   - Key entities and their relationships (not every column — just the model)
   - FK relationships between tables
   - Any polymorphic or JSONB patterns

5. **Background Jobs / Async Work**
   - Scheduled tasks (cron, scheduler)
   - Background workers
   - Event handlers, webhook receivers

6. **API Surface**
   - Group endpoints by router/controller
   - Note auth requirements per group
   - Note any versioning pattern

7. **Component Coupling**
   For each component, note what it imports from other components.
   Flag: tight coupling (A imports B's internals), circular dependencies.

Keep it structural — what connects to what. Save analysis for Phase 3.
```

---

## Agent 3: Decision Archaeologist

```
Read the project profile at `.claude/context/_bootstrap/project_profile.md`.

Your job: discover architectural decisions — both explicit and implicit.
Write output to `.claude/context/_bootstrap/decisions.md`.

### Sources to check:

1. **Git History** (use `git log`)
   - Look at the 50 most recent commits for: migration commits, dependency changes,
     refactoring commits, commits with long messages explaining "why"
   - `git log --oneline -50`
   - For interesting commits: `git show --stat <hash>` and read the message
   - Look for major structural changes: `git log --diff-filter=A --name-only --oneline -30`
     (files added in last 30 commits)

2. **Code Comments**
   - Search for: TODO, FIXME, HACK, NOTE, IMPORTANT, DECISION, WHY, RATIONALE
   - `grep -rn "TODO\|FIXME\|HACK\|NOTE.*:" --include="*.py" --include="*.ts" | head -50`
   - Read context around significant comments

3. **Configuration Choices**
   - Why this ORM? Why this auth provider? Why this deployment model?
   - These are often implicit — infer from what was chosen and note confidence level

4. **Existing Documentation**
   - Read README.md, ARCHITECTURE.md, any ADR files
   - Extract decisions that are already documented

5. **Code Patterns as Decisions**
   - If all services use static methods → that's a decision
   - If there's a custom base class → that's a decision
   - If errors follow a specific format → that's a decision

### Output Format

For each discovered decision:
```
### Decision: [title]
**Confidence**: confirmed (from docs/comments) | high (strong code evidence) | inferred (pattern-based)
**Source**: [where you found evidence]
**What**: [the decision itself]
**Why** (if known): [rationale, or "unknown — inferred from code"]
**Implications**: [what this constrains or enables]
```

Also include a section:
### Open Questions
- Decisions that are ambiguous — could be intentional or accidental
- Patterns that seem inconsistent — might be mid-migration or might be bugs
```

---

## Agent 4: Fragility Scanner

```
Read the project profile at `.claude/context/_bootstrap/project_profile.md`.

Your job: identify fragile, risky, or under-maintained code areas.
Write output to `.claude/context/_bootstrap/fragility.md`.

### Analysis to perform:

1. **High-Churn Files** (frequently modified)
   ```bash
   git log --format=format: --name-only --since="3 months ago" | sort | uniq -c | sort -rn | head -20
   ```
   High churn + high complexity = fragility hotspot.

2. **Large Files** (complexity risk)
   ```bash
   find . -name "*.py" -o -name "*.ts" | xargs wc -l 2>/dev/null | sort -rn | head -20
   ```
   Files over 300 lines are candidates for deep-dive documentation.

3. **Pattern Deviations**
   Compare against the codebase's own norms:
   - If 90% of services use pattern X but one uses pattern Y — flag it
   - If 90% of files handle errors one way but some don't — flag it
   - Search for bare `except:` or `except Exception:` in Python, or unhandled promise rejections

4. **TODO/FIXME/HACK Inventory**
   ```bash
   grep -rn "TODO\|FIXME\|HACK" --include="*.py" --include="*.ts" --include="*.js" | head -30
   ```
   Group by directory. High concentration = known technical debt.

5. **Test Coverage Gaps**
   - For each source directory, check if a corresponding test directory exists
   - Count: source files vs test files per directory
   - Flag directories with 0 test files

6. **Tight Coupling Signals**
   - Files that import from 5+ different directories
   - Circular import patterns (A imports B imports A)
   - God files (imported by 10+ other files)

7. **Configuration/Security Concerns**
   - Hardcoded URLs, secrets, or credentials (grep for common patterns)
   - Missing input validation at API boundaries
   - SQL string concatenation (injection risk)

### Output Format

Group findings by severity:
- **Critical** (data integrity risk, security issue)
- **High** (frequently touched + complex + undertested)
- **Medium** (pattern deviations, technical debt)
- **Low** (style inconsistencies, minor TODOs)

For each finding: file path, what the issue is, why it matters.
```
