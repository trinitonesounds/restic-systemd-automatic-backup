---
id: bd90ff33-a69f-454a-98dc-963759fd0b81
title: "Drop GitHub workflows"
type: issue
status: ready-for-agent
blocked_by: []
date: 2026-11-25
labels: []
---

**What to build:** The inherited GitHub Actions workflows (super-linter on `main`, which never fires on this fork's `master`, and the stale-issue closer, which has nothing to act on with the local tracker) are deleted. Linting stays local with shellcheck. GitLab pipelines will come with the planned repo move, which is out of scope here. See `docs/adr/0001-systemd-only-hard-fork.md` for the decision behind this.

## Acceptance criteria

- [ ] `.github/workflows/` (and `.github/` if empty) is removed
- [ ] No README or CLAUDE.md text refers to GitHub Actions or the lint badge

## Comments
