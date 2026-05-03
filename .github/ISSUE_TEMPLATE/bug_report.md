---
name: Bug report
about: Something broke. Report it here.
title: "[BUG] "
labels: bug
assignees: ''
---

## Summary

One sentence: what broke?

## Environment

- OS: (macOS 14, Ubuntu 22.04, etc.)
- Claude Code version: (`claude --version`)
- Shell: (bash 3.2 / 5.1 / zsh)
- `jq` version: (`jq --version`, or "not installed")
- Sutradhar version: (`cat VERSION`)

## Repro steps

1. ...
2. ...
3. ...

## Expected behavior

What did you expect to happen?

## Actual behavior

What happened? Include any error output. If a hook misbehaved, paste its stderr. If `install.sh` failed, paste the relevant output (redact paths if needed).

## Logs / files

- Hook output (if applicable)
- Relevant lines from `.claude/context/_modifications.log` or `_health_history.log`
- Output of `bash scripts/context-health-score.sh --verbose` (if context-related)

## Anything else?

Side notes, related issues, hypotheses.
