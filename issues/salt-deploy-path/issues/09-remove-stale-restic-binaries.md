---
id: 73375426-75df-4b90-9831-f5c6d35b3982
title: "Remove stale restic binaries that shadow the Salt-managed one"
type: issue
status: ready-for-human
blocked_by:
  - 03-log-which-restic-each-run-used.md
date: 2026-11-27
labels: []
---

**What to build:** Salt already installs the restic binary (from its utility files). Older copies left on some hosts are found first by the unit's PATH: ch-mail-1 runs a distro-packaged restic 0.18.0, and ch-harrison-1 runs restic 0.13.1 from a different directory than the Salt-managed 0.20.0. Salt removes those leftovers (or purges the distro package), so every unit runs the managed binary.

HITL: the change is in the Salt repo and touches host packages.

## Acceptance criteria

- [ ] Every host is checked for restic binaries other than the Salt-managed one; findings are recorded under Comments
- [ ] Salt removes the leftovers or purges the package
- [ ] The per-run log line (ticket 03) shows the managed version on every host after a manual run

Context: during the 2026-11 restic-01 restart-loop recovery, the fixed backup script had to be deployed by hand. The Salt checkout could not fetch, hosts were updated by `git pull` plus a manual scripts-only make, and installed versions were checked by comparing md5 sums. That rollout also turned up drifted units and stale restic binaries.
