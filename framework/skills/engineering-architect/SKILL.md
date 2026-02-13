---
name: engineering-architect
description: >
  Design technical architecture from a PRD. Produces system architecture,
  tech stack decisions, API design, database schema, and ADRs.
  Use after PRD is approved.
---

# Design Architecture

## Prerequisites

Run `scripts/validate.sh` first. Requires: PRD exists.

## Instructions

1. Read `docs/teams/product/PRD.md` — understand every feature and constraint
2. Read `docs/ARCHITECTURE.md` if it exists (iteration mode)
3. Design the architecture following this order:
   a. **Data model first** — entities, relationships, key queries
   b. **API layer** — endpoints, request/response shapes, auth
   c. **Component architecture** — frontend structure, state management
   d. **Infrastructure** — hosting, database, caching, external services
4. For each significant decision, write an ADR using `templates/ADR.md`
5. Present **minimum 2 options** for major decisions with trade-offs
6. Wait for user approval on tech stack and architecture direction
7. Write the architecture doc using `templates/ARCHITECTURE.md`
8. Write API contracts to `docs/teams/engineering/API_DESIGN.md`
9. Write DB schema to `docs/teams/engineering/DB_SCHEMA.md`

## Decision Framework

For every technology choice, evaluate:
- **Does it solve the problem simply?** (not "is it the most powerful?")
- **Is it boring?** (proven, documented, large community)
- **Can we switch away?** (reversibility)
- **What breaks at 10x scale?** (identify, don't solve yet)

## Quality Checklist

- [ ] Data model covers all PRD features and their relationships
- [ ] API endpoints exist for every user flow in the PRD
- [ ] Error handling strategy defined (error shapes, status codes)
- [ ] Auth strategy defined (how users authenticate and authorize)
- [ ] ADR written for every non-obvious technology choice
- [ ] No over-engineering — solve for MVP scale, flag what changes at 10x
