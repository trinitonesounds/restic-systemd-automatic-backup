---
id: c94b65bf-c88d-40b6-ba57-a2fd23125383
title: "Cut the git ties to upstream"
type: issue
status: ready-for-human
blocked_by:
  - 06-start-changelog-at-1-0-0.md
date: 2026-11-25
labels: []
---

**What to build:** The repo stops tracking erikw's upstream. The `upstream` remote is removed, and the `upstream-master` branch is deleted both locally and on `origin`. Future upstream fixes are ported by hand. This is HITL because deleting a remote branch can't be undone and needs the maintainer's go-ahead. See `docs/adr/0001-systemd-only-hard-fork.md` for the decision behind this.

## Acceptance criteria

- [ ] `git remote -v` shows only `origin`
- [ ] No local `upstream-master` branch and no `origin/upstream-master`
- [ ] `master` is unaffected (same commit before and after)

## Comments
