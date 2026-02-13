#!/bin/bash
# Validate prerequisites for design-ux-flows skill

if [ ! -f "docs/teams/product/PRD.md" ]; then
  echo "ERROR: PRD not found at docs/teams/product/PRD.md"
  echo "UX flows are derived from product requirements."
  echo "Run the product-prd skill first."
  exit 1
fi

echo "OK: PRD found. Ready to map UX flows."
