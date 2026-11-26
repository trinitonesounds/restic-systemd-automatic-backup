---
id: 448e1a0a-d7d1-43c7-9ac8-1c55cb3d79b0
title: "Rebrand README and CLAUDE.md as the systemd-only fork"
type: issue
status: ready-for-agent
blocked_by:
  - 03-remove-cron-support.md
  - 04-drop-github-workflows.md
date: 2026-11-25
labels: []
---

**What to build:** A reader landing on the README sees a systemd-only fork of erikw/restic-automatic-backup-scheduler that credits upstream and keeps the BSD-3 license. They no longer see upstream's identity. Upstream badges (Homebrew tap, stars and forks, lint), the Homebrew/AUR install paths and the "Releasing" steps that update erikw's PKGBUILD and formulas are gone. The README and CHANGELOG link to nothing on this fork's own host, so the planned GitLab move needs no doc edits. The development notes give the correct `resticw` path for regenerating the docopt parser. CLAUDE.md is rewritten to match the new scope: a hard fork that no longer merges upstream, systemd only, and the remaining make targets. See `docs/adr/0001-systemd-only-hard-fork.md` for the decision behind this.

## Acceptance criteria

- [ ] README opens with a fork statement and a credit link to upstream; license unchanged
- [ ] No upstream badges, Homebrew/AUR references or upstream packaging release steps remain
- [ ] No links to `github.com/trinitonesounds` (or any self-host URL) in README/CHANGELOG
- [ ] Development section's `resticw` regeneration path is `bin/resticw`
- [ ] CLAUDE.md describes the hard fork and systemd-only scope; no stale references to removed schedulers, the `upstream-master` merge flow or CI

## Comments
