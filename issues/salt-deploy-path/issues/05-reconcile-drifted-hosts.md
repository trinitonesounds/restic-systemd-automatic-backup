---
id: d75f9a97-5235-4290-aa88-319eaf1d2034
title: "Reconcile drifted hosts with the repo"
type: issue
status: ready-for-human
blocked_by:
  - 03-log-which-restic-each-run-used.md
  - 04-timer-schedules-as-drop-ins.md
date: 2026-11-27
labels: []
---

**What to build:** ch-mail-1, ch-salt3k-1 and ch-harrison-1 run stock units and scripts plus their own overrides. Today their backup service units match no repo version, ch-salt3k-1 has an extra env file, and ch-mail-1 and ch-harrison-1 run custom scripts and profiles. Record each difference and decide for each one: move it into the repo, a drop-in or a profile setting, or drop it.

HITL: needs host access and a decision on each difference.

## Acceptance criteria

- [ ] Each host's differences from the repo are recorded under Comments, along with the decision for each
- [ ] Each host's service unit and scripts match the repo; its local differences live only in drop-ins or profile files
- [ ] Every host's timer schedule is unchanged after the move (compare `systemctl list-timers` before and after)
- [ ] A manual backup run on each host exits 0

Context: during the 2026-11 restic-01 restart-loop recovery, the fixed backup script had to be deployed by hand. The Salt checkout could not fetch, hosts were updated by `git pull` plus a manual scripts-only make, and installed versions were checked by comparing md5 sums. That rollout also turned up drifted units and stale restic binaries.
