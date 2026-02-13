#!/bin/bash
# Validate prerequisites for engineering-implement skill

if [ ! -f "docs/ARCHITECTURE.md" ]; then
  echo "ERROR: Architecture doc not found. Run engineering-architect first."
  exit 1
fi

# Check if src/ or equivalent exists (project has been scaffolded)
if [ ! -d "src" ] && [ ! -d "app" ] && [ ! -d "lib" ]; then
  echo "ERROR: No source directory found (src/, app/, or lib/)."
  echo "Run engineering-scaffold first to set up the project."
  exit 1
fi

echo "OK: Project scaffolded. Ready to implement."
