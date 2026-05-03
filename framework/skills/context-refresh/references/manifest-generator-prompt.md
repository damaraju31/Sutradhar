# Manifest Generator — Agent Prompt

Spawn as **haiku** agent. Tools: Bash, Glob, Grep, Read.

## Task

Analyze the codebase in the current directory and generate `.claude/context/_score_manifest.json`.
This manifest configures the health score evaluator for this specific project.

## Steps

### 1. Detect project type

Check for package manager files to identify the tech stack:
```bash
ls pyproject.toml setup.py requirements.txt 2>/dev/null  # Python
ls package.json tsconfig.json 2>/dev/null                 # Node/TypeScript
ls go.mod 2>/dev/null                                      # Go
ls Cargo.toml 2>/dev/null                                  # Rust
ls pom.xml build.gradle 2>/dev/null                        # Java
ls Gemfile 2>/dev/null                                     # Ruby
```

From the detected package file, determine: primary language, file extensions, function patterns, class patterns.

| Language | Extensions | Function Patterns | Class Patterns |
|---|---|---|---|
| Python | .py | `def %s`, `async def %s` | `class %s` |
| TypeScript/JS | .ts, .tsx, .js, .jsx | `function %s`, `const %s`, `export function %s`, `export const %s` | `class %s`, `export class %s` |
| Go | .go | `func %s`, `func (%s` | `type %s struct` |
| Rust | .rs | `fn %s`, `pub fn %s` | `struct %s`, `pub struct %s` |
| Java | .java | `void %s`, `public .* %s`, `private .* %s` | `class %s`, `public class %s` |
| Ruby | .rb | `def %s` | `class %s` |

### 2. Discover directory structure

```bash
# Get all top-level directories with source file counts
find . -type f \( -name "*.EXT" \) \
  -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/venv/*" \
  -not -path "*/__pycache__/*" -not -path "*/build/*" -not -path "*/dist/*" \
  -not -path "*/.claude/*" \
  | sed 's|^\./||' | grep '/' | cut -d'/' -f1 | sort | uniq -c | sort -rn
```

Use the detected language's extensions (not all extensions).

### 3. Classify each directory

For each top-level directory with 2+ source files, classify:

**Source** (business logic, needs context): Directories that contain application code — services, routes, models, domain logic. Indicators: imports from other source dirs, contains business logic, not purely generated or supporting.

**Infrastructure** (excluded from coverage scoring): Common infrastructure patterns — detect by name AND content:
- Names: `tests`, `test`, `spec`, `specs`, `__tests__`, `fixtures`, `e2e`
- Names: `migrations`, `alembic`, `prisma/migrations`, `db/migrate`
- Names: `scripts`, `bin`, `tools`, `deploy`, `infra`, `infrastructure`
- Names: `docker`, `.github`, `.circleci`, `.vscode`, `ci`, `cd`
- Content: directory contains only test files (files starting with `test_` or ending with `.test.ts`)
- Content: directory contains only migration files (numbered/timestamped filenames)

**Config** (excluded from coverage): `.env`, configuration directories, template directories.

When uncertain, check the directory's imports. If it imports from source domains, it's likely infrastructure (tests, scripts). If other domains import FROM it, it's likely source.

### 4. Detect sub-domains

For each source domain, check if it has sub-directories with 5+ source files:
```bash
find {domain} -type f -name "*.EXT" | sed "s|^{domain}/||" | cut -d'/' -f1 | sort | uniq -c | awk '$1 >= 5'
```

Sub-domains get their own entries with paths and file counts.

### 5. Compute freshness thresholds

For each source domain, check recent git activity:
```bash
git log --since="30 days ago" --oneline -- "{domain}/" 2>/dev/null | wc -l
```

| Commits in 30 days | Threshold |
|---|---|
| 10+ | 7 days (high churn) |
| 3-9 | 14 days (medium churn) |
| 0-2 | 30 days (low churn) |

If git is not available, use 14 days as default for all domains.

### 6. Compute structure hash

```bash
find . -type f \( -name "*.EXT" \) -not -path "*/node_modules/*" ... \
  | sed 's|^\./||' | cut -d'/' -f1 | sort | uniq -c | sort \
  | md5
```

This hash changes when directories are added, removed, or significantly grow/shrink.

### 7. Write the manifest

Write to `.claude/context/_score_manifest.json` using the schema defined in the framework.

Ensure:
- Valid JSON (test with `python3 -c "import json; json.load(open('.claude/context/_score_manifest.json'))"`)
- All source domains listed
- All infrastructure domains listed (with `category: "infrastructure"`)
- Language patterns match the detected project type
- Structure hash computed and stored
