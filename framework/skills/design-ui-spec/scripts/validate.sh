#!/bin/bash
# Validate prerequisites for design-ui-spec skill

if [ ! -f "docs/teams/design/DESIGN_SYSTEM.md" ]; then
  echo "ERROR: Design system not found at docs/teams/design/DESIGN_SYSTEM.md"
  echo "Component specs reference design tokens from the design system."
  echo "Run the design-system skill first."
  exit 1
fi

echo "OK: Design system found. Ready to spec components."
