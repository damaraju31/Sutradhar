---
name: context-create
description: "Create context files (domain rules, component deep-dives, architectural decisions) from templates. Use when a new domain/module needs a rule file, a complex component needs documentation, or an architectural decision needs recording. Also use when the context-maintenance hook suggests creating a rule file. Trigger phrases: 'create context', 'add rule', 'document component', 'record decision', 'create ADR'."
disable-model-invocation: true
---

# Context Create

Scaffolds context files from project templates. Three types:

## Usage

**`/context-create rule <domain>`** — Create a domain rule file
**`/context-create component <name>`** — Create a component deep-dive
**`/context-create decision <title>`** — Create an architectural decision record

## Process

### For `rule`:
1. Read the template at `.claude/context/templates/rule.md.template`
2. Ask: "What directory does this domain cover?" (e.g., `ingestion/`, `src/api/`)
3. Ask: "Brief one-line summary and 2-3 sentence description of what this domain does"
4. Create `.claude/rules/<domain>.md`:
   - Replace `{{DOMAIN_PATH}}` with the directory path (without trailing slash)
   - Replace `{{DOMAIN_NAME}}` with a human-readable title
   - Replace `{{ONE_LINE_SUMMARY}}` with the user's summary
   - Fill sections from user's description. Leave unknowns with placeholder comments.
   - Fill `## Provenance`: `YYYY-MM-DD | /context-create | Created manually`
5. Verify the file was created and the `paths:` frontmatter is valid

### For `component`:
1. Read the template at `.claude/context/templates/component.md.template`
2. Ask: "Which component? One-line summary and brief description of what it does?"
3. Create `.claude/context/components/<name>.md`:
   - Replace `{{COMPONENT_NAME}}` with a human-readable title
   - Replace `{{ONE_LINE_SUMMARY}}` with the user's summary
   - Fill "How It Works" from description. Leave unknowns with placeholder comments.
   - Fill `## Provenance`: `YYYY-MM-DD | /context-create | Created manually`
4. Ask: "Which domain rule file should reference this component?" (show existing rule files)
5. Add a pointer to the rule file's "Deep Dives" section:
   `- <ComponentName>: .claude/context/components/<name>.md`

### For `decision`:
1. Read the template at `.claude/context/templates/adr.md.template`
2. Determine next ADR number: count existing files in `.claude/context/decisions/` matching `ADR-*.md`, add 1. Zero-pad to 3 digits.
3. Ask: "What was decided and why? What alternatives were considered? How was this discovered (explicit discussion, inferred from code, git history)?"
4. Create `.claude/context/decisions/ADR-<NNN>-<slug>.md`:
   - Replace `{{NUMBER}}` with the padded number
   - Replace `{{TITLE}}` with the decision title
   - Replace `{{ONE_LINE_SUMMARY}}` with a one-line summary
   - Replace `{{DATE}}` with today's date (YYYY-MM-DD)
   - Replace `{{SOURCE_OF_DECISION}}` with how it was discovered
   - Fill Context, Decision, and Implications from user's input
   - Fill Alternatives Considered
5. If the decision affects specific components, suggest updating those component files' "Related Decisions" section.

## Validation
- Rule files: verify `paths:` frontmatter is syntactically correct (YAML array of glob strings)
- Component files: verify the referenced rule file exists and the pointer was added
- ADR files: verify the number is unique and sequential
- All files: verify they are under size limits (rules ≤50 lines, components ≤150 lines, ADRs ≤30 lines)
