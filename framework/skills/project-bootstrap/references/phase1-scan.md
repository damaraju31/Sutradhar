# Phase 1: Codebase Scanner — Agent Prompt Template

Spawn as a **haiku** agent. Tools: Glob, Grep, Bash, Read.

## Prompt

```
Produce a structured project profile for the codebase in the current directory.
Write the output to `.claude/context/_bootstrap/project_profile.md`.

Gather the following (use Glob/Grep/Bash — don't read entire files unless needed):

### 1. Tech Stack
- Primary language(s) and version (check pyproject.toml, package.json, go.mod, Cargo.toml, etc.)
- Framework (check imports: fastapi, django, express, nextjs, gin, actix, etc.)
- Database (check connection strings, ORM configs, docker-compose for postgres/mysql/mongo)
- Key dependencies (requirements.txt, package.json — list top 10 by significance, not all)

### 2. Directory Structure
- List top-level directories with file counts and brief purpose inference
- Identify: source directories, test directories, config directories, docs directories
- Note any monorepo structure (multiple packages, workspaces)

### 3. Entry Points
- Main application entry (app.py, main.ts, cmd/main.go, etc.)
- Router/controller files (where HTTP endpoints are defined)
- Background job definitions (cron, scheduler, worker files)
- CLI commands if any

### 4. Database
- ORM models directory and model count
- Migration tool and migration count (alembic, knex, prisma, etc.)
- Key tables/collections (list model names from filenames)

### 5. External Integrations
- Third-party API clients (search for httpx, requests, fetch, axios calls to external URLs)
- Message queues, event buses
- Cloud services (S3, SQS, Cognito — check imports and config)
- Webhooks (inbound and outbound)

### 6. Testing
- Test framework (pytest, jest, vitest, go test)
- Test directory structure
- Approximate test count (count test files or test functions)
- Test configuration files

### 7. Existing Documentation
- List all .md files in docs/ or root directory
- Check for existing CLAUDE.md, README.md, ARCHITECTURE.md
- Check for ADR directories (docs/adr/, docs/decisions/)
- Check for API docs (openapi.json, swagger)

### 8. Size Metrics
- Total source files (excluding tests, configs, generated)
- Approximate lines of code (wc -l on source files)
- Number of database models/tables
- Number of API endpoints (count route decorators)

Format the output as a clean markdown document with these 8 sections.
Keep it factual — no analysis, no recommendations. Just the inventory.
```
