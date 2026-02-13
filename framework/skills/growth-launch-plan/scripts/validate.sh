#!/bin/bash
# Validate prerequisites for growth-launch-plan skill

if [ ! -f "docs/teams/product/PRD.md" ]; then
  echo "ERROR: PRD not found. Need product definition before launch planning."
  exit 1
fi

echo "OK: PRD found. Ready to plan launch."
