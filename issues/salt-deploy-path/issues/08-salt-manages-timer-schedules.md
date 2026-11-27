---
id: 1ea84c5d-c8c5-42c5-a31c-ce07ba3c125f
title: "Salt manages the timer schedules"
type: issue
status: ready-for-human
blocked_by:
  - 04-timer-schedules-as-drop-ins.md
  - 07-salt-deploys-pinned-release.md
date: 2026-11-27
labels: []
---

**What to build:** Each host's backup schedule is set in the pillar, and Salt writes it as a timer drop-in and reloads systemd. Schedules are no longer edited by hand in unit files.

HITL: the change is in the Salt repo; current schedules must be carried over exactly.

## Acceptance criteria

- [ ] Each host's current schedule is copied into the pillar before the switch
- [ ] Salt writes the drop-in and reloads systemd only when it changes
- [ ] `systemctl list-timers` on every host shows the same next-run times before and after
- [ ] Hand-edited timer units are replaced with stock ones

Context: during the 2026-11 restic-01 restart-loop recovery, the fixed backup script had to be deployed by hand. The Salt checkout could not fetch, hosts were updated by `git pull` plus a manual scripts-only make, and installed versions were checked by comparing md5 sums. That rollout also turned up drifted units and stale restic binaries.
