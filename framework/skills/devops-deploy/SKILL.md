---
name: devops-deploy
description: >
  Configure deployment infrastructure. Sets up hosting, containers,
  environment variables, and deployment automation. Use after INFRA_SPEC exists.
---

# Configure Deployment

## Prerequisites

Run `scripts/validate.sh` first. Requires: INFRA_SPEC.md exists.

## Instructions

1. Read `docs/teams/devops/INFRA_SPEC.md` — understand target infrastructure
2. Read `docs/ARCHITECTURE.md` — understand what's being deployed
3. Configure deployment based on the infrastructure spec:

### Deployment Setup

a. **Containerization** (if applicable):
   - Write `Dockerfile` — multi-stage build, minimal final image
   - Write `docker-compose.yml` for local development
   - `.dockerignore` to exclude unnecessary files

b. **Environment configuration:**
   - `.env.example` with all required variables documented
   - Environment-specific configs (dev, staging, production)
   - Secret management strategy

c. **Infrastructure-as-code** (if applicable):
   - Terraform/CloudFormation/platform-specific config
   - Tag all resources for cost tracking

d. **Deployment automation:**
   - Integrate with CI/CD pipeline
   - Health check endpoint (`GET /health` returning 200 + service status)
   - Zero-downtime strategy: rolling deploy or blue-green
   - Rollback plan: how to revert to previous version in < 5 minutes
   - Database migration strategy: forward-compatible migrations that don't break the old version

4. Test deployment locally (docker-compose up or equivalent)
5. Update `docs/teams/devops/DEPLOY_CONFIG.md` with deployment documentation

## Rules

- Start with the simplest deployment that works. Scale when needed.
- Never hardcode secrets. Environment variables or secret managers only.
- Every resource must be tagged and trackable.
- Document cost implications for infrastructure decisions.
