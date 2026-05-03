---
name: project-bootstrap
description: "Set up the context hierarchy for any project — greenfield, mid-build, or mature. Analyzes the codebase, extracts patterns and decisions, generates scoped context files (.claude/rules/, .claude/context/), and configures the framework. Replaces /project-init with a stage-aware setup. Use when: starting a new project, onboarding to an existing codebase, or setting up the agent framework for the first time."
disable-model-invocation: true
---

# Project Bootstrap

Sets up the agent team framework with a project-aware context hierarchy. Works at any project stage.

For detailed agent prompt templates, read files in `references/` within this skill's directory.

## Step 0: Detect Project Stage

Check what exists in the current directory:

| Signal | Greenfield | Mid-Build | Mature |
|---|---|---|---|
| Source code files (*.py, *.ts, etc.) | None | Some (<50 files) | Many (50+) |
| Git history | None or <10 commits | 10-100 commits | 100+ commits |
| Existing CLAUDE.md | None | Maybe | Likely |
| Existing .claude/ directory | None | Maybe | Maybe |
| Existing docs/ | None | Maybe | Likely |

Run this detection:
```bash
# Count source files
find . -type f \( -name "*.py" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.rb" -o -name "*.kt" -o -name "*.kts" -o -name "*.swift" -o -name "*.c" -o -name "*.cpp" -o -name "*.cs" -o -name "*.ex" -o -name "*.exs" -o -name "*.php" -o -name "*.scala" -o -name "*.dart" \) -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/venv/*" -not -path "*/__pycache__/*" -not -path "*/build/*" -not -path "*/dist/*" 2>/dev/null | wc -l
# Count git commits
git rev-list --count HEAD 2>/dev/null || echo "0"
# Check for existing setup
ls -la CLAUDE.md .claude/ docs/ 2>/dev/null
```

Announce the detected stage to the user and confirm before proceeding.

---

## Flow A: Greenfield (no code)

### A1: Structured Interview

Ask the user (all in one message to reduce back-and-forth):

```
I'll set up your project. Please answer:

1. **What are you building?** (product description, 2-3 sentences)
2. **Tech stack?** (language, framework, database, key dependencies — or "recommend")
3. **Key constraints?** (compliance, performance, budget, deployment target)
4. **Team structure?** Choose which teams you need:
   1. Product (CPO, researcher)
   2. Engineering (architect, frontend, backend, reviewer, tester)
   3. Design (lead, UX researcher, UI spec)
   4. DevOps (lead, infra, monitoring)
   5. Security (lead, auditor, privacy)
   6. Analytics, 7. Business, 8. Growth, 9. CX
   
   Recommended starting point: 1,2,3 (or just 2 for solo dev)
5. **Coding conventions?** (any established patterns, or "use framework defaults")
```

If user says "recommend" for tech stack, provide a reasoned recommendation based on their product description and constraints.

### A2: Framework Setup (MUST run before content generation)

First, set up the directory structure so templates and rules infrastructure exist:

Run the init script with the collected parameters:

```bash
bash ~/.claude/skills/project-init/scripts/init.sh \
  --name "PROJECT_NAME" \
  --description "PROJECT_DESCRIPTION" \
  --stack "TECH_STACK" \
  --teams "TEAM1,TEAM2" \
  --conventions "CODING_CONVENTIONS" \
  --date "$(date +%Y-%m-%d)"
```

If the user chose no teams (solo dev, context-only setup), run with `--teams ""` or skip the teams flag — init.sh should handle this gracefully. If init.sh doesn't support zero teams, create the directory structure manually:
```bash
mkdir -p .claude/agents .claude/skills .claude/commands .claude/hooks .claude/rules .claude/context/components .claude/context/decisions .claude/context/templates .claude/agent-memory
```

This creates:
- .claude/agents/, .claude/skills/, .claude/hooks/
- .claude/rules/ (with context-protocol.md)
- .claude/context/ (with templates)
- docs/ structure, team briefs (if teams selected)

### A3: Foundation Generation (runs AFTER A2 — templates must exist)

Now generate the initial context content using the installed templates:

**L0 — Update CLAUDE.md**: The base CLAUDE.md was created by init.sh. Update it with:
- Project identity and purpose (from interview)
- Critical rules derived from stack (e.g., "async everywhere" for FastAPI, "Decimal for money" for fintech)
- Context navigation section pointing to .claude/rules/ and .claude/context/

**Initial ADRs**: Create decisions using templates at `.claude/context/templates/adr.md.template`:
- ADR-001: Tech stack choice (language + framework + DB + rationale)
- ADR-002: Architecture pattern (monolith/microservice/modular monolith)
- Any decisions from the user's interview answers

### A4: Handoff

Present summary and suggest next steps based on selected teams.

---

## Flow B: Mid-Build / Mature (code exists)

### B0: Pre-flight

