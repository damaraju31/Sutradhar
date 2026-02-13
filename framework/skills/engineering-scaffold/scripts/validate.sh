#!/bin/bash
# Validate prerequisites for engineering-scaffold skill

if [ ! -f "docs/ARCHITECTURE.md" ]; then
  echo "ERROR: Architecture doc not found at docs/ARCHITECTURE.md"
  echo "Run the engineering-architect skill first."
  exit 1
fi

echo "OK: Architecture doc found. Ready to scaffold."
