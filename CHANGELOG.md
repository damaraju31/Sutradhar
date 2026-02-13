# Changelog

## v1.0.0 — 2026-02-12

Initial release.

### What's Included

- 29 agents across 9 teams (Product, Engineering, Design, DevOps, Security, Analytics, Business, Growth, CX)
- 13 workflow skills with templates and validation scripts
- 5 control commands (launch-team, project-status, project-sync, activate/deactivate-team)
- 4 project templates (CLAUDE.md, PROJECT_STATE.md, TEAM_BRIEF.md, TASK.md)
- init.sh: per-project initialization with team selection, tech stack configuration, and full directory scaffold

### Agent Roster (29 total)

6 merges applied during design to eliminate redundancy:
- `devops-cicd` + `devops-cloud` → `devops-infra`
- `engineering-db` → merged into `engineering-backend`
- `analytics-metrics` + `analytics-dashboard` → `analytics-analyst`
- `business-revenue` + `business-pricing` → `business-analyst`
- `cx-faq` → merged into `cx-docs`
- `growth-content` → merged into `growth-lead`
