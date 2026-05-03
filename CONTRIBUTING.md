# Contributing to Sutradhar

Thanks for the interest. This is a personal framework I've open-sourced after using it on my own projects — contributions, issues, and forks are welcome. Please read this short guide before opening a PR.

---

## Before you start

**Sutradhar is opinionated by design.** A lot of the value comes from specific, narrow choices: tmux for session isolation, file-system for state, single-machine, Claude Code only, no provider abstraction. PRs that fight these invariants need a strong case — see [`docs/DESIGN_RATIONALE.md`](docs/DESIGN_RATIONALE.md) for the reasoning. PRs that *extend* the framework along its existing grain are easy to merge.

**Good fits:**
- New agents, skills, hooks, or commands that follow the existing patterns
- Bug fixes in hooks, install/init scripts, the health-score evaluator
- Documentation improvements (especially worked examples)
- Cross-platform fixes (Linux compatibility, shell quirks)
- New context-hierarchy templates or rule patterns

**Likely-rejected without prior discussion:**
- Adding a database, queue, or coordinator
- Provider-agnostic abstraction layers
- A web UI / dashboard
- Multi-host orchestration (this is roadmap, but the design needs to land first)
- Vendoring runtime dependencies

If you're unsure, open an issue first to discuss before writing code.

---

## Reporting issues

Use the issue templates in [`.github/ISSUE_TEMPLATE/`](.github/ISSUE_TEMPLATE/):

- **Bug report** — something broke. Include OS, Claude Code version, repro steps, and any hook output.
- **Feature / agent / hook suggestion** — propose a new capability with a use case.
- **Context-rule pattern** — share a `.claude/rules/` template that worked well in your project.

Before filing, please search existing issues. For security issues, do not file publicly — see [Security](#security) below.

---

## Pull requests

### Branching

Fork, branch from `master`. Branch name: short and descriptive (e.g., `fix-jq-fallback`, `add-redis-rule`). One concern per PR.

### Commit hygiene

- Group commits into logical units by layer (hooks → templates → skills → install). Not one mega-commit, not 20 micro-commits.
- Commit messages: one-line subject in imperative mood (`add Redis context rule template`, not `added` or `adds`). Body explains the *why* if non-obvious. The PR description is the place for full context.
- No co-author lines unless someone actually co-authored.

### What we look for

- Existing patterns followed. New agents look like the existing 30, new hooks look like the existing 9, new skills follow the SKILL.md frontmatter.
- Bash scripts: `set -u` minimum, fail open on parse errors (return 0), use `jq` with `grep`/`sed` fallback.
- Hook contracts honored: read JSON on stdin, return 0 (allow) or 2 (block with a stderr message).
- Documentation updated. New agent → reference it in `framework/agents/` and update `docs/USAGE.md` if user-visible. New rule pattern → add a worked example in the relevant template.
- No personal information, secrets, or project-specific paths.

### Local development

Clone, then test in a sandbox:

```bash
# Fork-and-clone
git clone https://github.com/<you>/sutradhar.git
cd sutradhar

# Install to a non-default path for safe testing
SUTRADHAR_TEST_DIR="$HOME/.claude/skills/sutradhar-test"
mkdir -p "$SUTRADHAR_TEST_DIR"
# (Edit install.sh's INSTALL_DIR locally if you want to fully isolate)

# Run install
bash install.sh

# Test in a throwaway project
mkdir -p /tmp/sutradhar-test && cd /tmp/sutradhar-test
claude  # then run /project-bootstrap
```

For hook changes, exercise them with synthetic JSON before relying on Claude Code:

```bash
echo '{"tool_input":{"command":"echo hi"}}' | bash framework/hooks/security-guard.sh; echo "exit=$?"
echo '{"tool_input":{"command":"rm -rf /"}}' | bash framework/hooks/security-guard.sh; echo "exit=$?"
```

For health-score changes, run against a real project:

```bash
bash scripts/context-health-score.sh --verbose
```

---

## Style

- **Bash:** POSIX-compatible where possible, `bash` 3.2+ minimum. No `bashisms` that break on macOS's stock bash.
- **Markdown:** ATX headers (`#`), reference-style links acceptable, no HTML unless necessary.
- **Agent prompts:** opinions in the system prompt, not in the description. Keep `description` ≤200 chars, body unbounded but tiered (head agents ~300 lines, sub-agents ~150 lines, Haiku scouts ~80 lines).
- **Skill SKILL.md:** clear `description` triggers (the skill auto-loader matches on this), `disable-model-invocation: true` if not meant to be auto-invoked.

---

## License

By contributing, you agree your contributions are licensed under the MIT License (the same as the rest of the project).

---

## Security

If you find a security issue (especially in `security-guard.sh`, `file-lock-guard.sh`, or any code that touches the filesystem from agent input), please do **not** open a public issue. Email the maintainer directly via the address on their GitHub profile. I'll respond within a week.

---

## Code of conduct

Be respectful. Disagreement is fine; rudeness is not. I reserve the right to close conversations or block contributors who consistently undermine that.