**Check for previous bootstrap (re-run detection):**
First, check if context files already exist beyond the default `context-protocol.md`:
```bash
EXISTING_RULES=$(ls .claude/rules/*.md 2>/dev/null | grep -v context-protocol.md | wc -l | tr -d ' ')
EXISTING_COMPONENTS=$(ls .claude/context/components/*.md 2>/dev/null | wc -l | tr -d ' ')
EXISTING_ADRS=$(ls .claude/context/decisions/ADR-*.md 2>/dev/null | wc -l | tr -d ' ')
```

If any of these are >0, this project was previously bootstrapped. Present the user with options:
```
Existing context detected: {EXISTING_RULES} rule files, {EXISTING_COMPONENTS} component files, {EXISTING_ADRS} ADRs.

Options:
1. Re-analyze and MERGE (keep existing, add new findings, flag conflicts)
2. Re-analyze and REPLACE (backup existing to .claude/context/_backup/, regenerate)
3. Refresh only (run /context-refresh instead — verifies and updates existing files)
```

If user chooses option 2, backup first:
```bash
BACKUP_DIR=".claude/context/_backup_$(date +%s)"
mkdir -p "$BACKUP_DIR"
cp -r .claude/rules/ "$BACKUP_DIR/rules/" 2>/dev/null
cp -r .claude/context/components/ "$BACKUP_DIR/components/" 2>/dev/null
cp -r .claude/context/decisions/ "$BACKUP_DIR/decisions/" 2>/dev/null
```

If user chooses option 3, invoke `/context-refresh` and stop bootstrap.

**Check if the framework is already set up:**
- If `.claude/agents/` exists AND `.claude/rules/` exists → framework already initialized. Skip to B1 (context generation only).
- If `.claude/agents/` exists but `.claude/rules/` does NOT exist → framework v1 (pre-context-hierarchy). Create the missing context directories and copy templates:
  ```bash
  mkdir -p .claude/rules .claude/context/components .claude/context/decisions .claude/context/templates .claude/context/_bootstrap
  ```
  Copy context templates from the framework if available. Then proceed to B1.
- If `.claude/agents/` does NOT exist → framework not initialized. Ask user: "Do you want the full team setup or just the context hierarchy?" If teams, run the team interview (same as A1 steps 4-5) then run `init.sh`. If context-only, create minimal structure manually. Then proceed to B1.

Ensure these directories exist (create if missing):
- `.claude/rules/`
- `.claude/context/components/`
- `.claude/context/decisions/`
- `.claude/context/templates/`
- `.claude/context/_bootstrap/` (temporary, cleaned up in B6)

### B1: Quick Scan (Phase 1)

Spawn a **haiku** agent to produce a project profile. Read `${CLAUDE_SKILL_DIR}/references/phase1-scan.md` for the full agent prompt.

The agent scans: directory structure, tech stack detection, entry points, dependencies, DB models, test locations, existing docs, size metrics.

Output: a structured project profile written to `.claude/context/_bootstrap/project_profile.md`.

Wait for completion. Announce findings to the user: "Found a FastAPI + PostgreSQL project with X files across Y directories. Z test files. Existing docs: [list]. Proceeding to deep analysis."

### B2: Deep Analysis (Phase 2)

Spawn **4 sonnet agents in parallel**. Read `${CLAUDE_SKILL_DIR}/references/phase2-analysis.md` for all four agent prompts.

Each agent reads the project profile from Phase 1 and focuses on one lens:

1. **Pattern Extractor** → `.claude/context/_bootstrap/patterns.md`
   - Service/module structure patterns
   - Error handling conventions
   - Database access patterns
   - API conventions
   - Logging and config patterns

2. **Architecture Mapper** → `.claude/context/_bootstrap/architecture.md`
   - Component inventory and ownership
   - Data flow map
   - External integrations
   - Database schema overview
   - Background jobs, events, message flows

3. **Decision Archaeologist** → `.claude/context/_bootstrap/decisions.md`
   - Decisions inferred from code patterns (with confidence level)
   - Decisions found in git history (major refactors, migrations)
   - Decisions found in docs/comments
   - Open questions (ambiguous intent)

4. **Fragility Scanner** → `.claude/context/_bootstrap/fragility.md`
   - High-churn files (git log analysis)
   - Complex modules (size + cyclomatic complexity)
   - Pattern deviations (does X in most places, Y here)
   - TODO/FIXME/HACK inventory
   - Untested code paths

Wait for all 4 to complete.

**Verify Phase 2 outputs before proceeding.** Check that all 4 files exist and are non-empty:
- `.claude/context/_bootstrap/patterns.md`
- `.claude/context/_bootstrap/architecture.md`
- `.claude/context/_bootstrap/decisions.md`
- `.claude/context/_bootstrap/fragility.md`

If any are missing or empty, report which agent failed and ask the user:
1. **Re-run** the failed agent only (reconstruct its prompt from the reference file)
2. **Proceed** with partial results (synthesis will note which analysis is missing)
3. **Abort** and investigate

Announce: "Analysis complete. Found X patterns, Y components, Z inferred decisions, W fragile areas."

### B3: Synthesis (Phase 3)

