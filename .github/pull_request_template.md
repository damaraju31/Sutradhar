## Summary

One paragraph: what does this PR change, and why?

## Type of change

- [ ] Bug fix
- [ ] New feature (agent / skill / hook / command)
- [ ] Documentation
- [ ] Refactor / cleanup
- [ ] Other: ...

## Design fit

Sutradhar is opinionated by design (see `docs/DESIGN_RATIONALE.md`). Confirm your change aligns with the existing grain, or explain the trade-off if it doesn't.

## Test plan

How did you verify this works? Include the commands you ran. For hook changes, show synthetic-JSON exercises. For install/init changes, show a clean-sandbox run.

```
# example
echo '{"tool_input":{"command":"echo hi"}}' | bash framework/hooks/security-guard.sh; echo "exit=$?"
```

## Documentation

- [ ] README updated (if user-visible)
- [ ] `docs/USAGE.md` updated (if user-facing flow changed)
- [ ] CHANGELOG entry added under "Unreleased"
- [ ] Inline comments added only where the *why* is non-obvious

## Checklist

- [ ] One concern per PR (no drive-by changes)
- [ ] Commits are logical (not one mega-commit, not 20 micro-commits)
- [ ] No personal info, secrets, or project-specific paths
- [ ] Tested on macOS or Linux (specify which)
- [ ] `bash` 3.2+ compatible
