#!/bin/bash
# Validate prerequisites for product-prd skill

if [ ! -f "CLAUDE.md" ]; then
  echo "ERROR: No CLAUDE.md found. Run /project-bootstrap first."
  exit 1
fi

if [ ! -d "docs/teams/product" ]; then
  echo "ERROR: Product team directory not found. Run /project-bootstrap first."
  exit 1
fi

echo "OK: Prerequisites met for product-prd."