This is YOUR job as the orchestrator (opus). Do not delegate this phase. Read all 4 Phase 2 outputs and think carefully.

**Step 3a — Identify domains:**
From the architecture map and patterns, identify the natural domain boundaries. A domain is a directory (or set of directories) that represents a distinct business concern. Look for:
- Directories with 3+ source files that have cohesive purpose
- Directories that other code imports from as a unit
- Directories with distinct patterns or conventions

**Step 3b — Draft the hierarchy:**
For each identified domain, draft what goes where:
- L0 (CLAUDE.md): Critical rules that apply everywhere. Universal patterns. Project overview.
- L1 (rules per domain): Domain-specific patterns, constraints, integration points.
- L2 (components): Complex components with non-obvious behavior, known gaps.
- Decisions: Each inferred decision becomes a candidate ADR.

**Step 3c — Present to user for confirmation:**
Show the proposed hierarchy:
```
## Proposed Context Hierarchy

### L0 — CLAUDE.md (always loaded)
- [list critical rules]
- [list universal patterns]

### L1 — Domain Rules (auto-loaded by path)
- ingestion/ (paths: ["ingestion/**"]) — [brief description]
- analytics/ (paths: ["analytics/**"]) — [brief description]
- ...

### L2 — Component Deep-Dives (read on demand)
- account_resolution — [why it needs a dedicated file]
- dispatcher — [why it needs a dedicated file]
- ...

### Decisions (ADRs to create)
- ADR-001: [decision] (confidence: high/inferred)
- ADR-002: [decision] (confidence: high/inferred)
- ...

### Questions for You
- [ambiguous decisions that need human input]
- [patterns that could be intentional or accidental]
```

Wait for user to confirm, adjust, or answer questions.

**CRITICAL: Write the confirmed hierarchy to disk before proceeding.** Context may be compacted between this step and B4. Write the confirmed structure (domains, components, decisions, any user modifications) to `.claude/context/_bootstrap/confirmed_hierarchy.md`. The B4 agent reads this file — it must survive context compaction.

### B4: Generation (Phase 3 continued)

After user confirmation, spawn a **sonnet** agent to write all context files. Read `${CLAUDE_SKILL_DIR}/references/phase3-generation.md` for the agent prompt.

Pass to the agent:
- The confirmed hierarchy structure
- All Phase 2 analysis outputs
- The context file templates (from .claude/context/templates/)
- Size constraints (rules ≤50 lines, components ≤150 lines, ADRs ≤30 lines)

The agent writes:
- `.claude/rules/{domain}.md` for each confirmed domain
- `.claude/context/components/{name}.md` for each confirmed component
- `.claude/context/decisions/ADR-{NNN}-{slug}.md` for each confirmed decision
- Updated `CLAUDE.md` in lean L0 format (if user approves CLAUDE.md modification)

### B5: Validation (Phase 4)

Spawn a **sonnet** agent to audit the generated context. Read `${CLAUDE_SKILL_DIR}/references/phase4-validation.md` for the agent prompt.

The agent:
- Reads each generated context file
- Verifies claims against actual code (grep for referenced functions, classes, patterns)
- Flags: verified / uncertain / incorrect per claim
- Checks coverage: domains without rules, complex components without files
- Produces: `.claude/context/_bootstrap/validation_report.md`

Present the validation report to the user. Fix any issues found.

### B6: Cleanup and Handoff

Archive the validation report, then remove the temporary bootstrap directory:
```bash
cp .claude/context/_bootstrap/validation_report.md .claude/context/bootstrap_validation.md 2>/dev/null
rm -rf .claude/context/_bootstrap/
```

Announce completion:
```
Context hierarchy is live:
- X domain rules in .claude/rules/
- Y component files in .claude/context/components/
- Z architectural decisions in .claude/context/decisions/
- Context protocol active (auto-reminds on missing/stale context)

Next steps:
- Rules auto-load when you work in matching directories
- Run /context-refresh periodically to catch drift
- Run /context-create to add new context files as the project evolves
```

---

## Handling Existing CLAUDE.md

For mid-build/mature projects with an existing CLAUDE.md:

1. Read the existing CLAUDE.md completely
2. Identify content that should stay in L0 (critical rules, project overview)
3. Identify content that should move to L1 rules (domain-specific details)
4. Identify content that should move to L2 components (component internals)
5. Identify content that should become ADRs (documented decisions)
6. Present the proposed migration to the user:
   ```
   ## Proposed CLAUDE.md Migration
   
   KEEP in CLAUDE.md (L0):
   - [list of sections/content]
   
   MOVE to .claude/rules/:
   - [section] → .claude/rules/{domain}.md
   
   MOVE to .claude/context/components/:
   - [section] → .claude/context/components/{name}.md
   
   EXTRACT as ADRs:
   - [decision] → .claude/context/decisions/ADR-{NNN}.md
   ```
7. Only modify CLAUDE.md after explicit user approval
8. If user declines, generate new context files WITH the extracted content but leave CLAUDE.md untouched (content will exist in both places temporarily)
