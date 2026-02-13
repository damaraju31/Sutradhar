#!/bin/bash
# Validate prerequisites for devops-cicd skill

if [ ! -f "docs/ARCHITECTURE.md" ]; then
  echo "ERROR: Architecture doc not found. Run engineering-architect first."
  exit 1
fi

if [ ! -d "src" ] && [ ! -d "app" ] && [ ! -d "lib" ]; then
  echo "ERROR: No source directory found. Run engineering-scaffold first."
  exit 1
fi

echo "OK: Project scaffolded. Ready to set up CI/CD."
