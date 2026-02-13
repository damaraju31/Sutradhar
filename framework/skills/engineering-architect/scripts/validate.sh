#!/bin/bash
# Validate prerequisites for engineering-architect skill

if [ ! -f "docs/teams/product/PRD.md" ]; then
  echo "ERROR: PRD not found at docs/teams/product/PRD.md"
  echo "Run the product-prd skill first to create the PRD."
  exit 1
fi

echo "OK: PRD found. Ready to design architecture."
