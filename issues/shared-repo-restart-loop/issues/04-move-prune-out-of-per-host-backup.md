---
id: b2c788f6-f430-4375-8977-8452f2111163
title: "Move pruning out of the per-host backup"
type: issue
status: ready-for-human
blocked_by:
  - 02-partial-snapshot-is-completed-backup.md
date: 2026-11-25
labels: []
---

**What to build:** With many hosts backing up to one shared repo, each host's nightly run applies retention only to its own snapshots (`forget` scoped to its host, without pruning). Pruning, which needs an exclusive repo lock, runs as a separate prune service and timer that is enabled on just one designated host at a quiet time. Hosts' backups therefore never compete with a prune for the lock. The README documents the shared-repo setup: which host prunes, and how to enable the prune timer there. A single-host setup keeps working by enabling the prune timer on that host.

HITL: the maintainer chooses which host prunes and when, and confirms the default schedule.

Context: on 2026-11-25 several hosts sharing one restic repo looped for hours (restart counter 112 on ch-hvz-2) and each built up hundreds of snapshots. restic exited 3 ("snapshot saved" but "at least one source file could not be read"). errexit made the script stop before forget, `Restart=on-failure` re-ran it every 5 min, and the start limit (4 starts in 1260s) never triggered because each cycle takes about 9.5 min.

## Acceptance criteria

- [ ] The per-host backup run no longer prunes; its forget remains scoped to the host and to the profile's tag
- [ ] A prune service and timer exist and are installed by `make install-systemd`, but are not enabled by default
- [ ] The prune unit uses the same retry and hardening approach as the backup unit and cannot loop forever
- [ ] README explains the shared-repo layout and single-host enablement
- [ ] `PREFIX=/tmp/restic-test make install-systemd` installs the new units; `systemd-analyze verify` passes
- [ ] CHANGELOG Unreleased notes the change, including that single-host users must enable the prune timer

## Comments
