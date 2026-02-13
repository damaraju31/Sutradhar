---
name: engineering-scaffold
description: >
  Set up the project directory structure, install dependencies, configure
  build tools, and create initial files based on the approved architecture.
  Use after architecture is approved.
---

# Scaffold Project

## Prerequisites

Run `scripts/validate.sh` first. Requires: ARCHITECTURE.md exists.

## Instructions

1. Read `docs/ARCHITECTURE.md` — understand the tech stack and structure
2. Read `docs/teams/engineering/TECH_SPEC.md` if it exists
3. Create the project structure based on the architecture:

### Step-by-step

a. **Initialize the project** — package manager, language runtime
b. **Install dependencies** — only what's needed for MVP. Pin versions.
c. **Create directory structure** — match the architecture's component layout
d. **Configure build tools** — bundler, compiler, linter, formatter
e. **Set up environment** — `.env.example` with all required variables (no secrets)
f. **Create entry points** — main files for frontend and backend
g. **Set up testing** — test runner, config, first example test
h. **Create .gitignore** — language/framework appropriate

4. Run the project to verify it starts without errors
5. Run tests to verify test infrastructure works
6. Update `docs/teams/engineering/TECH_SPEC.md` with actual versions and configuration

## Rules

- Install ONLY what's needed for MVP. Every dependency is a maintenance burden.
- Pin dependency versions. No `^` or `~` for primary dependencies.
- The scaffold must build and run out of the box. If it doesn't start, it's not done.
- Follow the conventions from the architecture doc. Don't invent your own structure.
