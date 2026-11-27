---
id: 6aab8f4a-9a12-4037-b2d3-4cfe77f5561f
title: "Per-host timer schedules as drop-ins"
type: issue
status: ready-for-agent
blocked_by: []
date: 2026-11-27
labels: []
---

**What to build:** The shipped backup timer stays stock. A host sets its own schedule in a per-profile timer drop-in (a `.timer.d` override), which is documented with an example. Reinstalling the units never wipes a host's schedule. Today every host's timer file is edited by hand, and none matches any version in the repo.

## Acceptance criteria

- [ ] README documents setting a profile's schedule via a drop-in, including resetting `OnCalendar` before setting a new one
- [ ] An example drop-in ships in the repo but is not installed by default
- [ ] Verified on a scratch install: with the drop-in in place, `systemctl list-timers` shows the overridden schedule after a reinstall of the units
- [ ] CHANGELOG entry

Context: during the 2026-11 restic-01 restart-loop recovery, the fixed backup script had to be deployed by hand. The Salt checkout could not fetch, hosts were updated by `git pull` plus a manual scripts-only make, and installed versions were checked by comparing md5 sums. That rollout also turned up drifted units and stale restic binaries.
