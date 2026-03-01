#!/usr/bin/env bash
# Hook: Stop → all agents
# Purpose: Remind agents to write STATE_UPDATE.md before stopping
# Exit 0 always — warning only, never blocks stop

echo "Reminder: Before stopping, ensure you've written your team's STATE_UPDATE.md" >&2
echo "in docs/teams/{your-team}/ with a summary of work completed and any blockers." >&2

exit 0
