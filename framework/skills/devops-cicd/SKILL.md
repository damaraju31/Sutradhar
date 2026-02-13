---
name: devops-cicd
description: >
  Set up CI/CD pipeline with GitHub Actions. Configures automated testing,
  building, and deployment workflows. Use after project is scaffolded.
---

# Set Up CI/CD Pipeline

## Prerequisites

Run `scripts/validate.sh` first. Requires: project scaffolded.

## Instructions

1. Read `docs/ARCHITECTURE.md` — understand tech stack and deployment targets
2. Read `docs/teams/devops/INFRA_SPEC.md` if it exists
3. Identify what the pipeline needs:
   - **Test stage:** run unit/integration tests on PR and push
   - **Build stage:** compile/bundle the application
   - **Deploy stage:** deploy to target environment(s)

### Pipeline Design

a. **Read project config** (package.json, Cargo.toml, go.mod, requirements.txt) to determine language/runtime. Apply language-specific caching and build steps.
b. **Start with a single workflow** — `.github/workflows/ci.yml`
c. **Test on PR:** lint + type-check + unit tests
d. **Build on merge to main:** full build + integration tests
e. **Deploy:** only after build passes, environment-specific
f. **Cache aggressively:** dependency cache (node_modules, .cargo, pip cache), build artifacts, Docker layers
g. **Keep it fast:** target < 5 min for test stage, < 10 min for full pipeline
h. **Artifact management:** upload build artifacts for deployment stage to consume

4. Write the workflow file(s)
5. Test locally if possible (`act` or similar)
6. Update `docs/teams/devops/INFRA_SPEC.md` with pipeline documentation

## Rules

- Every pipeline must have a clear purpose — no dead workflows.
- Secrets go in GitHub Secrets, never in workflow files.
- Use matrix builds only when multi-environment testing is needed.
- Pin action versions: `uses: actions/checkout@v4`, not `@latest`.
