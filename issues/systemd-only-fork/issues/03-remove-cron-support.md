---
id: a954493b-d064-4fd6-b969-77b0b320e465
title: "Remove cron support"
type: issue
status: ready-for-agent
blocked_by:
  - 02-remove-macos-launchagent-support.md
date: 2026-11-25
labels: []
---

**What to build:** systemd is the only scheduler. The cron.d entry, the `cron_mail` helper and the `install-cron` target are gone. The README's cron setup and cron email-on-failure sections are removed, and setup docs list only systemd. No existing host uses cron, so no migration note is needed. See `docs/adr/0001-systemd-only-hard-fork.md` for the decision behind this.

## Acceptance criteria

- [ ] No cron sources, `install-cron` target or cron-related Makefile filters remain
- [ ] README has no cron setup or cron email section; the systemd email-on-failure section remains
- [ ] CLAUDE.md no longer describes cron as a scheduler
- [ ] `PREFIX=/tmp/restic-test make install-systemd` succeeds; shellcheck passes
- [ ] `grep -ri 'cron'` (excluding CHANGELOG and .git) finds nothing except unrelated words

## Comments
