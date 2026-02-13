#!/bin/bash
# Validate prerequisites for devops-deploy skill

if [ ! -f "docs/teams/devops/INFRA_SPEC.md" ]; then
  echo "ERROR: INFRA_SPEC.md not found at docs/teams/devops/INFRA_SPEC.md"
  echo "The DevOps Lead must define infrastructure requirements first."
  exit 1
fi

echo "OK: INFRA_SPEC found. Ready to configure deployment."
