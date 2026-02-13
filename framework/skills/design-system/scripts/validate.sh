#!/bin/bash
# Validate prerequisites for design-system skill

if [ ! -f "docs/teams/product/PRD.md" ]; then
  echo "ERROR: PRD not found at docs/teams/product/PRD.md"
  echo "The PRD defines the product audience and tone needed for design direction."
  echo "Run the product-prd skill first."
  exit 1
fi

echo "OK: PRD found. Ready to design the system."
